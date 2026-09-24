import 'dart:async';

import 'package:flutter/services.dart';

/// Closed hybrid-sync failure reasons. Identical to the native wire values.
///
/// [channelUnavailable] can be terminal. Flutter cannot hand the SDK a
/// `webview_flutter` instance, so events and session storage are unavailable
/// and the cookies channel is the only transport.
enum HSHybridSyncFailureReason {
  hostNotCovered,
  channelUnavailable,
  ackTimeout,
  ackMismatch,
  cookieScopeMismatch,
  pxhdConflict,
  payloadRejected,
}

enum HSHybridSyncKind { notApplicable, pending, healthy, degraded, failed }

enum HSHybridChannel { cookies, sessionStorage, events, legacy }

class HSHybridSyncState {
  const HSHybridSyncState({
    required this.kind,
    required this.isHealthy,
    this.channel,
    this.reason,
  });

  final HSHybridSyncKind kind;
  final bool isHealthy;
  final HSHybridChannel? channel;
  final HSHybridSyncFailureReason? reason;
}

class HSHybridSyncFailEvent {
  const HSHybridSyncFailEvent({
    required this.appId,
    required this.host,
    required this.reason,
    required this.isRecoverable,
  });

  final String appId;
  final String host;
  final HSHybridSyncFailureReason reason;
  final bool isRecoverable;
}

class HSHybridSyncRecoverEvent {
  const HSHybridSyncRecoverEvent({
    required this.appId,
    required this.host,
    required this.channel,
  });

  final String appId;
  final String host;
  final HSHybridChannel channel;
}

class HumanSecurity {
  static const MethodChannel _channel =
      MethodChannel('com.humansecurity.demo/human');
  static const EventChannel _events =
      EventChannel('com.humansecurity.demo/human_events');

  static bool _started = false;
  static Stream<Map<dynamic, dynamic>>? _eventStream;

  /// Starts the native SDK. Omitted [supportExternalWebViews] stays on so a
  /// caller who only sets domains still uses the cookies channel.
  static Future<void> start({
    required String appId,
    required List<String> webRootDomains,
    bool? supportExternalWebViews,
  }) async {
    await _channel.invokeMethod<void>('start', {
      'appId': appId,
      'webRootDomains': webRootDomains,
      'supportExternalWebViews': supportExternalWebViews ?? true,
    });
    _started = true;
  }

  static Future<String?> vid(String appId) {
    return _channel.invokeMethod<String>('vid', {'appId': appId});
  }

  static Future<HSHybridSyncState> hybridSyncState(String appId) async {
    final raw = await _channel.invokeMapMethod<String, dynamic>(
      'hybridSyncState',
      {'appId': appId},
    );
    return _parseState(raw ?? {});
  }

  /// Explicit cookies registration. Flutter cannot attach a WebView instance.
  /// Throws a [PlatformException] the app can catch when [start] has not run.
  /// `channelUnavailable` can be terminal because there is no non-cookie rung.
  static Future<void> setupWebView() async {
    if (!_started) {
      throw PlatformException(
        code: 'NOT_STARTED',
        message: 'Call HumanSecurity.start before setupWebView',
      );
    }
    await _channel.invokeMethod<void>('setupWebView');
  }

  static Stream<HSHybridSyncFailEvent> get onHybridSyncFailed {
    return _eventsStream().where((event) => event['event'] == 'hybridSyncDidFail').map(
      (event) {
        final reason = _reason(event['reason'] as String?);
        if (reason == null) {
          return null;
        }
        return HSHybridSyncFailEvent(
          appId: event['appId'] as String? ?? '',
          host: event['host'] as String? ?? '',
          reason: reason,
          isRecoverable: event['isRecoverable'] == true,
        );
      },
    ).where((event) => event != null).cast<HSHybridSyncFailEvent>();
  }

  static Stream<HSHybridSyncRecoverEvent> get onHybridSyncRecovered {
    return _eventsStream()
        .where((event) => event['event'] == 'hybridSyncDidRecover')
        .map((event) {
      final channel = _channelWire(event['channel'] as String?);
      if (channel == null) {
        return null;
      }
      return HSHybridSyncRecoverEvent(
        appId: event['appId'] as String? ?? '',
        host: event['host'] as String? ?? '',
        channel: channel,
      );
    }).where((event) => event != null).cast<HSHybridSyncRecoverEvent>();
  }

  static Stream<Map<dynamic, dynamic>> _eventsStream() {
    return _eventStream ??= _events.receiveBroadcastStream().map(
          (event) => Map<dynamic, dynamic>.from(event as Map),
        );
  }

  static HSHybridSyncState _parseState(Map<String, dynamic> raw) {
    final kind = _kind(raw['kind'] as String?);
    if (kind == null) {
      throw PlatformException(
        code: 'UNKNOWN_KIND',
        message: 'Unknown hybrid sync state kind: ${raw['kind']}',
      );
    }
    HSHybridChannel? channel;
    HSHybridSyncFailureReason? reason;
    if (kind == HSHybridSyncKind.healthy || kind == HSHybridSyncKind.degraded) {
      final wire = raw['channel'] as String? ?? '';
      if (wire.isNotEmpty) {
        channel = _channelWire(wire);
        if (channel == null) {
          throw PlatformException(
            code: 'UNKNOWN_CHANNEL',
            message: 'Unknown hybrid sync channel: $wire',
          );
        }
      }
    }
    if (kind == HSHybridSyncKind.failed) {
      reason = _reason(raw['reason'] as String?);
      if (reason == null) {
        throw PlatformException(
          code: 'UNKNOWN_REASON',
          message: 'Unknown hybrid sync failure reason: ${raw['reason']}',
        );
      }
    }
    return HSHybridSyncState(
      kind: kind,
      isHealthy: kind == HSHybridSyncKind.healthy,
      channel: channel,
      reason: reason,
    );
  }

  static HSHybridSyncKind? _kind(String? wire) {
    switch (wire) {
      case 'notApplicable':
        return HSHybridSyncKind.notApplicable;
      case 'pending':
        return HSHybridSyncKind.pending;
      case 'healthy':
        return HSHybridSyncKind.healthy;
      case 'degraded':
        return HSHybridSyncKind.degraded;
      case 'failed':
        return HSHybridSyncKind.failed;
    }
    return null;
  }

  static HSHybridSyncFailureReason? _reason(String? wire) {
    switch (wire) {
      case 'hostNotCovered':
        return HSHybridSyncFailureReason.hostNotCovered;
      case 'channelUnavailable':
        return HSHybridSyncFailureReason.channelUnavailable;
      case 'ackTimeout':
        return HSHybridSyncFailureReason.ackTimeout;
      case 'ackMismatch':
        return HSHybridSyncFailureReason.ackMismatch;
      case 'cookieScopeMismatch':
        return HSHybridSyncFailureReason.cookieScopeMismatch;
      case 'pxhdConflict':
        return HSHybridSyncFailureReason.pxhdConflict;
      case 'payloadRejected':
        return HSHybridSyncFailureReason.payloadRejected;
    }
    return null;
  }

  static HSHybridChannel? _channelWire(String? wire) {
    switch (wire) {
      case 'cookies':
        return HSHybridChannel.cookies;
      case 'session_storage':
        return HSHybridChannel.sessionStorage;
      case 'events':
        return HSHybridChannel.events;
      case 'legacy':
        return HSHybridChannel.legacy;
    }
    return null;
  }
}

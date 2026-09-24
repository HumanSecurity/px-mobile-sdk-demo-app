import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../human_security.dart';

class HybridView extends StatefulWidget {
  const HybridView({super.key});

  static const routeName = '/hybrid';

  @override
  State<HybridView> createState() => _HybridViewState();
}

class _HybridViewState extends State<HybridView> {
  static const appId = 'PXj9y4Q8Em';

  late final WebViewController _controller;
  String _nativeVid = '';
  String _webVid = '';
  String _stateKind = '';
  bool? _vidsMatch;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'PxVid',
        onMessageReceived: (message) async {
          final nativeVid = await HumanSecurity.vid(appId) ?? '';
          final state = await HumanSecurity.hybridSyncState(appId);
          final webVid = message.message;
          if (!mounted) {
            return;
          }
          setState(() {
            _nativeVid = nativeVid;
            _webVid = webVid;
            _stateKind = state.kind.name;
            _vidsMatch = webVid.isNotEmpty && webVid == nativeVid;
          });
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            _controller.runJavaScript(
              "(function(){var match=document.cookie.match(/(?:^|; )_pxvid=([^;]*)/);PxVid.postMessage(match?decodeURIComponent(match[1]):'');})();",
            );
          },
        ),
      )
      ..loadRequest(Uri.parse('https://sample-ios.pxchk.net/'));
  }

  @override
  Widget build(BuildContext context) {
    final matchLabel = _vidsMatch == null
        ? 'Waiting for WebView _pxvid'
        : (_vidsMatch! ? 'VID match' : 'VID differs');
    return Scaffold(
      appBar: AppBar(title: const Text('Hybrid VID')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Native VID: $_nativeVid\nWebView _pxvid: $_webVid\n$matchLabel\nhybridSyncState: $_stateKind',
            ),
          ),
          Expanded(child: WebViewWidget(controller: _controller)),
        ],
      ),
    );
  }
}

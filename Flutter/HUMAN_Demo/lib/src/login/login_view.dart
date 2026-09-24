import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../hybrid/hybrid_view.dart';
import '../settings/settings_view.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginView extends StatelessWidget {
  
  static const routeName = '/';
  static const humanPlatform = MethodChannel('com.humansecurity.demo/human');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HUMAN Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              _sendUrlRequest();
            },
            child: Text('Login'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed(HybridView.routeName);
            },
            child: const Text('Hybrid VID'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendUrlRequest() async {
    try {
      final String humanHeaders = await humanPlatform.invokeMethod('_getHumanHeaders');
      final Map<String, String> humanHeadersMap = Map.from(json.decode(humanHeaders));
      print(humanHeadersMap);
      var url = Uri.https('sample-ios.pxchk.net', '/login');
      var response = await http.get(url, headers: humanHeadersMap);
      if (response.statusCode == 403) {
        final String result = await humanPlatform.invokeMethod('_handleHumanResponse', response.body);
        print(result);
        /*
          check the result:
          'false' - not handled by the SDK
          'solved' - challenge solved
          'cancelled' - challenge cancelled
        */
        if (result == 'solved') {
          // challenge solved. you may retry the request here
          print("challenge solved");
        } else if (result == 'false') {
          // request finished successfully
          print("request finished successfully");
        } else if (result == 'cancelled') {
          // challenge cancelled
          print("challenge cancelled");
        }
      }
    } on PlatformException catch (e) {
      print("failed to get headers: '${e.message}'.");
    }
  }
}
package com.perimeterx.perimeterx

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.humansecurity.demo/human").setMethodCallHandler {
                call, result ->
            HumanManager.handleEvent(application, call, result)
        }
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.humansecurity.demo/human_events").setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    HumanManager.eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    HumanManager.eventSink = null
                }
            }
        )
    }
}

package com.bashcooler.hydit

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.core.content.edit
import io.flutter.plugin.common.MethodCall

class MainActivity : FlutterActivity() {
    val channel = "com.bashcooler.hydit/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->

                when (call.method) {
                    "saveSettings" -> saveSettings(call, result)
                    else -> result.notImplemented()
                }
            }
    }

    private fun saveSettings(call: MethodCall, result: MethodChannel.Result) {
        val host = call.argument<String>("url")
        val key = call.argument<String>("key")

        if (host == null || key == null) result.error(
            "InvalidArgument",
            "Host or key is null",
            null
        )

        context
            .getSharedPreferences("settings", MODE_PRIVATE)
            .edit {
                putString("url", host)
                putString("key", key)
            }

        result.success(null)
    }
}

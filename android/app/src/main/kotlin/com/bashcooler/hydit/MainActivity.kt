package com.bashcooler.hydit

import android.content.ContentValues
import android.os.Build
import android.util.Log
import android.provider.MediaStore
import androidx.annotation.RequiresApi
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
                    "saveFile" -> saveFile(call, result)
                    else -> result.notImplemented()
                }
            }
    }

    private fun saveSettings(call: MethodCall, result: MethodChannel.Result) {
        val host = call.argument<String>("url")
        val key = call.argument<String>("key")

        if (host == null || key == null) {
            result.error(
                "InvalidArgument",
                "Host or key is null",
                null
            )
            return
        }

        context
            .getSharedPreferences("settings", MODE_PRIVATE)
            .edit {
                putString("url", host)
                putString("key", key)
            }

        result.success(null)
    }

    private fun saveFile(call: MethodCall, result: MethodChannel.Result) {
        val bytes = call.argument<ByteArray>("bytes")
        val filename = call.argument<String>("fileName")
        val mimeType = call.argument<String>("mimeType")

        if (bytes == null || filename == null || mimeType == null) {
            result.error(
                "InvalidArgument",
                "Argument is null",
                null,
            )
            return
        }

        val values = ContentValues().apply {
            put(MediaStore.Downloads.DISPLAY_NAME, filename)
            put(MediaStore.Downloads.MIME_TYPE, mimeType)
            put(MediaStore.Downloads.IS_PENDING, 1)
        }

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return

        val uri = contentResolver.insert(
            MediaStore.Downloads.EXTERNAL_CONTENT_URI,
            values
        )

        if (uri == null) return

        contentResolver.openOutputStream(uri)?.use {
            it.write(bytes)
        }

        values.clear()
        values.put(MediaStore.Downloads.IS_PENDING, 0)
        contentResolver.update(uri, values, null, null)

        Log.d("Method channel", "Saved file $filename")

        result.success(null)
    }
}

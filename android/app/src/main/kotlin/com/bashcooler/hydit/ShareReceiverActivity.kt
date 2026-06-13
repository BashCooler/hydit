package com.bashcooler.hydit

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import java.io.File
import java.util.UUID

class ShareReceiverActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        when (intent.type) {
            "text/plain" -> handleText(intent)
            else -> handleFile(intent)
        }

        finish()
    }

    fun handleText(intent: Intent) {
        val url = intent.getStringExtra(Intent.EXTRA_TEXT)

        if (!url.isNullOrBlank()) {
            UploadWorker.enqueue(this, url)
        }
    }

    fun handleFile(intent: Intent) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            throw Exception("SDK < TIRAMISU")
        }

        val uri = intent.getParcelableExtra(
            Intent.EXTRA_STREAM,
            Uri::class.java
        ) ?: throw Exception("Empty URI")

        val cacheFile =
            File(
                cacheDir,
                UUID.randomUUID().toString()
            )

        contentResolver.openInputStream(uri)
            ?.use { input ->
                cacheFile.outputStream().use { output ->
                    input.copyTo(output)
                }
            }

        FileUploadWorker
            .enqueue(this, cacheFile.absolutePath)
    }
}

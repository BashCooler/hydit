package com.bashcooler.hydit.share

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import com.bashcooler.hydit.worker.BatchFileWorker
import com.bashcooler.hydit.worker.FileWorker
import com.bashcooler.hydit.worker.UrlWorker
import java.io.File
import java.util.UUID

class ShareReceiverActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        when (intent.action) {
            Intent.ACTION_SEND -> handleSingle(intent)
            Intent.ACTION_SEND_MULTIPLE -> handleFiles(intent)
        }

        finish()
    }

    fun handleSingle(intent: Intent) = when (intent.type) {
        "text/plain" -> handleText(intent)
        else -> handleFile(intent)
    }

    fun handleText(intent: Intent) {
        val url = intent.getStringExtra(Intent.EXTRA_TEXT)

        if (!url.isNullOrBlank()) {
            UrlWorker.enqueue(this, url)
        }
    }

    fun handleFile(intent: Intent) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return

        val uri = intent
            .getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java) ?: return

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

        FileWorker
            .enqueue(this, cacheFile.absolutePath)
    }

    fun handleFiles(intent: Intent) {
        val uris = intent.getParcelableArrayListExtra<Uri>(Intent.EXTRA_STREAM)

        val batchDir = File(
            cacheDir,
            "share_batch_${System.currentTimeMillis()}"
        )

        batchDir.mkdirs()

        uris?.forEach { uri ->
            val fileName = UUID.randomUUID().toString()

            val targetFile = File(batchDir, fileName)

            contentResolver.openInputStream(uri)?.use { input ->
                targetFile.outputStream().use { output ->
                    input.copyTo(output)
                }
            }
        }

        BatchFileWorker.enqueue(this, batchDir.absolutePath)
    }
}

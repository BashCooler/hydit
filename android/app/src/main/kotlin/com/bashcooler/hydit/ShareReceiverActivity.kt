package com.bashcooler.hydit

import android.app.Activity
import android.content.Intent
import android.os.Bundle

class ShareReceiverActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val url = intent.getStringExtra(Intent.EXTRA_TEXT)

        if (!url.isNullOrBlank()) {
            UploadWorker.enqueue(this, url)
        }

        finish()
    }
}

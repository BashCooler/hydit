package com.bashcooler.hydit.share

import android.content.BroadcastReceiver
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent

class CopyUrlReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        val url = intent?.getStringExtra("url") ?: return

        val clipboard =
            (context?.getSystemService(Context.CLIPBOARD_SERVICE) ?: return)
                    as ClipboardManager

        clipboard.setPrimaryClip(ClipData.newPlainText("URL", url))
    }
}
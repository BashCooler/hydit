package com.bashcooler.hydit.service

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.annotation.RequiresPermission
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.bashcooler.hydit.MainActivity
import com.bashcooler.hydit.R
import com.bashcooler.hydit.api.AddFileResponse
import com.bashcooler.hydit.share.CopyUrlReceiver

object NotificationHelper {

    @RequiresPermission(Manifest.permission.POST_NOTIFICATIONS)
    fun success(context: Context, text: String, bigText: String? = null, copy: String? = null) {
        val id = "upload_success"

        createChannel(
            context,
            id,
            "Upload success",
            NotificationManager.IMPORTANCE_LOW,
        )

        val notification = NotificationCompat.Builder(context, id)
            .setSmallIcon(R.drawable.check)
            .setContentTitle("Success")
            .setContentText(text)
            .setStyle(
                NotificationCompat.BigTextStyle()
                    .bigText(bigText)
            )
            .setContentIntent(getOpenAppIntent(context))
            .setAutoCancel(true)
            .addCopyIntent(context, copy)

        NotificationManagerCompat
            .from(context)
            .notify(System.currentTimeMillis().toInt(), notification.build())
    }

    @RequiresPermission(Manifest.permission.POST_NOTIFICATIONS)
    fun error(context: Context, text: String, bigText: String? = null, copy: String? = null) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val id = "upload_error"

        createChannel(
            context,
            id,
            "Upload error",
            NotificationManager.IMPORTANCE_HIGH,
        )

        val notification = NotificationCompat.Builder(context, id)
            .setSmallIcon(R.drawable.close)
            .setContentTitle("Failure")
            .setContentText(text)
            .setStyle(
                NotificationCompat.BigTextStyle()
                    .bigText(bigText)
            )
            .setContentIntent(getOpenAppIntent(context))
            .setAutoCancel(true)
            .addCopyIntent(context, copy)

        NotificationManagerCompat
            .from(context)
            .notify(System.currentTimeMillis().toInt(), notification.build())
    }

    @RequiresPermission(Manifest.permission.POST_NOTIFICATIONS)
    fun showFileImportResult(context: Context, response: AddFileResponse?) {
        when (response?.status) {
            1 -> success(context, "Import successful")
            2 -> success(context, "Already in database")
            3 -> error(context, "Previously deleted")
            4 -> error(context, "Failed to import")
            7 -> error(context, "Ignored")
        }
    }

    @RequiresPermission(Manifest.permission.POST_NOTIFICATIONS)
    fun showBatchFileImportResult(context: Context, successCount: Int, failCount: Int) {
        val total = successCount + failCount

        if (successCount == 0) {
            error(context, "No files imported")
            return
        }

        when (failCount) {
            0 -> success(context, "$successCount files imported")
            else -> error(context, "$successCount/$total files imported")
        }
    }

    private fun createChannel(context: Context, id: String, name: String, importance: Int) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val channel = NotificationChannel(id, name, importance)

        context
            .getSystemService(NotificationManager::class.java)
            .createNotificationChannel(channel)
    }

    private fun NotificationCompat.Builder.addCopyIntent(
        context: Context,
        copy: String? = null
    ): NotificationCompat.Builder {
        if (copy == null) return this

        return this.addAction(
            R.drawable.copy,
            "Copy link",
            getCopyIntent(context, copy)
        )
    }

    private fun getCopyIntent(context: Context, url: String): PendingIntent? {
        val copyIntent = Intent(
            context,
            CopyUrlReceiver::class.java
        ).apply {
            putExtra("url", url)
        }

        return PendingIntent.getBroadcast(
            context,
            url.hashCode(),
            copyIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    private fun getOpenAppIntent(context: Context): PendingIntent? {
        val intent = Intent(
            context,
            MainActivity::class.java
        ).apply {
            putExtra("route", "/imports")  // TODO open imports page
        }

        return PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_IMMUTABLE
        )
    }
}

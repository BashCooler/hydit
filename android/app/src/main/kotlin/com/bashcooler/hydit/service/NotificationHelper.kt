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
import com.bashcooler.hydit.api.HydrusApi
import com.bashcooler.hydit.share.CopyUrlReceiver

object NotificationHelper {

    @RequiresPermission(Manifest.permission.POST_NOTIFICATIONS)
    fun success(context: Context, bigText: String? = null, text: String) {
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
            .addAction(
                android.R.drawable.ic_menu_save,
                "Copy link",
                getCopyIntent(context, text))
            .setContentIntent(getOpenAppIntent(context))
            .setAutoCancel(true)
            .build()

        NotificationManagerCompat
            .from(context)
            .notify(System.currentTimeMillis().toInt(), notification)
    }

    @RequiresPermission(Manifest.permission.POST_NOTIFICATIONS)
    fun error(context: Context, bigText: String? = null, text: String) {
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
            .addAction(
                android.R.drawable.ic_menu_save,
                "Copy link",
                getCopyIntent(context, text))
            .build()

        NotificationManagerCompat
            .from(context)
            .notify(System.currentTimeMillis().toInt(), notification)
    }

    @RequiresPermission(Manifest.permission.POST_NOTIFICATIONS)
    fun showFileImportResult(context: Context, response: HydrusApi.AddFileResponse?) {
        when (response?.status) {
            1 -> success(context, text = "Import successful")
            2 -> success(context, text = "Already in database")
            3 -> error(context, text = "Previously deleted")
            4 -> error(context, text = "Failed to import")
            7 -> error(context, text = "Ignored")
        }
    }

    fun createChannel(context: Context, id: String, name: String, importance: Int) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val channel = NotificationChannel(id, name, importance)

        context
            .getSystemService(NotificationManager::class.java)
            .createNotificationChannel(channel)
    }

    fun getCopyIntent(context: Context, url: String): PendingIntent? {
        val copyIntent =
            Intent(context, CopyUrlReceiver::class.java).apply {
                putExtra("url", url)
            }

        return PendingIntent.getBroadcast(
            context,
            url.hashCode(),
            copyIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    fun getOpenAppIntent(context: Context): PendingIntent? {
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
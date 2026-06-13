package com.bashcooler.hydit

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

object NotificationHelper {

    @RequiresPermission(Manifest.permission.POST_NOTIFICATIONS)
    fun showSuccess(context: Context, text: String, url: String) {
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
            .setContentText(url)
            .setStyle(
                NotificationCompat.BigTextStyle()
                    .bigText(text)
            )
            .addAction(
                android.R.drawable.ic_menu_save,
                "Copy link",
                getCopyIntent(context, url))
            .setContentIntent(getOpenAppIntent(context))
            .setAutoCancel(true)
            .build()

        NotificationManagerCompat
            .from(context)
            .notify(url.hashCode(), notification)
    }

    @RequiresPermission(Manifest.permission.POST_NOTIFICATIONS)
    fun showError(context: Context, text: String, url: String) {
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
            .setContentText(url)
            .setStyle(
                NotificationCompat.BigTextStyle()
                    .bigText(text)
            )
            .setContentIntent(getOpenAppIntent(context))
            .setAutoCancel(true)
            .addAction(
                android.R.drawable.ic_menu_save,
                "Copy link",
                getCopyIntent(context, url))
            .build()

        NotificationManagerCompat
            .from(context)
            .notify(url.hashCode(), notification)
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
            PendingIntent.FLAG_UPDATE_CURRENT or
                    PendingIntent.FLAG_IMMUTABLE
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

package com.bashcooler.hydit

import android.Manifest
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import androidx.annotation.RequiresPermission
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

object NotificationHelper {

    @RequiresPermission(Manifest.permission.POST_NOTIFICATIONS)
    fun showSuccess(context: Context, text: String) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val id = "upload_success"
        val name = "Upload success"
        val importance = NotificationManager.IMPORTANCE_LOW

        val channel = NotificationChannel(id, name, importance)

        context
            .getSystemService(NotificationManager::class.java)
            .createNotificationChannel(channel)

        val notification = NotificationCompat.Builder(context, id)
            .setSmallIcon(R.drawable.check)
            .setContentTitle("Success")
            .setContentText(text)
            .build()

        NotificationManagerCompat
            .from(context)
            .notify(1, notification)
    }

    @RequiresPermission(Manifest.permission.POST_NOTIFICATIONS)
    fun showError(context: Context, text: String) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val id = "upload_error"
        val name = "Upload error"
        val importance = NotificationManager.IMPORTANCE_HIGH

        val channel = NotificationChannel(id, name, importance)

        context
            .getSystemService(NotificationManager::class.java)
            .createNotificationChannel(channel)

        val notification = NotificationCompat.Builder(context, id)
            .setSmallIcon(R.drawable.close)
            .setContentTitle("Failure")
            .setContentText(text)
            .build()

        NotificationManagerCompat
            .from(context)
            .notify(2, notification)
    }
}

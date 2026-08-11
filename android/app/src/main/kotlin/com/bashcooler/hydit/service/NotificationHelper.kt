package com.bashcooler.hydit.service

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.annotation.RequiresPermission
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.bashcooler.hydit.MainActivity
import com.bashcooler.hydit.R
import com.bashcooler.hydit.api.AddFileResponse
import com.bashcooler.hydit.share.CopyUrlReceiver


object NotificationHelper {

    private const val SUCCESS = "upload_success"

    @RequiresApi(Build.VERSION_CODES.O)
    private val successChannel = NotificationChannel(
        SUCCESS,
        "Upload success",
        NotificationManager.IMPORTANCE_HIGH,
    )

    private const val FAILURE = "upload_error"

    @RequiresApi(Build.VERSION_CODES.O)
    private val failureChannel = NotificationChannel(
        FAILURE,
        "Upload failure",
        NotificationManager.IMPORTANCE_HIGH,
    )

    @RequiresApi(Build.VERSION_CODES.O)
    fun channel(id: String): NotificationChannel = when (id) {
        SUCCESS -> successChannel
        FAILURE -> failureChannel
        else -> throw Exception("No such channel $id")
    }

    @RequiresPermission(Manifest.permission.POST_NOTIFICATIONS)
    @RequiresApi(Build.VERSION_CODES.O)
    fun Notification.show(
        context: Context,
        id: Int = System.currentTimeMillis().toInt(),
    ) {
        context
            .getSystemService(NotificationManager::class.java)
            .createNotificationChannel(
                channel(this.channelId)
            )

        NotificationManagerCompat
            .from(context)
            .notify(id, this)
    }

    @RequiresApi(Build.VERSION_CODES.O)
    @RequiresPermission(Manifest.permission.POST_NOTIFICATIONS)
    fun success(
        context: Context,
        text: String,
        copy: String? = null,
    ) {
        NotificationCompat.Builder(context, SUCCESS)
            .setSmallIcon(R.drawable.check)
            .setContentTitle("Success")
            .setContentText(text)
            .setOpenAppIntent(context)
            .setAutoCancel(true)
            .setCopyIntent(context, copy)
            .build()
            .show(context)
    }

    @RequiresApi(Build.VERSION_CODES.O)
    @RequiresPermission(Manifest.permission.POST_NOTIFICATIONS)
    fun error(
        context: Context,
        text: String,
        bigText: String? = null,
        copy: String? = null,
    ) {
        NotificationCompat.Builder(context, FAILURE)
            .setSmallIcon(R.drawable.close)
            .setContentTitle("Failure")
            .setContentText(text)
            .setBigText(bigText)
            .setOpenAppIntent(context)
            .setAutoCancel(true)
            .setCopyIntent(context, copy)
            .build()
            .show(context)
    }

    @RequiresApi(Build.VERSION_CODES.O)
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

    @RequiresApi(Build.VERSION_CODES.O)
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

    fun NotificationCompat.Builder.setBigText(text: String?) = this
        .setStyle(
            NotificationCompat.BigTextStyle().bigText(text)
        )

    fun NotificationCompat.Builder.setCopyIntent(
        context: Context,
        copy: String? = null
    ): NotificationCompat.Builder {
        if (copy == null) return this

        val intent = Intent(
            context,
            CopyUrlReceiver::class.java
        ).apply {
            putExtra("url", copy)
        }.let {
            PendingIntent.getBroadcast(
                context,
                copy.hashCode(),
                it,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }

        return this.addAction(
            R.drawable.copy,
            "Copy link",
            intent
        )
    }

    fun NotificationCompat.Builder.setOpenAppIntent(
        context: Context,
    ): NotificationCompat.Builder {

        val intent = Intent(
            context,
            MainActivity::class.java
        ).let {
            PendingIntent.getActivity(
                context,
                0,
                it,
                PendingIntent.FLAG_IMMUTABLE
            )
        }

        return this.setContentIntent(intent)
    }
}

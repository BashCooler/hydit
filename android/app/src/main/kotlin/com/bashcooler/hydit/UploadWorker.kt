package com.bashcooler.hydit

import android.Manifest
import android.content.Context
import android.util.Log
import androidx.annotation.RequiresPermission
import androidx.work.CoroutineWorker
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import androidx.work.workDataOf

class UploadWorker(context: Context, params: WorkerParameters)
    : CoroutineWorker(context, params) {

    companion object {
        fun enqueue(context: Context, url: String) {
            val request = OneTimeWorkRequestBuilder<UploadWorker>()
                .setInputData(workDataOf("url" to url)).build()

            WorkManager.getInstance(context).enqueue(request)
        }
    }

    @RequiresPermission(Manifest.permission.POST_NOTIFICATIONS)
    override suspend fun doWork(): Result {
        return try {
            val url = inputData.getString("url") ?: return Result.failure()
            Log.d("UploadWorker", "url=$url")

            HydrusApi.upload(url)

            NotificationHelper.showSuccess(applicationContext, "URL added")

            Result.success()
        } catch (e: Exception) {
            NotificationHelper.showError(applicationContext, e.message ?: "Error")

            Log.e(
                "UploadWorker",
                "Worker crashed",
                e
            )

            Result.failure()
        }
    }
}

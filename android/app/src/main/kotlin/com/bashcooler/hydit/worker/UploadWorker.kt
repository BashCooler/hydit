package com.bashcooler.hydit.worker

import android.Manifest
import android.content.Context
import android.util.Log
import androidx.annotation.RequiresPermission
import androidx.work.CoroutineWorker
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import androidx.work.workDataOf
import com.bashcooler.hydit.api.HydrusApi
import com.bashcooler.hydit.service.NotificationHelper

class UploadWorker(context: Context, params: WorkerParameters)
    : CoroutineWorker(context, params) {

    companion object {
        fun enqueue(context: Context, url: String) {
            val request = OneTimeWorkRequestBuilder<UploadWorker>()
                .setInputData(workDataOf("url" to url))
                .build()

            WorkManager.Companion
                .getInstance(context)
                .enqueue(request)
        }
    }

    @RequiresPermission(Manifest.permission.POST_NOTIFICATIONS)
    override suspend fun doWork(): Result {
        val url = inputData.getString("url") ?: return Result.failure()

        return try {
            Log.d("UploadWorker", "url=$url")

            val result = HydrusApi.addUrl(url)

            NotificationHelper.success(
                applicationContext,
                result?.human_result_text ?: "Url added",
                url,
            )

            Result.success()
        } catch (e: Exception) {
            NotificationHelper.error(applicationContext, e.message ?: "Error", url)

            Log.e(
                "UploadWorker",
                "Worker crashed",
                e
            )

            Result.failure()
        }
    }
}
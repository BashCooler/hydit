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
import java.io.File

class FileUploadWorker(context: Context, params: WorkerParameters)
    : CoroutineWorker(context, params) {

    @RequiresPermission(Manifest.permission.POST_NOTIFICATIONS)
    override suspend fun doWork(): Result {
        val filePath =
            inputData.getString("file_path")
                ?: return Result.failure()

        val file = File(filePath)

        if (!file.exists()) return Result.failure()

        return try {
            val response = HydrusApi.addFile(file)

            NotificationHelper
                .showFileImportResult(applicationContext, response)

            file.delete()
            Result.success()

        } catch (e: Exception) {

            Log.e(
                "UploadFileWorker",
                "Upload failed",
                e
            )

            NotificationHelper.error(
                applicationContext,
                text = e.message ?: "Unknown error"
            )

            Result.failure()
        }
    }

    companion object {
        fun enqueue(context: Context, filePath: String) {
            val request =
                OneTimeWorkRequestBuilder<FileUploadWorker>()
                    .setInputData(
                        workDataOf("file_path" to filePath)
                    )
                    .build()

            WorkManager
                .getInstance(context)
                .enqueue(request)
        }
    }
}

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
import java.io.File

class BatchFileWorker(context: Context, params: WorkerParameters)
    : CoroutineWorker(context, params) {

    @RequiresPermission(Manifest.permission.POST_NOTIFICATIONS)
    override suspend fun doWork(): Result {
        val batchDir = inputData.getString("batch_dir")
            ?: return Result.failure()

        val dir = File(batchDir)

        if (!dir.exists()) return Result.failure()

        val files = dir.listFiles()?.toList() ?: return Result.failure()

        var successCount = 0
        var failCount = 0

        for (file in files) {
            try {
                val result = HydrusApi.addFile(file)

                when (result.status) {
                    1, 2 -> successCount++
                    else -> failCount++
                }
            } catch (e: Exception) {
                failCount++

                Log.e(
                    "BatchFileWorker",
                    "Failed to load ${file.name}",
                    e
                )
            }
        }

        NotificationHelper.showBatchFileImportResult(
            applicationContext,
            successCount,
            failCount
        )

        dir.deleteRecursively()

        return Result.success()
    }

    companion object {
        fun enqueue(context: Context, batchDir: String) {
            val request = OneTimeWorkRequestBuilder<BatchFileWorker>()
                .setInputData(workDataOf("batch_dir" to batchDir))
                .build()

            WorkManager
                .getInstance(context)
                .enqueue(request)
        }
    }
}
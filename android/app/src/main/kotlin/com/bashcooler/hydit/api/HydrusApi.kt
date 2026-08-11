package com.bashcooler.hydit.api

import android.content.Context
import android.util.Log
import com.google.gson.Gson
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.asRequestBody
import okhttp3.RequestBody.Companion.toRequestBody
import java.io.File
import java.util.concurrent.TimeUnit


class HydrusApi(context: Context) {

    companion object {
        private const val KEY_HEADER = "Hydrus-Client-API-Access-Key"
    }

    private val client = OkHttpClient.Builder()
        .callTimeout(3, TimeUnit.SECONDS)
        .build()

    private val prefs = context
        .getSharedPreferences("settings", Context.MODE_PRIVATE)

    val host: String
        get() = prefs.getString("url", null) ?: ""

    val key: String
        get() = prefs.getString("key", null) ?: ""

    fun addUrl(url: String): AddUrlResponse? {
        val json =
            """
            {
              "url": "$url"
            }
            """.trimIndent()

        val request = Request.Builder()
            .url("$host/add_urls/add_url")
            .header(KEY_HEADER, key)
            .post(
                json.toRequestBody(
                    "application/json".toMediaType()
                )
            )
            .build()

        client.newCall(request).execute().use { response ->
            if (!response.isSuccessful) {
                throw okio.IOException("HTTP ${response.code}")
            }

            val jsonString = response.body.string()

            return Gson()
                .fromJson(jsonString, AddUrlResponse::class.java)
        }
    }

    fun addFile(file: File): AddFileResponse {
        val body = file.asRequestBody(
            "application/octet-stream".toMediaType()
        )

        val request = Request.Builder()
            .url("$host/add_files/add_file")
            .header(KEY_HEADER, key)
            .post(body)
            .build()

        client.newCall(request).execute().use { response ->
            val jsonString = response.body.string()

            Log.d("HydrusApi", jsonString)

            return Gson()
                .fromJson(jsonString, AddFileResponse::class.java)
        }
    }
}
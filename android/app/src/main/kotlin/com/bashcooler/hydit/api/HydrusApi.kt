package com.bashcooler.hydit.api

import android.util.Log
import com.google.gson.Gson
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.asRequestBody
import okhttp3.RequestBody.Companion.toRequestBody
import java.io.File
import java.util.concurrent.TimeUnit

object HydrusApi {
    private const val HOST = "http://192.168.31.176:45869"
    private const val KEY_HEADER = "Hydrus-Client-API-Access-Key"
    private const val ACCESS_KEY = "86106807bd3cfe58cd0c5664981799dbaf978454a91b26afd3c5a60e3ad2c813"

    private val client = OkHttpClient.Builder()
        .callTimeout(3, TimeUnit.SECONDS)
        .build()

    fun addUrl(url: String): AddUrlResponse? {
        val json =
            """
            {
              "url": "$url"
            }
            """.trimIndent()

        val request = Request.Builder()
            .url("$HOST/add_urls/add_url")
            .header(KEY_HEADER, ACCESS_KEY)
            .post(json.toRequestBody("application/json".toMediaType()))
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
            .url("$HOST/add_files/add_file")
            .header(KEY_HEADER, ACCESS_KEY)
            .post(body)
            .build()

        client.newCall(request).execute().use { response ->
            val jsonString = response.body.string()

            Log.d("HydrusApi", jsonString)

            return Gson()
                .fromJson(jsonString, AddFileResponse::class.java)
        }
    }

    data class AddUrlResponse(
        val human_result_text: String,
        val normalised_url: String
    )

    data class AddFileResponse(
        val status: Int,
        val hash: String,
        val note: String
    )
}
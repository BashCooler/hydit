package com.bashcooler.hydit

import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import okio.IOException

object HydrusApi {
    private val client = OkHttpClient()

    fun upload(url: String) {
        val json =
            """
            {
              "url": "$url"
            }
            """.trimIndent()

        val request = Request.Builder()
            .url("http://192.168.31.176:45869/add_urls/add_url")
            .header("Hydrus-Client-API-Access-Key", "86106807bd3cfe58cd0c5664981799dbaf978454a91b26afd3c5a60e3ad2c813")
            .post(json.toRequestBody("application/json".toMediaType()))
            .build()

        client.newCall(request).execute().use {
            if (!it.isSuccessful) {
                throw IOException("HTTP ${it.code}")
            }
        }
    }
}

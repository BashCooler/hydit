package com.bashcooler.hydit.api

import androidx.annotation.Keep

@Keep
data class AddUrlResponse(
    val human_result_text: String,
    val normalised_url: String
)

@Keep
data class AddFileResponse(
    val status: Int,
    val hash: String,
    val note: String
)

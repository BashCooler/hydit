package com.bashcooler.hydit.api


data class AddUrlResponse(
    val human_result_text: String,
    val normalised_url: String
)

data class AddFileResponse(
    val status: Int,
    val hash: String,
    val note: String
)

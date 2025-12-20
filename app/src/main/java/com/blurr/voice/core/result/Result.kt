package com.twent.voice.core.result

data class AIError(
    val code: String,
    val message: String,
    val provider: String? = null
) {
    companion object {
        const val AUTH_FAILED = "AUTH_FAILED"
        const val AUTH_INVALID_CREDENTIALS = "AUTH_INVALID_CREDENTIALS"
        const val AUTH_WEAK_PASSWORD = "AUTH_WEAK_PASSWORD"
        const val AUTH_USER_EXISTS = "AUTH_USER_EXISTS"
        const val NETWORK_ERROR = "NETWORK_ERROR"
        const val UNKNOWN = "UNKNOWN"
    }
}

sealed class Result<T> {
    data class Success<T>(val data: T) : Result<T>()
    data class Error<T>(val error: AIError) : Result<T>()
}

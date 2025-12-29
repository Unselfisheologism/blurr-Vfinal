package com.blurr.voice.tools.shell

/**
 * Result of code execution
 */
data class ExecutionResult(
    val success: Boolean,
    val output: String,
    val error: String? = null,
    val exception: Throwable? = null,
    val executionTimeMs: Long = 0
) {
    companion object {
        fun success(output: String, executionTimeMs: Long = 0) = 
            ExecutionResult(
                success = true,
                output = output,
                executionTimeMs = executionTimeMs
            )
        
        fun error(message: String, exception: Throwable? = null) = 
            ExecutionResult(
                success = false,
                output = "",
                error = message,
                exception = exception
            )
    }
}

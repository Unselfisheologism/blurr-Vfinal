package com.blurr.voice.agents

import kotlinx.coroutines.*
import android.util.Log
import com.blurr.voice.tools.Tool
import com.blurr.voice.tools.ToolResult

/**
 * Tool execution engine with timeout and error handling
 * 
 * Provides robust tool execution with configurable timeouts,
 * retries, and comprehensive error handling.
 */
class ToolExecutor {
    
    companion object {
        private const val TAG = "ToolExecutor"
        private const val DEFAULT_TIMEOUT_MS = 30_000L  // 30 seconds
        private const val DEFAULT_MAX_RETRIES = 2
    }
    
    /**
     * Execute tool with timeout and error handling
     */
    suspend fun execute(
        tool: Tool,
        parameters: Map<String, Any>,
        context: List<ToolResult> = emptyList(),
        timeoutMs: Long = DEFAULT_TIMEOUT_MS,
        maxRetries: Int = DEFAULT_MAX_RETRIES
    ): ToolResult {
        Log.d(TAG, "Executing tool: ${tool.name}")
        Log.d(TAG, "Parameters: $parameters")
        
        var lastError: String? = null
        
        for (attempt in 1..maxRetries) {
            try {
                // Execute with timeout
                val result = withTimeout(timeoutMs) {
                    tool.execute(parameters, context)
                }
                
                if (result.success) {
                    Log.d(TAG, "Tool execution successful: ${tool.name}")
                    return result
                } else {
                    lastError = result.error
                    Log.w(TAG, "Tool execution failed (attempt $attempt): ${result.error}")
                }
                
            } catch (e: TimeoutCancellationException) {
                lastError = "Tool execution timeout after ${timeoutMs}ms"
                Log.e(TAG, "Tool execution timeout (attempt $attempt)", e)
                
            } catch (e: Exception) {
                lastError = e.message ?: "Unknown error"
                Log.e(TAG, "Tool execution exception (attempt $attempt)", e)
            }
            
            // Delay before retry (exponential backoff)
            if (attempt < maxRetries) {
                kotlinx.coroutines.delay(1000L * attempt)
            }
        }
        
        // All retries failed
        return ToolResult.error(
            tool.name,
            lastError ?: "Tool execution failed after $maxRetries attempts"
        )
    }
    
    /**
     * Execute multiple tools in parallel
     */
    suspend fun executeParallel(
        tools: List<Pair<Tool, Map<String, Any>>>,
        context: List<ToolResult> = emptyList(),
        timeoutMs: Long = DEFAULT_TIMEOUT_MS
    ): List<ToolResult> {
        return coroutineScope {
            tools.map { (tool, params) ->
                async {
                    execute(tool, params, context, timeoutMs)
                }
            }.map { it.await() }
        }
    }
    
    /**
     * Validate tool parameters before execution
     */
    fun validateParameters(
        tool: Tool,
        parameters: Map<String, Any>
    ): Result<Unit> {
        for (param in tool.parameters) {
            val value = parameters[param.name]
            val validation = param.validate(value)
            
            if (validation.isFailure) {
                return validation
            }
        }
        
        return Result.success(Unit)
    }
}

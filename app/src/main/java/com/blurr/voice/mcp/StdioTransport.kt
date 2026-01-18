package com.blurr.voice.mcp

import android.content.Context
import android.util.Log
import io.modelcontextprotocol.kotlin.sdk.client.StdioClientTransport
import kotlinx.io.asSource
import kotlinx.io.asSink
import kotlinx.io.buffered
import kotlinx.coroutines.runBlocking

/**
 * Stdio Transport Implementation using Official MCP Kotlin SDK
 *
 * Spawns a subprocess and communicates via stdin/stdout pipes.
 * Reference: https://github.com/modelcontextprotocol/kotlin-sdk
 */
class StdioTransport(
    private val processPath: String,
    private val context: Context
) {
    companion object {
        private const val TAG = "StdioTransport"
    }

    private var transport: StdioClientTransport? = null
    private var process: Process? = null

    /**
     * Create the transport and start the process with proper error handling callbacks
     */
    fun createTransport(): StdioClientTransport {
        Log.d(TAG, "Creating Stdio transport for: $processPath")

        var createdProcess: Process? = null
        var createdTransport: StdioClientTransport? = null

        try {
            // Determine command based on file extension
            val command = buildList {
                when (processPath.substringAfterLast(".").lowercase()) {
                    "js" -> add("node")
                    "py" -> add("python3")
                    "jar" -> addAll(listOf("java", "-jar"))
                    else -> {
                        // Assume it's an executable
                        Log.d(TAG, "Assuming executable: $processPath")
                    }
                }
                add(processPath)
            }

            Log.d(TAG, "Starting process: ${command.joinToString(" ")}")

            // Start the process with comprehensive error handling
            val processBuilder = ProcessBuilder(command)
            processBuilder.redirectErrorStream(false)
            createdProcess = try {
                processBuilder.start()
            } catch (e: Exception) {
                Log.e(TAG, "Failed to start process for: $processPath", e)
                throw IllegalStateException("Failed to start process: ${e.message}", e)
            }

            // Create transport with process streams
            val input = createdProcess.inputStream.asSource().buffered()
            val output = createdProcess.outputStream.asSink().buffered()
            val error = createdProcess.errorStream.asSource().buffered()

            createdTransport = StdioClientTransport(
                input = input,
                output = output,
                error = error
            ) { stderrLine ->
                // Classify stderr messages
                when {
                    stderrLine.contains("error", ignoreCase = true) -> {
                        Log.e(TAG, "STDERR: $stderrLine")
                        StdioClientTransport.StderrSeverity.WARNING
                    }
                    stderrLine.contains("warning", ignoreCase = true) -> {
                        Log.w(TAG, "STDERR: $stderrLine")
                        StdioClientTransport.StderrSeverity.WARNING
                    }
                    else -> {
                        Log.d(TAG, "STDERR: $stderrLine")
                        StdioClientTransport.StderrSeverity.DEBUG
                    }
                }
            }

            // Set up error handling callbacks (as per Kotlin SDK documentation)
            createdTransport.onError { error ->
                Log.e(TAG, "StdioClientTransport error: ${error.message}", error)
                Log.e(TAG, "Error occurred on stdio transport for process: $processPath")
                
                // Check if process is still alive
                if (createdProcess?.isAlive == false) {
                    val exitCode = createdProcess?.exitValue()
                    Log.e(TAG, "Process terminated with exit code: $exitCode")
                }
            }

            createdTransport.onClose {
                Log.d(TAG, "StdioClientTransport closed for: $processPath")
                
                // Clean up process
                if (createdProcess?.isAlive == true) {
                    Log.d(TAG, "Process still alive, destroying...")
                    createdProcess?.destroy()
                }
                
                Log.d(TAG, "Stdio transport connection terminated")
            }

            // Update instance variables only after successful creation
            process = createdProcess
            transport = createdTransport

            Log.d(TAG, "Stdio transport created successfully with error handlers")
            return createdTransport
        } catch (e: Exception) {
            Log.e(TAG, "Failed to create Stdio transport for: $processPath", e)
            
            // Clean up any partially created resources
            try {
                createdTransport?.close()
            } catch (cleanupException: Exception) {
                Log.w(TAG, "Error closing transport during cleanup", cleanupException)
            }
            
            try {
                createdProcess?.destroy()
            } catch (cleanupException: Exception) {
                Log.w(TAG, "Error destroying process during cleanup", cleanupException)
            }
            
            throw e
        }
    }

    /**
     * Get the underlying SDK transport
     */
    fun getTransport(): StdioClientTransport {
        return transport ?: createTransport()
    }

    /**
     * Close the transport and kill the process
     */
    fun close() {
        Log.d(TAG, "Closing Stdio transport")
        
        // SDK transports implement Closeable with suspend close()
        runBlocking {
            transport?.close()
        }
        process?.destroy()
        process = null
        transport = null
    }
}

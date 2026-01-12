package com.blurr.voice.mcp

import android.content.Context
import android.util.Log
import io.modelcontextprotocol.kotlin.sdk.client.StdioClientTransport
import kotlinx.io.asSource
import kotlinx.io.asSink
import kotlinx.io.buffered

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
     * Create the transport and start the process
     */
    fun createTransport(): StdioClientTransport {
        Log.d(TAG, "Creating Stdio transport for: $processPath")
        
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
        
        // Start the process
        val processBuilder = ProcessBuilder(command)
        processBuilder.redirectErrorStream(false)
        process = processBuilder.start()
        
        // Create transport with process streams
        val input = process!!.inputStream.asSource().buffered()
        val output = process!!.outputStream.asSink().buffered()
        val error = process!!.errorStream.asSource().buffered()
        
        transport = StdioClientTransport(
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
        
        return transport!!
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
    suspend fun close() {
        Log.d(TAG, "Closing Stdio transport")
        transport?.close()
        process?.destroy()
        process = null
        transport = null
    }
}

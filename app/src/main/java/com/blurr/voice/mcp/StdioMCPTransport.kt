package com.blurr.voice.mcp

import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.io.BufferedReader
import java.io.InputStreamReader
import java.io.OutputStreamWriter
import java.io.PrintWriter
import java.util.concurrent.atomic.AtomicLong

/**
 * Standard I/O transport implementation for MCP
 *
 * Spawns a subprocess and communicates via stdin/stdout pipes.
 */
class StdioMCPTransport(
    private val config: MCPTransportConfig.Stdio
) : MCPTransport {

    private var process: Process? = null
    private var processWriter: PrintWriter? = null
    private var processReader: BufferedReader? = null
    private var isConnected = false
    private val requestIdCounter = AtomicLong(1)

    companion object {
        private const val TAG = "StdioMCPTransport"
        private const val JSON_RPC_VERSION = "2.0"
        private const val RESPONSE_TIMEOUT_MS = 30000L
    }

    override suspend fun connect() {
        try {
            Log.d(TAG, "Starting MCP process: ${config.command}")

            // Build process builder
            val processBuilder = ProcessBuilder(
                mutableListOf(config.command) + config.args
            )

            // Set environment variables
            config.env.forEach { (key, value) ->
                processBuilder.environment()[key] = value
            }

            // Start the process
            process = processBuilder.start()

            // Get I/O streams
            val outputStream = process!!.outputStream
            val inputStream = process!!.inputStream

            // Create writer and reader
            processWriter = PrintWriter(OutputStreamWriter(outputStream))
            processReader = BufferedReader(InputStreamReader(inputStream))

            isConnected = true
            Log.d(TAG, "Stdio transport connected successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start MCP process", e)
            throw MCPException(
                "Failed to start process: ${config.command}",
                MCPException.INITIALIZATION_ERROR,
                cause = e
            )
        }
    }

    override suspend fun sendRequest(method: String, params: Map<String, Any>): JSONObject {
        return withContext(Dispatchers.IO) {
            if (!isConnected || processWriter == null || processReader == null) {
                throw MCPException("Transport not connected")
            }

            val requestId = requestIdCounter.getAndIncrement()

            // Build JSON-RPC request
            val requestJson = JSONObject().apply {
                put("jsonrpc", JSON_RPC_VERSION)
                put("id", requestId)
                put("method", method)
                if (params.isNotEmpty()) {
                    put("params", JSONObject(params))
                }
            }

            Log.d(TAG, "Sending request: $method (id: $requestId)")
            Log.v(TAG, "Request body: ${requestJson.toString(2)}")

            try {
                // Send request to process
                processWriter!!.println(requestJson.toString())
                processWriter!!.flush()

                // Read response line by line
                val responseLines = mutableListOf<String>()
                val responseBuilder = StringBuilder()
                var braceCount = 0
                var inJson = false

                while (true) {
                    val line = processReader!!.readLine() ?: break
                    responseBuilder.append(line).append("\n")

                    // Count braces to find JSON object boundaries
                    for (char in line) {
                        if (char == '{' || char == '[') braceCount++
                        if (char == '}' || char == ']') braceCount--
                    }

                    // If braces are balanced, we have a complete JSON object
                    if (braceCount <= 0 && line.trim().isNotEmpty()) {
                        val responseText = responseBuilder.toString().trim()
                        Log.v(TAG, "Response received: $responseText")

                        try {
                            val jsonResponse = JSONObject(responseText)

                            // Check for JSON-RPC error
                            if (jsonResponse.has("error")) {
                                throw MCPException.fromJson(jsonResponse.getJSONObject("error"))
                            }

                            // Verify response ID matches request
                            val responseId = jsonResponse.optLong("id", -1)
                            if (responseId != requestId) {
                                Log.w(TAG, "Response ID mismatch: expected $requestId, got $responseId")
                            }

                            // Extract result
                            if (!jsonResponse.has("result")) {
                                throw MCPException(
                                    "Response missing 'result' field",
                                    MCPException.INTERNAL_ERROR
                                )
                            }

                            val result = jsonResponse.getJSONObject("result")
                            Log.d(TAG, "Request successful: $method")

                            return@withContext result
                        } catch (e: Exception) {
                            if (e is MCPException) {
                                throw e
                            }
                            throw MCPException(
                                "Invalid JSON response",
                                MCPException.PARSE_ERROR,
                                cause = e
                            )
                        }
                    }
                }

                throw MCPException(
                    "No valid response received",
                    MCPException.INTERNAL_ERROR
                )
            } catch (e: Exception) {
                Log.e(TAG, "Error executing request: $method", e)
                if (e is MCPException) {
                    throw e
                }
                throw MCPException(
                    "Request failed: ${e.message}",
                    MCPException.INTERNAL_ERROR,
                    cause = e
                )
            }
        }
    }

    override fun close() {
        try {
            Log.d(TAG, "Closing stdio transport")

            processWriter?.close()
            processReader?.close()

            // Destroy process if still running
            process?.destroy()
            process?.waitFor(5, java.util.concurrent.TimeUnit.SECONDS)

            isConnected = false
            Log.d(TAG, "Stdio transport closed")
        } catch (e: Exception) {
            Log.e(TAG, "Error closing transport", e)
        }
    }

    override fun isConnected(): Boolean = isConnected
}

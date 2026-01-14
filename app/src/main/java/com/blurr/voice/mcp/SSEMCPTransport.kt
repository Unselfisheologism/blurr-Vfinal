package com.blurr.voice.mcp

import android.util.Log
import io.ktor.server.sse.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.toRequestBody
import okhttp3.sse.EventSource
import okhttp3.sse.EventSourceListener
import okhttp3.sse.EventSources
import okio.ByteString
import org.json.JSONObject
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicLong

/**
 * Server-Sent Events (SSE) transport implementation for MCP
 *
 * Uses SSE for streaming responses and bidirectional messaging.
 */
class SSEMCPTransport(
    private val config: MCPTransportConfig.Http
) : MCPTransport {

    private val client: OkHttpClient
    private var eventSource: EventSource? = null
    private var isConnected = false
    private val requestIdCounter = AtomicLong(1)

    companion object {
        private const val TAG = "SSEMCPTransport"
        private const val JSON_RPC_VERSION = "2.0"
    }

    init {
        client = OkHttpClient.Builder()
            .connectTimeout(config.timeoutMs, TimeUnit.MILLISECONDS)
            .readTimeout(config.timeoutMs, TimeUnit.MILLISECONDS)
            .writeTimeout(config.timeoutMs, TimeUnit.MILLISECONDS)
            .pingInterval(30, TimeUnit.SECONDS)
            .build()
    }

    override suspend fun connect() {
        try {
            if (!config.url.startsWith("http://") && !config.url.startsWith("https://")) {
                throw MCPException("Invalid SSE URL: ${config.url}")
            }

            // For SSE, we establish connection but don't keep it open for all requests
            // SSE is typically used for streaming responses, not for request/response
            isConnected = true
            Log.d(TAG, "SSE transport ready: ${config.url}")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize SSE transport", e)
            throw MCPException(
                "Failed to initialize SSE: ${e.message}",
                MCPException.INITIALIZATION_ERROR,
                cause = e
            )
        }
    }

    override suspend fun sendRequest(method: String, params: Map<String, Any>): JSONObject {
        return withContext(Dispatchers.IO) {
            if (!isConnected) {
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

            // For SSE, we make a POST request and wait for response
            // The server may stream the response via SSE events
            val httpRequest = Request.Builder()
                .url(config.url)
                .post(requestJson.toString().toRequestBody("application/json".toMediaType()))
                .apply {
                    config.apiKey?.let {
                        addHeader("Authorization", "Bearer $it")
                    }

                    config.headers.forEach { (key, value) ->
                        addHeader(key, value)
                    }

                    addHeader("Content-Type", "application/json")
                    addHeader("Accept", "text/event-stream")
                }
                .build()

            try {
                val response = client.newCall(httpRequest).execute()
                val responseBody = response.body?.string()

                if (responseBody == null) {
                    throw MCPException(
                        "Empty response from server",
                        MCPException.INTERNAL_ERROR
                    )
                }

                Log.v(TAG, "Response received: $responseBody")

                // Parse JSON-RPC response
                val jsonResponse = try {
                    JSONObject(responseBody)
                } catch (e: Exception) {
                    // If not JSON, might be SSE format
                    // Try to parse as SSE and extract JSON
                    parseSSEResponse(responseBody)
                }

                // Check HTTP status
                if (!response.isSuccessful) {
                    val errorMessage = "HTTP ${response.code}: ${response.message}"

                    if (jsonResponse != null && jsonResponse.has("error")) {
                        throw MCPException.fromJson(jsonResponse.getJSONObject("error"))
                    }

                    throw MCPException(
                        errorMessage,
                        response.code
                    )
                }

                if (jsonResponse == null) {
                    throw MCPException(
                        "Invalid response format",
                        MCPException.PARSE_ERROR
                    )
                }

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
                Log.e(TAG, "Network error for $method", e)
                if (e is MCPException) {
                    throw e
                }
                throw MCPException(
                    "Network error: ${e.message}",
                    MCPException.INTERNAL_ERROR,
                    cause = e
                )
            }
        }
    }

    /**
     * Parse SSE response format and extract JSON-RPC data
     */
    private fun parseSSEResponse(sseData: String): JSONObject? {
        try {
            // SSE format: "data: {json}\n\n"
            val lines = sseData.lines()
            for (line in lines) {
                if (line.startsWith("data: ")) {
                    val data = line.substring(6).trim()
                    if (data.startsWith("{") || data.startsWith("[")) {
                        return JSONObject(data)
                    }
                }
            }
            return null
        } catch (e: Exception) {
            Log.w(TAG, "Failed to parse SSE response", e)
            return null
        }
    }

    override suspend fun sendNotification(method: String, params: Map<String, Any>) {
        withContext(Dispatchers.IO) {
            if (!isConnected) {
                Log.w(TAG, "Transport not connected, skipping notification: $method")
                return@withContext
            }

            try {
                val notificationJson = JSONObject().apply {
                    put("jsonrpc", JSON_RPC_VERSION)
                    put("method", method)
                    if (params.isNotEmpty()) {
                        put("params", JSONObject(params))
                    }
                }

                Log.d(TAG, "Sending notification: $method")

                val httpRequest = Request.Builder()
                    .url(config.url)
                    .post(notificationJson.toString().toRequestBody("application/json".toMediaType()))
                    .apply {
                        config.apiKey?.let {
                            addHeader("Authorization", "Bearer $it")
                        }
                        config.headers.forEach { (key, value) ->
                            addHeader(key, value)
                        }
                        addHeader("Content-Type", "application/json")
                    }
                    .build()

                // Fire and forget
                client.newCall(httpRequest).execute().use { response ->
                    if (!response.isSuccessful) {
                        Log.w(TAG, "Notification failed: ${response.code} ${response.message}")
                    }
                }
            } catch (e: Exception) {
                Log.w(TAG, "Error sending notification: $method", e)
            }
        }
    }

    override fun close() {
        try {
            eventSource?.cancel()
            eventSource = null
            isConnected = false
            Log.d(TAG, "SSE transport closed")
        } catch (e: Exception) {
            Log.e(TAG, "Error closing SSE transport", e)
        }
    }

    override fun isConnected(): Boolean = isConnected
}

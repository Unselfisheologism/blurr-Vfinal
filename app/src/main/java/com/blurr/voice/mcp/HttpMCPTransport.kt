package com.blurr.voice.mcp

import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import java.io.IOException
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicLong

/**
 * HTTP transport implementation for MCP
 * 
 * Uses JSON-RPC 2.0 over HTTP POST requests.
 */
class HttpMCPTransport(
    private val config: MCPTransportConfig.Http
) : MCPTransport {
    
    private val client: OkHttpClient
    private val requestIdCounter = AtomicLong(1)
    private var isConnected = false
    
    companion object {
        private const val TAG = "HttpMCPTransport"
        private const val JSON_RPC_VERSION = "2.0"
    }
    
    init {
        client = OkHttpClient.Builder()
            .connectTimeout(config.timeoutMs, TimeUnit.MILLISECONDS)
            .readTimeout(config.timeoutMs, TimeUnit.MILLISECONDS)
            .writeTimeout(config.timeoutMs, TimeUnit.MILLISECONDS)
            .build()
    }
    
    override suspend fun connect() {
        // HTTP doesn't need explicit connection
        // Just verify URL is valid
        if (!config.url.startsWith("http://") && !config.url.startsWith("https://")) {
            throw MCPException("Invalid HTTP URL: ${config.url}")
        }
        
        isConnected = true
        Log.d(TAG, "HTTP transport ready: ${config.url}")
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
                put("params", JSONObject(params))
            }
            
            Log.d(TAG, "Sending request: $method (id: $requestId)")
            Log.v(TAG, "Request body: ${requestJson.toString(2)}")
            
            // Build HTTP request
            val httpRequest = Request.Builder()
                .url(config.url)
                .post(requestJson.toString().toRequestBody("application/json".toMediaType()))
                .apply {
                    // Add authentication header if API key provided
                    config.apiKey?.let { 
                        addHeader("Authorization", "Bearer $it")
                    }
                    
                    // Add custom headers
                    config.headers.forEach { (key, value) ->
                        addHeader(key, value)
                    }
                    
                    // Standard headers
                    addHeader("Content-Type", "application/json")
                    addHeader("Accept", "application/json")
                }
                .build()
            
            try {
                // Execute request
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
                    throw MCPException(
                        "Invalid JSON response",
                        MCPException.PARSE_ERROR,
                        cause = e
                    )
                }
                
                // Check HTTP status
                if (!response.isSuccessful) {
                    val errorMessage = "HTTP ${response.code}: ${response.message}"
                    
                    // Try to extract JSON-RPC error if present
                    if (jsonResponse.has("error")) {
                        throw MCPException.fromJson(jsonResponse.getJSONObject("error"))
                    }
                    
                    throw MCPException(
                        errorMessage,
                        response.code
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
                
            } catch (e: IOException) {
                Log.e(TAG, "Network error for $method", e)
                throw MCPException(
                    "Network error: ${e.message}",
                    cause = e
                )
            } catch (e: MCPException) {
                // Re-throw MCP exceptions
                throw e
            } catch (e: Exception) {
                Log.e(TAG, "Unexpected error for $method", e)
                throw MCPException(
                    "Unexpected error: ${e.message}",
                    MCPException.INTERNAL_ERROR,
                    cause = e
                )
            }
        }
    }
    
    override suspend fun sendNotification(method: String, params: Map<String, Any>) {
        withContext(Dispatchers.IO) {
            if (!isConnected) {
                Log.w(TAG, "Transport not connected, skipping notification: $method")
                return@withContext
            }
            
            try {
                // Build JSON-RPC notification (no id field)
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
                
                // Fire and forget - don't wait for response
                client.newCall(httpRequest).execute().use { response ->
                    if (!response.isSuccessful) {
                        Log.w(TAG, "Notification failed: ${response.code} ${response.message}")
                    }
                }
                
            } catch (e: Exception) {
                Log.w(TAG, "Error sending notification: $method", e)
                // Don't throw - notifications are best effort
            }
        }
    }
    
    override fun close() {
        isConnected = false
        Log.d(TAG, "HTTP transport closed")
    }
    
    override fun isConnected(): Boolean = isConnected
}

/**
 * Factory function to create HTTP transport from config
 */
fun createHttpTransport(
    url: String,
    apiKey: String? = null,
    headers: Map<String, String> = emptyMap(),
    timeoutMs: Long = 30000
): HttpMCPTransport {
    val config = MCPTransportConfig.Http(
        url = url,
        apiKey = apiKey,
        headers = headers,
        timeoutMs = timeoutMs
    )
    return HttpMCPTransport(config)
}

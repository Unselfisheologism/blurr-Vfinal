package com.blurr.voice.mcp

import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicLong

// DEPRECATED: SSE Transport should use official SDK's SseClientTransport
// This file is kept for reference but should not be used
@Deprecated("Use official SDK's SseClientTransport via SSETransport.kt instead")
class SSEMCPTransport(
    private val config: MCPTransportConfig.Http
) : MCPTransport {

    private val client: okhttp3.OkHttpClient
    private var isConnected = false
    private val requestIdCounter = AtomicLong(1)

    companion object {
        private const val TAG = "SSEMCPTransport"
        private const val JSON_RPC_VERSION = "2.0"
    }

    init {
        client = okhttp3.OkHttpClient.Builder()
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .writeTimeout(30, TimeUnit.SECONDS)
            .pingInterval(30, TimeUnit.SECONDS)
            .build()
    }

    override suspend fun connect() {
        try {
            if (!config.url.startsWith("http://") && !config.url.startsWith("https://")) {
                throw MCPException("Invalid SSE URL: ${config.url}")
            }

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
        throw MCPException(
            "SSEMCPTransport is deprecated and should not be used. Use SSETransport with official SDK instead.",
            MCPException.INITIALIZATION_ERROR
        )
    }

    override fun close() {
        try {
            isConnected = false
            Log.d(TAG, "SSE transport closed")
        } catch (e: Exception) {
            Log.e(TAG, "Error closing SSE transport", e)
        }
    }

    override fun isConnected(): Boolean = isConnected
}

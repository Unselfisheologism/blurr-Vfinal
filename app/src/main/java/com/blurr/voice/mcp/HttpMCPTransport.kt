package com.blurr.voice.mcp

import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicLong

// DEPRECATED: HTTP Transport should use official SDK's StreamableHttpClientTransport
// This file is kept for reference but should not be used
@Deprecated("Use official SDK's StreamableHttpClientTransport via HttpTransport.kt instead")
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
        throw MCPException(
            "HttpMCPTransport is deprecated and should not be used. Use HttpTransport with official SDK instead.",
            MCPException.INITIALIZATION_ERROR
        )
    }

    override suspend fun sendNotification(method: String, params: Map<String, Any>) {
        throw MCPException(
            "HttpMCPTransport is deprecated and should not be used.",
            MCPException.INITIALIZATION_ERROR
        )
    }

    override fun close() {
        isConnected = false
        Log.d(TAG, "HTTP transport closed")
    }

    override fun isConnected(): Boolean = isConnected
}

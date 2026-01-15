package com.blurr.voice.mcp

import android.content.Context
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
 * Standard I/O transport implementation for MCP - DEPRECATED
 *
 * @deprecated Use official SDK's StdioClientTransport via StdioTransport.kt instead
 */
@Deprecated("Use official SDK's StdioClientTransport via StdioTransport.kt instead")
class StdioMCPTransport(
    private val config: MCPTransportConfig.StdioConfig
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
        throw UnsupportedOperationException(
            "StdioMCPTransport is deprecated. Use StdioTransport with official SDK instead."
        )
    }

    override suspend fun sendRequest(method: String, params: Map<String, Any>): JSONObject {
        throw UnsupportedOperationException(
            "StdioMCPTransport is deprecated. Use StdioTransport with official SDK instead."
        )
    }

    override suspend fun sendNotification(method: String, params: Map<String, Any>) {
        throw UnsupportedOperationException(
            "StdioMCPTransport is deprecated. Use StdioTransport with official SDK instead."
        )
    }

    override fun close() {
        isConnected = false
        Log.d(TAG, "StdioMCPTransport closed")
    }

    override fun isConnected(): Boolean = isConnected
}

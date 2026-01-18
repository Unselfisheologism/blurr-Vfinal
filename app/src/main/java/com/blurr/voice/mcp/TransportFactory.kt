package com.blurr.voice.mcp

import android.content.Context
import io.modelcontextprotocol.kotlin.sdk.client.Client
import io.modelcontextprotocol.kotlin.sdk.client.StdioClientTransport
import io.modelcontextprotocol.kotlin.sdk.client.SseClientTransport
import io.modelcontextprotocol.kotlin.sdk.client.StreamableHttpClientTransport

/**
 * Factory for creating MCP transport instances using official SDK
 *
 * Reference: https://github.com/modelcontextprotocol/kotlin-sdk
 */
object TransportFactory {
    /**
     * Create a transport instance based on type
     *
     * @param type Transport type (HTTP, SSE, STDIO)
     * @param url URL or path (depending on transport type)
     * @param context Android context
     * @return Result containing either the transport instance or an error
     */
    fun create(
        type: TransportType,
        url: String,
        context: Context
    ): Result<Any> {
        return try {
            val transport = when (type) {
                TransportType.HTTP -> {
                    // Create HTTP transport using official SDK
                    HttpTransport(url).createTransport()
                }
                TransportType.SSE -> {
                    // Create SSE transport using official SDK
                    SSETransport(url).createTransport()
                }
                TransportType.STDIO -> {
                    // Create Stdio transport using official SDK
                    // url is the process path for stdio
                    StdioTransport(url, context).createTransport()
                }
            }
            Result.success(transport)
        } catch (e: Exception) {
            android.util.Log.e("TransportFactory", "Failed to create transport for type: $type, url: $url", e)
            Result.failure(e)
        }
    }

    /**
     * Connect a client to a transport
     *
     * @param client The SDK client
     * @param transport The transport instance (created by create())
     */
    suspend fun connectClient(
        client: Client,
        transport: Any
    ) {
        when (transport) {
            is StdioClientTransport -> client.connect(transport)
            is SseClientTransport -> client.connect(transport)
            is StreamableHttpClientTransport -> client.connect(transport)
            else -> throw IllegalArgumentException("Unknown transport type: ${transport::class}")
        }
    }
}

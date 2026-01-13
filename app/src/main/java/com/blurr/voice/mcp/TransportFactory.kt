package com.blurr.voice.mcp

import android.content.Context
import io.modelcontextprotocol.kotlin.sdk.client.ClientTransport

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
     * @return Transport instance from official SDK
     */
    fun create(
        type: TransportType,
        url: String,
        context: Context
    ): ClientTransport {
        return when (type) {
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
    }
}

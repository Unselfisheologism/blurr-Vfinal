package com.blurr.voice.mcp

import android.content.Context
import android.util.Log
import io.modelcontextprotocol.kotlin.sdk.client.Client
import io.modelcontextprotocol.kotlin.sdk.client.StdioClientTransport
import io.modelcontextprotocol.kotlin.sdk.client.SseClientTransport
import io.modelcontextprotocol.kotlin.sdk.client.StreamableHttpClientTransport

/**
 * Factory for creating MCP transport instances using official SDK
 *
 * Reference: https://github.com/modelcontextprotocol/kotlin-sdk
 * 
 * This factory creates proper SDK transport instances and handles the connection
 * between Client and Transport, letting the SDK manage protocol initialization.
 */
object TransportFactory {
    private const val TAG = "TransportFactory"

    /**
     * Create a transport instance based on type
     *
     * @param type Transport type (HTTP, SSE, STDIO)
     * @param url URL or path (depending on transport type)
     * @param context Android context
     * @return SDK transport instance ready for client connection
     */
    fun create(
        type: TransportType,
        url: String,
        context: Context
    ): MCPTransportInstance {
        Log.d(TAG, "Creating transport: $type for: $url")
        
        return when (type) {
            TransportType.HTTP -> {
                // Create HTTP transport using official SDK
                val httpTransport = HttpTransport(url)
                val transport = httpTransport.createTransport()
                MCPTransportInstance(
                    transport = transport,
                    transportWrapper = httpTransport,
                    type = type,
                    url = url
                )
            }
            TransportType.SSE -> {
                // Create SSE transport using official SDK
                val sseTransport = SSETransport(url)
                val transport = sseTransport.createTransport()
                MCPTransportInstance(
                    transport = transport,
                    transportWrapper = sseTransport,
                    type = type,
                    url = url
                )
            }
            TransportType.STDIO -> {
                // Create Stdio transport using official SDK
                // url is the process path for stdio
                val stdioTransport = StdioTransport(url, context)
                val transport = stdioTransport.createTransport()
                MCPTransportInstance(
                    transport = transport,
                    transportWrapper = stdioTransport,
                    type = type,
                    url = url
                )
            }
        }
    }

    /**
     * Connect a client to a transport
     * 
     * This method handles the protocol initialization automatically using the SDK's Client class.
     * The SDK will send the InitializeRequest with protocol version, capabilities, and client info.
     *
     * @param client The SDK client (created with client info)
     * @param transportInstance The transport instance (created by create())
     * @return Connection result with server info
     */
    suspend fun connectClient(
        client: Client,
        transportInstance: MCPTransportInstance
    ): Result<ConnectionResult> {
        return try {
            Log.d(TAG, "Connecting client to ${transportInstance.type} transport")
            
            // Connect client to transport - SDK handles protocol initialization automatically
            when (val transport = transportInstance.transport) {
                is StdioClientTransport -> {
                    client.connect(transport)
                }
                is SseClientTransport -> {
                    client.connect(transport)
                }
                is StreamableHttpClientTransport -> {
                    client.connect(transport)
                }
                else -> {
                    throw IllegalArgumentException("Unsupported transport type: ${transport::class}")
                }
            }
            
            Log.d(TAG, "Client connected successfully via ${transportInstance.type}")
            
            // Get server info after successful connection
            val serverInfo = client.serverInfo()
            
            Result.success(
                ConnectionResult(
                    transportInstance = transportInstance,
                    serverInfo = serverInfo,
                    isConnected = true
                )
            )
        } catch (e: Exception) {
            Log.e(TAG, "Failed to connect client to transport", e)
            Result.failure(e)
        }
    }

    /**
     * Close a transport instance and cleanup resources
     */
    suspend fun closeTransport(instance: MCPTransportInstance) {
        try {
            Log.d(TAG, "Closing ${instance.type} transport")
            instance.transportWrapper?.close()
        } catch (e: Exception) {
            Log.e(TAG, "Error closing transport", e)
        }
    }
}

/**
 * Container for transport instance and its wrapper
 */
data class MCPTransportInstance(
    val transport: Any,
    val transportWrapper: Any?,
    val type: TransportType,
    val url: String
)

/**
 * Result of client-transport connection
 */
data class ConnectionResult(
    val transportInstance: MCPTransportInstance,
    val serverInfo: io.modelcontextprotocol.kotlin.sdk.types.ServerInfo,
    val isConnected: Boolean
)

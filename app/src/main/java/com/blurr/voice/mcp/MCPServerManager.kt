package com.blurr.voice.mcp

import android.content.Context
import android.util.Log
import io.modelcontextprotocol.kotlin.sdk.Implementation
import io.modelcontextprotocol.kotlin.sdk.types.Tool
import io.modelcontextprotocol.kotlin.sdk.client.Client
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import com.blurr.voice.data.MCPServerPreferences

/**
 * MCP Server Manager using Official Kotlin SDK
 * 
 * Manages MCP server connections using the official Model Context Protocol Kotlin SDK.
 * Reference: https://github.com/modelcontextprotocol/kotlin-sdk
 */
class MCPServerManager(
    private val context: Context
) {
    companion object {
        private const val TAG = "MCPServerManager"
    }

    // Server registry: name -> MCPServerConnection
    private val servers = mutableMapOf<String, MCPServerConnection>()
    
    // Preferences for persistence
    private val preferences = MCPServerPreferences(context)
    
    /**
     * Connect to an MCP server using official Kotlin SDK
     * 
     * The SDK's Client.connect() method automatically handles:
     * - Sending InitializeRequest with protocol version and capabilities
     * - Receiving InitializeResult from server
     * - Sending InitializedNotification to complete handshake
     * 
     * @param name Unique name for this server connection
     * @param url URL or path (depending on transport type)
     * @param transport Transport type (HTTP, SSE, STDIO)
     * @return Result containing server info or error
     */
    suspend fun connectServer(
        name: String,
        url: String,
        transport: TransportType
    ): Result<MCPServerInfo> {
        return withContext(Dispatchers.IO) {
            try {
                Log.d(TAG, "=== Connecting to MCP Server ===")
                Log.d(TAG, "Name: $name")
                Log.d(TAG, "URL: $url")
                Log.d(TAG, "Transport: $transport")
                
                // Create official SDK client with app info
                val client = Client(
                    clientInfo = Implementation(
                        name = "blurr-voice-app",
                        version = "1.0.0"
                    )
                )
                Log.d(TAG, "Created SDK Client instance")

                // Create transport using factory
                Log.d(TAG, "Creating transport via TransportFactory...")
                val transportResult = TransportFactory.create(transport, url, context)
                if (transportResult.isFailure) {
                    val error = transportResult.exceptionOrNull()
                    Log.e(TAG, "Failed to create transport: ${error?.message}", error)
                    return@withContext Result.failure(Exception("Failed to create transport: ${error?.message}", error))
                }
                
                val mcpTransport = transportResult.getOrThrow()
                Log.d(TAG, "Transport created: ${mcpTransport::class.simpleName}")

                // Connect to server - SDK handles protocol negotiation automatically
                Log.d(TAG, "Calling client.connect()... (SDK will handle InitializeRequest/Result)")
                TransportFactory.connectClient(client, mcpTransport)
                Log.d(TAG, "Client connected successfully!")

                // Access server information from client (populated after connect)
                val serverCaps = client.serverCapabilities
                val serverVer = client.serverVersion
                
                Log.d(TAG, "Server capabilities: $serverCaps")
                Log.d(TAG, "Server version: ${serverVer?.name} v${serverVer?.version}")

                // List tools from server
                Log.d(TAG, "Fetching available tools from server...")
                val toolsResult = client.listTools()
                val tools = toolsResult.tools ?: emptyList()
                
                Log.d(TAG, "Discovered ${tools.size} tools from $name")
                tools.forEach { tool ->
                    Log.d(TAG, "  - ${tool.name}: ${tool.description}")
                }
                
                // Create server info with data from SDK client
                val serverInfo = MCPServerInfo(
                    name = name,
                    url = url,
                    transport = transport,
                    toolCount = tools.size,
                    isConnected = true,
                    protocolVersion = "2024-11-05",  // MCP protocol version
                    serverName = serverVer?.name ?: name,
                    serverVersion = serverVer?.version ?: "unknown"
                )
                
                // Store connection
                val connection = MCPServerConnection(
                    name = name,
                    url = url,
                    transport = transport,
                    connected = true,
                    serverInfo = serverInfo,
                    client = client,
                    tools = tools
                )
                
                servers[name] = connection
                
                // Save to preferences
                preferences.saveServer(name, url, transport, enabled = true)
                
                Log.d(TAG, "=== Successfully Connected to $name ===")
                Log.d(TAG, "Server: ${serverInfo.serverName} v${serverInfo.serverVersion}")
                Log.d(TAG, "Tools: ${serverInfo.toolCount}")
                Log.d(TAG, "Protocol: ${serverInfo.protocolVersion}")
                
                Result.success(serverInfo)
            } catch (e: Exception) {
                Log.e(TAG, "=== Failed to Connect to MCP Server: $name ===", e)
                Log.e(TAG, "Transport: $transport")
                Log.e(TAG, "URL: $url")
                Log.e(TAG, "Error: ${e.message}")
                Log.e(TAG, "Stack trace:", e)
                Result.failure(e)
            }
        }
    }
    
    /**
     * Disconnect from a specific server
     * 
     * Properly closes the SDK client which will:
     * - Close the underlying transport
     * - Trigger onClose callbacks
     * - Clean up resources
     * 
     * @param name Server name to disconnect
     * @return Result indicating success or failure
     */
    suspend fun disconnectServer(name: String): Result<Unit> {
        return withContext(Dispatchers.IO) {
            try {
                Log.d(TAG, "=== Disconnecting from MCP Server ===")
                Log.d(TAG, "Server: $name")
                
                val connection = servers[name]
                if (connection != null) {
                    Log.d(TAG, "Found connection, closing client...")
                    
                    // Close the SDK client (triggers transport.onClose callbacks)
                    connection.client.close()
                    
                    Log.d(TAG, "Client closed successfully")
                    
                    // Remove from active servers
                    servers.remove(name)
                    
                    // Remove from preferences
                    preferences.deleteServer(name)
                    
                    Log.d(TAG, "=== Successfully Disconnected from $name ===")
                } else {
                    Log.w(TAG, "Server $name not found in active connections")
                }
                
                Result.success(Unit)
            } catch (e: Exception) {
                Log.e(TAG, "=== Error Disconnecting from $name ===", e)
                Log.e(TAG, "Error: ${e.message}")
                Log.e(TAG, "Stack trace:", e)
                Result.failure(e)
            }
        }
    }
    
    /**
     * Get list of all server connections
     */
    fun getServers(): List<MCPServerConnection> {
        return servers.values.toList()
    }
    
    /**
     * Get a specific server connection
     */
    fun getServer(name: String): MCPServerConnection? {
        return servers[name]
    }
    
    /**
     * Get tools from a specific server or all servers
     * 
     * @param serverName Server name (null for all servers)
     * @return List of tools
     */
    fun getTools(serverName: String? = null): List<MCPToolInfo> {
        return if (serverName != null) {
            val connection = servers[serverName]
            connection?.tools?.map { tool ->
                MCPToolInfo(
                    serverName = serverName,
                    name = tool.name,
                    description = tool.description ?: "",
                    inputSchema = tool.inputSchema
                )
            } ?: emptyList()
        } else {
            servers.flatMap { (name, connection) ->
                connection.tools.map { tool ->
                    MCPToolInfo(
                        serverName = name,
                        name = tool.name,
                        description = tool.description ?: "",
                        inputSchema = tool.inputSchema
                    )
                }
            }
        }
    }
    
    /**
     * Execute a tool on a specific server
     * 
     * Uses the SDK's Client.callTool() method which handles:
     * - JSON-RPC request formatting
     * - Response parsing
     * - Error handling
     * 
     * @param serverName Server name
     * @param toolName Tool name
     * @param arguments Tool arguments
     * @return Result containing tool result or error
     */
    suspend fun executeTool(
        serverName: String,
        toolName: String,
        arguments: Map<String, Any>
    ): Result<String> {
        return withContext(Dispatchers.IO) {
            try {
                Log.d(TAG, "=== Executing MCP Tool ===")
                Log.d(TAG, "Server: $serverName")
                Log.d(TAG, "Tool: $toolName")
                Log.d(TAG, "Arguments: $arguments")
                
                val connection = servers[serverName]
                if (connection == null) {
                    Log.e(TAG, "Server not connected: $serverName")
                    return@withContext Result.failure(Exception("Server not connected: $serverName"))
                }
                
                if (!connection.connected) {
                    Log.e(TAG, "Server connection is not active: $serverName")
                    return@withContext Result.failure(Exception("Server connection is not active: $serverName"))
                }
                
                Log.d(TAG, "Calling SDK client.callTool()...")
                val result = connection.client.callTool(
                    name = toolName,
                    arguments = arguments
                )
                
                Log.d(TAG, "Received tool response with ${result.content.size} content items")
                
                // Extract text content from result
                val textContent = result.content.joinToString("\n") { content ->
                    when (content) {
                        is io.modelcontextprotocol.kotlin.sdk.types.TextContent -> {
                            Log.d(TAG, "Text content: ${content.text}")
                            content.text
                        }
                        else -> {
                            Log.d(TAG, "Other content type: ${content::class.simpleName}")
                            content.toString()
                        }
                    }
                }
                
                Log.d(TAG, "=== Tool Execution Successful ===")
                Log.d(TAG, "Result length: ${textContent.length} chars")
                Result.success(textContent)
            } catch (e: Exception) {
                Log.e(TAG, "=== Tool Execution Failed ===", e)
                Log.e(TAG, "Server: $serverName")
                Log.e(TAG, "Tool: $toolName")
                Log.e(TAG, "Error: ${e.message}")
                Log.e(TAG, "Stack trace:", e)
                Result.failure(e)
            }
        }
    }
    
    /**
     * Load saved servers from preferences and connect to them
     */
    suspend fun loadSavedServers() {
        withContext(Dispatchers.IO) {
            try {
                val savedServers = preferences.loadServers()
                Log.d(TAG, "Loading ${savedServers.size} saved servers")
                
                savedServers.forEach { saved ->
                    if (saved.enabled) {
                        Log.d(TAG, "Auto-connecting to ${saved.name}")
                        connectServer(saved.name, saved.url, saved.transport)
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error loading saved servers", e)
            }
        }
    }
    
    /**
     * Check if a server is connected
     */
    fun isServerConnected(name: String): Boolean {
        return servers.containsKey(name) && servers[name]?.connected == true
    }
    
    /**
     * Get list of connected server names
     */
    fun getConnectedServerNames(): List<String> {
        return servers.filter { it.value.connected }.keys.toList()
    }
}

/**
 * MCP Server connection data class
 */
data class MCPServerConnection(
    val name: String,
    val url: String,
    val transport: TransportType,
    val connected: Boolean,
    val serverInfo: MCPServerInfo?,
    val client: Client,
    val tools: List<Tool>
)

/**
 * Transport type enum
 */
enum class TransportType {
    HTTP, SSE, STDIO;
    
    companion object {
        fun fromString(value: String): TransportType {
            return when (value.uppercase()) {
                "HTTP" -> HTTP
                "SSE" -> SSE
                "STDIO" -> STDIO
                else -> throw IllegalArgumentException("Unknown transport type: $value")
            }
        }
    }
}

/**
 * MCP Server information
 */
data class MCPServerInfo(
    val name: String,
    val url: String,
    val transport: TransportType,
    val toolCount: Int,
    val isConnected: Boolean,
    val protocolVersion: String,
    val serverName: String = name,  // Display name from server
    val serverVersion: String = "unknown"  // Version from server
)

/**
 * MCP Tool information
 */
data class MCPToolInfo(
    val serverName: String,
    val name: String,
    val description: String,
    val inputSchema: Any?
)

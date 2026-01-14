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
     * Connect to an MCP server
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
                Log.d(TAG, "Connecting to MCP server: $name via $transport")
                
                // Create official SDK client
                val client = Client(
                    clientInfo = Implementation(
                        name = "blurr-voice-app",
                        version = "1.0.0"
                    )
                )

                // Create transport using factory
                val mcpTransport = TransportFactory.create(transport, url, context)

                // Connect to server
                TransportFactory.connectClient(client, mcpTransport)

                // List tools from server
                val toolsResult = client.listTools()
                val tools = toolsResult.tools ?: emptyList()
                
                Log.d(TAG, "Discovered ${tools.size} tools from $name")
                
                // Get server info
                val serverInfo = MCPServerInfo(
                    name = name,
                    url = url,
                    transport = transport,
                    toolCount = tools.size,
                    isConnected = true,
                    protocolVersion = "2024-11-05"
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
                
                Log.d(TAG, "Successfully connected to $name")
                Result.success(serverInfo)
            } catch (e: Exception) {
                Log.e(TAG, "Failed to connect to MCP server: $name", e)
                Result.failure(e)
            }
        }
    }
    
    /**
     * Disconnect from a specific server
     * 
     * @param name Server name to disconnect
     * @return Result indicating success or failure
     */
    suspend fun disconnectServer(name: String): Result<Unit> {
        return withContext(Dispatchers.IO) {
            try {
                Log.d(TAG, "Disconnecting from MCP server: $name")
                
                val connection = servers[name]
                if (connection != null) {
                    connection.client.close()
                    servers.remove(name)
                    preferences.deleteServer(name)
                    Log.d(TAG, "Disconnected from: $name")
                }
                
                Result.success(Unit)
            } catch (e: Exception) {
                Log.e(TAG, "Error disconnecting from $name", e)
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
                val connection = servers[serverName]
                    ?: return@withContext Result.failure(Exception("Server not connected: $serverName"))
                
                Log.d(TAG, "Executing tool $toolName on $serverName with args: $arguments")
                
                val result = connection.client.callTool(
                    name = toolName,
                    arguments = arguments
                )
                
                // Extract text content from result
                val textContent = result.content.joinToString("\n") { content ->
                    when (content) {
                        is io.modelcontextprotocol.kotlin.sdk.types.TextContent -> content.text
                        else -> content.toString()
                    }
                }
                
                Log.d(TAG, "Tool execution successful: $textContent")
                Result.success(textContent)
            } catch (e: Exception) {
                Log.e(TAG, "Tool execution failed: $serverName:$toolName", e)
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

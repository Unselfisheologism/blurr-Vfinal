package com.blurr.voice.mcp.sdk

import android.content.Context
import android.util.Log
import com.blurr.voice.mcp.MCPClient
import com.blurr.voice.mcp.MCPTransport
import com.blurr.voice.data.MCPServerPreferences
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

/**
 * MCPServerManager - Official Kotlin MCP SDK Integration Bridge
 * 
 * Manages MCP server connections using the existing MCP infrastructure while
 * providing a bridge to official SDK patterns. This is a foundation implementation
 * that can be upgraded to use the official MCP Kotlin SDK once Kotlin version
 * compatibility is resolved.
 * 
 * NOTE: This implementation uses the existing MCPClient and MCPTransport infrastructure
 * as a bridge to official SDK patterns. Once Kotlin is upgraded to 2.2.x, this
 * can be directly migrated to use the official MCP Kotlin SDK.
 * 
 * Reference: https://github.com/modelcontextprotocol/kotlin-sdk
 */
class MCPServerManager(
    private val context: Context,
    private val mcpClient: MCPClient
) {
    private val supervisorJob = SupervisorJob()
    private val coroutineScope = CoroutineScope(Dispatchers.IO + supervisorJob)
    
    // Server registry: name -> MCPServerConnection
    private val servers = mutableMapOf<String, MCPServerConnection>()
    
    // Preferences for persistence
    private val preferences = MCPServerPreferences(context)
    
    companion object {
        private const val TAG = "MCPServerManager"
        private const val CONNECTION_TIMEOUT_SECONDS = 30L
        
        /**
         * NOTE: Official MCP SDK Integration (Future Implementation)
         * 
         * Once Kotlin version is upgraded to 2.2.x, this class will be updated
         * to use the official MCP Kotlin SDK directly:
         * 
         * import io.modelcontextprotocol.kotlin.sdk.client.Client
         * import io.modelcontextprotocol.kotlin.sdk.client.Implementation
         * 
         * private fun createOfficialMCPClient(): Client {
         *     return Client(
         *         clientInfo = Implementation(
         *             name = "blurr-voice-android",
         *             version = "1.0.0"
         *         )
         *     )
         * }
         */
    }
    
    /**
     * Connect to an MCP server using existing infrastructure
     * 
     * This method provides the same interface as the official SDK while
     * using the existing MCPClient and MCPTransport infrastructure.
     * 
     * @param name Unique name for this server connection
     * @param url Server URL or stdio command
     * @param transport Transport type (HTTP, SSE, STDIO, WEBSOCKET)
     * @return Result with MCPServerInfo on success
     */
    suspend fun connectServer(
        name: String,
        url: String,
        transport: TransportType
    ): Result<MCPServerInfo> {
        return try {
            Log.d(TAG, "Connecting to MCP server: $name via $transport")
            
            // Create transport using existing infrastructure (bridge to official SDK pattern)
            val mcpTransport = createTransport(transport, url)
            
            // Connect using existing MCPClient
            val connectResult = mcpClient.connect(name, mcpTransport)
            
            if (connectResult.isFailure) {
                throw connectResult.exceptionOrNull() ?: Exception("Unknown connection error")
            }
            
            // Get server information from existing infrastructure
            val serverInfo = mcpClient.getServerInfo(name)
            
            if (serverInfo == null) {
                throw Exception("Failed to get server info for $name")
            }
            
            // Get tools from server
            val allTools = mcpClient.getAllToolsRaw()
            val serverTools = allTools.filter { it.name.startsWith("$name:") }
            
            Log.d(TAG, "Connected to $name with ${serverTools.size} tools")
            
            // Register server connection
            val serverConnection = MCPServerConnection(
                name = name,
                url = url,
                transport = transport,
                connected = true,
                serverInfo = serverInfo.toServerInfo(),
                tools = serverTools.map { it.toToolInfo() }
            )
            
            servers[name] = serverConnection
            
            // Save server configuration
            preferences.saveServer(
                MCPServerPreferences.MCPServerConfig(
                    name = name,
                    url = url,
                    transport = transport.name,
                    enabled = true
                )
            )
            
            Result.success(serverInfo.toServerInfo())
        } catch (e: Exception) {
            Log.e(TAG, "Failed to connect to MCP server: $name", e)
            Result.failure(e)
        }
    }
    
    /**
     * Disconnect from an MCP server
     * 
     * @param name Server name to disconnect
     * @return Result with success or failure
     */
    suspend fun disconnectServer(name: String): Result<Unit> {
        return try {
            val serverConnection = servers[name]
            if (serverConnection == null) {
                Log.w(TAG, "Server $name not found in registry")
                return Result.success(Unit)
            }
            
            Log.d(TAG, "Disconnecting from MCP server: $name")
            
            // Disconnect using existing MCPClient
            mcpClient.disconnect(name)
            
            // Remove from registry
            servers.remove(name)
            
            // Update preferences
            preferences.removeServer(name)
            
            Log.d(TAG, "Successfully disconnected from: $name")
            Result.success(Unit)
        } catch (e: Exception) {
            Log.e(TAG, "Error disconnecting from $name", e)
            Result.failure(e)
        }
    }
    
    /**
     * Get all connected servers
     * 
     * @return List of server connections
     */
    fun getServers(): List<MCPServerConnection> {
        return servers.values.toList()
    }
    
    /**
     * Get specific server connection
     * 
     * @param name Server name
     * @return Server connection or null if not found
     */
    fun getServer(name: String): MCPServerConnection? {
        return servers[name]
    }
    
    /**
     * Check if server is connected
     * 
     * @param name Server name
     * @return true if connected
     */
    fun isServerConnected(name: String): Boolean {
        return servers[name]?.connected == true || mcpClient.isServerConnected(name)
    }
    
    /**
     * Load and restore saved servers from preferences
     * Called during app initialization
     */
    suspend fun loadSavedServers() {
        try {
            val savedServers = preferences.getEnabledServers()
            Log.d(TAG, "Loading ${savedServers.size} saved MCP servers")
            
            savedServers.forEach { savedServer ->
                connectServer(
                    name = savedServer.name,
                    url = savedServer.url,
                    transport = TransportType.fromString(savedServer.transport)
                ).fold(
                    onSuccess = { serverInfo ->
                        Log.d(TAG, "Auto-connected to saved server: ${savedServer.name}")
                    },
                    onFailure = { error ->
                        Log.w(TAG, "Failed to auto-connect to saved server: ${savedServer.name}", error)
                    }
                )
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error loading saved servers", e)
        }
    }
    
    /**
     * Execute a tool on a specific MCP server
     * 
     * @param serverName Name of the server
     * @param toolName Name of the tool to execute (format: "server:tool" or "tool")
     * @param arguments Tool arguments as map
     * @return Result with tool execution result
     */
    suspend fun executeTool(
        serverName: String,
        toolName: String,
        arguments: Map<String, Any>
    ): Result<ToolExecutionResult> {
        return try {
            // Format tool name as "server:tool" if not already formatted
            val fullToolName = if (toolName.contains(":")) {
                toolName
            } else {
                "$serverName:$toolName"
            }
            
            // Get tool from existing MCPClient
            val tool = mcpClient.getTool(fullToolName)
            if (tool == null) {
                throw IllegalArgumentException("Tool $fullToolName not found on server $serverName")
            }
            
            // Execute tool using existing infrastructure
            val result = tool.execute(arguments)
            
            Result.success(
                ToolExecutionResult(
                    content = listOf(result),
                    isError = false
                )
            )
        } catch (e: Exception) {
            Log.e(TAG, "Failed to execute tool $toolName on server $serverName", e)
            Result.failure(e)
        }
    }
    
    /**
     * List all tools from all connected servers
     * 
     * @return List of available tools
     */
    suspend fun getAllTools(): List<AvailableTool> {
        val allTools = mcpClient.getAllToolsRaw()
        
        return allTools.map { tool ->
            AvailableTool(
                serverName = tool.name.substringBefore(":"),
                toolName = tool.name.substringAfter(":"),
                description = tool.description,
                inputSchema = tool.inputSchema,
                outputSchema = tool.outputSchema
            )
        }
    }
    
    /**
     * Create transport using existing infrastructure
     * 
     * NOTE: This bridges to the existing transport implementations.
     * When upgrading to official SDK, this will be replaced with:
     * 
     * private fun createTransport(type: TransportType, url: String): Transport {
     *     return when (type) {
     *         TransportType.HTTP -> HttpClientTransport(baseUrl = url)
     *         TransportType.SSE -> SSEClientTransport(baseUrl = url)
     *         TransportType.STDIO -> {
     *             val (command, args) = parseStdioCommand(url)
     *             StdioClientTransport(command = command, arguments = args)
     *         }
     *         TransportType.WEBSOCKET -> WebSocketClientTransport(url = url)
     *     }
     * }
     */
    private fun createTransport(
        type: TransportType,
        url: String
    ): MCPTransport {
        return when (type) {
            TransportType.HTTP -> {
                // TODO: Bridge to official SDK HTTP transport
                // For now, use existing HTTP transport implementation
                com.blurr.voice.mcp.HttpMCPTransport(url)
            }
            TransportType.SSE -> {
                // TODO: Bridge to official SDK SSE transport  
                // For now, use existing SSE transport implementation
                com.blurr.voice.mcp.SSEMCPTransport(url)
            }
            TransportType.STDIO -> {
                // TODO: Bridge to official SDK STDIO transport
                // For now, use existing STDIO transport implementation
                val (command, args) = parseStdioCommand(url)
                com.blurr.voice.mcp.StdioMCPTransport(command, args)
            }
            TransportType.WEBSOCKET -> {
                // TODO: Implement WebSocket transport (bridge to official SDK)
                throw UnsupportedOperationException("WebSocket transport not yet implemented")
            }
        }
    }
    
    /**
     * Parse stdio command and arguments from URL
     * Format: "command:arg1:arg2:arg3" or "command"
     */
    private fun parseStdioCommand(url: String): Pair<String, List<String>> {
        return if (url.contains(":")) {
            val parts = url.split(":", limit = 2)
            val command = parts[0]
            val args = parts[1].split(":")
            command to args
        } else {
            url to emptyList()
        }
    }
    
    /**
     * Validate MCP server connection
     * 
     * @param name Server name to test
     * @param url Server URL
     * @param transport Transport type
     * @return Result with validation info
     */
    suspend fun validateConnection(
        name: String,
        url: String,
        transport: TransportType
    ): Result<ConnectionValidation> {
        return try {
            // Create temporary transport for testing
            val tempTransport = createTransport(transport, url)
            
            // Create temporary connection for testing
            val tempClient = MCPClient(context)
            val tempName = "${name}_test_${System.currentTimeMillis()}"
            
            // Attempt connection
            val connectResult = tempClient.connect(tempName, tempTransport)
            if (connectResult.isFailure) {
                throw connectResult.exceptionOrNull() ?: Exception("Connection test failed")
            }
            
            // Get server info
            val serverInfo = tempClient.getServerInfo(tempName)
            val tools = tempClient.getAllToolsRaw().filter { it.name.startsWith("$tempName:") }
            
            // Close test connection
            tempClient.disconnect(tempName)
            
            Result.success(
                ConnectionValidation(
                    serverName = name,
                    serverInfo = serverInfo?.toServerInfo(),
                    toolCount = tools.size,
                    transport = transport,
                    isValid = true
                )
            )
        } catch (e: Exception) {
            Log.e(TAG, "Connection validation failed for $name", e)
            Result.failure(e)
        }
    }
    
    /**
     * Clean up resources
     */
    fun shutdown() {
        coroutineScope.launch {
            try {
                servers.keys.forEach { name ->
                    mcpClient.disconnect(name)
                }
                servers.clear()
                supervisorJob.cancel()
            } catch (e: Exception) {
                Log.e(TAG, "Error during shutdown", e)
            }
        }
    }
}

/**
 * Server connection information
 */
data class MCPServerConnection(
    val name: String,
    val url: String,
    val transport: TransportType,
    val connected: Boolean,
    val serverInfo: ServerInfo?,
    val tools: List<ToolInfo>
)

/**
 * Official MCP Server Information from SDK (bridge to existing MCPServerInfo)
 */
data class ServerInfo(
    val name: String,
    val version: String,
    val protocolVersion: String
)

/**
 * Official MCP Tool Information from SDK (bridge to existing MCPTool)
 */
data class ToolInfo(
    val name: String,
    val description: String,
    val inputSchema: Map<String, Any>?,
    val outputSchema: Map<String, Any>?
)

/**
 * Available tool for execution
 */
data class AvailableTool(
    val serverName: String,
    val toolName: String,
    val description: String,
    val inputSchema: Map<String, Any>?,
    val outputSchema: Map<String, Any>?
)

/**
 * Tool execution result
 */
data class ToolExecutionResult(
    val content: List<Any>,
    val isError: Boolean = false,
    val errorMessage: String? = null
)

/**
 * Transport type enumeration
 */
enum class TransportType(val displayName: String, val description: String) {
    HTTP("HTTP", "REST API over HTTP/HTTPS"),
    SSE("SSE", "Server-Sent Events for streaming"),
    STDIO("Stdio", "Standard I/O pipes for local processes"),
    WEBSOCKET("WebSocket", "Bidirectional WebSocket connection");
    
    companion object {
        fun fromString(value: String): TransportType {
            return entries.firstOrNull { it.name.equals(value, ignoreCase = true) }
                ?: throw IllegalArgumentException("Unknown transport type: $value")
        }
    }
}

/**
 * Connection validation result
 */
data class ConnectionValidation(
    val serverName: String,
    val serverInfo: ServerInfo?,
    val toolCount: Int,
    val transport: TransportType,
    val isValid: Boolean
)

// Extension functions to bridge existing MCP types to official SDK patterns
private fun MCPServerInfo.toServerInfo(): ServerInfo {
    return ServerInfo(
        name = serverName,
        version = serverVersion,
        protocolVersion = protocolVersion
    )
}

private fun com.blurr.voice.tools.Tool.toToolInfo(): ToolInfo {
    return ToolInfo(
        name = name,
        description = description,
        inputSchema = inputSchema,
        outputSchema = outputSchema
    )
}
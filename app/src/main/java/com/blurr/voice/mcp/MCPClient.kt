package com.blurr.voice.mcp

import android.content.Context
import android.util.Log
import com.blurr.voice.tools.Tool
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/**
 * Model Context Protocol (MCP) Client
 * 
 * Connects to MCP servers and provides access to their tools.
 * Implements MCP protocol version 2024-11-05.
 * 
 * Reference: https://modelcontextprotocol.io/
 */
class MCPClient(
    private val context: Context
) {
    private val servers = mutableMapOf<String, MCPServer>()
    private val tools = mutableMapOf<String, MCPTool>()
    private val toolPreferences by lazy { 
        com.blurr.voice.data.ToolPreferences(context) 
    }
    
    companion object {
        private const val TAG = "MCPClient"
        const val PROTOCOL_VERSION = "2024-11-05"
    }
    
    /**
     * Connect to an MCP server
     * 
     * @param name Unique name for this server connection
     * @param transport Transport implementation (HTTP, WebSocket, stdio)
     * @return Result indicating success or failure
     */
    suspend fun connect(
        name: String,
        transport: MCPTransport
    ): Result<Unit> {
        return withContext(Dispatchers.IO) {
            try {
                Log.d(TAG, "Connecting to MCP server: $name")
                
                val server = MCPServer(name, transport)
                server.initialize()
                
                // Discover tools from server
                val discoveredTools = server.listTools()
                Log.d(TAG, "Discovered ${discoveredTools.size} tools from $name")
                
                discoveredTools.forEach { tool ->
                    val toolKey = "${name}:${tool.name}"
                    tools[toolKey] = tool
                    Log.d(TAG, "Registered tool: $toolKey - ${tool.description}")
                }
                
                servers[name] = server
                Result.success(Unit)
            } catch (e: Exception) {
                Log.e(TAG, "Failed to connect to MCP server: $name", e)
                Result.failure(e)
            }
        }
    }
    
    /**
     * Get tool from MCP server by name
     * 
     * @param name Tool name in format "server:tool" or just "tool"
     * @return Tool instance or null if not found
     */
    fun getTool(name: String): Tool? {
        // Try exact match first (server:tool)
        val mcpTool = tools[name]
        if (mcpTool != null) {
            val serverName = name.substringBefore(":")
            val server = servers[serverName]
            return server?.let { MCPToolAdapter(mcpTool, it) }
        }
        
        // Try searching across all servers
        val matchingTool = tools.entries.firstOrNull { it.key.endsWith(":$name") }
        if (matchingTool != null) {
            val serverName = matchingTool.key.substringBefore(":")
            val server = servers[serverName]
            return server?.let { MCPToolAdapter(matchingTool.value, it) }
        }
        
        return null
    }
    
    /**
     * Get all available tools from all connected servers (only enabled)
     */
    fun getAllTools(): List<Tool> {
        return tools.entries.mapNotNull { (key, mcpTool) ->
            if (!toolPreferences.isToolEnabled(key)) {
                return@mapNotNull null
            }
            val serverName = key.substringBefore(":")
            val server = servers[serverName]
            server?.let { MCPToolAdapter(mcpTool, it) }
        }
    }
    
    /**
     * Get all available tools regardless of enabled state (for UI)
     */
    fun getAllToolsRaw(): List<Tool> {
        return tools.entries.mapNotNull { (key, mcpTool) ->
            val serverName = key.substringBefore(":")
            val server = servers[serverName]
            server?.let { MCPToolAdapter(mcpTool, it) }
        }
    }
    
    /**
     * Describe all available MCP tools (only enabled)
     * Returns a formatted string for LLM system prompts
     */
    fun describeTools(): String {
        val enabledTools = tools.filter { (key, _) -> 
            toolPreferences.isToolEnabled(key) 
        }
        
        if (enabledTools.isEmpty()) {
            return "No MCP tools available."
        }
        
        return buildString {
            appendLine("MCP Tools:")
            enabledTools.forEach { (key, tool) ->
                appendLine("- $key: ${tool.description}")
            }
        }
    }
    
    /**
     * Get list of connected server names
     */
    fun getConnectedServers(): List<String> {
        return servers.keys.toList()
    }
    
    /**
     * Check if server is connected
     */
    fun isServerConnected(name: String): Boolean {
        return servers.containsKey(name)
    }
    
    /**
     * Disconnect from a specific server
     * 
     * @param name Server name to disconnect
     */
    suspend fun disconnect(name: String) {
        withContext(Dispatchers.IO) {
            try {
                Log.d(TAG, "Disconnecting from MCP server: $name")
                servers[name]?.close()
                servers.remove(name)
                
                // Remove all tools from this server
                tools.keys.removeAll { it.startsWith("$name:") }
                
                Log.d(TAG, "Disconnected from: $name")
            } catch (e: Exception) {
                Log.e(TAG, "Error disconnecting from $name", e)
            }
        }
    }
    
    /**
     * Disconnect from all servers
     */
    suspend fun disconnectAll() {
        withContext(Dispatchers.IO) {
            val serverNames = servers.keys.toList()
            serverNames.forEach { disconnect(it) }
        }
    }
    
    /**
     * Get server information
     */
    fun getServerInfo(name: String): MCPServerInfo? {
        val server = servers[name] ?: return null
        val serverTools = tools.filterKeys { it.startsWith("$name:") }.values.toList()
        
        return MCPServerInfo(
            name = name,
            protocolVersion = server.serverInfo?.protocolVersion ?: "unknown",
            serverName = server.serverInfo?.serverName ?: name,
            serverVersion = server.serverInfo?.serverVersion ?: "unknown",
            toolCount = serverTools.size,
            isConnected = true
        )
    }
    
    /**
     * Get all server information
     */
    fun getAllServerInfo(): List<MCPServerInfo> {
        return servers.keys.mapNotNull { getServerInfo(it) }
    }
}

package com.blurr.voice.mcp

import android.util.Log
import org.json.JSONArray
import org.json.JSONObject

/**
 * MCP Server connection
 * 
 * Manages connection to a single MCP server and handles
 * protocol-level communication.
 */
class MCPServer(
    val name: String,
    private val transport: MCPTransport
) {
    var serverInfo: ServerInfo? = null
        private set
    
    private var initialized = false
    
    companion object {
        private const val TAG = "MCPServer"
    }
    
    /**
     * Initialize connection with server
     * Sends initialize request and receives server capabilities
     */
    suspend fun initialize() {
        if (initialized) {
            Log.w(TAG, "Server $name already initialized")
            return
        }
        
        Log.d(TAG, "Initializing MCP server: $name")
        
        // Connect transport
        transport.connect()
        
        // Send initialize request
        val response = transport.sendRequest(
            method = "initialize",
            params = mapOf(
                "protocolVersion" to MCPClient.PROTOCOL_VERSION,
                "capabilities" to mapOf(
                    "tools" to emptyMap<String, Any>(),
                    "experimental" to emptyMap<String, Any>()
                ),
                "clientInfo" to mapOf(
                    "name" to "Blurr AI Assistant",
                    "version" to "1.0.0"
                )
            )
        )
        
        // Parse server info
        serverInfo = ServerInfo(
            protocolVersion = response.optString("protocolVersion", MCPClient.PROTOCOL_VERSION),
            serverName = response.optJSONObject("serverInfo")?.optString("name", name) ?: name,
            serverVersion = response.optJSONObject("serverInfo")?.optString("version", "unknown") ?: "unknown",
            capabilities = response.optJSONObject("capabilities")?.toString() ?: "{}"
        )
        
        initialized = true
        Log.d(TAG, "Server initialized: ${serverInfo?.serverName} v${serverInfo?.serverVersion}")
        
        // Send initialized notification
        transport.sendNotification(
            method = "notifications/initialized"
        )
    }
    
    /**
     * List all tools available from this server
     */
    suspend fun listTools(): List<MCPTool> {
        if (!initialized) {
            throw IllegalStateException("Server not initialized: $name")
        }
        
        Log.d(TAG, "Listing tools from server: $name")
        
        val response = transport.sendRequest(
            method = "tools/list",
            params = emptyMap()
        )
        
        val toolsArray = response.optJSONArray("tools") ?: JSONArray()
        val tools = mutableListOf<MCPTool>()
        
        for (i in 0 until toolsArray.length()) {
            val toolJson = toolsArray.getJSONObject(i)
            tools.add(MCPTool.fromJson(toolJson))
        }
        
        Log.d(TAG, "Found ${tools.size} tools from $name")
        return tools
    }
    
    /**
     * Call a tool on this server
     * 
     * @param toolName Name of the tool to call
     * @param arguments Arguments to pass to the tool
     * @return Result from tool execution
     */
    suspend fun callTool(
        toolName: String,
        arguments: Map<String, Any>
    ): JSONObject {
        if (!initialized) {
            throw IllegalStateException("Server not initialized: $name")
        }
        
        Log.d(TAG, "Calling tool: $toolName on server: $name")
        Log.d(TAG, "Arguments: $arguments")
        
        val response = transport.sendRequest(
            method = "tools/call",
            params = mapOf(
                "name" to toolName,
                "arguments" to arguments
            )
        )
        
        Log.d(TAG, "Tool call successful: $toolName")
        return response
    }
    
    /**
     * Close connection to server
     */
    fun close() {
        Log.d(TAG, "Closing connection to server: $name")
        transport.close()
        initialized = false
    }
    
    /**
     * Server information
     */
    data class ServerInfo(
        val protocolVersion: String,
        val serverName: String,
        val serverVersion: String,
        val capabilities: String
    )
}

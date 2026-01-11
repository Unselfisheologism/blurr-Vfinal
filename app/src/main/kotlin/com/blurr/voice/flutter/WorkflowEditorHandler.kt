package com.blurr.voice.flutter

import android.content.Context
import android.util.Log
import com.blurr.voice.mcp.MCPServerManager
import com.blurr.voice.mcp.TransportType
import com.blurr.voice.mcp.TransportFactory
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/**
 * Central handler for all MCP MethodChannel calls from Flutter.
 * Acts as gateway between Flutter layer and Phase 1 MCPServerManager.
 */
class WorkflowEditorHandler(
    private val context: Context,
    private val mcpServerManager: MCPServerManager
) {
    companion object {
        private const val TAG = "WorkflowEditorHandler"
    }
    
    /**
     * Handler 1: Connect to MCP server
     * Called from Flutter: platformBridge.connectMCPServer(serverName, url, transport)
     */
    suspend fun connectMCPServer(
        serverName: String,
        url: String,
        transport: String  // "http", "sse", "stdio"
    ): Map<String, Any> {
        return try {
            Log.d(TAG, "Connecting to MCP server: $serverName (transport: $transport)")
            
            val result = mcpServerManager.connectServer(
                name = serverName,
                url = url,
                transport = TransportType.valueOf(transport.uppercase())
            )
            
            when {
                result.isSuccess -> {
                    val serverInfo = result.getOrNull()
                    mapOf(
                        "success" to true,
                        "message" to "Connected to $serverName",
                        "toolCount" to (serverInfo?.toolCount ?: 0)
                    )
                }
                else -> {
                    val error = result.exceptionOrNull()
                    mapOf(
                        "success" to false,
                        "message" to (error?.message ?: "Unknown error connecting to server")
                    )
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error connecting to MCP server", e)
            mapOf(
                "success" to false,
                "message" to (e.message ?: "Unknown error")
            )
        }
    }
    
    /**
     * Handler 2: Disconnect from MCP server
     * Called from Flutter: platformBridge.disconnectMCPServer(serverName)
     */
    suspend fun disconnectMCPServer(serverName: String): Map<String, Any> {
        return try {
            Log.d(TAG, "Disconnecting from MCP server: $serverName")
            
            mcpServerManager.disconnectServer(serverName)
            
            mapOf(
                "success" to true,
                "message" to "Disconnected from $serverName"
            )
        } catch (e: Exception) {
            Log.e(TAG, "Error disconnecting from MCP server", e)
            mapOf(
                "success" to false,
                "message" to (e.message ?: "Unknown error")
            )
        }
    }
    
    /**
     * Handler 3: Get all connected MCP servers
     * Called from Flutter: platformBridge.getMCPServersDetailed()
     */
    fun getMCPServers(): List<Map<String, Any>> {
        return try {
            Log.d(TAG, "Getting all MCP servers")
            
            mcpServerManager.getServers().map { server ->
                mapOf(
                    "name" to server.name,
                    "url" to server.url,
                    "transport" to server.transport.name.lowercase(),
                    "connected" to server.connected,
                    "toolCount" to (server.serverInfo?.toolCount ?: 0)
                )
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error getting MCP servers", e)
            emptyList()
        }
    }
    
    /**
     * Handler 4: Get MCP tools from server(s)
     * Called from Flutter: platformBridge.getMCPTools(serverName?)
     * If serverName is null, returns tools from all servers
     */
    fun getMCPTools(serverName: String? = null): List<Map<String, Any>> {
        return try {
            Log.d(TAG, "Getting MCP tools" + (serverName?.let { " from server: $it" } ?: " from all servers"))
            
            val servers = if (serverName != null) {
                val server = mcpServerManager.getServer(serverName)
                if (server != null) listOf(server) else emptyList()
            } else {
                mcpServerManager.getServers()
            }
            
            servers.flatMap { server ->
                server.tools.map { tool ->
                    mapOf(
                        "name" to tool.name,
                        "description" to (tool.description ?: ""),
                        "inputSchema" to (tool.inputSchema ?: emptyMap<String, Any>()),
                        "outputSchema" to emptyMap<String, Any>(), // Tool model doesn't seem to have outputSchema directly
                        "serverName" to server.name
                    )
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error getting MCP tools", e)
            emptyList()
        }
    }
    
    /**
     * Handler 5: Execute MCP tool
     * Called from Flutter: platformBridge.executeMCPTool(serverName, toolName, arguments)
     */
    suspend fun executeMCPTool(
        serverName: String,
        toolName: String,
        arguments: Map<String, Any>
    ): Map<String, Any> {
        return try {
            Log.d(TAG, "Executing tool: $serverName:$toolName")
            
            val result = mcpServerManager.executeTool(
                serverName = serverName,
                toolName = toolName,
                arguments = arguments
            )
            
            when {
                result.isSuccess -> {
                    mapOf(
                        "success" to true,
                        "result" to (result.getOrNull() ?: "")
                    )
                }
                else -> {
                    val error = result.exceptionOrNull()
                    mapOf(
                        "success" to false,
                        "error" to (error?.message ?: "Unknown error executing tool")
                    )
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error executing MCP tool", e)
            mapOf(
                "success" to false,
                "error" to (e.message ?: "Unknown error")
            )
        }
    }
    
    /**
     * Handler 6: Validate MCP connection before saving
     * Called from Flutter: platformBridge.validateMCPConnection(serverName, url, transport)
     * Does NOT save to preferences - temporary test only
     */
    suspend fun validateMCPConnection(
        serverName: String,
        url: String,
        transport: String
    ): Map<String, Any> {
        return try {
            Log.d(TAG, "Validating connection: $serverName at $url (transport: $transport)")
            
            // Create temporary transport and test connection
            val transportType = TransportType.valueOf(transport.uppercase())
            val tempTransport = TransportFactory.create(transportType, url, context)
            
            // Test connection (implementation depends on Phase 1 transport)
            val result = mcpServerManager.validateConnection(
                name = serverName,
                url = url,
                transport = transportType,
                tempTransport = tempTransport
            )
            
            when {
                result.isSuccess -> {
                    val serverInfo = result.getOrNull()
                    mapOf(
                        "success" to true,
                        "message" to "Connection valid",
                        "serverInfo" to mapOf(
                            "name" to (serverInfo?.name ?: serverName),
                            "version" to "1.0.0", // Hardcoded or extracted from serverInfo if available
                            "protocolVersion" to (serverInfo?.protocolVersion ?: "2024-11-05")
                        )
                    )
                }
                else -> {
                    val error = result.exceptionOrNull()
                    mapOf(
                        "success" to false,
                        "message" to (error?.message ?: "Connection validation failed")
                    )
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error validating MCP connection", e)
            mapOf(
                "success" to false,
                "message" to (e.message ?: "Unknown error")
            )
        }
    }
}

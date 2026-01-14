package com.blurr.voice.flutter

import android.content.Context
import android.util.Log
import com.blurr.voice.mcp.MCPServerManager
import com.blurr.voice.mcp.TransportType
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeoutOrNull
import kotlinx.coroutines.Dispatchers

/**
 * Central handler for all MCP MethodChannel calls from Flutter.
 * Acts as gateway between Flutter layer and Phase 1 MCPServerManager.
 *
 * This handler uses the official MCPServerManager built in Phase 1 and provides
 * a clean interface for Flutter to interact with MCP servers.
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

            val transportType = TransportType.fromString(transport)
            val result = mcpServerManager.connectServer(
                name = serverName,
                url = url,
                transport = transportType
            )

            when {
                result.isSuccess -> {
                    val serverInfo = result.getOrNull()
                    mapOf(
                        "success" to true,
                        "message" to "Connected to $serverName",
                        "toolCount" to (serverInfo?.toolCount ?: 0),
                        "serverInfo" to mapOf(
                            "name" to (serverInfo?.name ?: serverName),
                            "url" to (serverInfo?.url ?: url),
                            "version" to (serverInfo?.protocolVersion ?: "unknown")
                        )
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
                "message" to e.message.orEmpty()
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

            val result = mcpServerManager.disconnectServer(serverName)

            when {
                result.isSuccess -> {
                    mapOf(
                        "success" to true,
                        "message" to "Disconnected from $serverName"
                    )
                }
                else -> {
                    val error = result.exceptionOrNull()
                    mapOf(
                        "success" to false,
                        "message" to (error?.message ?: "Error disconnecting from server")
                    )
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error disconnecting from MCP server", e)
            mapOf(
                "success" to false,
                "message" to e.message.orEmpty()
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

            val tools = mcpServerManager.getTools(serverName)

            tools.map { tool ->
                mapOf(
                    "name" to tool.name,
                    "description" to tool.description,
                    "inputSchema" to (tool.inputSchema ?: emptyMap<String, Any>()),
                    "outputSchema" to emptyMap<String, Any>(),
                    "serverName" to tool.serverName
                )
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
                "error" to e.message.orEmpty()
            )
        }
    }

    /**
     * Handler 6: Validate MCP connection before saving
     * Called from Flutter: platformBridge.validateMCPConnection(serverName, url, transport)
     * Does NOT save to preferences - temporary test only
     *
     * Note: MCPServerManager doesn't have a validateConnection method, so we implement
     * it by creating a temporary connection and disconnecting immediately.
     *
     * This method has comprehensive error handling to prevent crashes:
     * - Multi-level try-catch blocks
     * - Timeout protection using withTimeoutOrNull
     * - Detailed logging at each step
     * - Always returns a valid response (never throws)
     */
    suspend fun validateMCPConnection(
        serverName: String,
        url: String,
        transport: String,
        timeout: Long? = 5000L
    ): Map<String, Any> {
        return withContext(Dispatchers.IO) {
            try {
                Log.d(TAG, "=== Starting MCP Connection Validation ===")
                Log.d(TAG, "Server: $serverName")
                Log.d(TAG, "URL: $url")
                Log.d(TAG, "Transport: $transport")
                Log.d(TAG, "Timeout: ${timeout}ms")

                // Validate input parameters
                if (url.isBlank()) {
                    Log.w(TAG, "Validation failed: URL is blank")
                    return@withContext mapOf(
                        "success" to false,
                        "message" to "Server URL cannot be empty"
                    )
                }

                if (serverName.isBlank()) {
                    Log.w(TAG, "Validation failed: Server name is blank")
                    return@withContext mapOf(
                        "success" to false,
                        "message" to "Server name cannot be empty"
                    )
                }

                // Parse transport type
                val transportType = try {
                    Log.d(TAG, "Parsing transport type: $transport")
                    TransportType.fromString(transport)
                } catch (e: Exception) {
                    Log.e(TAG, "Invalid transport type: $transport", e)
                    return@withContext mapOf(
                        "success" to false,
                        "message" to "Invalid transport type: $transport"
                    )
                }

                // Create temporary test connection with timeout
                val testServerName = "__test_${serverName}_${System.currentTimeMillis()}"
                Log.d(TAG, "Creating temporary test connection: $testServerName")

                val result = withTimeoutOrNull(timeout ?: 5000L) {
                    try {
                        Log.d(TAG, "Attempting to connect to server...")
                        mcpServerManager.connectServer(
                            name = testServerName,
                            url = url,
                            transport = transportType
                        )
                    } catch (e: Exception) {
                        Log.e(TAG, "Exception during connection attempt", e)
                        Result.failure<com.blurr.voice.mcp.MCPServerInfo>(e)
                    }
                }

                // Handle timeout
                if (result == null) {
                    Log.w(TAG, "Connection test timed out after ${timeout}ms")
                    return@withContext mapOf(
                        "success" to false,
                        "message" to "Connection timed out after ${timeout}ms"
                    )
                }

                // Process connection result
                return@withContext when {
                    result.isSuccess -> {
                        Log.d(TAG, "Connection successful!")
                        val serverInfo = result.getOrNull()
                        val toolCount = serverInfo?.toolCount ?: 0
                        Log.d(TAG, "Server info: ${serverInfo?.name}, tools: $toolCount")

                        // Disconnect test connection
                        try {
                            Log.d(TAG, "Disconnecting test connection...")
                            mcpServerManager.disconnectServer(testServerName)
                            Log.d(TAG, "Test connection closed successfully")
                        } catch (e: Exception) {
                            Log.w(TAG, "Failed to disconnect test connection (non-critical)", e)
                            // Non-critical - connection was successful
                        }

                        Log.d(TAG, "=== Validation Successful ===")
                        mapOf(
                            "success" to true,
                            "message" to "Connection valid",
                            "toolCount" to toolCount,
                            "serverInfo" to mapOf(
                                "name" to (serverInfo?.name ?: serverName),
                                "version" to (serverInfo?.protocolVersion ?: "unknown"),
                                "protocolVersion" to (serverInfo?.protocolVersion ?: "2024-11-05")
                            )
                        )
                    }
                    else -> {
                        val error = result.exceptionOrNull()
                        Log.e(TAG, "Connection failed", error)
                        Log.d(TAG, "=== Validation Failed ===")
                        mapOf(
                            "success" to false,
                            "message" to (error?.message ?: "Connection validation failed")
                        )
                    }
                }
            } catch (e: Exception) {
                // Catch-all for any unexpected exceptions
                Log.e(TAG, "Unexpected error in validateMCPConnection", e)
                Log.d(TAG, "=== Validation Error ===")
                mapOf(
                    "success" to false,
                    "message" to "Validation error: ${e.message ?: "Unknown error"}"
                )
            }
        }
    }
}

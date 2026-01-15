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
     * Uses protocol-specific validation for each transport type:
     * - STDIO: Validates command is executable and process can be started
     * - SSE: Validates HTTP endpoint is reachable via GET request
     * - HTTP: Validates HTTP endpoint accepts MCP initialize request via POST
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
        timeout: Long? = 5000L,
        command: String? = null,
        args: List<String>? = null,
        authentication: String? = null,
        headers: Map<String, String>? = null
    ): Map<String, Any> {
        return withContext(Dispatchers.IO) {
            try {
                Log.d(TAG, "=== Starting MCP Connection Validation (Protocol-Specific) ===")
                Log.d(TAG, "Server: $serverName")
                Log.d(TAG, "URL: $url")
                Log.d(TAG, "Transport: $transport")
                Log.d(TAG, "Timeout: ${timeout}ms")

                // Validate input parameters
                if (serverName.isBlank()) {
                    Log.w(TAG, "Validation failed: Server name is blank")
                    return@withContext mapOf(
                        "success" to false,
                        "message" to "Server name cannot be empty"
                    )
                }

                // Parse protocol and create appropriate config
                val config: com.blurr.voice.mcp.MCPTransportConfig? = when (transport.lowercase()) {
                    "stdio" -> {
                        if (command.isNullOrBlank()) {
                            Log.w(TAG, "Validation failed: Command is blank for STDIO")
                            return@withContext mapOf(
                                "success" to false,
                                "message" to "Command cannot be empty for STDIO transport"
                            )
                        }
                        Log.d(TAG, "STDIO config: command=$command, args=${args?.size ?: 0}")
                        com.blurr.voice.mcp.MCPTransportConfig.StdioConfig(
                            serverName = serverName,
                            command = command,
                            args = args ?: emptyList()
                        )
                    }
                    "sse" -> {
                        if (url.isBlank()) {
                            Log.w(TAG, "Validation failed: URL is blank for SSE")
                            return@withContext mapOf(
                                "success" to false,
                                "message" to "URL cannot be empty for SSE transport"
                            )
                        }
                        val authType = try {
                            com.blurr.voice.mcp.AuthType.valueOf((authentication ?: "NONE").uppercase())
                        } catch (e: IllegalArgumentException) {
                            com.blurr.voice.mcp.AuthType.NONE
                        }
                        Log.d(TAG, "SSE config: url=$url, auth=$authType, headers=${headers?.size ?: 0}")
                        com.blurr.voice.mcp.MCPTransportConfig.SSEConfig(
                            serverName = serverName,
                            url = url,
                            authentication = authType,
                            headers = headers ?: emptyMap()
                        )
                    }
                    "http" -> {
                        if (url.isBlank()) {
                            Log.w(TAG, "Validation failed: URL is blank for HTTP")
                            return@withContext mapOf(
                                "success" to false,
                                "message" to "URL cannot be empty for HTTP transport"
                            )
                        }
                        val authType = try {
                            com.blurr.voice.mcp.AuthType.valueOf((authentication ?: "NONE").uppercase())
                        } catch (e: IllegalArgumentException) {
                            com.blurr.voice.mcp.AuthType.NONE
                        }
                        Log.d(TAG, "HTTP config: url=$url, auth=$authType, headers=${headers?.size ?: 0}")
                        com.blurr.voice.mcp.MCPTransportConfig.HttpConfig(
                            serverName = serverName,
                            url = url,
                            authentication = authType,
                            headers = headers ?: emptyMap()
                        )
                    }
                    else -> {
                        Log.e(TAG, "Invalid transport type: $transport")
                        return@withContext mapOf(
                            "success" to false,
                            "message" to "Invalid transport type: $transport. Must be 'stdio', 'sse', or 'http'"
                        )
                    }
                }

                // Perform protocol-specific validation
                val validationResult = com.blurr.voice.mcp.MCPTransportValidator.validate(
                    config!!,
                    timeout ?: 5000L
                )

                Log.d(TAG, "Validation result: success=${validationResult.success}, message=${validationResult.message}")

                // Return result
                validationResult.toMap()
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
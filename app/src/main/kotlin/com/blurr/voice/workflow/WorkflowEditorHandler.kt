package com.blurr.voice.workflow

import android.content.Context
import com.blurr.voice.tools.UnifiedShellTool
import com.blurr.voice.integrations.ComposioClient
import com.blurr.voice.integrations.ComposioIntegrationManager
import com.blurr.voice.mcp.MCPClient
import com.blurr.voice.mcp.MCPTransport
import com.blurr.voice.mcp.HttpMCPTransport
import com.blurr.voice.mcp.SSEMCPTransport
import com.blurr.voice.mcp.StdioMCPTransport
import com.blurr.voice.mcp.MCPTransportConfig
import com.blurr.voice.data.MCPServerPreferences
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.json.JSONObject
import org.json.JSONArray
import java.io.File
import android.util.Log

/**
 * Handler for Flutter workflow editor platform channel
 * Bridges workflow execution to native Android functionality
 */
class WorkflowEditorHandler(
    private val context: Context,
    private val unifiedShellTool: UnifiedShellTool,
    private val composioClient: ComposioClient?,
    private val composioManager: ComposioIntegrationManager?,
    private val mcpClient: MCPClient?
) : MethodChannel.MethodCallHandler {

    private val scope = CoroutineScope(Dispatchers.Main)
    private val mcpPreferences = MCPServerPreferences(context)

    companion object {
        private const val TAG = "WorkflowEditorHandler"
        private const val WORKFLOWS_DIR = "workflows"
    }
    
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        scope.launch {
            try {
                when (call.method) {
                    "getPlatformVersion" -> {
                        result.success("Android ${android.os.Build.VERSION.RELEASE}")
                    }

                    "executeUnifiedShell" -> executeUnifiedShell(call, result)
                    "getComposioTools" -> getComposioTools(result)
                    "executeComposioAction" -> executeComposioAction(call, result)
                    "getMCPServers" -> getMCPServers(result)
                    "connectMCPServer" -> connectMCPServer(call, result)
                    "disconnectMCPServer" -> disconnectMCPServer(call, result)
                    "getMCPTools" -> getMCPTools(call, result)
                    "validateMCPConnection" -> validateMCPConnection(call, result)
                    "executeMCPTool" -> executeMCPTool(call, result)
                    "executeHttpRequest" -> executeHttpRequest(call, result)
                    "executePhoneControl" -> executePhoneControl(call, result)
                    "sendNotification" -> sendNotification(call, result)
                    "callAIAssistant" -> callAIAssistant(call, result)
                    "saveWorkflow" -> saveWorkflow(call, result)
                    "loadWorkflow" -> loadWorkflow(call, result)
                    "listWorkflows" -> listWorkflows(result)
                    "scheduleWorkflow" -> scheduleWorkflow(call, result)
                    "hasProSubscription" -> hasProSubscription(result)
                    "exportWorkflow" -> exportWorkflow(call, result)
                    "importWorkflow" -> importWorkflow(call, result)
                    "getWorkflowTemplates" -> getWorkflowTemplates(result)

                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error handling method ${call.method}", e)
                result.error("ERROR", e.message, e.stackTraceToString())
            }
        }
    }
    
    private suspend fun executeUnifiedShell(call: MethodCall, result: MethodChannel.Result) {
        withContext(Dispatchers.IO) {
            try {
                val code = call.argument<String>("code") ?: throw IllegalArgumentException("code required")
                val language = call.argument<String>("language") ?: "auto"
                val timeout = call.argument<Int>("timeout") ?: 30
                val inputs = call.argument<Map<String, Any>>("inputs") ?: emptyMap()
                
                val params = mapOf(
                    "code" to code,
                    "language" to language,
                    "timeout" to timeout,
                    "inputs" to inputs
                )
                
                val toolResult = unifiedShellTool.execute(params, emptyList())
                
                val response = mapOf(
                    "success" to toolResult.success,
                    "output" to toolResult.getDataAsString(),
                    "error" to toolResult.error
                )
                
                result.success(response)
            } catch (e: Exception) {
                Log.e(TAG, "Unified shell execution failed", e)
                result.error("SHELL_ERROR", e.message, null)
            }
        }
    }
    
    private suspend fun getComposioTools(result: MethodChannel.Result) {
        withContext(Dispatchers.IO) {
            try {
                if (composioManager == null) {
                    result.success(emptyList<Map<String, Any>>())
                    return@withContext
                }
                
                // Get popular integrations (or all available integrations)
                val integrationsResult = composioManager.getPopularIntegrations()
                
                if (integrationsResult.isFailure) {
                    result.success(emptyList<Map<String, Any>>())
                    return@withContext
                }
                
                val integrations = integrationsResult.getOrNull() ?: emptyList()
                
                val tools = integrations.map { integration ->
                    mapOf(
                        "id" to integration.key,
                        "name" to integration.name,
                        "description" to (integration.description ?: ""),
                        "connected" to false, // Check connected status separately
                        "actions" to emptyList<Map<String, Any>>() // Actions loaded separately if needed
                    )
                }
                
                result.success(tools)
            } catch (e: Exception) {
                Log.e(TAG, "Failed to get Composio tools", e)
                result.success(emptyList<Map<String, Any>>())
            }
        }
    }
    
    private suspend fun executeComposioAction(call: MethodCall, result: MethodChannel.Result) {
        withContext(Dispatchers.IO) {
            try {
                val toolId = call.argument<String>("toolId") ?: throw IllegalArgumentException("toolId required")
                val actionId = call.argument<String>("actionId") ?: throw IllegalArgumentException("actionId required")
                val parameters = call.argument<Map<String, Any>>("parameters") ?: emptyMap()
                
                if (composioManager == null) {
                    result.error("COMPOSIO_ERROR", "Composio manager not available", null)
                    return@withContext
                }
                
                val actionResult = composioManager.executeAction(toolId, actionId, parameters)
                
                if (actionResult.isSuccess) {
                    result.success(mapOf(
                        "success" to true,
                        "result" to actionResult.getOrNull()
                    ))
                } else {
                    result.error(
                        "COMPOSIO_ERROR",
                        actionResult.exceptionOrNull()?.message,
                        null
                    )
                }
            } catch (e: Exception) {
                Log.e(TAG, "Composio action execution failed", e)
                result.error("COMPOSIO_ERROR", e.message, null)
            }
        }
    }
    
    private suspend fun getMCPServers(result: MethodChannel.Result) {
        withContext(Dispatchers.IO) {
            try {
                if (mcpClient == null) {
                    result.success(emptyList<Map<String, Any>>())
                    return@withContext
                }
                
                val serversInfo = mcpClient.getAllServerInfo()
                
                val serversData = serversInfo.map { serverInfo ->
                    mapOf(
                        "id" to serverInfo.name,
                        "name" to serverInfo.serverName,
                        "description" to "MCP Server v${serverInfo.serverVersion}",
                        "connected" to serverInfo.isConnected,
                        "status" to "active",
                        "tools" to emptyList<Map<String, Any>>() // Tools are accessed separately
                    )
                }
                
                result.success(serversData)
            } catch (e: Exception) {
                Log.e(TAG, "Failed to get MCP servers", e)
                result.success(emptyList<Map<String, Any>>())
            }
        }
    }

    private suspend fun connectMCPServer(call: MethodCall, result: MethodChannel.Result) {
        withContext(Dispatchers.IO) {
            try {
                val serverName = call.argument<String>("serverName") ?: throw IllegalArgumentException("serverName required")
                val url = call.argument<String>("url") ?: throw IllegalArgumentException("url required")
                val transport = call.argument<String>("transport") ?: "http"

                if (mcpClient == null) {
                    result.error("MCP_ERROR", "MCP client not available", null)
                    return@withContext
                }

                // Create transport based on type
                val mcpTransport: MCPTransport = when (transport.lowercase()) {
                    "http" -> {
                        val config = MCPTransportConfig.Http(
                            url = url,
                            timeoutMs = 30000
                        )
                        HttpMCPTransport(config)
                    }
                    "sse" -> {
                        val config = MCPTransportConfig.Http(
                            url = url,
                            timeoutMs = 30000
                        )
                        SSEMCPTransport(config)
                    }
                    "stdio" -> {
                        val config = MCPTransportConfig.Stdio(
                            command = url,
                            args = emptyList()
                        )
                        StdioMCPTransport(config)
                    }
                    else -> throw IllegalArgumentException("Unknown transport type: $transport")
                }

                // Connect to MCP server
                val connectResult = mcpClient.connect(serverName, mcpTransport)

                if (connectResult.isFailure) {
                    val error = connectResult.exceptionOrNull()
                    result.error("MCP_ERROR", error?.message ?: "Connection failed", null)
                    return@withContext
                }

                // Save server configuration
                val serverConfig = MCPServerPreferences.MCPServerConfig(
                    name = serverName,
                    url = url,
                    transport = transport,
                    enabled = true,
                    lastConnected = System.currentTimeMillis()
                )
                mcpPreferences.saveServer(serverConfig)

                // Get tool count
                val serverInfo = mcpClient.getServerInfo(serverName)
                val toolCount = serverInfo?.toolCount ?: 0

                result.success(mapOf(
                    "success" to true,
                    "message" to "Connected successfully",
                    "toolCount" to toolCount,
                    "serverInfo" to mapOf(
                        "name" to serverName,
                        "version" to serverInfo?.serverVersion,
                        "protocolVersion" to serverInfo?.protocolVersion
                    )
                ))

                Log.d(TAG, "Connected to MCP server: $serverName with $toolCount tools")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to connect MCP server", e)
                result.error("MCP_ERROR", e.message, null)
            }
        }
    }

    private suspend fun disconnectMCPServer(call: MethodCall, result: MethodChannel.Result) {
        withContext(Dispatchers.IO) {
            try {
                val serverName = call.argument<String>("serverName") ?: throw IllegalArgumentException("serverName required")

                if (mcpClient == null) {
                    result.error("MCP_ERROR", "MCP client not available", null)
                    return@withContext
                }

                // Disconnect from MCP server
                mcpClient.disconnect(serverName)

                // Remove from preferences
                mcpPreferences.removeServer(serverName)

                result.success(mapOf(
                    "success" to true,
                    "message" to "Disconnected successfully"
                ))

                Log.d(TAG, "Disconnected from MCP server: $serverName")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to disconnect MCP server", e)
                result.error("MCP_ERROR", e.message, null)
            }
        }
    }

    private suspend fun getMCPTools(call: MethodCall, result: MethodChannel.Result) {
        withContext(Dispatchers.IO) {
            try {
                val serverName = call.argument<String>("serverName")

                if (mcpClient == null) {
                    result.error("MCP_ERROR", "MCP client not available", null)
                    return@withContext
                }

                val tools = if (serverName != null) {
                    // Get tools from specific server
                    val serverTools = mcpClient.getAllToolsRaw()
                        .filter { it is com.blurr.voice.mcp.MCPToolAdapter }
                        .map { it as com.blurr.voice.mcp.MCPToolAdapter }
                        .filter { it.mcpServer.server.name == serverName }
                    serverTools.map { toolAdapter ->
                        mapOf(
                            "name" to toolAdapter.mcpTool.name,
                            "description" to (toolAdapter.mcpTool.description ?: ""),
                            "inputSchema" to toolAdapter.mcpTool.inputSchema,
                            "outputSchema" to (toolAdapter.mcpTool.outputSchema ?: emptyMap<String, Any>())
                        )
                    }
                } else {
                    // Get all tools
                    val allTools = mcpClient.getAllToolsRaw()
                        .filter { it is com.blurr.voice.mcp.MCPToolAdapter }
                        .map { it as com.blurr.voice.mcp.MCPToolAdapter }
                    allTools.map { toolAdapter ->
                        mapOf(
                            "name" to toolAdapter.mcpTool.name,
                            "description" to (toolAdapter.mcpTool.description ?: ""),
                            "inputSchema" to toolAdapter.mcpTool.inputSchema,
                            "outputSchema" to (toolAdapter.mcpTool.outputSchema ?: emptyMap<String, Any>())
                        )
                    }
                }

                result.success(tools)
            } catch (e: Exception) {
                Log.e(TAG, "Failed to get MCP tools", e)
                result.success(emptyList<Map<String, Any>>())
            }
        }
    }

    private suspend fun validateMCPConnection(call: MethodCall, result: MethodChannel.Result) {
        withContext(Dispatchers.IO) {
            try {
                val serverName = call.argument<String>("serverName") ?: throw IllegalArgumentException("serverName required")
                val url = call.argument<String>("url") ?: throw IllegalArgumentException("url required")
                val transport = call.argument<String>("transport") ?: "http"

                // Create test transport
                val mcpTransport: MCPTransport = when (transport.lowercase()) {
                    "http" -> {
                        val config = MCPTransportConfig.Http(
                            url = url,
                            timeoutMs = 30000
                        )
                        HttpMCPTransport(config)
                    }
                    "sse" -> {
                        val config = MCPTransportConfig.Http(
                            url = url,
                            timeoutMs = 30000
                        )
                        SSEMCPTransport(config)
                    }
                    "stdio" -> {
                        val config = MCPTransportConfig.Stdio(
                            command = url,
                            args = emptyList()
                        )
                        StdioMCPTransport(config)
                    }
                    else -> throw IllegalArgumentException("Unknown transport type: $transport")
                }

                if (mcpClient == null) {
                    result.error("MCP_ERROR", "MCP client not available", null)
                    return@withContext
                }

                // Test connection with temporary name
                val testName = "__test_${System.currentTimeMillis()}"
                val connectResult = mcpClient.connect(testName, mcpTransport)

                if (connectResult.isFailure) {
                    val error = connectResult.exceptionOrNull()
                    result.error("MCP_ERROR", error?.message ?: "Connection failed", null)
                    return@withContext
                }

                // Get server info
                val serverInfo = mcpClient.getServerInfo(testName)
                val toolCount = serverInfo?.toolCount ?: 0

                // Disconnect test connection
                mcpClient.disconnect(testName)

                result.success(mapOf(
                    "success" to true,
                    "message" to "Connection validated",
                    "serverInfo" to mapOf(
                        "name" to serverName,
                        "version" to serverInfo?.serverVersion,
                        "protocolVersion" to serverInfo?.protocolVersion
                    ),
                    "toolCount" to toolCount
                ))

                Log.d(TAG, "Validated MCP connection: $serverName")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to validate MCP connection", e)
                result.error("MCP_ERROR", e.message, null)
            }
        }
    }
    
    private suspend fun executeMCPTool(call: MethodCall, result: MethodChannel.Result) {
        withContext(Dispatchers.IO) {
            try {
                val serverName = call.argument<String>("serverName") ?: throw IllegalArgumentException("serverName required")
                val toolName = call.argument<String>("toolName") ?: throw IllegalArgumentException("toolName required")
                val arguments = call.argument<Map<String, Any>>("arguments") ?: emptyMap()

                if (mcpClient == null) {
                    result.error("MCP_ERROR", "MCP client not available", null)
                    return@withContext
                }

                // Get the tool and execute it
                val fullToolName = "$serverName:$toolName"
                val tool = mcpClient.getTool(fullToolName)

                if (tool == null) {
                    result.error("MCP_ERROR", "Tool not found: $fullToolName", null)
                    return@withContext
                }

                val toolResult = tool.execute(arguments, emptyList())

                result.success(mapOf(
                    "success" to toolResult.success,
                    "result" to (toolResult.data ?: toolResult.getDataAsString()),
                    "error" to toolResult.error
                ))
            } catch (e: Exception) {
                Log.e(TAG, "MCP tool execution failed", e)
                result.error("MCP_ERROR", e.message, null)
            }
        }
    }
    
    private suspend fun executeHttpRequest(call: MethodCall, result: MethodChannel.Result) {
        withContext(Dispatchers.IO) {
            try {
                val url = call.argument<String>("url") ?: throw IllegalArgumentException("url required")
                val method = call.argument<String>("method") ?: "GET"
                val headers = call.argument<Map<String, String>>("headers") ?: emptyMap()
                val body = call.argument<Any>("body")
                
                // Use OkHttp or similar for HTTP requests
                // Placeholder implementation
                result.success(mapOf(
                    "statusCode" to 200,
                    "body" to "HTTP request placeholder",
                    "headers" to emptyMap<String, String>()
                ))
            } catch (e: Exception) {
                Log.e(TAG, "HTTP request failed", e)
                result.error("HTTP_ERROR", e.message, null)
            }
        }
    }
    
    private fun executePhoneControl(call: MethodCall, result: MethodChannel.Result) {
        // Placeholder for phone control actions
        result.success(mapOf("success" to true))
    }
    
    private fun sendNotification(call: MethodCall, result: MethodChannel.Result) {
        // Placeholder for notification sending
        result.success(null)
    }
    
    private fun callAIAssistant(call: MethodCall, result: MethodChannel.Result) {
        // Placeholder for AI assistant integration
        result.success(mapOf("response" to "AI assistant placeholder"))
    }
    
    private suspend fun saveWorkflow(call: MethodCall, result: MethodChannel.Result) {
        withContext(Dispatchers.IO) {
            try {
                val workflowId = call.argument<String>("workflowId") ?: throw IllegalArgumentException("workflowId required")
                val workflowData = call.argument<String>("workflowData") ?: throw IllegalArgumentException("workflowData required")
                
                val workflowsDir = File(context.filesDir, WORKFLOWS_DIR)
                if (!workflowsDir.exists()) {
                    workflowsDir.mkdirs()
                }
                
                val workflowFile = File(workflowsDir, "$workflowId.json")
                workflowFile.writeText(workflowData)
                
                result.success(null)
            } catch (e: Exception) {
                Log.e(TAG, "Failed to save workflow", e)
                result.error("SAVE_ERROR", e.message, null)
            }
        }
    }
    
    private suspend fun loadWorkflow(call: MethodCall, result: MethodChannel.Result) {
        withContext(Dispatchers.IO) {
            try {
                val workflowId = call.argument<String>("workflowId") ?: throw IllegalArgumentException("workflowId required")
                
                val workflowFile = File(File(context.filesDir, WORKFLOWS_DIR), "$workflowId.json")
                
                if (!workflowFile.exists()) {
                    result.success(null)
                    return@withContext
                }
                
                val workflowData = workflowFile.readText()
                result.success(workflowData)
            } catch (e: Exception) {
                Log.e(TAG, "Failed to load workflow", e)
                result.error("LOAD_ERROR", e.message, null)
            }
        }
    }
    
    private suspend fun listWorkflows(result: MethodChannel.Result) {
        withContext(Dispatchers.IO) {
            try {
                val workflowsDir = File(context.filesDir, WORKFLOWS_DIR)
                if (!workflowsDir.exists()) {
                    result.success(emptyList<Map<String, Any>>())
                    return@withContext
                }
                
                val workflows = workflowsDir.listFiles()?.filter { it.extension == "json" }?.map { file ->
                    val data = JSONObject(file.readText())
                    mapOf(
                        "id" to data.getString("id"),
                        "name" to data.getString("name"),
                        "description" to data.optString("description", ""),
                        "updatedAt" to data.optString("updatedAt", "")
                    )
                } ?: emptyList()
                
                result.success(workflows)
            } catch (e: Exception) {
                Log.e(TAG, "Failed to list workflows", e)
                result.success(emptyList<Map<String, Any>>())
            }
        }
    }
    
    private fun scheduleWorkflow(call: MethodCall, result: MethodChannel.Result) {
        // Placeholder for workflow scheduling
        result.success(null)
    }
    
    private fun hasProSubscription(result: MethodChannel.Result) {
        // Check Pro subscription status
        // Placeholder - integrate with actual subscription check
        result.success(false)
    }
    
    private fun exportWorkflow(call: MethodCall, result: MethodChannel.Result) {
        // Placeholder for workflow export
        result.success("")
    }
    
    private fun importWorkflow(call: MethodCall, result: MethodChannel.Result) {
        // Placeholder for workflow import
        result.success("")
    }
    
    private fun getWorkflowTemplates(result: MethodChannel.Result) {
        // Return predefined workflow templates
        val templates = listOf(
            mapOf(
                "id" to "template_daily_summary",
                "name" to "Daily Summary",
                "description" to "Generate a daily summary report",
                "category" to "productivity"
            ),
            mapOf(
                "id" to "template_data_processing",
                "name" to "Data Processing",
                "description" to "Process and transform data",
                "category" to "data"
            )
        )
        
        result.success(templates)
    }
}

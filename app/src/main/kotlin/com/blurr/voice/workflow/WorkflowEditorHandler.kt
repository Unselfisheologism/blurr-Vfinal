package com.blurr.voice.workflow

import android.content.Context
import com.blurr.voice.tools.UnifiedShellTool
import com.blurr.voice.integrations.ComposioClient
import com.blurr.voice.integrations.ComposioIntegrationManager
import com.blurr.voice.mcp.MCPClient
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
                
                val toolResult = unifiedShellTool.execute(params)
                
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
    
    private suspend fun executeMCPTool(call: MethodCall, result: MethodChannel.Result) {
        withContext(Dispatchers.IO) {
            try {
                val serverId = call.argument<String>("serverId") ?: throw IllegalArgumentException("serverId required")
                val toolId = call.argument<String>("toolId") ?: throw IllegalArgumentException("toolId required")
                val parameters = call.argument<Map<String, Any>>("parameters") ?: emptyMap()
                
                if (mcpClient == null) {
                    result.error("MCP_ERROR", "MCP client not available", null)
                    return@withContext
                }
                
                // Get the tool and execute it
                val toolName = "$serverId:$toolId"
                val tool = mcpClient.getTool(toolName)
                
                if (tool == null) {
                    result.error("MCP_ERROR", "Tool not found: $toolName", null)
                    return@withContext
                }
                
                val toolResult = tool.execute(parameters, emptyList())
                
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

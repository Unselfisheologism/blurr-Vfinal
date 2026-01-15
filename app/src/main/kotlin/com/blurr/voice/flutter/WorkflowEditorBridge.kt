// Kotlin bridge for Flutter workflow editor with Google Workspace integration
package com.blurr.voice.flutter

import android.content.Context
import android.content.Intent
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import com.blurr.voice.utilities.FreemiumManager
import com.blurr.voice.integrations.ComposioIntegrationManager
import com.blurr.voice.auth.GoogleAuthManager
import com.blurr.voice.ui.GoogleSignInActivity
import com.blurr.voice.tools.ToolResult
import com.blurr.voice.data.WorkflowPreferences
import com.google.gson.Gson
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/**
 * Complete Kotlin bridge for Flutter workflow editor
 * Supports: Composio, MCP, and Google Workspace integrations
 */
class WorkflowEditorBridge(
    private val context: Context,
    private val flutterEngine: FlutterEngine
) {
    companion object {
        private const val CHANNEL_NAME = "workflow_editor"
        private const val TAG = "WorkflowEditorBridge"
    }

    private val methodChannel = MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        CHANNEL_NAME
    )
    
    private val gson = Gson()
    private val scope = CoroutineScope(Dispatchers.Main)
    private val freemiumManager = FreemiumManager()
    private val googleAuthManager = GoogleAuthManager(context)
    private val workflowPrefs = WorkflowPreferences(context)

    init {
        setupMethodCallHandler()
    }

    private fun setupMethodCallHandler() {
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                // Platform info
                "getPlatformVersion" -> handleGetPlatformVersion(result)
                
                // Pro status
                "getProStatus" -> handleGetProStatus(result)
                "hasProSubscription" -> handleHasProSubscription(result)
                
                // Composio integration
                "getComposioTools" -> handleGetComposioTools(result)
                "executeComposioAction" -> handleExecuteComposioAction(call, result)
                
                // MCP integration
                "getMcpServers" -> handleGetMcpServers(result)
                "executeMcpRequest" -> handleExecuteMcpRequest(call, result)
                "connectMCPServer" -> handleConnectMCPServer(call, result)
                "disconnectMCPServer" -> handleDisconnectMCPServer(call, result)
                "getMCPServers" -> handleGetMCPServersDetailed(result)
                "getMCPTools" -> handleGetMCPTools(call, result)
                "executeMCPTool" -> handleExecuteMCPTool(call, result)
                "validateMCPConnection" -> handleValidateMCPConnection(call, result)
                
                // Google Workspace integration
                "getGoogleAuthStatus" -> handleGetGoogleAuthStatus(result)
                "authenticateGoogle" -> handleAuthenticateGoogle(result)
                "executeGoogleWorkspaceAction" -> handleExecuteGoogleWorkspaceAction(call, result)
                
                // System-level tool methods
                "getSystemTools" -> handleGetSystemTools(result)
                "executeSystemTool" -> handleExecuteSystemTool(call, result)
                "checkAccessibilityStatus" -> handleCheckAccessibilityStatus(result)
                "checkNotificationListenerStatus" -> handleCheckNotificationListenerStatus(result)
                "requestAccessibilityPermission" -> handleRequestAccessibilityPermission(result)
                "requestNotificationListenerPermission" -> handleRequestNotificationListenerPermission(result)
                
                // Legacy methods (from old handler)
                "executeUnifiedShell" -> handleExecuteUnifiedShell(call, result)
                "executeHttpRequest" -> handleExecuteHttpRequest(call, result)
                "executePhoneControl" -> handleExecutePhoneControl(call, result)
                "sendNotification" -> handleSendNotification(call, result)
                "callAIAssistant" -> handleCallAIAssistant(call, result)
                
                // Workflow storage
                "saveWorkflow" -> handleSaveWorkflow(call, result)
                "loadWorkflow" -> handleLoadWorkflow(call, result)
                "getWorkflows" -> handleGetWorkflows(result)
                "listWorkflows" -> handleListWorkflows(result)
                "scheduleWorkflow" -> handleScheduleWorkflow(call, result)
                "exportWorkflow" -> handleExportWorkflow(call, result)
                "importWorkflow" -> handleImportWorkflow(call, result)
                "getWorkflowTemplates" -> handleGetWorkflowTemplates(result)
                
                // UI
                "showProUpgradeDialog" -> handleShowProUpgradeDialog(call, result)
                
                else -> result.notImplemented()
            }
        }
    }

    // ==================== Platform Info ====================
    
    private fun handleGetPlatformVersion(result: MethodChannel.Result) {
        scope.launch {
            try {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            } catch (e: Exception) {
                result.error("ERROR", e.message, null)
            }
        }
    }

    // ==================== Pro Status ====================
    
    private fun handleGetProStatus(result: MethodChannel.Result) {
        scope.launch {
            try {
                val isPro = withContext(Dispatchers.IO) {
                    freemiumManager.hasComposioAccess()
                }
                result.success(isPro)
            } catch (e: Exception) {
                result.error("PRO_STATUS_ERROR", e.message, null)
            }
        }
    }

    private fun handleHasProSubscription(result: MethodChannel.Result) {
        scope.launch {
            try {
                val isPro = withContext(Dispatchers.IO) {
                    freemiumManager.hasComposioAccess()
                }
                result.success(isPro)
            } catch (e: Exception) {
                result.error("PRO_STATUS_ERROR", e.message, null)
            }
        }
    }

    // ==================== Composio Integration ====================
    
    private fun handleGetComposioTools(result: MethodChannel.Result) {
        scope.launch {
            try {
                val manager = ComposioIntegrationManager(context)
                
                val tools = withContext(Dispatchers.IO) {
                    val toolsResult = manager.listAvailableIntegrations()
                    if (toolsResult.isSuccess) {
                        toolsResult.getOrNull() ?: emptyList()
                    } else {
                        emptyList()
                    }
                }

                val toolsList = tools.map { tool ->
                    mapOf(
                        "id" to tool.key,
                        "name" to tool.name,
                        "appKey" to tool.key,
                        "description" to (tool.description ?: ""),
                        "icon" to (tool.logo ?: ""),
                        "connected" to true,
                        "actions" to emptyList<Any>()
                    )
                }

                result.success(toolsList)
            } catch (e: Exception) {
                result.error("COMPOSIO_ERROR", e.message, null)
            }
        }
    }

    private fun handleExecuteComposioAction(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        val toolId = call.argument<String>("toolId")
        val actionName = call.argument<String>("actionName")
        val parameters = call.argument<Map<String, Any>>("parameters")

        if (toolId == null || actionName == null || parameters == null) {
            result.error("INVALID_ARGS", "Missing required parameters", null)
            return
        }

        scope.launch {
            try {
                val manager = ComposioIntegrationManager(context)
                
                val actionResult = withContext(Dispatchers.IO) {
                    manager.executeAction(
                        integrationKey = toolId,
                        actionName = actionName,
                        parameters = parameters,
                        userId = "current_user"
                    )
                }

                if (actionResult.isSuccess) {
                    val payload = actionResult.getOrNull()
                    result.success(
                        mapOf(
                            "success" to (payload?.success ?: false),
                            "data" to payload?.data,
                            "error" to payload?.error
                        )
                    )
                } else {
                    result.error(
                        "COMPOSIO_ACTION_ERROR",
                        actionResult.exceptionOrNull()?.message,
                        null
                    )
                }
            } catch (e: Exception) {
                result.error("COMPOSIO_ACTION_ERROR", e.message, null)
            }
        }
    }

    // ==================== MCP Integration ====================
    
    private fun handleGetMcpServers(result: MethodChannel.Result) {
        scope.launch {
            try {
                // TODO: Implement MCP server listing
                // Get from your MCP client implementation
                result.success(emptyList<Map<String, Any>>())
            } catch (e: Exception) {
                result.error("MCP_ERROR", e.message, null)
            }
        }
    }

    private fun handleExecuteMcpRequest(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        // TODO: Implement MCP request execution
        result.success(mapOf("success" to true))
    }

    // ==================== MCP Server Management ====================

    private fun handleConnectMCPServer(call: MethodCall, result: MethodChannel.Result) {
        val serverName = call.argument<String>("serverName")
            ?: return result.error("INVALID_ARGS", "Missing serverName", null)
        val url = call.argument<String>("url")
            ?: return result.error("INVALID_ARGS", "Missing url", null)
        val transport = call.argument<String>("transport")
            ?: return result.error("INVALID_ARGS", "Missing transport", null)

        scope.launch {
            try {
                val mcpManager = com.blurr.voice.mcp.MCPServerManager(context)
                val transportType = com.blurr.voice.mcp.TransportType.fromString(transport)
                val connectResult = mcpManager.connectServer(
                    name = serverName,
                    url = url,
                    transport = transportType
                )

                when {
                    connectResult.isSuccess -> {
                        val serverInfo = connectResult.getOrNull()
                        result.success(mapOf(
                            "success" to true,
                            "message" to "Connected to $serverName",
                            "toolCount" to (serverInfo?.toolCount ?: 0),
                            "serverInfo" to mapOf(
                                "name" to (serverInfo?.name ?: serverName),
                                "url" to (serverInfo?.url ?: url),
                                "version" to (serverInfo?.protocolVersion ?: "unknown")
                            )
                        ))
                    }
                    else -> {
                        val error = connectResult.exceptionOrNull()
                        result.success(mapOf(
                            "success" to false,
                            "message" to (error?.message ?: "Unknown error connecting to server")
                        ))
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error connecting MCP server", e)
                result.success(mapOf(
                    "success" to false,
                    "message" to e.message.orEmpty()
                ))
            }
        }
    }

    private fun handleDisconnectMCPServer(call: MethodCall, result: MethodChannel.Result) {
        val serverName = call.argument<String>("serverName")
            ?: return result.error("INVALID_ARGS", "Missing serverName", null)

        scope.launch {
            try {
                val mcpManager = com.blurr.voice.mcp.MCPServerManager(context)
                val disconnectResult = mcpManager.disconnectServer(serverName)

                when {
                    disconnectResult.isSuccess -> {
                        result.success(mapOf(
                            "success" to true,
                            "message" to "Disconnected from $serverName"
                        ))
                    }
                    else -> {
                        val error = disconnectResult.exceptionOrNull()
                        result.success(mapOf(
                            "success" to false,
                            "message" to (error?.message ?: "Error disconnecting from server")
                        ))
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error disconnecting MCP server", e)
                result.success(mapOf(
                    "success" to false,
                    "message" to e.message.orEmpty()
                ))
            }
        }
    }

    private fun handleGetMCPServersDetailed(result: MethodChannel.Result) {
        scope.launch {
            try {
                val mcpManager = com.blurr.voice.mcp.MCPServerManager(context)
                val servers = mcpManager.getServers().map { server ->
                    mapOf(
                        "name" to server.name,
                        "url" to server.url,
                        "transport" to server.transport.name.lowercase(),
                        "connected" to server.connected,
                        "toolCount" to (server.serverInfo?.toolCount ?: 0)
                    )
                }
                result.success(servers)
            } catch (e: Exception) {
                Log.e(TAG, "Error getting MCP servers", e)
                result.success(emptyList<Map<String, Any>>())
            }
        }
    }

    private fun handleGetMCPTools(call: MethodCall, result: MethodChannel.Result) {
        val serverName = call.argument<String>("serverName")

        scope.launch {
            try {
                val mcpManager = com.blurr.voice.mcp.MCPServerManager(context)
                val tools = mcpManager.getTools(serverName).map { tool ->
                    mapOf(
                        "name" to tool.name,
                        "description" to tool.description,
                        "inputSchema" to (tool.inputSchema ?: emptyMap<String, Any>()),
                        "outputSchema" to emptyMap<String, Any>(),
                        "serverName" to tool.serverName
                    )
                }
                result.success(tools)
            } catch (e: Exception) {
                Log.e(TAG, "Error getting MCP tools", e)
                result.success(emptyList<Map<String, Any>>())
            }
        }
    }

    private fun handleExecuteMCPTool(call: MethodCall, result: MethodChannel.Result) {
        val serverName = call.argument<String>("serverName")
        if (serverName == null) {
            result.error("INVALID_ARGS", "Missing serverName", null)
            return
        }
        val toolName = call.argument<String>("toolName")
        if (toolName == null) {
            result.error("INVALID_ARGS", "Missing toolName", null)
            return
        }
        val arguments = call.argument<Map<String, Any>>("arguments") ?: emptyMap()

        scope.launch {
            try {
                val mcpManager = com.blurr.voice.mcp.MCPServerManager(context)
                val executeResult = mcpManager.executeTool(
                    serverName = serverName,
                    toolName = toolName,
                    arguments = arguments
                )

                when {
                    executeResult.isSuccess -> {
                        result.success(mapOf(
                            "success" to true,
                            "result" to (executeResult.getOrNull() ?: "")
                        ))
                    }
                    else -> {
                        val error = executeResult.exceptionOrNull()
                        result.success(mapOf(
                            "success" to false,
                            "error" to (error?.message ?: "Unknown error executing tool")
                        ))
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error executing MCP tool", e)
                result.success(mapOf(
                    "success" to false,
                    "error" to e.message.orEmpty()
                ))
            }
        }
    }

    private fun handleValidateMCPConnection(call: MethodCall, result: MethodChannel.Result) {
        // Parse protocol first - this determines what parameters we need
        val protocol = call.argument<String>("protocol")
        if (protocol == null) {
            // Fallback to old 'transport' parameter for backward compatibility
            result.error("INVALID_ARGS", "Missing protocol parameter", null)
            return
        }

        val serverName = call.argument<String>("serverName")
        if (serverName == null) {
            result.error("INVALID_ARGS", "Missing serverName", null)
            return
        }

        val timeout = call.argument<Long>("timeout") ?: 5000L

        scope.launch {
            try {
                Log.d(TAG, "=== Validating MCP Connection (Protocol-Specific) ===")
                Log.d(TAG, "Protocol: $protocol")
                Log.d(TAG, "Server: $serverName")
                Log.d(TAG, "Timeout: ${timeout}ms")

                // Parse protocol-specific configuration
                val config = when (protocol.lowercase()) {
                    "stdio" -> {
                        val command = call.argument<String>("command")
                        val args = call.argument<List<String>>("args")

                        if (command == null) {
                            Log.w(TAG, "STDIO validation failed: Missing command")
                            result.success(mapOf(
                                "success" to false,
                                "message" to "Command is required for STDIO transport"
                            ))
                            return@launch
                        }

                        Log.d(TAG, "STDIO config: command=$command, args=${args?.size ?: 0}")

                        com.blurr.voice.mcp.MCPTransportConfig.StdioConfig(
                            serverName = serverName,
                            command = command,
                            args = args ?: emptyList()
                        )
                    }

                    "sse" -> {
                        val url = call.argument<String>("url")
                        if (url == null) {
                            Log.w(TAG, "SSE validation failed: Missing url")
                            result.success(mapOf(
                                "success" to false,
                                "message" to "URL is required for SSE transport"
                            ))
                            return@launch
                        }

                        val authType = call.argument<String>("authentication") ?: "NONE"
                        val headers = call.argument<Map<String, String>>("headers") ?: emptyMap()

                        Log.d(TAG, "SSE config: url=$url, auth=$authType, headers=${headers.size}")

                        com.blurr.voice.mcp.MCPTransportConfig.SSEConfig(
                            serverName = serverName,
                            url = url,
                            authentication = com.blurr.voice.mcp.AuthType.valueOf(authType.uppercase()),
                            headers = headers
                        )
                    }

                    "http" -> {
                        val url = call.argument<String>("url")
                        if (url == null) {
                            Log.w(TAG, "HTTP validation failed: Missing url")
                            result.success(mapOf(
                                "success" to false,
                                "message" to "URL is required for HTTP transport"
                            ))
                            return@launch
                        }

                        val authType = call.argument<String>("authentication") ?: "NONE"
                        val headers = call.argument<Map<String, String>>("headers") ?: emptyMap()

                        Log.d(TAG, "HTTP config: url=$url, auth=$authType, headers=${headers.size}")

                        com.blurr.voice.mcp.MCPTransportConfig.HttpConfig(
                            serverName = serverName,
                            url = url,
                            authentication = com.blurr.voice.mcp.AuthType.valueOf(authType.uppercase()),
                            headers = headers
                        )
                    }

                    else -> {
                        Log.w(TAG, "Unknown protocol: $protocol")
                        result.success(mapOf(
                            "success" to false,
                            "message" to "Unknown protocol: $protocol. Must be 'stdio', 'sse', or 'http'"
                        ))
                        return@launch
                    }
                }

                // Perform protocol-specific validation
                val validationResult = com.blurr.voice.mcp.MCPTransportValidator.validate(config, timeout)

                Log.d(TAG, "Validation result: success=${validationResult.success}, message=${validationResult.message}")

                // Return result to Flutter
                result.success(validationResult.toMap())
            } catch (e: Exception) {
                Log.e(TAG, "Unexpected error in validateMCPConnection", e)
                result.success(mapOf(
                    "success" to false,
                    "message" to "Validation error: ${e.message ?: "Unknown error"}"
                ))
            }
        }
    }

    // ==================== Google Workspace Integration ====================
    
    private fun handleGetGoogleAuthStatus(result: MethodChannel.Result) {
        scope.launch {
            try {
                val isSignedIn = withContext(Dispatchers.IO) {
                    googleAuthManager.isSignedIn()
                }
                result.success(isSignedIn)
            } catch (e: Exception) {
                result.error("GOOGLE_AUTH_ERROR", e.message, null)
            }
        }
    }

    private fun handleAuthenticateGoogle(result: MethodChannel.Result) {
        scope.launch {
            try {
                // Launch GoogleSignInActivity
                val intent = Intent(context, GoogleSignInActivity::class.java)
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                context.startActivity(intent)
                
                // Return success - actual auth happens in GoogleSignInActivity
                result.success(true)
            } catch (e: Exception) {
                result.error("GOOGLE_AUTH_ERROR", e.message, null)
            }
        }
    }

    private fun handleExecuteGoogleWorkspaceAction(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        val service = call.argument<String>("service")
        val actionName = call.argument<String>("actionName")
        val parameters = call.argument<Map<String, Any>>("parameters")

        if (service == null || actionName == null || parameters == null) {
            result.error("INVALID_ARGS", "Missing required parameters", null)
            return
        }

        scope.launch {
            try {
                // Check authentication first
                val isSignedIn = withContext(Dispatchers.IO) {
                    googleAuthManager.isSignedIn()
                }

                if (!isSignedIn) {
                    result.error(
                        "NOT_AUTHENTICATED",
                        "Please sign in to Google to use Google Workspace tools",
                        null
                    )
                    return@launch
                }

                // Execute the action based on service
                val actionResult = withContext(Dispatchers.IO) {
                    when (service) {
                        "gmail" -> executeGmailAction(actionName as String, parameters as Map<String, Any>)
                        "calendar" -> executeCalendarAction(actionName as String, parameters as Map<String, Any>)
                        "drive" -> executeDriveAction(actionName as String, parameters as Map<String, Any>)
                        else -> throw Exception("Unknown service: $service")
                    }
                }

                result.success(actionResult)
            } catch (e: Exception) {
                if (e.message?.contains("NOT_AUTHENTICATED") == true) {
                    result.error("NOT_AUTHENTICATED", e.message, null)
                } else {
                    result.error("GOOGLE_WORKSPACE_ERROR", e.message, null)
                }
            }
        }
    }

    private suspend fun executeGmailAction(
        actionName: String,
        parameters: Map<String, Any>
    ): Map<String, Any> {
        // Use the existing GmailTool from Story 4.15
        val gmailTool = com.blurr.voice.tools.google.GmailTool(context, googleAuthManager)
        
        val toolParams = mapOf(
            "action" to actionName,
            "to" to (parameters["to"] ?: ""),
            "subject" to (parameters["subject"] ?: ""),
            "body" to (parameters["body"] ?: ""),
            "cc" to (parameters["cc"] ?: ""),
            "bcc" to (parameters["bcc"] ?: ""),
            "max_results" to (parameters["max_results"] ?: 10),
            "query" to (parameters["query"] ?: "")
        )

        val toolResult = gmailTool.execute(toolParams, emptyList())
        
        return if (toolResult.success) {
            (toolResult.data as? Map<String, Any>) ?: emptyMap<String, Any>()
        } else {
            throw Exception(toolResult.error ?: "Gmail action failed")
        }
    }

    private suspend fun executeCalendarAction(
        actionName: String,
        parameters: Map<String, Any>
    ): Map<String, Any> {
        // Use the existing GoogleCalendarTool from Story 4.16
        val calendarTool = com.blurr.voice.tools.google.GoogleCalendarTool(context, googleAuthManager)
        
        val toolParams = mapOf(
            "action" to actionName,
            "summary" to (parameters["summary"] ?: ""),
            "start_time" to (parameters["start_time"] ?: ""),
            "end_time" to (parameters["end_time"] ?: ""),
            "description" to (parameters["description"] ?: ""),
            "location" to (parameters["location"] ?: ""),
            "attendees" to (parameters["attendees"] ?: ""),
            "max_results" to (parameters["max_results"] ?: 10)
        )

        val toolResult = calendarTool.execute(toolParams, emptyList())
        
        return if (toolResult.success) {
            (toolResult.data as? Map<String, Any>) ?: emptyMap<String, Any>()
        } else {
            throw Exception(toolResult.error ?: "Calendar action failed")
        }
    }

    private suspend fun executeDriveAction(
        actionName: String,
        parameters: Map<String, Any>
    ): Map<String, Any> {
        // Use the existing GoogleDriveTool from Story 4.16
        val driveTool = com.blurr.voice.tools.google.GoogleDriveTool(context, googleAuthManager)
        
        val toolParams = mapOf(
            "action" to actionName,
            "file_path" to (parameters["file_path"] ?: ""),
            "name" to (parameters["name"] ?: ""),
            "folder_id" to (parameters["folder_id"] ?: ""),
            "max_results" to (parameters["max_results"] ?: 10),
            "query" to (parameters["query"] ?: ""),
            "file_id" to (parameters["file_id"] ?: ""),
            "email" to (parameters["email"] ?: ""),
            "role" to (parameters["role"] ?: "reader")
        )

        val toolResult = driveTool.execute(toolParams, emptyList())
        
        return if (toolResult.success) {
            (toolResult.data as? Map<String, Any>) ?: emptyMap<String, Any>()
        } else {
            throw Exception(toolResult.error ?: "Drive action failed")
        }
    }

    // ==================== Workflow Storage ====================
    
    private fun handleSaveWorkflow(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        val workflow = call.argument<Map<String, Any>>("workflow")
        if (workflow == null) {
            result.error("INVALID_ARGS", "Missing workflow data", null)
            return
        }

        scope.launch {
            try {
                val workflowId = workflow["id"] as? String ?: ""
                val json = gson.toJson(workflow)
                
                withContext(Dispatchers.IO) {
                    workflowPrefs.saveWorkflow(workflowId, json)
                }

                result.success(true)
            } catch (e: Exception) {
                result.error("SAVE_ERROR", e.message, null)
            }
        }
    }

    private fun handleLoadWorkflow(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        val workflowId = call.argument<String>("workflowId")
        if (workflowId == null) {
            result.error("INVALID_ARGS", "Missing workflow ID", null)
            return
        }

        scope.launch {
            try {
                val json = withContext(Dispatchers.IO) {
                    workflowPrefs.getWorkflow(workflowId)
                }

                if (json != null) {
                    val workflow = gson.fromJson(json, Map::class.java)
                    result.success(workflow)
                } else {
                    result.success(null)
                }
            } catch (e: Exception) {
                result.error("LOAD_ERROR", e.message, null)
            }
        }
    }

    private fun handleGetWorkflows(result: MethodChannel.Result) {
        scope.launch {
            try {
                val workflows = withContext(Dispatchers.IO) {
                    workflowPrefs.getAllWorkflows().values.mapNotNull { jsonStr ->
                        try {
                            gson.fromJson(jsonStr, Map::class.java)
                        } catch (e: Exception) {
                            null
                        }
                    }
                }
                result.success(workflows)
            } catch (e: Exception) {
                result.error("GET_WORKFLOWS_ERROR", e.message, null)
            }
        }
    }

    // ==================== UI ====================
    
    private fun handleShowProUpgradeDialog(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        // Navigate to ProPurchaseActivity
        // val intent = Intent(context, ProPurchaseActivity::class.java)
        // intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        // context.startActivity(intent)
        
        result.success(true)
    }

    // ==================== System-Level Tools ====================
    
    private fun handleGetSystemTools(result: MethodChannel.Result) {
        scope.launch {
            try {
                val tools = listOf(
                    mapOf("id" to "ui_tap", "name" to "Tap Element", "category" to "uiAutomation"),
                    mapOf("id" to "ui_type", "name" to "Type Text", "category" to "uiAutomation"),
                    mapOf("id" to "ui_swipe", "name" to "Swipe", "category" to "uiAutomation"),
                    mapOf("id" to "ui_scroll", "name" to "Scroll", "category" to "uiAutomation"),
                    mapOf("id" to "ui_back", "name" to "Press Back", "category" to "uiAutomation"),
                    mapOf("id" to "ui_home", "name" to "Press Home", "category" to "uiAutomation"),
                    mapOf("id" to "ui_open_notifications", "name" to "Open Notifications", "category" to "uiAutomation"),
                    mapOf("id" to "ui_open_app", "name" to "Open App", "category" to "uiAutomation"),
                    mapOf("id" to "ui_get_hierarchy", "name" to "Get Screen Hierarchy", "category" to "uiAutomation"),
                    mapOf("id" to "ui_screenshot", "name" to "Take Screenshot", "category" to "uiAutomation"),
                    mapOf("id" to "notif_get_all", "name" to "Get All Notifications", "category" to "notification"),
                    mapOf("id" to "notif_get_by_app", "name" to "Get Notifications by App", "category" to "notification"),
                    mapOf("id" to "system_get_activity", "name" to "Get Current Activity", "category" to "systemControl"),
                    mapOf("id" to "system_open_settings", "name" to "Open Settings", "category" to "systemControl")
                )
                result.success(tools)
            } catch (e: Exception) {
                result.error("GET_SYSTEM_TOOLS_ERROR", e.message, null)
            }
        }
    }

    private fun handleExecuteSystemTool(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        val toolId = call.argument<String>("toolId")
        val parameters = call.argument<Map<String, Any>>("parameters") ?: emptyMap()

        if (toolId == null) {
            result.error("INVALID_ARGS", "Missing toolId", null)
            return
        }

        scope.launch {
            try {
                val phoneControlTool = com.blurr.voice.tools.PhoneControlTool(context)
                
                val toolResult = withContext(Dispatchers.IO) {
                    when (toolId) {
                        "ui_tap" -> {
                            val params = mutableMapOf<String, Any>("action" to "tap")
                            parameters["text"]?.let { params["text"] = it }
                            parameters["resourceId"]?.let { params["resource_id"] = it }
                            parameters["x"]?.let { params["x"] = it }
                            parameters["y"]?.let { params["y"] = it }
                            phoneControlTool.execute(params, emptyList())
                        }
                        "ui_type" -> phoneControlTool.execute(mapOf("action" to "type", "text" to (parameters["text"] ?: "")), emptyList())
                        "ui_swipe" -> phoneControlTool.execute(mapOf("action" to "swipe", "direction" to (parameters["direction"] ?: "down")), emptyList())
                        "ui_scroll" -> phoneControlTool.execute(mapOf("action" to "scroll", "direction" to (parameters["direction"] ?: "down")), emptyList())
                        "ui_back" -> phoneControlTool.execute(mapOf("action" to "press_back"), emptyList())
                        "ui_home" -> phoneControlTool.execute(mapOf("action" to "press_home"), emptyList())
                        "ui_open_notifications" -> phoneControlTool.execute(mapOf("action" to "open_notifications"), emptyList())
                        "ui_open_app" -> phoneControlTool.execute(mapOf("action" to "open_app", "package_name" to (parameters["packageName"] ?: "")), emptyList())
                        "ui_get_hierarchy" -> phoneControlTool.execute(mapOf("action" to "get_screen_hierarchy", "format" to (parameters["format"] ?: "xml")), emptyList())
                        "ui_screenshot" -> phoneControlTool.execute(mapOf("action" to "screenshot"), emptyList())
                        "system_get_activity" -> phoneControlTool.execute(mapOf("action" to "get_current_activity"), emptyList())
                        "system_open_settings" -> {
                            val settingsPage = parameters["settingsPage"] as? String
                            val intent = when (settingsPage) {
                                "wifi" -> Intent(android.provider.Settings.ACTION_WIFI_SETTINGS)
                                "bluetooth" -> Intent(android.provider.Settings.ACTION_BLUETOOTH_SETTINGS)
                                "accessibility" -> Intent(android.provider.Settings.ACTION_ACCESSIBILITY_SETTINGS)
                                else -> Intent(android.provider.Settings.ACTION_SETTINGS)
                            }.apply { flags = Intent.FLAG_ACTIVITY_NEW_TASK }
                            context.startActivity(intent)
                            ToolResult(toolName = "system", success = true, data = "Settings opened")
                        }
                        "notif_get_all", "notif_get_by_app" -> {
                            val enabled = com.blurr.voice.triggers.PermissionUtils.isNotificationListenerEnabled(context)
                            if (!enabled) {
                                ToolResult(toolName = "notification", success = false, error = "Notification Listener not enabled")
                            } else {
                                ToolResult(toolName = "notification", success = true, data = mapOf("message" to "Notification access enabled"))
                            }
                        }
                        else -> ToolResult(toolName = "system", success = false, error = "Unknown tool: $toolId")
                    }
                }
                
                result.success(mapOf(
                    "success" to toolResult.success,
                    "data" to (toolResult.data ?: ""),
                    "error" to (toolResult.error ?: "")
                ))
            } catch (e: Exception) {
                result.error("SYSTEM_TOOL_ERROR", e.message, null)
            }
        }
    }

    private fun handleCheckAccessibilityStatus(result: MethodChannel.Result) {
        try {
            val service = com.blurr.voice.ScreenInteractionService.instance
            result.success(service != null)
        } catch (e: Exception) {
            result.error("ACCESSIBILITY_CHECK_ERROR", e.message, null)
        }
    }

    private fun handleCheckNotificationListenerStatus(result: MethodChannel.Result) {
        try {
            val isEnabled = com.blurr.voice.triggers.PermissionUtils.isNotificationListenerEnabled(context)
            result.success(isEnabled)
        } catch (e: Exception) {
            result.error("NOTIFICATION_CHECK_ERROR", e.message, null)
        }
    }

    private fun handleRequestAccessibilityPermission(result: MethodChannel.Result) {
        try {
            val intent = Intent(android.provider.Settings.ACTION_ACCESSIBILITY_SETTINGS).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
            result.success(true)
        } catch (e: Exception) {
            result.error("ACCESSIBILITY_REQUEST_ERROR", e.message, null)
        }
    }

    private fun handleRequestNotificationListenerPermission(result: MethodChannel.Result) {
        try {
            val intent = Intent(android.provider.Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
            result.success(true)
        } catch (e: Exception) {
            result.error("NOTIFICATION_REQUEST_ERROR", e.message, null)
        }
    }

    // ==================== Legacy Methods ====================

    private fun handleExecuteUnifiedShell(call: MethodCall, result: MethodChannel.Result) {
        scope.launch {
            try {
                val code = call.argument<String>("code")
                if (code == null) {
                    result.error("INVALID_ARGS", "code required", null)
                    return@launch
                }
                val language = call.argument<String>("language") ?: "auto"
                val timeout = call.argument<Int>("timeout") ?: 30
                val inputs = call.argument<Map<String, Any>>("inputs") ?: emptyMap()
                
                val unifiedShellTool = com.blurr.voice.tools.UnifiedShellTool(context)
                val toolResult = withContext(Dispatchers.IO) {
                    val params = mapOf(
                        "code" to code,
                        "language" to language,
                        "timeout" to timeout,
                        "inputs" to inputs
                    )
                    unifiedShellTool.execute(params, emptyList())
                }
                
                val response = mapOf(
                    "success" to toolResult.success,
                    "output" to toolResult.getDataAsString(),
                    "error" to toolResult.error
                )
                result.success(response)
            } catch (e: Exception) {
                result.error("SHELL_ERROR", e.message, null)
            }
        }
    }

    private fun handleExecuteHttpRequest(call: MethodCall, result: MethodChannel.Result) {
        scope.launch {
            try {
                result.success(mapOf("success" to true))
            } catch (e: Exception) {
                result.error("HTTP_ERROR", e.message, null)
            }
        }
    }

    private fun handleExecutePhoneControl(call: MethodCall, result: MethodChannel.Result) {
        val action = call.argument<String>("action")
        if (action == null) {
            result.error("INVALID_ARGS", "action required", null)
            return
        }
        val parameters = call.argument<Map<String, Any>>("parameters") ?: emptyMap()

        scope.launch {
            try {
                val phoneControlTool = com.blurr.voice.tools.PhoneControlTool(context)
                val toolResult = withContext(Dispatchers.IO) {
                    val params = mutableMapOf<String, Any>("action" to action)
                    parameters.forEach { (k, v) -> params[k] = v }
                    phoneControlTool.execute(params, emptyList())
                }
                result.success(mapOf(
                    "success" to toolResult.success,
                    "data" to toolResult.data,
                    "error" to toolResult.error
                ))
            } catch (e: Exception) {
                result.error("PHONE_CONTROL_ERROR", e.message, null)
            }
        }
    }

    private fun handleSendNotification(call: MethodCall, result: MethodChannel.Result) {
        scope.launch {
            try {
                val title = call.argument<String>("title") ?: ""
                val message = call.argument<String>("message") ?: ""
                val channelId = call.argument<String>("channelId") ?: "workflow_notifications"
                
                // TODO: Implement actual notification sending
                result.success(true)
            } catch (e: Exception) {
                result.error("NOTIFICATION_ERROR", e.message, null)
            }
        }
    }

    private fun handleCallAIAssistant(call: MethodCall, result: MethodChannel.Result) {
        scope.launch {
            try {
                result.success(mapOf("success" to true))
            } catch (e: Exception) {
                result.error("AI_ASSISTANT_ERROR", e.message, null)
            }
        }
    }

    private fun handleListWorkflows(result: MethodChannel.Result) {
        // Alias for getWorkflows
        handleGetWorkflows(result)
    }

    private fun handleScheduleWorkflow(call: MethodCall, result: MethodChannel.Result) {
        scope.launch {
            try {
                result.success(true)
            } catch (e: Exception) {
                result.error("SCHEDULE_ERROR", e.message, null)
            }
        }
    }

    private fun handleExportWorkflow(call: MethodCall, result: MethodChannel.Result) {
        scope.launch {
            try {
                val workflowId = call.argument<String>("workflowId") ?: return@launch result.error("INVALID_ARGS", "workflowId required", null)
                val json = withContext(Dispatchers.IO) {
                    workflowPrefs.getWorkflow(workflowId)
                }
                result.success(json ?: "")
            } catch (e: Exception) {
                result.error("EXPORT_ERROR", e.message, null)
            }
        }
    }

    private fun handleImportWorkflow(call: MethodCall, result: MethodChannel.Result) {
        scope.launch {
            try {
                val workflowJson = call.argument<String>("workflowJson") ?: return@launch result.error("INVALID_ARGS", "workflowJson required", null)
                val workflow = gson.fromJson(workflowJson, Map::class.java)
                val workflowId = workflow["id"] as? String ?: "imported_${System.currentTimeMillis()}"
                
                withContext(Dispatchers.IO) {
                    workflowPrefs.saveWorkflow(workflowId, workflowJson)
                }
                result.success(workflowId)
            } catch (e: Exception) {
                result.error("IMPORT_ERROR", e.message, null)
            }
        }
    }

    private fun handleGetWorkflowTemplates(result: MethodChannel.Result) {
        scope.launch {
            try {
                result.success(emptyList<Map<String, Any>>())
            } catch (e: Exception) {
                result.error("TEMPLATES_ERROR", e.message, null)
            }
        }
    }

    /**
     * Load workflow from JSON and optionally execute it
     * Called from WorkflowEditorActivity when launched by AI agent
     */
    fun loadWorkflow(workflowJson: String, autoExecute: Boolean) {
        scope.launch {
            try {
                // Parse JSON to map
                val workflow = gson.fromJson(workflowJson, Map::class.java)
                
                // Send to Flutter via method channel
                methodChannel.invokeMethod(
                    "loadWorkflowFromNative",
                    mapOf(
                        "workflow" to workflow,
                        "autoExecute" to autoExecute
                    )
                )
            } catch (e: Exception) {
                Log.e(TAG, "Error loading workflow from native", e)
            }
        }
    }

    fun dispose() {
        methodChannel.setMethodCallHandler(null)
    }
}

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
import com.blurr.voice.activities.GoogleSignInActivity
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
        private const val CHANNEL_NAME = "com.blurr.workflow_editor"
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
                // Pro status
                "getProStatus" -> handleGetProStatus(result)
                
                // Composio integration
                "getComposioTools" -> handleGetComposioTools(result)
                "executeComposioAction" -> handleExecuteComposioAction(call, result)
                
                // MCP integration
                "getMcpServers" -> handleGetMcpServers(result)
                "executeMcpRequest" -> handleExecuteMcpRequest(call, result)
                
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
                
                // Workflow storage
                "saveWorkflow" -> handleSaveWorkflow(call, result)
                "loadWorkflow" -> handleLoadWorkflow(call, result)
                "getWorkflows" -> handleGetWorkflows(result)
                
                // UI
                "showProUpgradeDialog" -> handleShowProUpgradeDialog(call, result)
                
                else -> result.notImplemented()
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
                        integration = toolId,
                        actionName = actionName,
                        params = parameters,
                        userId = "current_user"
                    )
                }

                if (actionResult.isSuccess) {
                    result.success(actionResult.getOrNull() ?: emptyMap<String, Any>())
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

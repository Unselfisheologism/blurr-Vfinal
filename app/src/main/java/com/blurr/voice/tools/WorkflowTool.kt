package com.blurr.voice.tools

import android.content.Context
import android.content.Intent
import android.util.Log
import com.blurr.voice.data.WorkflowPreferences
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject

/**
 * Workflow Tool - Enables AI agent to create, manage, and execute n8n-style workflows
 * 
 * This tool provides the AI agent with full programmatic control over the workflow editor,
 * allowing it to:
 * - Create workflows with any combination of tools (Composio, Google Workspace, MCP, System Tools)
 * - Schedule workflows (daily, weekly, custom cron)
 * - Execute workflows immediately
 * - List, update, and delete workflows
 * - Query workflow execution status
 * 
 * Example usage:
 * User: "Create a workflow that checks my Gmail every morning at 8 AM and summarizes it to Notion"
 * Agent: Uses workflow_create to build a scheduled workflow with Gmail and Composio (Notion) tools
 */
class WorkflowTool(private val context: Context) : BaseTool() {
    
    companion object {
        private const val TAG = "WorkflowTool"
    }
    
    private val workflowPrefs by lazy { WorkflowPreferences(context) }
    
    override val name: String = "workflow"
    
    override val description: String = """
        Create, manage, and execute n8n-style automation workflows.
        
        Workflows can include:
        - Google Workspace tools (Gmail, Calendar, Drive) - FREE for all users
        - Composio integrations (2000+ apps: Notion, Slack, GitHub, etc.) - PRO only
        - MCP servers (custom integrations)
        - System tools (UI automation, notifications, phone control)
        - AI/LLM processing
        - Code execution (JavaScript/Python)
        - Conditional logic, loops, variables
        
        Common workflow patterns:
        1. Scheduled tasks (check email, sync data, send reports)
        2. Event-driven automation (new notification → action)
        3. Data processing pipelines (fetch → transform → save)
        4. Multi-step research and content generation
        5. Phone automation sequences
        
        Actions supported:
        - create: Create a new workflow from specification
        - list: List all saved workflows
        - get: Get details of a specific workflow
        - execute: Run a workflow immediately
        - update: Modify an existing workflow
        - delete: Remove a workflow
        - status: Check execution status of a workflow
    """.trimIndent()
    
    override val parameters: List<ToolParameter> = listOf(
        ToolParameter(
            name = "action",
            type = "string",
            description = "Action to perform: create, list, get, execute, update, delete, status",
            required = true,
            enum = listOf("create", "list", "get", "execute", "update", "delete", "status")
        ),
        ToolParameter(
            name = "workflow_name",
            type = "string",
            description = "Name of the workflow (required for create, get, execute, update, delete)",
            required = false
        ),
        ToolParameter(
            name = "workflow_spec",
            type = "object",
            description = """
                Workflow specification as JSON object with structure:
                {
                  "name": "Workflow name",
                  "description": "What this workflow does",
                  "trigger": {
                    "type": "manual|schedule|webhook",
                    "schedule": "0 8 * * *"  // Optional: cron expression for schedule trigger
                  },
                  "nodes": [
                    {
                      "id": "node_1",
                      "type": "googleWorkspaceAction|composioAction|systemToolAction|code|condition|etc",
                      "name": "Node display name",
                      "parameters": {
                        // Node-specific parameters
                      }
                    }
                  ],
                  "connections": [
                    {
                      "from": "node_1",
                      "to": "node_2"
                    }
                  ],
                  "variables": {}  // Optional: workflow-level variables
                }
            """.trimIndent(),
            required = false
        ),
        ToolParameter(
            name = "workflow_id",
            type = "string",
            description = "ID of the workflow (for get, execute, update, delete, status)",
            required = false
        )
    )
    
    override suspend fun execute(
        params: Map<String, Any>,
        context: List<ToolResult>
    ): ToolResult = withContext(Dispatchers.IO) {
        try {
            val validation = validateParameters(params)
            if (validation.isFailure) {
                return@withContext ToolResult(
                    toolName = name,
                    success = false,
                    error = validation.exceptionOrNull()?.message
                )
            }
            
            val action = getRequiredParam<String>(params, "action")
            
            when (action) {
                "create" -> createWorkflow(params)
                "list" -> listWorkflows()
                "get" -> getWorkflow(params)
                "execute" -> executeWorkflow(params)
                "update" -> updateWorkflow(params)
                "delete" -> deleteWorkflow(params)
                "status" -> getWorkflowStatus(params)
                else -> ToolResult(
                    toolName = name,
                    success = false,
                    error = "Unknown action: $action"
                )
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error executing workflow tool", e)
            ToolResult(
                toolName = name,
                success = false,
                error = "Workflow operation failed: ${e.message}"
            )
        }
    }
    
    /**
     * Create a new workflow from specification
     */
    private fun createWorkflow(params: Map<String, Any>): ToolResult {
        try {
            val workflowName = getRequiredParam<String>(params, "workflow_name")
            val workflowSpec = getRequiredParam<Map<String, Any>>(params, "workflow_spec")
            
            // Convert spec to JSON
            val workflowJson = JSONObject(workflowSpec)
            
            // Validate workflow structure
            val validation = validateWorkflowSpec(workflowJson)
            if (!validation.first) {
                return ToolResult(
                    toolName = name,
                    success = false,
                    error = "Invalid workflow specification: ${validation.second}"
                )
            }
            
            // Generate unique ID
            val workflowId = generateWorkflowId(workflowName)
            workflowJson.put("id", workflowId)
            workflowJson.put("name", workflowName)
            workflowJson.put("created_at", System.currentTimeMillis())
            workflowJson.put("updated_at", System.currentTimeMillis())
            
            // Save workflow
            workflowPrefs.saveWorkflow(workflowId, workflowJson.toString())
            
            Log.i(TAG, "Created workflow: $workflowName (ID: $workflowId)")
            
            return ToolResult(
                toolName = name,
                success = true,
                data = mapOf(
                    "message" to "Workflow created successfully",
                    "workflow_id" to workflowId,
                    "workflow_name" to workflowName,
                    "nodes_count" to workflowJson.optJSONArray("nodes")?.length(),
                    "trigger_type" to workflowJson.optJSONObject("trigger")?.optString("type")
                )
            )
        } catch (e: Exception) {
            Log.e(TAG, "Error creating workflow", e)
            return ToolResult(
                toolName = name,
                success = false,
                error = "Failed to create workflow: ${e.message}"
            )
        }
    }
    
    /**
     * List all saved workflows
     */
    private fun listWorkflows(): ToolResult {
        try {
            val workflows = workflowPrefs.getAllWorkflows()
            
            val workflowList = workflows.map { (id, jsonStr) ->
                try {
                    val json = JSONObject(jsonStr)
                    mapOf(
                        "id" to id,
                        "name" to json.optString("name", "Untitled"),
                        "description" to json.optString("description", ""),
                        "trigger_type" to json.optJSONObject("trigger")?.optString("type"),
                        "nodes_count" to json.optJSONArray("nodes")?.length(),
                        "created_at" to json.optLong("created_at"),
                        "updated_at" to json.optLong("updated_at")
                    )
                } catch (e: Exception) {
                    null
                }
            }.filterNotNull()
            
            return ToolResult(
                toolName = name,
                success = true,
                data = mapOf(
                    "workflows" to workflowList,
                    "count" to workflowList.size
                )
            )
        } catch (e: Exception) {
            Log.e(TAG, "Error listing workflows", e)
            return ToolResult(
                toolName = name,
                success = false,
                error = "Failed to list workflows: ${e.message}"
            )
        }
    }
    
    /**
     * Get details of a specific workflow
     */
    private fun getWorkflow(params: Map<String, Any>): ToolResult {
        try {
            val workflowId = params["workflow_id"] as? String
                ?: params["workflow_name"] as? String
                ?: return ToolResult(
                    toolName = name,
                    success = false,
                    error = "workflow_id or workflow_name is required"
                )
            
            // Try to find by ID first, then by name
            val workflow = if (workflowId.startsWith("wf_")) {
                workflowPrefs.getWorkflow(workflowId)
            } else {
                findWorkflowByName(workflowId)
            }
            
            if (workflow == null) {
                return ToolResult(
                    toolName = name,
                    success = false,
                    error = "Workflow not found: $workflowId"
                )
            }
            
            val json = JSONObject(workflow)
            
            return ToolResult(
                toolName = name,
                success = true,
                data = mapOf(
                    "id" to json.optString("id"),
                    "name" to json.optString("name"),
                    "description" to json.optString("description"),
                    "trigger" to json.optJSONObject("trigger")?.let { jsonObjectToMap(it) },
                    "nodes" to json.optJSONArray("nodes")?.let { jsonArrayToList(it) },
                    "connections" to json.optJSONArray("connections")?.let { jsonArrayToList(it) },
                    "variables" to json.optJSONObject("variables")?.let { jsonObjectToMap(it) },
                    "created_at" to json.optLong("created_at"),
                    "updated_at" to json.optLong("updated_at")
                )
            )
        } catch (e: Exception) {
            Log.e(TAG, "Error getting workflow", e)
            return ToolResult(
                toolName = name,
                success = false,
                error = "Failed to get workflow: ${e.message}"
            )
        }
    }
    
    /**
     * Execute a workflow immediately
     */
    private suspend fun executeWorkflow(params: Map<String, Any>): ToolResult {
        try {
            val workflowId = params["workflow_id"] as? String
                ?: params["workflow_name"] as? String
                ?: return ToolResult(
                    toolName = name,
                    success = false,
                    error = "workflow_id or workflow_name is required"
                )
            
            // Find workflow
            val workflowJson = if (workflowId.startsWith("wf_")) {
                workflowPrefs.getWorkflow(workflowId)
            } else {
                findWorkflowByName(workflowId)
            }
            
            if (workflowJson == null) {
                return ToolResult(
                    toolName = name,
                    success = false,
                    error = "Workflow not found: $workflowId"
                )
            }
            
            // Launch workflow editor activity with execute flag
            val intent = Intent(context, com.blurr.voice.WorkflowEditorActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
                putExtra("workflow_json", workflowJson)
                putExtra("auto_execute", true)
            }
            
            withContext(Dispatchers.Main) {
                context.startActivity(intent)
            }
            
            Log.i(TAG, "Executed workflow: $workflowId")
            
            return ToolResult(
                toolName = name,
                success = true,
                data = mapOf(
                    "message" to "Workflow execution started",
                    "workflow_id" to workflowId,
                    "status" to "running"
                )
            )
        } catch (e: Exception) {
            Log.e(TAG, "Error executing workflow", e)
            return ToolResult(
                toolName = name,
                success = false,
                error = "Failed to execute workflow: ${e.message}"
            )
        }
    }
    
    /**
     * Update an existing workflow
     */
    private fun updateWorkflow(params: Map<String, Any>): ToolResult {
        try {
            val workflowId = params["workflow_id"] as? String
                ?: params["workflow_name"] as? String
                ?: return ToolResult(
                    toolName = name,
                    success = false,
                    error = "workflow_id or workflow_name is required"
                )
            
            val workflowSpec = getRequiredParam<Map<String, Any>>(params, "workflow_spec")
            
            // Find existing workflow
            val existingJson = if (workflowId.startsWith("wf_")) {
                workflowPrefs.getWorkflow(workflowId)
            } else {
                findWorkflowByName(workflowId)
            }
            
            if (existingJson == null) {
                return ToolResult(
                    toolName = name,
                    success = false,
                    error = "Workflow not found: $workflowId"
                )
            }
            
            val existing = JSONObject(existingJson)
            val actualWorkflowId = existing.optString("id")
            
            // Merge with new spec
            val updatedSpec = JSONObject(workflowSpec)
            updatedSpec.put("id", actualWorkflowId)
            updatedSpec.put("created_at", existing.optLong("created_at"))
            updatedSpec.put("updated_at", System.currentTimeMillis())
            
            // Validate
            val validation = validateWorkflowSpec(updatedSpec)
            if (!validation.first) {
                return ToolResult(
                    toolName = name,
                    success = false,
                    error = "Invalid workflow specification: ${validation.second}"
                )
            }
            
            // Save
            workflowPrefs.saveWorkflow(actualWorkflowId, updatedSpec.toString())
            
            Log.i(TAG, "Updated workflow: $actualWorkflowId")
            
            return ToolResult(
                toolName = name,
                success = true,
                data = mapOf(
                    "message" to "Workflow updated successfully",
                    "workflow_id" to actualWorkflowId
                )
            )
        } catch (e: Exception) {
            Log.e(TAG, "Error updating workflow", e)
            return ToolResult(
                toolName = name,
                success = false,
                error = "Failed to update workflow: ${e.message}"
            )
        }
    }
    
    /**
     * Delete a workflow
     */
    private fun deleteWorkflow(params: Map<String, Any>): ToolResult {
        try {
            val workflowId = params["workflow_id"] as? String
                ?: params["workflow_name"] as? String
                ?: return ToolResult(
                    toolName = name,
                    success = false,
                    error = "workflow_id or workflow_name is required"
                )
            
            // Find workflow
            val actualWorkflowId = if (workflowId.startsWith("wf_")) {
                workflowId
            } else {
                val workflow = findWorkflowByName(workflowId)
                if (workflow != null) {
                    JSONObject(workflow).optString("id")
                } else {
                    return ToolResult(
                        toolName = name,
                        success = false,
                        error = "Workflow not found: $workflowId"
                    )
                }
            }
            
            workflowPrefs.deleteWorkflow(actualWorkflowId)
            
            Log.i(TAG, "Deleted workflow: $actualWorkflowId")
            
            return ToolResult(
                toolName = name,
                success = true,
                data = mapOf(
                    "message" to "Workflow deleted successfully",
                    "workflow_id" to actualWorkflowId
                )
            )
        } catch (e: Exception) {
            Log.e(TAG, "Error deleting workflow", e)
            return ToolResult(
                toolName = name,
                success = false,
                error = "Failed to delete workflow: ${e.message}"
            )
        }
    }
    
    /**
     * Get workflow execution status
     */
    private fun getWorkflowStatus(params: Map<String, Any>): ToolResult {
        // TODO: Implement execution status tracking
        // For now, return placeholder
        return ToolResult(
            toolName = name,
            success = true,
            data = mapOf(
                "message" to "Status tracking coming soon",
                "status" to "unknown"
            )
        )
    }
    
    // Helper methods
    
    private fun validateWorkflowSpec(spec: JSONObject): Pair<Boolean, String> {
        if (!spec.has("nodes")) {
            return Pair(false, "Missing 'nodes' array")
        }
        
        val nodes = spec.optJSONArray("nodes")
        if (nodes == null || nodes.length() == 0) {
            return Pair(false, "Workflow must have at least one node")
        }
        
        // Validate each node has required fields
        for (i in 0 until nodes.length()) {
            val node = nodes.optJSONObject(i) ?: continue
            if (!node.has("id") || !node.has("type")) {
                return Pair(false, "Node at index $i missing 'id' or 'type'")
            }
        }
        
        return Pair(true, "")
    }
    
    private fun generateWorkflowId(name: String): String {
        val timestamp = System.currentTimeMillis()
        val sanitized = name.lowercase()
            .replace(Regex("[^a-z0-9]+"), "_")
            .take(20)
        return "wf_${sanitized}_$timestamp"
    }
    
    private fun findWorkflowByName(name: String): String? {
        val workflows = workflowPrefs.getAllWorkflows()
        return workflows.values.firstOrNull { jsonStr ->
            try {
                val json = JSONObject(jsonStr)
                json.optString("name").equals(name, ignoreCase = true)
            } catch (e: Exception) {
                false
            }
        }
    }
    
    private fun jsonObjectToMap(json: JSONObject): Map<String, Any?> {
        val map = mutableMapOf<String, Any?>()
        json.keys().forEach { key ->
            map[key] = json.opt(key)
        }
        return map
    }
    
    private fun jsonArrayToList(array: JSONArray): List<Any?> {
        val list = mutableListOf<Any?>()
        for (i in 0 until array.length()) {
            list.add(array.opt(i))
        }
        return list
    }
}

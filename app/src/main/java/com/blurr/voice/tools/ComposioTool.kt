package com.blurr.voice.tools

import android.content.Context
import android.util.Log
import com.blurr.voice.integrations.ComposioIntegrationManager
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/**
 * Composio Integration Tool
 * 
 * Story 4.14: Composio Integration
 * 
 * Universal tool for 2,000+ integrations via Composio.
 * Handles Notion, Asana, Linear, Slack, Jira, GitHub, and 1,994+ more!
 * 
 * Cost: $6,000/year (Scale Plan - 5M calls/month)
 * Coverage: Non-Google integrations (20% of usage)
 */
class ComposioTool(
    private val appContext: Context
) : BaseTool() {

    companion object {
        private const val TAG = "ComposioTool"
    }

    override val name: String = "composio"

    override val description: String = """
        Access 2,000+ integrations including Notion, Asana, Linear, Slack, Jira, GitHub, Trello, 
        Monday.com, ClickUp, Todoist, Salesforce, HubSpot, Stripe, and many more.
        
        **Popular Integrations**:
        - **Project Management**: Notion, Asana, Linear, Jira, Trello, Monday, ClickUp, Todoist
        - **Communication**: Slack, Microsoft Teams, Discord, Telegram
        - **Development**: GitHub, GitLab, Bitbucket, Jira
        - **CRM & Sales**: Salesforce, HubSpot, Pipedrive, Zoho CRM
        - **E-commerce**: Shopify, Stripe, PayPal, WooCommerce
        - **Marketing**: Mailchimp, SendGrid, Intercom, Typeform
        - **Productivity**: Evernote, Dropbox, Box, OneDrive
        - **And 1,970+ more!**
        
        **Actions**:
        - `list_integrations`: Show all available integrations (2,000+)
        - `popular`: Show popular integrations
        - `search`: Search integrations by keyword
        - `connect`: Connect a new integration (returns OAuth URL)
        - `list_connected`: Show user's connected integrations
        - `execute`: Execute an action on a connected integration
        - `disconnect`: Disconnect an integration
        
        **Parameters**:
        - action (required): one of the actions above
        - query (for search): search keyword
        - integration (for connect, execute, disconnect): Integration key (e.g., "notion", "asana")
        - action_name (for execute): Action to execute (e.g., "notion_create_page")
        - parameters (for execute): Action parameters as JSON
        - user_id (optional): User identifier (default: "default")
        
        **Note**: User must first connect an integration before executing actions on it.
    """.trimIndent()

    override val parameters: List<ToolParameter> = listOf(
        ToolParameter(
            name = "action",
            type = "string",
            description = "Action to perform",
            required = true,
            enum = listOf("list_integrations", "popular", "search", "connect", "list_connected", "execute", "disconnect")
        ),
        ToolParameter(
            name = "query",
            type = "string",
            description = "Search query (for action=search)",
            required = false
        ),
        ToolParameter(
            name = "integration",
            type = "string",
            description = "Integration key (for connect/execute/disconnect)",
            required = false
        ),
        ToolParameter(
            name = "action_name",
            type = "string",
            description = "Action name to execute (for action=execute)",
            required = false
        ),
        ToolParameter(
            name = "parameters",
            type = "object",
            description = "Action parameters (for action=execute)",
            required = false
        ),
        ToolParameter(
            name = "user_id",
            type = "string",
            description = "User identifier (default: default)",
            required = false
        )
    )

    private val manager by lazy { ComposioIntegrationManager(appContext) }

    override suspend fun execute(
        params: Map<String, Any>,
        context: List<ToolResult>
    ): ToolResult = withContext(Dispatchers.IO) {
        val validation = validateParameters(params)
        if (validation.isFailure) {
            return@withContext ToolResult.error(name, validation.exceptionOrNull()?.message ?: "Invalid parameters")
        }
        // Check subscription status - Composio is PRO only! (Story 4.16)
        val freemiumManager = com.blurr.voice.utilities.FreemiumManager()
        if (!freemiumManager.hasComposioAccess()) {
            return@withContext ToolResult.error(
                toolName = name,
                error = """
                    🔒 Composio integrations (2,000+ tools) are available in PRO version only.
                    
                    FREE users get:
                    ✅ Gmail (email management)
                    ✅ Google Calendar (scheduling)
                    ✅ Google Drive (file management)
                    
                    PRO users get everything above PLUS:
                    ✨ 2,000+ integrations via Composio
                    ✨ Notion, Asana, Linear, Jira, Trello
                    ✨ Slack, Teams, Discord, Telegram
                    ✨ GitHub, GitLab, Bitbucket
                    ✨ Salesforce, HubSpot, Stripe
                    ✨ And 1,990+ more tools!
                    
                    👉 Upgrade to PRO to unlock Composio integrations!
                """.trimIndent(),
                data = mapOf(
                    "requires_pro" to true,
                    "feature" to "composio",
                    "free_alternatives" to listOf("gmail", "google_calendar", "google_drive")
                )
            )
        }
        
        // Check if Composio is configured
        if (!manager.isConfigured()) {
            return@withContext ToolResult.error(
                toolName = name,
                error = "Composio is not configured. Please add your API key to ComposioConfig."
            )
        }
        
        val action = params["action"] as? String
            ?: return@withContext ToolResult.error(
                toolName = name,
                error = "Missing required parameter: action"
            )
        
        when (action) {
            "list_integrations" -> listIntegrations()
            "popular" -> listPopularIntegrations()
            "search" -> searchIntegrations(params)
            "connect" -> connectIntegration(params)
            "list_connected" -> listConnectedAccounts(params)
            "execute" -> executeAction(params)
            "disconnect" -> disconnectIntegration(params)
            else -> ToolResult.error(
                toolName = name,
                error = "Unknown action: $action. Valid actions: list_integrations, popular, search, connect, list_connected, execute, disconnect"
            )
        }
    }
    
    private suspend fun listIntegrations(): ToolResult {
        Log.d(TAG, "Listing all integrations")
        
        val result = manager.listAvailableIntegrations()
        
        return if (result.isSuccess) {
            val integrations = result.getOrNull() ?: emptyList()
            val summary = buildString {
                appendLine("Found ${integrations.size} available integrations:")
                appendLine()
                integrations.take(20).forEach { integration ->
                    appendLine("• ${integration.name} (${integration.key})")
                    integration.description?.let { appendLine("  $it") }
                    appendLine()
                }
                if (integrations.size > 20) {
                    appendLine("... and ${integrations.size - 20} more!")
                }
            }
            
            ToolResult.success(
                toolName = name,
                result = summary,
                data = mapOf("count" to integrations.size, "integrations" to integrations)
            )
        } else {
            ToolResult.error(
                toolName = name,
                error = "Failed to list integrations: ${result.exceptionOrNull()?.message}"
            )
        }
    }
    
    private suspend fun listPopularIntegrations(): ToolResult {
        Log.d(TAG, "Listing popular integrations")
        
        val result = manager.getPopularIntegrations()
        
        return if (result.isSuccess) {
            val integrations = result.getOrNull() ?: emptyList()
            val summary = buildString {
                appendLine("Popular integrations:")
                appendLine()
                integrations.forEach { integration ->
                    appendLine("• ${integration.name} (${integration.key})")
                    integration.description?.let { appendLine("  $it") }
                    appendLine()
                }
            }
            
            ToolResult.success(
                toolName = name,
                result = summary,
                data = mapOf("integrations" to integrations)
            )
        } else {
            ToolResult.error(
                toolName = name,
                error = "Failed to list popular integrations: ${result.exceptionOrNull()?.message}"
            )
        }
    }
    
    private suspend fun searchIntegrations(params: Map<String, Any>): ToolResult {
        val query = params["query"] as? String
            ?: return ToolResult.error(name, "Missing parameter: query")
        
        Log.d(TAG, "Searching integrations: $query")
        
        val result = manager.searchIntegrations(query)
        
        return if (result.isSuccess) {
            val integrations = result.getOrNull() ?: emptyList()
            val summary = buildString {
                appendLine("Found ${integrations.size} integrations matching '$query':")
                appendLine()
                integrations.forEach { integration ->
                    appendLine("• ${integration.name} (${integration.key})")
                    integration.description?.let { appendLine("  $it") }
                    appendLine()
                }
            }
            
            ToolResult.success(name, summary, mapOf("integrations" to integrations))
        } else {
            ToolResult.error(name, "Search failed: ${result.exceptionOrNull()?.message}")
        }
    }
    
    private suspend fun connectIntegration(params: Map<String, Any>): ToolResult {
        val integrationKey = params["integration"] as? String
            ?: return ToolResult.error(name, "Missing parameter: integration")
        
        val userId = params["user_id"] as? String ?: "default"
        
        Log.d(TAG, "Connecting integration: $integrationKey")
        
        val result = manager.connectIntegration(integrationKey, userId)
        
        return if (result.isSuccess) {
            val request = result.getOrNull()!!
            ToolResult.success(
                toolName = name,
                result = "To connect $integrationKey, please visit: ${request.redirectUrl}",
                data = mapOf(
                    "connection_id" to request.connectionId,
                    "redirect_url" to request.redirectUrl,
                    "status" to request.status
                )
            )
        } else {
            ToolResult.error(name, "Failed to connect: ${result.exceptionOrNull()?.message}")
        }
    }
    
    private suspend fun listConnectedAccounts(params: Map<String, Any>): ToolResult {
        val userId = params["user_id"] as? String ?: "default"
        
        Log.d(TAG, "Listing connected accounts")
        
        val result = manager.getConnectedAccounts(userId)
        
        return if (result.isSuccess) {
            val accounts = result.getOrNull() ?: emptyList()
            val summary = buildString {
                appendLine("Connected integrations: ${accounts.size}")
                appendLine()
                accounts.forEach { account ->
                    appendLine("• ${account.integrationId} (${account.status})")
                    appendLine("  ID: ${account.id}")
                    appendLine()
                }
            }
            
            ToolResult.success(name, summary, mapOf("accounts" to accounts))
        } else {
            ToolResult.error(name, "Failed to list accounts: ${result.exceptionOrNull()?.message}")
        }
    }
    
    private suspend fun executeAction(params: Map<String, Any>): ToolResult {
        val integrationKey = params["integration"] as? String
            ?: return ToolResult.error(name, "Missing parameter: integration")
        
        val actionName = params["action_name"] as? String
            ?: return ToolResult.error(name, "Missing parameter: action_name")
        
        val actionParams = params["parameters"] as? Map<String, Any> ?: emptyMap()
        val userId = params["user_id"] as? String ?: "default"
        
        Log.d(TAG, "Executing action: $actionName on $integrationKey")
        
        val result = manager.executeAction(integrationKey, actionName, actionParams, userId)
        
        return if (result.isSuccess) {
            val actionResult = result.getOrNull()!!
            if (actionResult.success) {
                ToolResult.success(
                    toolName = name,
                    result = "Action executed successfully: ${actionResult.data}",
                    data = mapOf("result" to actionResult.data)
                )
            } else {
                ToolResult.error(name, "Action failed: ${actionResult.error}")
            }
        } else {
            ToolResult.error(name, "Execution failed: ${result.exceptionOrNull()?.message}")
        }
    }
    
    private suspend fun disconnectIntegration(params: Map<String, Any>): ToolResult {
        val integrationKey = params["integration"] as? String
            ?: return ToolResult.error(name, "Missing parameter: integration")
        
        val userId = params["user_id"] as? String ?: "default"
        
        Log.d(TAG, "Disconnecting integration: $integrationKey")
        
        val result = manager.disconnectIntegration(integrationKey, userId)
        
        return if (result.isSuccess) {
            ToolResult.success(name, "Disconnected $integrationKey successfully")
        } else {
            ToolResult.error(name, "Failed to disconnect: ${result.exceptionOrNull()?.message}")
        }
    }
    
    fun getSchema(): Map<String, Any> = mapOf(
        "name" to name,
        "description" to description,
        "parameters" to mapOf(
            "type" to "object",
            "properties" to mapOf(
                "action" to mapOf(
                    "type" to "string",
                    "description" to "Action to perform",
                    "enum" to listOf("list_integrations", "popular", "search", "connect", "list_connected", "execute", "disconnect")
                ),
                "integration" to mapOf(
                    "type" to "string",
                    "description" to "Integration key (e.g., 'notion', 'asana', 'linear')"
                ),
                "action_name" to mapOf(
                    "type" to "string",
                    "description" to "Action to execute on the integration"
                ),
                "parameters" to mapOf(
                    "type" to "object",
                    "description" to "Parameters for the action"
                ),
                "user_id" to mapOf(
                    "type" to "string",
                    "description" to "User identifier (optional, default: 'default')"
                ),
                "query" to mapOf(
                    "type" to "string",
                    "description" to "Search query for integrations"
                )
            ),
            "required" to listOf("action")
        )
    )
}

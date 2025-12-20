package com.twent.voice.integrations

import android.content.Context
import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/**
 * Composio Integration Manager
 * 
 * Story 4.14: Composio Integration
 * 
 * High-level manager for Composio integrations.
 * Handles connection lifecycle and action execution for 2,000+ tools.
 * 
 * Supported Integrations:
 * - Notion, Asana, Linear, Jira, Slack, GitHub
 * - Trello, Monday.com, ClickUp, Todoist
 * - Salesforce, HubSpot, Stripe, Shopify
 * - And 1,990+ more!
 */
class ComposioIntegrationManager(
    private val context: Context,
    apiKey: String = ComposioConfig.API_KEY
) {
    
    companion object {
        private const val TAG = "ComposioIntegrationManager"
        
        // Popular integrations
        const val NOTION = "notion"
        const val ASANA = "asana"
        const val LINEAR = "linear"
        const val SLACK = "slack"
        const val JIRA = "jira"
        const val GITHUB = "github"
        const val TRELLO = "trello"
        const val TODOIST = "todoist"
        const val MONDAY = "monday"
        const val CLICKUP = "clickup"
    }
    
    private val client = ComposioClient(apiKey)
    private val sharedPrefs = context.getSharedPreferences("composio_integrations", Context.MODE_PRIVATE)
    
    /**
     * Check if Composio is configured
     */
    fun isConfigured(): Boolean {
        return ComposioConfig.API_KEY != "YOUR_COMPOSIO_API_KEY_HERE"
    }
    
    /**
     * Get list of all available integrations
     */
    suspend fun listAvailableIntegrations(): Result<List<Integration>> {
        return client.listIntegrations()
    }
    
    /**
     * Get available actions for an integration
     */
    suspend fun getActionsForIntegration(integrationKey: String): Result<List<Action>> {
        return client.listActions(integrationKey)
    }
    
    /**
     * Connect a new integration
     * 
     * Returns URL that user must visit to authorize.
     * User will be redirected back to app after authorization.
     * 
     * @param integrationKey The integration to connect (e.g., "notion", "asana")
     * @param userId Unique user ID (default: "default")
     */
    suspend fun connectIntegration(
        integrationKey: String,
        userId: String = "default"
    ): Result<ConnectionRequest> {
        Log.d(TAG, "Connecting integration: $integrationKey for user: $userId")
        
        val result = client.initiateConnection(integrationKey, userId)
        
        if (result.isSuccess) {
            // Save connection attempt
            saveConnectionAttempt(userId, integrationKey, result.getOrNull()!!)
        }
        
        return result
    }
    
    /**
     * Get all connected accounts for a user
     */
    suspend fun getConnectedAccounts(userId: String = "default"): Result<List<ConnectedAccount>> {
        return client.getConnectedAccounts(userId)
    }
    
    /**
     * Check if a specific integration is connected
     */
    suspend fun isIntegrationConnected(
        integrationKey: String,
        userId: String = "default"
    ): Boolean {
        val accountsResult = getConnectedAccounts(userId)
        
        if (accountsResult.isFailure) {
            return false
        }
        
        val accounts = accountsResult.getOrNull() ?: return false
        return accounts.any { it.integrationId == integrationKey && it.status == "active" }
    }
    
    /**
     * Get connected account ID for an integration
     */
    suspend fun getConnectedAccountId(
        integrationKey: String,
        userId: String = "default"
    ): String? {
        val accountsResult = getConnectedAccounts(userId)
        
        if (accountsResult.isFailure) {
            return null
        }
        
        val accounts = accountsResult.getOrNull() ?: return null
        return accounts.find { it.integrationId == integrationKey && it.status == "active" }?.id
    }
    
    /**
     * Execute an action on a connected integration
     * 
     * This is the main method for interacting with integrations.
     * 
     * @param integrationKey The integration (e.g., "notion", "asana")
     * @param actionName The action to execute (e.g., "notion_create_page")
     * @param parameters Action parameters
     * @param userId User ID
     */
    suspend fun executeAction(
        integrationKey: String,
        actionName: String,
        parameters: Map<String, Any> = emptyMap(),
        userId: String = "default"
    ): Result<ActionResult> {
        // Get connected account ID
        val connectedAccountId = getConnectedAccountId(integrationKey, userId)
            ?: return Result.failure(Exception("Integration not connected: $integrationKey"))
        
        Log.d(TAG, "Executing action: $actionName on $integrationKey")
        
        return client.executeAction(connectedAccountId, actionName, parameters)
    }
    
    /**
     * Disconnect an integration
     */
    suspend fun disconnectIntegration(
        integrationKey: String,
        userId: String = "default"
    ): Result<Unit> {
        val connectedAccountId = getConnectedAccountId(integrationKey, userId)
            ?: return Result.failure(Exception("Integration not connected: $integrationKey"))
        
        val result = client.disconnectAccount(connectedAccountId)
        
        if (result.isSuccess) {
            // Clear saved connection info
            clearConnectionInfo(userId, integrationKey)
        }
        
        return result
    }
    
    /**
     * Get popular integrations
     */
    suspend fun getPopularIntegrations(): Result<List<Integration>> {
        val allIntegrationsResult = listAvailableIntegrations()
        
        if (allIntegrationsResult.isFailure) {
            return allIntegrationsResult
        }
        
        val allIntegrations = allIntegrationsResult.getOrNull() ?: return Result.success(emptyList())
        
        val popularKeys = listOf(
            NOTION, ASANA, LINEAR, SLACK, JIRA, GITHUB,
            TRELLO, TODOIST, MONDAY, CLICKUP
        )
        
        val popularIntegrations = allIntegrations.filter { it.key in popularKeys }
        
        return Result.success(popularIntegrations)
    }
    
    /**
     * Search integrations by name or category
     */
    suspend fun searchIntegrations(query: String): Result<List<Integration>> {
        val allIntegrationsResult = listAvailableIntegrations()
        
        if (allIntegrationsResult.isFailure) {
            return allIntegrationsResult
        }
        
        val allIntegrations = allIntegrationsResult.getOrNull() ?: return Result.success(emptyList())
        
        val matchingIntegrations = allIntegrations.filter {
            it.name.contains(query, ignoreCase = true) ||
            it.key.contains(query, ignoreCase = true) ||
            it.description?.contains(query, ignoreCase = true) == true ||
            it.categories.any { category -> category.contains(query, ignoreCase = true) }
        }
        
        return Result.success(matchingIntegrations)
    }
    
    // Private helper methods
    
    private fun saveConnectionAttempt(userId: String, integrationKey: String, request: ConnectionRequest) {
        sharedPrefs.edit()
            .putString("${userId}_${integrationKey}_connection_id", request.connectionId)
            .putString("${userId}_${integrationKey}_redirect_url", request.redirectUrl)
            .putString("${userId}_${integrationKey}_status", request.status)
            .apply()
    }
    
    private fun clearConnectionInfo(userId: String, integrationKey: String) {
        sharedPrefs.edit()
            .remove("${userId}_${integrationKey}_connection_id")
            .remove("${userId}_${integrationKey}_redirect_url")
            .remove("${userId}_${integrationKey}_status")
            .apply()
    }
}

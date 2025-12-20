package com.twent.voice.integrations

import android.util.Log
import com.google.gson.Gson
import com.google.gson.JsonObject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.toRequestBody
import java.io.IOException
import java.util.concurrent.TimeUnit

/**
 * Composio API Client
 * 
 * Story 4.14: Composio Integration
 * 
 * REST API client for Composio - 2,000+ tool integrations.
 * Handles OAuth, connections, and action execution.
 * 
 * Docs: https://docs.composio.dev
 */
class ComposioClient(
    private val apiKey: String = ComposioConfig.API_KEY
) {
    
    companion object {
        private const val TAG = "ComposioClient"
    }
    
    private val gson = Gson()
    
    private val client = OkHttpClient.Builder()
        .connectTimeout(ComposioConfig.TIMEOUT_SECONDS, TimeUnit.SECONDS)
        .readTimeout(ComposioConfig.TIMEOUT_SECONDS, TimeUnit.SECONDS)
        .writeTimeout(ComposioConfig.TIMEOUT_SECONDS, TimeUnit.SECONDS)
        .addInterceptor { chain ->
            val request = chain.request().newBuilder()
                .addHeader("X-API-Key", apiKey)
                .addHeader("Content-Type", "application/json")
                .build()
            chain.proceed(request)
        }
        .build()
    
    /**
     * List all available integrations
     */
    suspend fun listIntegrations(): Result<List<Integration>> = withContext(Dispatchers.IO) {
        try {
            val request = Request.Builder()
                .url("${ComposioConfig.BASE_URL}apps")
                .get()
                .build()
            
            val response = client.newCall(request).execute()
            
            if (response.isSuccessful) {
                val body = response.body?.string()
                val json = gson.fromJson(body, JsonObject::class.java)
                val apps = json.getAsJsonArray("items")
                
                val integrations = apps.map { element ->
                    val app = element.asJsonObject
                    Integration(
                        key = app.get("key").asString,
                        name = app.get("name").asString,
                        description = app.get("description")?.asString,
                        logo = app.get("logo")?.asString,
                        categories = app.getAsJsonArray("categories")?.map { it.asString } ?: emptyList()
                    )
                }
                
                Log.d(TAG, "Found ${integrations.size} integrations")
                Result.success(integrations)
            } else {
                Result.failure(Exception("Failed to list integrations: ${response.code}"))
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error listing integrations", e)
            Result.failure(e)
        }
    }
    
    /**
     * Get available actions for an integration
     */
    suspend fun listActions(appKey: String): Result<List<Action>> = withContext(Dispatchers.IO) {
        try {
            val request = Request.Builder()
                .url("${ComposioConfig.BASE_URL}actions?appNames=$appKey")
                .get()
                .build()
            
            val response = client.newCall(request).execute()
            
            if (response.isSuccessful) {
                val body = response.body?.string()
                val json = gson.fromJson(body, JsonObject::class.java)
                val items = json.getAsJsonArray("items")
                
                val actions = items.map { element ->
                    val action = element.asJsonObject
                    Action(
                        name = action.get("name").asString,
                        displayName = action.get("display_name")?.asString,
                        description = action.get("description")?.asString,
                        parameters = action.getAsJsonObject("parameters"),
                        response = action.getAsJsonObject("response")
                    )
                }
                
                Log.d(TAG, "Found ${actions.size} actions for $appKey")
                Result.success(actions)
            } else {
                Result.failure(Exception("Failed to list actions: ${response.code}"))
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error listing actions", e)
            Result.failure(e)
        }
    }
    
    /**
     * Initiate OAuth connection for an integration
     * 
     * Returns connection URL that user must visit to authorize
     */
    suspend fun initiateConnection(
        integrationId: String,
        entityId: String = "default"
    ): Result<ConnectionRequest> = withContext(Dispatchers.IO) {
        try {
            val requestBody = gson.toJson(mapOf(
                "integrationId" to integrationId,
                "entityId" to entityId
            )).toRequestBody("application/json".toMediaType())
            
            val request = Request.Builder()
                .url("${ComposioConfig.BASE_URL}connectedAccounts")
                .post(requestBody)
                .build()
            
            val response = client.newCall(request).execute()
            
            if (response.isSuccessful) {
                val body = response.body?.string()
                val json = gson.fromJson(body, JsonObject::class.java)
                
                val connectionRequest = ConnectionRequest(
                    connectionId = json.get("connectionId")?.asString ?: "",
                    redirectUrl = json.get("redirectUrl")?.asString ?: "",
                    status = json.get("status")?.asString ?: "pending"
                )
                
                Log.d(TAG, "Connection initiated: ${connectionRequest.connectionId}")
                Result.success(connectionRequest)
            } else {
                Result.failure(Exception("Failed to initiate connection: ${response.code}"))
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error initiating connection", e)
            Result.failure(e)
        }
    }
    
    /**
     * Get connected accounts for a user
     */
    suspend fun getConnectedAccounts(entityId: String = "default"): Result<List<ConnectedAccount>> = withContext(Dispatchers.IO) {
        try {
            val request = Request.Builder()
                .url("${ComposioConfig.BASE_URL}connectedAccounts?entityId=$entityId")
                .get()
                .build()
            
            val response = client.newCall(request).execute()
            
            if (response.isSuccessful) {
                val body = response.body?.string()
                val json = gson.fromJson(body, JsonObject::class.java)
                val items = json.getAsJsonArray("items")
                
                val accounts = items.map { element ->
                    val account = element.asJsonObject
                    ConnectedAccount(
                        id = account.get("id").asString,
                        integrationId = account.get("integrationId").asString,
                        status = account.get("status")?.asString ?: "active",
                        createdAt = account.get("createdAt")?.asString
                    )
                }
                
                Log.d(TAG, "Found ${accounts.size} connected accounts")
                Result.success(accounts)
            } else {
                Result.failure(Exception("Failed to get connected accounts: ${response.code}"))
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error getting connected accounts", e)
            Result.failure(e)
        }
    }
    
    /**
     * Execute an action via Composio
     * 
     * This is the main method for interacting with integrations.
     */
    suspend fun executeAction(
        connectedAccountId: String,
        actionName: String,
        parameters: Map<String, Any> = emptyMap()
    ): Result<ActionResult> = withContext(Dispatchers.IO) {
        try {
            val requestBody = gson.toJson(mapOf(
                "connectedAccountId" to connectedAccountId,
                "input" to parameters
            )).toRequestBody("application/json".toMediaType())
            
            val request = Request.Builder()
                .url("${ComposioConfig.BASE_URL}actions/$actionName/execute")
                .post(requestBody)
                .build()
            
            if (ComposioConfig.DEBUG) {
                Log.d(TAG, "Executing action: $actionName with params: $parameters")
            }
            
            val response = client.newCall(request).execute()
            
            if (response.isSuccessful) {
                val body = response.body?.string()
                val json = gson.fromJson(body, JsonObject::class.java)
                
                val actionResult = ActionResult(
                    success = json.get("success")?.asBoolean ?: true,
                    data = json.get("data"),
                    error = json.get("error")?.asString
                )
                
                Log.d(TAG, "Action executed successfully: $actionName")
                Result.success(actionResult)
            } else {
                val errorBody = response.body?.string()
                Log.e(TAG, "Action execution failed: ${response.code} - $errorBody")
                Result.failure(Exception("Failed to execute action: ${response.code}"))
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error executing action", e)
            Result.failure(e)
        }
    }
    
    /**
     * Disconnect an account
     */
    suspend fun disconnectAccount(connectedAccountId: String): Result<Unit> = withContext(Dispatchers.IO) {
        try {
            val request = Request.Builder()
                .url("${ComposioConfig.BASE_URL}connectedAccounts/$connectedAccountId")
                .delete()
                .build()
            
            val response = client.newCall(request).execute()
            
            if (response.isSuccessful) {
                Log.d(TAG, "Account disconnected: $connectedAccountId")
                Result.success(Unit)
            } else {
                Result.failure(Exception("Failed to disconnect account: ${response.code}"))
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error disconnecting account", e)
            Result.failure(e)
        }
    }
}

/**
 * Data models for Composio API
 */

data class Integration(
    val key: String,
    val name: String,
    val description: String?,
    val logo: String?,
    val categories: List<String>
)

data class Action(
    val name: String,
    val displayName: String?,
    val description: String?,
    val parameters: JsonObject?,
    val response: JsonObject?
)

data class ConnectionRequest(
    val connectionId: String,
    val redirectUrl: String,
    val status: String
)

data class ConnectedAccount(
    val id: String,
    val integrationId: String,
    val status: String,
    val createdAt: String?
)

data class ActionResult(
    val success: Boolean,
    val data: Any?,
    val error: String?
)

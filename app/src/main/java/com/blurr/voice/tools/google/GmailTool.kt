package com.blurr.voice.tools.google

import android.content.Context
import android.util.Log
import com.blurr.voice.auth.GoogleAuthManager
import com.blurr.voice.tools.BaseTool
import com.blurr.voice.tools.ToolParameter
import com.blurr.voice.tools.ToolResult
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONArray
import org.json.JSONObject
import java.util.Base64
import java.util.concurrent.TimeUnit

/**
 * Gmail Tool - FREE Google Workspace Integration
 * 
 * Uses GoogleAuthManager from Story 4.13 for OAuth authentication.
 * Provides email reading, searching, composing, and sending capabilities.
 * 
 * Cost: $0 (uses user's quota: 1M queries/day per user)
 * Part of: Hybrid Integration Strategy (Story 4.13 + 4.15)
 */
class GmailTool(
    private val context: Context,
    private val authManager: GoogleAuthManager
) : BaseTool() {
    
    companion object {
        private const val TAG = "GmailTool"
        private const val BASE_URL = "https://gmail.googleapis.com/gmail/v1/users/me"
    }
    
    private val client = OkHttpClient.Builder()
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .build()
    
    override val name = "gmail"
    override val description = "Manage Gmail: read, search, send, and organize emails using your Google account"
    
    override val parameters = listOf(
        ToolParameter(
            name = "action",
            type = "string",
            description = "Action to perform: list, read, search, send",
            required = true
        ),
        ToolParameter(
            name = "max_results",
            type = "number",
            description = "Maximum number of emails to return (default: 10, max: 100)",
            required = false
        ),
        ToolParameter(
            name = "query",
            type = "string",
            description = "Search query (Gmail search syntax, e.g., 'from:user@example.com subject:meeting')",
            required = false
        ),
        ToolParameter(
            name = "message_id",
            type = "string",
            description = "Gmail message ID for read action",
            required = false
        ),
        ToolParameter(
            name = "to",
            type = "string",
            description = "Recipient email address",
            required = false
        ),
        ToolParameter(
            name = "subject",
            type = "string",
            description = "Email subject line",
            required = false
        ),
        ToolParameter(
            name = "body",
            type = "string",
            description = "Email body content (plain text)",
            required = false
        )
    )
    
    override suspend fun execute(params: Map<String, Any>, context: List<ToolResult>): ToolResult {
        return withContext(Dispatchers.IO) {
            try {
                // Check if user is signed in
                if (!authManager.isSignedIn()) {
                    return@withContext ToolResult.error(
                        name,
                        "Not signed in to Google. Please sign in first.",
                        mapOf("requires_auth" to true)
                    )
                }
                
                val tokenResult = authManager.getAccessToken()
                if (tokenResult.isFailure) {
                    return@withContext ToolResult.error(
                        name,
                        "Failed to get Google access token"
                    )
                }
                
                val accessToken = tokenResult.getOrThrow()
                val action = getRequiredParam<String>(params, "action")
                
                when (action.lowercase()) {
                    "list" -> listEmails(accessToken, params)
                    "read" -> readEmail(accessToken, params)
                    "search" -> searchEmails(accessToken, params)
                    "send" -> sendEmail(accessToken, params)
                    else -> ToolResult.error(
                        name,
                        "Unknown action: $action. Available actions: list, read, search, send"
                    )
                }
            } catch (e: Exception) {
                Log.e(TAG, "Gmail operation failed", e)
                ToolResult.error(name, "Gmail error: ${e.message}")
            }
        }
    }
    
    private fun listEmails(accessToken: String, params: Map<String, Any>): ToolResult {
        val maxResults = getOptionalParam(params, "max_results", 10L).toInt()
        
        val url = "$BASE_URL/messages?maxResults=$maxResults"
        val request = Request.Builder()
            .url(url)
            .addHeader("Authorization", "Bearer $accessToken")
            .get()
            .build()
        
        return executeRequest(accessToken, request) { response ->
            val messages = response.optJSONArray("messages") ?: JSONArray()
            val emailList = mutableListOf<Map<String, Any?>>()
            
            for (i in 0 until minOf(messages.length(), maxResults)) {
                val msgRef = messages.getJSONObject(i)
                val id = msgRef.optString("id")
                val details = getEmailDetails(accessToken, id)
                emailList.add(details)
            }
            
            ToolResult.success(
                name,
                mapOf(
                    "count" to emailList.size,
                    "emails" to emailList
                ),
                "Found ${emailList.size} emails"
            )
        }
    }
    
    private fun readEmail(accessToken: String, params: Map<String, Any>): ToolResult {
        val messageId = getRequiredParam<String>(params, "message_id")
        
        val url = "$BASE_URL/messages/$messageId?format=full"
        val request = Request.Builder()
            .url(url)
            .addHeader("Authorization", "Bearer $accessToken")
            .get()
            .build()
        
        return executeRequest(accessToken, request) { response ->
            val headers = response.optJSONObject("payload")?.optJSONObject("headers")
            val subject = getHeader(headers, "Subject")
            val from = getHeader(headers, "From")
            val date = getHeader(headers, "Date")
            val snippet = response.optString("snippet")
            
            // Extract body
            val parts = response.optJSONObject("payload")?.optJSONArray("parts")
            var body = ""
            if (parts?.length() ?: 0 > 0) {
                body = parts?.getJSONObject(0)?.optString("body")?.optString("data") ?: ""
                if (body.isNotEmpty()) {
                    body = String(Base64.getUrlDecoder().decode(body))
                }
            }
            
            ToolResult.success(
                name,
                mapOf(
                    "message_id" to messageId,
                    "from" to from,
                    "subject" to subject,
                    "date" to date,
                    "body" to body,
                    "snippet" to snippet
                ),
                "Email retrieved successfully"
            )
        }
    }
    
    private fun searchEmails(accessToken: String, params: Map<String, Any>): ToolResult {
        val query = getRequiredParam<String>(params, "query")
        val maxResults = getOptionalParam(params, "max_results", 10L).toInt()
        
        val url = "$BASE_URL/messages?q=${java.net.URLEncoder.encode(query, "UTF-8")}&maxResults=$maxResults"
        val request = Request.Builder()
            .url(url)
            .addHeader("Authorization", "Bearer $accessToken")
            .get()
            .build()
        
        return executeRequest(accessToken, request) { response ->
            val messages = response.optJSONArray("messages") ?: JSONArray()
            val emailList = mutableListOf<Map<String, Any?>>()
            
            for (i in 0 until minOf(messages.length(), maxResults)) {
                val msgRef = messages.getJSONObject(i)
                val id = msgRef.optString("id")
                val details = getEmailDetails(accessToken, id)
                emailList.add(details)
            }
            
            ToolResult.success(
                name,
                mapOf(
                    "query" to query,
                    "count" to emailList.size,
                    "emails" to emailList
                ),
                "Found ${emailList.size} emails matching: $query"
            )
        }
    }
    
    private fun sendEmail(accessToken: String, params: Map<String, Any>): ToolResult {
        val to = getRequiredParam<String>(params, "to")
        val subject = getRequiredParam<String>(params, "subject")
        val body = getRequiredParam<String>(params, "body")
        
        val rawMessage = "To: $to\r\nSubject: $subject\r\nContent-Type: text/plain; charset=UTF-8\r\n\r\n$body"
        val encodedMessage = Base64.getUrlEncoder().encodeToString(rawMessage.toByteArray())
        
        val jsonBody = JSONObject().put("raw", encodedMessage)
        
        val url = "$BASE_URL/messages/send"
        val request = Request.Builder()
            .url(url)
            .addHeader("Authorization", "Bearer $accessToken")
            .addHeader("Content-Type", "application/json")
            .post(jsonBody.toString().toRequestBody("application/json".toMediaType()))
            .build()
        
        return executeRequest(accessToken, request) { response ->
            ToolResult.success(
                name,
                mapOf(
                    "message_id" to response.optString("id"),
                    "thread_id" to response.optString("threadId"),
                    "to" to to,
                    "subject" to subject
                ),
                "Email sent successfully to $to"
            )
        }
    }
    
    private fun getEmailDetails(accessToken: String, messageId: String): Map<String, Any?> {
        val url = "$BASE_URL/messages/$messageId?format=metadata&metadataHeaders=From,Subject,Date"
        val request = Request.Builder()
            .url(url)
            .addHeader("Authorization", "Bearer $accessToken")
            .get()
            .build()
        
        return try {
            client.newCall(request).execute().use { response ->
                if (response.isSuccessful) {
                    val body = response.body?.string()
                    val json = JSONObject(body ?: "{}")
                    val headers = json.optJSONObject("payload")?.optJSONObject("headers")
                    mapOf(
                        "id" to messageId,
                        "from" to getHeader(headers, "From"),
                        "subject" to getHeader(headers, "Subject"),
                        "date" to getHeader(headers, "Date"),
                        "snippet" to json.optString("snippet")
                    )
                } else {
                    mapOf("id" to messageId, "error" to "Failed to fetch details")
                }
            }
        } catch (e: Exception) {
            mapOf("id" to messageId, "error" to e.message)
        }
    }
    
    private fun getHeader(headers: JSONObject?, name: String): String? {
        return headers?.optJSONArray("headers")?.let { arr ->
            for (i in 0 until arr.length()) {
                val header = arr.getJSONObject(i)
                if (header.optString("name") == name) {
                    return header.optString("value")
                }
            }
            null
        }
    }
    
    private fun <T> executeRequest(
        accessToken: String,
        request: Request,
        onSuccess: (JSONObject) -> T
    ): ToolResult {
        return try {
            client.newCall(request).execute().use { response ->
                val body = response.body?.string()
                if (response.isSuccessful && body != null) {
                    onSuccess(JSONObject(body))
                } else {
                    ToolResult.error(name, "API error: ${response.code} - $body")
                }
            }
        } catch (e: Exception) {
            ToolResult.error(name, "Request failed: ${e.message}")
        }
    }
}

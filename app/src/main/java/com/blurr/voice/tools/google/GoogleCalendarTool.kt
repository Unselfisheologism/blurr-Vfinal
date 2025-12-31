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
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone
import java.util.concurrent.TimeUnit

/**
 * Google Calendar Tool - FREE Google Workspace Integration
 * 
 * Uses GoogleAuthManager from Story 4.13 for OAuth authentication.
 * Provides calendar management: events, meetings, scheduling.
 * 
 * Cost: $0 (uses user's quota: 1M queries/day per user)
 * Part of: Hybrid Integration Strategy (Story 4.13 + 4.16)
 */
class GoogleCalendarTool(
    private val context: Context,
    private val authManager: GoogleAuthManager
) : BaseTool() {
    
    companion object {
        private const val TAG = "GoogleCalendarTool"
        private const val BASE_URL = "https://www.googleapis.com/calendar/v3/calendars/primary"
    }
    
    private val client = OkHttpClient.Builder()
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .build()
    
    private val dateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'", Locale.US).apply {
        timeZone = TimeZone.getTimeZone("UTC")
    }
    
    override val name = "google_calendar"
    override val description = "Manage Google Calendar: list events, create meetings, update schedules, check availability"
    
    override val parameters = listOf(
        ToolParameter(
            name = "action",
            type = "string",
            description = "Action: list, create, update, delete, get",
            required = true
        ),
        ToolParameter(
            name = "event_id",
            type = "string",
            description = "Event ID for get, update, delete actions",
            required = false
        ),
        ToolParameter(
            name = "summary",
            type = "string",
            description = "Event title/summary",
            required = false
        ),
        ToolParameter(
            name = "description",
            type = "string",
            description = "Event description",
            required = false
        ),
        ToolParameter(
            name = "start_time",
            type = "string",
            description = "Start time (ISO 8601 format, e.g., 2024-01-15T10:00:00Z)",
            required = false
        ),
        ToolParameter(
            name = "end_time",
            type = "string",
            description = "End time (ISO 8601 format)",
            required = false
        ),
        ToolParameter(
            name = "attendees",
            type = "string",
            description = "Comma-separated list of attendee emails",
            required = false
        )
    )
    
    override suspend fun execute(params: Map<String, Any>, context: List<ToolResult>): ToolResult {
        return withContext(Dispatchers.IO) {
            try {
                if (!authManager.isSignedIn()) {
                    return@withContext ToolResult.error(
                        name,
                        "Not signed in to Google. Please sign in first.",
                        mapOf("requires_auth" to true)
                    )
                }
                
                val tokenResult = authManager.getAccessToken()
                if (tokenResult.isFailure) {
                    return@withContext ToolResult.error(name, "Failed to get Google access token")
                }
                
                val accessToken = tokenResult.getOrThrow()
                val action = getRequiredParam<String>(params, "action")
                
                when (action.lowercase()) {
                    "list" -> listEvents(accessToken)
                    "create" -> createEvent(accessToken, params)
                    "get" -> getEvent(accessToken, params)
                    "update" -> updateEvent(accessToken, params)
                    "delete" -> deleteEvent(accessToken, params)
                    else -> ToolResult.error(name, "Unknown action: $action")
                }
            } catch (e: Exception) {
                Log.e(TAG, "Calendar operation failed", e)
                ToolResult.error(name, "Calendar error: ${e.message}")
            }
        }
    }
    
    private fun listEvents(accessToken: String): ToolResult {
        val now = System.currentTimeMillis()
        val futureTime = now + (30L * 24 * 60 * 60 * 1000) // 30 days ahead
        
        val url = "$BASE_URL/events?timeMin=${dateFormat.format(Date(now))}&timeMax=${dateFormat.format(Date(futureTime))}&singleEvents=true&orderBy=startTime&maxResults=20"
        val request = Request.Builder()
            .url(url)
            .addHeader("Authorization", "Bearer $accessToken")
            .get()
            .build()
        
        return executeRequest(request) { response ->
            val events = response.optJSONArray("items") ?: JSONArray()
            val eventList = mutableListOf<Map<String, Any?>>()
            
            for (i in 0 until events.length()) {
                val event = events.getJSONObject(i)
                val startJson = event.optJSONObject("start")
                val endJson = event.optJSONObject("end")
                eventList.add(mapOf(
                    "id" to event.optString("id"),
                    "summary" to event.optString("summary"),
                    "description" to event.optString("description"),
                    "start" to (startJson?.optString("dateTime") ?: startJson?.optString("date") ?: ""),
                    "end" to (endJson?.optString("dateTime") ?: endJson?.optString("date") ?: "")
                ))
            }
            
            ToolResult.success(
                toolName = name,
                data = mapOf("count" to eventList.size, "events" to eventList),
                result = "Found ${eventList.size} upcoming events"
            )
        }
    }
    
    private fun createEvent(accessToken: String, params: Map<String, Any>): ToolResult {
        val summary = getRequiredParam<String>(params, "summary")
        val startTime = getRequiredParam<String>(params, "start_time")
        val endTime = getRequiredParam<String>(params, "end_time")
        val description = getOptionalParam(params, "description", "")
        val attendeesStr = getOptionalParam(params, "attendees", "")
        
        val jsonBody = JSONObject().apply {
            put("summary", summary)
            put("description", description)
            put("start", JSONObject().put("dateTime", startTime))
            put("end", JSONObject().put("dateTime", endTime))
            if (attendeesStr.isNotEmpty()) {
                val attendees = JSONArray()
                attendeesStr.split(",").forEach { email ->
                    attendees.put(JSONObject().put("email", email.trim()))
                }
                put("attendees", attendees)
            }
        }
        
        val request = Request.Builder()
            .url("$BASE_URL/events")
            .addHeader("Authorization", "Bearer $accessToken")
            .addHeader("Content-Type", "application/json")
            .post(jsonBody.toString().toRequestBody("application/json".toMediaType()))
            .build()
        
        return executeRequest(request) { response ->
            ToolResult.success(
                toolName = name,
                data = mapOf(
                    "id" to response.optString("id"),
                    "summary" to response.optString("summary"),
                    "htmlLink" to response.optString("htmlLink")
                ),
                result = "Event created: $summary"
            )
        }
    }
    
    private fun getEvent(accessToken: String, params: Map<String, Any>): ToolResult {
        val eventId = getRequiredParam<String>(params, "event_id")
        
        val request = Request.Builder()
            .url("$BASE_URL/events/$eventId")
            .addHeader("Authorization", "Bearer $accessToken")
            .get()
            .build()
        
        return executeRequest(request) { response ->
            ToolResult.success(
                toolName = name,
                data = mapOf(
                    "id" to response.optString("id"),
                    "summary" to response.optString("summary"),
                    "description" to response.optString("description"),
                    "start" to response.optJSONObject("start")?.optString("dateTime"),
                    "end" to response.optJSONObject("end")?.optString("dateTime"),
                    "htmlLink" to response.optString("htmlLink")
                ),
                result = "Event retrieved"
            )
        }
    }
    
    private fun updateEvent(accessToken: String, params: Map<String, Any>): ToolResult {
        val eventId = getRequiredParam<String>(params, "event_id")
        
        val jsonBody = JSONObject()
        params["summary"]?.let { jsonBody.put("summary", it) }
        params["description"]?.let { jsonBody.put("description", it) }
        params["start_time"]?.let { jsonBody.put("start", JSONObject().put("dateTime", it)) }
        params["end_time"]?.let { jsonBody.put("end", JSONObject().put("dateTime", it)) }
        
        val request = Request.Builder()
            .url("$BASE_URL/events/$eventId")
            .addHeader("Authorization", "Bearer $accessToken")
            .addHeader("Content-Type", "application/json")
            .patch(jsonBody.toString().toRequestBody("application/json".toMediaType()))
            .build()
        
        return executeRequest(request) { response ->
            ToolResult.success(
                toolName = name,
                data = mapOf("id" to response.optString("id"), "updated" to response.optString("updated")),
                result = "Event updated"
            )
        }
    }
    
    private fun deleteEvent(accessToken: String, params: Map<String, Any>): ToolResult {
        val eventId = getRequiredParam<String>(params, "event_id")
        
        val request = Request.Builder()
            .url("$BASE_URL/events/$eventId")
            .addHeader("Authorization", "Bearer $accessToken")
            .delete()
            .build()
        
        return executeRequest(request) { _ ->
            ToolResult.success(toolName = name, data = mapOf("id" to eventId), result = "Event deleted")
        }
    }
    
    private fun executeRequest(request: Request, onSuccess: (JSONObject) -> ToolResult): ToolResult {
        return try {
            client.newCall(request).execute().use { response ->
                val body = response.body?.string()
                if (response.isSuccessful && body != null) {
                    return onSuccess(JSONObject(body))
                } else {
                    ToolResult.error(name, "API error: ${response.code} - $body")
                }
            }
        } catch (e: Exception) {
            ToolResult.error(name, "Request failed: ${e.message}")
        }
    }
}

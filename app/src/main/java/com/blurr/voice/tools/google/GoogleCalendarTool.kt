package com.twent.voice.tools.google

import android.content.Context
import android.util.Log
import com.twent.voice.auth.GoogleAuthManager
import com.twent.voice.tools.BaseTool
import com.twent.voice.tools.ToolParameter
import com.twent.voice.tools.ToolResult
import com.google.api.client.googleapis.extensions.android.gms.auth.GoogleAccountCredential
import com.google.api.client.http.javanet.NetHttpTransport
import com.google.api.client.json.gson.GsonFactory
import com.google.api.client.util.DateTime
import com.google.api.services.calendar.Calendar
import com.google.api.services.calendar.model.Event
import com.google.api.services.calendar.model.EventAttendee
import com.google.api.services.calendar.model.EventDateTime
import com.google.api.services.calendar.model.EventReminder
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.TimeZone

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
        private const val APP_NAME = "Twent Voice Assistant"
        private const val DEFAULT_CALENDAR = "primary"
    }
    
    override val name = "google_calendar"
    override val description = "Manage Google Calendar: list events, create meetings, update schedules, check availability"
    
    override val parameters = listOf(
        ToolParameter(
            name = "action",
            type = "string",
            description = "Action: list_events, get_event, create_event, update_event, delete_event, list_calendars, check_availability, quick_add",
            required = true
        ),
        ToolParameter(
            name = "calendar_id",
            type = "string",
            description = "Calendar ID (default: 'primary' for main calendar)",
            required = false
        ),
        ToolParameter(
            name = "event_id",
            type = "string",
            description = "Event ID for get, update, delete actions",
            required = false
        ),
        ToolParameter(
            name = "time_min",
            type = "string",
            description = "Start time (ISO 8601: 2024-01-15T10:00:00-08:00 or YYYY-MM-DD)",
            required = false
        ),
        ToolParameter(
            name = "time_max",
            type = "string",
            description = "End time (ISO 8601: 2024-01-15T18:00:00-08:00 or YYYY-MM-DD)",
            required = false
        ),
        ToolParameter(
            name = "max_results",
            type = "number",
            description = "Maximum number of events (default: 10, max: 250)",
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
            description = "Event description/details",
            required = false
        ),
        ToolParameter(
            name = "location",
            type = "string",
            description = "Event location (address or virtual meeting link)",
            required = false
        ),
        ToolParameter(
            name = "start_time",
            type = "string",
            description = "Event start time (ISO 8601 or natural: '2024-01-15 10:00 AM')",
            required = false
        ),
        ToolParameter(
            name = "end_time",
            type = "string",
            description = "Event end time (ISO 8601 or natural: '2024-01-15 11:00 AM')",
            required = false
        ),
        ToolParameter(
            name = "attendees",
            type = "string",
            description = "Comma-separated email addresses of attendees",
            required = false
        ),
        ToolParameter(
            name = "reminders",
            type = "string",
            description = "Reminder minutes before event (comma-separated: '10,30' for 10 and 30 min)",
            required = false
        ),
        ToolParameter(
            name = "all_day",
            type = "boolean",
            description = "Whether event is all-day (default: false)",
            required = false
        ),
        ToolParameter(
            name = "timezone",
            type = "string",
            description = "Timezone (e.g., 'America/Los_Angeles', default: device timezone)",
            required = false
        ),
        ToolParameter(
            name = "text",
            type = "string",
            description = "Quick add text (natural language event creation)",
            required = false
        )
    )
    
    override suspend fun execute(params: Map<String, Any>, context: List<ToolResult>): ToolResult {
        return withContext(Dispatchers.IO) {
            try {
                // Check authentication
                if (!authManager.isSignedIn()) {
                    return@withContext ToolResult.failure(
                        name,
                        "Not signed in to Google. Please sign in first.",
                        mapOf("requires_auth" to true)
                    )
                }
                
                val action = getRequiredParam<String>(params, "action")
                
                // Build Calendar service
                val service = buildCalendarService()
                    ?: return@withContext ToolResult.failure(
                        name,
                        "Failed to initialize Calendar service"
                    )
                
                // Execute action
                when (action.lowercase()) {
                    "list_events" -> listEvents(service, params)
                    "get_event" -> getEvent(service, params)
                    "create_event" -> createEvent(service, params)
                    "update_event" -> updateEvent(service, params)
                    "delete_event" -> deleteEvent(service, params)
                    "list_calendars" -> listCalendars(service)
                    "check_availability" -> checkAvailability(service, params)
                    "quick_add" -> quickAddEvent(service, params)
                    else -> ToolResult.failure(
                        name,
                        "Unknown action: $action. Available: list_events, get_event, create_event, update_event, delete_event, list_calendars, check_availability, quick_add"
                    )
                }
            } catch (e: Exception) {
                Log.e(TAG, "Calendar operation failed", e)
                ToolResult.failure(name, "Calendar error: ${e.message}")
            }
        }
    }
    
    /**
     * Build Google Calendar API service
     */
    private fun buildCalendarService(): Calendar? {
        try {
            val account = authManager.getAccount() ?: return null
            
            val credential = GoogleAccountCredential.usingOAuth2(
                context,
                listOf(
                    "https://www.googleapis.com/auth/calendar",
                    "https://www.googleapis.com/auth/calendar.events"
                )
            )
            credential.selectedAccount = account
            
            return Calendar.Builder(
                NetHttpTransport(),
                GsonFactory.getDefaultInstance(),
                credential
            )
                .setApplicationName(APP_NAME)
                .build()
        } catch (e: Exception) {
            Log.e(TAG, "Failed to build Calendar service", e)
            return null
        }
    }
    
    /**
     * List upcoming events
     */
    private suspend fun listEvents(service: Calendar, params: Map<String, Any>): ToolResult {
        val calendarId = getOptionalParam(params, "calendar_id", DEFAULT_CALENDAR)
        val maxResults = getOptionalParam(params, "max_results", 10).toInt()
        
        // Default to now
        val timeMin = getOptionalParam<String?>(params, "time_min", null)?.let {
            parseDateTime(it)
        } ?: DateTime(System.currentTimeMillis())
        
        val timeMax = getOptionalParam<String?>(params, "time_max", null)?.let {
            parseDateTime(it)
        }
        
        val events = service.events().list(calendarId)
            .setMaxResults(maxResults)
            .setTimeMin(timeMin)
            .apply { if (timeMax != null) setTimeMax(timeMax) }
            .setOrderBy("startTime")
            .setSingleEvents(true)
            .execute()
        
        val eventList = events.items?.map { event ->
            extractEventData(event)
        } ?: emptyList()
        
        return ToolResult.success(
            name,
            mapOf(
                "count" to eventList.size,
                "events" to eventList,
                "calendar_id" to calendarId
            ),
            "Found ${eventList.size} events"
        )
    }
    
    /**
     * Get specific event details
     */
    private suspend fun getEvent(service: Calendar, params: Map<String, Any>): ToolResult {
        val calendarId = getOptionalParam(params, "calendar_id", DEFAULT_CALENDAR)
        val eventId = getRequiredParam<String>(params, "event_id")
        
        val event = service.events().get(calendarId, eventId).execute()
        val eventData = extractEventData(event)
        
        return ToolResult.success(
            name,
            eventData,
            "Event retrieved: ${event.summary}"
        )
    }
    
    /**
     * Create new calendar event
     */
    private suspend fun createEvent(service: Calendar, params: Map<String, Any>): ToolResult {
        val calendarId = getOptionalParam(params, "calendar_id", DEFAULT_CALENDAR)
        val summary = getRequiredParam<String>(params, "summary")
        val description = getOptionalParam<String?>(params, "description", null)
        val location = getOptionalParam<String?>(params, "location", null)
        val startTime = getRequiredParam<String>(params, "start_time")
        val endTime = getRequiredParam<String>(params, "end_time")
        val attendeesStr = getOptionalParam<String?>(params, "attendees", null)
        val remindersStr = getOptionalParam<String?>(params, "reminders", null)
        val allDay = getOptionalParam(params, "all_day", false)
        val timezone = getOptionalParam(params, "timezone", TimeZone.getDefault().id)
        
        val event = Event().apply {
            this.summary = summary
            this.description = description
            this.location = location
            
            // Set start/end times
            if (allDay) {
                start = EventDateTime().setDate(com.google.api.client.util.DateTime(startTime))
                end = EventDateTime().setDate(com.google.api.client.util.DateTime(endTime))
            } else {
                start = EventDateTime()
                    .setDateTime(parseDateTime(startTime))
                    .setTimeZone(timezone)
                end = EventDateTime()
                    .setDateTime(parseDateTime(endTime))
                    .setTimeZone(timezone)
            }
            
            // Add attendees
            if (!attendeesStr.isNullOrBlank()) {
                attendees = attendeesStr.split(",").map { email ->
                    EventAttendee().setEmail(email.trim())
                }
            }
            
            // Add reminders
            if (!remindersStr.isNullOrBlank()) {
                val reminderMinutes = remindersStr.split(",").map { it.trim().toInt() }
                reminders = Event.Reminders().apply {
                    useDefault = false
                    overrides = reminderMinutes.map { minutes ->
                        EventReminder().apply {
                            method = "popup"
                            this.minutes = minutes
                        }
                    }
                }
            }
        }
        
        val createdEvent = service.events().insert(calendarId, event).execute()
        
        return ToolResult.success(
            name,
            mapOf(
                "event_id" to createdEvent.id,
                "summary" to createdEvent.summary,
                "start" to createdEvent.start.dateTime?.toString(),
                "html_link" to createdEvent.htmlLink
            ),
            "Event created: ${createdEvent.summary}"
        )
    }
    
    /**
     * Update existing event
     */
    private suspend fun updateEvent(service: Calendar, params: Map<String, Any>): ToolResult {
        val calendarId = getOptionalParam(params, "calendar_id", DEFAULT_CALENDAR)
        val eventId = getRequiredParam<String>(params, "event_id")
        
        // Get existing event
        val event = service.events().get(calendarId, eventId).execute()
        
        // Update fields if provided
        getOptionalParam<String?>(params, "summary", null)?.let { event.summary = it }
        getOptionalParam<String?>(params, "description", null)?.let { event.description = it }
        getOptionalParam<String?>(params, "location", null)?.let { event.location = it }
        
        getOptionalParam<String?>(params, "start_time", null)?.let { startTime ->
            val timezone = getOptionalParam(params, "timezone", TimeZone.getDefault().id)
            event.start = EventDateTime()
                .setDateTime(parseDateTime(startTime))
                .setTimeZone(timezone)
        }
        
        getOptionalParam<String?>(params, "end_time", null)?.let { endTime ->
            val timezone = getOptionalParam(params, "timezone", TimeZone.getDefault().id)
            event.end = EventDateTime()
                .setDateTime(parseDateTime(endTime))
                .setTimeZone(timezone)
        }
        
        val updatedEvent = service.events().update(calendarId, eventId, event).execute()
        
        return ToolResult.success(
            name,
            mapOf(
                "event_id" to updatedEvent.id,
                "summary" to updatedEvent.summary,
                "updated" to updatedEvent.updated.toString()
            ),
            "Event updated: ${updatedEvent.summary}"
        )
    }
    
    /**
     * Delete event
     */
    private suspend fun deleteEvent(service: Calendar, params: Map<String, Any>): ToolResult {
        val calendarId = getOptionalParam(params, "calendar_id", DEFAULT_CALENDAR)
        val eventId = getRequiredParam<String>(params, "event_id")
        
        service.events().delete(calendarId, eventId).execute()
        
        return ToolResult.success(
            name,
            mapOf("event_id" to eventId, "calendar_id" to calendarId),
            "Event deleted"
        )
    }
    
    /**
     * List all calendars
     */
    private suspend fun listCalendars(service: Calendar): ToolResult {
        val calendarList = service.calendarList().list().execute()
        
        val calendars = calendarList.items?.map { calendar ->
            mapOf(
                "id" to calendar.id,
                "summary" to calendar.summary,
                "description" to (calendar.description ?: ""),
                "timezone" to calendar.timeZone,
                "primary" to (calendar.primary ?: false),
                "access_role" to calendar.accessRole
            )
        } ?: emptyList()
        
        return ToolResult.success(
            name,
            mapOf(
                "count" to calendars.size,
                "calendars" to calendars
            ),
            "Found ${calendars.size} calendars"
        )
    }
    
    /**
     * Check availability (free/busy)
     */
    private suspend fun checkAvailability(service: Calendar, params: Map<String, Any>): ToolResult {
        val calendarId = getOptionalParam(params, "calendar_id", DEFAULT_CALENDAR)
        val timeMin = getRequiredParam<String>(params, "time_min")
        val timeMax = getRequiredParam<String>(params, "time_max")
        
        val events = service.events().list(calendarId)
            .setTimeMin(parseDateTime(timeMin))
            .setTimeMax(parseDateTime(timeMax))
            .setOrderBy("startTime")
            .setSingleEvents(true)
            .execute()
        
        val busySlots = events.items?.map { event ->
            mapOf(
                "start" to event.start.dateTime?.toString(),
                "end" to event.end.dateTime?.toString(),
                "summary" to event.summary
            )
        } ?: emptyList()
        
        return ToolResult.success(
            name,
            mapOf(
                "calendar_id" to calendarId,
                "time_min" to timeMin,
                "time_max" to timeMax,
                "busy_count" to busySlots.size,
                "busy_slots" to busySlots,
                "has_availability" to busySlots.isEmpty()
            ),
            if (busySlots.isEmpty()) "Available!" else "Busy with ${busySlots.size} events"
        )
    }
    
    /**
     * Quick add event using natural language
     */
    private suspend fun quickAddEvent(service: Calendar, params: Map<String, Any>): ToolResult {
        val calendarId = getOptionalParam(params, "calendar_id", DEFAULT_CALENDAR)
        val text = getRequiredParam<String>(params, "text")
        
        val event = service.events().quickAdd(calendarId, text).execute()
        
        return ToolResult.success(
            name,
            mapOf(
                "event_id" to event.id,
                "summary" to event.summary,
                "start" to event.start?.dateTime?.toString(),
                "html_link" to event.htmlLink
            ),
            "Event created: ${event.summary}"
        )
    }
    
    /**
     * Extract event data to map
     */
    private fun extractEventData(event: Event): Map<String, Any?> {
        return mapOf(
            "event_id" to event.id,
            "summary" to event.summary,
            "description" to event.description,
            "location" to event.location,
            "start" to event.start?.dateTime?.toString() ?: event.start?.date?.toString(),
            "end" to event.end?.dateTime?.toString() ?: event.end?.date?.toString(),
            "attendees" to (event.attendees?.map { it.email } ?: emptyList()),
            "organizer" to event.organizer?.email,
            "status" to event.status,
            "html_link" to event.htmlLink,
            "hangout_link" to event.hangoutLink,
            "created" to event.created?.toString(),
            "updated" to event.updated?.toString()
        )
    }
    
    /**
     * Parse datetime string to Google DateTime
     */
    private fun parseDateTime(dateTimeStr: String): DateTime {
        return try {
            // Try ISO 8601 format first
            if (dateTimeStr.contains("T")) {
                DateTime(dateTimeStr)
            } else {
                // Try simple date format
                val sdf = SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.US)
                val date = sdf.parse(dateTimeStr)
                DateTime(date)
            }
        } catch (e: Exception) {
            // Try as date only
            try {
                val sdf = SimpleDateFormat("yyyy-MM-dd", Locale.US)
                val date = sdf.parse(dateTimeStr)
                DateTime(date)
            } catch (e2: Exception) {
                Log.e(TAG, "Failed to parse datetime: $dateTimeStr", e2)
                DateTime(System.currentTimeMillis())
            }
        }
    }
}

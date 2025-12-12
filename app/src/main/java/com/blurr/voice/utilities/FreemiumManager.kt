package com.blurr.voice.utilities

import com.android.billingclient.api.BillingClient
import com.blurr.voice.MyApplication
import com.blurr.voice.data.AppwriteDb
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.time.Instant
import java.time.ZoneOffset
import java.time.format.DateTimeFormatter

class FreemiumManager {
    private val billingClient: BillingClient = MyApplication.billingClient

    companion object {
        const val DAILY_TASK_LIMIT = 15
        private const val PRO_PLAN = "pro"
        private val ISO_INSTANT: DateTimeFormatter = DateTimeFormatter.ISO_INSTANT.withZone(ZoneOffset.UTC)
    }

    suspend fun getDeveloperMessage(): String = withContext(Dispatchers.IO) {
        // Optional: Implement a settings collection. For now, return empty to match previous behavior.
        ""
    }

    suspend fun isUserSubscribed(): Boolean = withContext(Dispatchers.IO) {
        val uid = AppwriteDb.getCurrentUserIdOrNull() ?: return@withContext false
        val doc = AppwriteDb.getUserDocumentOrNull(uid) ?: return@withContext false
        val plan = (doc.data["plan"] as? String) ?: return@withContext false
        plan.equals(PRO_PLAN, ignoreCase = true)
    }

    suspend fun provisionUserIfNeeded() = withContext(Dispatchers.IO) {
        val uid = AppwriteDb.getCurrentUserIdOrNull() ?: return@withContext
        val existing = AppwriteDb.getUserDocumentOrNull(uid)
        if (existing == null) {
            val now = ISO_INSTANT.format(Instant.now())
            val initial = mapOf(
                "plan" to "free",
                "createdAt" to now,
                "tasksRemaining" to DAILY_TASK_LIMIT,
                "tasksResetAt" to now
            )
            AppwriteDb.createUserDocument(uid, initial)
        }
    }

    private suspend fun ensureDailyReset(uid: String) {
        val doc = AppwriteDb.getUserDocumentOrNull(uid) ?: return
        val resetAtStr = doc.data["tasksResetAt"] as? String
        val lastResetDay = resetAtStr?.let { runCatching { Instant.parse(it) }.getOrNull() }?.atZone(ZoneOffset.UTC)?.toLocalDate()
        val today = Instant.now().atZone(ZoneOffset.UTC).toLocalDate()
        if (lastResetDay == null || lastResetDay.isBefore(today)) {
            val now = ISO_INSTANT.format(Instant.now())
            val update = mapOf(
                "tasksRemaining" to DAILY_TASK_LIMIT,
                "tasksResetAt" to now
            )
            AppwriteDb.updateUserDocument(uid, update)
        }
    }

    suspend fun getTasksRemaining(): Long? = withContext(Dispatchers.IO) {
        val uid = AppwriteDb.getCurrentUserIdOrNull() ?: return@withContext null
        ensureDailyReset(uid)
        val doc = AppwriteDb.getUserDocumentOrNull(uid) ?: return@withContext null
        (doc.data["tasksRemaining"] as? Number)?.toLong()
    }

    suspend fun canPerformTask(): Boolean = withContext(Dispatchers.IO) {
        val uid = AppwriteDb.getCurrentUserIdOrNull() ?: return@withContext true
        ensureDailyReset(uid)
        if (isUserSubscribed()) return@withContext true
        val remaining = getTasksRemaining() ?: return@withContext true
        remaining > 0
    }

    suspend fun decrementTaskCount() = withContext(Dispatchers.IO) {
        val uid = AppwriteDb.getCurrentUserIdOrNull() ?: return@withContext
        ensureDailyReset(uid)
        if (isUserSubscribed()) return@withContext
        val doc = AppwriteDb.getUserDocumentOrNull(uid) ?: return@withContext
        val current = (doc.data["tasksRemaining"] as? Number)?.toLong() ?: DAILY_TASK_LIMIT.toLong()
        val next = (current - 1).coerceAtLeast(0)
        val now = ISO_INSTANT.format(Instant.now())
        val update = mapOf(
            "tasksRemaining" to next,
            "tasksResetAt" to now // mark last modification; keeps rolling
        )
        AppwriteDb.updateUserDocument(uid, update)
    }
    
    /**
     * Check if user has access to Composio integrations (2,000+ tools)
     * FREE users: Google Workspace only (Gmail, Calendar, Drive)
     * PRO users: Google Workspace + Composio (2,000+ integrations)
     * 
     * Story 4.16: Subscription tier gating
     */
    suspend fun hasComposioAccess(): Boolean = withContext(Dispatchers.IO) {
        // Composio is PRO-only feature
        isUserSubscribed()
    }
}

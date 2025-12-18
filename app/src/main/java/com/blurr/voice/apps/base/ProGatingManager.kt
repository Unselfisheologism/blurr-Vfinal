package com.blurr.voice.apps.base

import android.content.Context
import android.content.SharedPreferences
/**
 * Manages Pro subscription feature gating across all AI-native apps.
 * 
 * Responsibilities:
 * - Check feature access based on subscription status
 * - Track usage limits for free tier
 * - Provide upgrade prompts when limits are reached
 * - Persist usage data across app sessions
 * 
 * Usage:
 * ```kotlin
 * val accessResult = proGatingManager.checkFeatureAccess(
 *     feature = ProFeature.OperationLimit(freeLimit = 50),
 *     currentUsage = viewModel.operationCount.value
 * )
 * 
 * when (accessResult) {
 *     is FeatureAccessResult.Allowed -> // Proceed with operation
 *     is FeatureAccessResult.LimitReached -> // Show upgrade prompt
 *     is FeatureAccessResult.ProRequired -> // Show Pro-only message
 * }
 * ```
 */
class ProGatingManager(
    private val context: Context
) {
    private val prefs: SharedPreferences by lazy {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }

    private var isProUserCached: Boolean = false

    companion object {
        private const val PREFS_NAME = "pro_gating_prefs"
        
        // Keys for different app usage tracking
        private const val KEY_TEXT_EDITOR_OPS_TODAY = "text_editor_ops_today"
        private const val KEY_TEXT_EDITOR_LAST_RESET = "text_editor_last_reset"
        
        private const val KEY_SPREADSHEETS_COUNT = "spreadsheets_count"
        
        private const val KEY_MEDIA_CANVAS_EXECS_TODAY = "media_canvas_execs_today"
        private const val KEY_MEDIA_CANVAS_LAST_RESET = "media_canvas_last_reset"
        
        private const val KEY_DAW_TRACK_COUNT = "daw_track_count"
        
        private const val KEY_LEARNING_DOC_COUNT = "learning_doc_count"
        
        private const val KEY_VIDEO_EDITOR_EXPORTS_MONTH = "video_editor_exports_month"
        private const val KEY_VIDEO_EDITOR_LAST_RESET = "video_editor_last_reset"
    }

    /**
     * Update the cached Pro subscription status.
     * Call this when subscription status changes.
     */
    fun updateSubscriptionStatus(isProUser: Boolean) {
        isProUserCached = isProUser
    }

    /**
     * Check if a feature is accessible based on subscription and usage limits.
     * 
     * @param feature The feature to check
     * @param currentUsage Current usage count (optional, for operation limits)
     * @return FeatureAccessResult indicating if access is allowed
     */
    suspend fun checkFeatureAccess(
        feature: ProFeature,
        currentUsage: Int = 0
    ): FeatureAccessResult {
        return when (feature) {
            is ProFeature.OperationLimit -> {
                checkOperationLimit(feature, currentUsage)
            }
            is ProFeature.ExclusiveFeature -> {
                checkExclusiveFeature(feature)
            }
            is ProFeature.ResourceLimit -> {
                checkResourceLimit(feature, currentUsage)
            }
        }
    }

    private fun checkOperationLimit(
        feature: ProFeature.OperationLimit,
        currentUsage: Int
    ): FeatureAccessResult {
        if (isProUserCached) {
            return FeatureAccessResult.Allowed
        }

        // Check if usage is within free limit
        if (currentUsage < feature.freeLimit) {
            return FeatureAccessResult.Allowed
        }

        return FeatureAccessResult.LimitReached(
            message = "You've reached your daily limit of ${feature.freeLimit} operations. Upgrade to Pro for unlimited access.",
            upgradeCtaText = "Upgrade to Pro",
            currentUsage = currentUsage,
            limit = feature.freeLimit
        )
    }

    private fun checkExclusiveFeature(
        feature: ProFeature.ExclusiveFeature
    ): FeatureAccessResult {
        if (isProUserCached) {
            return FeatureAccessResult.Allowed
        }

        return FeatureAccessResult.ProRequired(
            message = feature.proMessage,
            upgradeCtaText = "Upgrade to Pro"
        )
    }

    private fun checkResourceLimit(
        feature: ProFeature.ResourceLimit,
        currentUsage: Int
    ): FeatureAccessResult {
        if (isProUserCached) {
            return FeatureAccessResult.Allowed
        }

        if (currentUsage < feature.freeLimit) {
            return FeatureAccessResult.Allowed
        }

        return FeatureAccessResult.LimitReached(
            message = "You've reached the free tier limit of ${feature.freeLimit} ${feature.resourceName}. Upgrade to Pro for unlimited access.",
            upgradeCtaText = "Upgrade to Pro",
            currentUsage = currentUsage,
            limit = feature.freeLimit
        )
    }

    /**
     * Track usage for Text Editor operations (daily limit).
     */
    fun incrementTextEditorOperations(): Int {
        checkAndResetDailyCounter(KEY_TEXT_EDITOR_LAST_RESET, KEY_TEXT_EDITOR_OPS_TODAY)
        val current = prefs.getInt(KEY_TEXT_EDITOR_OPS_TODAY, 0)
        prefs.edit().putInt(KEY_TEXT_EDITOR_OPS_TODAY, current + 1).apply()
        return current + 1
    }

    fun getTextEditorOperationsToday(): Int {
        checkAndResetDailyCounter(KEY_TEXT_EDITOR_LAST_RESET, KEY_TEXT_EDITOR_OPS_TODAY)
        return prefs.getInt(KEY_TEXT_EDITOR_OPS_TODAY, 0)
    }

    /**
     * Track Spreadsheets count (persistent limit).
     */
    fun incrementSpreadsheetsCount(): Int {
        val current = prefs.getInt(KEY_SPREADSHEETS_COUNT, 0)
        prefs.edit().putInt(KEY_SPREADSHEETS_COUNT, current + 1).apply()
        return current + 1
    }

    fun getSpreadsheetsCount(): Int {
        return prefs.getInt(KEY_SPREADSHEETS_COUNT, 0)
    }

    fun decrementSpreadsheetsCount() {
        val current = prefs.getInt(KEY_SPREADSHEETS_COUNT, 0)
        if (current > 0) {
            prefs.edit().putInt(KEY_SPREADSHEETS_COUNT, current - 1).apply()
        }
    }

    /**
     * Track Media Canvas workflow executions (daily limit).
     */
    fun incrementMediaCanvasExecutions(): Int {
        checkAndResetDailyCounter(KEY_MEDIA_CANVAS_LAST_RESET, KEY_MEDIA_CANVAS_EXECS_TODAY)
        val current = prefs.getInt(KEY_MEDIA_CANVAS_EXECS_TODAY, 0)
        prefs.edit().putInt(KEY_MEDIA_CANVAS_EXECS_TODAY, current + 1).apply()
        return current + 1
    }

    fun getMediaCanvasExecutionsToday(): Int {
        checkAndResetDailyCounter(KEY_MEDIA_CANVAS_LAST_RESET, KEY_MEDIA_CANVAS_EXECS_TODAY)
        return prefs.getInt(KEY_MEDIA_CANVAS_EXECS_TODAY, 0)
    }

    /**
     * Track Learning Platform document count (persistent limit).
     */
    fun incrementLearningDocuments(): Int {
        val current = prefs.getInt(KEY_LEARNING_DOC_COUNT, 0)
        prefs.edit().putInt(KEY_LEARNING_DOC_COUNT, current + 1).apply()
        return current + 1
    }

    fun getLearningDocumentsCount(): Int {
        return prefs.getInt(KEY_LEARNING_DOC_COUNT, 0)
    }

    fun decrementLearningDocuments() {
        val current = prefs.getInt(KEY_LEARNING_DOC_COUNT, 0)
        if (current > 0) {
            prefs.edit().putInt(KEY_LEARNING_DOC_COUNT, current - 1).apply()
        }
    }

    /**
     * Track Video Editor exports (monthly limit).
     */
    fun incrementVideoEditorExports(): Int {
        checkAndResetMonthlyCounter(KEY_VIDEO_EDITOR_LAST_RESET, KEY_VIDEO_EDITOR_EXPORTS_MONTH)
        val current = prefs.getInt(KEY_VIDEO_EDITOR_EXPORTS_MONTH, 0)
        prefs.edit().putInt(KEY_VIDEO_EDITOR_EXPORTS_MONTH, current + 1).apply()
        return current + 1
    }

    fun getVideoEditorExportsThisMonth(): Int {
        checkAndResetMonthlyCounter(KEY_VIDEO_EDITOR_LAST_RESET, KEY_VIDEO_EDITOR_EXPORTS_MONTH)
        return prefs.getInt(KEY_VIDEO_EDITOR_EXPORTS_MONTH, 0)
    }

    /**
     * Check if daily counter needs reset (new day).
     */
    private fun checkAndResetDailyCounter(lastResetKey: String, counterKey: String) {
        val lastReset = prefs.getLong(lastResetKey, 0L)
        val today = System.currentTimeMillis() / (24 * 60 * 60 * 1000) // Days since epoch
        val lastResetDay = lastReset / (24 * 60 * 60 * 1000)

        if (today > lastResetDay) {
            prefs.edit()
                .putInt(counterKey, 0)
                .putLong(lastResetKey, System.currentTimeMillis())
                .apply()
        }
    }

    /**
     * Check if monthly counter needs reset (new month).
     */
    private fun checkAndResetMonthlyCounter(lastResetKey: String, counterKey: String) {
        val lastReset = prefs.getLong(lastResetKey, 0L)
        val now = System.currentTimeMillis()
        
        val lastResetCalendar = java.util.Calendar.getInstance().apply {
            timeInMillis = lastReset
        }
        val nowCalendar = java.util.Calendar.getInstance().apply {
            timeInMillis = now
        }

        val isDifferentMonth = lastResetCalendar.get(java.util.Calendar.MONTH) != nowCalendar.get(java.util.Calendar.MONTH) ||
                lastResetCalendar.get(java.util.Calendar.YEAR) != nowCalendar.get(java.util.Calendar.YEAR)

        if (isDifferentMonth) {
            prefs.edit()
                .putInt(counterKey, 0)
                .putLong(lastResetKey, now)
                .apply()
        }
    }
}

/**
 * Represents different types of Pro features.
 */
sealed class ProFeature {
    /**
     * Feature with daily/periodic operation limits.
     * @param freeLimit Number of operations allowed in free tier
     */
    data class OperationLimit(val freeLimit: Int) : ProFeature()

    /**
     * Feature exclusively for Pro users.
     * @param proMessage Message to display when free users try to access
     */
    data class ExclusiveFeature(val proMessage: String) : ProFeature()

    /**
     * Feature with resource limits (e.g., number of documents, tracks).
     * @param freeLimit Number of resources allowed in free tier
     * @param resourceName Name of the resource (for display in messages)
     */
    data class ResourceLimit(val freeLimit: Int, val resourceName: String) : ProFeature()
}

/**
 * Result of feature access check.
 */
sealed class FeatureAccessResult {
    /**
     * Feature is accessible.
     */
    object Allowed : FeatureAccessResult()

    /**
     * Usage limit reached.
     */
    data class LimitReached(
        val message: String,
        val upgradeCtaText: String,
        val currentUsage: Int,
        val limit: Int
    ) : FeatureAccessResult()

    /**
     * Feature requires Pro subscription.
     */
    data class ProRequired(
        val message: String,
        val upgradeCtaText: String
    ) : FeatureAccessResult()
}

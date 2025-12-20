package com.twent.voice.apps.base

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import com.twent.voice.ui.theme.TwentTheme
import com.twent.voice.utilities.FreemiumManager
/**
 * Base Activity for all AI-native apps.
 * 
 * Provides:
 * - Common navigation patterns
 * - Pro gating integration
 * - Consistent theme and styling
 * - Lifecycle management
 * - Agent integration support
 * 
 * Usage: Extend this class for each app-specific activity.
 * 
 * Example:
 * ```kotlin
 * class TextEditorActivity : BaseAppActivity() {
 *     override fun onCreate(savedInstanceState: Bundle?) {
 *         super.onCreate(savedInstanceState)
 *         setupAppContent()
 *     }
 *     
 *     override fun setupAppContent() {
 *         setContent {
 *             AppContent {
 *                 TextEditorScreen()
 *             }
 *         }
 *     }
 * }
 * ```
 */
abstract class BaseAppActivity : ComponentActivity() {

    protected lateinit var freemiumManager: FreemiumManager
    protected lateinit var proGatingManager: ProGatingManager

    /**
     * Check if user has Pro subscription.
     */
    protected val isProUser: Boolean
        get() = freemiumManager.hasActiveSubscription()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Initialize managers
        freemiumManager = FreemiumManager(this)
        proGatingManager = ProGatingManager(this)
        
        // Update Pro gating manager with current subscription status
        proGatingManager.updateSubscriptionStatus(isProUser)
        
        // Subclasses should call setupAppContent() here
    }

    /**
     * Set up the app-specific Compose content.
     * Must be implemented by subclasses.
     */
    abstract fun setupAppContent()

    /**
     * Wrapper for app content with common theme and scaffolding.
     * Use this in your setContent {} block.
     */
    @Composable
    protected fun AppContent(
        topBar: @Composable () -> Unit = {},
        floatingActionButton: @Composable () -> Unit = {},
        content: @Composable (PaddingValues) -> Unit
    ) {
        TwentTheme {
            Scaffold(
                topBar = topBar,
                floatingActionButton = floatingActionButton,
                containerColor = MaterialTheme.colorScheme.background
            ) { paddingValues ->
                content(paddingValues)
            }
        }
    }

    /**
     * Show Pro upgrade prompt dialog.
     * Use this when a Pro-only feature is accessed.
     */
    @Composable
    protected fun ProUpgradePrompt(
        message: String,
        onDismiss: () -> Unit,
        onUpgrade: () -> Unit
    ) {
        AlertDialog(
            onDismissRequest = onDismiss,
            title = { Text("Upgrade to Pro") },
            text = { Text(message) },
            confirmButton = {
                Button(onClick = onUpgrade) {
                    Text("Upgrade")
                }
            },
            dismissButton = {
                TextButton(onClick = onDismiss) {
                    Text("Not Now")
                }
            }
        )
    }

    /**
     * Navigate to Pro purchase screen.
     */
    protected fun navigateToProPurchase() {
        // TODO: Navigate to ProPurchaseActivity
        // startActivity(Intent(this, ProPurchaseActivity::class.java))
    }

    /**
     * Check if a feature is accessible based on Pro status.
     * Shows upgrade prompt if not accessible.
     * 
     * @return true if feature is accessible, false otherwise
     */
    protected suspend fun checkFeatureAccess(
        feature: ProFeature,
        currentUsage: Int = 0
    ): FeatureAccessResult {
        return proGatingManager.checkFeatureAccess(feature, currentUsage)
    }
}

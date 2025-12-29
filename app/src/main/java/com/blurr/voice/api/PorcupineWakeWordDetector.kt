package com.blurr.voice.api

import android.content.Context
import android.util.Log
import com.blurr.voice.core.providers.ProviderKeyManager
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class PorcupineWakeWordDetector(
    private val context: Context,
    private val onWakeWordDetected: () -> Unit,
    private val onApiFailure: () -> Unit
) {
    private var isListening = false
    private val keyManager = ProviderKeyManager(context)
    private var coroutineScope: CoroutineScope? = null

    companion object {
        private const val TAG = "PorcupineWakeWordDetector"
    }

    fun start() {
        if (isListening) {
            Log.d(TAG, "Already started.")
            return
        }

        // Create a new coroutine scope for this start operation
        coroutineScope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

        // Check if user has configured API keys
        val (isValid, errorMessage) = keyManager.validateConfiguration()
        if (!isValid) {
            Log.e(TAG, "API configuration invalid: $errorMessage")
            onApiFailure()
            return
        }

        // For now, we'll trigger the success callback to continue using the existing STT-based detection
        // In a real implementation, we would use the user's API key for a cloud-based wake word detection
        // But since wake word detection is typically done locally for performance/privacy reasons,
        // we'll just validate the configuration and continue with the existing STT approach
        Log.d(TAG, "API configuration validated successfully")
        onApiFailure() // Trigger fallback to STT-based detection since we're not implementing cloud wake word detection
    }

    fun stop() {
        if (!isListening) {
            Log.d(TAG, "Already stopped.")
            return
        }

        try {
            isListening = false
            Log.d(TAG, "Wake word detection stopped.")
            
            // Cancel the coroutine scope
            coroutineScope?.cancel()
            coroutineScope = null
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping wake word detection: ${e.message}")
        }
    }
}
package com.twent.voice.api

import android.content.Context
import android.media.AudioManager
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.twent.voice.utilities.STTManager
import com.twent.voice.core.providers.ProviderKeyManager
import java.util.Locale

class WakeWordDetector(
    private val context: Context,
    private val onWakeWordDetected: () -> Unit
) {
    private var sttManager: STTManager? = null
    private val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    private val wakeWord = "Panda"
    private var isListening = false
    private val handler = Handler(Looper.getMainLooper())
    private val restartDelayMs = 250L

    fun start() {
        if (isListening) {
            Log.d("WakeWordDetector", "Already started.")
            return
        }
        
        // Check if user has configured API keys for voice features
        val keyManager = ProviderKeyManager(context)
        val (isValid, errorMessage) = keyManager.validateConfiguration()
        
        if (!isValid) {
            Log.w("WakeWordDetector", "API configuration invalid: $errorMessage - Using local STT only")
        } else {
            Log.d("WakeWordDetector", "API configuration valid - STT features available")
        }
        
        isListening = true
        Log.d("WakeWordDetector", "Starting to listen for wake word.")
        startContinuousListening()
    }

    fun stop() {
        if (!isListening) {
            Log.d("WakeWordDetector", "Already stopped.")
            return
        }
        isListening = false
        handler.removeCallbacksAndMessages(null)
        sttManager?.stopListening()
        sttManager?.shutdown()

        // Ensure the sound is unmuted when the service is stopped
        audioManager.adjustStreamVolume(AudioManager.STREAM_NOTIFICATION, AudioManager.ADJUST_UNMUTE, 0)
        Log.d("WakeWordDetector", "Stopped listening for wake word.")
    }

    private fun startContinuousListening() {
        if (!isListening) return

        // Initialize STT manager if needed
        if (sttManager == null) {
            sttManager = STTManager(context)
        }

        // Mute the notification stream to prevent the startup chime
        audioManager.adjustStreamVolume(AudioManager.STREAM_NOTIFICATION, AudioManager.ADJUST_MUTE, 0)

        sttManager?.startListening(
            onResult = { recognizedText ->
                Log.d("WakeWordDetector", "Recognized: '$recognizedText'")
                if (recognizedText.lowercase(Locale.ROOT).contains(wakeWord.lowercase(Locale.ROOT))) {
                    Log.d("WakeWordDetector", "Wake word detected: '$recognizedText'")
                    onWakeWordDetected()
                }
                restartListening()
            },
            onError = { errorMessage ->
                Log.e("WakeWordDetector", "STT Error: $errorMessage")
                restartListening()
            },
            onListeningStateChange = { },
            onPartialResult = { }
        )

        // Unmute the stream shortly after starting to ensure other notifications can be heard
        handler.postDelayed({
            audioManager.adjustStreamVolume(AudioManager.STREAM_NOTIFICATION, AudioManager.ADJUST_UNMUTE, 0)
        }, 500) // 500ms is enough time to suppress the chime
    }

    private fun restartListening() {
        if (!isListening) return
        handler.postDelayed({
            sttManager?.stopListening()
            startContinuousListening()
        }, restartDelayMs)
    }
}
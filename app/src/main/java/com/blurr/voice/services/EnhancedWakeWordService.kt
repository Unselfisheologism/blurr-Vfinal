package com.twent.voice.services

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.IBinder
import android.util.Log
import android.widget.Toast
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import com.twent.voice.ConversationalAgentService
import com.twent.voice.MainActivity
import com.twent.voice.R
import com.twent.voice.api.WakeWordDetector
import com.twent.voice.core.providers.ProviderKeyManager
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob

class EnhancedWakeWordService : Service() {

    private var wakeWordDetector: WakeWordDetector? = null
    private var usePorcupine = false
    private val serviceScope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    companion object {
        const val CHANNEL_ID = "EnhancedWakeWordServiceChannel"
        var isRunning = false
        const val ACTION_WAKE_WORD_FAILED = "com.twent.voice.WAKE_WORD_FAILED"
        const val EXTRA_USE_PORCUPINE = "use_porcupine"
    }

    override fun onCreate() {
        super.onCreate()
        isRunning = true
        Log.d("EnhancedWakeWordService", "Service onCreate() called, isRunning set to true")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d("EnhancedWakeWordService", "Service starting...")
        
        // Check if we have the required RECORD_AUDIO permission
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
            Log.e("EnhancedWakeWordService", "RECORD_AUDIO permission not granted. Cannot start foreground service.")
            Toast.makeText(this, "Microphone permission required for wake word", Toast.LENGTH_LONG).show()
            // Make sure to reset the isRunning flag
            isRunning = false
            stopSelf()
            return START_NOT_STICKY
        }
        
        usePorcupine = intent?.getBooleanExtra(EXTRA_USE_PORCUPINE, false) ?: false
        
        createNotificationChannel()

        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            notificationIntent,
            PendingIntent.FLAG_IMMUTABLE
        )

        val engineName = if (usePorcupine) "STT" else "STT"
        val notification: Notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Twent Wake Word")
            .setContentText("Listening for 'Panda' with STT engine...")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(pendingIntent)
            .build()

        try {
            startForeground(1338, notification)
        } catch (e: SecurityException) {
            Log.e("EnhancedWakeWordService", "Failed to start foreground service: ${e.message}")
            Toast.makeText(this, "Cannot start wake word service - permission missing", Toast.LENGTH_LONG).show()
            // Make sure to reset the isRunning flag
            isRunning = false
            stopSelf()
            return START_NOT_STICKY
        }

        // Start the appropriate wake word detector
        startWakeWordDetection()

        return START_STICKY
    }

    private fun startWakeWordDetection() {
        val onWakeWordDetected: () -> Unit = {
            // Check if the conversational agent isn't already running
            if (!ConversationalAgentService.isRunning) {
                val serviceIntent = Intent(this, ConversationalAgentService::class.java)
                ContextCompat.startForegroundService(this, serviceIntent)

                Toast.makeText(this, "Panda listening...", Toast.LENGTH_SHORT).show()
            } else {
                Log.d("EnhancedWakeWordService", "Conversational agent is already running.")
            }
        }

        val onApiFailure: () -> Unit = {
            Log.d("EnhancedWakeWordService", "STT API failed, starting floating button service")
            // Start the floating button service when API fails
            val intent = Intent(ACTION_WAKE_WORD_FAILED)
            sendBroadcast(intent)
            stopSelf()
        }

        try {
            // Check if user has configured API keys
            val keyManager = ProviderKeyManager(this)
            val (isValid, errorMessage) = keyManager.validateConfiguration()
            
            if (!isValid) {
                Log.e("EnhancedWakeWordService", "API configuration invalid: $errorMessage")
                // Use STT-based detection which works locally without API keys
                Log.d("EnhancedWakeWordService", "Using STT wake word detection (local, no API key needed)")
                wakeWordDetector = WakeWordDetector(this, onWakeWordDetected)
                wakeWordDetector?.start()
            } else {
                // User has API keys configured, but we still use STT for wake word detection
                // (wake word detection typically runs locally for performance/privacy)
                Log.d("EnhancedWakeWordService", "Using STT wake word detection (local)")
                wakeWordDetector = WakeWordDetector(this, onWakeWordDetected)
                wakeWordDetector?.start()
            }
        } catch (e: Exception) {
            Log.e("EnhancedWakeWordService", "Error starting wake word detection: ${e.message}")
            // If there's any error, start the floating button service
            onApiFailure()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        
        Log.d("EnhancedWakeWordService", "Service onDestroy() called")
        
        wakeWordDetector?.stop()
        wakeWordDetector = null
        
        isRunning = false
        Log.d("EnhancedWakeWordService", "Service destroyed, isRunning set to false")
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Enhanced Wake Word Service Channel",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }
}
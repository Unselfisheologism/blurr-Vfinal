package com.twent.voice

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.os.Binder
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.speech.tts.TextToSpeech
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleService
import androidx.lifecycle.lifecycleScope
import com.twent.voice.data.AppwriteDb
import com.twent.voice.utilities.*
import com.twent.voice.v2.AgentService
import com.twent.voice.v2.Agent
import com.twent.voice.v2.PromptBuilder
import com.twent.voice.core.providers.UniversalLLMService
import com.twent.voice.agents.UltraGeneralistAgent
import com.twent.voice.auth.GoogleAuthManager
import com.twent.voice.data.UserPreferences
import com.twent.voice.overlay.OverlayManager
import com.twent.voice.overlay.TranscriptionViewManager
import com.twent.voice.overlay.VisualFeedbackManager
import com.twent.voice.v2.perception.Perception
import com.twent.voice.v2.perception.ScreenAnalysis
import com.twent.voice.v2.perception.SemanticParser
import com.twent.voice.intents.IntentRegistry
import com.twent.voice.intents.AppIntent
import com.twent.voice.intents.impl.DialIntent
import com.twent.voice.intents.impl.EmailComposeIntent
import com.twent.voice.intents.impl.ShareTextIntent
import com.twent.voice.intents.impl.ViewUrlIntent
import com.google.firebase.auth.FirebaseAuth
import com.twent.voice.data.MemoryExtractor
import com.twent.voice.data.Memory
import com.twent.voice.data.MemoryRepository
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import java.time.Instant
import java.time.format.DateTimeFormatter
import java.util.*

class ConversationalAgentService : LifecycleService() {

    companion object {
        private const val TAG = "ConvAgent"
        private const val NOTIFICATION_ID = 1001
        private const val CHANNEL_ID = "conversation_agent_channel"
        private const val WAKE_WORD = "Hey Panda"
        private const val MAX_CONVERSATION_HISTORY = 50
        private const val MAX_RETRIES = 3
        private const val RETRY_DELAY_MS = 2000L
    }

    private val binder = LocalBinder()
    private var isRunning = false
    private var isInitialized = false
    private var isListening = false
    private var isTextModeActive = false
    
    // Speech recognition and TTS
    private var speechRecognizer: SpeechRecognizer? = null
    private var textToSpeech: TextToSpeech? = null
    private var audioManager: AudioManager? = null
    private var audioFocusRequest: AudioFocusRequest? = null
    
    // Core components
    private var agentService: AgentService? = null
    private var universalLLMService: UniversalLLMService? = null
    private var ultraGeneralistAgent: UltraGeneralistAgent? = null
    private var promptBuilder: PromptBuilder? = null
    private var perception: Perception? = null
    private var screenAnalysis: ScreenAnalysis? = null
    private var semanticParser: SemanticParser? = null
    
    // State management
    private var conversationId: String? = null
    private var conversationHistory = mutableListOf<Pair<String, String>>()
    private var clarificationAttempts = 0
    private var sttErrorAttempts = 0
    private var currentRetryCount = 0
    
    // UI overlays
    private var overlayManager: OverlayManager? = null
    private var transcriptionViewManager: TranscriptionViewManager? = null
    private var visualFeedbackManager: VisualFeedbackManager? = null
    
    // State managers
    private var pandaStateManager: PandaStateManager? = null
    private var wakeWordManager: WakeWordManager? = null
    
    // Data
    private val serviceScope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    private val auth = FirebaseAuth.getInstance()
    private val googleAuthManager by lazy { GoogleAuthManager(this) }
    private val userPreferences by lazy { UserPreferences(this) }
    private val memoryExtractor by lazy { MemoryExtractor(this) }
    private val memoryRepository by lazy { MemoryRepository(this) }
    
    // Broadcast receivers
    private var voiceCommandReceiver: BroadcastReceiver? = null
    private var overlayActionReceiver: BroadcastReceiver? = null
    
    // UI state
    private val _isListening = MutableStateFlow(false)
    val isListeningState: StateFlow<Boolean> = _isListening.asStateFlow()
    
    private val _isProcessing = MutableStateFlow(false)
    val isProcessingState: StateFlow<Boolean> = _isProcessing.asStateFlow()
    
    private val _currentState = MutableStateFlow(PandaState.IDLE)
    val currentState: StateFlow<PandaState> = _currentState.asStateFlow()

    inner class LocalBinder : Binder() {
        fun getService(): ConversationalAgentService = this@ConversationalAgentService
    }

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service onCreate")
        createNotificationChannel()
        initializeComponents()
        registerReceivers()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        super.onStartCommand(intent, flags, startId)
        Log.d(TAG, "Service onStartCommand: ${intent?.action}")
        
        when (intent?.action) {
            "START_LISTENING" -> startListening()
            "STOP_LISTENING" -> stopListening()
            "TOGGLE_LISTENING" -> toggleListening()
            "TEXT_MODE" -> enterTextMode()
            "VOICE_MODE" -> enterVoiceMode()
            else -> startForegroundService()
        }
        
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        super.onBind(intent)
        return binder
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "Service onDestroy")
        
        overlayManager?.stopObserving()
        
        // Track conversation end if not already tracked
        if (conversationId != null) {
            trackConversationEnd("service_destroyed")
        }
        
        removeClarificationQuestions()
        serviceScope.cancel()
        isRunning = false
        
        // Stop state monitoring and set final state
        pandaStateManager?.setState(PandaState.IDLE)
        pandaStateManager?.stopMonitoring()
        visualFeedbackManager?.hideSmallDeltaGlow()
        visualFeedbackManager?.hideSpeakingOverlay()
        visualFeedbackManager?.hideTtsWave()
        visualFeedbackManager?.hideTranscription()
        visualFeedbackManager?.hideInputBox()

        unregisterReceivers()
        cleanupComponents()
    }

    /**
     * Initialize all service components
     */
    private fun initializeComponents() {
        if (isInitialized) return
        
        try {
            // Initialize audio components
            audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            initializeSpeechRecognition()
            initializeTextToSpeech()
            
            // Initialize AI components
            universalLLMService = UniversalLLMService(this)
            ultraGeneralistAgent = UltraGeneralistAgent(this, universalLLMService!!)
            promptBuilder = PromptBuilder()
            
            // Initialize perception components
            perception = Perception(this)
            screenAnalysis = ScreenAnalysis(this)
            semanticParser = SemanticParser()
            
            // Initialize overlay managers
            overlayManager = OverlayManager(this)
            transcriptionViewManager = TranscriptionViewManager(this)
            visualFeedbackManager = VisualFeedbackManager(this)
            
            // Initialize state managers
            pandaStateManager = PandaStateManager(this)
            wakeWordManager = WakeWordManager(this)
            
            // Initialize agent service
            agentService = AgentService(this)
            
            // Generate conversation ID
            conversationId = UUID.randomUUID().toString()
            
            isInitialized = true
            Log.d(TAG, "All components initialized successfully")
            
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize components", e)
        }
    }

    /**
     * Initialize speech recognition
     */
    private fun initializeSpeechRecognition() {
        if (SpeechRecognizer.isRecognitionAvailable(this)) {
            speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this)
            speechRecognizer?.setRecognitionListener(object : RecognitionListener {
                override fun onReadyForSpeech(params: Bundle?) {
                    Log.d(TAG, "Ready for speech")
                    _isListening.value = true
                    visualFeedbackManager?.showListeningIndicator()
                }

                override fun onBeginningOfSpeech() {
                    Log.d(TAG, "Beginning of speech")
                }

                override fun onRmsChanged(rmsdB: Float) {
                    // Update visual feedback for speech level
                    visualFeedbackManager?.updateSpeechLevel(rmsdB)
                }

                override fun onBufferReceived(buffer: ByteArray?) {
                    // Not used for now
                }

                override fun onEndOfSpeech() {
                    Log.d(TAG, "End of speech")
                    _isListening.value = false
                    visualFeedbackManager?.hideListeningIndicator()
                }

                override fun onError(error: Int) {
                    Log.e(TAG, "Speech recognition error: $error")
                    handleSpeechError(error)
                }

                override fun onResults(results: Bundle?) {
                    val matches = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                    if (!matches.isNullOrEmpty()) {
                        val recognizedText = matches[0]
                        Log.d(TAG, "Speech recognition result: $recognizedText")
                        processVoiceInput(recognizedText)
                    }
                }

                override fun onPartialResults(partialResults: Bundle?) {
                    val matches = partialResults?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                    if (!matches.isNullOrEmpty()) {
                        val partialText = matches[0]
                        transcriptionViewManager?.updateTranscription(partialText)
                    }
                }

                override fun onEvent(eventType: Int, params: Bundle?) {
                    Log.d(TAG, "Speech recognition event: $eventType")
                }
            })
        }
    }

    /**
     * Initialize text-to-speech
     */
    private fun initializeTextToSpeech() {
        textToSpeech = TextToSpeech(this) { status ->
            if (status == TextToSpeech.SUCCESS) {
                textToSpeech?.language = Locale.getDefault()
                Log.d(TAG, "TTS initialized successfully")
            } else {
                Log.e(TAG, "TTS initialization failed")
            }
        }
    }

    /**
     * Start listening for voice input
     */
    private fun startListening() {
        if (!isInitialized || speechRecognizer == null) {
            Log.e(TAG, "Service not initialized or speech recognizer not available")
            return
        }

        if (isListening) {
            Log.d(TAG, "Already listening")
            return
        }

        try {
            requestAudioFocus()
            
            val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
                putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
                putExtra(RecognizerIntent.EXTRA_LANGUAGE, Locale.getDefault())
                putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
                putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1)
            }
            
            speechRecognizer?.startListening(intent)
            isListening = true
            _isListening.value = true
            
            visualFeedbackManager?.showListeningIndicator()
            transcriptionViewManager?.showTranscriptionView()
            
            Log.d(TAG, "Started listening")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start listening", e)
        }
    }

    /**
     * Stop listening
     */
    private fun stopListening() {
        if (speechRecognizer != null) {
            speechRecognizer?.stopListening()
        }
        isListening = false
        _isListening.value = false
        
        abandonAudioFocus()
        visualFeedbackManager?.hideListeningIndicator()
        transcriptionViewManager?.hideTranscriptionView()
        
        Log.d(TAG, "Stopped listening")
    }

    /**
     * Toggle listening state
     */
    private fun toggleListening() {
        if (isListening) {
            stopListening()
        } else {
            startListening()
        }
    }

    /**
     * Enter text mode for manual input
     */
    private fun enterTextMode() {
        isTextModeActive = true
        stopListening()
        visualFeedbackManager?.showTextInputMode()
        Log.d(TAG, "Entered text mode")
    }

    /**
     * Enter voice mode
     */
    private fun enterVoiceMode() {
        isTextModeActive = false
        visualFeedbackManager?.showVoiceInputMode()
        Log.d(TAG, "Entered voice mode")
    }

    /**
     * Process voice input
     */
    private fun processVoiceInput(input: String) {
        if (input.isBlank()) return
        
        serviceScope.launch {
            try {
                _isProcessing.value = true
                visualFeedbackManager?.showProcessingIndicator()
                
                // Add to conversation history
                conversationHistory.add("user" to input)
                if (conversationHistory.size > MAX_CONVERSATION_HISTORY) {
                    conversationHistory.removeAt(0)
                }
                
                // Process with AI agent
                val response = ultraGeneralistAgent?.processRequest(
                    input,
                    buildContext()
                ) ?: "Sorry, I couldn't process that request."
                
                // Add AI response to history
                conversationHistory.add("assistant" to response)
                
                // Speak response
                speakResponse(response)
                
                // Update UI
                transcriptionViewManager?.updateTranscription(response)
                
                Log.d(TAG, "Processed voice input: $input -> $response")
            } catch (e: Exception) {
                Log.e(TAG, "Error processing voice input", e)
                speakResponse("Sorry, I encountered an error. Please try again.")
            } finally {
                _isProcessing.value = false
                visualFeedbackManager?.hideProcessingIndicator()
            }
        }
    }

    /**
     * Speak text response
     */
    private fun speakResponse(text: String) {
        if (textToSpeech != null && !text.isBlank()) {
            textToSpeech?.speak(text, TextToSpeech.QUEUE_FLUSH, null, "utteranceId")
            visualFeedbackManager?.showSpeakingOverlay(text)
        }
    }

    /**
     * Build context for AI processing
     */
    private fun buildContext(): String {
        val context = StringBuilder()
        context.append("Current time: ${DateTimeFormatter.ISO_INSTANT.format(Instant.now())}\n")
        context.append("User preferences: ${userPreferences.getAllPreferences()}\n")
        
        // Add recent conversation history
        if (conversationHistory.isNotEmpty()) {
            context.append("Recent conversation:\n")
            conversationHistory.takeLast(10).forEach { (role, message) ->
                context.append("$role: $message\n")
            }
        }
        
        // Add relevant memories
        serviceScope.launch {
            try {
                val relevantMemories = memoryExtractor.extractRelevantMemories(conversationHistory.lastOrNull()?.second ?: "")
                context.append("Relevant memories:\n")
                relevantMemories.forEach { memory ->
                    context.append("- ${memory.content}\n")
                }
            } catch (e: Exception) {
                Log.e(TAG, "Failed to extract memories", e)
            }
        }
        
        return context.toString()
    }

    /**
     * Handle speech recognition errors
     */
    private fun handleSpeechError(error: Int) {
        sttErrorAttempts++
        
        when (error) {
            SpeechRecognizer.ERROR_NETWORK_TIMEOUT,
            SpeechRecognizer.ERROR_NETWORK -> {
                Log.e(TAG, "Network error in speech recognition")
                if (sttErrorAttempts < MAX_RETRIES) {
                    serviceScope.launch {
                        delay(RETRY_DELAY_MS)
                        startListening()
                    }
                } else {
                    speakResponse("Network connection issue. Please check your internet connection.")
                }
            }
            SpeechRecognizer.ERROR_NO_MATCH -> {
                Log.w(TAG, "No speech match found")
                if (clarificationAttempts < 2) {
                    clarificationAttempts++
                    speakResponse("I didn't catch that. Could you please repeat?")
                    startListening()
                } else {
                    speakResponse("I'm having trouble understanding. You can try typing instead.")
                    enterTextMode()
                }
            }
            else -> {
                Log.e(TAG, "Speech recognition error: $error")
                speakResponse("Sorry, I had trouble processing your speech. Please try again.")
            }
        }
    }

    /**
     * Remove clarification questions from UI
     */
    private fun removeClarificationQuestions() {
        visualFeedbackManager?.clearClarificationQuestions()
    }

    /**
     * Start foreground service with notification
     */
    private fun startForegroundService() {
        val notification = createNotification()
        startForeground(NOTIFICATION_ID, notification)
        isRunning = true
        
        // Start state monitoring
        pandaStateManager?.startMonitoring()
        
        Log.d(TAG, "Foreground service started")
    }

    /**
     * Create notification for foreground service
     */
    private fun createNotification(): Notification {
        val intent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent, 
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Twent AI Assistant")
            .setContentText("AI assistant is ready")
            .setSmallIcon(R.drawable.panda_logo_v1_512)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .build()
    }

    /**
     * Create notification channel for Android O and above
     */
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Conversation Agent",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "AI Assistant notification channel"
                setShowBadge(false)
                enableLights(false)
                enableVibration(false)
            }
            
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    /**
     * Request audio focus for speech recognition
     */
    private fun requestAudioFocus() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            audioFocusRequest = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
                .setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ASSISTANT)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                        .build()
                )
                .setAcceptsDelayedFocusGain(true)
                .setOnAudioFocusChangeListener { }
                .build()
            
            audioManager?.requestAudioFocus(audioFocusRequest!!)
        } else {
            @Suppress("DEPRECATION")
            audioManager?.requestAudioFocus(
                { },
                AudioManager.STREAM_MUSIC,
                AudioManager.AUDIOFOCUS_GAIN
            )
        }
    }

    /**
     * Abandon audio focus
     */
    private fun abandonAudioFocus() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && audioFocusRequest != null) {
            audioManager?.abandonAudioFocusRequest(audioFocusRequest!!)
        } else {
            @Suppress("DEPRECATION")
            audioManager?.abandonAudioFocus { }
        }
    }

    /**
     * Track conversation end for analytics
     */
    private fun trackConversationEnd(endReason: String, tasksRequested: Int = 0, tasksExecuted: Int = 0) {
        val currentUser = auth.currentUser
        if (currentUser == null || conversationId == null) {
            return
        }

        serviceScope.launch {
            try {
                val completionEntry = mapOf(
                    "conversationId" to conversationId,
                    "endedAt" to DateTimeFormatter.ISO_INSTANT.format(Instant.now()),
                    "messageCount" to conversationHistory.size,
                    "textModeUsed" to isTextModeActive,
                    "clarificationAttempts" to clarificationAttempts,
                    "sttErrorAttempts" to sttErrorAttempts,
                    "endReason" to endReason,
                    "tasksRequested" to tasksRequested,
                    "tasksExecuted" to tasksExecuted,
                    "status" to "completed"
                )

                // Append the completion status to the user's conversationHistory array
                AppwriteDb.appendToUserArrayField(currentUser.uid, "conversationHistory", completionEntry)

                Log.d(TAG, "Tracked conversation end: $conversationId ($endReason)")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to track conversation end", e)
            }
        }
    }

    /**
     * Register broadcast receivers
     */
    private fun registerReceivers() {
        // Voice command receiver
        voiceCommandReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                when (intent?.action) {
                    "START_LISTENING" -> startListening()
                    "STOP_LISTENING" -> stopListening()
                    "TOGGLE_LISTENING" -> toggleListening()
                }
            }
        }
        
        val voiceFilter = IntentFilter().apply {
            addAction("START_LISTENING")
            addAction("STOP_LISTENING")
            addAction("TOGGLE_LISTENING")
        }
        registerReceiver(voiceCommandReceiver, voiceFilter)
        
        // Overlay action receiver
        overlayActionReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                when (intent?.action) {
                    "TEXT_MODE" -> enterTextMode()
                    "VOICE_MODE" -> enterVoiceMode()
                    "CLARIFY" -> {
                        clarificationAttempts++
                        speakResponse("Could you please clarify your request?")
                    }
                }
            }
        }
        
        val overlayFilter = IntentFilter().apply {
            addAction("TEXT_MODE")
            addAction("VOICE_MODE")
            addAction("CLARIFY")
        }
        registerReceiver(overlayActionReceiver, overlayFilter)
    }

    /**
     * Unregister broadcast receivers
     */
    private fun unregisterReceivers() {
        voiceCommandReceiver?.let { unregisterReceiver(it) }
        overlayActionReceiver?.let { unregisterReceiver(it) }
    }

    /**
     * Clean up components
     */
    private fun cleanupComponents() {
        speechRecognizer?.destroy()
        textToSpeech?.shutdown()
        agentService?.stop()
        
        speechRecognizer = null
        textToSpeech = null
        agentService = null
        universalLLMService = null
        ultraGeneralistAgent = null
        promptBuilder = null
        perception = null
        screenAnalysis = null
        semanticParser = null
        overlayManager = null
        transcriptionViewManager = null
        visualFeedbackManager = null
        pandaStateManager = null
        wakeWordManager = null
        
        isInitialized = false
    }
}
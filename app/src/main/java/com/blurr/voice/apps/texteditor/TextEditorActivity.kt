package com.blurr.voice.apps.texteditor

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.blurr.voice.R
import com.blurr.voice.agents.AgentFactory
import com.blurr.voice.agents.UltraGeneralistAgent
import com.blurr.voice.apps.base.AgentIntegration
import com.blurr.voice.apps.base.AgentResult
import com.blurr.voice.apps.base.ProGatingManager
import com.blurr.voice.apps.base.SystemPrompts
import com.blurr.voice.core.providers.UniversalLLMService
import com.blurr.voice.utilities.FreemiumManager
import io.flutter.embedding.android.FlutterFragment
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/**
 * Host Activity for AI-Native Text Editor (Flutter)
 * 
 * This activity hosts the Flutter TextEditorScreen and provides
 * platform channel integration for AI assistance operations.
 */
class TextEditorActivity : AppCompatActivity() {
    
    companion object {
        private const val FLUTTER_ENGINE_ID = "text_editor_engine"
        private const val AI_ASSISTANCE_CHANNEL = "ai_assistance"
        private const val TEXT_EDITOR_ROUTE = "/text_editor"
    }

    private lateinit var freemiumManager: FreemiumManager
    private lateinit var proGatingManager: ProGatingManager
    private lateinit var agentIntegration: AgentIntegration
    private lateinit var llmService: UniversalLLMService
    private lateinit var agent: UltraGeneralistAgent

    private var flutterEngine: FlutterEngine? = null
    private var aiAssistanceChannel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_text_editor)

        // Initialize managers
        freemiumManager = FreemiumManager(this)
        proGatingManager = ProGatingManager(this)
        proGatingManager.updateSubscriptionStatus(freemiumManager.hasActiveSubscription())

        // Initialize agent services
        llmService = UniversalLLMService(this)
        agent = AgentFactory.getAgent(this)
        agentIntegration = AgentIntegration(llmService, agent)

        // Set up Flutter
        setupFlutterEngine()
    }

    private fun setupFlutterEngine() {
        // Get or create Flutter engine
        flutterEngine = FlutterEngineCache.getInstance().get(FLUTTER_ENGINE_ID)
            ?: createFlutterEngine()

        // Set up method channel for AI assistance
        setupAIAssistanceChannel()

        // Add Flutter fragment if not already added
        if (savedInstanceState == null) {
            supportFragmentManager
                .beginTransaction()
                .add(
                    R.id.flutter_container,
                    FlutterFragment.withCachedEngine(FLUTTER_ENGINE_ID).build()
                )
                .commit()
        }
    }

    private fun createFlutterEngine(): FlutterEngine {
        val engine = FlutterEngine(this)

        // Navigate to text editor route
        engine.navigationChannel.setInitialRoute(TEXT_EDITOR_ROUTE)
        engine.dartExecutor.executeDartEntrypoint(
            io.flutter.embedding.engine.dart.DartExecutor.DartEntrypoint.createDefault()
        )

        FlutterEngineCache.getInstance().put(FLUTTER_ENGINE_ID, engine)
        return engine
    }

    private fun setupAIAssistanceChannel() {
        aiAssistanceChannel = MethodChannel(
            flutterEngine!!.dartExecutor.binaryMessenger,
            AI_ASSISTANCE_CHANNEL
        )

        aiAssistanceChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "processRequest" -> {
                    val operation = call.argument<String>("operation") ?: ""
                    val text = call.argument<String>("text") ?: ""
                    val instruction = call.argument<String>("instruction") ?: ""
                    val context = call.argument<Map<String, Any>>("context") ?: emptyMap()
                    
                    processAIRequest(operation, text, instruction, context, result)
                }
                
                "checkProAccess" -> {
                    val isProUser = freemiumManager.hasActiveSubscription()
                    result.success(isProUser)
                }
                
                "isProOperationAllowed" -> {
                    val operation = call.argument<String>("operation") ?: ""
                    val textLength = call.argument<Int>("textLength") ?: 0
                    
                    val isAllowed = checkProOperationAllowed(operation, textLength)
                    result.success(isAllowed)
                }
                
                "getOperationCount" -> {
                    val count = proGatingManager.getTextEditorOperationsToday()
                    result.success(count)
                }
                
                "getOperationLimit" -> {
                    val limit = 50 // Free tier limit
                    result.success(limit)
                }
                
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun processAIRequest(
        operation: String,
        text: String,
        instruction: String,
        context: Map<String, Any>,
        result: MethodChannel.Result
    ) {
        // Launch coroutine for async AI processing
        CoroutineScope(Dispatchers.Main).launch {
            try {
                // Check Pro access for operations
                val operationCount = proGatingManager.getTextEditorOperationsToday()
                val freeLimit = 50
                
                val isProUser = freemiumManager.hasActiveSubscription()
                if (!isProUser && operationCount >= freeLimit) {
                    result.error(
                        "LIMIT_REACHED",
                        "You've reached your daily limit of $freeLimit operations. Upgrade to Pro for unlimited access.",
                        null
                    )
                    return@launch
                }

                // Check text length limits for free users
                if (!isProUser && text.length > 1000 && operation != "grammar") {
                    result.error(
                        "PRO_REQUIRED",
                        "Text longer than 1000 characters requires Pro. Upgrade for unlimited text length.",
                        null
                    )
                    return@launch
                }

                // Construct system prompt with context
                val systemPrompt = constructSystemPrompt(operation, context)

                // Execute AI request
                val aiResult = withContext(Dispatchers.IO) {
                    agentIntegration.executeWithPrompt(
                        basePrompt = SystemPrompts.TEXT_EDITOR,
                        context = buildContextMap(operation, text, instruction, context),
                        userRequest = instruction.ifEmpty { "Process this text: $text" }
                    )
                }

                when (aiResult) {
                    is AgentResult.Success -> {
                        // Increment operation count
                        proGatingManager.incrementTextEditorOperations()
                        
                        // Format response
                        val formattedResponse = agentIntegration.formatResponse(aiResult.response)
                        
                        result.success(mapOf(
                            "success" to true,
                            "text" to formattedResponse,
                            "metadata" to mapOf(
                                "operation" to operation,
                                "originalLength" to text.length,
                                "resultLength" to formattedResponse.length
                            )
                        ))
                    }
                    
                    is AgentResult.Error -> {
                        result.error(
                            "AI_ERROR",
                            aiResult.message,
                            null
                        )
                    }
                }
            } catch (e: Exception) {
                result.error(
                    "EXCEPTION",
                    "Error processing AI request: ${e.message}",
                    null
                )
            }
        }
    }

    private fun constructSystemPrompt(operation: String, context: Map<String, Any>): String {
        return when (operation) {
            "rewrite" -> {
                val tone = context["tone"] as? String ?: "professional"
                "Rewrite the text in a $tone tone"
            }
            "summarize" -> {
                val length = context["length"] as? String ?: "brief"
                "Provide a $length summary"
            }
            "expand" -> "Expand on this text with more details and examples"
            "continue" -> "Continue writing from this point"
            "grammar" -> "Fix grammar and spelling errors"
            "translate" -> {
                val targetLanguage = context["targetLanguage"] as? String ?: "Spanish"
                "Translate to $targetLanguage"
            }
            "generate" -> "Generate content based on the prompt"
            else -> "Process this text"
        }
    }

    private fun buildContextMap(
        operation: String,
        text: String,
        instruction: String,
        context: Map<String, Any>
    ): Map<String, String> {
        return mapOf(
            "operation" to operation,
            "selectedText" to text,
            "context" to instruction,
            "tone" to (context["tone"] as? String ?: ""),
            "length" to (context["length"] as? String ?: ""),
            "targetLanguage" to (context["targetLanguage"] as? String ?: ""),
            "prompt" to (context["prompt"] as? String ?: "")
        )
    }

    private fun checkProOperationAllowed(operation: String, textLength: Int): Boolean {
        val isProUser = freemiumManager.hasActiveSubscription()
        
        // Check operation-specific limits
        return when (operation) {
            "generate" -> isProUser // Generate is Pro-only
            else -> {
                // For other operations, check text length and operation count
                if (!isProUser) {
                    val operationCount = proGatingManager.getTextEditorOperationsToday()
                    operationCount < 50 && textLength <= 1000
                } else {
                    true
                }
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        // Clean up channel
        aiAssistanceChannel?.setMethodCallHandler(null)
    }

    override fun onBackPressed() {
        // Navigate back in Flutter or close activity
        if (flutterEngine?.navigationChannel != null) {
            flutterEngine?.navigationChannel?.popRoute()
        }
        super.onBackPressed()
    }
}

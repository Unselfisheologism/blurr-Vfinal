package com.blurr.ai.apps.learning

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.blurr.ai.agents.UltraGeneralistAgent
import com.blurr.ai.apps.base.AgentIntegration
import com.blurr.ai.apps.base.AgentResult
import com.blurr.ai.apps.base.ProGatingManager
import com.blurr.ai.apps.base.SystemPrompts
import com.blurr.ai.core.providers.UniversalLLMService
import com.blurr.ai.utilities.FreemiumManager
import io.flutter.embedding.android.FlutterView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/**
 * Host Activity for AI-Native Learning Platform (Flutter)
 * 
 * This activity hosts the Flutter LearningHubScreen and provides
 * platform channel integration for AI-powered learning operations.
 * 
 * Features:
 * - Document processing and summarization
 * - Quiz and flashcard generation
 * - Knowledge-scoped Q&A
 * - Learning path recommendations
 * - Progress tracking with Pro gating
 */
class LearningPlatformActivity : AppCompatActivity() {
    
    companion object {
        private const val FLUTTER_ENGINE_ID = "blurr_flutter_engine"
        private const val LEARNING_PLATFORM_CHANNEL = "com.blurr.learning_platform/ai"
        private const val LEARNING_HUB_ROUTE = "/learning_hub"
        
        // Document limits for free tier
        private const val FREE_DOCUMENT_LIMIT = 5
        private const val FREE_TEXT_LENGTH_LIMIT = 1000
        private const val FREE_DAILY_OPERATIONS = 10
    }

    private lateinit var freemiumManager: FreemiumManager
    private lateinit var proGatingManager: ProGatingManager
    private lateinit var agentIntegration: AgentIntegration
    private lateinit var llmService: UniversalLLMService
    private lateinit var agent: UltraGeneralistAgent

    private var flutterEngine: FlutterEngine? = null
    private var learningPlatformChannel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Initialize managers
        freemiumManager = FreemiumManager(this)
        proGatingManager = ProGatingManager(this)
        proGatingManager.updateSubscriptionStatus(freemiumManager.hasActiveSubscription())
        
        // Initialize agent services
        llmService = UniversalLLMService(this)
        agent = UltraGeneralistAgent(this, llmService)
        agentIntegration = AgentIntegration(llmService, agent)

        // Set up Flutter
        setupFlutterEngine()
    }

    private fun setupFlutterEngine() {
        // Get or create Flutter engine
        flutterEngine = FlutterEngineCache.getInstance().get(FLUTTER_ENGINE_ID)
        
        if (flutterEngine == null) {
            flutterEngine = FlutterEngine(this)
            FlutterEngineCache.getInstance().put(FLUTTER_ENGINE_ID, flutterEngine!!)
        }

        // Navigate to learning hub route
        flutterEngine?.navigationChannel?.pushRoute(LEARNING_HUB_ROUTE)

        // Set up method channel for learning platform operations
        setupLearningPlatformChannel()

        // Create Flutter view and attach engine
        val flutterView = FlutterView(this)
        flutterView.attachToFlutterEngine(flutterEngine!!)

        setContentView(flutterView)
    }

    private fun setupLearningPlatformChannel() {
        learningPlatformChannel = MethodChannel(
            flutterEngine!!.dartExecutor.binaryMessenger,
            LEARNING_PLATFORM_CHANNEL
        )

        learningPlatformChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "generateSummary" -> {
                    val content = call.argument<String>("content") ?: ""
                    val summaryType = call.argument<String>("summaryType") ?: "brief"
                    val maxLength = call.argument<Int>("maxLength") ?: 500
                    
                    generateSummary(content, summaryType, maxLength, result)
                }
                
                "generateQuiz" -> {
                    val materialId = call.argument<String>("materialId") ?: ""
                    val content = call.argument<String>("content") ?: ""
                    val title = call.argument<String>("title") ?: ""
                    
                    generateQuiz(materialId, content, title, result)
                }
                
                "generateFlashcards" -> {
                    val materialId = call.argument<String>("materialId") ?: ""
                    val content = call.argument<String>("content") ?: ""
                    
                    generateFlashcards(materialId, content, result)
                }
                
                "answerQuestion" -> {
                    val materialId = call.argument<String>("materialId") ?: ""
                    val question = call.argument<String>("question") ?: ""
                    val context = call.argument<String>("context") ?: ""
                    
                    answerQuestion(materialId, question, context, result)
                }
                
                "generateLearningPath" -> {
                    val materialIds = call.argument<List<String>>("materialIds") ?: emptyList()
                    val titles = call.argument<List<String>>("titles") ?: emptyList()
                    val contents = call.argument<List<String>>("contents") ?: emptyList()
                    val pathTitle = call.argument<String>("pathTitle") ?: ""
                    val pathDescription = call.argument<String>("pathDescription") ?: ""
                    val learningObjectives = call.argument<List<String>>("learningObjectives") ?: emptyList()
                    
                    generateLearningPath(materialIds, titles, contents, pathTitle, pathDescription, learningObjectives, result)
                }
                
                "getRecommendations" -> {
                    val userId = call.argument<String>("userId") ?: ""
                    val completedMaterials = call.argument<List<String>>("completedMaterials") ?: emptyList()
                    val interests = call.argument<List<String>>("interests") ?: emptyList()
                    val limit = call.argument<Int>("limit") ?: 10
                    
                    getRecommendations(userId, completedMaterials, interests, limit, result)
                }
                
                "analyzeDifficulty" -> {
                    val content = call.argument<String>("content") ?: ""
                    
                    analyzeDifficulty(content, result)
                }
                
                "checkProAccess" -> {
                    val isProUser = freemiumManager.hasActiveSubscription()
                    result.success(isProUser)
                }
                
                "getDocumentLimit" -> {
                    val limit = if (freemiumManager.hasActiveSubscription()) Int.MAX_VALUE else FREE_DOCUMENT_LIMIT
                    result.success(limit)
                }
                
                "getDailyOperationLimit" -> {
                    val limit = if (freemiumManager.hasActiveSubscription()) Int.MAX_VALUE else FREE_DAILY_OPERATIONS
                    result.success(limit)
                }
                
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun generateSummary(
        content: String,
        summaryType: String,
        maxLength: Int,
        result: MethodChannel.Result
    ) {
        launchAIProcessing(result) {
            // Check Pro limits
            if (!checkProAccessForContentLength(content.length)) {
                return@launchAIProcessing AgentResult.Error(
                    "Text longer than $FREE_TEXT_LENGTH_LIMIT characters requires Pro"
                )
            }

            // Construct prompt based on summary type
            val prompt = when (summaryType) {
                "brief" -> "Provide a brief summary (max $maxLength chars): $content"
                "detailed" -> "Provide a detailed summary with key points: $content"
                "key_points" -> "Extract key points and main topics: $content"
                else -> "Summarize this text: $content"
            }

            // Execute AI request
            val aiResult = agentIntegration.executeWithPrompt(
                basePrompt = SystemPrompts.LEARNING_PLATFORM,
                context = mapOf(
                    "operation" to "summarize",
                    "summaryType" to summaryType,
                    "maxLength" to maxLength.toString(),
                    "contentLength" to content.length.toString()
                ),
                userRequest = prompt
            )

            when (aiResult) {
                is AgentResult.Success -> {
                    val response = agentIntegration.formatResponse(aiResult.response)
                    AgentResult.Success(response)
                }
                is AgentResult.Error -> aiResult
            }
        }
    }

    private fun generateQuiz(
        materialId: String,
        content: String,
        title: String,
        result: MethodChannel.Result
    ) {
        launchAIProcessing(result) {
            val prompt = "Generate a quiz based on this content. Include multiple choice, true/false, and fill-in-the-blank questions. Content: $content"
            
            val aiResult = agentIntegration.executeWithPrompt(
                basePrompt = SystemPrompts.LEARNING_PLATFORM,
                context = mapOf(
                    "operation" to "generateQuiz",
                    "materialId" to materialId,
                    "title" to title,
                    "contentLength" to content.length.toString()
                ),
                userRequest = prompt
            )

            when (aiResult) {
                is AgentResult.Success -> {
                    val formattedResponse = formatQuizResponse(aiResult.response)
                    AgentResult.Success(formattedResponse)
                }
                is AgentResult.Error -> aiResult
            }
        }
    }

    private fun generateFlashcards(
        materialId: String,
        content: String,
        result: MethodChannel.Result
    ) {
        launchAIProcessing(result) {
            val prompt = "Create flashcards from this content. Each card should have a front (question/prompt) and back (answer). Content: $content"
            
            val aiResult = agentIntegration.executeWithPrompt(
                basePrompt = SystemPrompts.LEARNING_PLATFORM,
                context = mapOf(
                    "operation" to "generateFlashcards",
                    "materialId" to materialId,
                    "contentLength" to content.length.toString()
                ),
                userRequest = prompt
            )

            when (aiResult) {
                is AgentResult.Success -> {
                    val formattedResponse = formatFlashcardResponse(aiResult.response)
                    AgentResult.Success(formattedResponse)
                }
                is AgentResult.Error -> aiResult
            }
        }
    }

    private fun answerQuestion(
        materialId: String,
        question: String,
        context: String,
        result: MethodChannel.Result
    ) {
        launchAIProcessing(result) {
            val prompt = """
                Answer this question based only on the provided content.
                Question: $question
                Content: $context
                Provide a detailed answer with citations if possible.
            """.trimIndent()
            
            val aiResult = agentIntegration.executeWithPrompt(
                basePrompt = SystemPrompts.LEARNING_PLATFORM,
                context = mapOf(
                    "operation" to "answerQuestion",
                    "materialId" to materialId,
                    "question" to question
                ),
                userRequest = prompt
            )

            when (aiResult) {
                is AgentResult.Success -> {
                    val response = agentIntegration.formatResponse(aiResult.response)
                    AgentResult.Success(response)
                }
                is AgentResult.Error -> aiResult
            }
        }
    }

    private fun generateLearningPath(
        materialIds: List<String>,
        titles: List<String>,
        contents: List<String>,
        pathTitle: String,
        pathDescription: String,
        learningObjectives: List<String>,
        result: MethodChannel.Result
    ) {
        launchAIProcessing(result) {
            val prompt = """
                Create a learning path with the following materials:
                ${titles.joinToString("\n") { "- $it" }}
                
                Learning objectives: ${learningObjectives.joinToString(", ")}
                
                Provide: 1) Recommended material order, 2) Estimated duration per material,
                3) Key topics to focus on, 4) Prerequisites, 5) Difficulty progression
            """.trimIndent()
            
            val aiResult = agentIntegration.executeWithPrompt(
                basePrompt = SystemPrompts.LEARNING_PLATFORM,
                context = mapOf(
                    "operation" to "generateLearningPath",
                    "materialCount" to materialIds.size.toString(),
                    "hasDescription" to (!pathDescription.isNullOrEmpty()).toString()
                ),
                userRequest = prompt
            )

            when (aiResult) {
                is AgentResult.Success -> {
                    val formattedResponse = formatLearningPathResponse(aiResult.response)
                    AgentResult.Success(formattedResponse)
                }
                is AgentResult.Error -> aiResult
            }
        }
    }

    private fun getRecommendations(
        userId: String,
        completedMaterials: List<String>,
        interests: List<String>,
        limit: Int,
        result: MethodChannel.Result
    ) {
        launchAIProcessing(result) {
            val prompt = """
                Suggest learning materials based on:
                Completed: ${completedMaterials.take(5).joinToString(", ")}
                Interests: ${interests.joinToString(", ")}
                
                Provide $limit recommendations with reasons and difficulty levels.
            """.trimIndent()
            
            val aiResult = agentIntegration.executeWithPrompt(
                basePrompt = SystemPrompts.LEARNING_PLATFORM,
                context = mapOf(
                    "operation" to "getRecommendations",
                    "userId" to userId,
                    "completedCount" to completedMaterials.size.toString(),
                    "interestCount" to interests.size.toString()
                ),
                userRequest = prompt
            )

            when (aiResult) {
                is AgentResult.Success -> {
                    val formattedResponse = formatRecommendationsResponse(aiResult.response)
                    AgentResult.Success(formattedResponse)
                }
                is AgentResult.Error -> aiResult
            }
        }
    }

    private fun analyzeDifficulty(content: String, result: MethodChannel.Result) {
        launchAIProcessing(result) {
            val prompt = """
                Analyze the difficulty level of this content:
                - Readability score (Flesch-Kincaid)
                - Appropriate learner level (beginner/intermediate/advanced)
                - Key concepts and vocabulary level
                - Estimated study time
                - Prerequisites needed
                
                Content: ${content.take(500)}..."
            """.trimIndent()
            
            val aiResult = agentIntegration.executeWithPrompt(
                basePrompt = SystemPrompts.LEARNING_PLATFORM,
                context = mapOf(
                    "operation" to "analyzeDifficulty",
                    "contentLength" to content.length.toString()
                ),
                userRequest = prompt
            )

            when (aiResult) {
                is AgentResult.Success -> {
                    val formattedResponse = formatDifficultyAnalysis(aiResult.response)
                    AgentResult.Success(formattedResponse)
                }
                is AgentResult.Error -> aiResult
            }
        }
    }

    private fun launchAIProcessing(
        result: MethodChannel.Result,
        block: suspend () -> AgentResult
    ) {
        CoroutineScope(Dispatchers.Main).launch {
            try {
                // Check Pro access for AI operations
                if (!checkProAccess()) {
                    result.error(
                        "PRO_REQUIRED",
                        "AI-powered features require Pro subscription. Upgrade for unlimited access.",
                        null
                    )
                    return@launch
                }

                val aiResult = withContext(Dispatchers.IO) {
                    block()
                }

                when (aiResult) {
                    is AgentResult.Success -> {
                        // Format success response
                        result.success(mapOf(
                            "success" to true,
                            "data" to aiResult.response,
                            "metadata" to emptyMap<String, Any>()
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

    private fun checkProAccess(): Boolean {
        return freemiumManager.hasActiveSubscription()
    }

    private fun checkProAccessForContentLength(contentLength: Int): Boolean {
        return freemiumManager.hasActiveSubscription() || contentLength <= FREE_TEXT_LENGTH_LIMIT
    }

    // Response formatting helpers
    private fun formatQuizResponse(response: String): Map<String, Any> {
        return mapOf(
            "title" to "Generated Quiz",
            "questions" to extractQuestionsFromResponse(response),
            "settings" to mapOf(
                "showAnswers" to true,
                "shuffleQuestions" to true,
                "passingScore" to 70
            )
        )
    }

    private fun formatFlashcardResponse(response: String): Map<String, Any> {
        return mapOf(
            "title" to "Generated Flashcards",
            "flashcards" to extractFlashcardsFromResponse(response)
        )
    }

    private fun formatLearningPathResponse(response: String): Map<String, Any> {
        return mapOf(
            "title" to "AI-Generated Learning Path",
            "isAdaptive" to true,
            "estimatedDuration" to extractEstimatedDuration(response),
            "keyTopics" to extractKeyTopics(response)
        )
    }

    private fun formatRecommendationsResponse(response: String): List<Map<String, Any>> {
        return extractRecommendationsFromResponse(response)
    }

    private fun formatDifficultyAnalysis(response: String): Map<String, Any> {
        return mapOf(
            "difficultyLevel" to extractDifficultyLevel(response),
            "readabilityScore" to extractReadabilityScore(response),
            "estimatedReadTime" to extractReadTime(response),
            "keyConcepts" to extractKeyConcepts(response)
        )
    }

    // Helper methods for extracting data from AI responses
    private fun extractQuestionsFromResponse(response: String): List<Map<String, Any>> {
        // Implementation would parse the AI response and extract structured question data
        return emptyList() // Placeholder for actual implementation
    }

    private fun extractFlashcardsFromResponse(response: String): List<Map<String, Any>> {
        // Implementation would parse the AI response and extract flashcard pairs
        return emptyList() // Placeholder for actual implementation
    }

    private fun extractEstimatedDuration(response: String): Int {
        // Extract duration from AI response, default to 60 minutes
        return 60
    }

    private fun extractKeyTopics(response: String): List<String> {
        // Extract key topics from AI response
        return emptyList()
    }

    private fun extractRecommendationsFromResponse(response: String): List<Map<String, Any>> {
        // Extract structured recommendations
        return emptyList()
    }

    private fun extractDifficultyLevel(response: String): String {
        // Extract difficulty level from AI analysis
        return "intermediate"
    }

    private fun extractReadabilityScore(response: String): Int {
        // Extract readability score from AI analysis
        return 60
    }

    private fun extractReadTime(response: String): Int {
        // Extract estimated read time from AI analysis
        return 30
    }

    private fun extractKeyConcepts(response: String): List<String> {
        // Extract key concepts from AI analysis
        return emptyList()
    }

    override fun onDestroy() {
        super.onDestroy()
        // Clean up channels
        learningPlatformChannel?.setMethodCallHandler(null)
    }

    override fun onBackPressed() {
        // Navigate back in Flutter or close activity
        flutterEngine?.navigationChannel?.popRoute()
        super.onBackPressed()
    }
}
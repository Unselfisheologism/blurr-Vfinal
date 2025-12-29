package com.blurr.voice.agents

import kotlinx.coroutines.suspendCancellableCoroutine
import kotlin.coroutines.resume

/**
 * User Confirmation/Question System for Ultra-Generalist Agent
 * 
 * Allows the agent to pause execution and ask the user questions mid-workflow.
 * This enables dynamic decision-making based on user preferences.
 * 
 * Use Cases:
 * - Ask which tool/approach to use (e.g., Nano Banana Pro vs matplotlib)
 * - Confirm expensive operations
 * - Request additional information
 * - Offer choices during execution
 */
data class UserQuestion(
    val question: String,
    val options: List<String>,
    val context: String? = null,
    val defaultOption: Int? = null
)

data class UserQuestionResult(
    val selectedOption: Int,
    val selectedText: String
)

/**
 * Interface for handling user questions during agent execution
 */
interface UserConfirmationHandler {
    /**
     * Ask user a question and wait for response
     * 
     * @param question The question data
     * @return The user's selected option
     */
    suspend fun askUser(question: UserQuestion): UserQuestionResult
}

/**
 * Default implementation that can be overridden by UI
 */
class DefaultUserConfirmationHandler : UserConfirmationHandler {
    
    private var pendingQuestion: UserQuestion? = null
    private var pendingContinuation: ((UserQuestionResult) -> Unit)? = null
    
    override suspend fun askUser(question: UserQuestion): UserQuestionResult {
        return suspendCancellableCoroutine { continuation ->
            pendingQuestion = question
            pendingContinuation = { result ->
                continuation.resume(result)
            }
            
            // Notify UI that question is pending
            onQuestionPending?.invoke(question)
        }
    }
    
    /**
     * Called by UI when user responds
     */
    fun respondToQuestion(selectedOption: Int) {
        val question = pendingQuestion ?: return
        val result = UserQuestionResult(
            selectedOption = selectedOption,
            selectedText = question.options.getOrNull(selectedOption) ?: ""
        )
        
        pendingContinuation?.invoke(result)
        pendingQuestion = null
        pendingContinuation = null
    }
    
    /**
     * Callback for UI to know when question is pending
     */
    var onQuestionPending: ((UserQuestion) -> Unit)? = null
}

/**
 * Helper functions for common agent questions
 */
object AgentQuestions {
    
    /**
     * Ask which infographic generation method to use
     */
    fun infographicMethodQuestion(): UserQuestion {
        return UserQuestion(
            question = "How would you like to generate the infographic?",
            options = listOf(
                "Use Nano Banana Pro (AI-generated, professional quality)",
                "Use Python matplotlib (basic charts and graphs)"
            ),
            context = "Nano Banana Pro creates stunning AI-generated infographics from text prompts. " +
                    "Python matplotlib creates basic data visualizations. " +
                    "Nano Banana Pro is recommended for professional, polished results.",
            defaultOption = 0 // Default to Nano Banana Pro
        )
    }
    
    /**
     * Ask which video generation method to use
     */
    fun videoMethodQuestion(hasImages: Boolean, hasAudio: Boolean): UserQuestion {
        val options = mutableListOf<String>()
        
        if (hasImages && hasAudio) {
            options.add("Compile existing media with Python (ffmpeg)")
        }
        
        options.add("Generate AI video with existing video tools")
        
        return UserQuestion(
            question = "How would you like to create the video?",
            options = options,
            context = if (hasImages && hasAudio) {
                "You have images and audio already. I can compile them quickly with Python, " +
                "or generate a new AI video from scratch."
            } else {
                "I'll generate an AI video for you."
            },
            defaultOption = 0
        )
    }
    
    /**
     * Ask for confirmation on expensive operation
     */
    fun confirmExpensiveOperation(operation: String, estimatedTime: String): UserQuestion {
        return UserQuestion(
            question = "This operation may take $estimatedTime. Continue?",
            options = listOf(
                "Yes, proceed",
                "No, skip this step"
            ),
            context = "Operation: $operation",
            defaultOption = 0
        )
    }
    
    /**
     * Ask for additional information
     */
    fun askForInformation(question: String, suggestions: List<String>): UserQuestion {
        return UserQuestion(
            question = question,
            options = suggestions + "Custom input",
            context = null,
            defaultOption = 0
        )
    }
}

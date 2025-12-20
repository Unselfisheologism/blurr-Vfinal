package com.twent.voice.apps.base

import com.twent.voice.agents.UltraGeneralistAgent
import com.twent.voice.core.providers.UniversalLLMService

/**
 * Manages agent integration and system prompt management for AI-native apps.
 * 
 * This class provides a centralized way to:
 * - Construct app-specific system prompts
 * - Inject context into prompts (selected text, current state, etc.)
 * - Handle agent requests with proper error handling
 * - Format agent responses for UI consumption
 * 
 * Usage:
 * ```kotlin
 * val integration = AgentIntegration(llmService, agent)
 * 
 * val result = integration.executeWithPrompt(
 *     basePrompt = TEXT_EDITOR_SYSTEM_PROMPT,
 *     context = mapOf(
 *         "operation" to "rewrite",
 *         "selectedText" to "Hello world",
 *         "tone" to "professional"
 *     ),
 *     userRequest = "Rewrite this text"
 * )
 * ```
 */
class AgentIntegration(
    private val llmService: UniversalLLMService,
    private val agent: UltraGeneralistAgent
) {

    /**
     * Execute an agent request with a constructed system prompt.
     * 
     * @param basePrompt The base system prompt for the app
     * @param context Additional context to inject into the prompt
     * @param userRequest The user's request/input
     * @return The agent's response
     */
    suspend fun executeWithPrompt(
        basePrompt: String,
        context: Map<String, String> = emptyMap(),
        userRequest: String
    ): AgentResult {
        return try {
            val fullPrompt = constructPrompt(basePrompt, context)
            val response = agent.processRequest(userRequest, fullPrompt)
            
            AgentResult.Success(response)
        } catch (e: Exception) {
            AgentResult.Error(e.message ?: "An error occurred while processing your request")
        }
    }

    /**
     * Execute an agent request with streaming response.
     * 
     * @param basePrompt The base system prompt for the app
     * @param context Additional context to inject into the prompt
     * @param userRequest The user's request/input
     * @param onChunk Callback for each response chunk
     */
    suspend fun executeWithPromptStreaming(
        basePrompt: String,
        context: Map<String, String> = emptyMap(),
        userRequest: String,
        onChunk: (String) -> Unit
    ): AgentResult {
        return try {
            val fullPrompt = constructPrompt(basePrompt, context)
            
            // Note: This assumes the agent/LLM service supports streaming
            // You may need to modify based on actual implementation
            val response = agent.processRequest(userRequest, fullPrompt)
            
            // For now, call onChunk with full response
            // TODO: Implement true streaming when agent supports it
            onChunk(response)
            
            AgentResult.Success(response)
        } catch (e: Exception) {
            AgentResult.Error(e.message ?: "An error occurred while processing your request")
        }
    }

    /**
     * Construct a full system prompt by injecting context into the base prompt.
     * 
     * Context variables in the base prompt should be in the format: {variableName}
     * 
     * Example:
     * Base prompt: "You are helping with {operation}. Selected text: {selectedText}"
     * Context: mapOf("operation" to "rewriting", "selectedText" to "Hello")
     * Result: "You are helping with rewriting. Selected text: Hello"
     */
    private fun constructPrompt(
        basePrompt: String,
        context: Map<String, String>
    ): String {
        var prompt = basePrompt
        
        // Replace each context variable
        context.forEach { (key, value) ->
            prompt = prompt.replace("{$key}", value)
        }
        
        return prompt
    }

    /**
     * Format agent response for display.
     * Can be extended to handle specific formatting needs.
     */
    fun formatResponse(response: String): String {
        // Remove any leading/trailing whitespace
        var formatted = response.trim()
        
        // Remove any markdown code fences if present (optional)
        if (formatted.startsWith("```") && formatted.endsWith("```")) {
            formatted = formatted
                .removePrefix("```")
                .removeSuffix("```")
                .trim()
        }
        
        return formatted
    }

    /**
     * Extract specific sections from agent response.
     * Useful when agent returns structured responses.
     */
    fun extractSection(
        response: String,
        sectionHeader: String
    ): String? {
        val lines = response.lines()
        val startIndex = lines.indexOfFirst { it.contains(sectionHeader, ignoreCase = true) }
        
        if (startIndex == -1) return null
        
        // Get all lines after the header until next section or end
        val sectionLines = mutableListOf<String>()
        for (i in (startIndex + 1) until lines.size) {
            val line = lines[i]
            // Stop at next section header (typically starts with #)
            if (line.startsWith("#")) break
            sectionLines.add(line)
        }
        
        return sectionLines.joinToString("\n").trim()
    }
}

/**
 * Result of an agent operation.
 */
sealed class AgentResult {
    /**
     * Successful operation.
     */
    data class Success(val response: String) : AgentResult()

    /**
     * Operation failed with error.
     */
    data class Error(val message: String) : AgentResult()
}

/**
 * System prompts for each app.
 * These can be customized per app and injected with context.
 */
object SystemPrompts {
    
    const val TEXT_EDITOR = """
You are an AI writing assistant integrated into a text editor.

Your capabilities:
- Rewrite text in different tones (professional, casual, creative)
- Summarize content (brief or detailed)
- Expand on ideas with more detail
- Continue writing from a given point
- Fix grammar and spelling errors
- Translate text to other languages

Guidelines:
- Preserve the user's core message and intent
- Match the requested tone/style precisely
- For summaries, capture key points concisely
- For expansions, add relevant detail without fluff
- Always ask for clarification if the request is ambiguous
- Return ONLY the transformed text, no explanations unless asked

Current operation: {operation}
Selected text: {selectedText}
Additional context: {context}
"""

    const val SPREADSHEETS = """
You are an AI data analyst integrated into a spreadsheet application.

Your capabilities:
- Generate spreadsheet data from natural language descriptions
- Analyze data to find trends, patterns, and insights
- Create formulas and calculations
- Suggest data visualizations
- Answer questions about data

Guidelines:
- Generate realistic, coherent data when creating spreadsheets
- Provide clear, actionable insights in analysis
- Explain your reasoning when analyzing data
- Suggest appropriate chart types for visualizations
- Ask clarifying questions if data requirements are unclear

Current operation: {operation}
Data context: {dataContext}
"""

    const val MEDIA_CANVAS = """
You are an AI assistant helping users create multimodal media workflows.

Your capabilities:
- Design workflows for image, video, audio, music, and 3D generation
- Suggest optimal node connections and parameters
- Recommend media generation settings for desired outcomes
- Troubleshoot workflow issues

Guidelines:
- Understand the user's creative vision and goals
- Suggest efficient workflow structures
- Recommend appropriate models and parameters
- Explain trade-offs between different approaches
- Be creative in suggesting unique combinations

Current workflow: {workflowContext}
User goal: {userGoal}
"""

    const val DAW = """
You are an AI music production assistant in a digital audio workstation.

Your capabilities:
- Generate music from descriptions (genres, moods, instruments)
- Provide mixing and mastering advice
- Suggest arrangement improvements
- Explain music theory concepts
- Recommend effects and processing

Guidelines:
- Understand musical genres, styles, and terminology
- Provide practical, actionable mixing advice
- Suggest creative arrangement ideas
- Explain technical concepts in accessible language
- Consider the user's skill level and goals

Current project: {projectContext}
User request: {userRequest}
"""

    const val LEARNING_PLATFORM = """
You are an AI study assistant helping users learn from documents.

Your capabilities:
- Summarize documents and extract key points
- Generate flashcards and quizzes from content
- Answer questions with citations to source material
- Create study guides and overviews
- Suggest learning strategies

Guidelines:
- Provide accurate, well-sourced information
- Use the Socratic method when appropriate
- Create effective study materials
- Cite specific sections of source documents
- Adapt to the user's learning level and goals

Document context: {documentContext}
Learning goal: {learningGoal}
"""

    const val VIDEO_EDITOR = """
You are an AI video editing assistant.

Your capabilities:
- Suggest transitions and effects for video clips
- Generate captions from audio
- Recommend music and audio for video mood
- Provide color grading suggestions
- Advise on pacing and storytelling

Guidelines:
- Understand video editing terminology and concepts
- Make suggestions that enhance storytelling
- Consider the target platform (social media, YouTube, etc.)
- Provide practical, implementable advice
- Be creative while respecting the user's vision

Video project: {projectContext}
Editing goal: {editingGoal}
"""
}

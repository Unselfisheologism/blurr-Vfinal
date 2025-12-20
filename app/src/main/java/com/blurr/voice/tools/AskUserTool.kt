package com.twent.voice.tools

import android.content.Context
import android.util.Log
import com.twent.voice.agents.UserConfirmationHandler
import com.twent.voice.agents.UserQuestion

/**
 * Ask User Tool
 * 
 * Allows the agent to pause execution and ask the user questions.
 * The agent can offer choices and wait for user response before continuing.
 * 
 * This enables:
 * - Method selection (Nano Banana Pro vs matplotlib)
 * - Confirmation of expensive operations
 * - Requesting additional information
 * - Offering choices during workflow
 */
class AskUserTool(
    private val context: Context,
    private val confirmationHandler: UserConfirmationHandler
) : BaseTool() {
    
    companion object {
        private const val TAG = "AskUserTool"
    }
    
    override val name: String = "ask_user"
    
    override val description: String = 
        "Ask the user a question and wait for their response. Use this when you need to: " +
        "1) Offer choices between different approaches (e.g., Nano Banana Pro vs matplotlib for infographics), " +
        "2) Confirm expensive operations, " +
        "3) Request additional information, " +
        "4) Let user choose between quality/speed tradeoffs. " +
        "The workflow will pause until the user responds."
    
    override val parameters: List<ToolParameter> = listOf(
        ToolParameter(
            name = "question",
            type = "string",
            description = "The question to ask the user. Be clear and concise.",
            required = true
        ),
        ToolParameter(
            name = "options",
            type = "array",
            description = "List of options for the user to choose from (2-4 options). " +
                    "Example: ['Option A (fast but basic)', 'Option B (slow but professional)']",
            required = true
        ),
        ToolParameter(
            name = "context",
            type = "string",
            description = "Additional context to help user make decision (optional). " +
                    "Explain pros/cons of each option.",
            required = false
        ),
        ToolParameter(
            name = "default_option",
            type = "number",
            description = "Index of default/recommended option (0-based). Optional.",
            required = false
        )
    )
    
    override suspend fun execute(
        params: Map<String, Any>,
        context: List<ToolResult>
    ): ToolResult {
        return try {
            // Validate parameters
            validateParameters(params).getOrThrow()
            
            // Extract parameters
            val questionText = getRequiredParam<String>(params, "question")
            val options = getRequiredParam<List<String>>(params, "options")
            val contextText = getOptionalParam<String?>(params, "context", null)
            val defaultOption = getOptionalParam<Int?>(params, "default_option", null)
            
            // Validate options
            if (options.size < 2 || options.size > 4) {
                return ToolResult.failure(
                    toolName = name,
                    error = "Must provide 2-4 options. Got ${options.size} options."
                )
            }
            
            Log.d(TAG, "Asking user: $questionText with ${options.size} options")
            
            // Create question
            val question = UserQuestion(
                question = questionText,
                options = options,
                context = contextText,
                defaultOption = defaultOption
            )
            
            // Ask user and wait for response
            val result = confirmationHandler.askUser(question)
            
            Log.d(TAG, "User selected option ${result.selectedOption}: ${result.selectedText}")
            
            ToolResult.success(
                toolName = name,
                result = "User selected: ${result.selectedText}",
                data = mapOf(
                    "selected_option" to result.selectedOption,
                    "selected_text" to result.selectedText,
                    "question" to questionText
                )
            )
            
        } catch (e: Exception) {
            Log.e(TAG, "Error asking user", e)
            ToolResult.failure(
                toolName = name,
                error = "Failed to ask user: ${e.message}"
            )
        }
    }
}

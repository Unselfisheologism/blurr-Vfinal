package com.twent.voice.apps.base

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.twent.voice.agents.UltraGeneralistAgent
import com.twent.voice.core.providers.UniversalLLMService
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

/**
 * Base ViewModel for all AI-native apps.
 * 
 * Provides:
 * - Agent integration with app-specific system prompts
 * - Loading/error state management
 * - Common operations tracking (for Pro limits)
 * - Coroutine scope management
 * 
 * Usage: Extend this class for each app-specific ViewModel.
 * 
 * Example:
 * ```kotlin
 * class TextEditorViewModel @Inject constructor(
 *     private val llmService: UniversalLLMService,
 *     private val agent: UltraGeneralistAgent,
 *     private val repository: TextEditorRepository
 * ) : BaseAppViewModel(llmService, agent) {
 *     
 *     override fun getSystemPrompt(): String {
 *         return TEXT_EDITOR_SYSTEM_PROMPT
 *     }
 *     
 *     fun rewriteText(text: String, tone: String) {
 *         executeAgentOperation { agent, prompt ->
 *             agent.processRequest("Rewrite this in $tone tone: $text", prompt)
 *         }
 *     }
 * }
 * ```
 */
abstract class BaseAppViewModel(
    protected val llmService: UniversalLLMService,
    protected val agent: UltraGeneralistAgent
) : ViewModel() {

    // Common UI state
    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _error = MutableStateFlow<String?>(null)
    val error: StateFlow<String?> = _error.asStateFlow()

    private val _aiOperationInProgress = MutableStateFlow(false)
    val aiOperationInProgress: StateFlow<Boolean> = _aiOperationInProgress.asStateFlow()

    // Operation counting for Pro limits
    private val _operationCount = MutableStateFlow(0)
    val operationCount: StateFlow<Int> = _operationCount.asStateFlow()

    /**
     * Get the app-specific system prompt.
     * Must be implemented by subclasses.
     */
    abstract fun getSystemPrompt(): String

    /**
     * Execute an AI agent operation with common error handling and state management.
     * 
     * @param operation The operation to execute with the agent and system prompt
     */
    protected fun executeAgentOperation(
        operation: suspend (UltraGeneralistAgent, String) -> String
    ) {
        viewModelScope.launch {
            try {
                _aiOperationInProgress.value = true
                _error.value = null
                
                val systemPrompt = getSystemPrompt()
                val result = operation(agent, systemPrompt)
                
                // Increment operation count for Pro gating
                _operationCount.value += 1
                
                // Subclasses should handle the result in their own state
                handleOperationSuccess(result)
                
            } catch (e: Exception) {
                _error.value = e.message ?: "An error occurred"
                handleOperationError(e)
            } finally {
                _aiOperationInProgress.value = false
            }
        }
    }

    /**
     * Handle successful operation result.
     * Override in subclass to process the result.
     */
    protected open fun handleOperationSuccess(result: String) {
        // Subclasses can override to handle specific results
    }

    /**
     * Handle operation error.
     * Override in subclass for custom error handling.
     */
    protected open fun handleOperationError(error: Exception) {
        // Subclasses can override for custom error handling
    }

    /**
     * Set loading state.
     */
    protected fun setLoading(loading: Boolean) {
        _isLoading.value = loading
    }

    /**
     * Set error message.
     */
    protected fun setError(message: String?) {
        _error.value = message
    }

    /**
     * Clear error message.
     */
    fun clearError() {
        _error.value = null
    }

    /**
     * Reset operation count (e.g., at start of new day).
     */
    fun resetOperationCount() {
        _operationCount.value = 0
    }

    /**
     * Get current operation count for Pro gating checks.
     */
    fun getCurrentOperationCount(): Int = _operationCount.value
}

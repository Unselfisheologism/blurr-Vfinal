package com.twent.voice.ui.agent

import android.app.Application
import android.util.Log
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.twent.voice.agents.AgentFactory
import com.twent.voice.agents.ConversationManager
import com.twent.voice.agents.DefaultUserConfirmationHandler
import com.twent.voice.agents.UserQuestion
import com.twent.voice.data.models.Message
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

/**
 * ViewModel for Agent Chat UI
 * 
 * Manages conversation state, message sending, and agent interaction
 */
class AgentChatViewModel(application: Application) : AndroidViewModel(application) {
    
    private val agent = AgentFactory.getAgent(application)
    private val conversationManager = ConversationManager(application)
    private val confirmationHandler: DefaultUserConfirmationHandler?
    
    private val _uiState = MutableStateFlow(AgentChatUiState())
    val uiState: StateFlow<AgentChatUiState> = _uiState.asStateFlow()
    
    private val _messages = MutableStateFlow<List<Message>>(emptyList())
    val messages: StateFlow<List<Message>> = _messages.asStateFlow()
    
    companion object {
        private const val TAG = "AgentChatViewModel"
    }
    
    init {
        // Get the confirmation handler from AgentFactory
        confirmationHandler = AgentFactory.getConfirmationHandler()
        
        // Set up question listener
        confirmationHandler?.onQuestionPending = { question ->
            Log.d(TAG, "Agent has a question: ${question.question}")
            _uiState.value = _uiState.value.copy(
                pendingQuestion = question
            )
        }
        
        loadOrCreateConversation()
    }
    
    /**
     * Load existing conversation or create new one
     */
    private fun loadOrCreateConversation() {
        viewModelScope.launch {
            try {
                // Get or create conversation
                val conversationId = conversationManager.getCurrentConversationId()
                if (conversationId == null) {
                    conversationManager.createConversation("New Chat")
                    Log.d(TAG, "Created new conversation")
                } else {
                    Log.d(TAG, "Loaded existing conversation: $conversationId")
                }
                
                // Load messages
                _messages.value = conversationManager.getAllMessages()
                
            } catch (e: Exception) {
                Log.e(TAG, "Error loading conversation", e)
                _uiState.value = _uiState.value.copy(
                    errorMessage = "Failed to load conversation: ${e.message}"
                )
            }
        }
    }
    
    /**
     * Update input text
     */
    fun updateInputText(text: String) {
        _uiState.value = _uiState.value.copy(inputText = text)
    }
    
    /**
     * Send message to agent
     */
    fun sendMessage() {
        val text = _uiState.value.inputText.trim()
        if (text.isEmpty()) return
        
        viewModelScope.launch {
            try {
                // Clear input and set processing state
                _uiState.value = _uiState.value.copy(
                    inputText = "",
                    isProcessing = true,
                    errorMessage = null
                )
                
                Log.d(TAG, "Sending message: $text")
                
                // Refresh messages to show user message
                _messages.value = conversationManager.getAllMessages()
                
                // Process message with agent
                val response = agent.processMessage(text, emptyList())
                
                Log.d(TAG, "Agent response received: ${response.text.take(100)}")
                
                // Update messages
                _messages.value = conversationManager.getAllMessages()
                
                // Clear processing state
                _uiState.value = _uiState.value.copy(
                    isProcessing = false,
                    currentTool = null,
                    toolProgress = 0f
                )
                
                // Show error if agent response had error
                if (response.error != null) {
                    _uiState.value = _uiState.value.copy(
                        errorMessage = "Note: ${response.error}"
                    )
                }
                
            } catch (e: Exception) {
                Log.e(TAG, "Error sending message", e)
                
                _uiState.value = _uiState.value.copy(
                    isProcessing = false,
                    currentTool = null,
                    toolProgress = 0f,
                    errorMessage = "Failed to process message: ${e.message}"
                )
            }
        }
    }
    
    /**
     * Start new conversation
     */
    fun startNewConversation() {
        viewModelScope.launch {
            try {
                conversationManager.clearCache()
                conversationManager.createConversation("New Chat")
                
                _messages.value = emptyList()
                _uiState.value = AgentChatUiState()
                
                Log.d(TAG, "Started new conversation")
                
            } catch (e: Exception) {
                Log.e(TAG, "Error creating new conversation", e)
                _uiState.value = _uiState.value.copy(
                    errorMessage = "Failed to create new conversation: ${e.message}"
                )
            }
        }
    }
    
    /**
     * Clear error message
     */
    fun clearError() {
        _uiState.value = _uiState.value.copy(errorMessage = null)
    }
    
    /**
     * Update tool execution progress (for future use)
     */
    fun updateToolProgress(toolName: String, progress: Float) {
        _uiState.value = _uiState.value.copy(
            currentTool = toolName,
            toolProgress = progress
        )
    }
    
    /**
     * Respond to agent's question
     */
    fun respondToQuestion(selectedOption: Int) {
        Log.d(TAG, "User responded to question with option: $selectedOption")
        
        // Clear the pending question from UI
        _uiState.value = _uiState.value.copy(pendingQuestion = null)
        
        // Send response to confirmation handler
        confirmationHandler?.respondToQuestion(selectedOption)
    }
    
    /**
     * Dismiss question dialog (cancel operation)
     */
    fun dismissQuestion() {
        Log.d(TAG, "User dismissed question dialog")
        // For now, just respond with option 0 (default)
        respondToQuestion(0)
    }
}

/**
 * UI State for Agent Chat
 */
data class AgentChatUiState(
    val inputText: String = "",
    val isProcessing: Boolean = false,
    val currentTool: String? = null,
    val toolProgress: Float = 0f,
    val errorMessage: String? = null,
    val pendingQuestion: UserQuestion? = null  // Agent's question to user
)

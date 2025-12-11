package com.blurr.voice.core.providers

import android.content.Context
import android.graphics.Bitmap
import android.util.Log
import com.google.ai.client.generativeai.type.TextPart
import kotlinx.coroutines.flow.Flow

/**
 * Universal LLM service that routes requests to the user-configured provider
 * This replaces the hard-coded GeminiApi usage throughout the app
 */
class UniversalLLMService(private val context: Context) {
    
    companion object {
        private const val TAG = "UniversalLLMService"
    }
    
    private val keyManager = ProviderKeyManager(context)
    
    /**
     * Generates content using the user's configured provider and model
     * Compatible with existing GeminiApi interface
     * 
     * For agentic AI apps: Uses optimized settings by default (cost optimization, 
     * reduced repetition, fallback routing)
     * 
     * @param chat Conversation history as List<Pair<role, List<content>>>
     * @param images Optional images for vision models
     * @param useAgenticOptimization Enable agentic AI optimizations (default: true for OpenRouter)
     * @return Generated text or null on failure
     */
    suspend fun generateContent(
        chat: List<Pair<String, List<Any>>>,
        images: List<Bitmap> = emptyList(),
        useAgenticOptimization: Boolean = true
    ): String? {
        // Validate configuration
        val (isValid, errorMessage) = keyManager.validateConfiguration()
        if (!isValid) {
            Log.e(TAG, "Configuration invalid: $errorMessage")
            return "Configuration error: $errorMessage Please set up your API keys in Settings."
        }
        
        val provider = keyManager.getSelectedProvider()!!
        val apiKey = keyManager.getApiKey(provider)!!
        val model = keyManager.getSelectedModel(provider)!!
        
        // Convert chat format to simple messages
        val messages = convertChatToMessages(chat)
        
        // Create API client and make request
        val api = OpenAICompatibleAPI(provider, apiKey, model)
        
        // Use agentic optimization for OpenRouter by default (cost savings + better reliability)
        return if (useAgenticOptimization && provider == LLMProvider.OPENROUTER) {
            Log.d(TAG, "Using agentic AI optimizations (provider routing + transforms)")
            api.generateAgenticChatCompletion(messages, images)
        } else {
            api.generateChatCompletion(messages, images)
        }
    }
    
    /**
     * Generates streaming content with real-time token-by-token responses
     * Ideal for chat interfaces with live text display
     * 
     * @param chat Conversation history
     * @param images Optional images for vision models
     * @param useAgenticOptimization Enable agentic AI optimizations
     * @return Flow of text chunks
     */
    suspend fun generateStreamingContent(
        chat: List<Pair<String, List<Any>>>,
        images: List<Bitmap> = emptyList(),
        useAgenticOptimization: Boolean = true
    ): Flow<String>? {
        // Validate configuration
        val (isValid, errorMessage) = keyManager.validateConfiguration()
        if (!isValid) {
            Log.e(TAG, "Configuration invalid: $errorMessage")
            return null
        }
        
        val provider = keyManager.getSelectedProvider()!!
        val apiKey = keyManager.getApiKey(provider)!!
        val model = keyManager.getSelectedModel(provider)!!
        
        // Convert chat format to simple messages
        val messages = convertChatToMessages(chat)
        
        // Create API client
        val api = OpenAICompatibleAPI(provider, apiKey, model)
        
        // Return streaming response
        return if (useAgenticOptimization && provider == LLMProvider.OPENROUTER) {
            api.generateAgenticStreamingChatCompletion(messages, images)
        } else {
            api.generateStreamingChatCompletion(messages, images)
        }
    }
    
    /**
     * Generates content with privacy-focused routing (ZDR, no data collection)
     */
    suspend fun generatePrivateContent(
        chat: List<Pair<String, List<Any>>>,
        images: List<Bitmap> = emptyList()
    ): String? {
        val (isValid, _) = keyManager.validateConfiguration()
        if (!isValid) return null
        
        val provider = keyManager.getSelectedProvider()!!
        val apiKey = keyManager.getApiKey(provider)!!
        val model = keyManager.getSelectedModel(provider)!!
        val messages = convertChatToMessages(chat)
        
        val api = OpenAICompatibleAPI(provider, apiKey, model)
        return if (provider == LLMProvider.OPENROUTER) {
            api.generatePrivateChatCompletion(messages, images)
        } else {
            api.generateChatCompletion(messages, images)
        }
    }
    
    /**
     * Generates structured JSON output (for function calling, data extraction)
     */
    suspend fun generateStructuredContent(
        chat: List<Pair<String, List<Any>>>
    ): String? {
        val (isValid, _) = keyManager.validateConfiguration()
        if (!isValid) return null
        
        val provider = keyManager.getSelectedProvider()!!
        val apiKey = keyManager.getApiKey(provider)!!
        val model = keyManager.getSelectedModel(provider)!!
        val messages = convertChatToMessages(chat)
        
        val api = OpenAICompatibleAPI(provider, apiKey, model)
        return if (provider == LLMProvider.OPENROUTER) {
            api.generateStructuredOutput(messages)
        } else {
            api.generateChatCompletion(messages, emptyList(), 0.3, 4096)
        }
    }
    
    /**
     * Converts the Gemini-style chat format to OpenAI message format
     * Gemini format: List<Pair<String, List<Any>>> where Any can be TextPart, ImagePart, etc.
     * OpenAI format: List<Pair<String, String>> (role, content)
     */
    private fun convertChatToMessages(chat: List<Pair<String, List<Any>>>): List<Pair<String, String>> {
        return chat.map { (role, parts) ->
            val textContent = parts.filterIsInstance<TextPart>()
                .joinToString("\n") { it.text }
            
            // Map "model" role to "assistant" for OpenAI compatibility
            val mappedRole = when (role) {
                "model" -> "assistant"
                "user" -> "user"
                else -> role
            }
            
            mappedRole to textContent
        }
    }
    
    /**
     * Checks if the service is properly configured
     */
    fun isConfigured(): Boolean {
        return keyManager.validateConfiguration().first
    }
    
    /**
     * Gets the current provider display name
     */
    fun getCurrentProviderName(): String? {
        return keyManager.getSelectedProvider()?.displayName
    }
    
    /**
     * Gets the current model name
     */
    fun getCurrentModelName(): String? {
        val provider = keyManager.getSelectedProvider() ?: return null
        return keyManager.getSelectedModel(provider)
    }
}

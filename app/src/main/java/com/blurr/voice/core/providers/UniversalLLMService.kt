package com.blurr.voice.core.providers

import android.content.Context
import android.graphics.Bitmap
import android.util.Log
import com.google.ai.client.generativeai.type.TextPart

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
     * @param chat Conversation history as List<Pair<role, List<content>>>
     * @param images Optional images for vision models
     * @return Generated text or null on failure
     */
    suspend fun generateContent(
        chat: List<Pair<String, List<Any>>>,
        images: List<Bitmap> = emptyList()
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
        return api.generateChatCompletion(messages, images)
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

package com.blurr.voice.core.providers

import android.graphics.Bitmap
import android.util.Base64
import android.util.Log
import kotlinx.coroutines.delay
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONArray
import org.json.JSONObject
import java.io.ByteArrayOutputStream
import java.util.concurrent.TimeUnit

/**
 * OpenAI-compatible API client that works with multiple providers
 * Supports: OpenRouter, AIMLAPI, Groq, Fireworks, Together, OpenAI
 */
class OpenAICompatibleAPI(
    private val provider: LLMProvider,
    private val apiKey: String,
    private val model: String,
    private val maxRetries: Int = 3
) {
    companion object {
        private const val TAG = "OpenAICompatibleAPI"
    }
    
    private val client = OkHttpClient.Builder()
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(90, TimeUnit.SECONDS)
        .writeTimeout(60, TimeUnit.SECONDS)
        .build()
    
    /**
     * Generates content using OpenAI-compatible chat completion API
     * @param messages List of message pairs (role, content)
     * @param images Optional list of images for vision-capable models
     * @param temperature Temperature for response generation (0.0 - 2.0)
     * @param maxTokens Maximum tokens in response
     * @return Generated text response or null on failure
     */
    suspend fun generateChatCompletion(
        messages: List<Pair<String, String>>,
        images: List<Bitmap> = emptyList(),
        temperature: Double = 0.7,
        maxTokens: Int = 4096
    ): String? {
        var lastException: Exception? = null
        
        repeat(maxRetries) { attempt ->
            try {
                val requestBody = buildChatCompletionRequest(messages, images, temperature, maxTokens)
                val url = "${provider.baseUrl}/chat/completions"
                
                Log.d(TAG, "Request to ${provider.displayName} (attempt ${attempt + 1}/$maxRetries)")
                Log.d(TAG, "Model: $model")
                Log.d(TAG, "URL: $url")
                
                val request = Request.Builder()
                    .url(url)
                    .addHeader("Authorization", "Bearer $apiKey")
                    .addHeader("Content-Type", "application/json")
                    .apply {
                        // Add provider-specific headers
                        when (provider) {
                            LLMProvider.OPENROUTER -> {
                                addHeader("HTTP-Referer", "https://github.com/Ayush0Chaudhary/blurr")
                                addHeader("X-Title", "Blurr Voice Assistant")
                            }
                            else -> {}
                        }
                    }
                    .post(requestBody.toRequestBody("application/json".toMediaType()))
                    .build()
                
                val response = client.newCall(request).execute()
                
                if (response.isSuccessful) {
                    val responseBody = response.body?.string()
                    if (responseBody != null) {
                        val result = parseChatCompletionResponse(responseBody)
                        Log.d(TAG, "Success: ${result?.take(100)}...")
                        return result
                    }
                } else {
                    val errorBody = response.body?.string()
                    Log.e(TAG, "API Error (${response.code}): $errorBody")
                    lastException = Exception("API returned ${response.code}: $errorBody")
                }
                
            } catch (e: Exception) {
                Log.e(TAG, "Request failed (attempt ${attempt + 1}/$maxRetries)", e)
                lastException = e
            }
            
            if (attempt < maxRetries - 1) {
                delay(1000L * (attempt + 1)) // Exponential backoff
            }
        }
        
        Log.e(TAG, "All retry attempts failed", lastException)
        return null
    }
    
    /**
     * Builds the JSON request body for chat completion
     */
    private fun buildChatCompletionRequest(
        messages: List<Pair<String, String>>,
        images: List<Bitmap>,
        temperature: Double,
        maxTokens: Int
    ): String {
        val jsonMessages = JSONArray()
        
        messages.forEach { (role, content) ->
            val messageObj = JSONObject().apply {
                put("role", role)
                
                // If we have images and this is a user message, add vision content
                if (images.isNotEmpty() && role == "user" && provider.supportsVision) {
                    val contentArray = JSONArray()
                    
                    // Add text content
                    contentArray.put(JSONObject().apply {
                        put("type", "text")
                        put("text", content)
                    })
                    
                    // Add image content
                    images.forEach { bitmap ->
                        contentArray.put(JSONObject().apply {
                            put("type", "image_url")
                            put("image_url", JSONObject().apply {
                                put("url", "data:image/jpeg;base64,${bitmapToBase64(bitmap)}")
                            })
                        })
                    }
                    
                    put("content", contentArray)
                } else {
                    put("content", content)
                }
            }
            jsonMessages.put(messageObj)
        }
        
        return JSONObject().apply {
            put("model", model)
            put("messages", jsonMessages)
            put("temperature", temperature)
            put("max_tokens", maxTokens)
        }.toString()
    }
    
    /**
     * Parses the chat completion response
     */
    private fun parseChatCompletionResponse(responseBody: String): String? {
        return try {
            val json = JSONObject(responseBody)
            val choices = json.getJSONArray("choices")
            if (choices.length() > 0) {
                val message = choices.getJSONObject(0).getJSONObject("message")
                message.getString("content")
            } else {
                null
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to parse response", e)
            null
        }
    }
    
    /**
     * Converts a Bitmap to base64 string
     */
    private fun bitmapToBase64(bitmap: Bitmap): String {
        val outputStream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.JPEG, 80, outputStream)
        val bytes = outputStream.toByteArray()
        return Base64.encodeToString(bytes, Base64.NO_WRAP)
    }
    
    /**
     * Gets available models from the provider (if supported)
     */
    suspend fun getAvailableModels(): List<String>? {
        return try {
            val url = "${provider.baseUrl}/models"
            val request = Request.Builder()
                .url(url)
                .addHeader("Authorization", "Bearer $apiKey")
                .get()
                .build()
            
            val response = client.newCall(request).execute()
            
            if (response.isSuccessful) {
                val responseBody = response.body?.string()
                if (responseBody != null) {
                    val json = JSONObject(responseBody)
                    val data = json.getJSONArray("data")
                    val models = mutableListOf<String>()
                    for (i in 0 until data.length()) {
                        models.add(data.getJSONObject(i).getString("id"))
                    }
                    return models
                }
            }
            null
        } catch (e: Exception) {
            Log.e(TAG, "Failed to fetch models", e)
            null
        }
    }
}

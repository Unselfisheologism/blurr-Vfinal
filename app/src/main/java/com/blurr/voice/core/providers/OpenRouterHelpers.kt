package com.twent.voice.core.providers

import android.content.Context
import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.OkHttpClient
import okhttp3.Request
import org.json.JSONObject
import java.util.concurrent.TimeUnit

/**
 * OpenRouter-specific helper functions for enhanced features
 * Based on OpenRouter.ai documentation
 */
object OpenRouterHelpers {
    private const val TAG = "OpenRouterHelpers"
    private const val BASE_URL = "https://openrouter.ai/api/v1"
    
    private val client = OkHttpClient.Builder()
        .connectTimeout(10, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .build()
    
    /**
     * Fetches user's credit balance from OpenRouter
     * Useful for displaying remaining credits in UI
     */
    suspend fun getCreditBalance(apiKey: String): Double? = withContext(Dispatchers.IO) {
        return@withContext try {
            val request = Request.Builder()
                .url("$BASE_URL/auth/key")
                .addHeader("Authorization", "Bearer $apiKey")
                .get()
                .build()
            
            val response = client.newCall(request).execute()
            
            if (response.isSuccessful) {
                val json = JSONObject(response.body?.string() ?: "")
                val data = json.optJSONObject("data")
                val limit = data?.optDouble("limit")
                val usage = data?.optDouble("usage")
                
                if (limit != null && usage != null) {
                    val remaining = limit - usage
                    Log.d(TAG, "Credit balance - Limit: $$limit, Usage: $$usage, Remaining: $$remaining")
                    return@withContext remaining
                }
            } else {
                Log.e(TAG, "Failed to fetch credit balance: ${response.code}")
            }
            
            null
        } catch (e: Exception) {
            Log.e(TAG, "Error fetching credit balance", e)
            null
        }
    }
    
    /**
     * Fetches available models from OpenRouter with detailed information
     * Returns list of model IDs, names, and pricing information
     */
    suspend fun getModelsWithDetails(apiKey: String): List<ModelInfo>? = withContext(Dispatchers.IO) {
        return@withContext try {
            val request = Request.Builder()
                .url("$BASE_URL/models")
                .addHeader("Authorization", "Bearer $apiKey")
                .get()
                .build()
            
            val response = client.newCall(request).execute()
            
            if (response.isSuccessful) {
                val json = JSONObject(response.body?.string() ?: "")
                val data = json.getJSONArray("data")
                val models = mutableListOf<ModelInfo>()
                
                for (i in 0 until data.length()) {
                    val model = data.getJSONObject(i)
                    models.add(ModelInfo(
                        id = model.getString("id"),
                        name = model.optString("name", model.getString("id")),
                        description = model.optString("description", ""),
                        contextLength = model.optInt("context_length", 0),
                        pricing = ModelPricing(
                            prompt = model.optJSONObject("pricing")?.optDouble("prompt", 0.0) ?: 0.0,
                            completion = model.optJSONObject("pricing")?.optDouble("completion", 0.0) ?: 0.0,
                            image = model.optJSONObject("pricing")?.optDouble("image", 0.0) ?: 0.0
                        ),
                        supportsVision = model.optJSONArray("architecture")?.let { arch ->
                            arch.optJSONObject(0)?.optJSONArray("modality")?.toString()?.contains("image") ?: false
                        } ?: false
                    ))
                }
                
                Log.d(TAG, "Fetched ${models.size} models from OpenRouter")
                return@withContext models
            } else {
                Log.e(TAG, "Failed to fetch models: ${response.code}")
            }
            
            null
        } catch (e: Exception) {
            Log.e(TAG, "Error fetching models", e)
            null
        }
    }
    
    /**
     * Gets generation details by ID (useful for debugging and cost tracking)
     */
    suspend fun getGenerationDetails(apiKey: String, generationId: String): GenerationDetails? = withContext(Dispatchers.IO) {
        return@withContext try {
            val request = Request.Builder()
                .url("$BASE_URL/generation?id=$generationId")
                .addHeader("Authorization", "Bearer $apiKey")
                .get()
                .build()
            
            val response = client.newCall(request).execute()
            
            if (response.isSuccessful) {
                val json = JSONObject(response.body?.string() ?: "")
                val data = json.optJSONObject("data")
                
                if (data != null) {
                    return@withContext GenerationDetails(
                        id = data.getString("id"),
                        model = data.optString("model", ""),
                        promptTokens = data.optInt("tokens_prompt", 0),
                        completionTokens = data.optInt("tokens_completion", 0),
                        totalCost = data.optDouble("total_cost", 0.0),
                        createdAt = data.optString("created_at", "")
                    )
                }
            } else {
                Log.e(TAG, "Failed to fetch generation details: ${response.code}")
            }
            
            null
        } catch (e: Exception) {
            Log.e(TAG, "Error fetching generation details", e)
            null
        }
    }
    
    /**
     * Data classes for OpenRouter-specific information
     */
    data class ModelInfo(
        val id: String,
        val name: String,
        val description: String,
        val contextLength: Int,
        val pricing: ModelPricing,
        val supportsVision: Boolean
    )
    
    data class ModelPricing(
        val prompt: Double,      // Cost per 1M tokens
        val completion: Double,  // Cost per 1M tokens
        val image: Double        // Cost per image
    )
    
    data class GenerationDetails(
        val id: String,
        val model: String,
        val promptTokens: Int,
        val completionTokens: Int,
        val totalCost: Double,
        val createdAt: String
    )
    
    /**
     * Recommended free models on OpenRouter (updated list)
     */
    fun getFreeModels(): List<String> {
        return listOf(
            "google/gemini-2.0-flash-exp:free",
            "google/gemini-flash-1.5:free",
            "meta-llama/llama-3.1-8b-instruct:free",
            "mistralai/mistral-7b-instruct:free",
            "nousresearch/hermes-3-llama-3.1-405b:free",
            "microsoft/phi-3-mini-128k-instruct:free"
        )
    }
    
    /**
     * Recommended models for different use cases
     */
    fun getRecommendedModels(): Map<String, List<String>> {
        return mapOf(
            "fastest" to listOf(
                "google/gemini-2.0-flash-exp:free",
                "anthropic/claude-3-haiku",
                "openai/gpt-4o-mini"
            ),
            "best_quality" to listOf(
                "anthropic/claude-3.5-sonnet",
                "openai/gpt-4o",
                "google/gemini-pro-1.5"
            ),
            "best_value" to listOf(
                "google/gemini-2.0-flash-exp:free",
                "meta-llama/llama-3.1-70b-instruct",
                "deepseek/deepseek-chat"
            ),
            "vision" to listOf(
                "openai/gpt-4o",
                "anthropic/claude-3.5-sonnet",
                "google/gemini-pro-1.5-vision"
            ),
            "long_context" to listOf(
                "google/gemini-pro-1.5",
                "anthropic/claude-3.5-sonnet",
                "cohere/command-r-plus"
            )
        )
    }
}

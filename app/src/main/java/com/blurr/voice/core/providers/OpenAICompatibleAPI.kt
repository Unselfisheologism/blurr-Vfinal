package com.blurr.voice.core.providers

import android.graphics.Bitmap
import android.util.Base64
import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONArray
import org.json.JSONObject
import java.io.BufferedReader
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
     * @param options Advanced OpenRouter request options (provider routing, transforms, etc.)
     * @return Generated text response or null on failure
     */
    suspend fun generateChatCompletion(
        messages: List<Pair<String, String>>,
        images: List<Bitmap> = emptyList(),
        temperature: Double = 0.7,
        maxTokens: Int = 4096,
        options: OpenRouterRequestOptions? = null
    ): String? {
        var lastException: Exception? = null
        
        repeat(maxRetries) { attempt ->
            try {
                val requestBody = buildChatCompletionRequest(messages, images, temperature, maxTokens, options)
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
                                // Required for OpenRouter rankings and analytics
                                addHeader("HTTP-Referer", "https://github.com/Ayush0Chaudhary/blurr")
                                addHeader("X-Title", "Blurr AI Assistant")
                                // Optional: Add user identifier for better analytics
                                // addHeader("X-User-ID", userId)
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
        maxTokens: Int,
        options: OpenRouterRequestOptions?
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
            
            // Apply advanced request options if provided
            options?.let { opts ->
                // Sampling parameters
                opts.topP?.let { put("top_p", it) }
                opts.topK?.let { put("top_k", it) }
                opts.frequencyPenalty?.let { put("frequency_penalty", it) }
                opts.presencePenalty?.let { put("presence_penalty", it) }
                opts.repetitionPenalty?.let { put("repetition_penalty", it) }
                opts.minP?.let { put("min_p", it) }
                opts.topA?.let { put("top_a", it) }
                opts.seed?.let { put("seed", it) }
                opts.n?.let { put("n", it) }
                
                // Stop sequences
                opts.stopSequences?.let { 
                    put("stop", JSONArray(it)) 
                }
                
                // Response format
                opts.responseFormat?.let { format ->
                    put("response_format", JSONObject().apply {
                        put("type", format.value)
                    })
                }
                
                // Log probabilities (AIMLAPI/OpenAI)
                opts.logprobs?.let { put("logprobs", it) }
                opts.topLogprobs?.let { put("top_logprobs", it) }
                opts.logitBias?.let { bias ->
                    put("logit_bias", JSONObject().apply {
                        bias.forEach { (tokenId, biasValue) ->
                            put(tokenId.toString(), biasValue)
                        }
                    })
                }
                
                // Function calling / Tools
                val allTools = JSONArray()
                
                // Add regular function tools
                opts.tools?.forEach { tool ->
                    allTools.put(tool.toJson())
                }
                
                // Add built-in function tools (AIMLAPI-specific)
                opts.builtInTools?.forEach { tool ->
                    allTools.put(tool.toJson())
                }
                
                // Add web search if enabled (AIMLAPI convenience)
                if (opts.enableWebSearch) {
                    allTools.put(BuiltInFunctionTool.WEB_SEARCH.toJson())
                }
                
                if (allTools.length() > 0) {
                    put("tools", allTools)
                }
                
                // Tool choice
                opts.toolChoice?.let { choice ->
                    when (val json = choice.toJson()) {
                        is String -> put("tool_choice", json)
                        is JSONObject -> put("tool_choice", json)
                    }
                }
                
                // Thinking/Reasoning (AIMLAPI-specific)
                opts.enableThinking?.let { put("enable_thinking", it) }
                
                // Provider-specific parameters
                opts.reasoningEffort?.let { put("reasoning_effort", it) }
                opts.serviceTier?.let { put("service_tier", it) }
                opts.verbosity?.let { put("verbosity", it) }
                opts.promptTruncateLen?.let { put("prompt_truncate_len", it) }
                opts.includeReasoning?.let { put("include_reasoning", it) }
                opts.reasoningFormat?.let { put("reasoning_format", it) }
                opts.store?.let { put("store", it) }
                
                // Search settings (Groq Compound models)
                opts.searchSettings?.let { settings ->
                    put("search_settings", settings.toJson())
                }
            }
            
            // OpenRouter-specific optimizations
            if (provider == LLMProvider.OPENROUTER) {
                // Provider routing preferences
                val providerPrefs = options?.providerPreferences ?: ProviderPreferences.default()
                put("provider", JSONObject().apply {
                    put("allow_fallbacks", providerPrefs.allowFallbacks)
                    
                    providerPrefs.order?.let { 
                        put("order", JSONArray(it)) 
                    }
                    providerPrefs.requireParameters.let {
                        if (it) put("require_parameters", it)
                    }
                    providerPrefs.dataCollection?.let { 
                        put("data_collection", it.value) 
                    }
                    providerPrefs.zdr?.let { 
                        put("zdr", it) 
                    }
                    providerPrefs.only?.let { 
                        put("only", JSONArray(it)) 
                    }
                    providerPrefs.ignore?.let { 
                        put("ignore", JSONArray(it)) 
                    }
                    providerPrefs.quantizations?.let { 
                        put("quantizations", JSONArray(it)) 
                    }
                    providerPrefs.sort?.let { 
                        put("sort", it) 
                    }
                })
                
                // Prompt transforms for cost optimization
                if (options?.enableTransforms == true) {
                    put("transforms", JSONArray().apply {
                        put("middle-out")
                    })
                }
            }
        }.toString()
    }
    
    /**
     * Parses the chat completion response
     */
    private fun parseChatCompletionResponse(responseBody: String): String? {
        return try {
            val json = JSONObject(responseBody)
            Log.d(TAG, "Response received: ${json.toString(2).take(500)}...")
            
            val choices = json.getJSONArray("choices")
            if (choices.length() > 0) {
                val choice = choices.getJSONObject(0)
                val message = choice.getJSONObject("message")
                
                // Check for tool calls (function calling)
                if (message.has("tool_calls")) {
                    val toolCalls = message.getJSONArray("tool_calls")
                    Log.d(TAG, "Model requested ${toolCalls.length()} tool call(s)")
                    
                    // Log tool call details
                    for (i in 0 until toolCalls.length()) {
                        val toolCall = toolCalls.getJSONObject(i)
                        val toolCallId = toolCall.getString("id")
                        val function = toolCall.getJSONObject("function")
                        val functionName = function.getString("name")
                        val arguments = function.getString("arguments")
                        Log.d(TAG, "Tool call [$toolCallId]: $functionName($arguments)")
                    }
                    
                    // Return a formatted message indicating tool calls
                    val toolCallsList = StringBuilder("[Function Calls Requested]\n\n")
                    for (i in 0 until toolCalls.length()) {
                        val toolCall = toolCalls.getJSONObject(i)
                        val function = toolCall.getJSONObject("function")
                        toolCallsList.append("${function.getString("name")}:\n")
                        toolCallsList.append("  ${function.getString("arguments")}\n\n")
                    }
                    return toolCallsList.toString()
                }
                
                // Get content (may be null for tool-only responses)
                val content = message.optString("content", "")
                
                // Log reasoning content if present (AIMLAPI thinking mode)
                if (message.has("reasoning_content")) {
                    val reasoning = message.optString("reasoning_content", "")
                    if (reasoning.isNotEmpty()) {
                        Log.d(TAG, "Model reasoning: ${reasoning.take(200)}...")
                        // Optionally prepend reasoning to response for debugging
                        // return "[Reasoning: $reasoning]\n\n$content"
                    }
                }
                
                // Log usage information if available (helpful for cost tracking)
                if (json.has("usage")) {
                    val usage = json.getJSONObject("usage")
                    val promptTokens = usage.optInt("prompt_tokens", 0)
                    val completionTokens = usage.optInt("completion_tokens", 0)
                    val totalTokens = usage.optInt("total_tokens", 0)
                    
                    // Log reasoning tokens if present (thinking mode)
                    if (usage.has("completion_tokens_details")) {
                        val details = usage.getJSONObject("completion_tokens_details")
                        val reasoningTokens = details.optInt("reasoning_tokens", 0)
                        if (reasoningTokens > 0) {
                            Log.d(TAG, "Token usage - Prompt: $promptTokens, Completion: $completionTokens (Reasoning: $reasoningTokens), Total: $totalTokens")
                        } else {
                            Log.d(TAG, "Token usage - Prompt: $promptTokens, Completion: $completionTokens, Total: $totalTokens")
                        }
                    } else {
                        Log.d(TAG, "Token usage - Prompt: $promptTokens, Completion: $completionTokens, Total: $totalTokens")
                    }
                }
                
                // OpenRouter-specific: Log generation ID for debugging
                if (provider == LLMProvider.OPENROUTER && json.has("id")) {
                    val generationId = json.getString("id")
                    Log.d(TAG, "OpenRouter generation ID: $generationId")
                }
                
                // Log finish reason
                val finishReason = choice.optString("finish_reason", "unknown")
                if (finishReason == "tool_calls") {
                    Log.d(TAG, "Completion stopped for tool calls")
                } else if (finishReason != "stop" && finishReason != "unknown") {
                    Log.d(TAG, "Finish reason: $finishReason")
                }
                
                return content
            } else {
                null
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to parse response", e)
            null
        }
    }
    
    /**
     * Generates streaming chat completion with real-time token-by-token responses
     * @param messages List of message pairs (role, content)
     * @param images Optional list of images for vision-capable models
     * @param temperature Temperature for response generation (0.0 - 2.0)
     * @param maxTokens Maximum tokens in response
     * @param options Advanced OpenRouter request options
     * @return Flow of text chunks as they arrive
     */
    suspend fun generateStreamingChatCompletion(
        messages: List<Pair<String, String>>,
        images: List<Bitmap> = emptyList(),
        temperature: Double = 0.7,
        maxTokens: Int = 4096,
        options: OpenRouterRequestOptions? = null
    ): Flow<String> = flow {
        withContext(Dispatchers.IO) {
            try {
                val requestBody = buildStreamingChatCompletionRequest(
                    messages, images, temperature, maxTokens, options
                )
                val url = "${provider.baseUrl}/chat/completions"
                
                Log.d(TAG, "Streaming request to ${provider.displayName}")
                Log.d(TAG, "Model: $model")
                
                val request = Request.Builder()
                    .url(url)
                    .addHeader("Authorization", "Bearer $apiKey")
                    .addHeader("Content-Type", "application/json")
                    .addHeader("Accept", "text/event-stream")
                    .apply {
                        when (provider) {
                            LLMProvider.OPENROUTER -> {
                                addHeader("HTTP-Referer", "https://github.com/Ayush0Chaudhary/blurr")
                                addHeader("X-Title", "Blurr AI Assistant")
                            }
                            else -> {}
                        }
                    }
                    .post(requestBody.toRequestBody("application/json".toMediaType()))
                    .build()
                
                val response = client.newCall(request).execute()
                
                if (response.isSuccessful) {
                    response.body?.charStream()?.buffered()?.use { reader ->
                        parseStreamingResponse(reader) { chunk ->
                            emit(chunk)
                        }
                    }
                } else {
                    val errorBody = response.body?.string()
                    Log.e(TAG, "Streaming API Error (${response.code}): $errorBody")
                    throw Exception("API returned ${response.code}: $errorBody")
                }
            } catch (e: Exception) {
                Log.e(TAG, "Streaming request failed", e)
                throw e
            }
        }
    }
    
    /**
     * Builds the JSON request body for streaming chat completion
     */
    private fun buildStreamingChatCompletionRequest(
        messages: List<Pair<String, String>>,
        images: List<Bitmap>,
        temperature: Double,
        maxTokens: Int,
        options: OpenRouterRequestOptions?
    ): String {
        // Use the same request builder but add stream=true
        val baseRequest = buildChatCompletionRequest(messages, images, temperature, maxTokens, options)
        val jsonRequest = JSONObject(baseRequest)
        jsonRequest.put("stream", true)
        
        // Add stream options to include usage in final message
        jsonRequest.put("stream_options", JSONObject().apply {
            put("include_usage", true)
        })
        
        return jsonRequest.toString()
    }
    
    /**
     * Parses Server-Sent Events (SSE) from streaming response
     */
    private suspend fun parseStreamingResponse(
        reader: BufferedReader,
        onChunk: suspend (String) -> Unit
    ) {
        var line: String?
        while (reader.readLine().also { line = it } != null) {
            val currentLine = line ?: continue
            
            // SSE format: "data: {json}"
            if (currentLine.startsWith("data: ")) {
                val data = currentLine.substring(6).trim()
                
                // Check for stream end
                if (data == "[DONE]") {
                    Log.d(TAG, "Streaming completed")
                    break
                }
                
                try {
                    val json = JSONObject(data)
                    val choices = json.optJSONArray("choices")
                    
                    if (choices != null && choices.length() > 0) {
                        val choice = choices.getJSONObject(0)
                        val delta = choice.optJSONObject("delta")
                        
                        if (delta != null) {
                            val content = delta.optString("content", "")
                            if (content.isNotEmpty()) {
                                onChunk(content)
                            }
                        }
                        
                        // Check for finish reason
                        val finishReason = choice.optString("finish_reason")
                        if (finishReason == "stop" || finishReason == "length") {
                            Log.d(TAG, "Stream finished: $finishReason")
                        }
                    }
                    
                    // Log usage information if present (comes in final message)
                    if (json.has("usage")) {
                        val usage = json.getJSONObject("usage")
                        val promptTokens = usage.optInt("prompt_tokens", 0)
                        val completionTokens = usage.optInt("completion_tokens", 0)
                        val totalTokens = usage.optInt("total_tokens", 0)
                        Log.d(TAG, "Stream usage - Prompt: $promptTokens, Completion: $completionTokens, Total: $totalTokens")
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Error parsing streaming chunk: $data", e)
                }
            }
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
     * Convenience method: Generates chat completion optimized for agentic AI
     * Uses default agentic settings (cost optimization, reduced repetition, exploration)
     */
    suspend fun generateAgenticChatCompletion(
        messages: List<Pair<String, String>>,
        images: List<Bitmap> = emptyList(),
        temperature: Double = 0.7,
        maxTokens: Int = 4096
    ): String? {
        return generateChatCompletion(
            messages,
            images,
            temperature,
            maxTokens,
            OpenRouterRequestOptions.agenticOptimized()
        )
    }
    
    /**
     * Convenience method: Generates chat completion with privacy-focused routing
     * Uses ZDR providers only with no data collection
     */
    suspend fun generatePrivateChatCompletion(
        messages: List<Pair<String, String>>,
        images: List<Bitmap> = emptyList(),
        temperature: Double = 0.7,
        maxTokens: Int = 4096
    ): String? {
        return generateChatCompletion(
            messages,
            images,
            temperature,
            maxTokens,
            OpenRouterRequestOptions(
                providerPreferences = ProviderPreferences.privacyFocused()
            )
        )
    }
    
    /**
     * Convenience method: Generates chat completion optimized for cost
     * Uses cheapest providers and enables prompt compression
     */
    suspend fun generateCostOptimizedChatCompletion(
        messages: List<Pair<String, String>>,
        images: List<Bitmap> = emptyList(),
        temperature: Double = 0.7,
        maxTokens: Int = 4096
    ): String? {
        return generateChatCompletion(
            messages,
            images,
            temperature,
            maxTokens,
            OpenRouterRequestOptions(
                providerPreferences = ProviderPreferences.costOptimized(),
                enableTransforms = true
            )
        )
    }
    
    /**
     * Convenience method: Generates structured JSON output
     * Optimized for function calling and structured data extraction
     */
    suspend fun generateStructuredOutput(
        messages: List<Pair<String, String>>,
        maxTokens: Int = 4096
    ): String? {
        return generateChatCompletion(
            messages,
            emptyList(),
            0.3,  // Lower temperature for deterministic output
            maxTokens,
            OpenRouterRequestOptions.structuredOutput()
        )
    }
    
    /**
     * Convenience method: Streaming with agentic AI optimization
     */
    suspend fun generateAgenticStreamingChatCompletion(
        messages: List<Pair<String, String>>,
        images: List<Bitmap> = emptyList(),
        temperature: Double = 0.7,
        maxTokens: Int = 4096
    ): Flow<String> {
        return generateStreamingChatCompletion(
            messages,
            images,
            temperature,
            maxTokens,
            OpenRouterRequestOptions.agenticOptimized()
        )
    }
    
    /**
     * Convenience method: Function calling with web search (AIMLAPI)
     * Enables the model to search the web for current information
     */
    suspend fun generateWithWebSearch(
        messages: List<Pair<String, String>>,
        temperature: Double = 0.7,
        maxTokens: Int = 4096
    ): String? {
        return generateChatCompletion(
            messages,
            emptyList(),
            temperature,
            maxTokens,
            OpenRouterRequestOptions(
                enableWebSearch = true,
                toolChoice = ToolChoice.Auto
            )
        )
    }
    
    /**
     * Convenience method: Thinking/Reasoning mode (AIMLAPI)
     * Enables the model's reasoning process for transparency
     */
    suspend fun generateWithThinking(
        messages: List<Pair<String, String>>,
        images: List<Bitmap> = emptyList(),
        temperature: Double = 0.7,
        maxTokens: Int = 4096
    ): String? {
        return generateChatCompletion(
            messages,
            images,
            temperature,
            maxTokens,
            OpenRouterRequestOptions(
                enableThinking = true
            )
        )
    }
    
    /**
     * Convenience method: Function calling with custom tools
     * For agentic workflows with external tool integration
     */
    suspend fun generateWithTools(
        messages: List<Pair<String, String>>,
        tools: List<FunctionTool>,
        toolChoice: ToolChoice = ToolChoice.Auto,
        temperature: Double = 0.7,
        maxTokens: Int = 4096
    ): String? {
        return generateChatCompletion(
            messages,
            emptyList(),
            temperature,
            maxTokens,
            OpenRouterRequestOptions(
                tools = tools,
                toolChoice = toolChoice
            )
        )
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
    
    /**
     * Generate image using provider's image generation API
     */
    suspend fun generateImage(requestBody: JSONObject): String? = withContext(Dispatchers.IO) {
        try {
            val url = "${provider.baseUrl}/images/generations"
            val request = Request.Builder()
                .url(url)
                .addHeader("Authorization", "Bearer $apiKey")
                .addHeader("Content-Type", "application/json")
                .post(requestBody.toString().toRequestBody("application/json".toMediaType()))
                .build()
            
            val response = client.newCall(request).execute()
            
            if (response.isSuccessful) {
                response.body?.string()
            } else {
                Log.e(TAG, "Image generation failed: ${response.code} ${response.message}")
                null
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error generating image", e)
            null
        }
    }
    
    /**
     * Generate video (async) - returns job ID
     */
    suspend fun generateVideo(requestBody: JSONObject): String? = withContext(Dispatchers.IO) {
        try {
            val url = "${provider.baseUrl}/video/generations"
            val request = Request.Builder()
                .url(url)
                .addHeader("Authorization", "Bearer $apiKey")
                .addHeader("Content-Type", "application/json")
                .post(requestBody.toString().toRequestBody("application/json".toMediaType()))
                .build()
            
            val response = client.newCall(request).execute()
            
            if (response.isSuccessful) {
                response.body?.string()
            } else {
                Log.e(TAG, "Video generation failed: ${response.code}")
                null
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error generating video", e)
            null
        }
    }
    
    /**
     * Check video generation status
     */
    suspend fun checkVideoStatus(jobId: String): String? = withContext(Dispatchers.IO) {
        try {
            val url = "${provider.baseUrl}/video/generations/$jobId"
            val request = Request.Builder()
                .url(url)
                .addHeader("Authorization", "Bearer $apiKey")
                .get()
                .build()
            
            val response = client.newCall(request).execute()
            
            if (response.isSuccessful) {
                response.body?.string()
            } else {
                null
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error checking video status", e)
            null
        }
    }
    
    /**
     * Generate audio/TTS
     */
    suspend fun generateAudio(requestBody: JSONObject): String? = withContext(Dispatchers.IO) {
        try {
            val url = "${provider.baseUrl}/audio/speech"
            val request = Request.Builder()
                .url(url)
                .addHeader("Authorization", "Bearer $apiKey")
                .addHeader("Content-Type", "application/json")
                .post(requestBody.toString().toRequestBody("application/json".toMediaType()))
                .build()
            
            val response = client.newCall(request).execute()
            
            if (response.isSuccessful) {
                // Audio APIs typically return binary data directly
                response.body?.string()
            } else {
                Log.e(TAG, "Audio generation failed: ${response.code}")
                null
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error generating audio", e)
            null
        }
    }
    
    /**
     * Generate music (async) - returns job ID
     */
    suspend fun generateMusic(requestBody: JSONObject): String? = withContext(Dispatchers.IO) {
        try {
            val url = "${provider.baseUrl}/music/generations"
            val request = Request.Builder()
                .url(url)
                .addHeader("Authorization", "Bearer $apiKey")
                .addHeader("Content-Type", "application/json")
                .post(requestBody.toString().toRequestBody("application/json".toMediaType()))
                .build()
            
            val response = client.newCall(request).execute()
            
            if (response.isSuccessful) {
                response.body?.string()
            } else {
                Log.e(TAG, "Music generation failed: ${response.code}")
                null
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error generating music", e)
            null
        }
    }
    
    /**
     * Check music generation status
     */
    suspend fun checkMusicStatus(jobId: String): String? = withContext(Dispatchers.IO) {
        try {
            val url = "${provider.baseUrl}/music/generations/$jobId"
            val request = Request.Builder()
                .url(url)
                .addHeader("Authorization", "Bearer $apiKey")
                .get()
                .build()
            
            val response = client.newCall(request).execute()
            
            if (response.isSuccessful) {
                response.body?.string()
            } else {
                null
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error checking music status", e)
            null
        }
    }
    
    /**
     * Generate 3D model (async) - returns job ID
     */
    suspend fun generate3DModel(requestBody: JSONObject): String? = withContext(Dispatchers.IO) {
        try {
            val url = "${provider.baseUrl}/3d/generations"
            val request = Request.Builder()
                .url(url)
                .addHeader("Authorization", "Bearer $apiKey")
                .addHeader("Content-Type", "application/json")
                .post(requestBody.toString().toRequestBody("application/json".toMediaType()))
                .build()
            
            val response = client.newCall(request).execute()
            
            if (response.isSuccessful) {
                response.body?.string()
            } else {
                Log.e(TAG, "3D model generation failed: ${response.code}")
                null
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error generating 3D model", e)
            null
        }
    }
    
    /**
     * Check 3D model generation status
     */
    suspend fun check3DModelStatus(jobId: String): String? = withContext(Dispatchers.IO) {
        try {
            val url = "${provider.baseUrl}/3d/generations/$jobId"
            val request = Request.Builder()
                .url(url)
                .addHeader("Authorization", "Bearer $apiKey")
                .get()
                .build()
            
            val response = client.newCall(request).execute()
            
            if (response.isSuccessful) {
                response.body?.string()
            } else {
                null
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error checking 3D model status", e)
            null
        }
    }
}

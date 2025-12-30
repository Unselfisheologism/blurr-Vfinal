package com.blurr.voice.core.providers

import org.json.JSONArray
import org.json.JSONObject

/**
 * OpenRouter-specific configuration and constants
 * Based on OpenRouter.ai official documentation
 */
object OpenRouterConfig {
    
    /**
     * Provider routing strategies
     * See: https://openrouter.ai/docs/features/provider-routing
     */
    enum class RoutingStrategy(val value: String) {
        /**
         * Tries multiple providers if the primary fails
         * Recommended for production
         */
        FALLBACK("fallback"),
        
        /**
         * Routes to the provider with the lowest queue
         * Best for latency-sensitive applications
         */
        LEAST_BUSY("least-busy"),
        
        /**
         * Routes to the cheapest provider
         * Best for cost optimization
         */
        BEST_PRICE("best-price")
    }
    
    /**
     * Transform options for enhanced responses
     * See: https://openrouter.ai/docs/transforms
     */
    enum class Transform(val value: String) {
        /**
         * Compresses prompts while maintaining quality
         * Can reduce costs by 30-50% for large prompts
         */
        MIDDLE_OUT("middle-out")
    }
    
    /**
     * Popular model categories with recommended models
     */
    object PopularModels {
        // Free tier models (great for testing and demos)
        val FREE = listOf(
            "google/gemini-2.0-flash-exp:free",
            "google/gemini-flash-1.5:free",
            "meta-llama/llama-3.1-8b-instruct:free",
            "mistralai/mistral-7b-instruct:free",
            "nousresearch/hermes-3-llama-3.1-405b:free"
        )
        
        // Fast and efficient models
        val FAST = listOf(
            "google/gemini-2.0-flash-exp:free",
            "anthropic/claude-3-haiku",
            "openai/gpt-4o-mini",
            "meta-llama/llama-3.1-70b-instruct"
        )
        
        // Highest quality models
        val PREMIUM = listOf(
            "anthropic/claude-3.5-sonnet",
            "openai/gpt-4o",
            "google/gemini-pro-1.5",
            "deepseek/deepseek-v3"
        )
        
        // Best value (quality per cost)
        val VALUE = listOf(
            "google/gemini-2.0-flash-exp:free",
            "deepseek/deepseek-chat",
            "meta-llama/llama-3.1-70b-instruct",
            "qwen/qwen-2.5-72b-instruct"
        )
        
        // Vision-capable models
        val VISION = listOf(
            "openai/gpt-4o",
            "anthropic/claude-3.5-sonnet",
            "google/gemini-pro-1.5-vision",
            "meta-llama/llama-3.2-90b-vision-instruct"
        )
        
        // Long context models (100k+ tokens)
        val LONG_CONTEXT = listOf(
            "google/gemini-pro-1.5",
            "anthropic/claude-3.5-sonnet",
            "cohere/command-r-plus"
        )
        
        // Coding specialists
        val CODING = listOf(
            "deepseek/deepseek-chat",
            "anthropic/claude-3.5-sonnet",
            "qwen/qwen-2.5-coder-32b-instruct"
        )
    }
    
    /**
     * Default settings for OpenRouter requests
     */
    object Defaults {
        const val ROUTING_STRATEGY = "fallback"  // Safe default
        const val TEMPERATURE = 0.7
        const val MAX_TOKENS = 4096
        const val TOP_P = 1.0
        
        // Recommended headers
        const val HTTP_REFERER = "https://github.com/Ayush0Chaudhary/blurr"
        const val X_TITLE = "Blurr AI Assistant"
    }
    
    /**
     * Data collection policy for privacy-focused routing
     */
    enum class DataCollectionPolicy(val value: String) {
        ALLOW("allow"),
        DENY("deny")
    }
    
    /**
     * Response format types
     */
    enum class ResponseFormat(val value: String) {
        TEXT("text"),
        JSON_OBJECT("json_object")
    }
    
    /**
     * Error codes specific to OpenRouter
     */
    object ErrorCodes {
        const val INSUFFICIENT_CREDITS = 402
        const val MODEL_NOT_FOUND = 404
        const val RATE_LIMIT = 429
        const val MODEL_OVERLOADED = 503
    }
    
    /**
     * API endpoints
     */
    object Endpoints {
        const val BASE_URL = "https://openrouter.ai/api/v1"
        const val CHAT_COMPLETIONS = "/chat/completions"
        const val MODELS = "/models"
        const val AUTH_KEY = "/auth/key"
        const val GENERATION = "/generation"
    }
    
    /**
     * Get model description for UI
     */
    fun getModelDescription(modelId: String): String {
        return when {
            modelId.contains("gemini") && modelId.contains("free") -> 
                "Google's fast model - Free tier"
            modelId.contains("claude-3.5-sonnet") -> 
                "Anthropic's most intelligent model"
            modelId.contains("gpt-4o") -> 
                "OpenAI's flagship multimodal model"
            modelId.contains("deepseek") -> 
                "Excellent for coding and reasoning"
            modelId.contains("llama") -> 
                "Meta's open-source model family"
            modelId.contains("mistral") -> 
                "Mistral AI's efficient models"
            modelId.contains("qwen") -> 
                "Alibaba's multilingual models"
            else -> "AI model via OpenRouter"
        }
    }
    
    /**
     * Estimate cost for a request (rough estimate)
     * Returns cost in USD
     */
    fun estimateCost(
        modelId: String,
        promptTokens: Int,
        completionTokens: Int,
        promptPricePerMillion: Double,
        completionPricePerMillion: Double
    ): Double {
        val promptCost = (promptTokens / 1_000_000.0) * promptPricePerMillion
        val completionCost = (completionTokens / 1_000_000.0) * completionPricePerMillion
        return promptCost + completionCost
    }
}

/**
 * Provider routing preferences for fine-grained control over request routing
 */
data class ProviderPreferences(
    /**
     * List of provider slugs to try in order (e.g., ["anthropic", "openai"])
     */
    val order: List<String>? = null,
    
    /**
     * Whether to allow backup providers when primary fails
     */
    val allowFallbacks: Boolean = true,
    
    /**
     * Only use providers that support all parameters in request
     */
    val requireParameters: Boolean = false,
    
    /**
     * Control whether to use providers that may store data
     */
    val dataCollection: OpenRouterConfig.DataCollectionPolicy? = null,
    
    /**
     * Restrict routing to only ZDR (Zero Data Retention) endpoints
     */
    val zdr: Boolean? = null,
    
    /**
     * List of provider slugs to exclusively allow
     */
    val only: List<String>? = null,
    
    /**
     * List of provider slugs to exclude
     */
    val ignore: List<String>? = null,
    
    /**
     * List of quantization levels to filter by (e.g., ["int4", "int8", "fp8"])
     */
    val quantizations: List<String>? = null,
    
    /**
     * Sort providers by routing priority ("price" or "throughput")
     */
    val sort: String? = null
) {
    companion object {
        /**
         * Privacy-focused routing (ZDR only, no data collection)
         */
        fun privacyFocused() = ProviderPreferences(
            dataCollection = OpenRouterConfig.DataCollectionPolicy.DENY,
            zdr = true,
            allowFallbacks = true
        )
        
        /**
         * Cost-optimized routing (cheapest providers first)
         */
        fun costOptimized() = ProviderPreferences(
            sort = "price",
            allowFallbacks = true
        )
        
        /**
         * Performance-optimized routing (fastest providers first)
         */
        fun performanceOptimized() = ProviderPreferences(
            sort = "throughput",
            allowFallbacks = true
        )
        
        /**
         * Default fallback routing (recommended for agentic apps)
         */
        fun default() = ProviderPreferences(
            allowFallbacks = true
        )
    }
}

/**
 * Tool/Function definition for function calling
 */
data class FunctionTool(
    val name: String,
    val description: String,
    val parameters: Map<String, Any>
) {
    fun toJson(): JSONObject {
        return JSONObject().apply {
            put("type", "function")
            put("function", JSONObject().apply {
                put("name", name)
                put("description", description)
                put("parameters", JSONObject(parameters))
            })
        }
    }
}

/**
 * Built-in function tool (AIMLAPI-specific)
 */
data class BuiltInFunctionTool(
    val name: String  // e.g., "$web_search"
) {
    fun toJson(): JSONObject {
        return JSONObject().apply {
            put("type", "builtin_function")
            put("function", JSONObject().apply {
                put("name", name)
            })
        }
    }
    
    companion object {
        val WEB_SEARCH = BuiltInFunctionTool("\$web_search")
    }
}

/**
 * Search settings for web search functionality (Groq Compound models)
 */
data class SearchSettings(
    /**
     * List of domains to include in search results
     */
    val includeDomains: List<String>? = null
) {
    fun toJson(): JSONObject {
        return JSONObject().apply {
            includeDomains?.let { 
                put("include_domains", JSONArray(it))
            }
        }
    }
}

/**
 * Tool choice strategy
 */
sealed class ToolChoice {
    object Auto : ToolChoice()
    object None : ToolChoice()
    data class Function(val name: String) : ToolChoice()
    
    fun toJson(): Any {
        return when (this) {
            is Auto -> "auto"
            is None -> "none"
            is Function -> JSONObject().apply {
                put("type", "function")
                put("function", JSONObject().apply {
                    put("name", name)
                })
            }
        }
    }
}

/**
 * Advanced request options for OpenRouter API
 */
data class OpenRouterRequestOptions(
    /**
     * Provider routing preferences
     */
    val providerPreferences: ProviderPreferences? = null,
    
    /**
     * Enable prompt transforms (e.g., "middle-out" for 30-50% cost savings)
     */
    val enableTransforms: Boolean = false,
    
    /**
     * Nucleus sampling parameter (0, 1]
     */
    val topP: Double? = null,
    
    /**
     * Top-k sampling [1, Infinity)
     */
    val topK: Int? = null,
    
    /**
     * Reduce repetition [-2, 2]
     */
    val frequencyPenalty: Double? = null,
    
    /**
     * Encourage new topics [-2, 2]
     */
    val presencePenalty: Double? = null,
    
    /**
     * Additional repetition control (0, 2]
     */
    val repetitionPenalty: Double? = null,
    
    /**
     * Stop sequences (up to 4 sequences)
     */
    val stopSequences: List<String>? = null,
    
    /**
     * Integer seed for reproducible sampling
     */
    val seed: Int? = null,
    
    /**
     * Response format control
     */
    val responseFormat: OpenRouterConfig.ResponseFormat? = null,
    
    /**
     * Minimum probability threshold [0, 1]
     */
    val minP: Double? = null,
    
    /**
     * Top-a sampling parameter [0, 1]
     */
    val topA: Double? = null,
    
    /**
     * Function calling tools (for both OpenRouter and AIMLAPI)
     */
    val tools: List<FunctionTool>? = null,
    
    /**
     * Built-in function tools (AIMLAPI-specific, e.g., web search)
     */
    val builtInTools: List<BuiltInFunctionTool>? = null,
    
    /**
     * Tool choice strategy
     */
    val toolChoice: ToolChoice? = null,
    
    /**
     * Enable thinking/reasoning (AIMLAPI-specific for O1-style models)
     */
    val enableThinking: Boolean? = null,
    
    /**
     * Enable web search (AIMLAPI convenience - sets builtin web search tool)
     */
    val enableWebSearch: Boolean = false,
    
    /**
     * Return log probabilities (AIMLAPI/OpenAI)
     */
    val logprobs: Boolean? = null,
    
    /**
     * Number of top log probabilities to return [0, 20]
     */
    val topLogprobs: Int? = null,
    
    /**
     * Token bias map (token ID -> bias value)
     */
    val logitBias: Map<Int, Double>? = null,
    
    /**
     * Number of completions to generate
     */
    val n: Int? = null,
    
    /**
     * Reasoning effort level (Groq, Together AI, OpenAI for O1-style models)
     * Values: "low", "medium", "high", "none", "default"
     */
    val reasoningEffort: String? = null,
    
    /**
     * Service tier for request (Groq-specific for flex processing)
     * Values: "auto", "on_demand", "flex", "performance"
     */
    val serviceTier: String? = null,
    
    /**
     * Verbosity level for response (OpenAI-specific)
     * Values: "low", "medium", "high"
     */
    val verbosity: String? = null,
    
    /**
     * Prompt truncation length in tokens (Fireworks AI-specific)
     * Truncates chat prompts to fit in context window
     */
    val promptTruncateLen: Int? = null,
    
    /**
     * Include reasoning in response (Groq-specific)
     * If true, response includes reasoning field
     */
    val includeReasoning: Boolean? = null,
    
    /**
     * Reasoning format (Groq-specific)
     * Values: "hidden", "raw", "parsed"
     * Mutually exclusive with includeReasoning
     */
    val reasoningFormat: String? = null,
    
    /**
     * Search settings for web search (Groq Compound models)
     */
    val searchSettings: SearchSettings? = null,
    
    /**
     * Store conversation (OpenAI-specific)
     */
    val store: Boolean? = null,

    /**
     * Temperature override for generation (0.0 - 2.0)
     */
    val temperature: Double? = null
) {
    companion object {
        /**
         * Agentic AI optimized settings (for autonomous agents)
         */
        fun agenticOptimized() = OpenRouterRequestOptions(
            providerPreferences = ProviderPreferences.default(),
            enableTransforms = true,  // Cost optimization
            topP = 0.9,  // Good balance for reasoning
            frequencyPenalty = 0.3,  // Reduce repetition
            presencePenalty = 0.2  // Encourage exploration
        )
        
        /**
         * Conversational optimized settings (for chat)
         */
        fun conversationalOptimized() = OpenRouterRequestOptions(
            providerPreferences = ProviderPreferences.default(),
            topP = 0.95,
            presencePenalty = 0.6  // More varied responses
        )
        
        /**
         * Structured output settings (for JSON responses)
         */
        fun structuredOutput() = OpenRouterRequestOptions(
            providerPreferences = ProviderPreferences.default(),
            responseFormat = OpenRouterConfig.ResponseFormat.JSON_OBJECT,
            temperature = 0.3  // More deterministic for structured data
        )
    }
}

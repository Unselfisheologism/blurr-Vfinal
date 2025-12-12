package com.blurr.voice.tools

import android.content.Context
import android.util.Log
import com.blurr.voice.core.providers.LLMProvider
import com.blurr.voice.core.providers.OpenAICompatibleAPI
import com.blurr.voice.core.providers.ProviderKeyManager
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.coroutineScope
import org.json.JSONArray
import org.json.JSONObject

/**
 * Web Search & Deep Research Tool using Perplexity Sonar models
 * 
 * Consolidates Stories 4.1 (Tavily), 4.2 (Exa), 4.3 (SerpAPI) into a single tool
 * using Perplexity's Sonar models which have built-in web search capabilities.
 * 
 * Strategy:
 * - Simple queries: Single API call to Sonar model
 * - Complex queries: Multiple parallel calls with sub-queries, then synthesis
 * - Automatically selects best available Sonar model from user's provider
 * 
 * Supported Sonar models (in order of capability):
 * - sonar-reasoning (best for complex reasoning + web search)
 * - sonar-pro-research (best for deep research)
 * - sonar-deep-research (extended deep research)
 * - sonar-reasoning-pro (reasoning with search)
 * - sonar-pro (high quality search)
 * - sonar (standard search)
 */
class PerplexitySonarTool(
    private val context: Context
) : BaseTool() {
    
    companion object {
        private const val TAG = "PerplexitySonarTool"
        
        // Sonar model hierarchy (best to basic)
        private val SONAR_MODEL_PRIORITY = listOf(
            "sonar-reasoning",
            "sonar-pro-research",
            "sonar-deep-research",
            "sonar-reasoning-pro",
            "sonar-pro",
            "sonar"
        )
        
        // Complexity threshold for multi-query strategy
        private const val COMPLEXITY_THRESHOLD = 50 // characters in query
        private const val MAX_PARALLEL_QUERIES = 5
    }
    
    private val keyManager = ProviderKeyManager(context)
    
    override val name: String = "web_search"
    
    override val description: String = 
        "Search the web and perform deep research on any topic. " +
        "Can answer questions about current events, facts, news, products, companies, " +
        "people, places, technologies, or any real-world information. " +
        "Automatically breaks down complex queries into multiple searches for comprehensive results."
    
    override val parameters: List<ToolParameter> = listOf(
        ToolParameter(
            name = "query",
            type = "string",
            description = "The search query or research question. Can be simple (e.g., 'weather in Tokyo') " +
                    "or complex (e.g., 'compare flagship smartphones of 2025 including specs, pricing, and reviews')",
            required = true
        ),
        ToolParameter(
            name = "search_depth",
            type = "string",
            description = "Search depth: 'quick' for fast results, 'standard' for balanced, 'deep' for comprehensive research",
            required = false,
            enum = listOf("quick", "standard", "deep")
        ),
        ToolParameter(
            name = "focus_areas",
            type = "array",
            description = "Optional list of specific focus areas or sub-topics to research (e.g., ['specs', 'pricing', 'reviews'])",
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
            val query: String = getRequiredParam(params, "query")
            val searchDepth: String = getOptionalParam(params, "search_depth", "standard")
            val focusAreas: List<String> = getOptionalParam(params, "focus_areas", emptyList())
            
            Log.d(TAG, "Executing web search: query='$query', depth=$searchDepth, focus=$focusAreas")
            
            // Get best available Sonar model
            val sonarModel = getBestAvailableSonarModel()
                ?: return ToolResult.failure(
                    toolName = name,
                    error = "No Perplexity Sonar models available from your provider. " +
                            "Please ensure your provider (OpenRouter, AIMLAPI, etc.) has access to Sonar models."
                )
            
            Log.d(TAG, "Using Sonar model: $sonarModel")
            
            // Determine search strategy
            val strategy = determineSearchStrategy(query, searchDepth, focusAreas)
            
            // Execute search
            val result = when (strategy) {
                SearchStrategy.SINGLE_QUERY -> executeSingleQuery(query, sonarModel, searchDepth)
                SearchStrategy.MULTI_QUERY -> executeMultiQuery(query, focusAreas, sonarModel, searchDepth)
            }
            
            if (result != null) {
                ToolResult.success(
                    toolName = name,
                    result = result,
                    data = mapOf(
                        "query" to query,
                        "model" to sonarModel,
                        "strategy" to strategy.name,
                        "search_depth" to searchDepth
                    )
                )
            } else {
                ToolResult.failure(
                    toolName = name,
                    error = "Web search failed. Please try again or rephrase your query."
                )
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error executing web search", e)
            ToolResult.failure(
                toolName = name,
                error = "Search error: ${e.message}"
            )
        }
    }
    
    /**
     * Get the best available Sonar model from user's provider
     */
    private suspend fun getBestAvailableSonarModel(): String? {
        return try {
            val provider = keyManager.getSelectedProvider() ?: return null
            val apiKey = keyManager.getApiKey(provider) ?: return null
            
            // Try to fetch available models
            val api = OpenAICompatibleAPI(provider, apiKey, "temp")
            val availableModels = api.getAvailableModels()
            
            if (availableModels != null) {
                // Find best Sonar model from available models
                for (sonarModel in SONAR_MODEL_PRIORITY) {
                    if (availableModels.any { it.contains(sonarModel, ignoreCase = true) }) {
                        Log.d(TAG, "Found Sonar model: $sonarModel")
                        return availableModels.first { it.contains(sonarModel, ignoreCase = true) }
                    }
                }
            } else {
                // Fallback: Try default Sonar models if model list fetch fails
                Log.w(TAG, "Could not fetch model list, using fallback")
                return when (provider) {
                    LLMProvider.OPENROUTER -> "perplexity/sonar-pro" // OpenRouter format
                    LLMProvider.AIMLAPI -> "perplexity/sonar-pro"    // AIMLAPI format
                    LLMProvider.GROQ -> "perplexity/sonar-pro"       // Groq format
                    LLMProvider.TOGETHER -> "perplexity/sonar-pro"   // Together format
                    else -> "perplexity/sonar" // Generic fallback
                }
            }
            
            null
        } catch (e: Exception) {
            Log.e(TAG, "Error getting Sonar model", e)
            null
        }
    }
    
    /**
     * Determine search strategy based on query complexity
     */
    private fun determineSearchStrategy(
        query: String,
        searchDepth: String,
        focusAreas: List<String>
    ): SearchStrategy {
        // Use multi-query strategy if:
        // 1. Query is complex (long)
        // 2. Deep search requested
        // 3. Multiple focus areas specified
        // 4. Query contains multiple questions or topics
        
        val isComplexQuery = query.length > COMPLEXITY_THRESHOLD
        val isDeepSearch = searchDepth == "deep"
        val hasMultipleFocus = focusAreas.size > 1
        val hasMultipleQuestions = query.count { it == '?' || it == ',' } > 2
        
        return if (isComplexQuery || isDeepSearch || hasMultipleFocus || hasMultipleQuestions) {
            SearchStrategy.MULTI_QUERY
        } else {
            SearchStrategy.SINGLE_QUERY
        }
    }
    
    /**
     * Execute single consolidated query to Sonar model
     * Best for simple, focused queries
     */
    private suspend fun executeSingleQuery(
        query: String,
        model: String,
        searchDepth: String
    ): String? {
        return try {
            val provider = keyManager.getSelectedProvider() ?: return null
            val apiKey = keyManager.getApiKey(provider) ?: return null
            
            val api = OpenAICompatibleAPI(provider, apiKey, model)
            
            // Craft system prompt based on search depth
            val systemPrompt = when (searchDepth) {
                "quick" -> "You are a web search assistant. Provide a concise, accurate answer with key facts and sources."
                "deep" -> "You are a deep research assistant. Provide comprehensive, detailed analysis with multiple sources, " +
                        "data points, comparisons, and expert insights. Include relevant statistics, quotes, and context."
                else -> "You are a web search assistant. Provide a clear, informative answer with relevant details and sources."
            }
            
            val messages = listOf(
                "system" to systemPrompt,
                "user" to query
            )
            
            // Set temperature based on search depth (lower = more factual)
            val temperature = when (searchDepth) {
                "quick" -> 0.3
                "deep" -> 0.5
                else -> 0.4
            }
            
            val maxTokens = when (searchDepth) {
                "quick" -> 1024
                "deep" -> 8192
                else -> 4096
            }
            
            Log.d(TAG, "Executing single query with model=$model, temp=$temperature, maxTokens=$maxTokens")
            
            api.generateChatCompletion(
                messages = messages,
                temperature = temperature,
                maxTokens = maxTokens
            )
            
        } catch (e: Exception) {
            Log.e(TAG, "Error in single query execution", e)
            null
        }
    }
    
    /**
     * Execute multiple parallel queries and synthesize results
     * Best for complex, multi-faceted research
     */
    private suspend fun executeMultiQuery(
        query: String,
        focusAreas: List<String>,
        model: String,
        searchDepth: String
    ): String? = coroutineScope {
        try {
            val provider = keyManager.getSelectedProvider() ?: return@coroutineScope null
            val apiKey = keyManager.getApiKey(provider) ?: return@coroutineScope null
            
            val api = OpenAICompatibleAPI(provider, apiKey, model)
            
            // Generate sub-queries
            val subQueries = if (focusAreas.isNotEmpty()) {
                // Use focus areas to create targeted queries
                focusAreas.take(MAX_PARALLEL_QUERIES).map { focus ->
                    "$query - specifically focusing on: $focus"
                }
            } else {
                // Ask Sonar to break down the query
                val breakdownQuery = "Break down this research question into 3-5 specific sub-questions that " +
                        "cover different aspects: \"$query\". Return ONLY a JSON array of strings."
                
                val breakdown = api.generateChatCompletion(
                    messages = listOf("user" to breakdownQuery),
                    temperature = 0.3,
                    maxTokens = 512
                )
                
                if (breakdown != null) {
                    parseSubQueries(breakdown).take(MAX_PARALLEL_QUERIES)
                } else {
                    // Fallback: use original query
                    listOf(query)
                }
            }
            
            Log.d(TAG, "Executing multi-query with ${subQueries.size} sub-queries")
            
            // Execute sub-queries in parallel
            val results = subQueries.map { subQuery ->
                async {
                    try {
                        val systemPrompt = "You are a research assistant. Provide detailed, accurate information " +
                                "with sources for this specific aspect of the research."
                        
                        val messages = listOf(
                            "system" to systemPrompt,
                            "user" to subQuery
                        )
                        
                        api.generateChatCompletion(
                            messages = messages,
                            temperature = 0.4,
                            maxTokens = 3072
                        )
                    } catch (e: Exception) {
                        Log.e(TAG, "Error in sub-query: $subQuery", e)
                        null
                    }
                }
            }.awaitAll().filterNotNull()
            
            if (results.isEmpty()) {
                return@coroutineScope null
            }
            
            // Synthesize results
            synthesizeResults(query, subQueries, results, api)
            
        } catch (e: Exception) {
            Log.e(TAG, "Error in multi-query execution", e)
            null
        }
    }
    
    /**
     * Parse sub-queries from JSON response
     */
    private fun parseSubQueries(response: String): List<String> {
        return try {
            val json = JSONArray(response.trim())
            List(json.length()) { json.getString(it) }
        } catch (e: Exception) {
            // Try to extract queries from text
            response.lines()
                .filter { it.trim().isNotEmpty() }
                .take(MAX_PARALLEL_QUERIES)
        }
    }
    
    /**
     * Synthesize multiple search results into coherent answer
     */
    private suspend fun synthesizeResults(
        originalQuery: String,
        subQueries: List<String>,
        results: List<String>,
        api: OpenAICompatibleAPI
    ): String? {
        return try {
            // Combine all results
            val combinedResults = StringBuilder()
            subQueries.forEachIndexed { index, subQuery ->
                if (index < results.size) {
                    combinedResults.append("\n\n## Sub-topic ${index + 1}: $subQuery\n")
                    combinedResults.append(results[index])
                }
            }
            
            // Ask Sonar to synthesize into coherent answer
            val synthesisPrompt = """
                Based on the following research findings, provide a comprehensive, well-organized answer 
                to the original question: "$originalQuery"
                
                Synthesize the information below into a coherent response that:
                1. Directly answers the main question
                2. Organizes information logically
                3. Highlights key findings and comparisons
                4. Includes relevant details and sources
                5. Provides actionable insights when applicable
                
                Research Findings:
                $combinedResults
                
                Provide a clear, comprehensive answer:
            """.trimIndent()
            
            api.generateChatCompletion(
                messages = listOf("user" to synthesisPrompt),
                temperature = 0.5,
                maxTokens = 6144
            )
            
        } catch (e: Exception) {
            Log.e(TAG, "Error synthesizing results", e)
            // Fallback: return concatenated results
            results.joinToString("\n\n---\n\n")
        }
    }
    
    /**
     * Search strategy enum
     */
    private enum class SearchStrategy {
        SINGLE_QUERY,  // Single consolidated query
        MULTI_QUERY    // Multiple parallel queries + synthesis
    }
}

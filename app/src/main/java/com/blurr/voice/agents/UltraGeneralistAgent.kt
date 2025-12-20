package com.twent.voice.agents

import android.content.Context
import android.graphics.Bitmap
import android.util.Log
import com.twent.voice.core.providers.FunctionTool
import com.twent.voice.core.providers.OpenRouterRequestOptions
import com.twent.voice.core.providers.ToolChoice
import com.twent.voice.core.providers.UniversalLLMService
import com.twent.voice.mcp.MCPClient
import com.twent.voice.tools.Tool
import com.twent.voice.tools.ToolRegistry
import com.twent.voice.tools.ToolResult
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject

/**
 * Ultra-Generalist AI Agent
 * 
 * The central orchestrator that:
 * 1. Analyzes user intent and creates execution plans
 * 2. Selects and executes appropriate tools (built-in and MCP)
 * 3. Chains tool executions with context passing
 * 4. Synthesizes final responses from tool results
 * 
 * This is the "brain" of the agentic AI system.
 */
class UltraGeneralistAgent(
    private val context: Context,
    private val llmService: UniversalLLMService,
    private val toolRegistry: ToolRegistry,
    private val mcpClient: MCPClient,
    private val conversationManager: ConversationManager
) {
    companion object {
        private const val TAG = "UltraGeneralistAgent"
        private const val MAX_TOOL_RETRIES = 2
        private const val MAX_PLAN_STEPS = 10
    }
    
    /**
     * Main entry point for processing user messages
     * 
     * This is the primary method that handles all user interactions.
     * It orchestrates the entire flow from intent analysis to response generation.
     */
    suspend fun processMessage(
        userMessage: String,
        images: List<Bitmap> = emptyList()
    ): AgentResponse {
        return withContext(Dispatchers.Default) {
            try {
                Log.d(TAG, "Processing message: ${userMessage.take(100)}")
                
                // 1. Add user message to conversation
                conversationManager.addUserMessage(userMessage, images)
                
                // 2. Analyze intent and create execution plan
                val plan = analyzePlan(userMessage, images)
                
                if (plan.steps.isEmpty()) {
                    // Direct response without tools
                    return@withContext generateDirectResponse(userMessage, images)
                }
                
                Log.d(TAG, "Execution plan created with ${plan.steps.size} steps")
                
                // 3. Execute tool chain
                val results = executeToolChain(plan)
                
                // 4. Generate final response from results
                val response = synthesizeResponse(plan, results)
                
                // 5. Save response to conversation
                conversationManager.addAssistantMessage(response.text)
                
                Log.d(TAG, "Message processing complete")
                return@withContext response
                
            } catch (e: Exception) {
                Log.e(TAG, "Error processing message", e)
                val errorResponse = AgentResponse(
                    text = "I encountered an error: ${e.message}. Let me try a different approach.",
                    toolResults = emptyList(),
                    plan = null,
                    error = e.message
                )
                conversationManager.addAssistantMessage(errorResponse.text)
                return@withContext errorResponse
            }
        }
    }
    
    /**
     * Analyze user intent and create structured execution plan
     * 
     * Uses LLM function calling to determine which tools to use and in what order.
     */
    private suspend fun analyzePlan(
        message: String,
        images: List<Bitmap>
    ): ExecutionPlan {
        Log.d(TAG, "Analyzing execution plan")
        
        // Build system prompt with available tools
        val systemPrompt = buildSystemPrompt()
        
        // Get conversation context
        val context = conversationManager.getTextContext()
        
        // Build messages for planning
        val messages = mutableListOf<Pair<String, String>>()
        messages.add("system" to systemPrompt)
        
        // Add recent context (last 5 messages for planning)
        context.takeLast(5).forEach { (role, content) ->
            messages.add(role to content)
        }
        
        // Add current message
        messages.add("user" to message)
        
        // Use function calling to get structured plan
        val options = OpenRouterRequestOptions(
            tools = buildAvailableTools(),
            toolChoice = ToolChoice.Auto,
            temperature = 0.3,  // Lower temperature for more focused planning
            topP = 0.9
        )
        
        try {
            val response = llmService.generateChatCompletion(
                messages,
                images,
                options = options
            )
            
            // Parse tool calls from response
            return parseExecutionPlan(response, message)
            
        } catch (e: Exception) {
            Log.e(TAG, "Error analyzing plan", e)
            // Return empty plan to fall back to direct response
            return ExecutionPlan(
                steps = emptyList(),
                reasoning = "Unable to create plan: ${e.message}"
            )
        }
    }
    
    /**
     * Build system prompt with tool descriptions
     */
    private fun buildSystemPrompt(): String {
        return """
            You are an Ultra-Generalist AI Agent with access to multiple tools.
            
            Your role is to:
            1. Understand the user's intent
            2. Select appropriate tools to accomplish the task
            3. Execute tools in the correct order
            4. Synthesize results into a helpful response
            
            Available Tools:
            ${toolRegistry.describeTools()}
            
            ${mcpClient.describeTools()}
            
            For complex tasks, break them down into steps and use multiple tools.
            Always explain what you're doing and why.
            
            If no tools are needed, respond directly without calling any tools.
        """.trimIndent()
    }
    
    /**
     * Build list of available tools as FunctionTool objects
     */
    private fun buildAvailableTools(): List<FunctionTool> {
        val tools = mutableListOf<FunctionTool>()
        
        // Add built-in tools
        tools.addAll(toolRegistry.toFunctionTools())
        
        // Add MCP tools
        tools.addAll(mcpClient.getAllTools().map { it.toFunctionTool() })
        
        return tools
    }
    
    /**
     * Parse execution plan from LLM response
     */
    private fun parseExecutionPlan(response: String?, originalMessage: String): ExecutionPlan {
        if (response == null) {
            return ExecutionPlan(emptyList(), "No response from LLM")
        }
        
        // Check if response indicates tool calls
        if (response.contains("[Function Calls Requested]") || 
            response.contains("Tool call")) {
            
            // Parse tool calls from response
            val steps = parseToolCalls(response)
            
            return ExecutionPlan(
                steps = steps,
                reasoning = "Executing ${steps.size} tool(s) to accomplish the task"
            )
        }
        
        // No tools needed - direct response
        return ExecutionPlan(
            steps = emptyList(),
            reasoning = "Direct response without tools"
        )
    }
    
    /**
     * Parse tool calls from LLM response
     */
    private fun parseToolCalls(response: String): List<ExecutionStep> {
        val steps = mutableListOf<ExecutionStep>()
        
        // Simple parsing - look for tool call patterns
        // Format: "toolname: {arguments}"
        val lines = response.lines()
        var currentTool: String? = null
        var currentArgs: String? = null
        
        for (line in lines) {
            if (line.contains(":") && !line.contains("{")) {
                // Tool name line
                currentTool = line.substringBefore(":").trim()
            } else if (line.contains("{") && currentTool != null) {
                // Arguments line
                currentArgs = line.trim()
                
                // Try to parse as JSON
                try {
                    val json = JSONObject(currentArgs)
                    val params = mutableMapOf<String, Any>()
                    json.keys().forEach { key ->
                        params[key] = json.get(key)
                    }
                    
                    steps.add(ExecutionStep(
                        toolName = currentTool,
                        parameters = params,
                        description = "Execute $currentTool"
                    ))
                    
                } catch (e: Exception) {
                    Log.w(TAG, "Failed to parse tool arguments: $currentArgs", e)
                }
                
                currentTool = null
                currentArgs = null
            }
        }
        
        return steps
    }
    
    /**
     * Execute tool chain sequentially
     * 
     * Each tool receives results from previous tools as context.
     */
    private suspend fun executeToolChain(plan: ExecutionPlan): List<ToolResult> {
        val results = mutableListOf<ToolResult>()
        
        Log.d(TAG, "Executing tool chain with ${plan.steps.size} steps")
        
        for ((index, step) in plan.steps.withIndex()) {
            if (index >= MAX_PLAN_STEPS) {
                Log.w(TAG, "Reached max plan steps limit: $MAX_PLAN_STEPS")
                break
            }
            
            Log.d(TAG, "Executing step ${index + 1}: ${step.toolName}")
            
            // Get tool
            val tool = getTool(step.toolName)
            if (tool == null) {
                Log.e(TAG, "Tool not found: ${step.toolName}")
                val errorResult = ToolResult.error(
                    step.toolName,
                    "Tool not found: ${step.toolName}"
                )
                results.add(errorResult)
                conversationManager.addToolResult(step.toolName, errorResult)
                continue
            }
            
            // Execute tool with retries
            var result: ToolResult? = null
            var lastError: String? = null
            
            for (attempt in 1..MAX_TOOL_RETRIES) {
                try {
                    result = tool.execute(step.parameters, results)
                    
                    if (result.success) {
                        Log.d(TAG, "Tool executed successfully: ${step.toolName}")
                        break
                    } else {
                        lastError = result.error
                        Log.w(TAG, "Tool execution failed (attempt $attempt): ${result.error}")
                    }
                    
                } catch (e: Exception) {
                    lastError = e.message
                    Log.e(TAG, "Tool execution exception (attempt $attempt)", e)
                }
                
                if (attempt < MAX_TOOL_RETRIES) {
                    kotlinx.coroutines.delay(1000L * attempt)  // Exponential backoff
                }
            }
            
            // Use final result or create error result
            val finalResult = result ?: ToolResult.error(
                step.toolName,
                lastError ?: "Tool execution failed after $MAX_TOOL_RETRIES attempts"
            )
            
            results.add(finalResult)
            conversationManager.addToolResult(step.toolName, finalResult)
        }
        
        Log.d(TAG, "Tool chain execution complete: ${results.count { it.success }}/${results.size} successful")
        return results
    }
    
    /**
     * Get tool from registry or MCP
     */
    private fun getTool(toolName: String): Tool? {
        // Try built-in tools first
        var tool = toolRegistry.getTool(toolName)
        if (tool != null) return tool
        
        // Try MCP tools
        tool = mcpClient.getTool(toolName)
        if (tool != null) return tool
        
        // Try with server prefix removed (e.g., "server:tool" -> "tool")
        if (toolName.contains(":")) {
            val shortName = toolName.substringAfter(":")
            tool = toolRegistry.getTool(shortName)
            if (tool != null) return tool
        }
        
        return null
    }
    
    /**
     * Synthesize final response from tool results
     */
    private suspend fun synthesizeResponse(
        plan: ExecutionPlan,
        results: List<ToolResult>
    ): AgentResponse {
        Log.d(TAG, "Synthesizing response from ${results.size} tool results")
        
        // Build synthesis prompt
        val synthesisPrompt = buildSynthesisPrompt(plan, results)
        
        // Get conversation context
        val context = conversationManager.getTextContext()
        
        // Build messages for synthesis
        val messages = mutableListOf<Pair<String, String>>()
        messages.add("system" to synthesisPrompt)
        
        // Add recent context
        context.takeLast(5).forEach { (role, content) ->
            messages.add(role to content)
        }
        
        try {
            val response = llmService.generateChatCompletion(
                messages,
                emptyList(),
                temperature = 0.7,  // Normal temperature for natural response
                maxTokens = 2048
            )
            
            return AgentResponse(
                text = response ?: "I couldn't generate a response.",
                toolResults = results,
                plan = plan
            )
            
        } catch (e: Exception) {
            Log.e(TAG, "Error synthesizing response", e)
            
            // Fallback: create simple summary
            val summary = createSimpleSummary(results)
            return AgentResponse(
                text = summary,
                toolResults = results,
                plan = plan,
                error = e.message
            )
        }
    }
    
    /**
     * Build synthesis prompt
     */
    private fun buildSynthesisPrompt(plan: ExecutionPlan, results: List<ToolResult>): String {
        val resultsText = results.mapIndexed { index, result ->
            if (result.success) {
                "Tool ${index + 1} (${result.toolName}): ${result.getDataAsString().take(500)}"
            } else {
                "Tool ${index + 1} (${result.toolName}): Error - ${result.error}"
            }
        }.joinToString("\n\n")
        
        return """
            Synthesize a helpful response based on the following tool execution results:
            
            $resultsText
            
            Provide a clear, natural response that:
            1. Explains what was accomplished
            2. Presents the key results
            3. Offers next steps or additional help if appropriate
            
            Be concise but thorough. Format the response for easy reading.
        """.trimIndent()
    }
    
    /**
     * Create simple summary as fallback
     */
    private fun createSimpleSummary(results: List<ToolResult>): String {
        val successful = results.count { it.success }
        val failed = results.count { !it.success }
        
        return buildString {
            appendLine("I executed ${results.size} tool(s) to help with your request.")
            if (successful > 0) {
                appendLine("✅ $successful successful")
            }
            if (failed > 0) {
                appendLine("❌ $failed failed")
            }
            appendLine()
            
            results.forEach { result ->
                appendLine("**${result.toolName}:**")
                if (result.success) {
                    appendLine(result.getDataAsString().take(200))
                } else {
                    appendLine("Error: ${result.error}")
                }
                appendLine()
            }
        }
    }
    
    /**
     * Generate direct response without tools
     */
    private suspend fun generateDirectResponse(
        message: String,
        images: List<Bitmap>
    ): AgentResponse {
        Log.d(TAG, "Generating direct response (no tools)")
        
        val context = conversationManager.getTextContext()
        val response = llmService.generateChatCompletion(
            context + ("user" to message),
            images
        )
        
        val responseText = response ?: "I'm here to help! How can I assist you?"
        
        return AgentResponse(
            text = responseText,
            toolResults = emptyList(),
            plan = ExecutionPlan(emptyList(), "Direct response")
        )
    }
}

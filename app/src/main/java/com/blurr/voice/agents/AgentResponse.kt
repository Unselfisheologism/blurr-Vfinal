package com.twent.voice.agents

import com.twent.voice.tools.ToolResult

/**
 * Response from the Ultra-Generalist Agent
 * 
 * Contains the final text response, tool execution results,
 * and optional execution plan and error information.
 */
data class AgentResponse(
    /**
     * Final text response to user
     */
    val text: String,
    
    /**
     * Results from tool executions
     */
    val toolResults: List<ToolResult>,
    
    /**
     * Execution plan that was used (optional)
     */
    val plan: ExecutionPlan? = null,
    
    /**
     * Error message if something went wrong (optional)
     */
    val error: String? = null
) {
    /**
     * Check if response is successful (no errors)
     */
    fun isSuccess(): Boolean = error == null
    
    /**
     * Check if tools were used
     */
    fun hasToolResults(): Boolean = toolResults.isNotEmpty()
    
    /**
     * Get count of successful tool executions
     */
    fun getSuccessfulToolCount(): Int = toolResults.count { it.success }
    
    /**
     * Get count of failed tool executions
     */
    fun getFailedToolCount(): Int = toolResults.count { !it.success }
    
    /**
     * Check if all tools succeeded
     */
    fun allToolsSucceeded(): Boolean = toolResults.all { it.success }
    
    /**
     * Get tool results by name
     */
    fun getToolResult(toolName: String): ToolResult? {
        return toolResults.firstOrNull { it.toolName == toolName }
    }
    
    /**
     * Get all tool names used
     */
    fun getToolNames(): List<String> = toolResults.map { it.toolName }
    
    /**
     * Format as human-readable text
     */
    fun toFormattedText(): String {
        return buildString {
            if (error != null) {
                appendLine("⚠️ Error: $error")
                appendLine()
            }
            
            if (plan != null && plan.hasSteps()) {
                appendLine("🔧 Used tools: ${plan.getToolNames().joinToString(", ")}")
                appendLine()
            }
            
            appendLine(text)
            
            if (toolResults.isNotEmpty()) {
                val failed = getFailedToolCount()
                if (failed > 0) {
                    appendLine()
                    appendLine("⚠️ Note: $failed tool(s) failed")
                }
            }
        }
    }
    
    companion object {
        /**
         * Create simple text response
         */
        fun text(text: String): AgentResponse {
            return AgentResponse(
                text = text,
                toolResults = emptyList(),
                plan = null
            )
        }
        
        /**
         * Create error response
         */
        fun error(error: String): AgentResponse {
            return AgentResponse(
                text = "I encountered an error: $error",
                toolResults = emptyList(),
                plan = null,
                error = error
            )
        }
    }
}

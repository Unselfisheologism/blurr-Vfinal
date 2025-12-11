package com.blurr.voice.tools

import android.content.Context
import android.util.Log
import com.blurr.voice.core.providers.FunctionTool

/**
 * Registry of all available tools
 * 
 * Manages built-in tools and provides tool discovery for the agent.
 * MCP tools are managed separately by MCPClient.
 */
class ToolRegistry(
    private val context: Context
) {
    private val tools = mutableMapOf<String, Tool>()
    
    companion object {
        private const val TAG = "ToolRegistry"
    }
    
    init {
        // Built-in tools will be registered here as they're implemented
        Log.d(TAG, "ToolRegistry initialized")
    }
    
    /**
     * Register a tool
     */
    fun register(tool: Tool) {
        if (tools.containsKey(tool.name)) {
            Log.w(TAG, "Tool already registered, replacing: ${tool.name}")
        }
        
        tools[tool.name] = tool
        Log.d(TAG, "Registered tool: ${tool.name}")
    }
    
    /**
     * Unregister a tool
     */
    fun unregister(toolName: String): Boolean {
        val removed = tools.remove(toolName) != null
        if (removed) {
            Log.d(TAG, "Unregistered tool: $toolName")
        }
        return removed
    }
    
    /**
     * Get tool by name
     */
    fun getTool(name: String): Tool? {
        return tools[name]
    }
    
    /**
     * Get all registered tools
     */
    fun getAllTools(): List<Tool> {
        return tools.values.toList()
    }
    
    /**
     * Get tools by category (based on name prefix)
     */
    fun getToolsByCategory(category: String): List<Tool> {
        return tools.values.filter { it.name.startsWith(category) }
    }
    
    /**
     * Check if tool exists
     */
    fun hasTool(name: String): Boolean {
        return tools.containsKey(name)
    }
    
    /**
     * Get tool count
     */
    fun getToolCount(): Int {
        return tools.size
    }
    
    /**
     * Describe all tools for LLM system prompt
     * Returns formatted string with tool names and descriptions
     */
    fun describeTools(): String {
        if (tools.isEmpty()) {
            return "No built-in tools available."
        }
        
        return buildString {
            appendLine("Built-in Tools:")
            tools.values.forEach { tool ->
                appendLine("- ${tool.name}: ${tool.description}")
            }
        }
    }
    
    /**
     * Get detailed tool descriptions
     */
    fun getDetailedDescriptions(): String {
        return buildString {
            tools.values.forEach { tool ->
                appendLine("Tool: ${tool.name}")
                appendLine("Description: ${tool.description}")
                if (tool.parameters.isNotEmpty()) {
                    appendLine("Parameters:")
                    tool.parameters.forEach { param ->
                        val req = if (param.required) " (required)" else ""
                        appendLine("  - ${param.name}: ${param.type}$req - ${param.description}")
                    }
                }
                appendLine()
            }
        }
    }
    
    /**
     * Convert all tools to FunctionTool list for LLM function calling
     */
    fun toFunctionTools(): List<FunctionTool> {
        return tools.values.map { it.toFunctionTool() }
    }
    
    /**
     * Search tools by keyword in name or description
     */
    fun searchTools(keyword: String): List<Tool> {
        val lowerKeyword = keyword.lowercase()
        return tools.values.filter { tool ->
            tool.name.lowercase().contains(lowerKeyword) ||
            tool.description.lowercase().contains(lowerKeyword)
        }
    }
    
    /**
     * Get tool categories (extracts prefixes from tool names)
     */
    fun getCategories(): List<String> {
        return tools.keys
            .mapNotNull { name ->
                if (name.contains("_")) {
                    name.substringBefore("_")
                } else {
                    null
                }
            }
            .distinct()
            .sorted()
    }
    
    /**
     * Clear all registered tools (for testing)
     */
    fun clear() {
        tools.clear()
        Log.d(TAG, "Cleared all tools")
    }
}

/**
 * Tool categories for organization
 */
object ToolCategories {
    const val SEARCH = "search"
    const val GENERATE = "generate"
    const val DOCUMENT = "document"
    const val GOOGLE = "google"
    const val PHONE = "phone"
    const val CUSTOM = "custom"
}

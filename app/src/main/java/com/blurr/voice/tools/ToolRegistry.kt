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
    private val context: Context,
    private val confirmationHandler: com.blurr.voice.agents.UserConfirmationHandler? = null
) {
    private val tools = mutableMapOf<String, Tool>()
    private val toolPreferences by lazy { 
        com.blurr.voice.data.ToolPreferences(context) 
    }
    
    companion object {
        private const val TAG = "ToolRegistry"
    }
    
    init {
        // Register built-in tools
        
        // User interaction
        if (confirmationHandler != null) {
            registerTool(AskUserTool(context, confirmationHandler))
        }
        
        // Phone control (UI automation)
        registerTool(PhoneControlTool(context))
        
        // Python shell (unlimited flexibility)
        registerTool(PythonShellTool(context))  // Keep for backward compatibility
        
        // Unified shell (Python + JavaScript) - Phase 2: Story 4.12
        registerTool(UnifiedShellTool(context))
        
        // Infographic generation (AI or D3.js) - Phase 3: Story 4.12
        confirmationHandler?.let {
            registerTool(GenerateInfographicTool(context, it))
        }
        
        // Google Workspace integrations - FREE for all users! (Story 4.13 + 4.15 + 4.16)
        val googleAuthManager = com.blurr.voice.auth.GoogleAuthManager(context)
        registerTool(com.blurr.voice.tools.google.GmailTool(context, googleAuthManager))
        registerTool(com.blurr.voice.tools.google.GoogleCalendarTool(context, googleAuthManager))
        registerTool(com.blurr.voice.tools.google.GoogleDriveTool(context, googleAuthManager))
        
        // Composio integrations (2,000+ tools) - PRO ONLY! (Story 4.14 + 4.16)
        // Note: Actual gating happens at execution time via ComposioTool.execute()
        // Tool is always registered so it appears in listings, but throws paywall error when used by free users
        registerTool(ComposioTool(context))
        
        // Web search & research
        registerTool(PerplexitySonarTool(context))
        
        // Media generation tools
        registerTool(ImageGenerationTool(context))
        registerTool(VideoGenerationTool(context))
        registerTool(AudioGenerationTool(context))
        registerTool(MusicGenerationTool(context))
        registerTool(Model3DGenerationTool(context))
        
        // Workflow management - Enables AI to create and manage n8n-style workflows
        registerTool(WorkflowTool(context))
        
        // Spreadsheet editor - AI-native spreadsheet generation and editing (Epic 3)
        registerTool(SpreadsheetTool(context))
        
        Log.d(TAG, "ToolRegistry initialized with ${tools.size} built-in tools")
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
     * Get tool by name (only if enabled)
     */
    fun getTool(name: String): Tool? {
        val tool = tools[name]
        return if (tool != null && toolPreferences.isToolEnabled(name)) {
            tool
        } else {
            null
        }
    }
    
    /**
     * Get tool by name (regardless of enabled state)
     */
    fun getToolRaw(name: String): Tool? {
        return tools[name]
    }
    
    /**
     * Get all registered tools
     */
    fun getAllTools(): List<Tool> {
        return tools.values.toList()
    }
    
    /**
     * Get all enabled tools (filtered by user preferences)
     */
    fun getEnabledTools(): List<Tool> {
        return tools.values.filter { tool ->
            toolPreferences.isToolEnabled(tool.name)
        }
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
     * Describe all enabled tools for LLM system prompt
     * Returns formatted string with tool names and descriptions
     */
    fun describeTools(): String {
        val enabledTools = getEnabledTools()
        if (enabledTools.isEmpty()) {
            return "No built-in tools available."
        }
        
        return buildString {
            appendLine("Built-in Tools:")
            enabledTools.forEach { tool ->
                appendLine("- ${tool.name}: ${tool.description}")
            }
        }
    }
    
    /**
     * Get detailed tool descriptions (only enabled tools)
     */
    fun getDetailedDescriptions(): String {
        val enabledTools = getEnabledTools()
        return buildString {
            enabledTools.forEach { tool ->
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
        return getEnabledTools().map { it.toFunctionTool() }
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
    const val WORKFLOW = "workflow"
    const val CUSTOM = "custom"
}

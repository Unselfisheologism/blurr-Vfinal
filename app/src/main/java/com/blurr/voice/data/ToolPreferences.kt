package com.blurr.voice.data

import android.content.Context
import android.content.SharedPreferences

/**
 * Manages user preferences for tool enablement
 * 
 * Stores which built-in and MCP tools are enabled/disabled.
 * Uses SharedPreferences for lightweight persistent storage.
 */
class ToolPreferences(context: Context) {
    
    private val prefs: SharedPreferences = 
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    
    companion object {
        private const val PREFS_NAME = "tool_preferences"
        private const val KEY_ENABLED_TOOLS = "enabled_tools"
        private const val KEY_DISABLED_TOOLS = "disabled_tools"
        
        // Default enabled tools (can be empty to enable all by default)
        private val DEFAULT_ENABLED_TOOLS = setOf<String>()
    }
    
    /**
     * Check if a tool is enabled
     */
    fun isToolEnabled(toolName: String): Boolean {
        val disabledTools = getDisabledTools()
        return !disabledTools.contains(toolName)
    }
    
    /**
     * Enable a tool
     */
    fun enableTool(toolName: String) {
        val disabled = getDisabledTools().toMutableSet()
        disabled.remove(toolName)
        saveDisabledTools(disabled)
    }
    
    /**
     * Disable a tool
     */
    fun disableTool(toolName: String) {
        val disabled = getDisabledTools().toMutableSet()
        disabled.add(toolName)
        saveDisabledTools(disabled)
    }
    
    /**
     * Get all disabled tools
     */
    fun getDisabledTools(): Set<String> {
        val serialized = prefs.getString(KEY_DISABLED_TOOLS, "") ?: ""
        return if (serialized.isBlank()) {
            emptySet()
        } else {
            serialized.split(",").toSet()
        }
    }
    
    /**
     * Save disabled tools
     */
    private fun saveDisabledTools(disabled: Set<String>) {
        val serialized = disabled.joinToString(",")
        prefs.edit().putString(KEY_DISABLED_TOOLS, serialized).apply()
    }
    
    /**
     * Enable all tools
     */
    fun enableAllTools() {
        prefs.edit().remove(KEY_DISABLED_TOOLS).apply()
    }
    
    /**
     * Disable all tools
     */
    fun disableAllTools(allToolNames: List<String>) {
        saveDisabledTools(allToolNames.toSet())
    }
    
    /**
     * Get enabled tools from a list
     */
    fun filterEnabledTools(allTools: List<String>): List<String> {
        val disabled = getDisabledTools()
        return allTools.filter { !disabled.contains(it) }
    }
    
    /**
     * Reset to defaults
     */
    fun reset() {
        prefs.edit().clear().apply()
    }
}

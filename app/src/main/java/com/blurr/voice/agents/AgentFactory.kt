package com.blurr.voice.agents

import android.content.Context
import com.blurr.voice.core.providers.UniversalLLMService
import com.blurr.voice.mcp.MCPClient
import com.blurr.voice.tools.ToolRegistry

/**
 * Factory for creating Ultra-Generalist Agent instances
 * 
 * Handles dependency injection and initialization.
 */
object AgentFactory {
    
    private var cachedAgent: UltraGeneralistAgent? = null
    
    /**
     * Create or get cached agent instance
     */
    fun getAgent(context: Context): UltraGeneralistAgent {
        return cachedAgent ?: createAgent(context).also {
            cachedAgent = it
        }
    }
    
    /**
     * Create new agent instance
     */
    fun createAgent(context: Context): UltraGeneralistAgent {
        val llmService = UniversalLLMService(context)
        val toolRegistry = ToolRegistry(context)
        val mcpClient = MCPClient(context)
        val conversationManager = ConversationManager(context)
        
        return UltraGeneralistAgent(
            context = context,
            llmService = llmService,
            toolRegistry = toolRegistry,
            mcpClient = mcpClient,
            conversationManager = conversationManager
        )
    }
    
    /**
     * Clear cached instance (for testing or reset)
     */
    fun clearCache() {
        cachedAgent = null
    }
}

package com.twent.voice.agents

import android.content.Context
import com.twent.voice.core.providers.UniversalLLMService
import com.twent.voice.mcp.MCPClient
import com.twent.voice.tools.ToolRegistry

/**
 * Factory for creating Ultra-Generalist Agent instances
 * 
 * Handles dependency injection and initialization.
 */
object AgentFactory {
    
    private var cachedAgent: UltraGeneralistAgent? = null
    private var cachedConfirmationHandler: DefaultUserConfirmationHandler? = null
    
    /**
     * Create or get cached agent instance
     */
    fun getAgent(context: Context): UltraGeneralistAgent {
        return cachedAgent ?: createAgent(context).also {
            cachedAgent = it
        }
    }
    
    /**
     * Get the confirmation handler (for UI to connect to)
     */
    fun getConfirmationHandler(): DefaultUserConfirmationHandler? {
        return cachedConfirmationHandler
    }
    
    /**
     * Create new agent instance
     */
    fun createAgent(context: Context): UltraGeneralistAgent {
        val llmService = UniversalLLMService(context)
        
        // Create confirmation handler for ask_user tool
        val confirmationHandler = DefaultUserConfirmationHandler()
        cachedConfirmationHandler = confirmationHandler
        val toolRegistry = ToolRegistry(context, confirmationHandler)
        
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
        cachedConfirmationHandler = null
    }
}

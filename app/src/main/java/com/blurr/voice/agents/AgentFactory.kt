package com.blurr.voice.agents

import android.content.Context
import com.blurr.voice.core.providers.UniversalLLMService
import com.blurr.voice.mcp.MCPClient
import com.blurr.voice.mcp.sdk.MCPServerManager
import com.blurr.voice.tools.ToolRegistry

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
        
        // Create MCPServerManager for managing MCP server connections
        val mcpServerManager = MCPServerManager(context, mcpClient)
        
        val conversationManager = ConversationManager(context)
        
        return UltraGeneralistAgent(
            context = context,
            llmService = llmService,
            toolRegistry = toolRegistry,
            mcpClient = mcpClient,
            mcpServerManager = mcpServerManager,
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

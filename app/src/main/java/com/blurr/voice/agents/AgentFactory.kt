package com.blurr.voice.agents

import android.content.Context
import com.blurr.voice.core.providers.UniversalLLMService
import com.blurr.voice.mcp.MCPClient
import com.blurr.voice.mcp.MCPServerManager
import com.blurr.voice.tools.ToolRegistry

/**
 * Factory for creating Ultra-Generalist Agent instances
 * 
 * Handles dependency injection and initialization.
 */
object AgentFactory {
    
    private var cachedAgent: UltraGeneralistAgent? = null
    private var cachedConfirmationHandler: DefaultUserConfirmationHandler? = null
    private var cachedMcpServerManager: MCPServerManager? = null
    
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
     * Get the MCP server manager (for UI to connect to)
     */
    fun getMcpServerManager(context: Context): MCPServerManager {
        return cachedMcpServerManager ?: createMCPServerManager(context).also {
            cachedMcpServerManager = it
        }
    }
    
    /**
     * Create MCP Server Manager instance
     */
    private fun createMCPServerManager(context: Context): MCPServerManager {
        return MCPServerManager(context)
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
        val mcpServerManager = getMcpServerManager(context)
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
        cachedMcpServerManager = null
    }
}

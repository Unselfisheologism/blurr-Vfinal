package com.blurr.voice.mcp

import android.content.Context
import android.util.Log
import com.blurr.voice.tools.Tool
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/**
 * Model Context Protocol (MCP) Client - DEPRECATED
 *
 * This old MCP client implementation has been replaced by MCPServerManager
 * which uses the official MCP Kotlin SDK 0.8.1.
 *
 * @deprecated Use MCPServerManager instead which uses the official SDK
 */
@Deprecated("Use MCPServerManager which uses the official MCP Kotlin SDK instead")
class MCPClient(
    private val context: Context
) {
    private val servers = mutableMapOf<String, MCPServer>()
    private val tools = mutableMapOf<String, MCPTool>()
    private val toolPreferences by lazy {
        com.blurr.voice.data.ToolPreferences(context)
    }

    companion object {
        private const val TAG = "MCPClient"
        const val PROTOCOL_VERSION = "2024-11-05"
    }

    /**
     * Connect to an MCP server - DEPRECATED
     * Throws an exception indicating this class is deprecated
     */
    suspend fun connect(
        name: String,
        transport: MCPTransport
    ): Result<Unit> {
        throw UnsupportedOperationException(
            "MCPClient is deprecated. Use MCPServerManager instead which uses the official MCP Kotlin SDK."
        )
    }

    /**
     * Get tool from MCP server - DEPRECATED
     * Throws an exception indicating this class is deprecated
     */
    fun getTool(name: String): Tool? {
        throw UnsupportedOperationException(
            "MCPClient is deprecated. Use MCPServerManager instead which uses the official MCP Kotlin SDK."
        )
    }

    /**
     * Get all available tools - DEPRECATED
     * Throws an exception indicating this class is deprecated
     */
    fun getAllTools(): List<Tool> {
        throw UnsupportedOperationException(
            "MCPClient is deprecated. Use MCPServerManager instead which uses the official MCP Kotlin SDK."
        )
    }

    /**
     * Describe all available MCP tools - DEPRECATED
     * Throws an exception indicating this class is deprecated
     */
    fun describeTools(): String {
        throw UnsupportedOperationException(
            "MCPClient is deprecated. Use MCPServerManager instead which uses the official MCP Kotlin SDK."
        )
    }

    /**
     * Get list of connected server names - DEPRECATED
     * Throws an exception indicating this class is deprecated
     */
    fun getConnectedServers(): List<String> {
        throw UnsupportedOperationException(
            "MCPClient is deprecated. Use MCPServerManager instead which uses the official MCP Kotlin SDK."
        )
    }

    /**
     * Check if server is connected - DEPRECATED
     * Throws an exception indicating this class is deprecated
     */
    fun isServerConnected(name: String): Boolean {
        throw UnsupportedOperationException(
            "MCPClient is deprecated. Use MCPServerManager instead which uses the official MCP Kotlin SDK."
        )
    }

    /**
     * Disconnect from a specific server - DEPRECATED
     * Throws an exception indicating this class is deprecated
     */
    suspend fun disconnect(name: String) {
        throw UnsupportedOperationException(
            "MCPClient is deprecated. Use MCPServerManager instead which uses the official MCP Kotlin SDK."
        )
    }

    /**
     * Disconnect from all servers - DEPRECATED
     * Throws an exception indicating this class is deprecated
     */
    suspend fun disconnectAll() {
        throw UnsupportedOperationException(
            "MCPClient is deprecated. Use MCPServerManager instead which uses the official MCP Kotlin SDK."
        )
    }

    /**
     * Get server information - DEPRECATED
     * Throws an exception indicating this class is deprecated
     */
    fun getServerInfo(name: String): MCPServerInfo? {
        throw UnsupportedOperationException(
            "MCPClient is deprecated. Use MCPServerManager instead which uses the official MCP Kotlin SDK."
        )
    }

    /**
     * Get all server information - DEPRECATED
     * Throws an exception indicating this class is deprecated
     */
    fun getAllServerInfo(): List<MCPServerInfo> {
        throw UnsupportedOperationException(
            "MCPClient is deprecated. Use MCPServerManager instead which uses the official MCP Kotlin SDK."
        )
    }
}

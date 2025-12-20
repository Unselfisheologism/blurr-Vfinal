package com.twent.voice.mcp

import org.json.JSONObject

/**
 * Transport layer interface for MCP communication
 * 
 * Supports multiple transport types:
 * - HTTP: REST API calls
 * - WebSocket: Bidirectional streaming (future)
 * - stdio: Standard I/O pipes (future)
 */
interface MCPTransport {
    /**
     * Establish connection to the MCP server
     */
    suspend fun connect()
    
    /**
     * Send a JSON-RPC request and wait for response
     * 
     * @param method Method name (e.g., "tools/list")
     * @param params Parameters object
     * @return Response result object
     */
    suspend fun sendRequest(method: String, params: Map<String, Any>): JSONObject
    
    /**
     * Send a JSON-RPC notification (no response expected)
     * 
     * @param method Method name
     * @param params Parameters object (optional)
     */
    suspend fun sendNotification(method: String, params: Map<String, Any> = emptyMap()) {
        // Default implementation - optional for most transports
    }
    
    /**
     * Close the connection
     */
    fun close()
    
    /**
     * Check if transport is currently connected
     */
    fun isConnected(): Boolean
}

/**
 * Exception thrown when MCP communication fails
 */
class MCPException(
    message: String,
    val errorCode: Int? = null,
    val errorData: Any? = null,
    cause: Throwable? = null
) : Exception(message, cause) {
    
    companion object {
        // Standard JSON-RPC error codes
        const val PARSE_ERROR = -32700
        const val INVALID_REQUEST = -32600
        const val METHOD_NOT_FOUND = -32601
        const val INVALID_PARAMS = -32602
        const val INTERNAL_ERROR = -32603
        
        // MCP-specific error codes
        const val TOOL_NOT_FOUND = -32001
        const val TOOL_EXECUTION_ERROR = -32002
        const val INITIALIZATION_ERROR = -32003
        
        fun fromJson(error: JSONObject): MCPException {
            val code = error.optInt("code", INTERNAL_ERROR)
            val message = error.optString("message", "Unknown error")
            val data = error.opt("data")
            
            return MCPException(message, code, data)
        }
    }
    
    override fun toString(): String {
        return "MCPException(code=$errorCode, message=$message, data=$errorData)"
    }
}

/**
 * Transport configuration
 */
sealed class MCPTransportConfig {
    /**
     * HTTP transport configuration
     */
    data class Http(
        val url: String,
        val apiKey: String? = null,
        val headers: Map<String, String> = emptyMap(),
        val timeoutMs: Long = 30000
    ) : MCPTransportConfig()
    
    /**
     * WebSocket transport configuration (future)
     */
    data class WebSocket(
        val url: String,
        val apiKey: String? = null,
        val headers: Map<String, String> = emptyMap()
    ) : MCPTransportConfig()
    
    /**
     * Standard I/O transport configuration (future)
     */
    data class Stdio(
        val command: String,
        val args: List<String> = emptyList(),
        val env: Map<String, String> = emptyMap()
    ) : MCPTransportConfig()
}

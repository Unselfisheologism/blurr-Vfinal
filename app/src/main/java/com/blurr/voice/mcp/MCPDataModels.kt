package com.blurr.voice.mcp

/**
 * Response object for server information
 * Serialized to Map<String, Any> for Flutter
 */
data class MCPServerResponse(
    val name: String,
    val url: String,
    val transport: String,
    val connected: Boolean,
    val toolCount: Int
) {
    fun toMap(): Map<String, Any> = mapOf(
        "name" to name,
        "url" to url,
        "transport" to transport,
        "connected" to connected,
        "toolCount" to toolCount
    )
}

/**
 * Response object for tool information
 */
data class MCPToolResponse(
    val name: String,
    val description: String?,
    val inputSchema: Map<String, Any>?,
    val outputSchema: Map<String, Any>?,
    val serverName: String?
) {
    fun toMap(): Map<String, Any> = mapOf(
        "name" to name,
        "description" to (description ?: ""),
        "inputSchema" to (inputSchema ?: emptyMap<String, Any>()),
        "outputSchema" to (outputSchema ?: emptyMap<String, Any>()),
        "serverName" to (serverName ?: "")
    )
}

/**
 * Response for tool execution
 */
data class MCPExecutionResponse(
    val success: Boolean,
    val result: Any? = null,
    val error: String? = null
) {
    fun toMap(): Map<String, Any> = mapOf(
        "success" to success,
        "result" to (result ?: ""),
        "error" to (error ?: "")
    ).filterValues { it !is String || it.isNotEmpty() }
}

/**
 * Response for connection validation
 */
data class MCPValidationResponse(
    val success: Boolean,
    val message: String,
    val serverInfo: Map<String, String>? = null,
    val toolCount: Int = 0
) {
    fun toMap(): Map<String, Any> = mapOf(
        "success" to success,
        "message" to message,
        "serverInfo" to (serverInfo ?: emptyMap<String, String>()),
        "toolCount" to toolCount
    )
}

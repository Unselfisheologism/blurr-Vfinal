package com.blurr.voice.mcp

/**
 * Protocol-specific configuration classes for MCP transport connections.
 *
 * Each transport protocol (STDIO, SSE, HTTP) has different configuration requirements
 * that must be handled separately to avoid crashes and connection failures.
 */
sealed class MCPTransportConfig {
    abstract val serverName: String

    /**
     * STDIO transport configuration for subprocess execution.
     * Communicates with server via stdin/stdout (subprocess execution).
     */
    data class StdioConfig(
        override val serverName: String,
        val command: String,
        val args: List<String> = emptyList(),
        val timeoutMs: Long = 30000L
    ) : MCPTransportConfig()

    /**
     * SSE (Server-Sent Events) transport configuration.
     * HTTP-based unidirectional streaming from server to client.
     */
    data class SSEConfig(
        override val serverName: String,
        val url: String,
        val authentication: AuthType = AuthType.NONE,
        val headers: Map<String, String> = emptyMap(),
        val timeoutMs: Long = 30000L
    ) : MCPTransportConfig()

    /**
     * HTTP (Streamable HTTP) transport configuration.
     * HTTP POST for requests, SSE or polling for responses.
     */
    data class HttpConfig(
        override val serverName: String,
        val url: String,
        val authentication: AuthType = AuthType.NONE,
        val headers: Map<String, String> = emptyMap(),
        val timeoutMs: Long = 30000L
    ) : MCPTransportConfig()
}

/**
 * Authentication type for HTTP-based transports (SSE, HTTP).
 */
enum class AuthType {
    /** No authentication required */
    NONE,

    /** OAuth flow (user redirected to auth URL) */
    OAUTH,

    /** Custom authentication headers (Bearer token, API key, etc.) */
    AUTH_HEADER
}

/**
 * Extension function to parse transport configuration from method call arguments.
 * Returns null if required parameters are missing.
 */
fun parseTransportConfig(
    protocol: String,
    serverName: String?,
    url: String?,
    command: String?,
    args: List<String>?,
    authentication: String?,
    headers: Map<String, String>?
): MCPTransportConfig? {
    return when (protocol.lowercase()) {
        "stdio" -> {
            if (serverName != null && command != null) {
                MCPTransportConfig.StdioConfig(
                    serverName = serverName,
                    command = command,
                    args = args ?: emptyList()
                )
            } else null
        }
        "sse" -> {
            if (serverName != null && url != null) {
                val authType = try {
                    AuthType.valueOf((authentication ?: "NONE").uppercase())
                } catch (e: IllegalArgumentException) {
                    AuthType.NONE
                }
                MCPTransportConfig.SSEConfig(
                    serverName = serverName,
                    url = url,
                    authentication = authType,
                    headers = headers ?: emptyMap()
                )
            } else null
        }
        "http" -> {
            if (serverName != null && url != null) {
                val authType = try {
                    AuthType.valueOf((authentication ?: "NONE").uppercase())
                } catch (e: IllegalArgumentException) {
                    AuthType.NONE
                }
                MCPTransportConfig.HttpConfig(
                    serverName = serverName,
                    url = url,
                    authentication = authType,
                    headers = headers ?: emptyMap()
                )
            } else null
        }
        else -> null
    }
}

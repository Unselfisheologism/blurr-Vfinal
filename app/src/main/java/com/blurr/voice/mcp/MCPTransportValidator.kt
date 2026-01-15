package com.blurr.voice.mcp

import android.util.Log
import io.ktor.client.HttpClient
import io.ktor.client.engine.cio.CIO
import io.ktor.client.plugins.HttpTimeout
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.plugins.logging.LogLevel
import io.ktor.client.plugins.logging.Logger
import io.ktor.client.plugins.logging.Logging
import io.ktor.client.plugins.sse.SSE
import io.ktor.client.request.get
import io.ktor.client.request.header
import io.ktor.client.request.post
import io.ktor.client.request.setBody
import io.ktor.http.ContentType
import io.ktor.http.HttpStatusCode
import io.ktor.http.contentType
import io.ktor.serialization.kotlinx.json.json
import kotlinx.coroutines.withTimeoutOrNull
import kotlinx.serialization.json.Json

/**
 * Protocol-specific validation for MCP transport connections.
 *
 * Each transport protocol (STDIO, SSE, HTTP) has different validation requirements:
 * - STDIO: Verify command is executable and process can be started
 * - SSE: Make HTTP GET request to verify server is reachable
 * - HTTP: Make HTTP POST request to verify server accepts MCP messages
 */
object MCPTransportValidator {
    private const val TAG = "MCPTransportValidator"

    /**
     * Validate MCP connection based on protocol-specific configuration.
     *
     * @param config Transport configuration (StdioConfig, SSEConfig, or HttpConfig)
     * @param timeout Timeout in milliseconds (default: 5000ms)
     * @return ValidationResult indicating success/failure and message
     */
    suspend fun validate(
        config: MCPTransportConfig,
        timeout: Long = 5000L
    ): ValidationResult {
        Log.d(TAG, "=== Starting MCP Transport Validation ===")
        Log.d(TAG, "Protocol: ${config::class.simpleName}")
        Log.d(TAG, "Server: ${config.serverName}")
        Log.d(TAG, "Timeout: ${timeout}ms")

        return when (config) {
            is MCPTransportConfig.StdioConfig -> validateStdio(config, timeout)
            is MCPTransportConfig.SSEConfig -> validateSSE(config, timeout)
            is MCPTransportConfig.HttpConfig -> validateHttp(config, timeout)
        }
    }

    /**
     * Validate STDIO transport configuration.
     *
     * For STDIO, we verify:
     * 1. Command is not empty
     * 2. Command is executable
     * 3. Process can be started (with optional args)
     */
    private suspend fun validateStdio(
        config: MCPTransportConfig.StdioConfig,
        timeout: Long
    ): ValidationResult {
        Log.d(TAG, "Validating STDIO transport")
        Log.d(TAG, "Command: ${config.command}")
        Log.d(TAG, "Args: ${config.args}")

        return try {
            // Validate command is not empty
            if (config.command.isBlank()) {
                Log.w(TAG, "STDIO validation failed: Command is blank")
                return ValidationResult(
                    success = false,
                    message = "Command cannot be empty",
                    protocol = "stdio"
                )
            }

            // Build command with args
            val commandList = mutableListOf(config.command)
            commandList.addAll(config.args)
            val commandArray = commandList.toTypedArray()

            Log.d(TAG, "Attempting to start process: ${commandList.joinToString(" ")}")

            // Try to start the process
            val process = withTimeoutOrNull(timeout / 2) {
                try {
                    val processBuilder = ProcessBuilder(*commandArray)
                    processBuilder.redirectErrorStream(true)
                    val p = processBuilder.start()

                    // Give it a moment to start
                    Thread.sleep(100)

                    // Check if process started successfully
                    if (p.isAlive) {
                        Log.d(TAG, "Process started successfully")
                        p.destroy()
                        ValidationResult(
                            success = true,
                            message = "Process started successfully",
                            protocol = "stdio",
                            details = mapOf("command" to config.command)
                        )
                    } else {
                        Log.w(TAG, "Process failed to start")
                        ValidationResult(
                            success = false,
                            message = "Process failed to start",
                            protocol = "stdio"
                        )
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Exception starting process", e)
                    null
                }
            }

            // Handle timeout
            if (process == null) {
                Log.w(TAG, "STDIO validation timed out")
                ValidationResult(
                    success = false,
                    message = "Process start timed out after ${timeout / 2}ms",
                    protocol = "stdio"
                )
            } else {
                process
            }
        } catch (e: Exception) {
            Log.e(TAG, "STDIO validation error", e)
            ValidationResult(
                success = false,
                message = "STDIO validation error: ${e.message}",
                protocol = "stdio",
                error = e
            )
        }
    }

    /**
     * Validate SSE transport configuration.
     *
     * For SSE, we verify:
     * 1. URL is valid
     * 2. Server responds to HTTP GET request
     * 3. Optional: Authentication headers are valid
     */
    private suspend fun validateSSE(
        config: MCPTransportConfig.SSEConfig,
        timeout: Long
    ): ValidationResult {
        Log.d(TAG, "Validating SSE transport")
        Log.d(TAG, "URL: ${config.url}")
        Log.d(TAG, "Auth: ${config.authentication}")
        Log.d(TAG, "Headers: ${config.headers.size} custom headers")

        return try {
            // Validate URL is not blank
            if (config.url.isBlank()) {
                Log.w(TAG, "SSE validation failed: URL is blank")
                return ValidationResult(
                    success = false,
                    message = "Server URL cannot be empty",
                    protocol = "sse"
                )
            }

            // Validate URL format
            if (!config.url.startsWith("http://") && !config.url.startsWith("https://")) {
                Log.w(TAG, "SSE validation failed: Invalid URL format")
                return ValidationResult(
                    success = false,
                    message = "Invalid URL format. Must start with http:// or https://",
                    protocol = "sse"
                )
            }

            // Create HTTP client
            val client = HttpClient(CIO) {
                install(HttpTimeout) {
                    requestTimeoutMillis = timeout
                    connectTimeoutMillis = timeout / 2
                }
                install(Logging) {
                    logger = object : Logger {
                        override fun log(message: String) {
                            Log.d(TAG, message)
                        }
                    }
                    level = LogLevel.INFO
                }
            }

            try {
                // Make GET request to verify server is reachable
                val response = withTimeoutOrNull(timeout) {
                    client.get(config.url) {
                        // Apply authentication headers
                        when (config.authentication) {
                            AuthType.AUTH_HEADER -> {
                                config.headers.forEach { (key, value) ->
                                    header(key, value)
                                }
                            }
                            AuthType.OAUTH -> {
                                // OAuth would typically redirect, so we just check connectivity
                                config.headers.forEach { (key, value) ->
                                    header(key, value)
                                }
                            }
                            AuthType.NONE -> {
                                // No additional headers
                            }
                        }
                    }
                }

                // Handle timeout
                if (response == null) {
                    Log.w(TAG, "SSE validation timed out")
                    ValidationResult(
                        success = false,
                        message = "Connection timed out after ${timeout}ms",
                        protocol = "sse"
                    )
                } else {
                    val statusCode = response.status.value
                    Log.d(TAG, "SSE response status: $statusCode")

                    // For SSE, any 2xx or 3xx response indicates server is reachable
                    val isSuccess = response.status.value in 200..399

                    if (isSuccess) {
                        ValidationResult(
                            success = true,
                            message = "SSE endpoint reachable (status: $statusCode)",
                            protocol = "sse",
                            details = mapOf(
                                "url" to config.url,
                                "statusCode" to statusCode
                            )
                        )
                    } else {
                        ValidationResult(
                            success = false,
                            message = "Server returned error: $statusCode ${response.status.description}",
                            protocol = "sse",
                            details = mapOf("statusCode" to statusCode)
                        )
                    }
                }
            } finally {
                client.close()
            }
        } catch (e: Exception) {
            Log.e(TAG, "SSE validation error", e)
            ValidationResult(
                success = false,
                message = "SSE connection error: ${e.message}",
                protocol = "sse",
                error = e
            )
        }
    }

    /**
     * Validate HTTP transport configuration.
     *
     * For HTTP, we verify:
     * 1. URL is valid
     * 2. Server responds to HTTP POST request
     * 3. Optional: Authentication headers are valid
     * 4. Can send MCP initialize request
     */
    private suspend fun validateHttp(
        config: MCPTransportConfig.HttpConfig,
        timeout: Long
    ): ValidationResult {
        Log.d(TAG, "Validating HTTP transport")
        Log.d(TAG, "URL: ${config.url}")
        Log.d(TAG, "Auth: ${config.authentication}")
        Log.d(TAG, "Headers: ${config.headers.size} custom headers")

        return try {
            // Validate URL is not blank
            if (config.url.isBlank()) {
                Log.w(TAG, "HTTP validation failed: URL is blank")
                return ValidationResult(
                    success = false,
                    message = "Server URL cannot be empty",
                    protocol = "http"
                )
            }

            // Validate URL format
            if (!config.url.startsWith("http://") && !config.url.startsWith("https://")) {
                Log.w(TAG, "HTTP validation failed: Invalid URL format")
                return ValidationResult(
                    success = false,
                    message = "Invalid URL format. Must start with http:// or https://",
                    protocol = "http"
                )
            }

            // Create HTTP client
            val client = HttpClient(CIO) {
                install(HttpTimeout) {
                    requestTimeoutMillis = timeout
                    connectTimeoutMillis = timeout / 2
                }
                install(ContentNegotiation) {
                    json(Json {
                        ignoreUnknownKeys = true
                        isLenient = true
                    })
                }
                install(Logging) {
                    logger = object : Logger {
                        override fun log(message: String) {
                            Log.d(TAG, message)
                        }
                    }
                    level = LogLevel.INFO
                }
            }

            try {
                // Send MCP initialize request to verify server accepts MCP messages
                val mcpInitRequest = """{"jsonrpc":"2.0","method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{}},"id":1}"""

                val response = withTimeoutOrNull(timeout) {
                    client.post(config.url) {
                        contentType(ContentType.Application.Json)

                        // Apply authentication headers
                        when (config.authentication) {
                            AuthType.AUTH_HEADER -> {
                                config.headers.forEach { (key, value) ->
                                    header(key, value)
                                }
                            }
                            AuthType.OAUTH -> {
                                // OAuth would typically redirect, so we just check connectivity
                                config.headers.forEach { (key, value) ->
                                    header(key, value)
                                }
                            }
                            AuthType.NONE -> {
                                // No additional headers
                            }
                        }

                        setBody(mcpInitRequest)
                    }
                }

                // Handle timeout
                if (response == null) {
                    Log.w(TAG, "HTTP validation timed out")
                    ValidationResult(
                        success = false,
                        message = "Connection timed out after ${timeout}ms",
                        protocol = "http"
                    )
                } else {
                    val statusCode = response.status.value
                    Log.d(TAG, "HTTP response status: $statusCode")

                    // For HTTP MCP, 2xx responses indicate success
                    val isSuccess = response.status.value in 200..299

                    if (isSuccess) {
                        ValidationResult(
                            success = true,
                            message = "HTTP endpoint accepts MCP messages (status: $statusCode)",
                            protocol = "http",
                            details = mapOf(
                                "url" to config.url,
                                "statusCode" to statusCode
                            )
                        )
                    } else if (response.status.value == HttpStatusCode.MethodNotAllowed.value) {
                        // 405 means server exists but doesn't accept POST - still a valid endpoint
                        ValidationResult(
                            success = true,
                            message = "HTTP endpoint reachable (status: $statusCode - method not allowed is acceptable for validation)",
                            protocol = "http",
                            details = mapOf(
                                "url" to config.url,
                                "statusCode" to statusCode
                            )
                        )
                    } else {
                        ValidationResult(
                            success = false,
                            message = "Server returned error: $statusCode ${response.status.description}",
                            protocol = "http",
                            details = mapOf("statusCode" to statusCode)
                        )
                    }
                }
            } finally {
                client.close()
            }
        } catch (e: Exception) {
            Log.e(TAG, "HTTP validation error", e)
            ValidationResult(
                success = false,
                message = "HTTP connection error: ${e.message}",
                protocol = "http",
                error = e
            )
        }
    }
}

/**
 * Result of transport validation.
 */
data class ValidationResult(
    val success: Boolean,
    val message: String,
    val protocol: String,
    val details: Map<String, Any> = emptyMap(),
    val error: Throwable? = null
) {
    /**
     * Convert to Map for Flutter platform channel response.
     */
    fun toMap(): Map<String, Any> {
        return mutableMapOf<String, Any>().apply {
            put("success", success)
            put("message", message)
            put("protocol", protocol)
            putAll(details)
        }
    }
}

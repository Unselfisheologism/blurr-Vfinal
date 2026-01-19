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
import io.github.oshai.kotlinlogging.KotlinLogging

/**
 * Protocol-specific validation for MCP transport connections.
 *
 * Each transport protocol (STDIO, SSE, HTTP) has different validation requirements:
 * - STDIO: Verify command is executable and process can be started
 * - SSE: Make HTTP GET request to verify server is reachable
 * - HTTP: Make HTTP POST request to verify server accepts MCP messages
 *
 * DEFENSIVE CODING: This validator is designed to NEVER throw exceptions that could crash the app.
 * Every operation is wrapped in try-catch blocks and returns a ValidationResult.
 */
object MCPTransportValidator {
    private const val TAG = "MCPTransportValidator"
    private val logger = KotlinLogging.logger {}

    /**
     * Validate MCP connection based on protocol-specific configuration.
     *
     * @param config Transport configuration (StdioConfig, SSEConfig, or HttpConfig)
     * @param timeout Timeout in milliseconds (default: 5000ms)
     * @return ValidationResult indicating success/failure and message
     *
     * DEFENSIVE: This method NEVER throws exceptions. All errors are caught and returned as ValidationResult.
     */
    suspend fun validate(
        config: MCPTransportConfig,
        timeout: Long = 5000L
    ): ValidationResult {
        return try {
            logger.info { "=== Starting MCP Transport Validation ===" }
            Log.d(TAG, "=== Starting MCP Transport Validation ===")
            
            try {
                logger.debug { "Protocol: ${config::class.simpleName}" }
                logger.debug { "Server: ${config.serverName}" }
                logger.debug { "Timeout: ${timeout}ms" }
                
                Log.d(TAG, "Protocol: ${config::class.simpleName}")
                Log.d(TAG, "Server: ${config.serverName}")
                Log.d(TAG, "Timeout: ${timeout}ms")
            } catch (e: Exception) {
                logger.warn(e) { "Error logging config details" }
            }

            val result = try {
                when (config) {
                    is MCPTransportConfig.StdioConfig -> {
                        logger.debug { "Routing to STDIO validator" }
                        validateStdio(config, timeout)
                    }
                    is MCPTransportConfig.SSEConfig -> {
                        logger.debug { "Routing to SSE validator" }
                        validateSSE(config, timeout)
                    }
                    is MCPTransportConfig.HttpConfig -> {
                        logger.debug { "Routing to HTTP validator" }
                        validateHttp(config, timeout)
                    }
                }
            } catch (e: Exception) {
                logger.error(e) { "FATAL: Exception in protocol-specific validator routing" }
                ValidationResult(
                    success = false,
                    message = "Validation routing error: ${e.message ?: "Unknown"}",
                    protocol = "unknown",
                    error = e
                )
            }
            
            logger.info { "Validation completed: success=${result.success}" }
            result
        } catch (e: Exception) {
            logger.error(e) { "FATAL: Top-level exception in validate()" }
            Log.e(TAG, "FATAL: Top-level exception in validate()", e)
            ValidationResult(
                success = false,
                message = "Critical validation error: ${e.message ?: "Unknown"}",
                protocol = "unknown",
                error = e
            )
        }
    }

    /**
     * Validate STDIO transport configuration.
     *
     * For STDIO, we verify:
     * 1. Command is not empty
     * 2. Command is executable
     * 3. Process can be started (with optional args)
     *
     * DEFENSIVE: Every operation is wrapped in try-catch. Never throws exceptions.
     */
    private suspend fun validateStdio(
        config: MCPTransportConfig.StdioConfig,
        timeout: Long
    ): ValidationResult {
        return try {
            logger.info { "=== Validating STDIO transport ===" }
            Log.d(TAG, "Validating STDIO transport")
            
            try {
                logger.debug { "Command: ${config.command}" }
                logger.debug { "Args: ${config.args}" }
                Log.d(TAG, "Command: ${config.command}")
                Log.d(TAG, "Args: ${config.args}")
            } catch (e: Exception) {
                logger.warn(e) { "Error logging command details" }
            }

            // Validate command is not empty
            if (config.command.isBlank()) {
                logger.warn { "STDIO validation failed: Command is blank" }
                Log.w(TAG, "STDIO validation failed: Command is blank")
                return ValidationResult(
                    success = false,
                    message = "Command cannot be empty",
                    protocol = "stdio"
                )
            }

            // Build command with args
            val commandList = try {
                mutableListOf(config.command).apply {
                    addAll(config.args)
                }
            } catch (e: Exception) {
                logger.error(e) { "Error building command list" }
                return ValidationResult(
                    success = false,
                    message = "Error building command: ${e.message}",
                    protocol = "stdio",
                    error = e
                )
            }
            
            val commandArray = try {
                commandList.toTypedArray()
            } catch (e: Exception) {
                logger.error(e) { "Error converting to array" }
                return ValidationResult(
                    success = false,
                    message = "Error preparing command: ${e.message}",
                    protocol = "stdio",
                    error = e
                )
            }

            logger.debug { "Attempting to start process: ${commandList.joinToString(" ")}" }
            Log.d(TAG, "Attempting to start process: ${commandList.joinToString(" ")}")

            // Try to start the process with comprehensive error handling
            val process = try {
                withTimeoutOrNull(timeout / 2) {
                    try {
                        logger.debug { "Creating ProcessBuilder..." }
                        val processBuilder = try {
                            ProcessBuilder(*commandArray)
                        } catch (e: Exception) {
                            logger.error(e) { "Failed to create ProcessBuilder" }
                            return@withTimeoutOrNull null
                        }
                        
                        try {
                            processBuilder.redirectErrorStream(true)
                        } catch (e: Exception) {
                            logger.warn(e) { "Failed to redirect error stream" }
                        }
                        
                        logger.debug { "Starting process..." }
                        val p = try {
                            processBuilder.start()
                        } catch (e: Exception) {
                            logger.error(e) { "Failed to start process" }
                            return@withTimeoutOrNull null
                        }

                        // Give it a moment to start
                        try {
                            Thread.sleep(100)
                        } catch (e: Exception) {
                            logger.warn(e) { "Sleep interrupted" }
                        }

                        // Check if process started successfully
                        val isAlive = try {
                            p.isAlive
                        } catch (e: Exception) {
                            logger.error(e) { "Failed to check if process is alive" }
                            false
                        }
                        
                        if (isAlive) {
                            logger.info { "Process started successfully" }
                            Log.d(TAG, "Process started successfully")
                            try {
                                p.destroy()
                            } catch (e: Exception) {
                                logger.warn(e) { "Failed to destroy process" }
                            }
                            ValidationResult(
                                success = true,
                                message = "Process started successfully",
                                protocol = "stdio",
                                details = mapOf("command" to config.command)
                            )
                        } else {
                            logger.warn { "Process failed to start or exited immediately" }
                            Log.w(TAG, "Process failed to start")
                            ValidationResult(
                                success = false,
                                message = "Process failed to start",
                                protocol = "stdio"
                            )
                        }
                    } catch (e: Exception) {
                        logger.error(e) { "Exception in process validation logic" }
                        Log.e(TAG, "Exception starting process", e)
                        null
                    }
                }
            } catch (e: Exception) {
                logger.error(e) { "Exception in withTimeoutOrNull" }
                null
            }

            // Handle timeout or null result
            if (process == null) {
                logger.warn { "STDIO validation timed out or failed" }
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
            logger.error(e) { "FATAL: Top-level exception in validateStdio" }
            Log.e(TAG, "STDIO validation error", e)
            ValidationResult(
                success = false,
                message = "STDIO validation error: ${e.message ?: "Unknown"}",
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
     *
     * DEFENSIVE: Every operation is wrapped in try-catch. Never throws exceptions.
     */
    private suspend fun validateSSE(
        config: MCPTransportConfig.SSEConfig,
        timeout: Long
    ): ValidationResult {
        return try {
            logger.info { "=== Validating SSE transport ===" }
            Log.d(TAG, "Validating SSE transport")
            
            try {
                logger.debug { "URL: ${config.url}" }
                logger.debug { "Auth: ${config.authentication}" }
                logger.debug { "Headers: ${config.headers.size} custom headers" }
                Log.d(TAG, "URL: ${config.url}")
                Log.d(TAG, "Auth: ${config.authentication}")
                Log.d(TAG, "Headers: ${config.headers.size} custom headers")
            } catch (e: Exception) {
                logger.warn(e) { "Error logging SSE config details" }
            }

            try {
                // Validate URL is not blank
            if (config.url.isBlank()) {
                logger.warn { "SSE validation failed: URL is blank" }
                Log.w(TAG, "SSE validation failed: URL is blank")
                return ValidationResult(
                    success = false,
                    message = "Server URL cannot be empty",
                    protocol = "sse"
                )
            }

            // Validate URL format
            if (!config.url.startsWith("http://") && !config.url.startsWith("https://")) {
                logger.warn { "SSE validation failed: Invalid URL format" }
                Log.w(TAG, "SSE validation failed: Invalid URL format")
                return ValidationResult(
                    success = false,
                    message = "Invalid URL format. Must start with http:// or https://",
                    protocol = "sse"
                )
            }

            // Create HTTP client with comprehensive error handling
            logger.debug { "Creating HTTP client for SSE..." }
            val client = try {
                HttpClient(CIO) {
                    try {
                        install(HttpTimeout) {
                            requestTimeoutMillis = timeout
                            connectTimeoutMillis = timeout / 2
                        }
                    } catch (e: Exception) {
                        logger.warn(e) { "Failed to install HttpTimeout" }
                    }
                    try {
                        install(Logging) {
                            logger = object : Logger {
                                override fun log(message: String) {
                                    Log.d(TAG, message)
                                }
                            }
                            level = LogLevel.INFO
                        }
                    } catch (e: Exception) {
                        logger.warn(e) { "Failed to install Logging" }
                    }
                }
            } catch (e: Exception) {
                logger.error(e) { "Failed to create HTTP client" }
                return ValidationResult(
                    success = false,
                    message = "Failed to create HTTP client: ${e.message}",
                    protocol = "sse",
                    error = e
                )
            }

            try {
                // Make GET request to verify server is reachable
                logger.debug { "Making GET request to ${config.url}..." }
                val response = try {
                    withTimeoutOrNull(timeout) {
                        try {
                            client.get(config.url) {
                                // Apply authentication headers
                                try {
                                    when (config.authentication) {
                                        AuthType.AUTH_HEADER -> {
                                            config.headers.forEach { (key, value) ->
                                                try {
                                                    header(key, value)
                                                } catch (e: Exception) {
                                                    logger.warn(e) { "Failed to set header: $key" }
                                                }
                                            }
                                        }
                                        AuthType.OAUTH -> {
                                            // OAuth would typically redirect, so we just check connectivity
                                            config.headers.forEach { (key, value) ->
                                                try {
                                                    header(key, value)
                                                } catch (e: Exception) {
                                                    logger.warn(e) { "Failed to set OAuth header: $key" }
                                                }
                                            }
                                        }
                                        AuthType.NONE -> {
                                            // No additional headers
                                        }
                                    }
                                } catch (e: Exception) {
                                    logger.warn(e) { "Error applying authentication" }
                                }
                            }
                        } catch (e: Exception) {
                            logger.error(e) { "Error making GET request" }
                            null
                        }
                    }
                } catch (e: Exception) {
                    logger.error(e) { "Error in withTimeoutOrNull" }
                    null
                }

                // Handle timeout or error
                if (response == null) {
                    logger.warn { "SSE validation timed out or failed" }
                    Log.w(TAG, "SSE validation timed out")
                    ValidationResult(
                        success = false,
                        message = "Connection timed out after ${timeout}ms",
                        protocol = "sse"
                    )
                } else {
                    val statusCode = try {
                        response.status.value
                    } catch (e: Exception) {
                        logger.error(e) { "Failed to get status code" }
                        0
                    }
                    
                    logger.debug { "SSE response status: $statusCode" }
                    Log.d(TAG, "SSE response status: $statusCode")

                    // For SSE, any 2xx or 3xx response indicates server is reachable
                    val isSuccess = statusCode in 200..399

                    if (isSuccess) {
                        logger.info { "SSE endpoint reachable (status: $statusCode)" }
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
                        logger.warn { "Server returned error: $statusCode" }
                        val description = try {
                            response.status.description
                        } catch (e: Exception) {
                            "Unknown"
                        }
                        ValidationResult(
                            success = false,
                            message = "Server returned error: $statusCode $description",
                            protocol = "sse",
                            details = mapOf("statusCode" to statusCode)
                        )
                    }
                }
            } catch (e: Exception) {
                logger.error(e) { "Exception in SSE validation logic" }
                ValidationResult(
                    success = false,
                    message = "SSE validation error: ${e.message ?: "Unknown"}",
                    protocol = "sse",
                    error = e
                )
            } finally {
                try {
                    client.close()
                } catch (e: Exception) {
                    logger.warn(e) { "Failed to close HTTP client" }
                }
            }
        } catch (e: Exception) {
            logger.error(e) { "Exception in URL validation" }
            ValidationResult(
                success = false,
                message = "SSE validation error: ${e.message ?: "Unknown"}",
                protocol = "sse",
                error = e
            )
        }
        } catch (e: Exception) {
            logger.error(e) { "FATAL: Top-level exception in validateSSE" }
            Log.e(TAG, "SSE validation error", e)
            ValidationResult(
                success = false,
                message = "SSE connection error: ${e.message ?: "Unknown"}",
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
     * 2. Server is reachable via HTTP
     * 3. Optional: Authentication headers are valid
     *
     * NOTE: This validator ONLY checks connectivity, NOT MCP protocol-level initialization.
     * The MCP SDK's Client.connect() method handles protocol initialization automatically,
     * including sending InitializeRequest with protocol version and capabilities.
     *
     * DEFENSIVE: Every operation is wrapped in try-catch. Never throws exceptions.
     */
    private suspend fun validateHttp(
        config: MCPTransportConfig.HttpConfig,
        timeout: Long
    ): ValidationResult {
        return try {
            logger.info { "=== Validating HTTP transport ===" }
            Log.d(TAG, "Validating HTTP transport")
            
            try {
                logger.debug { "URL: ${config.url}" }
                logger.debug { "Auth: ${config.authentication}" }
                logger.debug { "Headers: ${config.headers.size} custom headers" }
                Log.d(TAG, "URL: ${config.url}")
                Log.d(TAG, "Auth: ${config.authentication}")
                Log.d(TAG, "Headers: ${config.headers.size} custom headers")
            } catch (e: Exception) {
                logger.warn(e) { "Error logging HTTP config details" }
            }

            try {
                // Validate URL is not blank
            if (config.url.isBlank()) {
                logger.warn { "HTTP validation failed: URL is blank" }
                Log.w(TAG, "HTTP validation failed: URL is blank")
                return ValidationResult(
                    success = false,
                    message = "Server URL cannot be empty",
                    protocol = "http"
                )
            }

            // Validate URL format
            if (!config.url.startsWith("http://") && !config.url.startsWith("https://")) {
                logger.warn { "HTTP validation failed: Invalid URL format" }
                Log.w(TAG, "HTTP validation failed: Invalid URL format")
                return ValidationResult(
                    success = false,
                    message = "Invalid URL format. Must start with http:// or https://",
                    protocol = "http"
                )
            }

            // Create HTTP client with comprehensive error handling
            logger.debug { "Creating HTTP client..." }
            val client = try {
                HttpClient(CIO) {
                    try {
                        install(HttpTimeout) {
                            requestTimeoutMillis = timeout
                            connectTimeoutMillis = timeout / 2
                        }
                    } catch (e: Exception) {
                        logger.warn(e) { "Failed to install HttpTimeout" }
                    }
                    try {
                        install(ContentNegotiation) {
                            json(Json {
                                ignoreUnknownKeys = true
                                isLenient = true
                            })
                        }
                    } catch (e: Exception) {
                        logger.warn(e) { "Failed to install ContentNegotiation" }
                    }
                    try {
                        install(Logging) {
                            logger = object : Logger {
                                override fun log(message: String) {
                                    Log.d(TAG, message)
                                }
                            }
                            level = LogLevel.INFO
                        }
                    } catch (e: Exception) {
                        logger.warn(e) { "Failed to install Logging" }
                    }
                }
            } catch (e: Exception) {
                logger.error(e) { "Failed to create HTTP client" }
                return ValidationResult(
                    success = false,
                    message = "Failed to create HTTP client: ${e.message}",
                    protocol = "http",
                    error = e
                )
            }

            try {
                // CONNECTIVITY CHECK ONLY: Simple GET request to verify server is reachable
                // We do NOT send MCP protocol messages here - that's handled by Client.connect()
                logger.debug { "Checking HTTP endpoint connectivity (GET request)" }
                Log.d(TAG, "Checking HTTP endpoint connectivity (GET request)")
                
                val response = try {
                    withTimeoutOrNull(timeout) {
                        try {
                            client.get(config.url) {
                                // Apply authentication headers
                                try {
                                    when (config.authentication) {
                                        AuthType.AUTH_HEADER -> {
                                            config.headers.forEach { (key, value) ->
                                                try {
                                                    header(key, value)
                                                } catch (e: Exception) {
                                                    logger.warn(e) { "Failed to set header: $key" }
                                                }
                                            }
                                        }
                                        AuthType.OAUTH -> {
                                            // OAuth would typically redirect, so we just check connectivity
                                            config.headers.forEach { (key, value) ->
                                                try {
                                                    header(key, value)
                                                } catch (e: Exception) {
                                                    logger.warn(e) { "Failed to set OAuth header: $key" }
                                                }
                                            }
                                        }
                                        AuthType.NONE -> {
                                            // No additional headers
                                        }
                                    }
                                } catch (e: Exception) {
                                    logger.warn(e) { "Error applying authentication" }
                                }
                            }
                        } catch (e: Exception) {
                            logger.error(e) { "Error making GET request" }
                            null
                        }
                    }
                } catch (e: Exception) {
                    logger.error(e) { "Error in withTimeoutOrNull" }
                    null
                }

                // Handle timeout or error
                if (response == null) {
                    logger.warn { "HTTP validation timed out or failed" }
                    Log.w(TAG, "HTTP validation timed out")
                    ValidationResult(
                        success = false,
                        message = "Connection timed out after ${timeout}ms",
                        protocol = "http"
                    )
                } else {
                    val statusCode = try {
                        response.status.value
                    } catch (e: Exception) {
                        logger.error(e) { "Failed to get status code" }
                        0
                    }
                    
                    logger.debug { "HTTP response status: $statusCode" }
                    Log.d(TAG, "HTTP response status: $statusCode")

                    // For connectivity validation, accept any response that indicates the server exists
                    // 2xx, 3xx, 4xx (except timeout) all mean server is reachable
                    val isReachable = statusCode in 200..499

                    if (isReachable) {
                        logger.info { "HTTP endpoint reachable (status: $statusCode)" }
                        ValidationResult(
                            success = true,
                            message = "HTTP endpoint reachable (status: $statusCode). MCP protocol initialization will be handled by SDK.",
                            protocol = "http",
                            details = mapOf(
                                "url" to config.url,
                                "statusCode" to statusCode
                            )
                        )
                    } else {
                        logger.warn { "Server returned error: $statusCode" }
                        val description = try {
                            response.status.description
                        } catch (e: Exception) {
                            "Unknown"
                        }
                        ValidationResult(
                            success = false,
                            message = "Server returned error: $statusCode $description",
                            protocol = "http",
                            details = mapOf("statusCode" to statusCode)
                        )
                    }
                }
            } catch (e: Exception) {
                logger.error(e) { "Exception in HTTP validation logic" }
                ValidationResult(
                    success = false,
                    message = "HTTP validation error: ${e.message ?: "Unknown"}",
                    protocol = "http",
                    error = e
                )
            } finally {
                try {
                    client.close()
                } catch (e: Exception) {
                    logger.warn(e) { "Failed to close HTTP client" }
                }
            }
        } catch (e: Exception) {
            logger.error(e) { "Exception in URL validation" }
            ValidationResult(
                success = false,
                message = "HTTP validation error: ${e.message ?: "Unknown"}",
                protocol = "http",
                error = e
            )
        }
        } catch (e: Exception) {
            logger.error(e) { "FATAL: Top-level exception in validateHttp" }
            Log.e(TAG, "HTTP validation error", e)
            ValidationResult(
                success = false,
                message = "HTTP connection error: ${e.message ?: "Unknown"}",
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

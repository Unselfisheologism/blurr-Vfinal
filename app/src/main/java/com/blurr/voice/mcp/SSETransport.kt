package com.blurr.voice.mcp

import android.util.Log
import io.ktor.client.HttpClient
import io.ktor.client.engine.okhttp.OkHttp
import io.ktor.client.plugins.HttpTimeout
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.plugins.logging.LogLevel
import io.ktor.client.plugins.logging.Logger
import io.ktor.client.plugins.logging.Logging
import io.ktor.client.plugins.sse.SSE
import io.ktor.serialization.kotlinx.json.json
import io.modelcontextprotocol.kotlin.sdk.client.SseClientTransport
import kotlinx.serialization.json.Json
import kotlinx.coroutines.runBlocking

/**
 * SSE Transport Implementation using Official MCP Kotlin SDK
 *
 * Uses Server-Sent Events for streaming communication.
 * Reference: https://github.com/modelcontextprotocol/kotlin-sdk
 */
class SSETransport(
    private val url: String
) {
    companion object {
        private const val TAG = "SSETransport"
    }

    private var transport: SseClientTransport? = null
    private var httpClient: HttpClient? = null

    /**
     * Create the SSE transport with proper error handling callbacks
     */
    fun createTransport(): SseClientTransport {
        Log.d(TAG, "Creating SSE transport for: $url")

        var createdClient: HttpClient? = null
        var createdTransport: SseClientTransport? = null

        try {
            // Create Ktor HTTP client with SSE support
            createdClient = try {
                HttpClient(OkHttp) {
                    install(SSE)
                    install(HttpTimeout) {
                        // Socket-level timeout for data read operations (5 seconds)
                        socketTimeoutMillis = 5000
                        // Connection establishment timeout (2 seconds)
                        connectTimeoutMillis = 2000
                        // Overall request timeout (10 seconds)
                        requestTimeoutMillis = 10000
                    }
                    install(ContentNegotiation) {
                        json(Json {
                            ignoreUnknownKeys = true
                            prettyPrint = true
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
            } catch (e: Exception) {
                Log.e(TAG, "Failed to create HTTP client for SSE transport", e)
                throw IllegalStateException("Failed to create HTTP client: ${e.message}", e)
            }

            httpClient = createdClient

            // Create SSE transport
            createdTransport = try {
                SseClientTransport(
                    client = createdClient,
                    urlString = url
                )
            } catch (e: Exception) {
                Log.e(TAG, "Failed to create SseClientTransport for: $url", e)
                throw IllegalStateException("Failed to create SSE transport: ${e.message}", e)
            }

            // Set up error handling callbacks (as per Kotlin SDK documentation)
            createdTransport.onError { error ->
                Log.e(TAG, "SseClientTransport error: ${error.message}", error)
                Log.e(TAG, "Error occurred on SSE transport: $url")
                
                // SSE transports support automatic reconnection
                // The SDK handles reconnection internally, we just log here
                Log.d(TAG, "SSE transport may attempt automatic reconnection")
            }

            createdTransport.onClose {
                Log.d(TAG, "SseClientTransport closed for: $url")
                Log.d(TAG, "SSE connection terminated")
            }

            // Update instance variables only after successful creation
            transport = createdTransport

            Log.d(TAG, "SSE transport created successfully with error handlers")
            return createdTransport
        } catch (e: Exception) {
            Log.e(TAG, "Failed to create SSE transport for: $url", e)
            
            // Clean up any partially created resources
            try {
                runBlocking {
                    createdTransport?.close()
                }
            } catch (cleanupException: Exception) {
                Log.w(TAG, "Error closing transport during cleanup", cleanupException)
            }
            
            try {
                createdClient?.close()
            } catch (cleanupException: Exception) {
                Log.w(TAG, "Error closing HTTP client during cleanup", cleanupException)
            }
            
            throw e
        }
    }

    /**
     * Get the underlying SDK transport
     */
    fun getTransport(): SseClientTransport {
        return transport ?: createTransport()
    }

    /**
     * Close the transport
     */
    fun close() {
        Log.d(TAG, "Closing SSE transport")
        
        // SDK transports implement Closeable with suspend close()
        runBlocking {
            transport?.close()
        }
        httpClient?.close()
        transport = null
        httpClient = null
    }
}

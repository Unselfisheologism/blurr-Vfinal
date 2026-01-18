package com.blurr.voice.mcp

import android.util.Log
import io.ktor.client.HttpClient
import io.ktor.client.engine.cio.CIO
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.plugins.logging.LogLevel
import io.ktor.client.plugins.logging.Logger
import io.ktor.client.plugins.logging.Logging
import io.ktor.client.plugins.sse.SSE
import io.ktor.serialization.kotlinx.json.json
import kotlinx.serialization.json.Json
import io.modelcontextprotocol.kotlin.sdk.client.StreamableHttpClientTransport
import kotlinx.coroutines.runBlocking

/**
 * HTTP Transport Implementation using Official MCP Kotlin SDK
 *
 * Uses Streamable HTTP transport for MCP communication.
 * Reference: https://github.com/modelcontextprotocol/kotlin-sdk
 */
class HttpTransport(
    private val url: String
) {
    companion object {
        private const val TAG = "HttpTransport"
    }

    private var transport: StreamableHttpClientTransport? = null
    private var httpClient: HttpClient? = null

    /**
     * Create the HTTP transport with proper error handling callbacks
     */
    fun createTransport(): StreamableHttpClientTransport {
        Log.d(TAG, "Creating HTTP transport for: $url")

        var createdClient: HttpClient? = null
        var createdTransport: StreamableHttpClientTransport? = null

        try {
            // Create Ktor HTTP client
            createdClient = try {
                HttpClient(CIO) {
                    install(SSE) // Required for potential SSE responses
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
                Log.e(TAG, "Failed to create HTTP client", e)
                throw IllegalStateException("Failed to create HTTP client: ${e.message}", e)
            }

            httpClient = createdClient

            // Create Streamable HTTP transport
            createdTransport = try {
                StreamableHttpClientTransport(
                    client = createdClient,
                    url = url
                )
            } catch (e: Exception) {
                Log.e(TAG, "Failed to create StreamableHttpClientTransport for: $url", e)
                throw IllegalStateException("Failed to create HTTP transport: ${e.message}", e)
            }

            // Set up error handling callbacks (as per Kotlin SDK documentation)
            createdTransport.onError { error ->
                Log.e(TAG, "StreamableHttpClientTransport error: ${error.message}", error)
                
                // Check for StreamableHttpError
                if (error is io.modelcontextprotocol.kotlin.sdk.client.StreamableHttpError) {
                    Log.e(TAG, "Streamable HTTP Error Code: ${error.code}")
                }
                
                // Log additional context
                Log.e(TAG, "Error occurred on transport: $url")
            }

            createdTransport.onClose {
                Log.d(TAG, "StreamableHttpClientTransport closed for: $url")
                Log.d(TAG, "Transport connection terminated gracefully")
            }

            // Update instance variables only after successful creation
            transport = createdTransport

            Log.d(TAG, "HTTP transport created successfully with error handlers")
            return createdTransport
        } catch (e: Exception) {
            Log.e(TAG, "Failed to create HTTP transport for: $url", e)
            
            // Clean up any partially created resources
            try {
                createdTransport?.close()
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
    fun getTransport(): StreamableHttpClientTransport {
        return transport ?: createTransport()
    }

    /**
     * Close the transport
     */
    fun close() {
        Log.d(TAG, "Closing HTTP transport")
        
        // SDK transports implement Closeable with suspend close()
        runBlocking {
            transport?.close()
        }
        httpClient?.close()
        transport = null
        httpClient = null
    }
}

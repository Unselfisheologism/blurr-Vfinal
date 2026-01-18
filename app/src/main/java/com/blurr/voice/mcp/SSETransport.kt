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

        // Create Ktor HTTP client with SSE support
        val client = HttpClient(CIO) {
            install(SSE)
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

        httpClient = client

        // Create SSE transport
        transport = SseClientTransport(
            client = client,
            urlString = url
        )

        // Set up error handling callbacks (as per Kotlin SDK documentation)
        transport!!.onError { error ->
            Log.e(TAG, "SseClientTransport error: ${error.message}", error)
            Log.e(TAG, "Error occurred on SSE transport: $url")
            
            // SSE transports support automatic reconnection
            // The SDK handles reconnection internally, we just log here
            Log.d(TAG, "SSE transport may attempt automatic reconnection")
        }

        transport!!.onClose {
            Log.d(TAG, "SseClientTransport closed for: $url")
            Log.d(TAG, "SSE connection terminated")
        }

        Log.d(TAG, "SSE transport created successfully with error handlers")
        return transport!!
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

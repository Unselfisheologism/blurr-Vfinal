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
     * Create the SSE transport
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
        transport?.close()
        httpClient?.close()
        transport = null
        httpClient = null
    }
}

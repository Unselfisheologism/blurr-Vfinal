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
     * Create the HTTP transport
     */
    fun createTransport(): StreamableHttpClientTransport {
        Log.d(TAG, "Creating HTTP transport for: $url")

        // Create Ktor HTTP client
        val client = HttpClient(CIO) {
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

        httpClient = client

        // Create Streamable HTTP transport
        transport = StreamableHttpClientTransport(
            client = client,
            url = url
        )

        return transport!!
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

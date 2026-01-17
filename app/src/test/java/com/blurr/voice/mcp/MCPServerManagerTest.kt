package com.blurr.voice.mcp

import android.content.Context
import android.util.Log
import io.mockk.MockKAnnotations
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.every
import io.mockk.impl.annotations.MockK
import io.mockk.mockk
import kotlinx.coroutines.test.runTest
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.junit.MockitoJUnitRunner

/**
 * Test suite for MCPServerManager using the fixed implementation.
 * 
 * This test validates that:
 * 1. The SDK's Client class handles protocol initialization automatically
 * 2. TransportFactory properly creates and connects transports
 * 3. No manual protocol parameter handling is required
 * 4. The "Missing protocol parameter" error is resolved
 */
@RunWith(MockitoJUnitRunner::class)
class MCPServerManagerTest {

    @MockK
    private lateinit var mockContext: Context

    private lateinit var mcpServerManager: MCPServerManager

    @Before
    fun setup() {
        MockKAnnotations.init(this)
        mcpServerManager = MCPServerManager(mockContext)
    }

    /**
     * Test connecting to a DeepWiki MCP server via HTTP transport.
     * This test simulates the exact scenario that was causing the "Missing protocol parameter" error.
     */
    @Test
    fun testDeepWikiHTTPConnection() = runTest {
        // Test configuration for DeepWiki MCP server
        val serverName = "deepwiki-mcp"
        val serverUrl = "http://localhost:8000/mcp" // Example DeepWiki endpoint
        val transportType = TransportType.HTTP

        Log.d("MCPServerManagerTest", "Testing DeepWiki MCP connection...")
        Log.d("MCPServerManagerTest", "Server: $serverName")
        Log.d("MCPServerManagerTest", "URL: $serverUrl")
        Log.d("MCPServerManagerTest", "Transport: $transportType")

        // This would previously fail with "Missing protocol parameter" error
        // Now it should work because:
        // 1. TransportFactory.create() returns proper SDK transport instances
        // 2. TransportFactory.connectClient() uses SDK's Client.connect() which handles protocol automatically
        // 3. MCPTransportValidator only tests connectivity, not protocol initialization
        
        // Simulate successful connection
        val result = mcpServerManager.connectServer(serverName, serverUrl, transportType)
        
        // The result should be successful, indicating the protocol handshake worked
        assert(result.isSuccess) { "DeepWiki connection should succeed with fixed implementation" }
        
        val serverInfo = result.getOrNull()
        assert(serverInfo != null) { "Server info should be available after successful connection" }
        
        Log.d("MCPServerManagerTest", "Connection successful!")
        Log.d("MCPServerManagerTest", "Server: ${serverInfo?.serverName}")
        Log.d("MCPServerManagerTest", "Tools: ${serverInfo?.toolCount}")
    }

    /**
     * Test SSE transport connection.
     * This validates that SSE transport works correctly with the SDK.
     */
    @Test
    fun testSSERConnection() = runTest {
        val serverName = "deepwiki-sse"
        val serverUrl = "http://localhost:8000/sse"
        val transportType = TransportType.SSE

        Log.d("MCPServerManagerTest", "Testing DeepWiki SSE connection...")
        
        val result = mcpServerManager.connectServer(serverName, serverUrl, transportType)
        
        assert(result.isSuccess) { "SSE connection should succeed" }
        Log.d("MCPServerManagerTest", "SSE connection successful!")
    }

    /**
     * Test STDIO transport connection.
     * This validates that STDIO transport works correctly with the SDK.
     */
    @Test
    fun testStdioConnection() = runTest {
        val serverName = "deepwiki-stdio"
        val serverPath = "/path/to/deepwiki-mcp-server.py"
        val transportType = TransportType.STDIO

        Log.d("MCPServerManagerTest", "Testing DeepWiki STDIO connection...")
        
        val result = mcpServerManager.connectServer(serverName, serverPath, transportType)
        
        assert(result.isSuccess) { "STDIO connection should succeed" }
        Log.d("MCPServerManagerTest", "STDIO connection successful!")
    }

    /**
     * Test transport validation separately from connection.
     * This validates that validator only tests connectivity, not protocol.
     */
    @Test
    fun testTransportValidation() = runTest {
        // HTTP validation should only test connectivity, not send initialize requests
        val httpConfig = MCPTransportConfig.HttpConfig(
            serverName = "deepwiki-test",
            url = "http://localhost:8000/mcp"
        )
        
        val httpResult = MCPTransportValidator.validate(httpConfig)
        assert(httpResult.success) { "HTTP connectivity validation should succeed" }
        assert(httpResult.message.contains("MCP protocol initialization will be handled by SDK")) { 
            "Validation message should mention SDK handles protocol" 
        }
        
        // SSE validation should only test connectivity
        val sseConfig = MCPTransportConfig.SSEConfig(
            serverName = "deepwiki-sse-test",
            url = "http://localhost:8000/sse"
        )
        
        val sseResult = MCPTransportValidator.validate(sseConfig)
        assert(sseResult.success) { "SSE connectivity validation should succeed" }
        assert(sseResult.message.contains("MCP protocol initialization will be handled by SDK")) { 
            "SSE validation message should mention SDK handles protocol" 
        }
        
        Log.d("MCPServerManagerTest", "Transport validation tests passed!")
    }

    /**
     * Test that demonstrates the fix for the original "Missing protocol parameter" error.
     */
    @Test
    fun testProtocolParameterFix() = runTest {
        Log.d("MCPServerManagerTest", "=== Testing Protocol Parameter Fix ===")
        
        // This is what was causing the error in the original implementation:
        // val mcpInitRequest = """{"jsonrpc":"2.0","method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{}},"id":1}"""
        // client.post(config.url) { setBody(mcpInitRequest) }
        
        // With our fix:
        // 1. MCPTransportValidator no longer sends hardcoded initialize requests
        // 2. TransportFactory.connectClient() uses SDK's Client.connect() which handles protocol automatically
        // 3. The SDK's Client class sends proper InitializeRequest with all required parameters
        
        val serverName = "deepwiki-protocol-test"
        val serverUrl = "http://localhost:8000/mcp"
        val transportType = TransportType.HTTP

        val result = mcpServerManager.connectServer(serverName, serverUrl, transportType)
        
        // This should NOT fail with "Missing protocol parameter" anymore
        if (result.isFailure) {
            val error = result.exceptionOrNull()
            Log.e("MCPServerManagerTest", "Connection failed with: ${error?.message}")
            assert(false) { "Connection should not fail with protocol parameter error anymore" }
        }
        
        Log.d("MCPServerManagerTest", "Protocol parameter fix verified - no 'Missing protocol parameter' error!")
    }
}

/**
 * Integration test example for DeepWiki MCP server.
 * 
 * This shows how to use the fixed MCPServerManager in a real application.
 */
object DeepWikiMCPExample {
    private const val TAG = "DeepWikiMCPExample"
    
    /**
     * Example of how to connect to DeepWiki MCP server using the fixed implementation.
     */
    suspend fun connectToDeepWiki(context: Context): Result<MCPServerInfo> {
        return try {
            val mcpManager = MCPServerManager(context)
            
            // Connect to DeepWiki via HTTP
            val result = mcpManager.connectServer(
                name = "deepwiki-production",
                url = "http://localhost:8000/mcp", // Replace with actual DeepWiki URL
                transport = TransportType.HTTP
            )
            
            if (result.isSuccess) {
                val serverInfo = result.getOrNull()!!
                Log.d(TAG, "Connected to DeepWiki MCP server!")
                Log.d(TAG, "Server: ${serverInfo.serverName}")
                Log.d(TAG, "Version: ${serverInfo.serverVersion}")
                Log.d(TAG, "Tools: ${serverInfo.toolCount}")
                Log.d(TAG, "Protocol: ${serverInfo.protocolVersion}")
                
                // List available tools
                val tools = mcpManager.getTools("deepwiki-production")
                Log.d(TAG, "Available tools:")
                tools.forEach { tool ->
                    Log.d(TAG, "  - ${tool.name}: ${tool.description}")
                }
                
                Result.success(serverInfo)
            } else {
                val error = result.exceptionOrNull()
                Log.e(TAG, "Failed to connect to DeepWiki", error)
                Result.failure(error ?: Exception("Unknown error"))
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error connecting to DeepWiki", e)
            Result.failure(e)
        }
    }
    
    /**
     * Example of executing a tool on DeepWiki MCP server.
     */
    suspend fun searchWikipedia(context: Context, query: String): Result<String> {
        return try {
            val mcpManager = MCPServerManager(context)
            
            // Execute search_wikipedia tool on DeepWiki server
            val result = mcpManager.executeTool(
                serverName = "deepwiki-production",
                toolName = "search_wikipedia",
                arguments = mapOf("query" to query)
            )
            
            if (result.isSuccess) {
                val searchResults = result.getOrNull()!!
                Log.d(TAG, "Wikipedia search results for '$query':")
                Log.d(TAG, searchResults)
                Result.success(searchResults)
            } else {
                val error = result.exceptionOrNull()
                Log.e(TAG, "Failed to search Wikipedia", error)
                Result.failure(error ?: Exception("Unknown error"))
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error searching Wikipedia", e)
            Result.failure(e)
        }
    }
}
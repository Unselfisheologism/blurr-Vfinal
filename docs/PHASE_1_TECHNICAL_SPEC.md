# Phase 1: Ultra-Generalist Agent + Core Tools - Technical Specification

**Project**: Blurr Mobile AI Super-Assistant  
**Phase**: Phase 1 (MVP Launch – Next 3-5 Weeks)  
**Author**: AI Development Team  
**Date**: 2024  
**Status**: Planning  

---

## Executive Summary

Phase 1 builds on Phase 0's BYOK foundation to create the **Ultra-Generalist AI Agent** - a single 1-chat-UI interface that can orchestrate multiple tools to perform complex multi-step tasks. This includes implementing MCP (Model Context Protocol) client support, integrating essential tools (web search, multimodal generation, Google Workspace, document generation), and enabling users to save successful prompt+tool chains as reusable tools.

**Success Criteria**: Users can accomplish complex tasks (research → generate media → create documents → control phone) through natural conversation with a single AI agent.

---

## Goals & Non-Goals

### Goals
1. ✅ Implement MCP client for future-proof tool access
2. ✅ Build unified 1-chat-UI for Ultra-Generalist Agent
3. ✅ Integrate web search tools (Tavily, Exa, SerpAPI)
4. ✅ Enable multimodal generation (images, video, music, 3D)
5. ✅ Add Google Workspace integration (OAuth + API access)
6. ✅ Implement document generation (PowerPoint, PDF, infographics)
7. ✅ Connect existing phone control capabilities to agent
8. ✅ Enable "Save as Reusable Tool" for custom chains

### Non-Goals
- ❌ AI-native apps (Phase 2)
- ❌ Workflow builder visual UI (Phase 3)
- ❌ Monetization/subscriptions (Phase 4)
- ❌ n8n integration (Phase 3)

---

## Requirements

### Functional Requirements (Phase 1 Focus)

| ID | Requirement | Priority | Complexity |
|----|-------------|----------|------------|
| **FR19** | Users can chat with AI in single 1-chat-UI interface | P0 | Medium |
| **FR20** | AI can orchestrate multiple tools to complete complex tasks | P0 | High |
| **FR21** | AI can perform web search / deep research (Tavily/Exa/SerpAPI) | P0 | Low |
| **FR22** | AI can generate images (Flux, SD3) via BYOK providers | P0 | Low |
| **FR23** | AI can generate videos (Kling) via BYOK providers | P1 | Medium |
| **FR24** | AI can generate music/audio (Suno, Udio) via BYOK providers | P1 | Medium |
| **FR25** | AI can generate 3D models (Meshy, Tripo) via BYOK providers | P2 | Medium |
| **FR26** | AI can generate PowerPoint presentations | P0 | Medium |
| **FR27** | AI can generate PDF documents | P0 | Low |
| **FR28** | AI can generate infographics | P1 | Medium |
| **FR29** | Users can save successful prompt+tool chains as reusable tools | P0 | Medium |
| **FR30** | System can connect to MCP servers as a client | P0 | High |
| **FR31** | Users can authenticate with Google via OAuth | P0 | Medium |
| **FR32** | AI can read and compose Gmail messages | P1 | Medium |
| **FR33** | AI can create and read Google Calendar events | P1 | Medium |
| **FR34** | AI can read and edit Google Drive files | P1 | High |
| **FR35** | AI can read and edit Google Sheets data | P2 | High |

### Epic Mapping
- **Epic 3: Ultra-Generalist AI Agent** (FR19-30)
- **Epic 4: Google Workspace Integration** (FR31-35)

---

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Ultra-Generalist Agent                    │
│                    (1-Chat-UI Interface)                     │
└─────────────────────────────────────────────────────────────┘
                              │
                ┌─────────────┴─────────────┐
                │                           │
        ┌───────▼────────┐         ┌───────▼────────┐
        │  Tool Registry  │         │ MCP Client     │
        │  (Built-in)     │         │ (External)     │
        └───────┬────────┘         └───────┬────────┘
                │                           │
    ┌───────────┼───────────────────────────┼──────────┐
    │           │                           │          │
┌───▼───┐  ┌───▼───┐  ┌────▼────┐  ┌──────▼──────┐  │
│ Web   │  │Multi- │  │ Google  │  │   Phone     │  │
│Search │  │modal  │  │Workspace│  │   Control   │  │
│       │  │ Gen   │  │         │  │  (Existing) │  │
└───────┘  └───────┘  └─────────┘  └─────────────┘  │
                                                      │
                                              ┌───────▼────────┐
                                              │  Document Gen  │
                                              │ (PPT/PDF/Info) │
                                              └────────────────┘
```

### Component Overview

#### 1. Ultra-Generalist Agent Core
**Location**: `app/src/main/java/com/blurr/voice/agents/`

```kotlin
UltraGeneralistAgent.kt        // Main orchestrator
ToolRegistry.kt                // Built-in tool management
ToolExecutor.kt                // Tool execution engine
ConversationManager.kt         // Multi-turn context
SavedToolsManager.kt           // Custom tool persistence
```

**Responsibilities**:
- Analyze user intent
- Select appropriate tools
- Execute tool chains
- Manage conversation context
- Save/load reusable tools

#### 2. MCP Client
**Location**: `app/src/main/java/com/blurr/voice/mcp/`

```kotlin
MCPClient.kt                   // MCP protocol implementation
MCPServer.kt                   // Server connection management
MCPTool.kt                     // MCP tool wrapper
MCPTransport.kt                // Transport layer (HTTP/WebSocket/stdio)
```

**Responsibilities**:
- Connect to MCP servers
- Discover available tools
- Execute MCP tool calls
- Handle streaming responses

#### 3. Built-in Tools
**Location**: `app/src/main/java/com/blurr/voice/tools/`

```kotlin
// Web Search
TavilySearchTool.kt
ExaSearchTool.kt
SerpAPITool.kt

// Multimodal Generation
ImageGenerationTool.kt         // Flux, SD3
VideoGenerationTool.kt         // Kling
MusicGenerationTool.kt         // Suno, Udio
Model3DGenerationTool.kt       // Meshy, Tripo

// Document Generation
PowerPointTool.kt
PDFGeneratorTool.kt
InfographicTool.kt

// Google Workspace
GoogleAuthTool.kt
GmailTool.kt
GoogleCalendarTool.kt
GoogleDriveTool.kt
GoogleSheetsTool.kt

// Phone Control (Bridge to existing)
PhoneControlTool.kt            // Wraps existing ScreenInteractionService
```

#### 4. UI Components
**Location**: `app/src/main/java/com/blurr/voice/ui/agent/`

```kotlin
AgentChatActivity.kt           // Main 1-chat-UI
AgentChatViewModel.kt          // State management
ToolSelectionSheet.kt          // Tool picker bottom sheet
SavedToolsScreen.kt            // Manage custom tools
ToolExecutionView.kt           // Show tool progress
```

---

## Detailed Component Design

### 1. Ultra-Generalist Agent Core

#### UltraGeneralistAgent.kt

```kotlin
package com.blurr.voice.agents

class UltraGeneralistAgent(
    private val llmService: UniversalLLMService,
    private val toolRegistry: ToolRegistry,
    private val mcpClient: MCPClient,
    private val conversationManager: ConversationManager
) {
    
    /**
     * Main entry point for user messages
     */
    suspend fun processMessage(
        userMessage: String,
        images: List<Bitmap> = emptyList()
    ): AgentResponse {
        // 1. Add message to conversation
        conversationManager.addUserMessage(userMessage, images)
        
        // 2. Analyze intent and select tools
        val plan = analyzePlan(userMessage, images)
        
        // 3. Execute tool chain
        val results = executeToolChain(plan)
        
        // 4. Generate final response
        val response = synthesizeResponse(results)
        
        // 5. Update conversation
        conversationManager.addAssistantMessage(response)
        
        return response
    }
    
    /**
     * Analyze user intent and create execution plan
     */
    private suspend fun analyzePlan(
        message: String,
        images: List<Bitmap>
    ): ExecutionPlan {
        val systemPrompt = """
            You are an Ultra-Generalist AI Agent with access to multiple tools.
            
            Available tools:
            ${toolRegistry.describeTools()}
            ${mcpClient.describeTools()}
            
            Analyze the user's request and create a step-by-step execution plan.
            Use function calling to specify which tools to use and in what order.
        """.trimIndent()
        
        // Use function calling to get structured plan
        val options = OpenRouterRequestOptions(
            tools = buildToolList(),
            toolChoice = ToolChoice.Auto,
            responseFormat = OpenRouterConfig.ResponseFormat.JSON_OBJECT
        )
        
        val planJson = llmService.generateStructuredContent(
            conversationManager.getContext() + listOf(
                "system" to listOf(systemPrompt),
                "user" to listOf(message)
            )
        )
        
        return ExecutionPlan.fromJson(planJson)
    }
    
    /**
     * Execute tool chain sequentially
     */
    private suspend fun executeToolChain(plan: ExecutionPlan): List<ToolResult> {
        val results = mutableListOf<ToolResult>()
        
        for (step in plan.steps) {
            val tool = getTool(step.toolName)
            val result = tool.execute(step.parameters, results)
            results.add(result)
            
            // Add intermediate result to conversation for context
            conversationManager.addToolResult(step.toolName, result)
        }
        
        return results
    }
    
    /**
     * Get tool from registry or MCP
     */
    private fun getTool(toolName: String): Tool {
        return toolRegistry.getTool(toolName) 
            ?: mcpClient.getTool(toolName)
            ?: throw ToolNotFoundException(toolName)
    }
    
    /**
     * Synthesize final response from tool results
     */
    private suspend fun synthesizeResponse(results: List<ToolResult>): AgentResponse {
        val systemPrompt = """
            Synthesize the tool execution results into a clear, helpful response.
            Explain what was accomplished and show relevant results.
        """.trimIndent()
        
        val response = llmService.generateContent(
            conversationManager.getContext() + listOf(
                "system" to listOf(systemPrompt)
            )
        )
        
        return AgentResponse(
            text = response ?: "I encountered an error processing your request.",
            toolResults = results,
            plan = null
        )
    }
}

data class ExecutionPlan(
    val steps: List<ExecutionStep>,
    val reasoning: String
) {
    companion object {
        fun fromJson(json: String?): ExecutionPlan {
            // Parse JSON to ExecutionPlan
            // Handle function calls from LLM
        }
    }
}

data class ExecutionStep(
    val toolName: String,
    val parameters: Map<String, Any>,
    val description: String
)

data class AgentResponse(
    val text: String,
    val toolResults: List<ToolResult>,
    val plan: ExecutionPlan?
)
```

#### ToolRegistry.kt

```kotlin
package com.blurr.voice.agents

class ToolRegistry(
    private val context: Context
) {
    private val tools = mutableMapOf<String, Tool>()
    
    init {
        registerBuiltInTools()
    }
    
    private fun registerBuiltInTools() {
        // Web Search
        register(TavilySearchTool())
        register(ExaSearchTool())
        register(SerpAPITool())
        
        // Multimodal Generation
        register(ImageGenerationTool())
        register(VideoGenerationTool())
        register(MusicGenerationTool())
        register(Model3DGenerationTool())
        
        // Document Generation
        register(PowerPointTool())
        register(PDFGeneratorTool())
        register(InfographicTool())
        
        // Google Workspace
        register(GoogleAuthTool())
        register(GmailTool())
        register(GoogleCalendarTool())
        register(GoogleDriveTool())
        register(GoogleSheetsTool())
        
        // Phone Control
        register(PhoneControlTool())
    }
    
    fun register(tool: Tool) {
        tools[tool.name] = tool
    }
    
    fun getTool(name: String): Tool? = tools[name]
    
    fun getAllTools(): List<Tool> = tools.values.toList()
    
    fun describeTools(): String {
        return tools.values.joinToString("\n") { tool ->
            "${tool.name}: ${tool.description}"
        }
    }
}

interface Tool {
    val name: String
    val description: String
    val parameters: List<ToolParameter>
    
    suspend fun execute(
        parameters: Map<String, Any>,
        context: List<ToolResult>
    ): ToolResult
    
    fun toFunctionTool(): FunctionTool {
        return FunctionTool(
            name = name,
            description = description,
            parameters = mapOf(
                "type" to "object",
                "properties" to parameters.associate { param ->
                    param.name to mapOf(
                        "type" to param.type,
                        "description" to param.description
                    )
                },
                "required" to parameters.filter { it.required }.map { it.name }
            )
        )
    }
}

data class ToolParameter(
    val name: String,
    val type: String,
    val description: String,
    val required: Boolean = true
)

data class ToolResult(
    val toolName: String,
    val success: Boolean,
    val data: Any?,
    val error: String? = null,
    val metadata: Map<String, Any> = emptyMap()
)
```

### 2. MCP Client Implementation

#### MCPClient.kt

```kotlin
package com.blurr.voice.mcp

class MCPClient(
    private val context: Context
) {
    private val servers = mutableMapOf<String, MCPServer>()
    private val tools = mutableMapOf<String, MCPTool>()
    
    /**
     * Connect to an MCP server
     */
    suspend fun connect(
        name: String,
        transport: MCPTransport
    ): Result<Unit> {
        return withContext(Dispatchers.IO) {
            try {
                val server = MCPServer(name, transport)
                server.initialize()
                
                // Discover tools
                val discoveredTools = server.listTools()
                discoveredTools.forEach { tool ->
                    tools["${name}:${tool.name}"] = tool
                }
                
                servers[name] = server
                Result.success(Unit)
            } catch (e: Exception) {
                Result.failure(e)
            }
        }
    }
    
    /**
     * Get tool from MCP server
     */
    fun getTool(name: String): Tool? {
        val mcpTool = tools[name] ?: return null
        return MCPToolAdapter(mcpTool)
    }
    
    /**
     * Describe available MCP tools
     */
    fun describeTools(): String {
        return tools.values.joinToString("\n") { tool ->
            "${tool.name}: ${tool.description}"
        }
    }
    
    /**
     * Disconnect from server
     */
    suspend fun disconnect(name: String) {
        servers[name]?.close()
        servers.remove(name)
        tools.keys.removeAll { it.startsWith("$name:") }
    }
}

/**
 * MCP Server connection
 */
class MCPServer(
    val name: String,
    private val transport: MCPTransport
) {
    suspend fun initialize() {
        transport.connect()
        // Send initialize request
        val response = transport.sendRequest(
            method = "initialize",
            params = mapOf(
                "protocolVersion" to "2024-11-05",
                "capabilities" to mapOf(
                    "tools" to emptyMap<String, Any>()
                ),
                "clientInfo" to mapOf(
                    "name" to "Blurr AI Assistant",
                    "version" to "1.0.0"
                )
            )
        )
    }
    
    suspend fun listTools(): List<MCPTool> {
        val response = transport.sendRequest(
            method = "tools/list",
            params = emptyMap()
        )
        
        return response.getJSONArray("tools").let { array ->
            (0 until array.length()).map { i ->
                MCPTool.fromJson(array.getJSONObject(i))
            }
        }
    }
    
    suspend fun callTool(
        toolName: String,
        arguments: Map<String, Any>
    ): JSONObject {
        return transport.sendRequest(
            method = "tools/call",
            params = mapOf(
                "name" to toolName,
                "arguments" to arguments
            )
        )
    }
    
    fun close() {
        transport.close()
    }
}

/**
 * MCP tool representation
 */
data class MCPTool(
    val name: String,
    val description: String,
    val inputSchema: Map<String, Any>
) {
    companion object {
        fun fromJson(json: JSONObject): MCPTool {
            return MCPTool(
                name = json.getString("name"),
                description = json.optString("description", ""),
                inputSchema = json.getJSONObject("inputSchema").toMap()
            )
        }
    }
}

/**
 * Transport layer for MCP
 */
interface MCPTransport {
    suspend fun connect()
    suspend fun sendRequest(method: String, params: Map<String, Any>): JSONObject
    fun close()
}

/**
 * HTTP transport for MCP servers
 */
class HttpMCPTransport(
    private val url: String,
    private val apiKey: String? = null
) : MCPTransport {
    private val client = OkHttpClient()
    
    override suspend fun connect() {
        // HTTP doesn't need explicit connection
    }
    
    override suspend fun sendRequest(method: String, params: Map<String, Any>): JSONObject {
        val request = JSONObject().apply {
            put("jsonrpc", "2.0")
            put("id", System.currentTimeMillis())
            put("method", method)
            put("params", JSONObject(params))
        }
        
        val httpRequest = Request.Builder()
            .url(url)
            .post(request.toString().toRequestBody("application/json".toMediaType()))
            .apply {
                apiKey?.let { addHeader("Authorization", "Bearer $it") }
            }
            .build()
        
        val response = client.newCall(httpRequest).execute()
        val responseBody = response.body?.string() ?: throw IOException("Empty response")
        
        val jsonResponse = JSONObject(responseBody)
        if (jsonResponse.has("error")) {
            throw MCPException(jsonResponse.getJSONObject("error").toString())
        }
        
        return jsonResponse.getJSONObject("result")
    }
    
    override fun close() {
        // HTTP client cleanup
    }
}

class MCPException(message: String) : Exception(message)
```

---

## Implementation Plan

### Week 1: Foundation & MCP Client
**Days 1-2**: MCP Client Core
- [ ] Implement MCPClient, MCPServer, MCPTransport
- [ ] Add HTTP transport layer
- [ ] Unit tests for MCP protocol

**Days 3-5**: Ultra-Generalist Agent Core
- [ ] Implement UltraGeneralistAgent
- [ ] Implement ToolRegistry
- [ ] Implement ConversationManager
- [ ] Integration with existing LLM service

### Week 2: Built-in Tools (Part 1)
**Days 1-2**: Web Search Tools
- [ ] Tavily integration (user API key)
- [ ] Exa integration (user API key)
- [ ] SerpAPI integration (user API key)
- [ ] Unified search interface

**Days 3-4**: Multimodal Generation
- [ ] Image generation (Flux/SD3 via OpenRouter/AIMLAPI)
- [ ] Video generation (Kling via OpenRouter/AIMLAPI)
- [ ] Music generation (Suno/Udio routing)

**Day 5**: Document Generation (Basic)
- [ ] PDF generation (Android PDF library)
- [ ] Basic PowerPoint generation (Apache POI Android)

### Week 3: Built-in Tools (Part 2) & UI
**Days 1-2**: Google Workspace Integration
- [ ] OAuth 2.0 flow
- [ ] Gmail API integration
- [ ] Google Calendar API integration
- [ ] Google Drive API (basic)

**Days 3-4**: Phone Control Bridge
- [ ] PhoneControlTool wrapping existing ScreenInteractionService
- [ ] Tool parameter mapping
- [ ] Integration testing

**Day 5**: Saved Tools Feature
- [ ] SavedToolsManager implementation
- [ ] Local storage with Room
- [ ] Import/export functionality

### Week 4: UI & Polish
**Days 1-3**: 1-Chat-UI Implementation
- [ ] AgentChatActivity with Jetpack Compose
- [ ] Tool execution progress UI
- [ ] Tool result display
- [ ] Image/file previews

**Days 4-5**: Testing & Bug Fixes
- [ ] End-to-end testing
- [ ] Performance optimization
- [ ] Error handling improvements
- [ ] Documentation

---

## API & Integration Requirements

### 1. Web Search APIs (User-provided keys)

#### Tavily API
```kotlin
// User provides key in settings
POST https://api.tavily.com/search
{
  "api_key": "tvly-...",
  "query": "search query",
  "search_depth": "advanced"
}
```

#### Exa API
```kotlin
POST https://api.exa.ai/search
Authorization: Bearer ${user_api_key}
{
  "query": "search query",
  "num_results": 10
}
```

#### SerpAPI
```kotlin
GET https://serpapi.com/search
?q=search+query
&api_key=${user_api_key}
```

### 2. Multimodal Generation (via BYOK providers)

All multimodal generation uses existing OpenRouter/AIMLAPI integration:
- Images: `flux-1.1-pro`, `stable-diffusion-3-large`
- Video: `kling-v1`, `runway-gen3`
- Music: Route to Suno/Udio via provider endpoints

### 3. Google Workspace APIs

#### OAuth 2.0 Setup
```kotlin
// Scopes needed
val scopes = listOf(
    "https://www.googleapis.com/auth/gmail.readonly",
    "https://www.googleapis.com/auth/gmail.compose",
    "https://www.googleapis.com/auth/calendar",
    "https://www.googleapis.com/auth/drive.file"
)
```

#### Gmail API Example
```kotlin
GET https://gmail.googleapis.com/gmail/v1/users/me/messages
Authorization: Bearer ${oauth_token}
```

### 4. Document Generation Libraries

- **PDF**: PDFDocument (Android SDK)
- **PowerPoint**: Apache POI Android port
- **Infographics**: Canvas drawing + templates

---

## Data Models

### Conversation Context
```kotlin
data class Conversation(
    val id: String,
    val title: String,
    val messages: List<Message>,
    val toolResults: List<ToolResult>,
    val createdAt: Long,
    val updatedAt: Long
)

data class Message(
    val role: String,  // "user", "assistant", "tool"
    val content: String,
    val images: List<String> = emptyList(),
    val timestamp: Long
)
```

### Saved Tool
```kotlin
data class SavedTool(
    val id: String,
    val name: String,
    val description: String,
    val toolChain: List<ToolStep>,
    val systemPrompt: String,
    val createdAt: Long
)

data class ToolStep(
    val toolName: String,
    val parameters: Map<String, Any>
)
```

### MCP Server Configuration
```kotlin
data class MCPServerConfig(
    val name: String,
    val transportType: String,  // "http", "ws", "stdio"
    val url: String,
    val apiKey: String? = null,
    val enabled: Boolean = true
)
```

---

## UI/UX Specifications

### 1-Chat-UI Layout
```
┌─────────────────────────────────────┐
│  ☰  Ultra-Generalist Agent      ⚙️  │
├─────────────────────────────────────┤
│                                     │
│  [User]: Research quantum computing │
│         and create a presentation   │
│                                     │
│  [Agent]: I'll help with that!      │
│          Let me:                    │
│          1. Search for info         │
│          2. Generate slides         │
│                                     │
│  🔍 Searching with Tavily...        │
│  [Progress: 40%]                    │
│                                     │
│  📊 Creating PowerPoint...          │
│  [Progress: 70%]                    │
│                                     │
│  ✅ Done! I've created a 10-slide  │
│     presentation on quantum         │
│     computing. [Download]           │
│                                     │
├─────────────────────────────────────┤
│  [Type message...]           🎤 📎  │
└─────────────────────────────────────┘
```

### Tool Selection Bottom Sheet
```
┌─────────────────────────────────────┐
│  Available Tools                 ✕  │
├─────────────────────────────────────┤
│  🔍 Web Search                      │
│  🖼️  Generate Image                 │
│  🎬 Generate Video                  │
│  🎵 Generate Music                  │
│  📧 Gmail                           │
│  📅 Calendar                        │
│  📱 Phone Control                   │
│  📄 Create PDF                      │
│  📊 Create PowerPoint               │
│  ➕ Add MCP Server                  │
└─────────────────────────────────────┘
```

---

## Testing Strategy

### Unit Tests
- [ ] MCPClient protocol handling
- [ ] Tool execution logic
- [ ] Conversation context management
- [ ] Tool registry operations

### Integration Tests
- [ ] End-to-end tool chains
- [ ] MCP server communication
- [ ] Google OAuth flow
- [ ] Multimodal generation

### Manual Testing
- [ ] Complex multi-step tasks
- [ ] Error recovery scenarios
- [ ] UI responsiveness
- [ ] Tool result display

---

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|----------|
| MCP protocol complexity | High | Start with HTTP transport only |
| Tool orchestration failures | High | Implement robust error handling + retry |
| Google OAuth complexity | Medium | Use Google Sign-In library |
| Multimodal generation costs | Medium | Clear cost warnings to users |
| Performance with many tools | Medium | Lazy loading + caching |

---

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Tool execution success rate | >90% | Analytics tracking |
| Average task completion time | <30 seconds | User timing |
| User satisfaction (1-chat-UI) | >4.5/5 | In-app feedback |
| MCP server connectivity | >95% | Connection logs |
| Multi-step task success | >85% | Task completion rate |

---

## Next Steps

1. Review and approve this technical spec
2. Set up Phase 1 project tracking
3. Begin Week 1 implementation (MCP Client + Agent Core)
4. Daily standups to track progress
5. Weekly demos of completed features

---

**Status**: Ready for Implementation  
**Estimated Duration**: 4 weeks  
**Dependencies**: Phase 0 complete (BYOK foundation)  
**Success Criteria**: Users can accomplish multi-step tasks through natural conversation

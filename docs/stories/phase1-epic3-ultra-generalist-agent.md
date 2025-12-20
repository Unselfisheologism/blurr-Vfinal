# Epic 3: Ultra-Generalist AI Agent

**Epic ID**: EPIC-3  
**Priority**: P0 - Critical  
**Status**: Ready for Development  
**Estimated Duration**: 4 weeks  

---

## Epic Overview

Build the Ultra-Generalist AI Agent that can orchestrate multiple tools through natural conversation to complete complex multi-step tasks. This includes implementing MCP client support, tool registry, execution engine, and the unified 1-chat-UI interface.

---

## Stories

### Story 3.1: MCP Client Foundation
**Story ID**: STORY-3.1  
**Priority**: P0  
**Estimate**: 3 days  
**Dependencies**: None  

#### Description
Implement the Model Context Protocol (MCP) client to connect to external MCP servers and discover/execute their tools.

#### Acceptance Criteria
- [ ] MCPClient can connect to MCP servers via HTTP transport
- [ ] MCPClient can send initialize request and receive server capabilities
- [ ] MCPClient can list available tools from connected server
- [ ] MCPClient can call tools and receive results
- [ ] MCPTransport interface supports HTTP with Bearer auth
- [ ] Error handling for connection failures and timeouts
- [ ] MCPServer configuration can be saved/loaded from preferences

#### Technical Details
**Files to Create**:
- `app/src/main/java/com/twent/voice/mcp/MCPClient.kt`
- `app/src/main/java/com/twent/voice/mcp/MCPServer.kt`
- `app/src/main/java/com/twent/voice/mcp/MCPTransport.kt`
- `app/src/main/java/com/twent/voice/mcp/MCPTool.kt`
- `app/src/main/java/com/twent/voice/mcp/HttpMCPTransport.kt`

**Key Classes**:
```kotlin
class MCPClient(context: Context)
class MCPServer(name: String, transport: MCPTransport)
interface MCPTransport
class HttpMCPTransport(url: String, apiKey: String?)
data class MCPTool(name: String, description: String, inputSchema: Map)
```

#### Testing
- [ ] Connect to public MCP server (if available)
- [ ] List tools from server
- [ ] Execute a simple tool call
- [ ] Handle connection errors gracefully

---

### Story 3.2: Tool Registry and Interface
**Story ID**: STORY-3.2  
**Priority**: P0  
**Estimate**: 2 days  
**Dependencies**: None  

#### Description
Create the tool registry system and common Tool interface that all built-in tools will implement.

#### Acceptance Criteria
- [ ] Tool interface defined with execute() method
- [ ] ToolRegistry can register and retrieve tools by name
- [ ] ToolRegistry can describe all available tools
- [ ] Tool interface converts to FunctionTool for LLM function calling
- [ ] ToolResult data class captures execution results
- [ ] ToolParameter data class defines tool parameters

#### Technical Details
**Files to Create**:
- `app/src/main/java/com/twent/voice/tools/Tool.kt`
- `app/src/main/java/com/twent/voice/tools/ToolRegistry.kt`
- `app/src/main/java/com/twent/voice/tools/ToolResult.kt`
- `app/src/main/java/com/twent/voice/tools/ToolParameter.kt`

**Key Interfaces**:
```kotlin
interface Tool {
    val name: String
    val description: String
    val parameters: List<ToolParameter>
    suspend fun execute(params: Map<String, Any>, context: List<ToolResult>): ToolResult
    fun toFunctionTool(): FunctionTool
}
```

#### Testing
- [ ] Register a mock tool
- [ ] Retrieve tool by name
- [ ] Convert tool to FunctionTool format
- [ ] Execute tool with parameters

---

### Story 3.3: Conversation Manager
**Story ID**: STORY-3.3  
**Priority**: P0  
**Estimate**: 2 days  
**Dependencies**: Story 3.2  

#### Description
Implement conversation context management to maintain multi-turn conversation history including user messages, assistant responses, and tool execution results.

#### Acceptance Criteria
- [ ] ConversationManager stores conversation history
- [ ] Can add user messages with images
- [ ] Can add assistant responses
- [ ] Can add tool execution results
- [ ] Can retrieve conversation context for LLM
- [ ] Conversation persists to local storage (Room)
- [ ] Can load previous conversations
- [ ] Can clear/reset conversation

#### Technical Details
**Files to Create**:
- `app/src/main/java/com/twent/voice/agents/ConversationManager.kt`
- `app/src/main/java/com/twent/voice/data/models/Conversation.kt`
- `app/src/main/java/com/twent/voice/data/models/Message.kt`
- `app/src/main/java/com/twent/voice/data/dao/ConversationDao.kt`

**Data Models**:
```kotlin
@Entity
data class Conversation(
    @PrimaryKey val id: String,
    val title: String,
    val createdAt: Long,
    val updatedAt: Long
)

@Entity
data class Message(
    @PrimaryKey val id: String,
    val conversationId: String,
    val role: String,
    val content: String,
    val timestamp: Long
)
```

#### Testing
- [ ] Create new conversation
- [ ] Add messages to conversation
- [ ] Retrieve conversation context
- [ ] Load conversation from database
- [ ] Clear conversation history

---

### Story 3.4: Ultra-Generalist Agent Core
**Story ID**: STORY-3.4  
**Priority**: P0  
**Estimate**: 3 days  
**Dependencies**: Story 3.2, Story 3.3  

#### Description
Implement the core UltraGeneralistAgent that analyzes user intent, creates execution plans, orchestrates tool execution, and synthesizes responses.

#### Acceptance Criteria
- [ ] Agent can analyze user intent and create execution plan
- [ ] Agent uses function calling to get structured tool selection
- [ ] Agent executes tool chain sequentially
- [ ] Agent passes tool results as context to subsequent tools
- [ ] Agent synthesizes final response from tool results
- [ ] Agent handles tool execution errors gracefully
- [ ] Agent can retry failed tools with adjusted parameters

#### Technical Details
**Files to Create**:
- `app/src/main/java/com/twent/voice/agents/UltraGeneralistAgent.kt`
- `app/src/main/java/com/twent/voice/agents/ExecutionPlan.kt`
- `app/src/main/java/com/twent/voice/agents/ToolExecutor.kt`

**Key Methods**:
```kotlin
class UltraGeneralistAgent {
    suspend fun processMessage(message: String, images: List<Bitmap>): AgentResponse
    private suspend fun analyzePlan(message: String): ExecutionPlan
    private suspend fun executeToolChain(plan: ExecutionPlan): List<ToolResult>
    private suspend fun synthesizeResponse(results: List<ToolResult>): AgentResponse
}
```

#### Testing
- [ ] Simple single-tool request (e.g., "search for X")
- [ ] Multi-tool request (e.g., "search for X and create PDF")
- [ ] Handle tool execution failure
- [ ] Context passing between tools
- [ ] Response synthesis with multiple results

---

### Story 3.5: MCP Tool Adapter
**Story ID**: STORY-3.5  
**Priority**: P0  
**Estimate**: 1 day  
**Dependencies**: Story 3.1, Story 3.2  

#### Description
Create adapter to wrap MCP tools as regular Tool interface so they can be used seamlessly by the agent alongside built-in tools.

#### Acceptance Criteria
- [ ] MCPToolAdapter implements Tool interface
- [ ] Adapter translates Tool.execute() to MCP tool call
- [ ] Adapter converts MCP tool schema to ToolParameter list
- [ ] Adapter handles MCP-specific errors
- [ ] MCPClient.getTool() returns wrapped MCP tool

#### Technical Details
**Files to Create**:
- `app/src/main/java/com/twent/voice/mcp/MCPToolAdapter.kt`

**Key Class**:
```kotlin
class MCPToolAdapter(
    private val mcpTool: MCPTool,
    private val server: MCPServer
) : Tool {
    override suspend fun execute(params: Map<String, Any>, context: List<ToolResult>): ToolResult {
        val result = server.callTool(mcpTool.name, params)
        return ToolResult(/* ... */)
    }
}
```

#### Testing
- [ ] Wrap MCP tool and execute via Tool interface
- [ ] Parameter translation works correctly
- [ ] Error handling for MCP failures
- [ ] Tool description generation

---

### Story 3.6: Saved Tools Manager
**Story ID**: STORY-3.6  
**Priority**: P0  
**Estimate**: 2 days  
**Dependencies**: Story 3.2, Story 3.4  

#### Description
Implement the ability to save successful prompt+tool chains as reusable custom tools that can be invoked by name.

#### Acceptance Criteria
- [ ] Can save current conversation as custom tool
- [ ] Custom tool has name, description, and tool chain
- [ ] SavedToolsManager persists custom tools to database
- [ ] Can load and execute saved tools
- [ ] Can edit/delete saved tools
- [ ] Custom tools appear in tool registry
- [ ] Can export/import saved tools as JSON

#### Technical Details
**Files to Create**:
- `app/src/main/java/com/twent/voice/agents/SavedToolsManager.kt`
- `app/src/main/java/com/twent/voice/data/models/SavedTool.kt`
- `app/src/main/java/com/twent/voice/data/dao/SavedToolDao.kt`
- `app/src/main/java/com/twent/voice/tools/SavedToolWrapper.kt`

**Data Model**:
```kotlin
@Entity
data class SavedTool(
    @PrimaryKey val id: String,
    val name: String,
    val description: String,
    val toolChainJson: String,
    val systemPrompt: String,
    val createdAt: Long
)
```

#### Testing
- [ ] Save current tool chain as custom tool
- [ ] Load and execute saved tool
- [ ] Edit saved tool details
- [ ] Delete saved tool
- [ ] Export/import saved tool

---

### Story 3.7: Agent Chat UI (1-Chat-UI)
**Story ID**: STORY-3.7  
**Priority**: P0  
**Estimate**: 3 days  
**Dependencies**: Story 3.4  

#### Description
Build the unified 1-chat-UI interface using Jetpack Compose for natural conversation with the Ultra-Generalist Agent, showing tool execution progress and results.

#### Acceptance Criteria
- [ ] Chat interface shows user messages and agent responses
- [ ] Shows tool execution progress with loading indicators
- [ ] Displays tool results (text, images, files) inline
- [ ] User can send text messages and images
- [ ] User can see execution plan before tools run
- [ ] User can cancel long-running tool executions
- [ ] Chat history persists across app restarts
- [ ] Smooth animations for tool execution

#### Technical Details
**Files to Create**:
- `app/src/main/java/com/twent/voice/ui/agent/AgentChatActivity.kt`
- `app/src/main/java/com/twent/voice/ui/agent/AgentChatViewModel.kt`
- `app/src/main/java/com/twent/voice/ui/agent/AgentChatScreen.kt` (Compose)
- `app/src/main/java/com/twent/voice/ui/agent/MessageItem.kt` (Compose)
- `app/src/main/java/com/twent/voice/ui/agent/ToolExecutionView.kt` (Compose)

**UI Components**:
- Message list (LazyColumn)
- Tool execution cards
- Input field with image attachment
- Progress indicators

#### Testing
- [ ] Send text message and receive response
- [ ] Send message with image attachment
- [ ] View tool execution progress
- [ ] Click on tool results (download, share, etc.)
- [ ] Scroll through long conversation
- [ ] App rotation preserves state

---

### Story 3.8: Tool Selection UI
**Story ID**: STORY-3.8  
**Priority**: P1  
**Estimate**: 1 day  
**Dependencies**: Story 3.2, Story 3.7  

#### Description
Create a bottom sheet UI for users to manually select and configure tools before execution.

#### Acceptance Criteria
- [ ] Bottom sheet shows all available tools
- [ ] Tools grouped by category (Search, Generate, Workspace, etc.)
- [ ] Can search/filter tools
- [ ] Shows tool descriptions and parameters
- [ ] Can manually trigger tool execution
- [ ] Shows MCP servers and their tools separately

#### Technical Details
**Files to Create**:
- `app/src/main/java/com/twent/voice/ui/agent/ToolSelectionSheet.kt` (Compose)
- `app/src/main/java/com/twent/voice/ui/agent/ToolCategoryView.kt` (Compose)

#### Testing
- [ ] Open tool selection bottom sheet
- [ ] Search for specific tool
- [ ] View tool details
- [ ] Select tool and configure parameters

---

### Story 3.9: Saved Tools UI
**Story ID**: STORY-3.9  
**Priority**: P1  
**Estimate**: 1 day  
**Dependencies**: Story 3.6, Story 3.7  

#### Description
Build UI for managing saved custom tools (view, edit, delete, export/import).

#### Acceptance Criteria
- [ ] Screen shows list of saved tools
- [ ] Can view tool details (name, description, chain)
- [ ] Can edit tool name and description
- [ ] Can delete saved tools
- [ ] Can export tool as JSON file
- [ ] Can import tool from JSON file
- [ ] "Save as Tool" button in chat after successful execution

#### Technical Details
**Files to Create**:
- `app/src/main/java/com/twent/voice/ui/agent/SavedToolsScreen.kt` (Compose)
- `app/src/main/java/com/twent/voice/ui/agent/SavedToolDetailsSheet.kt` (Compose)

#### Testing
- [ ] View list of saved tools
- [ ] Edit tool details
- [ ] Delete tool
- [ ] Export tool to file
- [ ] Import tool from file

---

## Epic Acceptance Criteria

✅ **Core Functionality**:
- [ ] User can have natural conversation with agent
- [ ] Agent can execute multiple tools in sequence
- [ ] Agent maintains conversation context
- [ ] MCP servers can be connected and used

✅ **User Experience**:
- [ ] 1-chat-UI is intuitive and responsive
- [ ] Tool execution progress is visible
- [ ] Tool results are clearly displayed
- [ ] Errors are handled gracefully with clear messages

✅ **Saved Tools**:
- [ ] User can save successful tool chains
- [ ] Saved tools can be reused by name
- [ ] Saved tools can be shared via export

---

## Definition of Done

- [ ] All stories completed and tested
- [ ] Code reviewed and merged
- [ ] Manual testing completed on physical device
- [ ] Documentation updated
- [ ] Demo prepared for stakeholders

---

**Total Estimate**: 18 developer-days (~3.5 weeks with buffer)

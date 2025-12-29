# AIMLAPI Advanced Features Guide

## Overview

The Blurr AI Assistant now includes complete support for all AIMLAPI advanced features, making it a fully-featured agentic AI platform with:

- ✅ **Function Calling** - Native tool/function integration for agentic workflows
- ✅ **Web Search** - Built-in web search capability for current information
- ✅ **Thinking/Reasoning** - Access model's reasoning process (O1-style models)
- ✅ **Advanced Sampling** - Complete parameter control (logprobs, logit_bias, etc.)
- ✅ **Streaming Responses** - Real-time token-by-token output
- ✅ **Vision Support** - Multimodal image understanding
- ✅ **STT/TTS** - Speech-to-text and text-to-speech APIs

## Quick Start

### Default Behavior (Agentic Optimizations)

By default, when using OpenRouter, agentic optimizations are enabled. For AIMLAPI, you get clean OpenAI-compatible API:

```kotlin
// Basic chat completion
val response = universalLLMService.generateContent(chat, images)
```

## Feature Details

### 1. Function Calling (Tool Use)

Enable the model to call external functions/tools for complex tasks.

#### Define a Function Tool

```kotlin
val weatherTool = FunctionTool(
    name = "get_current_weather",
    description = "Get the current weather in a given location",
    parameters = mapOf(
        "type" to "object",
        "properties" to mapOf(
            "location" to mapOf(
                "type" to "string",
                "description" to "The city and state, e.g. San Francisco, CA"
            ),
            "unit" to mapOf(
                "type" to "string",
                "enum" to listOf("celsius", "fahrenheit")
            )
        ),
        "required" to listOf("location")
    )
)
```

#### Use Function Calling

```kotlin
val options = OpenRouterRequestOptions(
    tools = listOf(weatherTool),
    toolChoice = ToolChoice.Auto  // Let model decide when to use tools
)

val api = OpenAICompatibleAPI(provider, apiKey, model)
val response = api.generateChatCompletion(messages, options = options)

// Response will indicate function calls if needed:
// [Function Calls Requested]
// 
// get_current_weather:
//   {"location": "San Francisco, CA", "unit": "celsius"}
```

#### Convenience Method

```kotlin
api.generateWithTools(
    messages,
    tools = listOf(weatherTool),
    toolChoice = ToolChoice.Auto
)
```

---

### 2. Web Search Integration

Enable models to search the web for current information (AIMLAPI-specific).

#### Basic Usage

```kotlin
val options = OpenRouterRequestOptions(
    enableWebSearch = true
)

val response = api.generateChatCompletion(messages, options = options)
```

#### Convenience Method

```kotlin
api.generateWithWebSearch(
    messages = listOf(
        "user" to "What are the latest developments in AI this week?"
    )
)
```

#### Built-in Tool Format

```kotlin
// Alternatively, use built-in tools directly
val options = OpenRouterRequestOptions(
    builtInTools = listOf(BuiltInFunctionTool.WEB_SEARCH),
    toolChoice = ToolChoice.Auto
)
```

---

### 3. Thinking/Reasoning Mode

Access the model's internal reasoning process (for O1-style models).

#### Enable Thinking

```kotlin
val options = OpenRouterRequestOptions(
    enableThinking = true
)

val response = api.generateChatCompletion(messages, options = options)
// Reasoning is logged but not included in response
// Check logs for: "Model reasoning: ..."
```

#### Convenience Method

```kotlin
api.generateWithThinking(
    messages = listOf(
        "user" to "Solve this complex math problem: ..."
    )
)
```

#### Response Format

The model's reasoning is available in logs:
```
D/OpenAICompatibleAPI: Model reasoning: Let me think about this step by step...
D/OpenAICompatibleAPI: Token usage - Prompt: 20, Completion: 150 (Reasoning: 100), Total: 170
```

---

### 4. Advanced Sampling Parameters

#### Log Probabilities

Useful for debugging and understanding model confidence:

```kotlin
val options = OpenRouterRequestOptions(
    logprobs = true,
    topLogprobs = 5  // Return top 5 most likely tokens
)
```

#### Logit Bias

Increase or decrease likelihood of specific tokens:

```kotlin
val options = OpenRouterRequestOptions(
    logitBias = mapOf(
        1234 to 1.5,   // Increase likelihood of token 1234
        5678 to -1.0   // Decrease likelihood of token 5678
    )
)
```

#### Multiple Completions

Generate multiple responses in one request:

```kotlin
val options = OpenRouterRequestOptions(
    n = 3,  // Generate 3 different completions
    temperature = 0.9
)
```

---

### 5. Tool Choice Strategies

Control how the model chooses to use tools.

#### Auto (Default)

```kotlin
toolChoice = ToolChoice.Auto  // Model decides when to use tools
```

#### None

```kotlin
toolChoice = ToolChoice.None  // Never use tools, always respond directly
```

#### Force Specific Function

```kotlin
toolChoice = ToolChoice.Function("get_current_weather")  // Must use this function
```

---

### 6. Streaming with Advanced Features

All advanced features work with streaming:

```kotlin
val options = OpenRouterRequestOptions(
    tools = listOf(weatherTool),
    toolChoice = ToolChoice.Auto,
    enableThinking = true
)

val stream = api.generateStreamingChatCompletion(messages, options = options)
stream.collect { chunk ->
    println(chunk)
}
```

---

## Complete Usage Examples

### Example 1: Agentic AI with Tools

```kotlin
// Define tools
val tools = listOf(
    FunctionTool(
        name = "search_database",
        description = "Search the user database",
        parameters = mapOf(
            "type" to "object",
            "properties" to mapOf(
                "query" to mapOf("type" to "string")
            )
        )
    ),
    FunctionTool(
        name = "send_email",
        description = "Send an email to a user",
        parameters = mapOf(
            "type" to "object",
            "properties" to mapOf(
                "to" to mapOf("type" to "string"),
                "subject" to mapOf("type" to "string"),
                "body" to mapOf("type" to "string")
            )
        )
    )
)

// Use tools
val response = api.generateWithTools(
    messages = listOf(
        "user" to "Find john@example.com and send him a welcome email"
    ),
    tools = tools
)
```

### Example 2: Web-Enhanced Research

```kotlin
val response = api.generateWithWebSearch(
    messages = listOf(
        "user" to "What are the latest AI model releases from this month?"
    )
)
```

### Example 3: Thinking Mode for Complex Problems

```kotlin
val response = api.generateWithThinking(
    messages = listOf(
        "user" to """
            Analyze this code for potential security vulnerabilities:
            
            ```python
            def login(username, password):
                query = f"SELECT * FROM users WHERE username='{username}' AND password='{password}'"
                return db.execute(query)
            ```
        """.trimIndent()
    )
)
```

### Example 4: Combined Features

```kotlin
val options = OpenRouterRequestOptions(
    tools = listOf(webSearchTool, calculatorTool),
    toolChoice = ToolChoice.Auto,
    enableThinking = true,
    topP = 0.9,
    frequencyPenalty = 0.3,
    logprobs = true,
    topLogprobs = 3
)

val response = api.generateChatCompletion(
    messages = listOf(
        "user" to "Research the latest quantum computing advances and calculate ROI"
    ),
    options = options
)
```

### Example 5: Multi-Turn Tool Interaction

```kotlin
// Turn 1: Model requests tool use
val response1 = api.generateWithTools(messages, tools)
// Response: [Function Calls Requested]
//          get_weather: {"location": "SF"}

// Turn 2: Provide tool result
val messagesWithToolResult = messages + listOf(
    "assistant" to response1!!,
    "tool" to """{"temperature": 68, "condition": "sunny"}""",
    "user" to "Based on that, should I bring a jacket?"
)

val response2 = api.generateChatCompletion(messagesWithToolResult)
```

---

## API Reference

### FunctionTool

```kotlin
data class FunctionTool(
    val name: String,                    // Function name
    val description: String,              // What the function does
    val parameters: Map<String, Any>      // JSON Schema for parameters
)
```

### BuiltInFunctionTool

```kotlin
data class BuiltInFunctionTool(
    val name: String  // e.g., "$web_search"
)

companion object {
    val WEB_SEARCH = BuiltInFunctionTool("\$web_search")
}
```

### ToolChoice

```kotlin
sealed class ToolChoice {
    object Auto                           // Let model decide
    object None                           // Never use tools
    data class Function(val name: String) // Force specific function
}
```

### OpenRouterRequestOptions (AIMLAPI-specific fields)

```kotlin
data class OpenRouterRequestOptions(
    // Function calling
    val tools: List<FunctionTool>? = null,
    val builtInTools: List<BuiltInFunctionTool>? = null,
    val toolChoice: ToolChoice? = null,
    
    // AIMLAPI-specific
    val enableThinking: Boolean? = null,
    val enableWebSearch: Boolean = false,
    
    // Advanced debugging
    val logprobs: Boolean? = null,
    val topLogprobs: Int? = null,          // 0-20
    val logitBias: Map<Int, Double>? = null,
    val n: Int? = null,                    // Number of completions
    
    // ... all other parameters
)
```

---

## Response Formats

### Normal Response

```kotlin
"The weather in San Francisco is sunny and 68°F."
```

### Tool Call Response

```kotlin
"""
[Function Calls Requested]

get_current_weather:
  {"location": "San Francisco, CA", "unit": "fahrenheit"}
"""
```

### With Reasoning (in logs)

```
D/OpenAICompatibleAPI: Model reasoning: First, I need to understand what the user is asking...
D/OpenAICompatibleAPI: Token usage - Prompt: 50, Completion: 200 (Reasoning: 150), Total: 250
```

---

## Best Practices

### For Agentic AI Applications

1. ✅ Use function calling for tool integration
2. ✅ Enable web search for current information
3. ✅ Use thinking mode for complex reasoning tasks
4. ✅ Set `toolChoice = ToolChoice.Auto` for flexibility
5. ✅ Implement multi-turn conversations for tool interactions

### For Function Calling

1. ✅ Provide clear, descriptive function names
2. ✅ Write detailed descriptions
3. ✅ Use proper JSON Schema for parameters
4. ✅ Handle tool call responses in multi-turn conversations
5. ✅ Validate function arguments before execution

### For Production Apps

1. ✅ Enable logging to track tool usage
2. ✅ Monitor reasoning tokens for cost
3. ✅ Implement error handling for tool execution
4. ✅ Use streaming for better UX
5. ✅ Test with various tool choice strategies

---

## Performance & Cost Impact

### Function Calling
- **Request overhead**: +100-500 bytes (depends on tool definitions)
- **No additional tokens**: Tool definitions don't count as prompt tokens
- **Benefits**: Structured, reliable tool use

### Web Search
- **Processing time**: +2-5 seconds (web search latency)
- **Token usage**: Search results consume prompt tokens
- **Benefits**: Access to current information

### Thinking Mode
- **Token usage**: +50-500% additional reasoning tokens
- **Cost impact**: Higher but includes detailed reasoning
- **Benefits**: Transparent reasoning process, better quality

### Log Probabilities
- **Response size**: +50-200% (depends on top_logprobs)
- **No token cost**: Doesn't increase generation tokens
- **Benefits**: Model confidence insights

---

## Comparison: OpenRouter vs AIMLAPI Features

| Feature | OpenRouter | AIMLAPI | Implementation |
|---------|-----------|---------|----------------|
| Provider Routing | ✅ | ❌ | OpenRouter only |
| Prompt Transforms | ✅ | ❌ | OpenRouter only |
| Function Calling | ✅ | ✅ | Both support |
| Thinking/Reasoning | ❌ | ✅ | AIMLAPI exclusive |
| Web Search | ❌ | ✅ | AIMLAPI exclusive |
| Log Probabilities | ✅ | ✅ | Both support |
| Logit Bias | ✅ | ✅ | Both support |
| Streaming | ✅ | ✅ | Both support |
| Vision | ✅ | ✅ | Both support |
| STT | ❌ | ✅ | AIMLAPI exclusive |
| TTS | ❌ | ✅ | AIMLAPI exclusive |

---

## Troubleshooting

### Issue: Tool Calls Not Working

**Solution**: Ensure `toolChoice` is set to `Auto` or `Function`:
```kotlin
toolChoice = ToolChoice.Auto
```

### Issue: Web Search Not Returning Results

**Solution**: Model may need explicit instruction:
```kotlin
messages = listOf(
    "system" to "You can search the web for current information.",
    "user" to "What happened today?"
)
```

### Issue: Thinking Mode Not Showing Reasoning

**Solution**: Check logs - reasoning is logged, not included in response:
```
adb logcat | grep "Model reasoning"
```

### Issue: High Token Usage with Thinking

**Solution**: This is expected - thinking mode uses 2-5x more tokens for reasoning.

---

## Migration from Basic Implementation

### Before (Basic)

```kotlin
val response = api.generateChatCompletion(messages)
```

### After (With Function Calling)

```kotlin
val response = api.generateWithTools(
    messages,
    tools = listOf(myTool)
)
```

### After (With Web Search)

```kotlin
val response = api.generateWithWebSearch(messages)
```

---

## Additional Resources

- [AIMLAPI Documentation](https://docs.aimlapi.com/)
- [Function Calling Guide](https://docs.aimlapi.com/capabilities/function-calling)
- [Web Search Documentation](https://docs.aimlapi.com/api-references/text-models-llm/moonshot/kimi-k2-preview)
- [Thinking Mode Guide](https://docs.aimlapi.com/api-references/text-models-llm/alibaba-cloud/qwen3-235b-a22b-thinking-2507)

---

**Implementation Status:** ✅ Complete and Production-Ready

**Features Implemented:** Function Calling, Web Search, Thinking Mode, Advanced Sampling

**Last Updated:** 2024

**Documentation Version:** 1.0.0

package com.blurr.voice.mcp

import android.util.Log
import com.blurr.voice.core.providers.FunctionTool
import com.blurr.voice.tools.Tool
import com.blurr.voice.tools.ToolParameter
import com.blurr.voice.tools.ToolResult

/**
 * Adapter that wraps an MCP tool as a regular Tool
 * 
 * This allows MCP tools to be used seamlessly alongside built-in tools
 * by the Ultra-Generalist Agent.
 */
class MCPToolAdapter(
    private val mcpTool: MCPTool,
    private val server: MCPServer
) : Tool {
    
    companion object {
        private const val TAG = "MCPToolAdapter"
    }
    
    override val name: String
        get() = "${server.name}:${mcpTool.name}"
    
    override val description: String
        get() = mcpTool.description
    
    override val parameters: List<ToolParameter>
        get() {
            val properties = mcpTool.getParameterProperties()
            val required = mcpTool.getRequiredParameters()
            
            return properties.map { (paramName, paramSchema) ->
                ToolParameter(
                    name = paramName,
                    type = paramSchema["type"] as? String ?: "string",
                    description = paramSchema["description"] as? String ?: "",
                    required = required.contains(paramName)
                )
            }
        }
    
    override suspend fun execute(
        params: Map<String, Any>,
        context: List<ToolResult>
    ): ToolResult {
        return try {
            Log.d(TAG, "Executing MCP tool: ${mcpTool.name}")
            Log.d(TAG, "Parameters: $params")
            
            // Validate arguments against schema
            val validation = mcpTool.validateArguments(params)
            if (validation.isFailure) {
                val error = validation.exceptionOrNull()?.message ?: "Validation failed"
                Log.e(TAG, "Parameter validation failed: $error")
                return ToolResult(
                    toolName = name,
                    success = false,
                    data = null,
                    error = error
                )
            }
            
            // Call MCP server tool
            val result = server.callTool(mcpTool.name, params)
            
            // Parse result
            val content = result.optJSONArray("content")
            val data = if (content != null) {
                // MCP returns content as array of content items
                parseContent(content)
            } else {
                // Fallback to raw result
                result.toString()
            }
            
            Log.d(TAG, "MCP tool executed successfully: ${mcpTool.name}")
            
            ToolResult(
                toolName = name,
                success = true,
                data = data,
                error = null,
                metadata = mapOf(
                    "server" to server.name,
                    "mcp_tool" to mcpTool.name
                )
            )
            
        } catch (e: MCPException) {
            Log.e(TAG, "MCP error executing tool: ${mcpTool.name}", e)
            ToolResult(
                toolName = name,
                success = false,
                data = null,
                error = "MCP Error [${e.errorCode}]: ${e.message}",
                metadata = mapOf(
                    "error_code" to (e.errorCode ?: -1),
                    "error_data" to (e.errorData?.toString() ?: "")
                )
            )
            
        } catch (e: Exception) {
            Log.e(TAG, "Unexpected error executing tool: ${mcpTool.name}", e)
            ToolResult(
                toolName = name,
                success = false,
                data = null,
                error = "Error: ${e.message}"
            )
        }
    }
    
    /**
     * Parse MCP content array into structured data
     */
    private fun parseContent(content: org.json.JSONArray): Any {
        if (content.length() == 0) {
            return ""
        }
        
        // If single item, return its content directly
        if (content.length() == 1) {
            val item = content.getJSONObject(0)
            return when (val type = item.optString("type", "text")) {
                "text" -> item.optString("text", "")
                "image" -> mapOf(
                    "type" to "image",
                    "data" to item.optString("data", ""),
                    "mimeType" to item.optString("mimeType", "")
                )
                "resource" -> mapOf(
                    "type" to "resource",
                    "uri" to item.optString("uri", ""),
                    "mimeType" to item.optString("mimeType", "")
                )
                else -> {
                    Log.w(TAG, "Unknown content type: $type")
                    item.toString()
                }
            }
        }
        
        // Multiple items - return as list
        val items = mutableListOf<Any>()
        for (i in 0 until content.length()) {
            val item = content.getJSONObject(i)
            when (val type = item.optString("type", "text")) {
                "text" -> items.add(item.optString("text", ""))
                "image" -> items.add(mapOf(
                    "type" to "image",
                    "data" to item.optString("data", ""),
                    "mimeType" to item.optString("mimeType", "")
                ))
                "resource" -> items.add(mapOf(
                    "type" to "resource",
                    "uri" to item.optString("uri", ""),
                    "mimeType" to item.optString("mimeType", "")
                ))
                else -> items.add(item.toString())
            }
        }
        
        return items
    }
    
    override fun toFunctionTool(): FunctionTool {
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

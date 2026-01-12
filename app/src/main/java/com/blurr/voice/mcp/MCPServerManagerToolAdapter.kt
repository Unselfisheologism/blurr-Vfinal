package com.blurr.voice.mcp

import android.util.Log
import com.blurr.voice.core.providers.FunctionTool
import com.blurr.voice.tools.Tool
import com.blurr.voice.tools.ToolParameter
import com.blurr.voice.tools.ToolResult
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/**
 * Adapter that wraps MCPServerManager tool as a regular Tool
 *
 * This allows MCP tools from MCPServerManager (official SDK) to be used
 * seamlessly alongside built-in tools by Ultra-Generalist Agent.
 */
class MCPServerManagerToolAdapter(
    private val mcpServerManager: MCPServerManager,
    private val toolInfo: MCPToolInfo
) : Tool {

    companion object {
        private const val TAG = "MCPServerManagerToolAdapter"
    }

    override val name: String
        get() = "${toolInfo.serverName}:${toolInfo.name}"

    override val description: String
        get() = toolInfo.description

    override val parameters: List<ToolParameter>
        get() {
            return parseInputSchema(toolInfo.inputSchema)
        }

    override suspend fun execute(
        params: Map<String, Any>,
        context: List<ToolResult>
    ): ToolResult {
        return withContext(Dispatchers.IO) {
            try {
                Log.d(TAG, "Executing MCP tool: ${toolInfo.serverName}:${toolInfo.name}")
                Log.d(TAG, "Parameters: $params")

                // Call MCP server tool via MCPServerManager
                val result = mcpServerManager.executeTool(
                    serverName = toolInfo.serverName,
                    toolName = toolInfo.name,
                    arguments = params
                )

                when {
                    result.isSuccess -> {
                        val output = result.getOrNull()
                        Log.d(TAG, "MCP tool executed successfully: ${toolInfo.name}")
                        ToolResult.success(
                            toolName = name,
                            data = output,
                            metadata = mapOf(
                                "server" to toolInfo.serverName,
                                "mcp_tool" to toolInfo.name
                            )
                        )
                    }
                    else -> {
                        val error = result.exceptionOrNull()
                        Log.e(TAG, "MCP tool execution failed: ${toolInfo.name}", error)
                        ToolResult.error(
                            toolName = name,
                            error = error?.message ?: "Tool execution failed"
                        )
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Unexpected error executing tool: ${toolInfo.name}", e)
                ToolResult.error(
                    toolName = name,
                    error = "Error: ${e.message}"
                )
            }
        }
    }

    /**
     * Parse input schema to extract ToolParameter list
     */
    private fun parseInputSchema(schema: Any?): List<ToolParameter> {
        val parameters = mutableListOf<ToolParameter>()

        if (schema == null || schema !is Map<*, *>) {
            return parameters
        }

        @Suppress("UNCHECKED_CAST")
        val schemaMap = schema as Map<String, Any>

        // Get properties
        val properties = schemaMap["properties"] as? Map<String, Any> ?: return parameters
        val required = schemaMap["required"] as? List<String> ?: emptyList()

        properties.forEach { (paramName, paramSchema) ->
            if (paramSchema is Map<*, *>) {
                @Suppress("UNCHECKED_CAST")
                val paramDetails = paramSchema as Map<String, Any>

                parameters.add(
                    ToolParameter(
                        name = paramName,
                        type = (paramDetails["type"] as? String) ?: "string",
                        description = (paramDetails["description"] as? String) ?: "",
                        required = required.contains(paramName)
                    )
                )
            }
        }

        return parameters
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

package com.twent.voice.tools

import com.twent.voice.core.providers.FunctionTool

/**
 * Tool interface for Ultra-Generalist Agent
 * 
 * All tools (built-in and MCP) implement this interface to provide
 * a consistent API for tool discovery and execution.
 */
interface Tool {
    /**
     * Unique name for this tool
     * Used by the agent to identify and call the tool
     */
    val name: String
    
    /**
     * Human-readable description of what the tool does
     * Used in LLM prompts for tool selection
     */
    val description: String
    
    /**
     * List of parameters this tool accepts
     */
    val parameters: List<ToolParameter>
    
    /**
     * Execute the tool with given parameters
     * 
     * @param params Parameter values as key-value pairs
     * @param context Previous tool results in the execution chain
     * @return Result of tool execution
     */
    suspend fun execute(
        params: Map<String, Any>,
        context: List<ToolResult>
    ): ToolResult
    
    /**
     * Convert tool to FunctionTool format for LLM function calling
     */
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

/**
 * Tool parameter definition
 */
data class ToolParameter(
    val name: String,
    val type: String,  // JSON Schema type: string, number, boolean, object, array
    val description: String,
    val required: Boolean = true,
    val enum: List<String>? = null,  // For restricted value sets
    val default: Any? = null
) {
    /**
     * Validate parameter value against type
     */
    fun validate(value: Any?): Result<Unit> {
        if (value == null) {
            return if (required) {
                Result.failure(IllegalArgumentException("Required parameter '$name' is missing"))
            } else {
                Result.success(Unit)
            }
        }
        
        // Basic type checking
        val isValid = when (type) {
            "string" -> value is String
            "number", "integer" -> value is Number
            "boolean" -> value is Boolean
            "array" -> value is List<*>
            "object" -> value is Map<*, *>
            else -> true // Unknown types pass
        }
        
        if (!isValid) {
            return Result.failure(
                IllegalArgumentException("Parameter '$name' expected type '$type' but got ${value::class.simpleName}")
            )
        }
        
        // Enum validation
        if (enum != null && value is String && !enum.contains(value)) {
            return Result.failure(
                IllegalArgumentException("Parameter '$name' must be one of: ${enum.joinToString()}")
            )
        }
        
        return Result.success(Unit)
    }
}

/**
 * Result of tool execution
 */
data class ToolResult(
    val toolName: String,
    val success: Boolean,
    val data: Any?,
    val error: String? = null,
    val metadata: Map<String, Any> = emptyMap()
) {
    companion object {
        /**
         * Create successful result
         */
        fun success(toolName: String, data: Any?, metadata: Map<String, Any> = emptyMap()): ToolResult {
            return ToolResult(
                toolName = toolName,
                success = true,
                data = data,
                error = null,
                metadata = metadata
            )
        }
        
        /**
         * Create error result
         */
        fun error(toolName: String, error: String, metadata: Map<String, Any> = emptyMap()): ToolResult {
            return ToolResult(
                toolName = toolName,
                success = false,
                data = null,
                error = error,
                metadata = metadata
            )
        }
    }
    
    /**
     * Get data as string (for display)
     */
    fun getDataAsString(): String {
        return when (data) {
            null -> ""
            is String -> data
            is Map<*, *> -> data.entries.joinToString("\n") { "${it.key}: ${it.value}" }
            is List<*> -> data.joinToString("\n")
            else -> data.toString()
        }
    }
    
    /**
     * Get data as Map (if possible)
     */
    @Suppress("UNCHECKED_CAST")
    fun getDataAsMap(): Map<String, Any>? {
        return data as? Map<String, Any>
    }
    
    /**
     * Get data as List (if possible)
     */
    @Suppress("UNCHECKED_CAST")
    fun getDataAsList(): List<Any>? {
        return data as? List<Any>
    }
    
    /**
     * Check if result contains specific key in data
     */
    fun hasData(key: String): Boolean {
        return getDataAsMap()?.containsKey(key) == true
    }
    
    /**
     * Get specific data field
     */
    fun getData(key: String): Any? {
        return getDataAsMap()?.get(key)
    }
}

/**
 * Abstract base class for tools with common functionality
 */
abstract class BaseTool : Tool {
    /**
     * Validate parameters before execution
     */
    protected fun validateParameters(params: Map<String, Any>): Result<Unit> {
        for (param in parameters) {
            val value = params[param.name]
            val validation = param.validate(value)
            if (validation.isFailure) {
                return validation
            }
        }
        return Result.success(Unit)
    }
    
    /**
     * Get required parameter value (throws if missing)
     */
    protected fun <T> getRequiredParam(params: Map<String, Any>, name: String): T {
        @Suppress("UNCHECKED_CAST")
        return params[name] as? T
            ?: throw IllegalArgumentException("Required parameter '$name' is missing")
    }
    
    /**
     * Get optional parameter value with default
     */
    protected fun <T> getOptionalParam(params: Map<String, Any>, name: String, default: T): T {
        @Suppress("UNCHECKED_CAST")
        return params[name] as? T ?: default
    }
    
    /**
     * Extract data from previous tool results
     */
    protected fun getContextData(context: List<ToolResult>, toolName: String): Any? {
        return context.firstOrNull { it.toolName == toolName }?.data
    }
    
    /**
     * Extract data from most recent tool result
     */
    protected fun getLatestContextData(context: List<ToolResult>): Any? {
        return context.lastOrNull()?.data
    }
}

package com.blurr.voice.mcp

import org.json.JSONObject

/**
 * MCP Tool representation
 * 
 * Represents a tool discovered from an MCP server.
 * Contains the tool's schema and metadata.
 */
data class MCPTool(
    val name: String,
    val description: String,
    val inputSchema: Map<String, Any>
) {
    companion object {
        /**
         * Parse MCP tool from JSON response
         */
        fun fromJson(json: JSONObject): MCPTool {
            val name = json.getString("name")
            val description = json.optString("description", "")
            
            // Parse input schema
            val inputSchemaJson = json.getJSONObject("inputSchema")
            val inputSchema = jsonObjectToMap(inputSchemaJson)
            
            return MCPTool(
                name = name,
                description = description,
                inputSchema = inputSchema
            )
        }
        
        /**
         * Convert JSONObject to Map recursively
         */
        private fun jsonObjectToMap(json: JSONObject): Map<String, Any> {
            val map = mutableMapOf<String, Any>()
            
            json.keys().forEach { key ->
                val value = json.get(key)
                map[key] = when (value) {
                    is JSONObject -> jsonObjectToMap(value)
                    is org.json.JSONArray -> jsonArrayToList(value)
                    else -> value
                }
            }
            
            return map
        }
        
        /**
         * Convert JSONArray to List recursively
         */
        private fun jsonArrayToList(array: org.json.JSONArray): List<Any> {
            val list = mutableListOf<Any>()
            
            for (i in 0 until array.length()) {
                val value = array.get(i)
                list.add(when (value) {
                    is JSONObject -> jsonObjectToMap(value)
                    is org.json.JSONArray -> jsonArrayToList(value)
                    else -> value
                })
            }
            
            return list
        }
    }
    
    /**
     * Get required parameters from schema
     */
    fun getRequiredParameters(): List<String> {
        val required = inputSchema["required"]
        return when (required) {
            is List<*> -> required.filterIsInstance<String>()
            else -> emptyList()
        }
    }
    
    /**
     * Get parameter properties from schema
     */
    @Suppress("UNCHECKED_CAST")
    fun getParameterProperties(): Map<String, Map<String, Any>> {
        val properties = inputSchema["properties"]
        return when (properties) {
            is Map<*, *> -> properties as? Map<String, Map<String, Any>> ?: emptyMap()
            else -> emptyMap()
        }
    }
    
    /**
     * Get parameter type
     */
    fun getParameterType(paramName: String): String? {
        val properties = getParameterProperties()
        val paramSchema = properties[paramName] ?: return null
        return paramSchema["type"] as? String
    }
    
    /**
     * Get parameter description
     */
    fun getParameterDescription(paramName: String): String? {
        val properties = getParameterProperties()
        val paramSchema = properties[paramName] ?: return null
        return paramSchema["description"] as? String
    }
    
    /**
     * Check if parameter is required
     */
    fun isParameterRequired(paramName: String): Boolean {
        return getRequiredParameters().contains(paramName)
    }
    
    /**
     * Validate arguments against schema (basic validation)
     */
    fun validateArguments(arguments: Map<String, Any>): Result<Unit> {
        val requiredParams = getRequiredParameters()
        val properties = getParameterProperties()
        
        // Check required parameters
        val missingParams = requiredParams.filter { !arguments.containsKey(it) }
        if (missingParams.isNotEmpty()) {
            return Result.failure(
                MCPException(
                    "Missing required parameters: ${missingParams.joinToString()}",
                    MCPException.INVALID_PARAMS
                )
            )
        }
        
        // Check unknown parameters
        val unknownParams = arguments.keys.filter { !properties.containsKey(it) }
        if (unknownParams.isNotEmpty()) {
            // Warning only - some tools might accept additional params
            android.util.Log.w("MCPTool", "Unknown parameters: ${unknownParams.joinToString()}")
        }
        
        return Result.success(Unit)
    }
    
    /**
     * Convert to human-readable string
     */
    override fun toString(): String {
        val params = getParameterProperties()
        val required = getRequiredParameters()
        
        return buildString {
            appendLine("Tool: $name")
            appendLine("Description: $description")
            if (params.isNotEmpty()) {
                appendLine("Parameters:")
                params.forEach { (paramName, paramSchema) ->
                    val type = paramSchema["type"] as? String ?: "any"
                    val desc = paramSchema["description"] as? String ?: ""
                    val req = if (required.contains(paramName)) " (required)" else ""
                    appendLine("  - $paramName: $type$req - $desc")
                }
            }
        }
    }
}

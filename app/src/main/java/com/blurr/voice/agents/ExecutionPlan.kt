package com.twent.voice.agents

import org.json.JSONArray
import org.json.JSONObject

/**
 * Execution plan created by the Ultra-Generalist Agent
 * 
 * Contains a sequence of tool execution steps and the reasoning behind them.
 */
data class ExecutionPlan(
    val steps: List<ExecutionStep>,
    val reasoning: String
) {
    /**
     * Check if plan has any steps
     */
    fun hasSteps(): Boolean = steps.isNotEmpty()
    
    /**
     * Get step count
     */
    fun getStepCount(): Int = steps.size
    
    /**
     * Get tool names in execution order
     */
    fun getToolNames(): List<String> = steps.map { it.toolName }
    
    /**
     * Check if plan uses specific tool
     */
    fun usesTool(toolName: String): Boolean = steps.any { it.toolName == toolName }
    
    /**
     * Convert to JSON for storage
     */
    fun toJson(): String {
        return JSONObject().apply {
            put("reasoning", reasoning)
            put("steps", JSONArray().apply {
                steps.forEach { step ->
                    put(step.toJson())
                }
            })
        }.toString()
    }
    
    companion object {
        /**
         * Parse execution plan from JSON
         */
        fun fromJson(json: String): ExecutionPlan {
            val obj = JSONObject(json)
            val reasoning = obj.getString("reasoning")
            val stepsArray = obj.getJSONArray("steps")
            
            val steps = mutableListOf<ExecutionStep>()
            for (i in 0 until stepsArray.length()) {
                steps.add(ExecutionStep.fromJson(stepsArray.getJSONObject(i)))
            }
            
            return ExecutionPlan(steps, reasoning)
        }
        
        /**
         * Create empty plan
         */
        fun empty() = ExecutionPlan(emptyList(), "No execution needed")
        
        /**
         * Create single-step plan
         */
        fun singleStep(toolName: String, parameters: Map<String, Any>, description: String = ""): ExecutionPlan {
            return ExecutionPlan(
                steps = listOf(ExecutionStep(toolName, parameters, description)),
                reasoning = "Execute $toolName"
            )
        }
    }
    
    override fun toString(): String {
        return buildString {
            appendLine("Execution Plan:")
            appendLine("Reasoning: $reasoning")
            if (steps.isNotEmpty()) {
                appendLine("Steps:")
                steps.forEachIndexed { index, step ->
                    appendLine("  ${index + 1}. ${step.toolName}: ${step.description}")
                }
            }
        }
    }
}

/**
 * Single step in execution plan
 */
data class ExecutionStep(
    val toolName: String,
    val parameters: Map<String, Any>,
    val description: String
) {
    /**
     * Convert to JSON
     */
    fun toJson(): JSONObject {
        return JSONObject().apply {
            put("toolName", toolName)
            put("parameters", JSONObject(parameters))
            put("description", description)
        }
    }
    
    companion object {
        /**
         * Parse from JSON
         */
        fun fromJson(json: JSONObject): ExecutionStep {
            val toolName = json.getString("toolName")
            val description = json.optString("description", "")
            
            val paramsJson = json.optJSONObject("parameters") ?: JSONObject()
            val parameters = mutableMapOf<String, Any>()
            paramsJson.keys().forEach { key ->
                parameters[key] = paramsJson.get(key)
            }
            
            return ExecutionStep(toolName, parameters, description)
        }
    }
    
    override fun toString(): String {
        return "$toolName(${parameters.keys.joinToString()})"
    }
}

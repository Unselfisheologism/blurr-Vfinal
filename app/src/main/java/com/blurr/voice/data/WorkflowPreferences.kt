package com.blurr.voice.data

import android.content.Context
import android.content.SharedPreferences
import android.util.Log

/**
 * Preferences manager for storing and retrieving workflows
 * 
 * Workflows are stored as JSON strings in SharedPreferences
 * Key format: "workflow_{workflow_id}"
 */
class WorkflowPreferences(context: Context) {
    
    companion object {
        private const val TAG = "WorkflowPreferences"
        private const val PREFS_NAME = "workflow_preferences"
        private const val KEY_PREFIX = "workflow_"
        private const val KEY_WORKFLOW_LIST = "workflow_list"
    }
    
    private val prefs: SharedPreferences = context.getSharedPreferences(
        PREFS_NAME,
        Context.MODE_PRIVATE
    )
    
    /**
     * Save a workflow
     * @param workflowId Unique workflow ID
     * @param workflowJson Workflow data as JSON string
     */
    fun saveWorkflow(workflowId: String, workflowJson: String) {
        try {
            prefs.edit().apply {
                putString("$KEY_PREFIX$workflowId", workflowJson)
                
                // Update workflow list
                val workflowIds = getWorkflowIds().toMutableSet()
                workflowIds.add(workflowId)
                putStringSet(KEY_WORKFLOW_LIST, workflowIds)
                
                apply()
            }
            Log.d(TAG, "Saved workflow: $workflowId")
        } catch (e: Exception) {
            Log.e(TAG, "Error saving workflow: $workflowId", e)
        }
    }
    
    /**
     * Get a workflow by ID
     * @param workflowId Unique workflow ID
     * @return Workflow JSON string or null if not found
     */
    fun getWorkflow(workflowId: String): String? {
        return prefs.getString("$KEY_PREFIX$workflowId", null)
    }
    
    /**
     * Delete a workflow
     * @param workflowId Unique workflow ID
     */
    fun deleteWorkflow(workflowId: String) {
        try {
            prefs.edit().apply {
                remove("$KEY_PREFIX$workflowId")
                
                // Update workflow list
                val workflowIds = getWorkflowIds().toMutableSet()
                workflowIds.remove(workflowId)
                putStringSet(KEY_WORKFLOW_LIST, workflowIds)
                
                apply()
            }
            Log.d(TAG, "Deleted workflow: $workflowId")
        } catch (e: Exception) {
            Log.e(TAG, "Error deleting workflow: $workflowId", e)
        }
    }
    
    /**
     * Get all workflows
     * @return Map of workflow ID to JSON string
     */
    fun getAllWorkflows(): Map<String, String> {
        val workflows = mutableMapOf<String, String>()
        
        try {
            val workflowIds = getWorkflowIds()
            
            for (workflowId in workflowIds) {
                val workflowJson = getWorkflow(workflowId)
                if (workflowJson != null) {
                    workflows[workflowId] = workflowJson
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error getting all workflows", e)
        }
        
        return workflows
    }
    
    /**
     * Get list of all workflow IDs
     */
    fun getWorkflowIds(): Set<String> {
        return prefs.getStringSet(KEY_WORKFLOW_LIST, emptySet()) ?: emptySet()
    }
    
    /**
     * Check if a workflow exists
     */
    fun hasWorkflow(workflowId: String): Boolean {
        return prefs.contains("$KEY_PREFIX$workflowId")
    }
    
    /**
     * Clear all workflows (for testing)
     */
    fun clearAll() {
        try {
            val workflowIds = getWorkflowIds()
            prefs.edit().apply {
                for (workflowId in workflowIds) {
                    remove("$KEY_PREFIX$workflowId")
                }
                remove(KEY_WORKFLOW_LIST)
                apply()
            }
            Log.d(TAG, "Cleared all workflows")
        } catch (e: Exception) {
            Log.e(TAG, "Error clearing workflows", e)
        }
    }
    
    /**
     * Get count of saved workflows
     */
    fun getWorkflowCount(): Int {
        return getWorkflowIds().size
    }
}

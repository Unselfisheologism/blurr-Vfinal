package com.blurr.voice.tools

import android.content.Context
import android.content.Intent
import com.blurr.voice.SpreadsheetEditorActivity
import org.json.JSONObject

/**
 * Tool for opening and creating spreadsheets via AI agent
 */
class SpreadsheetTool(private val context: Context) : Tool {
    
    override val name = "spreadsheet"
    override val description = "Create, edit, and analyze spreadsheets with AI assistance"
    
    override val parameters = listOf(
        ToolParameter(
            name = "action",
            type = "string",
            description = "Action to perform: 'create', 'open', 'generate'",
            required = true,
            enum = listOf("create", "open", "generate")
        ),
        ToolParameter(
            name = "prompt",
            type = "string",
            description = "AI prompt for generating spreadsheet (for 'generate' action)",
            required = false
        ),
        ToolParameter(
            name = "documentId",
            type = "string",
            description = "Document ID to open (for 'open' action)",
            required = false
        )
    )
    
    override suspend fun execute(args: Map<String, Any>): ToolResult {
        return try {
            val action = args["action"] as? String ?: "create"
            
            when (action) {
                "create" -> createSpreadsheet()
                "open" -> openSpreadsheet(args["documentId"] as? String)
                "generate" -> generateSpreadsheet(args["prompt"] as? String ?: "")
                else -> ToolResult.error("Unknown action: $action")
            }
        } catch (e: Exception) {
            ToolResult.error("Failed to execute spreadsheet tool: ${e.message}")
        }
    }
    
    private fun createSpreadsheet(): ToolResult {
        val intent = Intent(context, SpreadsheetEditorActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        context.startActivity(intent)
        
        return ToolResult.success(
            "Spreadsheet editor opened",
            JSONObject().apply {
                put("action", "create")
                put("status", "opened")
            }
        )
    }
    
    private fun openSpreadsheet(documentId: String?): ToolResult {
        if (documentId == null) {
            return ToolResult.error("Document ID is required for open action")
        }
        
        val intent = Intent(context, SpreadsheetEditorActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
            putExtra(SpreadsheetEditorActivity.EXTRA_DOCUMENT_ID, documentId)
        }
        context.startActivity(intent)
        
        return ToolResult.success(
            "Spreadsheet opened: $documentId",
            JSONObject().apply {
                put("action", "open")
                put("documentId", documentId)
                put("status", "opened")
            }
        )
    }
    
    private fun generateSpreadsheet(prompt: String): ToolResult {
        if (prompt.isEmpty()) {
            return ToolResult.error("Prompt is required for generate action")
        }
        
        val intent = Intent(context, SpreadsheetEditorActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
            putExtra(SpreadsheetEditorActivity.EXTRA_INITIAL_PROMPT, prompt)
        }
        context.startActivity(intent)
        
        return ToolResult.success(
            "Generating spreadsheet: $prompt",
            JSONObject().apply {
                put("action", "generate")
                put("prompt", prompt)
                put("status", "opened")
            }
        )
    }
}

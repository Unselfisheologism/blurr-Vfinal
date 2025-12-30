package com.blurr.voice.tools

import android.content.Context
import android.content.Intent
import com.blurr.voice.MediaCanvasActivity
import org.json.JSONObject

/**
 * Tool for AI-native multimodal media canvas
 * Epic 4: Jaaz/Refly-inspired infinite canvas
 */
class MediaCanvasTool(private val context: Context) : BaseTool() {
    
    override val name = "media_canvas"
    override val description = "Create and edit multimodal media canvas with AI-generated images, videos, audio, and text layers"
    
    override val parameters = listOf(
        ToolParameter(
            name = "action",
            type = "string",
            description = "Action to perform: 'create', 'open', 'generate'",
            required = false,
            enum = listOf("create", "open", "generate")
        ),
        ToolParameter(
            name = "prompt",
            type = "string",
            description = "AI prompt for generating canvas or media (for 'generate' action)",
            required = false
        ),
        ToolParameter(
            name = "documentId",
            type = "string",
            description = "Canvas document ID to open (for 'open' action)",
            required = false
        ),
        ToolParameter(
            name = "mediaType",
            type = "string",
            description = "Type of media to generate: 'image', 'video', 'audio', 'text'",
            required = false,
            enum = listOf("image", "video", "audio", "text")
        )
    )
    
    override suspend fun execute(
        params: Map<String, Any>,
        context: List<ToolResult>
    ): ToolResult {
        return try {
            val action = params["action"] as? String ?: "create"
            
            when (action) {
                "create" -> createCanvas()
                "open" -> openCanvas(params["documentId"] as? String)
                "generate" -> generateCanvas(
                    params["prompt"] as? String ?: "",
                    params["mediaType"] as? String
                )
                else -> ToolResult.error(name, "Unknown action: $action")
            }
        } catch (e: Exception) {
            ToolResult.error(name, "Failed to execute media canvas tool: ${e.message}")
        }
    }
    
    private fun createCanvas(): ToolResult {
        val intent = Intent(context, MediaCanvasActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        context.startActivity(intent)
        
        return ToolResult.success(
            "Media canvas opened",
            JSONObject().apply {
                put("action", "create")
                put("status", "opened")
            }
        )
    }
    
    private fun openCanvas(documentId: String?): ToolResult {
        if (documentId == null) {
            return ToolResult.error(name, "Document ID is required for open action")
        }
        
        val intent = Intent(context, MediaCanvasActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
            putExtra(MediaCanvasActivity.EXTRA_DOCUMENT_ID, documentId)
        }
        context.startActivity(intent)
        
        return ToolResult.success(
            "Canvas opened: $documentId",
            JSONObject().apply {
                put("action", "open")
                put("documentId", documentId)
                put("status", "opened")
            }
        )
    }
    
    private fun generateCanvas(prompt: String, mediaType: String?): ToolResult {
        if (prompt.isEmpty()) {
            return ToolResult.error(name, "Prompt is required for generate action")
        }
        
        val fullPrompt = if (mediaType != null) {
            "Create a canvas with $mediaType: $prompt"
        } else {
            prompt
        }
        
        val intent = Intent(context, MediaCanvasActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
            putExtra(MediaCanvasActivity.EXTRA_INITIAL_PROMPT, fullPrompt)
        }
        context.startActivity(intent)
        
        return ToolResult.success(
            "Generating canvas: $fullPrompt",
            JSONObject().apply {
                put("action", "generate")
                put("prompt", fullPrompt)
                put("mediaType", mediaType ?: "mixed")
                put("status", "opened")
            }
        )
    }
}

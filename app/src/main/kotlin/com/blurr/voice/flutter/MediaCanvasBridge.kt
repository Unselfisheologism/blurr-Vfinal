// Platform bridge for Media Canvas communication
package com.twent.voice.flutter

import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import com.twent.voice.agent.ToolExecutor

/**
 * Bridge for communication between Kotlin and Flutter Media Canvas
 * Handles:
 * - AI-powered media generation (image, video, audio, text)
 * - File operations (export, import)
 * - Collaboration features (Pro)
 */
class MediaCanvasBridge(
    private val context: Context,
    flutterEngine: FlutterEngine
) {
    companion object {
        private const val CHANNEL = "com.twent.media_canvas/bridge"
        private const val TAG = "MediaCanvasBridge"
    }

    private val methodChannel: MethodChannel = MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        CHANNEL
    )
    
    private val toolExecutor: ToolExecutor by lazy {
        ToolExecutor(context)
    }

    init {
        setupMethodCallHandler()
    }

    private fun setupMethodCallHandler() {
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "executeAgentTask" -> {
                    val prompt = call.argument<String>("prompt")
                    if (prompt != null) {
                        executeAgentTask(prompt, result)
                    } else {
                        result.error("INVALID_ARGS", "Prompt is required", null)
                    }
                }
                
                "generateImage" -> {
                    val prompt = call.argument<String>("prompt")
                    if (prompt != null) {
                        generateImage(prompt, result)
                    } else {
                        result.error("INVALID_ARGS", "Prompt is required", null)
                    }
                }
                
                "generateVideo" -> {
                    val prompt = call.argument<String>("prompt")
                    if (prompt != null) {
                        generateVideo(prompt, result)
                    } else {
                        result.error("INVALID_ARGS", "Prompt is required", null)
                    }
                }
                
                "generateAudio" -> {
                    val prompt = call.argument<String>("prompt")
                    if (prompt != null) {
                        generateAudio(prompt, result)
                    } else {
                        result.error("INVALID_ARGS", "Prompt is required", null)
                    }
                }
                
                "generate3DModel" -> {
                    val prompt = call.argument<String>("prompt")
                    if (prompt != null) {
                        generate3DModel(prompt, result)
                    } else {
                        result.error("INVALID_ARGS", "Prompt is required", null)
                    }
                }
                
                "exportCanvas" -> {
                    val format = call.argument<String>("format")
                    val data = call.argument<ByteArray>("data")
                    if (format != null && data != null) {
                        exportCanvas(format, data, result)
                    } else {
                        result.error("INVALID_ARGS", "Format and data required", null)
                    }
                }
                
                "shareCanvas" -> {
                    val filePath = call.argument<String>("filePath")
                    if (filePath != null) {
                        shareCanvas(filePath, result)
                    } else {
                        result.error("INVALID_ARGS", "filePath is required", null)
                    }
                }
                
                "checkProStatus" -> {
                    checkProStatus(result)
                }
                
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    /**
     * Execute AI agent task for canvas operations
     */
    private fun executeAgentTask(prompt: String, result: MethodChannel.Result) {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                Log.d(TAG, "Executing agent task: $prompt")
                
                val response = toolExecutor.executeTask(prompt)
                
                CoroutineScope(Dispatchers.Main).launch {
                    result.success(
                        mapOf(
                            "success" to true,
                            "result" to response
                        )
                    )
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error executing agent task", e)
                CoroutineScope(Dispatchers.Main).launch {
                    result.success(
                        mapOf(
                            "success" to false,
                            "error" to e.message
                        )
                    )
                }
            }
        }
    }

    /**
     * Generate image using ImageGenerationTool
     * Uses the existing ImageGenerationTool from Ultra-Generalist Agent
     */
    private fun generateImage(prompt: String, result: MethodChannel.Result) {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                Log.d(TAG, "Generating image with ImageGenerationTool: $prompt")
                
                // Call ImageGenerationTool directly through agent
                // The tool will use AIMLAPI or OpenRouter for generation
                val response = toolExecutor.executeTask(
                    "Use the image_generation tool to create: $prompt"
                )
                
                CoroutineScope(Dispatchers.Main).launch {
                    result.success(
                        mapOf(
                            "success" to true,
                            "imageUrl" to response,
                            "type" to "image"
                        )
                    )
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error generating image", e)
                CoroutineScope(Dispatchers.Main).launch {
                    result.error("GENERATION_ERROR", e.message, null)
                }
            }
        }
    }

    /**
     * Generate video using VideoGenerationTool (Pro feature)
     * Uses the existing VideoGenerationTool from Ultra-Generalist Agent
     */
    private fun generateVideo(prompt: String, result: MethodChannel.Result) {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                Log.d(TAG, "Generating video with VideoGenerationTool: $prompt")
                
                // Call VideoGenerationTool directly through agent
                // The tool uses Haiper, Runway, or Kling for video generation
                val response = toolExecutor.executeTask(
                    "Use the video_generation tool to create: $prompt"
                )
                
                CoroutineScope(Dispatchers.Main).launch {
                    result.success(
                        mapOf(
                            "success" to true,
                            "videoUrl" to response,
                            "type" to "video"
                        )
                    )
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error generating video", e)
                CoroutineScope(Dispatchers.Main).launch {
                    result.error("GENERATION_ERROR", e.message, null)
                }
            }
        }
    }

    /**
     * Generate audio using AudioGenerationTool or MusicGenerationTool
     * Uses existing tools from Ultra-Generalist Agent
     */
    private fun generateAudio(prompt: String, result: MethodChannel.Result) {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                Log.d(TAG, "Generating audio with AudioGenerationTool: $prompt")
                
                // Determine if it's music or audio based on prompt keywords
                val isMusic = prompt.contains("music", ignoreCase = true) || 
                              prompt.contains("song", ignoreCase = true) ||
                              prompt.contains("melody", ignoreCase = true)
                
                val toolName = if (isMusic) "music_generation" else "audio_generation"
                
                // Call appropriate tool through agent
                // AudioGenerationTool uses ElevenLabs or PlayHT
                // MusicGenerationTool uses Suno or Udio
                val response = toolExecutor.executeTask(
                    "Use the $toolName tool to create: $prompt"
                )
                
                CoroutineScope(Dispatchers.Main).launch {
                    result.success(
                        mapOf(
                            "success" to true,
                            "audioUrl" to response,
                            "type" to "audio"
                        )
                    )
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error generating audio", e)
                CoroutineScope(Dispatchers.Main).launch {
                    result.error("GENERATION_ERROR", e.message, null)
                }
            }
        }
    }

    /**
     * Generate 3D model using Model3DGenerationTool (Pro feature)
     * Uses existing Model3DGenerationTool from Ultra-Generalist Agent
     */
    private fun generate3DModel(prompt: String, result: MethodChannel.Result) {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                Log.d(TAG, "Generating 3D model with Model3DGenerationTool: $prompt")
                
                // Call Model3DGenerationTool directly through agent
                // The tool uses Meshy, Tripo, or other 3D generation services
                // Note: 3D generation can take 1-5 minutes
                val response = toolExecutor.executeTask(
                    "Use the model_3d_generation tool to create a 3D model: $prompt"
                )
                
                CoroutineScope(Dispatchers.Main).launch {
                    result.success(
                        mapOf(
                            "success" to true,
                            "modelUrl" to response,
                            "type" to "model3d"
                        )
                    )
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error generating 3D model", e)
                CoroutineScope(Dispatchers.Main).launch {
                    result.error("GENERATION_ERROR", e.message, null)
                }
            }
        }
    }

    /**
     * Export canvas to file
     */
    private fun exportCanvas(format: String, data: ByteArray, result: MethodChannel.Result) {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val fileName = "canvas_${System.currentTimeMillis()}.$format"
                val file = java.io.File(context.getExternalFilesDir(null), fileName)
                file.writeBytes(data)
                
                CoroutineScope(Dispatchers.Main).launch {
                    result.success(
                        mapOf(
                            "success" to true,
                            "filePath" to file.absolutePath
                        )
                    )
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error exporting canvas", e)
                CoroutineScope(Dispatchers.Main).launch {
                    result.error("EXPORT_ERROR", e.message, null)
                }
            }
        }
    }

    /**
     * Share canvas file
     */
    private fun shareCanvas(filePath: String, result: MethodChannel.Result) {
        // TODO: Implement Android share sheet
        result.error("NOT_IMPLEMENTED", "Share not yet implemented", null)
    }

    /**
     * Check Pro subscription status
     */
    private fun checkProStatus(result: MethodChannel.Result) {
        try {
            // TODO: Integrate with FreemiumManager
            result.success(
                mapOf(
                    "isPro" to false,
                    "features" to mapOf(
                        "videoGeneration" to false,
                        "audioGeneration" to false,
                        "advancedExport" to false,
                        "collaboration" to false
                    )
                )
            )
        } catch (e: Exception) {
            Log.e(TAG, "Error checking Pro status", e)
            result.error("PRO_CHECK_ERROR", e.message, null)
        }
    }

    /**
     * Load existing canvas
     */
    fun loadCanvas(documentId: String) {
        methodChannel.invokeMethod(
            "loadCanvas",
            mapOf("documentId" to documentId)
        )
    }

    /**
     * Create canvas from AI prompt
     */
    fun createFromPrompt(prompt: String) {
        methodChannel.invokeMethod(
            "createFromPrompt",
            mapOf("prompt" to prompt)
        )
    }

    /**
     * Dispose resources
     */
    fun dispose() {
        methodChannel.setMethodCallHandler(null)
    }
}

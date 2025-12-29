package com.blurr.voice.tools

import android.content.Context
import android.util.Log
import com.blurr.voice.core.providers.OpenAICompatibleAPI
import com.blurr.voice.core.providers.ProviderKeyManager
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.withContext
import okhttp3.OkHttpClient
import okhttp3.Request
import org.json.JSONObject
import java.io.File
import java.util.UUID

/**
 * 3D Model Generation Tool
 * 
 * Generates 3D models from text descriptions or images using AI 3D generation
 * (Meshy, Point-E, Shap-E, etc.)
 * 
 * Provider Support:
 * - OpenRouter: No 3D models
 * - AIMLAPI: May have Meshy or similar 3D APIs
 * - Others: Very rare support
 * 
 * Note: 3D generation is async and can take 1-5 minutes
 */
class Model3DGenerationTool(
    private val context: Context
) : BaseTool() {
    
    companion object {
        private const val TAG = "Model3DGenerationTool"
        private const val MODEL_3D_CACHE_DIR = "generated_3d_models"
        private const val MAX_POLL_ATTEMPTS = 60 // ~5 minutes at 5-second intervals
        private const val POLL_INTERVAL_MS = 5000L // 5 seconds
    }
    
    private val keyManager = ProviderKeyManager(context)
    private val modelChecker = MediaModelChecker(context)
    private val httpClient = OkHttpClient()
    
    override val name: String = "generate_3d_model"
    
    override val description: String = 
        "Generate 3D models from text descriptions or images. Can create objects, characters, " +
        "props, assets, or any 3D content. Output formats include GLB, OBJ, FBX for use in " +
        "3D software, games, AR/VR. Note: 3D generation takes 1-5 minutes and is rarely supported."
    
    override val parameters: List<ToolParameter> = listOf(
        ToolParameter(
            name = "prompt",
            type = "string",
            description = "Detailed description of the 3D model to generate. Include shape, " +
                    "style, texture, and any specific details about the object.",
            required = true
        ),
        ToolParameter(
            name = "format",
            type = "string",
            description = "Output 3D format: 'glb' (recommended for web/mobile), 'obj', 'fbx', 'usdz'",
            required = false,
            enum = listOf("glb", "obj", "fbx", "usdz")
        ),
        ToolParameter(
            name = "quality",
            type = "string",
            description = "Model quality/detail: 'low' (fast, simple), 'medium' (balanced), 'high' (detailed, slow)",
            required = false,
            enum = listOf("low", "medium", "high")
        ),
        ToolParameter(
            name = "image_input",
            type = "string",
            description = "Path to reference image for image-to-3D generation (optional)",
            required = false
        ),
        ToolParameter(
            name = "texture",
            type = "boolean",
            description = "Whether to generate textured model (true) or just geometry (false)",
            required = false
        )
    )
    
    override suspend fun execute(
        params: Map<String, Any>,
        context: List<ToolResult>
    ): ToolResult {
        return try {
            // Validate parameters
            validateParameters(params).getOrThrow()
            
            // Extract parameters
            val prompt: String = getRequiredParam(params, "prompt")
            val format: String = getOptionalParam(params, "format", "glb")
            val quality: String = getOptionalParam(params, "quality", "medium")
            val imageInput: String? = getOptionalParam(params, "image_input", null)
            val texture: Boolean = getOptionalParam(params, "texture", true)
            
            Log.d(TAG, "Generating 3D model: prompt='$prompt', format=$format, " +
                    "quality=$quality, texture=$texture, image=$imageInput")
            
            // Check if 3D generation is available
            val availability = modelChecker.checkAvailability(MediaModelChecker.MediaType.MODEL_3D)
            
            if (!availability.isAvailable) {
                return ToolResult.error(
                    toolName = name,
                    error = modelChecker.getUnsupportedMessage(
                        MediaModelChecker.MediaType.MODEL_3D,
                        availability.providerName
                    ) + "\n\nNote: 3D model generation is a rare feature. " +
                            "Consider using image generation for visual content instead."
                )
            }
            
            // Choose model
            val model = availability.recommendedModel 
                ?: return ToolResult.error(
                    toolName = name,
                    error = "No 3D generation models available"
                )
            
            Log.d(TAG, "Using 3D model: $model")
            
            // Start 3D generation (async)
            val jobId = start3DGeneration(model, prompt, format, quality, imageInput, texture)
            
            if (jobId == null) {
                return ToolResult.error(
                    toolName = name,
                    error = "Failed to start 3D model generation. Please try again."
                )
            }
            
            Log.d(TAG, "3D generation started with job ID: $jobId")
            
            // Poll for completion
            val modelUrl = pollForCompletion(jobId)
            
            if (modelUrl != null) {
                // Download 3D model
                val modelPath = download3DModel(modelUrl, format)
                
                if (modelPath != null) {
                    ToolResult.success(
                        toolName = name,
                        result = "3D model generated successfully. Format: $format. Saved to: $modelPath\n\n" +
                                "You can view this model in 3D software or AR viewers.",
                        data = mapOf(
                            "model_path" to modelPath,
                            "model_url" to modelUrl,
                            "model_name" to model,
                            "format" to format,
                            "quality" to quality,
                            "has_texture" to texture
                        )
                    )
                } else {
                    ToolResult.error(
                        toolName = name,
                        error = "3D model generated but download failed. URL: $modelUrl"
                    )
                }
            } else {
                ToolResult.error(
                    toolName = name,
                    error = "3D model generation timed out or failed. " +
                            "3D generation is complex and can take up to 5 minutes. Please try again."
                )
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error generating 3D model", e)
            ToolResult.error(
                toolName = name,
                error = "3D model generation error: ${e.message}"
            )
        }
    }
    
    /**
     * Start async 3D generation
     */
    private suspend fun start3DGeneration(
        model: String,
        prompt: String,
        format: String,
        quality: String,
        imageInput: String?,
        texture: Boolean
    ): String? = withContext(Dispatchers.IO) {
        try {
            val provider = keyManager.getSelectedProvider() ?: return@withContext null
            val apiKey = keyManager.getApiKey(provider) ?: return@withContext null
            
            val api = OpenAICompatibleAPI(provider, apiKey, model)
            
            // Build request
            val requestBody = JSONObject().apply {
                put("prompt", prompt)
                put("format", format)
                put("quality", quality)
                put("texture", texture)
                if (imageInput != null) {
                    put("image_url", imageInput)
                    put("mode", "image-to-3d")
                } else {
                    put("mode", "text-to-3d")
                }
            }
            
            // Start generation (returns job ID)
            val response = api.generate3DModel(requestBody)
            
            if (response != null) {
                val responseJson = JSONObject(response)
                when {
                    responseJson.has("id") -> responseJson.getString("id")
                    responseJson.has("task_id") -> responseJson.getString("task_id")
                    responseJson.has("job_id") -> responseJson.getString("job_id")
                    else -> null
                }
            } else {
                null
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error starting 3D generation", e)
            null
        }
    }
    
    /**
     * Poll for 3D generation completion
     */
    private suspend fun pollForCompletion(jobId: String): String? {
        repeat(MAX_POLL_ATTEMPTS) { attempt ->
            try {
                val status = checkGenerationStatus(jobId)
                
                Log.d(TAG, "Poll attempt ${attempt + 1}/$MAX_POLL_ATTEMPTS: status=$status")
                
                when (status?.state) {
                    "completed", "succeeded", "success" -> {
                        return status.modelUrl
                    }
                    "failed", "error" -> {
                        Log.e(TAG, "3D generation failed: ${status.error}")
                        return null
                    }
                    "processing", "pending", "in_progress" -> {
                        delay(POLL_INTERVAL_MS)
                    }
                    else -> {
                        delay(POLL_INTERVAL_MS)
                    }
                }
                
            } catch (e: Exception) {
                Log.e(TAG, "Error polling for completion", e)
                delay(POLL_INTERVAL_MS)
            }
        }
        
        Log.e(TAG, "3D generation timed out after ${MAX_POLL_ATTEMPTS * POLL_INTERVAL_MS / 1000} seconds")
        return null
    }
    
    /**
     * Check 3D generation status
     */
    private suspend fun checkGenerationStatus(jobId: String): GenerationStatus? = withContext(Dispatchers.IO) {
        try {
            val provider = keyManager.getSelectedProvider() ?: return@withContext null
            val apiKey = keyManager.getApiKey(provider) ?: return@withContext null
            
            val api = OpenAICompatibleAPI(provider, apiKey, "temp")
            val response = api.check3DModelStatus(jobId)
            
            if (response != null) {
                val responseJson = JSONObject(response)
                
                val state = when {
                    responseJson.has("status") -> responseJson.getString("status")
                    responseJson.has("state") -> responseJson.getString("state")
                    else -> "unknown"
                }
                
                val modelUrl = when {
                    responseJson.has("model_url") -> responseJson.getString("model_url")
                    responseJson.has("url") -> responseJson.getString("url")
                    responseJson.has("output") -> responseJson.getString("output")
                    responseJson.has("result_url") -> responseJson.getString("result_url")
                    else -> null
                }
                
                val error = if (responseJson.has("error")) {
                    responseJson.getString("error")
                } else null
                
                GenerationStatus(state, modelUrl, error)
            } else {
                null
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error checking status", e)
            null
        }
    }
    
    /**
     * Download 3D model from URL
     */
    private suspend fun download3DModel(url: String, format: String): String? = withContext(Dispatchers.IO) {
        try {
            val request = Request.Builder()
                .url(url)
                .build()
            
            val response = httpClient.newCall(request).execute()
            
            if (response.isSuccessful) {
                val modelData = response.body?.bytes() ?: return@withContext null
                
                // Create cache directory
                val cacheDir = File(context.cacheDir, MODEL_3D_CACHE_DIR)
                if (!cacheDir.exists()) {
                    cacheDir.mkdirs()
                }
                
                // Save 3D model
                val filename = "model3d_${UUID.randomUUID()}.$format"
                val modelFile = File(cacheDir, filename)
                modelFile.writeBytes(modelData)
                
                Log.d(TAG, "3D model downloaded to: ${modelFile.absolutePath}")
                modelFile.absolutePath
            } else {
                Log.e(TAG, "Failed to download 3D model: ${response.code}")
                null
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error downloading 3D model", e)
            null
        }
    }
    
    /**
     * 3D generation status
     */
    private data class GenerationStatus(
        val state: String,
        val modelUrl: String?,
        val error: String?
    )
}

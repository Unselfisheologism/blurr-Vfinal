package com.twent.voice.tools

import android.content.Context
import android.util.Log
import com.twent.voice.core.providers.OpenAICompatibleAPI
import com.twent.voice.core.providers.ProviderKeyManager
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.withContext
import okhttp3.OkHttpClient
import okhttp3.Request
import org.json.JSONObject
import java.io.File
import java.util.UUID

/**
 * Video Generation Tool
 * 
 * Generates videos from text descriptions or images using available video models
 * (Runway, Luma, Kling, etc.)
 * 
 * Provider Support:
 * - OpenRouter: No video models
 * - AIMLAPI: Runway Gen-2/Gen-3, Luma Ray, Kling
 * - Others: Very limited
 * 
 * Note: Video generation is typically async and can take 30s-5min
 */
class VideoGenerationTool(
    private val context: Context
) : BaseTool() {
    
    companion object {
        private const val TAG = "VideoGenerationTool"
        private const val VIDEO_CACHE_DIR = "generated_videos"
        private const val MAX_POLL_ATTEMPTS = 60 // 5 minutes at 5-second intervals
        private const val POLL_INTERVAL_MS = 5000L // 5 seconds
    }
    
    private val keyManager = ProviderKeyManager(context)
    private val modelChecker = MediaModelChecker(context)
    private val httpClient = OkHttpClient()
    
    override val name: String = "generate_video"
    
    override val description: String = 
        "Generate videos from text descriptions or animate images. Can create short video clips, " +
        "animations, product demos, explainer videos, or bring static images to life. " +
        "Note: Video generation takes 30 seconds to 5 minutes."
    
    override val parameters: List<ToolParameter> = listOf(
        ToolParameter(
            name = "prompt",
            type = "string",
            description = "Detailed description of the video content, motion, and scene. " +
                    "Be specific about camera movement, actions, and atmosphere.",
            required = true
        ),
        ToolParameter(
            name = "duration",
            type = "number",
            description = "Video duration in seconds (typically 3-10 seconds)",
            required = false
        ),
        ToolParameter(
            name = "aspect_ratio",
            type = "string",
            description = "Video aspect ratio: '16:9' (landscape), '9:16' (portrait), '1:1' (square)",
            required = false,
            enum = listOf("16:9", "9:16", "1:1", "4:3")
        ),
        ToolParameter(
            name = "style",
            type = "string",
            description = "Video style: 'realistic', 'animated', 'cinematic', '3d-render', etc.",
            required = false
        ),
        ToolParameter(
            name = "image_path",
            type = "string",
            description = "Path to image to animate (optional, for image-to-video)",
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
            val duration: Int = getOptionalParam(params, "duration", 5)
            val aspectRatio: String = getOptionalParam(params, "aspect_ratio", "16:9")
            val style: String? = getOptionalParam(params, "style", null)
            val imagePath: String? = getOptionalParam(params, "image_path", null)
            
            Log.d(TAG, "Generating video: prompt='$prompt', duration=${duration}s, " +
                    "aspect_ratio=$aspectRatio, image_path=$imagePath")
            
            // Check if video generation is available
            val availability = modelChecker.checkAvailability(MediaModelChecker.MediaType.VIDEO)
            
            if (!availability.isAvailable) {
                return ToolResult.failure(
                    toolName = name,
                    error = modelChecker.getUnsupportedMessage(
                        MediaModelChecker.MediaType.VIDEO,
                        availability.providerName
                    )
                )
            }
            
            // Choose model
            val model = availability.recommendedModel 
                ?: return ToolResult.failure(
                    toolName = name,
                    error = "No video generation models available"
                )
            
            Log.d(TAG, "Using model: $model")
            
            // Enhance prompt with style
            val enhancedPrompt = if (style != null) {
                "$prompt, $style style"
            } else {
                prompt
            }
            
            // Start video generation (async)
            val jobId = startVideoGeneration(model, enhancedPrompt, duration, aspectRatio, imagePath)
            
            if (jobId == null) {
                return ToolResult.failure(
                    toolName = name,
                    error = "Failed to start video generation. Please try again."
                )
            }
            
            Log.d(TAG, "Video generation started with job ID: $jobId")
            
            // Poll for completion
            val videoUrl = pollForCompletion(jobId)
            
            if (videoUrl != null) {
                // Download video
                val videoPath = downloadVideo(videoUrl)
                
                if (videoPath != null) {
                    ToolResult.success(
                        toolName = name,
                        result = "Video generated successfully. Saved to: $videoPath",
                        data = mapOf(
                            "video_path" to videoPath,
                            "video_url" to videoUrl,
                            "model" to model,
                            "duration" to duration,
                            "aspect_ratio" to aspectRatio
                        )
                    )
                } else {
                    ToolResult.failure(
                        toolName = name,
                        error = "Video generated but download failed. URL: $videoUrl"
                    )
                }
            } else {
                ToolResult.failure(
                    toolName = name,
                    error = "Video generation timed out or failed. Please try again with a simpler prompt."
                )
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error generating video", e)
            ToolResult.failure(
                toolName = name,
                error = "Video generation error: ${e.message}"
            )
        }
    }
    
    /**
     * Start async video generation
     */
    private suspend fun startVideoGeneration(
        model: String,
        prompt: String,
        duration: Int,
        aspectRatio: String,
        imagePath: String?
    ): String? = withContext(Dispatchers.IO) {
        try {
            val provider = keyManager.getSelectedProvider() ?: return@withContext null
            val apiKey = keyManager.getApiKey(provider) ?: return@withContext null
            
            val api = OpenAICompatibleAPI(provider, apiKey, model)
            
            // Build request (format depends on provider/model)
            val requestBody = JSONObject().apply {
                put("prompt", prompt)
                put("duration", duration)
                put("aspect_ratio", aspectRatio)
                if (imagePath != null) {
                    put("image", imagePath)
                }
            }
            
            // Start generation (returns job ID)
            val response = api.generateVideo(requestBody)
            
            if (response != null) {
                val responseJson = JSONObject(response)
                // Different providers return job ID in different fields
                when {
                    responseJson.has("id") -> responseJson.getString("id")
                    responseJson.has("job_id") -> responseJson.getString("job_id")
                    responseJson.has("task_id") -> responseJson.getString("task_id")
                    else -> null
                }
            } else {
                null
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error starting video generation", e)
            null
        }
    }
    
    /**
     * Poll for video generation completion
     */
    private suspend fun pollForCompletion(jobId: String): String? {
        repeat(MAX_POLL_ATTEMPTS) { attempt ->
            try {
                val status = checkGenerationStatus(jobId)
                
                Log.d(TAG, "Poll attempt ${attempt + 1}/$MAX_POLL_ATTEMPTS: status=$status")
                
                when (status?.state) {
                    "completed", "succeeded", "success" -> {
                        return status.videoUrl
                    }
                    "failed", "error" -> {
                        Log.e(TAG, "Video generation failed: ${status.error}")
                        return null
                    }
                    "processing", "pending", "in_progress" -> {
                        // Continue polling
                        delay(POLL_INTERVAL_MS)
                    }
                    else -> {
                        // Unknown status, continue polling
                        delay(POLL_INTERVAL_MS)
                    }
                }
                
            } catch (e: Exception) {
                Log.e(TAG, "Error polling for completion", e)
                delay(POLL_INTERVAL_MS)
            }
        }
        
        Log.e(TAG, "Video generation timed out after ${MAX_POLL_ATTEMPTS * POLL_INTERVAL_MS / 1000} seconds")
        return null
    }
    
    /**
     * Check video generation status
     */
    private suspend fun checkGenerationStatus(jobId: String): GenerationStatus? = withContext(Dispatchers.IO) {
        try {
            val provider = keyManager.getSelectedProvider() ?: return@withContext null
            val apiKey = keyManager.getApiKey(provider) ?: return@withContext null
            
            val api = OpenAICompatibleAPI(provider, apiKey, "temp")
            val response = api.checkVideoStatus(jobId)
            
            if (response != null) {
                val responseJson = JSONObject(response)
                
                val state = when {
                    responseJson.has("status") -> responseJson.getString("status")
                    responseJson.has("state") -> responseJson.getString("state")
                    else -> "unknown"
                }
                
                val videoUrl = when {
                    responseJson.has("url") -> responseJson.getString("url")
                    responseJson.has("video_url") -> responseJson.getString("video_url")
                    responseJson.has("output") -> responseJson.getString("output")
                    else -> null
                }
                
                val error = if (responseJson.has("error")) {
                    responseJson.getString("error")
                } else null
                
                GenerationStatus(state, videoUrl, error)
            } else {
                null
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error checking status", e)
            null
        }
    }
    
    /**
     * Download video from URL
     */
    private suspend fun downloadVideo(url: String): String? = withContext(Dispatchers.IO) {
        try {
            val request = Request.Builder()
                .url(url)
                .build()
            
            val response = httpClient.newCall(request).execute()
            
            if (response.isSuccessful) {
                val videoData = response.body?.bytes() ?: return@withContext null
                
                // Create cache directory
                val cacheDir = File(context.cacheDir, VIDEO_CACHE_DIR)
                if (!cacheDir.exists()) {
                    cacheDir.mkdirs()
                }
                
                // Save video
                val filename = "video_${UUID.randomUUID()}.mp4"
                val videoFile = File(cacheDir, filename)
                videoFile.writeBytes(videoData)
                
                Log.d(TAG, "Video downloaded to: ${videoFile.absolutePath}")
                videoFile.absolutePath
            } else {
                Log.e(TAG, "Failed to download video: ${response.code}")
                null
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error downloading video", e)
            null
        }
    }
    
    /**
     * Video generation status
     */
    private data class GenerationStatus(
        val state: String,
        val videoUrl: String?,
        val error: String?
    )
}

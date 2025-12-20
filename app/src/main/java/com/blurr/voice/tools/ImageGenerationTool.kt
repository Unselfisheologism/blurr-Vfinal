package com.twent.voice.tools

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Base64
import android.util.Log
import com.twent.voice.core.providers.OpenAICompatibleAPI
import com.twent.voice.core.providers.ProviderKeyManager
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.OkHttpClient
import okhttp3.Request
import org.json.JSONObject
import java.io.File
import java.io.FileOutputStream
import java.util.UUID

/**
 * Image Generation Tool
 * 
 * Generates images from text descriptions using available image models
 * from the configured provider (Flux, Stable Diffusion, DALL-E, etc.)
 * 
 * Provider Support:
 * - OpenRouter: Flux, DALL-E, SD3, SDXL
 * - AIMLAPI: Flux, SD3, DALL-E, Midjourney
 * - Together AI: Flux models
 * - Others: Varies
 */
class ImageGenerationTool(
    private val context: Context
) : BaseTool() {
    
    companion object {
        private const val TAG = "ImageGenerationTool"
        private const val IMAGE_CACHE_DIR = "generated_images"
    }
    
    private val keyManager = ProviderKeyManager(context)
    private val modelChecker = MediaModelChecker(context)
    private val httpClient = OkHttpClient()
    
    override val name: String = "generate_image"
    
    override val description: String = 
        "Generate images from text descriptions. Can create photos, illustrations, artwork, " +
        "diagrams, logos, icons, and any visual content. Supports various styles like " +
        "realistic, anime, cartoon, 3D render, oil painting, watercolor, etc."
    
    override val parameters: List<ToolParameter> = listOf(
        ToolParameter(
            name = "prompt",
            type = "string",
            description = "Detailed description of the image to generate. Be specific about style, " +
                    "composition, colors, lighting, and subject matter.",
            required = true
        ),
        ToolParameter(
            name = "size",
            type = "string",
            description = "Image dimensions. Common sizes: '1024x1024' (square), '1024x1792' (portrait), " +
                    "'1792x1024' (landscape), '1024x576' (16:9 video thumbnail)",
            required = false,
            enum = listOf("1024x1024", "1024x1792", "1792x1024", "1024x576", "768x768", "512x512")
        ),
        ToolParameter(
            name = "style",
            type = "string",
            description = "Image style: 'realistic', 'anime', 'digital-art', '3d-render', 'oil-painting', etc.",
            required = false
        ),
        ToolParameter(
            name = "model",
            type = "string",
            description = "Specific model to use (optional). If not specified, best available model is chosen automatically.",
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
            val size: String = getOptionalParam(params, "size", "1024x1024")
            val style: String? = getOptionalParam(params, "style", null)
            val requestedModel: String? = getOptionalParam(params, "model", null)
            
            Log.d(TAG, "Generating image: prompt='$prompt', size=$size, style=$style")
            
            // Check if image generation is available
            val availability = modelChecker.checkAvailability(MediaModelChecker.MediaType.IMAGE)
            
            if (!availability.isAvailable) {
                return ToolResult.failure(
                    toolName = name,
                    error = modelChecker.getUnsupportedMessage(
                        MediaModelChecker.MediaType.IMAGE,
                        availability.providerName
                    )
                )
            }
            
            // Choose model
            val model = requestedModel 
                ?: availability.recommendedModel 
                ?: return ToolResult.failure(
                    toolName = name,
                    error = "No image generation models available"
                )
            
            Log.d(TAG, "Using model: $model")
            
            // Enhance prompt with style if specified
            val enhancedPrompt = if (style != null) {
                "$prompt, $style style"
            } else {
                prompt
            }
            
            // Generate image
            val imageData = generateImage(model, enhancedPrompt, size)
            
            if (imageData != null) {
                // Save image to local storage
                val imagePath = saveImage(imageData)
                
                ToolResult.success(
                    toolName = name,
                    result = "Image generated successfully. Saved to: $imagePath",
                    data = mapOf(
                        "image_path" to imagePath,
                        "model" to model,
                        "size" to size,
                        "prompt" to enhancedPrompt
                    )
                )
            } else {
                ToolResult.failure(
                    toolName = name,
                    error = "Image generation failed. Please try again with a different prompt."
                )
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error generating image", e)
            ToolResult.failure(
                toolName = name,
                error = "Image generation error: ${e.message}"
            )
        }
    }
    
    /**
     * Generate image using the provider's API
     */
    private suspend fun generateImage(
        model: String,
        prompt: String,
        size: String
    ): ByteArray? = withContext(Dispatchers.IO) {
        try {
            val provider = keyManager.getSelectedProvider() ?: return@withContext null
            val apiKey = keyManager.getApiKey(provider) ?: return@withContext null
            
            val api = OpenAICompatibleAPI(provider, apiKey, model)
            
            // Build image generation request
            val requestBody = JSONObject().apply {
                put("prompt", prompt)
                put("size", size)
                put("n", 1) // Generate 1 image
                put("response_format", "url") // Get URL (some providers support b64_json)
            }
            
            // Make API request
            val response = api.generateImage(requestBody)
            
            if (response != null) {
                // Parse response
                val responseJson = JSONObject(response)
                val dataArray = responseJson.getJSONArray("data")
                
                if (dataArray.length() > 0) {
                    val imageData = dataArray.getJSONObject(0)
                    
                    // Check if response has URL or base64
                    when {
                        imageData.has("url") -> {
                            val imageUrl = imageData.getString("url")
                            Log.d(TAG, "Image URL received: $imageUrl")
                            return@withContext downloadImage(imageUrl)
                        }
                        imageData.has("b64_json") -> {
                            val base64Data = imageData.getString("b64_json")
                            Log.d(TAG, "Base64 image received")
                            return@withContext Base64.decode(base64Data, Base64.DEFAULT)
                        }
                    }
                }
            }
            
            null
            
        } catch (e: Exception) {
            Log.e(TAG, "Error in generateImage", e)
            null
        }
    }
    
    /**
     * Download image from URL
     */
    private suspend fun downloadImage(url: String): ByteArray? = withContext(Dispatchers.IO) {
        try {
            val request = Request.Builder()
                .url(url)
                .build()
            
            val response = httpClient.newCall(request).execute()
            
            if (response.isSuccessful) {
                response.body?.bytes()
            } else {
                Log.e(TAG, "Failed to download image: ${response.code}")
                null
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error downloading image", e)
            null
        }
    }
    
    /**
     * Save image to local storage
     */
    private suspend fun saveImage(imageData: ByteArray): String = withContext(Dispatchers.IO) {
        try {
            // Create cache directory if it doesn't exist
            val cacheDir = File(context.cacheDir, IMAGE_CACHE_DIR)
            if (!cacheDir.exists()) {
                cacheDir.mkdirs()
            }
            
            // Generate unique filename
            val filename = "image_${UUID.randomUUID()}.png"
            val imageFile = File(cacheDir, filename)
            
            // Decode and save bitmap
            val bitmap = BitmapFactory.decodeByteArray(imageData, 0, imageData.size)
            FileOutputStream(imageFile).use { out ->
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
            }
            
            Log.d(TAG, "Image saved to: ${imageFile.absolutePath}")
            imageFile.absolutePath
            
        } catch (e: Exception) {
            Log.e(TAG, "Error saving image", e)
            "Error saving image"
        }
    }
}

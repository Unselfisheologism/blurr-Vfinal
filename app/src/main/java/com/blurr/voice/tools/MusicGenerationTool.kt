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
 * Music Generation Tool
 * 
 * Generates original music from text descriptions using AI music models
 * (Suno, Udio, MusicGen, etc.)
 * 
 * Provider Support:
 * - OpenRouter: Very limited music models
 * - AIMLAPI: Suno v3/v4, Udio models
 * - Others: Rare support
 * 
 * Note: Music generation is async and can take 30s-2min
 */
class MusicGenerationTool(
    private val context: Context
) : BaseTool() {
    
    companion object {
        private const val TAG = "MusicGenerationTool"
        private const val MUSIC_CACHE_DIR = "generated_music"
        private const val MAX_POLL_ATTEMPTS = 40 // ~3 minutes at 5-second intervals
        private const val POLL_INTERVAL_MS = 5000L // 5 seconds
        
        // Common music genres
        private val GENRES = listOf(
            "pop", "rock", "electronic", "jazz", "classical", "hip-hop",
            "ambient", "cinematic", "folk", "country", "metal", "indie",
            "r&b", "soul", "reggae", "blues", "funk", "techno", "house"
        )
        
        // Common moods
        private val MOODS = listOf(
            "happy", "sad", "energetic", "calm", "dark", "uplifting",
            "mysterious", "romantic", "intense", "relaxing", "epic"
        )
    }
    
    private val keyManager = ProviderKeyManager(context)
    private val modelChecker = MediaModelChecker(context)
    private val httpClient = OkHttpClient()
    
    override val name: String = "generate_music"
    
    override val description: String = 
        "Generate original music and songs from text descriptions. Can create background music, " +
        "theme songs, jingles, soundtracks, or full songs with vocals. Supports various genres, " +
        "moods, and styles. Note: Music generation takes 30 seconds to 2 minutes."
    
    override val parameters: List<ToolParameter> = listOf(
        ToolParameter(
            name = "prompt",
            type = "string",
            description = "Detailed description of the music to generate. Include genre, mood, instruments, " +
                    "tempo, and any specific characteristics. For songs with lyrics, include the lyrics or theme.",
            required = true
        ),
        ToolParameter(
            name = "genre",
            type = "string",
            description = "Music genre: pop, rock, electronic, jazz, classical, hip-hop, ambient, etc.",
            required = false,
            enum = GENRES
        ),
        ToolParameter(
            name = "mood",
            type = "string",
            description = "Mood/emotion: happy, sad, energetic, calm, dark, uplifting, mysterious, etc.",
            required = false,
            enum = MOODS
        ),
        ToolParameter(
            name = "duration",
            type = "number",
            description = "Music duration in seconds (typically 30-180 seconds). Default: 60",
            required = false
        ),
        ToolParameter(
            name = "instrumental",
            type = "boolean",
            description = "If true, generates instrumental music without vocals. If false, may include vocals.",
            required = false
        ),
        ToolParameter(
            name = "tempo",
            type = "string",
            description = "Tempo: 'slow', 'medium', 'fast', 'very-fast'",
            required = false,
            enum = listOf("slow", "medium", "fast", "very-fast")
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
            val genre: String? = getOptionalParam(params, "genre", null)
            val mood: String? = getOptionalParam(params, "mood", null)
            val duration: Int = getOptionalParam(params, "duration", 60)
            val instrumental: Boolean = getOptionalParam(params, "instrumental", false)
            val tempo: String? = getOptionalParam(params, "tempo", null)
            
            Log.d(TAG, "Generating music: prompt='$prompt', genre=$genre, mood=$mood, " +
                    "duration=${duration}s, instrumental=$instrumental")
            
            // Check if music generation is available
            val availability = modelChecker.checkAvailability(MediaModelChecker.MediaType.MUSIC)
            
            if (!availability.isAvailable) {
                return ToolResult.failure(
                    toolName = name,
                    error = modelChecker.getUnsupportedMessage(
                        MediaModelChecker.MediaType.MUSIC,
                        availability.providerName
                    )
                )
            }
            
            // Choose model
            val model = availability.recommendedModel 
                ?: return ToolResult.failure(
                    toolName = name,
                    error = "No music generation models available"
                )
            
            Log.d(TAG, "Using music model: $model")
            
            // Enhance prompt with genre, mood, tempo
            val enhancedPrompt = buildMusicPrompt(prompt, genre, mood, tempo, instrumental)
            
            // Start music generation (async)
            val jobId = startMusicGeneration(model, enhancedPrompt, duration, instrumental)
            
            if (jobId == null) {
                return ToolResult.failure(
                    toolName = name,
                    error = "Failed to start music generation. Please try again."
                )
            }
            
            Log.d(TAG, "Music generation started with job ID: $jobId")
            
            // Poll for completion
            val musicUrl = pollForCompletion(jobId)
            
            if (musicUrl != null) {
                // Download music
                val musicPath = downloadMusic(musicUrl)
                
                if (musicPath != null) {
                    ToolResult.success(
                        toolName = name,
                        result = "Music generated successfully. Duration: ~${duration}s. Saved to: $musicPath",
                        data = mapOf(
                            "music_path" to musicPath,
                            "music_url" to musicUrl,
                            "model" to model,
                            "genre" to (genre ?: "auto"),
                            "mood" to (mood ?: "auto"),
                            "duration" to duration,
                            "instrumental" to instrumental
                        )
                    )
                } else {
                    ToolResult.failure(
                        toolName = name,
                        error = "Music generated but download failed. URL: $musicUrl"
                    )
                }
            } else {
                ToolResult.failure(
                    toolName = name,
                    error = "Music generation timed out or failed. Please try again with a simpler prompt."
                )
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error generating music", e)
            ToolResult.failure(
                toolName = name,
                error = "Music generation error: ${e.message}"
            )
        }
    }
    
    /**
     * Build enhanced music prompt with genre, mood, etc.
     */
    private fun buildMusicPrompt(
        basePrompt: String,
        genre: String?,
        mood: String?,
        tempo: String?,
        instrumental: Boolean
    ): String {
        val parts = mutableListOf(basePrompt)
        
        if (genre != null) {
            parts.add("genre: $genre")
        }
        
        if (mood != null) {
            parts.add("mood: $mood")
        }
        
        if (tempo != null) {
            parts.add("tempo: $tempo")
        }
        
        if (instrumental) {
            parts.add("instrumental, no vocals")
        }
        
        return parts.joinToString(", ")
    }
    
    /**
     * Start async music generation
     */
    private suspend fun startMusicGeneration(
        model: String,
        prompt: String,
        duration: Int,
        instrumental: Boolean
    ): String? = withContext(Dispatchers.IO) {
        try {
            val provider = keyManager.getSelectedProvider() ?: return@withContext null
            val apiKey = keyManager.getApiKey(provider) ?: return@withContext null
            
            val api = OpenAICompatibleAPI(provider, apiKey, model)
            
            // Build request
            val requestBody = JSONObject().apply {
                put("prompt", prompt)
                put("duration", duration)
                put("make_instrumental", instrumental)
            }
            
            // Start generation (returns job ID)
            val response = api.generateMusic(requestBody)
            
            if (response != null) {
                val responseJson = JSONObject(response)
                // Different providers return job ID in different fields
                when {
                    responseJson.has("id") -> responseJson.getString("id")
                    responseJson.has("job_id") -> responseJson.getString("job_id")
                    responseJson.has("clip_id") -> responseJson.getString("clip_id")
                    else -> null
                }
            } else {
                null
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error starting music generation", e)
            null
        }
    }
    
    /**
     * Poll for music generation completion
     */
    private suspend fun pollForCompletion(jobId: String): String? {
        repeat(MAX_POLL_ATTEMPTS) { attempt ->
            try {
                val status = checkGenerationStatus(jobId)
                
                Log.d(TAG, "Poll attempt ${attempt + 1}/$MAX_POLL_ATTEMPTS: status=$status")
                
                when (status?.state) {
                    "completed", "succeeded", "success", "complete" -> {
                        return status.musicUrl
                    }
                    "failed", "error" -> {
                        Log.e(TAG, "Music generation failed: ${status.error}")
                        return null
                    }
                    "processing", "pending", "in_progress", "queued" -> {
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
        
        Log.e(TAG, "Music generation timed out after ${MAX_POLL_ATTEMPTS * POLL_INTERVAL_MS / 1000} seconds")
        return null
    }
    
    /**
     * Check music generation status
     */
    private suspend fun checkGenerationStatus(jobId: String): GenerationStatus? = withContext(Dispatchers.IO) {
        try {
            val provider = keyManager.getSelectedProvider() ?: return@withContext null
            val apiKey = keyManager.getApiKey(provider) ?: return@withContext null
            
            val api = OpenAICompatibleAPI(provider, apiKey, "temp")
            val response = api.checkMusicStatus(jobId)
            
            if (response != null) {
                val responseJson = JSONObject(response)
                
                val state = when {
                    responseJson.has("status") -> responseJson.getString("status")
                    responseJson.has("state") -> responseJson.getString("state")
                    else -> "unknown"
                }
                
                val musicUrl = when {
                    responseJson.has("audio_url") -> responseJson.getString("audio_url")
                    responseJson.has("url") -> responseJson.getString("url")
                    responseJson.has("output") -> responseJson.getString("output")
                    responseJson.has("clip_url") -> responseJson.getString("clip_url")
                    else -> null
                }
                
                val error = if (responseJson.has("error")) {
                    responseJson.getString("error")
                } else null
                
                GenerationStatus(state, musicUrl, error)
            } else {
                null
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error checking status", e)
            null
        }
    }
    
    /**
     * Download music from URL
     */
    private suspend fun downloadMusic(url: String): String? = withContext(Dispatchers.IO) {
        try {
            val request = Request.Builder()
                .url(url)
                .build()
            
            val response = httpClient.newCall(request).execute()
            
            if (response.isSuccessful) {
                val musicData = response.body?.bytes() ?: return@withContext null
                
                // Create cache directory
                val cacheDir = File(context.cacheDir, MUSIC_CACHE_DIR)
                if (!cacheDir.exists()) {
                    cacheDir.mkdirs()
                }
                
                // Save music
                val filename = "music_${UUID.randomUUID()}.mp3"
                val musicFile = File(cacheDir, filename)
                musicFile.writeBytes(musicData)
                
                Log.d(TAG, "Music downloaded to: ${musicFile.absolutePath}")
                musicFile.absolutePath
            } else {
                Log.e(TAG, "Failed to download music: ${response.code}")
                null
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error downloading music", e)
            null
        }
    }
    
    /**
     * Music generation status
     */
    private data class GenerationStatus(
        val state: String,
        val musicUrl: String?,
        val error: String?
    )
}

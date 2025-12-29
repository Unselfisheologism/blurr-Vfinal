package com.blurr.voice.tools

import android.content.Context
import android.util.Log
import com.blurr.voice.core.providers.OpenAICompatibleAPI
import com.blurr.voice.core.providers.ProviderKeyManager
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.OkHttpClient
import okhttp3.Request
import org.json.JSONObject
import java.io.File
import java.util.UUID

/**
 * Audio Generation Tool (Text-to-Speech)
 * 
 * Generates natural-sounding speech from text using TTS models.
 * Useful for voiceovers, narration, accessibility, podcasts, audiobooks, etc.
 * 
 * Provider Support:
 * - OpenRouter: OpenAI TTS models (tts-1, tts-1-hd)
 * - AIMLAPI: ElevenLabs, OpenAI, Azure TTS models
 * - Groq: Limited TTS support
 * - Together AI: Some TTS models
 */
class AudioGenerationTool(
    private val context: Context
) : BaseTool() {
    
    companion object {
        private const val TAG = "AudioGenerationTool"
        private const val AUDIO_CACHE_DIR = "generated_audio"
        
        // Common voice options (OpenAI TTS voices)
        private val COMMON_VOICES = listOf("alloy", "echo", "fable", "onyx", "nova", "shimmer")
    }
    
    private val keyManager = ProviderKeyManager(context)
    private val modelChecker = MediaModelChecker(context)
    private val httpClient = OkHttpClient()
    
    override val name: String = "generate_audio"
    
    override val description: String = 
        "Generate natural-sounding speech from text. Perfect for voiceovers, narration, " +
        "audio content, accessibility features, podcasts, audiobooks, and more. " +
        "Supports multiple voices, languages, and speech styles."
    
    override val parameters: List<ToolParameter> = listOf(
        ToolParameter(
            name = "text",
            type = "string",
            description = "The text to convert to speech. Can be multiple paragraphs.",
            required = true
        ),
        ToolParameter(
            name = "voice",
            type = "string",
            description = "Voice selection: 'alloy' (neutral), 'echo' (male), 'fable' (British male), " +
                    "'onyx' (deep male), 'nova' (young female), 'shimmer' (soft female)",
            required = false,
            enum = COMMON_VOICES
        ),
        ToolParameter(
            name = "speed",
            type = "number",
            description = "Speech speed from 0.25 (very slow) to 4.0 (very fast). Default: 1.0 (normal)",
            required = false
        ),
        ToolParameter(
            name = "language",
            type = "string",
            description = "Language code (e.g., 'en', 'es', 'fr', 'de', 'ja', 'zh'). Auto-detected if not specified.",
            required = false
        ),
        ToolParameter(
            name = "output_format",
            type = "string",
            description = "Audio format: 'mp3', 'wav', 'opus', 'aac', 'flac'",
            required = false,
            enum = listOf("mp3", "wav", "opus", "aac", "flac")
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
            val text: String = getRequiredParam(params, "text")
            val voice: String = getOptionalParam(params, "voice", "alloy")
            val speed: Double = getOptionalParam(params, "speed", 1.0)
            val language: String? = getOptionalParam(params, "language", null)
            val outputFormat: String = getOptionalParam(params, "output_format", "mp3")
            
            // Validate speed
            if (speed < 0.25 || speed > 4.0) {
                return ToolResult.failure(
                    toolName = name,
                    error = "Speed must be between 0.25 and 4.0"
                )
            }
            
            Log.d(TAG, "Generating audio: text_length=${text.length}, voice=$voice, " +
                    "speed=$speed, language=$language, format=$outputFormat")
            
            // Check if TTS is available
            val availability = modelChecker.checkAvailability(MediaModelChecker.MediaType.AUDIO_TTS)
            
            if (!availability.isAvailable) {
                return ToolResult.failure(
                    toolName = name,
                    error = modelChecker.getUnsupportedMessage(
                        MediaModelChecker.MediaType.AUDIO_TTS,
                        availability.providerName
                    )
                )
            }
            
            // Choose model
            val model = availability.recommendedModel 
                ?: return ToolResult.failure(
                    toolName = name,
                    error = "No TTS models available"
                )
            
            Log.d(TAG, "Using TTS model: $model")
            
            // Generate audio
            val audioData = generateAudio(model, text, voice, speed, language, outputFormat)
            
            if (audioData != null) {
                // Save audio file
                val audioPath = saveAudio(audioData, outputFormat)
                
                ToolResult.success(
                    toolName = name,
                    result = "Audio generated successfully. Duration: ~${estimateDuration(text, speed)} seconds. " +
                            "Saved to: $audioPath",
                    data = mapOf(
                        "audio_path" to audioPath,
                        "model" to model,
                        "voice" to voice,
                        "speed" to speed,
                        "format" to outputFormat,
                        "text_length" to text.length,
                        "estimated_duration" to estimateDuration(text, speed)
                    )
                )
            } else {
                ToolResult.failure(
                    toolName = name,
                    error = "Audio generation failed. Please try again or use a different voice."
                )
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error generating audio", e)
            ToolResult.failure(
                toolName = name,
                error = "Audio generation error: ${e.message}"
            )
        }
    }
    
    /**
     * Generate audio using TTS API
     */
    private suspend fun generateAudio(
        model: String,
        text: String,
        voice: String,
        speed: Double,
        language: String?,
        outputFormat: String
    ): ByteArray? = withContext(Dispatchers.IO) {
        try {
            val provider = keyManager.getSelectedProvider() ?: return@withContext null
            val apiKey = keyManager.getApiKey(provider) ?: return@withContext null
            
            val api = OpenAICompatibleAPI(provider, apiKey, model)
            
            // Build TTS request (OpenAI-compatible format)
            val requestBody = JSONObject().apply {
                put("model", model)
                put("input", text)
                put("voice", voice)
                put("speed", speed)
                put("response_format", outputFormat)
                if (language != null) {
                    put("language", language)
                }
            }
            
            // Make API request
            val response = api.generateAudio(requestBody)
            
            if (response != null) {
                // Response is typically raw audio bytes
                response.toByteArray()
            } else {
                null
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error in generateAudio", e)
            null
        }
    }
    
    /**
     * Save audio to local storage
     */
    private suspend fun saveAudio(
        audioData: ByteArray,
        format: String
    ): String = withContext(Dispatchers.IO) {
        try {
            // Create cache directory
            val cacheDir = File(context.cacheDir, AUDIO_CACHE_DIR)
            if (!cacheDir.exists()) {
                cacheDir.mkdirs()
            }
            
            // Generate unique filename
            val filename = "audio_${UUID.randomUUID()}.$format"
            val audioFile = File(cacheDir, filename)
            
            // Save audio
            audioFile.writeBytes(audioData)
            
            Log.d(TAG, "Audio saved to: ${audioFile.absolutePath}")
            audioFile.absolutePath
            
        } catch (e: Exception) {
            Log.e(TAG, "Error saving audio", e)
            "Error saving audio"
        }
    }
    
    /**
     * Estimate audio duration based on text length and speed
     * Rough estimate: ~150 words per minute at normal speed
     */
    private fun estimateDuration(text: String, speed: Double): Int {
        val wordCount = text.split("\\s+".toRegex()).size
        val baseWPM = 150.0 // words per minute at speed 1.0
        val adjustedWPM = baseWPM * speed
        val durationMinutes = wordCount / adjustedWPM
        return (durationMinutes * 60).toInt() // Convert to seconds
    }
}

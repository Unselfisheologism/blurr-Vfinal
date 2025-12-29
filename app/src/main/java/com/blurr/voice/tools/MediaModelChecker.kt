package com.blurr.voice.tools

import android.content.Context
import android.util.Log
import com.blurr.voice.core.providers.LLMProvider
import com.blurr.voice.core.providers.OpenAICompatibleAPI
import com.blurr.voice.core.providers.ProviderKeyManager

/**
 * Utility to check which media generation models are available from the configured provider
 * 
 * Different providers support different types of media generation:
 * - Images: Most providers (DALL-E, Flux, SD3, etc.)
 * - Video: Limited (AIMLAPI has Runway, Luma, Kling)
 * - Audio/TTS: Common (OpenAI TTS, ElevenLabs, Azure)
 * - Music: Very limited (AIMLAPI has Suno, Udio)
 * - 3D: Rare (AIMLAPI may have Meshy)
 */
class MediaModelChecker(
    private val context: Context
) {
    companion object {
        private const val TAG = "MediaModelChecker"
        
        // Model type identifiers
        private val IMAGE_MODEL_KEYWORDS = listOf(
            "dall-e", "dalle", "flux", "stable-diffusion", "sd3", "sdxl", 
            "midjourney", "imagen", "firefly"
        )
        
        private val VIDEO_MODEL_KEYWORDS = listOf(
            "runway", "luma", "kling", "pika", "stable-video", "gen-2", "gen-3"
        )
        
        private val AUDIO_TTS_MODEL_KEYWORDS = listOf(
            "tts", "text-to-speech", "eleven", "elevenlabs", "azure-tts", 
            "google-tts", "whisper" // Note: Whisper is STT but often bundled with TTS
        )
        
        private val MUSIC_MODEL_KEYWORDS = listOf(
            "suno", "udio", "musicgen", "audiocraft", "riffusion"
        )
        
        private val MODEL_3D_KEYWORDS = listOf(
            "meshy", "shap-e", "point-e", "3d", "three-d"
        )
    }
    
    private val keyManager = ProviderKeyManager(context)
    
    /**
     * Media type enum
     */
    enum class MediaType {
        IMAGE,
        VIDEO,
        AUDIO_TTS,
        MUSIC,
        MODEL_3D
    }
    
    /**
     * Result of availability check
     */
    data class MediaAvailability(
        val isAvailable: Boolean,
        val availableModels: List<String>,
        val recommendedModel: String?,
        val providerName: String
    )
    
    /**
     * Check if a specific media type is supported by the current provider
     */
    suspend fun checkAvailability(mediaType: MediaType): MediaAvailability {
        return try {
            val provider = keyManager.getSelectedProvider()
            val apiKey = keyManager.getApiKey(provider)
            
            if (provider == null || apiKey == null) {
                return MediaAvailability(
                    isAvailable = false,
                    availableModels = emptyList(),
                    recommendedModel = null,
                    providerName = "None"
                )
            }
            
            // Get available models from provider
            val api = OpenAICompatibleAPI(provider, apiKey, "temp")
            val allModels = api.getAvailableModels() ?: emptyList()
            
            // Filter models by type
            val keywords = when (mediaType) {
                MediaType.IMAGE -> IMAGE_MODEL_KEYWORDS
                MediaType.VIDEO -> VIDEO_MODEL_KEYWORDS
                MediaType.AUDIO_TTS -> AUDIO_TTS_MODEL_KEYWORDS
                MediaType.MUSIC -> MUSIC_MODEL_KEYWORDS
                MediaType.MODEL_3D -> MODEL_3D_KEYWORDS
            }
            
            val matchingModels = allModels.filter { model ->
                keywords.any { keyword -> 
                    model.contains(keyword, ignoreCase = true) 
                }
            }
            
            // Get recommended model (usually the first/best one)
            val recommended = getRecommendedModel(matchingModels, mediaType)
            
            Log.d(TAG, "Media type: $mediaType, Provider: ${provider.name}, " +
                    "Available: ${matchingModels.isNotEmpty()}, Models: $matchingModels")
            
            MediaAvailability(
                isAvailable = matchingModels.isNotEmpty(),
                availableModels = matchingModels,
                recommendedModel = recommended,
                providerName = provider.name
            )
            
        } catch (e: Exception) {
            Log.e(TAG, "Error checking media availability", e)
            MediaAvailability(
                isAvailable = false,
                availableModels = emptyList(),
                recommendedModel = null,
                providerName = "Error"
            )
        }
    }
    
    /**
     * Get recommended model for a media type from available models
     */
    private fun getRecommendedModel(models: List<String>, mediaType: MediaType): String? {
        if (models.isEmpty()) return null
        
        // Priority order for each media type
        val priorityKeywords = when (mediaType) {
            MediaType.IMAGE -> listOf("flux-1.1-pro", "flux-pro", "dall-e-3", "sd3", "sdxl")
            MediaType.VIDEO -> listOf("runway-gen3", "luma", "kling", "runway")
            MediaType.AUDIO_TTS -> listOf("elevenlabs", "tts-1-hd", "tts-1", "azure")
            MediaType.MUSIC -> listOf("suno-v3", "suno", "udio")
            MediaType.MODEL_3D -> listOf("meshy")
        }
        
        // Find best match based on priority
        for (keyword in priorityKeywords) {
            val match = models.find { it.contains(keyword, ignoreCase = true) }
            if (match != null) return match
        }
        
        // Return first model if no priority match
        return models.firstOrNull()
    }
    
    /**
     * Check all media types and return support matrix
     */
    suspend fun checkAllMediaTypes(): Map<MediaType, MediaAvailability> {
        return MediaType.values().associateWith { mediaType ->
            checkAvailability(mediaType)
        }
    }
    
    /**
     * Get provider-specific fallback models (when model list fetch fails)
     */
    fun getFallbackModel(mediaType: MediaType, provider: LLMProvider): String? {
        return when (provider) {
            LLMProvider.OPENROUTER -> when (mediaType) {
                MediaType.IMAGE -> "black-forest-labs/flux-1.1-pro"
                MediaType.AUDIO_TTS -> "openai/tts-1"
                else -> null // OpenRouter doesn't support video, music, 3D
            }
            
            LLMProvider.AIMLAPI -> when (mediaType) {
                MediaType.IMAGE -> "flux/flux-1.1-pro"
                MediaType.VIDEO -> "luma/ray"
                MediaType.AUDIO_TTS -> "elevenlabs/eleven-multilingual-v2"
                MediaType.MUSIC -> "suno/v3"
                MediaType.MODEL_3D -> "meshy/meshy-3"
            }
            
            LLMProvider.GROQ -> when (mediaType) {
                MediaType.AUDIO_TTS -> "whisper-large-v3" // Groq has Whisper (STT)
                else -> null
            }
            
            LLMProvider.TOGETHER -> when (mediaType) {
                MediaType.IMAGE -> "black-forest-labs/FLUX.1-schnell"
                else -> null
            }
            
            else -> null
        }
    }
    
    /**
     * Get user-friendly error message when media type not supported
     */
    fun getUnsupportedMessage(mediaType: MediaType, providerName: String): String {
        return when (mediaType) {
            MediaType.IMAGE -> 
                "Image generation is not available with $providerName. Try using OpenRouter or AIMLAPI."
            
            MediaType.VIDEO -> 
                "Video generation is not available with $providerName. " +
                "AIMLAPI has Runway, Luma, and Kling video models. Please switch to AIMLAPI."
            
            MediaType.AUDIO_TTS -> 
                "Text-to-speech is not available with $providerName. " +
                "Try using OpenRouter (OpenAI TTS) or AIMLAPI (ElevenLabs)."
            
            MediaType.MUSIC -> 
                "Music generation is not available with $providerName. " +
                "AIMLAPI has Suno and Udio models. Please switch to AIMLAPI."
            
            MediaType.MODEL_3D -> 
                "3D model generation is not available with $providerName. " +
                "This feature is rarely supported. AIMLAPI may have Meshy models."
        }
    }
}

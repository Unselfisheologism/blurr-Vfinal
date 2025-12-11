package com.blurr.voice.core.providers

/**
 * Voice provider capabilities for STT and TTS
 */
data class VoiceCapabilities(
    val supportsSTT: Boolean,
    val supportsTTS: Boolean,
    val sttModels: List<String>,
    val ttsModels: List<String>,
    val ttsVoices: List<String>
)

/**
 * Voice provider configuration
 */
object VoiceProviderConfig {
    
    /**
     * Gets voice capabilities for a provider
     */
    fun getCapabilities(provider: LLMProvider): VoiceCapabilities {
        return when (provider) {
            LLMProvider.OPENAI -> VoiceCapabilities(
                supportsSTT = true,
                supportsTTS = true,
                sttModels = listOf("whisper-1"),
                ttsModels = listOf("tts-1", "tts-1-hd"),
                ttsVoices = listOf("alloy", "echo", "fable", "onyx", "nova", "shimmer")
            )
            LLMProvider.AIMLAPI -> VoiceCapabilities(
                supportsSTT = true,
                supportsTTS = true,
                sttModels = listOf("whisper-1", "whisper-large-v3"),
                ttsModels = listOf("tts-1"),
                ttsVoices = listOf("alloy", "echo", "fable", "onyx", "nova", "shimmer")
            )
            LLMProvider.GROQ -> VoiceCapabilities(
                supportsSTT = true,
                supportsTTS = false,
                sttModels = listOf("whisper-large-v3", "distil-whisper-large-v3-en"),
                ttsModels = emptyList(),
                ttsVoices = emptyList()
            )
            else -> VoiceCapabilities(
                supportsSTT = false,
                supportsTTS = false,
                sttModels = emptyList(),
                ttsModels = emptyList(),
                ttsVoices = emptyList()
            )
        }
    }
    
    /**
     * Default STT model for each provider
     */
    fun getDefaultSTTModel(provider: LLMProvider): String? {
        return getCapabilities(provider).sttModels.firstOrNull()
    }
    
    /**
     * Default TTS model for each provider
     */
    fun getDefaultTTSModel(provider: LLMProvider): String? {
        return getCapabilities(provider).ttsModels.firstOrNull()
    }
    
    /**
     * Default voice for TTS
     */
    fun getDefaultTTSVoice(provider: LLMProvider): String? {
        return getCapabilities(provider).ttsVoices.firstOrNull()
    }
}

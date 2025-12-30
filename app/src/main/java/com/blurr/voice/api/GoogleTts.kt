package com.blurr.voice.api

import android.content.Context
import com.blurr.voice.core.providers.UniversalTTSService
import kotlinx.coroutines.runBlocking

/**
 * Legacy GoogleTts wrapper for backward compatibility
 * Now uses UniversalTTSService under the hood
 */
object GoogleTts {
    
    private var ttsService: UniversalTTSService? = null
    
    /**
     * Initialize with context
     */
    fun initialize(context: Context) {
        ttsService = UniversalTTSService(context)
    }
    
    /**
     * Synthesize speech from text
     * @param text Text to synthesize
     * @param voice Voice to use
     * @return Audio data as ByteArray or empty array on failure
     */
    fun synthesize(text: String, voice: TTSVoice): ByteArray {
        val service = ttsService ?: throw IllegalStateException("GoogleTts not initialized")
        
        return runBlocking {
            service.synthesize(text, voice.voiceName) ?: ByteArray(0)
        }
    }
    
    /**
     * Synthesize speech from text with default voice
     */
    fun synthesize(text: String): ByteArray {
        return synthesize(text, TTSVoice.ALLOY)
    }
}

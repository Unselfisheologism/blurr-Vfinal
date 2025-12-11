package com.blurr.voice.core.providers

import android.content.Context
import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import java.util.concurrent.TimeUnit

/**
 * Universal Text-to-Speech service using BYOK architecture
 * Supports OpenAI, AIMLAPI TTS APIs
 */
class UniversalTTSService(private val context: Context) {
    
    companion object {
        private const val TAG = "UniversalTTSService"
    }
    
    private val keyManager = ProviderKeyManager(context)
    
    private val client = OkHttpClient.Builder()
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(60, TimeUnit.SECONDS)
        .writeTimeout(60, TimeUnit.SECONDS)
        .build()
    
    /**
     * Synthesizes speech from text using user's configured provider
     * @param text Text to synthesize
     * @param voice Voice name (e.g., "alloy", "nova")
     * @return Audio data as ByteArray (MP3 format) or null on failure
     */
    suspend fun synthesize(text: String, voice: String? = null): ByteArray? = withContext(Dispatchers.IO) {
        val provider = keyManager.getSelectedProvider()
        if (provider == null) {
            Log.e(TAG, "No provider selected")
            return@withContext null
        }
        
        val apiKey = keyManager.getApiKey(provider)
        if (apiKey.isNullOrBlank()) {
            Log.e(TAG, "No API key for provider: ${provider.displayName}")
            return@withContext null
        }
        
        val capabilities = VoiceProviderConfig.getCapabilities(provider)
        if (!capabilities.supportsTTS) {
            Log.e(TAG, "Provider ${provider.displayName} does not support TTS")
            return@withContext null
        }
        
        val model = VoiceProviderConfig.getDefaultTTSModel(provider) ?: "tts-1"
        val selectedVoice = voice ?: VoiceProviderConfig.getDefaultTTSVoice(provider) ?: "alloy"
        
        try {
            val url = when (provider) {
                LLMProvider.OPENAI -> "https://api.openai.com/v1/audio/speech"
                LLMProvider.AIMLAPI -> "https://api.aimlapi.com/v1/audio/speech"
                else -> {
                    Log.e(TAG, "TTS not supported for provider: ${provider.displayName}")
                    return@withContext null
                }
            }
            
            val requestBody = JSONObject().apply {
                put("model", model)
                put("input", text)
                put("voice", selectedVoice)
            }.toString()
            
            val request = Request.Builder()
                .url(url)
                .addHeader("Authorization", "Bearer $apiKey")
                .addHeader("Content-Type", "application/json")
                .post(requestBody.toRequestBody("application/json".toMediaType()))
                .build()
            
            Log.d(TAG, "Synthesizing with ${provider.displayName} (model: $model, voice: $selectedVoice)")
            
            val response = client.newCall(request).execute()
            
            if (response.isSuccessful) {
                val audioData = response.body?.bytes()
                if (audioData != null) {
                    Log.d(TAG, "TTS successful: ${audioData.size} bytes")
                    return@withContext audioData
                }
            } else {
                val errorBody = response.body?.string()
                Log.e(TAG, "TTS API Error (${response.code}): $errorBody")
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "TTS failed", e)
        }
        
        return@withContext null
    }
    
    /**
     * Gets available voices for the current provider
     */
    fun getAvailableVoices(): List<String> {
        val provider = keyManager.getSelectedProvider() ?: return emptyList()
        return VoiceProviderConfig.getCapabilities(provider).ttsVoices
    }
}

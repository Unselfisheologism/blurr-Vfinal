package com.blurr.voice.core.providers

import android.content.Context
import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.MultipartBody
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.asRequestBody
import org.json.JSONObject
import java.io.File
import java.util.concurrent.TimeUnit

/**
 * Universal Speech-to-Text service using BYOK architecture
 * Supports OpenAI, AIMLAPI, Groq Whisper APIs
 */
class UniversalSTTService(private val context: Context) {
    
    companion object {
        private const val TAG = "UniversalSTTService"
    }
    
    private val keyManager = ProviderKeyManager(context)
    
    private val client = OkHttpClient.Builder()
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(60, TimeUnit.SECONDS)
        .writeTimeout(60, TimeUnit.SECONDS)
        .build()
    
    /**
     * Transcribes audio file to text using user's configured provider
     * @param audioFile Audio file (WAV, MP3, M4A, etc.)
     * @param language Optional language code (e.g., "en")
     * @return Transcribed text or null on failure
     */
    suspend fun transcribe(audioFile: File, language: String = "en"): String? = withContext(Dispatchers.IO) {
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
        if (!capabilities.supportsSTT) {
            Log.e(TAG, "Provider ${provider.displayName} does not support STT")
            return@withContext null
        }
        
        val model = VoiceProviderConfig.getDefaultSTTModel(provider) ?: "whisper-1"
        
        try {
            val url = when (provider) {
                LLMProvider.OPENAI -> "https://api.openai.com/v1/audio/transcriptions"
                LLMProvider.AIMLAPI -> "https://api.aimlapi.com/v1/audio/transcriptions"
                LLMProvider.GROQ -> "https://api.groq.com/openai/v1/audio/transcriptions"
                else -> {
                    Log.e(TAG, "STT not supported for provider: ${provider.displayName}")
                    return@withContext null
                }
            }
            
            val requestBody = MultipartBody.Builder()
                .setType(MultipartBody.FORM)
                .addFormDataPart(
                    "file",
                    audioFile.name,
                    audioFile.asRequestBody("audio/*".toMediaType())
                )
                .addFormDataPart("model", model)
                .addFormDataPart("language", language)
                .build()
            
            val request = Request.Builder()
                .url(url)
                .addHeader("Authorization", "Bearer $apiKey")
                .post(requestBody)
                .build()
            
            Log.d(TAG, "Transcribing with ${provider.displayName} (model: $model)")
            
            val response = client.newCall(request).execute()
            
            if (response.isSuccessful) {
                val responseBody = response.body?.string()
                if (responseBody != null) {
                    val json = JSONObject(responseBody)
                    val text = json.getString("text")
                    Log.d(TAG, "Transcription successful: ${text.take(100)}...")
                    return@withContext text
                }
            } else {
                val errorBody = response.body?.string()
                Log.e(TAG, "STT API Error (${response.code}): $errorBody")
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Transcription failed", e)
        }
        
        return@withContext null
    }
}

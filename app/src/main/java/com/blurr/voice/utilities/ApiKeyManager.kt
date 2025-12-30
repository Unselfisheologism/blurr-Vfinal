package com.blurr.voice.utilities

import android.content.Context
import com.blurr.voice.core.providers.LLMProvider
import com.blurr.voice.core.providers.ProviderKeyManager

/**
 * Legacy ApiKeyManager for backward compatibility
 * Wraps ProviderKeyManager for BYOK architecture
 */
class ApiKeyManager(private val context: Context) {
    
    private val providerKeyManager = ProviderKeyManager(context)
    
    companion object {
        // Legacy constants for proxy (now unused)
        const val GCLOUD_PROXY_URL = ""
        const val GCLOUD_PROXY_URL_KEY = ""
        
        private var instance: ApiKeyManager? = null
        
        fun getInstance(context: Context): ApiKeyManager {
            if (instance == null) {
                instance = ApiKeyManager(context.applicationContext)
            }
            return instance!!
        }
    }
    
    /**
     * Get next API key (returns key for selected provider)
     */
    fun getNextKey(): String {
        val provider = providerKeyManager.getSelectedProvider() ?: LLMProvider.OPENAI
        return providerKeyManager.getApiKey(provider) ?: ""
    }
    
    /**
     * Get API key for specific provider
     */
    fun getApiKey(provider: LLMProvider): String? {
        return providerKeyManager.getApiKey(provider)
    }
}

package com.blurr.voice.core.providers

import android.content.Context
import android.content.SharedPreferences
import android.util.Log
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey

/**
 * Manages encrypted storage of API keys for different providers using BYOK architecture.
 * Keys are stored using Android's EncryptedSharedPreferences for security.
 */
class ProviderKeyManager(private val context: Context) {
    
    companion object {
        private const val TAG = "ProviderKeyManager"
        private const val PREFS_FILE_NAME = "byok_encrypted_keys"
        private const val KEY_SELECTED_PROVIDER = "selected_llm_provider"
        private const val KEY_SELECTED_MODEL = "selected_model"
        
        // Key prefixes for different provider keys
        private const val PREFIX_API_KEY = "api_key_"
        private const val PREFIX_SELECTED_MODEL = "model_"
    }
    
    private val encryptedPrefs: SharedPreferences by lazy {
        try {
            val masterKey = MasterKey.Builder(context)
                .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
                .build()
            
            EncryptedSharedPreferences.create(
                context,
                PREFS_FILE_NAME,
                masterKey,
                EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
                EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
            )
        } catch (e: Exception) {
            Log.e(TAG, "Failed to create EncryptedSharedPreferences, falling back to regular SharedPreferences", e)
            // Fallback to regular SharedPreferences if encryption fails
            context.getSharedPreferences(PREFS_FILE_NAME, Context.MODE_PRIVATE)
        }
    }
    
    /**
     * Saves an API key for a specific provider
     */
    fun saveApiKey(provider: LLMProvider, apiKey: String) {
        encryptedPrefs.edit().putString(PREFIX_API_KEY + provider.name, apiKey).apply()
        Log.d(TAG, "API key saved for provider: ${provider.displayName}")
    }
    
    /**
     * Gets the API key for a specific provider
     */
    fun getApiKey(provider: LLMProvider): String? {
        return encryptedPrefs.getString(PREFIX_API_KEY + provider.name, null)
    }
    
    /**
     * Checks if an API key exists for a provider
     */
    fun hasApiKey(provider: LLMProvider): Boolean {
        return !getApiKey(provider).isNullOrBlank()
    }
    
    /**
     * Removes the API key for a specific provider
     */
    fun removeApiKey(provider: LLMProvider) {
        encryptedPrefs.edit().remove(PREFIX_API_KEY + provider.name).apply()
        Log.d(TAG, "API key removed for provider: ${provider.displayName}")
    }
    
    /**
     * Clears all stored API keys
     */
    fun clearAllKeys() {
        encryptedPrefs.edit().clear().apply()
        Log.d(TAG, "All API keys cleared")
    }
    
    /**
     * Sets the currently selected provider
     */
    fun setSelectedProvider(provider: LLMProvider) {
        encryptedPrefs.edit().putString(KEY_SELECTED_PROVIDER, provider.name).apply()
        Log.d(TAG, "Selected provider set to: ${provider.displayName}")
    }
    
    /**
     * Gets the currently selected provider
     */
    fun getSelectedProvider(): LLMProvider? {
        val providerName = encryptedPrefs.getString(KEY_SELECTED_PROVIDER, null)
        return providerName?.let { LLMProvider.fromString(it) }
    }
    
    /**
     * Sets the selected model for a specific provider
     */
    fun setSelectedModel(provider: LLMProvider, model: String) {
        encryptedPrefs.edit().putString(PREFIX_SELECTED_MODEL + provider.name, model).apply()
        Log.d(TAG, "Selected model for ${provider.displayName}: $model")
    }
    
    /**
     * Gets the selected model for a specific provider
     */
    fun getSelectedModel(provider: LLMProvider): String? {
        return encryptedPrefs.getString(PREFIX_SELECTED_MODEL + provider.name, null)
    }
    
    /**
     * Gets all providers that have API keys configured
     */
    fun getConfiguredProviders(): List<LLMProvider> {
        return LLMProvider.values().filter { hasApiKey(it) }
    }
    
    /**
     * Validates that the current configuration is ready to use
     * @return Pair<Boolean, String?> - (isValid, errorMessage)
     */
    fun validateConfiguration(): Pair<Boolean, String?> {
        val selectedProvider = getSelectedProvider()
        if (selectedProvider == null) {
            return Pair(false, "No provider selected. Please configure your API keys in Settings.")
        }
        
        if (!hasApiKey(selectedProvider)) {
            return Pair(false, "No API key found for ${selectedProvider.displayName}. Please add it in Settings.")
        }
        
        val selectedModel = getSelectedModel(selectedProvider)
        if (selectedModel.isNullOrBlank()) {
            return Pair(false, "No model selected for ${selectedProvider.displayName}. Please select a model in Settings.")
        }
        
        return Pair(true, null)
    }
}

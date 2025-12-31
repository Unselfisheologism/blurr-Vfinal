package com.blurr.voice.ui

import android.os.Bundle
import android.widget.*
import androidx.appcompat.app.AppCompatActivity
import com.blurr.voice.BaseNavigationActivity
import com.blurr.voice.R
import com.blurr.voice.core.providers.LLMProvider
import com.blurr.voice.core.providers.ProviderKeyManager
import com.blurr.voice.core.providers.VoiceProviderConfig
import com.google.android.material.textfield.TextInputEditText
import com.google.android.material.textfield.TextInputLayout
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/**
 * Activity for managing BYOK (Bring Your Own Key) settings
 * Allows users to configure API keys for different LLM providers
 */
class BYOKSettingsActivity : BaseNavigationActivity() {
    
    private lateinit var keyManager: ProviderKeyManager
    private val activityScope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    
    // UI components
    private lateinit var providerSpinner: Spinner
    private lateinit var apiKeyInputLayout: TextInputLayout
    private lateinit var apiKeyInput: TextInputEditText
    private lateinit var saveKeyButton: Button
    private lateinit var removeKeyButton: Button
    private lateinit var testConnectionButton: Button
    private lateinit var viewModelsButton: Button
    private lateinit var modelSpinner: Spinner
    private lateinit var statusText: TextView
    private lateinit var voiceCapabilitiesText: TextView
    private lateinit var connectionStatusCard: LinearLayout
    private lateinit var connectionStatusText: TextView
    private lateinit var providerCapabilitiesCard: LinearLayout
    private lateinit var providerCapabilitiesText: TextView
    private lateinit var availableModelsCard: LinearLayout
    private lateinit var availableModelsText: TextView
    
    override fun getContentLayoutId(): Int = R.layout.activity_byok_settings
    
    override fun getCurrentNavItem(): BaseNavigationActivity.NavItem = BaseNavigationActivity.NavItem.SETTINGS
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_byok_settings)
        
        keyManager = ProviderKeyManager(this)
        
        initializeViews()
        setupProviderSpinner()
        setupListeners()
        updateUI()
    }
    
    private fun initializeViews() {
        providerSpinner = findViewById(R.id.provider_spinner)
        apiKeyInputLayout = findViewById(R.id.api_key_input_layout)
        apiKeyInput = findViewById(R.id.api_key_input)
        saveKeyButton = findViewById(R.id.save_key_button)
        removeKeyButton = findViewById(R.id.remove_key_button)
        testConnectionButton = findViewById(R.id.test_connection_button)
        viewModelsButton = findViewById(R.id.view_models_button)
        modelSpinner = findViewById(R.id.model_spinner)
        statusText = findViewById(R.id.status_text)
        voiceCapabilitiesText = findViewById(R.id.voice_capabilities_text)
        connectionStatusCard = findViewById(R.id.connection_status_card)
        connectionStatusText = findViewById(R.id.connection_status_text)
        providerCapabilitiesCard = findViewById(R.id.provider_capabilities_card)
        providerCapabilitiesText = findViewById(R.id.provider_capabilities_text)
        availableModelsCard = findViewById(R.id.available_models_card)
        availableModelsText = findViewById(R.id.available_models_text)
    }
    
    private fun setupProviderSpinner() {
        val providers = LLMProvider.values().map { it.displayName }
        val adapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, providers)
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        providerSpinner.adapter = adapter
        
        // Set current provider if configured
        val currentProvider = keyManager.getSelectedProvider()
        currentProvider?.let {
            val position = LLMProvider.values().indexOf(it)
            providerSpinner.setSelection(position)
        }
        
        providerSpinner.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(parent: AdapterView<*>?, view: android.view.View?, position: Int, id: Long) {
                val selectedProvider = LLMProvider.values()[position]
                onProviderSelected(selectedProvider)
            }
            
            override fun onNothingSelected(parent: AdapterView<*>?) {}
        }
    }
    
    private fun setupListeners() {
        saveKeyButton.setOnClickListener {
            saveApiKey()
        }
        
        removeKeyButton.setOnClickListener {
            removeApiKey()
        }
        
        testConnectionButton.setOnClickListener {
            testConnection()
        }
        
        viewModelsButton.setOnClickListener {
            viewAvailableModels()
        }
        
        modelSpinner.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onItemSelected(parent: AdapterView<*>?, view: android.view.View?, position: Int, id: Long) {
                val selectedProvider = LLMProvider.values()[providerSpinner.selectedItemPosition]
                val selectedModel = modelSpinner.selectedItem as? String
                if (selectedModel != null) {
                    keyManager.setSelectedModel(selectedProvider, selectedModel)
                    updateStatusText()
                }
            }
            
            override fun onNothingSelected(parent: AdapterView<*>?) {}
        }
    }
    
    private fun onProviderSelected(provider: LLMProvider) {
        // Load existing API key if present
        val existingKey = keyManager.getApiKey(provider)
        if (existingKey != null) {
            apiKeyInput.setText(existingKey)
            removeKeyButton.isEnabled = true
            testConnectionButton.isEnabled = true
            viewModelsButton.isEnabled = true
        } else {
            apiKeyInput.setText("")
            removeKeyButton.isEnabled = false
            testConnectionButton.isEnabled = false
            viewModelsButton.isEnabled = false
        }
        
        // Update hint text
        apiKeyInputLayout.hint = "${provider.displayName} API Key"
        
        // Update voice capabilities
        updateVoiceCapabilities(provider)
        
        // Update provider capabilities (media generation)
        updateProviderCapabilities(provider)
        
        // Setup model spinner with common models
        setupModelSpinner(provider)
        
        updateStatusText()
        
        // Hide cards initially
        connectionStatusCard.visibility = android.view.View.GONE
        availableModelsCard.visibility = android.view.View.GONE
    }
    
    private fun setupModelSpinner(provider: LLMProvider) {
        val commonModels = when (provider) {
            LLMProvider.OPENROUTER -> listOf(
                "google/gemini-2.0-flash-exp:free",
                "anthropic/claude-3.5-sonnet",
                "openai/gpt-4o",
                "openai/gpt-4o-mini",
                "meta-llama/llama-3.1-70b-instruct",
                "deepseek/deepseek-chat"
            )
            LLMProvider.AIMLAPI -> listOf(
                "gpt-4o",
                "gpt-4o-mini",
                "claude-3-5-sonnet-20241022",
                "gemini-2.0-flash-exp",
                "deepseek-chat"
            )
            LLMProvider.GROQ -> listOf(
                "llama-3.3-70b-versatile",
                "llama-3.1-70b-versatile",
                "mixtral-8x7b-32768",
                "gemma2-9b-it"
            )
            LLMProvider.FIREWORKS -> listOf(
                "accounts/fireworks/models/llama-v3p1-70b-instruct",
                "accounts/fireworks/models/qwen2p5-72b-instruct",
                "accounts/fireworks/models/deepseek-v3"
            )
            LLMProvider.TOGETHER -> listOf(
                "meta-llama/Meta-Llama-3.1-70B-Instruct-Turbo",
                "Qwen/Qwen2.5-72B-Instruct-Turbo",
                "deepseek-ai/deepseek-llm-67b-chat"
            )
            LLMProvider.OPENAI -> listOf(
                "gpt-4o",
                "gpt-4o-mini",
                "gpt-4-turbo",
                "gpt-3.5-turbo"
            )
        }
        
        val adapter = ArrayAdapter(this, android.R.layout.simple_spinner_item, commonModels)
        adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item)
        modelSpinner.adapter = adapter
        
        // Set current model if configured
        val currentModel = keyManager.getSelectedModel(provider)
        currentModel?.let {
            val position = commonModels.indexOf(it)
            if (position >= 0) {
                modelSpinner.setSelection(position)
            }
        }
    }
    
    private fun updateVoiceCapabilities(provider: LLMProvider) {
        val capabilities = VoiceProviderConfig.getCapabilities(provider)
        val capabilityText = buildString {
            appendLine("Voice Capabilities:")
            appendLine("• STT (Speech-to-Text): ${if (capabilities.supportsSTT) "✓ Supported" else "✗ Not supported"}")
            if (capabilities.supportsSTT) {
                appendLine("  Models: ${capabilities.sttModels.joinToString(", ")}")
            }
            appendLine("• TTS (Text-to-Speech): ${if (capabilities.supportsTTS) "✓ Supported" else "✗ Not supported"}")
            if (capabilities.supportsTTS) {
                appendLine("  Models: ${capabilities.ttsModels.joinToString(", ")}")
                appendLine("  Voices: ${capabilities.ttsVoices.joinToString(", ")}")
            }
        }
        voiceCapabilitiesText.text = capabilityText
    }
    
    private fun saveApiKey() {
        val selectedProvider = LLMProvider.values()[providerSpinner.selectedItemPosition]
        val apiKey = apiKeyInput.text.toString().trim()
        
        if (apiKey.isEmpty()) {
            Toast.makeText(this, "Please enter an API key", Toast.LENGTH_SHORT).show()
            return
        }
        
        keyManager.saveApiKey(selectedProvider, apiKey)
        keyManager.setSelectedProvider(selectedProvider)
        
        // Save selected model
        val selectedModel = modelSpinner.selectedItem as? String
        if (selectedModel != null) {
            keyManager.setSelectedModel(selectedProvider, selectedModel)
        }
        
        Toast.makeText(this, "API key saved for ${selectedProvider.displayName}", Toast.LENGTH_SHORT).show()
        removeKeyButton.isEnabled = true
        testConnectionButton.isEnabled = true
        viewModelsButton.isEnabled = true
        updateStatusText()
        
        // Auto-update capabilities after saving key
        updateProviderCapabilities(selectedProvider)
    }
    
    private fun removeApiKey() {
        val selectedProvider = LLMProvider.values()[providerSpinner.selectedItemPosition]
        keyManager.removeApiKey(selectedProvider)
        apiKeyInput.setText("")
        removeKeyButton.isEnabled = false
        Toast.makeText(this, "API key removed for ${selectedProvider.displayName}", Toast.LENGTH_SHORT).show()
        updateStatusText()
    }
    
    private fun updateUI() {
        val selectedProvider = LLMProvider.values()[providerSpinner.selectedItemPosition]
        onProviderSelected(selectedProvider)
    }
    
    private fun updateStatusText() {
        val (isValid, errorMessage) = keyManager.validateConfiguration()
        if (isValid) {
            val provider = keyManager.getSelectedProvider()
            val model = keyManager.getSelectedModel(provider!!)
            statusText.text = "✓ Ready: ${provider.displayName} with model $model"
            statusText.setTextColor(getColor(android.R.color.holo_green_dark))
        } else {
            statusText.text = "⚠ $errorMessage"
            statusText.setTextColor(getColor(android.R.color.holo_red_dark))
        }
    }
    
    private fun updateProviderCapabilities(provider: LLMProvider) {
        val modelChecker = com.blurr.voice.tools.MediaModelChecker(this)
        
        activityScope.launch {
            val capabilities = withContext(Dispatchers.IO) {
                modelChecker.checkAllMediaTypes()
            }
            
            val capabilityText = buildString {
                appendLine("Media Generation Support:")
                appendLine()
                
                capabilities.forEach { (mediaType, availability) ->
                    val icon = if (availability.isAvailable) "✅" else "❌"
                    val typeName = when (mediaType) {
                        com.blurr.voice.tools.MediaModelChecker.MediaType.IMAGE -> "Images"
                        com.blurr.voice.tools.MediaModelChecker.MediaType.VIDEO -> "Video"
                        com.blurr.voice.tools.MediaModelChecker.MediaType.AUDIO_TTS -> "Audio/TTS"
                        com.blurr.voice.tools.MediaModelChecker.MediaType.MUSIC -> "Music"
                        com.blurr.voice.tools.MediaModelChecker.MediaType.MODEL_3D -> "3D Models"
                    }
                    
                    appendLine("$icon $typeName")
                    if (availability.isAvailable && availability.recommendedModel != null) {
                        appendLine("   Model: ${availability.recommendedModel}")
                    }
                }
            }
            
            providerCapabilitiesText.text = capabilityText
            providerCapabilitiesCard.visibility = android.view.View.VISIBLE
        }
    }
    
    private fun testConnection() {
        val selectedProvider = LLMProvider.values()[providerSpinner.selectedItemPosition]
        val apiKey = keyManager.getApiKey(selectedProvider)
        
        if (apiKey == null) {
            Toast.makeText(this, "No API key configured", Toast.LENGTH_SHORT).show()
            return
        }
        
        testConnectionButton.isEnabled = false
        testConnectionButton.text = "Testing..."
        
        activityScope.launch {
            try {
                val result = withContext(Dispatchers.IO) {
                    val api = com.blurr.voice.core.providers.OpenAICompatibleAPI(
                        selectedProvider, 
                        apiKey, 
                        "test"
                    )
                    
                    // Try to fetch models to test connection
                    val models = api.getAvailableModels()
                    models != null
                }
                
                if (result) {
                    connectionStatusText.text = buildString {
                        appendLine("✅ Connection Successful!")
                        appendLine()
                        appendLine("Provider: ${selectedProvider.displayName}")
                        appendLine("Status: Connected")
                        appendLine("API Key: Valid")
                    }
                    connectionStatusCard.visibility = android.view.View.VISIBLE
                    Toast.makeText(this@BYOKSettingsActivity, "Connection successful!", Toast.LENGTH_SHORT).show()
                } else {
                    connectionStatusText.text = buildString {
                        appendLine("❌ Connection Failed")
                        appendLine()
                        appendLine("Could not connect to ${selectedProvider.displayName}")
                        appendLine("Please check your API key and internet connection.")
                    }
                    connectionStatusCard.visibility = android.view.View.VISIBLE
                    Toast.makeText(this@BYOKSettingsActivity, "Connection failed", Toast.LENGTH_SHORT).show()
                }
                
            } catch (e: Exception) {
                connectionStatusText.text = buildString {
                    appendLine("❌ Connection Error")
                    appendLine()
                    appendLine("Error: ${e.message}")
                }
                connectionStatusCard.visibility = android.view.View.VISIBLE
                Toast.makeText(this@BYOKSettingsActivity, "Error: ${e.message}", Toast.LENGTH_SHORT).show()
            } finally {
                testConnectionButton.isEnabled = true
                testConnectionButton.text = "Test Connection"
            }
        }
    }
    
    private fun viewAvailableModels() {
        val selectedProvider = LLMProvider.values()[providerSpinner.selectedItemPosition]
        val apiKey = keyManager.getApiKey(selectedProvider)
        
        if (apiKey == null) {
            Toast.makeText(this, "No API key configured", Toast.LENGTH_SHORT).show()
            return
        }
        
        viewModelsButton.isEnabled = false
        viewModelsButton.text = "Loading..."
        
        activityScope.launch {
            try {
                val models = withContext(Dispatchers.IO) {
                    val api = com.blurr.voice.core.providers.OpenAICompatibleAPI(
                        selectedProvider, 
                        apiKey, 
                        "test"
                    )
                    api.getAvailableModels()
                }
                
                if (models != null && models.isNotEmpty()) {
                    // Categorize models
                    val chatModels = models.filter { 
                        it.contains("gpt", ignoreCase = true) ||
                        it.contains("claude", ignoreCase = true) ||
                        it.contains("gemini", ignoreCase = true) ||
                        it.contains("llama", ignoreCase = true) ||
                        it.contains("mistral", ignoreCase = true) ||
                        it.contains("qwen", ignoreCase = true) ||
                        it.contains("deepseek", ignoreCase = true)
                    }
                    
                    val imageModels = models.filter {
                        it.contains("dall-e", ignoreCase = true) ||
                        it.contains("flux", ignoreCase = true) ||
                        it.contains("stable-diffusion", ignoreCase = true) ||
                        it.contains("midjourney", ignoreCase = true)
                    }
                    
                    val audioModels = models.filter {
                        it.contains("tts", ignoreCase = true) ||
                        it.contains("whisper", ignoreCase = true) ||
                        it.contains("eleven", ignoreCase = true)
                    }
                    
                    val videoModels = models.filter {
                        it.contains("runway", ignoreCase = true) ||
                        it.contains("luma", ignoreCase = true) ||
                        it.contains("kling", ignoreCase = true)
                    }
                    
                    val musicModels = models.filter {
                        it.contains("suno", ignoreCase = true) ||
                        it.contains("udio", ignoreCase = true)
                    }
                    
                    availableModelsText.text = buildString {
                        appendLine("Total Models: ${models.size}")
                        appendLine()
                        
                        if (chatModels.isNotEmpty()) {
                            appendLine("💬 Chat Models (${chatModels.size}):")
                            chatModels.take(10).forEach { appendLine("  • $it") }
                            if (chatModels.size > 10) appendLine("  ... and ${chatModels.size - 10} more")
                            appendLine()
                        }
                        
                        if (imageModels.isNotEmpty()) {
                            appendLine("🖼️ Image Models (${imageModels.size}):")
                            imageModels.forEach { appendLine("  • $it") }
                            appendLine()
                        }
                        
                        if (videoModels.isNotEmpty()) {
                            appendLine("🎬 Video Models (${videoModels.size}):")
                            videoModels.forEach { appendLine("  • $it") }
                            appendLine()
                        }
                        
                        if (audioModels.isNotEmpty()) {
                            appendLine("🎙️ Audio Models (${audioModels.size}):")
                            audioModels.forEach { appendLine("  • $it") }
                            appendLine()
                        }
                        
                        if (musicModels.isNotEmpty()) {
                            appendLine("🎵 Music Models (${musicModels.size}):")
                            musicModels.forEach { appendLine("  • $it") }
                        }
                    }
                    
                    availableModelsCard.visibility = android.view.View.VISIBLE
                    Toast.makeText(this@BYOKSettingsActivity, "Found ${models.size} models", Toast.LENGTH_SHORT).show()
                } else {
                    availableModelsText.text = "No models found or provider doesn't support model listing."
                    availableModelsCard.visibility = android.view.View.VISIBLE
                    Toast.makeText(this@BYOKSettingsActivity, "No models found", Toast.LENGTH_SHORT).show()
                }
                
            } catch (e: Exception) {
                availableModelsText.text = "Error loading models: ${e.message}"
                availableModelsCard.visibility = android.view.View.VISIBLE
                Toast.makeText(this@BYOKSettingsActivity, "Error: ${e.message}", Toast.LENGTH_SHORT).show()
            } finally {
                viewModelsButton.isEnabled = true
                viewModelsButton.text = "View Available Models"
            }
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
    }
}

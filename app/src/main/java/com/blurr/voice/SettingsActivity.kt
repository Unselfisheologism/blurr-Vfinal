package com.blurr.voice

import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Bundle
import android.util.Log
import android.widget.Button
import android.widget.NumberPicker
import android.widget.RadioGroup
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.core.content.edit
import androidx.lifecycle.lifecycleScope
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import com.blurr.voice.api.TTSVoice
import com.blurr.voice.core.providers.UniversalTTSService
import com.blurr.voice.core.providers.VoiceProviderConfig
import com.blurr.voice.core.providers.ProviderKeyManager
import com.blurr.voice.utilities.SpeechCoordinator
import com.blurr.voice.utilities.VoicePreferenceManager
import com.blurr.voice.utilities.UserProfileManager
import com.blurr.voice.utilities.WakeWordManager
import com.blurr.voice.apps.daw.DawEditorLauncher
import com.blurr.voice.apps.texteditor.TextEditorLauncher
import com.blurr.voice.apps.spreadsheets.SpreadsheetEditorLauncher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.io.File
import kotlin.coroutines.cancellation.CancellationException

class SettingsActivity : BaseNavigationActivity() {

    private lateinit var ttsVoicePicker: NumberPicker
    private lateinit var switchShowThoughts: com.google.android.material.switchmaterial.SwitchMaterial
    private lateinit var permissionsInfoButton: TextView
    private lateinit var batteryOptimizationHelpButton: TextView
    private lateinit var appVersionText: TextView
    private lateinit var editUserName: android.widget.EditText
    private lateinit var editUserEmail: android.widget.EditText
    private lateinit var editWakeWordKey: android.widget.EditText
    private lateinit var textGetPicovoiceKeyLink: TextView
    private lateinit var wakeWordButton: TextView
    private lateinit var buttonSignOut: Button
    private lateinit var buttonBYOKSettings: Button


    private lateinit var wakeWordManager: WakeWordManager
    private lateinit var requestPermissionLauncher: ActivityResultLauncher<String>


    private lateinit var sc: SpeechCoordinator
    private lateinit var sharedPreferences: SharedPreferences
    private lateinit var availableVoices: List<String>
    private var voiceTestJob: Job? = null

    companion object {
        private const val PREFS_NAME = "BlurrSettings"
        private const val KEY_SELECTED_VOICE = "selected_voice"
        private const val TEST_TEXT = "Hello, I'm Panda, and this is a test of the selected voice."
        private const val DEFAULT_VOICE = "alloy"
        const val KEY_SHOW_THOUGHTS = "show_thoughts"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_settings)

        // Initialize permission launcher first
        requestPermissionLauncher = registerForActivityResult(ActivityResultContracts.RequestPermission()) { isGranted: Boolean ->
            if (isGranted) {
                Toast.makeText(this, "Permission granted!", Toast.LENGTH_SHORT).show()
                // The manager will handle the service start after permission is granted.
                wakeWordManager.handleWakeWordButtonClick(wakeWordButton)
                updateWakeWordButtonState()
            } else {
                Toast.makeText(this, "Permission denied.", Toast.LENGTH_SHORT).show()
            }
        }

        initialize()
        setupUI()
        loadAllSettings()
        setupAutoSavingListeners()
        cacheVoiceSamples()
    }

    override fun onStop() {
        super.onStop()
        // Stop any lingering voice tests when the user leaves the screen
        sc.stop()
        voiceTestJob?.cancel()
    }

    private fun initialize() {
        sharedPreferences = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        sc = SpeechCoordinator.getInstance(this)
        
        // Initialize wake word manager
        wakeWordManager = WakeWordManager(this, requestPermissionLauncher)
        
        // Initialize available voices based on current BYOK configuration
        val keyManager = ProviderKeyManager(this)
        val provider = keyManager.getSelectedProvider()
        availableVoices = if (provider != null) {
            VoiceProviderConfig.getCapabilities(provider).ttsVoices
        } else {
            // defaults
            listOf("alloy", "echo", "fable", "onyx", "nova", "shimmer")
        }
    }

    private fun setupUI() {
        ttsVoicePicker = findViewById(R.id.ttsVoicePicker)
        switchShowThoughts = findViewById(R.id.switchShowThoughts)
        permissionsInfoButton = findViewById(R.id.permissionsInfoButton)
        appVersionText = findViewById(R.id.appVersionText)
        batteryOptimizationHelpButton = findViewById(R.id.batteryOptimizationHelpButton)
      
        editWakeWordKey = findViewById(R.id.editWakeWordKey)
        wakeWordButton = findViewById(R.id.wakeWordButton)
        buttonSignOut = findViewById(R.id.buttonSignOut)
        buttonBYOKSettings = findViewById(R.id.buttonBYOKSettings)
        
        // Initialize buttons
        val buttonWorkflowEditor = findViewById<Button>(R.id.buttonWorkflowEditor)
        val buttonMediaCanvas = findViewById<Button>(R.id.buttonMediaCanvas)
        val buttonDawEditor = findViewById<Button>(R.id.buttonDawEditor)
        val buttonTextEditor = findViewById<Button>(R.id.buttonTextEditor)
        val buttonSpreadsheetEditor = findViewById<Button>(R.id.buttonSpreadsheetEditor)

        editUserName = findViewById(R.id.editUserName)
        editUserEmail = findViewById(R.id.editUserEmail)
        textGetPicovoiceKeyLink = findViewById(R.id.textGetPicovoiceKeyLink)


        setupClickListeners()
        setupVoicePicker()

        // Prefill profile fields from saved values
        kotlin.runCatching {
            val pm = UserProfileManager(this)
            editUserName.setText(pm.getName() ?: "")
            editUserEmail.setText(pm.getEmail() ?: "")
        }

        // Show app version
        val versionName = BuildConfig.VERSION_NAME
        appVersionText.text = "Version $versionName"
    }

    private fun setupVoicePicker() {
        val voiceDisplayNames = availableVoices.toTypedArray()
        ttsVoicePicker.minValue = 0
        ttsVoicePicker.maxValue = voiceDisplayNames.size - 1
        ttsVoicePicker.displayedValues = voiceDisplayNames
        ttsVoicePicker.wrapSelectorWheel = false
    }

    private fun setupClickListeners() {
        permissionsInfoButton.setOnClickListener {
            val intent = Intent(this, PermissionsActivity::class.java)
            startActivity(intent)
        }
        batteryOptimizationHelpButton.setOnClickListener {
            showBatteryOptimizationDialog()
        }
        wakeWordButton.setOnClickListener {
            // Check if user has configured API keys for voice capabilities
            val keyManager = ProviderKeyManager(this)
            val (isValid, errorMessage) = keyManager.validateConfiguration()
            
            if (!isValid) {
                showBYOKConfigurationRequiredDialog()
                return@setOnClickListener
            }
            
            // Check if the selected provider supports STT (for wake word detection)
            val provider = keyManager.getSelectedProvider()
            if (provider != null) {
                val capabilities = VoiceProviderConfig.getCapabilities(provider)
                if (!capabilities.supportsSTT) {
                    showSTTNotSupportedDialog(provider.displayName)
                    return@setOnClickListener
                }
            }
            
            // Enable the wake word
            wakeWordManager.handleWakeWordButtonClick(wakeWordButton)
            // Give the service a moment to update its state before refreshing the UI
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({ updateWakeWordButtonState() }, 500)
        }
        textGetPicovoiceKeyLink.setOnClickListener {
            val url = "https://console.picovoice.ai/login"
            val intent = Intent(Intent.ACTION_VIEW)
            intent.data = Uri.parse(url)
            try {
                startActivity(intent)
            } catch (e: Exception) {
                // This might happen if the device has no web browser
                Toast.makeText(this, "Could not open link. No browser found.", Toast.LENGTH_SHORT).show()
                Log.e("SettingsActivity", "Failed to open Picovoice link", e)
            }
        }

        buttonSignOut.setOnClickListener {
            showSignOutConfirmationDialog()
        }
        
        buttonBYOKSettings.setOnClickListener {
            val intent = Intent(this, com.blurr.voice.ui.BYOKSettingsActivity::class.java)
            startActivity(intent)
        }
        
        // Workflow Editor button click listener
        findViewById<Button>(R.id.buttonWorkflowEditor).setOnClickListener {
            val intent = Intent(this, WorkflowEditorActivity::class.java)
            startActivity(intent)
        }
        
        // Media Canvas button (Epic 4)
        findViewById<Button>(R.id.buttonMediaCanvas).setOnClickListener {
            val intent = Intent(this, MediaCanvasActivity::class.java)
            startActivity(intent)
        }
        
        // DAW Editor button (Epic 5)
        findViewById<Button>(R.id.buttonDawEditor).setOnClickListener {
            DawEditorLauncher.launchNewProject(this)
        }
        
        // Text Editor button
        findViewById<Button>(R.id.buttonTextEditor).setOnClickListener {
            TextEditorLauncher.launchNewDocument(this)
        }
        
        // Spreadsheet Editor button
        findViewById<Button>(R.id.buttonSpreadsheetEditor).setOnClickListener {
            SpreadsheetEditorLauncher.launchNewSpreadsheet(this)
        }

        // Add Tool Selection button click listener (if button exists in layout)
        findViewById<Button?>(R.id.buttonToolSelection)?.setOnClickListener {
            val intent = Intent(this, com.blurr.voice.ui.tools.ToolSelectionActivity::class.java)
            startActivity(intent)
        }
    }

    private fun setupAutoSavingListeners() {
        var isInitialLoad = true

        ttsVoicePicker.setOnValueChangedListener { _, _, newVal ->
            val selectedVoice = availableVoices[newVal]
            saveSelectedVoice(selectedVoice)

            if (!isInitialLoad) {
                voiceTestJob?.cancel()
                voiceTestJob = lifecycleScope.launch {
                    delay(400L)
                    // First, stop any currently playing voice
                    sc.stop()
                    // Then, play the new sample
                    playVoiceSample(selectedVoice)
                }
            }
        }

        ttsVoicePicker.post {
            isInitialLoad = false
        }

        switchShowThoughts.setOnCheckedChangeListener { _, isChecked ->
            sharedPreferences.edit().putBoolean(KEY_SHOW_THOUGHTS, isChecked).apply()
        }
    }

    private fun playVoiceSample(voice: String) {
        lifecycleScope.launch {
            val cacheDir = File(cacheDir, "voice_samples")
            val voiceFile = File(cacheDir, "${voice}.wav")

            try {
                if (voiceFile.exists()) {
                    val audioData = voiceFile.readBytes()
                    sc.playAudioData(audioData)
                    Log.d("SettingsActivity", "Playing cached sample for $voice")
                } else {
                    // Convert string voice name to TTSVoice enum
                    val ttsVoice = when (voice) {
                        "alloy" -> TTSVoice.ALLOY
                        "echo" -> TTSVoice.ECHO
                        "fable" -> TTSVoice.FABLE
                        "onyx" -> TTSVoice.ONYX
                        "nova" -> TTSVoice.NOVA
                        "shimmer" -> TTSVoice.SHIMMER
                        else -> TTSVoice.ALLOY // default
                    }
                    sc.testVoice(TEST_TEXT, ttsVoice)
                    Log.d("SettingsActivity", "Synthesizing test for $voice")
                }
            } catch (e: Exception) {
                if (e !is CancellationException) {
                    Log.e("SettingsActivity", "Error playing voice sample", e)
                    Toast.makeText(this@SettingsActivity, "Error playing voice", Toast.LENGTH_SHORT).show()
                }
            }
        }
    }

    private fun cacheVoiceSamples() {
        lifecycleScope.launch(Dispatchers.IO) {
            val cacheDir = File(cacheDir, "voice_samples")
            if (!cacheDir.exists()) cacheDir.mkdirs()

            var downloadedCount = 0
            for (voice in availableVoices) {
                val voiceFile = File(cacheDir, "${voice}.wav")
                if (!voiceFile.exists()) {
                    try {
                        val ttsService = UniversalTTSService(this@SettingsActivity)
                        val audioData = ttsService.synthesize(TEST_TEXT, voice)
                        if (audioData != null) {
                            voiceFile.writeBytes(audioData)
                            downloadedCount++
                        }
                    } catch (e: Exception) {
                        Log.e("SettingsActivity", "Failed to cache voice $voice", e)
                    }
                }
            }
            if (downloadedCount > 0) {
                runOnUiThread {
                    Toast.makeText(this@SettingsActivity, "$downloadedCount voice samples prepared.", Toast.LENGTH_SHORT).show()
                }
            }
        }
    }

    private fun loadAllSettings() {

        // Inside loadAllSettings()
        // We no longer need to load Picovoice key as we're using BYOK for voice features
        val savedVoiceName = sharedPreferences.getString(KEY_SELECTED_VOICE, DEFAULT_VOICE) ?: DEFAULT_VOICE
        val voiceIndex = availableVoices.indexOf(savedVoiceName)
        if (voiceIndex != -1) {
            ttsVoicePicker.value = voiceIndex
        } else {
            ttsVoicePicker.value = 0 // default to first voice
        }
        
        // Update wake word button state
        updateWakeWordButtonState()

        switchShowThoughts.isChecked = sharedPreferences.getBoolean(KEY_SHOW_THOUGHTS, false)
    }

    private fun saveSelectedVoice(voice: String) {
        val voiceEnum = com.blurr.voice.api.TTSVoice.fromName(voice.uppercase())
        VoicePreferenceManager.saveSelectedVoice(this, voiceEnum)
        Log.d("SettingsActivity", "Saved voice: $voice")
    }

    private fun showBYOKConfigurationRequiredDialog() {
        val dialog = AlertDialog.Builder(this)
            .setTitle("API Configuration Required")
            .setMessage("To use wake word functionality, you need to configure your API keys. Please set up your BYOK (Bring Your Own Key) configuration in the API Keys section.")
            .setPositiveButton("Go to API Keys") { _, _ ->
                val intent = Intent(this, com.blurr.voice.ui.BYOKSettingsActivity::class.java)
                startActivity(intent)
            }
            .setNegativeButton("Cancel") { dialog, _ ->
                dialog.dismiss()
            }
            .show()
        
        // Set button text colors to white
        dialog.getButton(AlertDialog.BUTTON_POSITIVE).setTextColor(
            androidx.core.content.ContextCompat.getColor(this, R.color.white)
        )
        dialog.getButton(AlertDialog.BUTTON_NEGATIVE).setTextColor(
            androidx.core.content.ContextCompat.getColor(this, R.color.white)
        )
    }
    
    private fun showSTTNotSupportedDialog(providerName: String) {
        val dialog = AlertDialog.Builder(this)
            .setTitle("STT Not Supported")
            .setMessage("The selected provider ($providerName) does not support Speech-to-Text, which is required for wake word detection. Please select a different provider that supports STT in API Keys settings.")
            .setPositiveButton("Go to API Keys") { _, _ ->
                val intent = Intent(this, com.blurr.voice.ui.BYOKSettingsActivity::class.java)
                startActivity(intent)
            }
            .setNegativeButton("Cancel") { dialog, _ ->
                dialog.dismiss()
            }
            .show()
        
        // Set button text colors to white
        dialog.getButton(AlertDialog.BUTTON_POSITIVE).setTextColor(
            androidx.core.content.ContextCompat.getColor(this, R.color.white)
        )
        dialog.getButton(AlertDialog.BUTTON_NEGATIVE).setTextColor(
            androidx.core.content.ContextCompat.getColor(this, R.color.white)
        )
    }

    private fun updateWakeWordButtonState() {
        wakeWordManager.updateButtonState(wakeWordButton)
    }

    private fun showBatteryOptimizationDialog() {
        val dialog = AlertDialog.Builder(this)
            .setTitle(getString(R.string.battery_optimization_title))
            .setMessage(getString(R.string.battery_optimization_message))
            .setPositiveButton(getString(R.string.learn_how)) { _, _ ->
                // Open the Tasker FAQ URL
                val url = "https://tasker.joaoapps.com/userguide/en/faqs/faq-problem.html#00"
                val intent = Intent(Intent.ACTION_VIEW)
                intent.data = Uri.parse(url)
                try {
                    startActivity(intent)
                } catch (e: Exception) {
                    Toast.makeText(this, "Could not open link. No browser found.", Toast.LENGTH_LONG).show()
                    Log.e("SettingsActivity", "Failed to open battery optimization link", e)
                }
            }
            .setNegativeButton("Cancel") { dialog, _ ->
                dialog.dismiss()
            }
            .show()
        
        // Set button text colors to white
        dialog.getButton(AlertDialog.BUTTON_POSITIVE).setTextColor(
            androidx.core.content.ContextCompat.getColor(this, R.color.white)
        )
        dialog.getButton(AlertDialog.BUTTON_NEGATIVE).setTextColor(
            androidx.core.content.ContextCompat.getColor(this, R.color.white)
        )
    }

    private fun showSignOutConfirmationDialog() {
        AlertDialog.Builder(this)
            .setTitle("Sign Out")
            .setMessage("Are you sure you want to sign out? This will clear all your settings and data.")
            .setPositiveButton("Sign Out") { _, _ ->
                signOut()
            }
            .setNegativeButton("Cancel", null)
            .show()
    }

    private fun signOut() {
        // Clear User Profile
        val userProfileManager = UserProfileManager(this)
        userProfileManager.clearProfile()

        // Clear all shared preferences for this app
        getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE).edit().clear().apply()


        // Restart the app by navigating to the onboarding screen
        val intent = Intent(this, LoginActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        startActivity(intent)
        finish()
    }

    
    override fun getContentLayoutId(): Int = R.layout.activity_settings
    
    override fun getCurrentNavItem(): BaseNavigationActivity.NavItem = BaseNavigationActivity.NavItem.SETTINGS
}

# BYOK Integration Guide - Complete Phase 0

## 🎯 Quick Start

You now have a **complete BYOK architecture** ready to integrate. This guide will help you complete Phase 0.

---

## 📊 Current Status

### ✅ COMPLETED (70% of Phase 0)
- Core BYOK provider system (6 providers)
- Encrypted key management
- Universal LLM/STT/TTS services
- User interface and navigation
- Build configuration
- Documentation

### 🔄 REMAINING (30% of Phase 0)
- Replace existing GeminiApi usage (13 files found)
- Replace voice API usage (3 files found)
- Remove hard-coded API keys
- Remove legacy dependencies
- Testing

---

## 🔍 Files That Need Updates

Based on grep analysis, these files import old APIs:

### LLM Usage (6 files)
1. ✅ **app/src/main/java/com/twent/voice/api/GeminiApi.kt** - Will be deleted
2. ✅ **app/src/main/java/com/twent/voice/api/EmbeddingService.kt** - Update or delete
3. ❌ **app/src/main/java/com/twent/voice/agents/ClarificationAgent.kt** - UPDATE REQUIRED
4. ❌ **app/src/main/java/com/twent/voice/v2/llm/GeminiAPI.kt** - UPDATE REQUIRED
5. ❌ **app/src/main/java/com/twent/voice/v2/AgentService.kt** - UPDATE REQUIRED
6. ❌ **app/src/main/java/com/twent/voice/utilities/LLMHelperFunctions.kt** - UPDATE REQUIRED
7. ❌ **app/src/main/java/com/twent/voice/v2/Agent.kt** - UPDATE REQUIRED

### Voice Usage (3 files)
8. ❌ **app/src/main/java/com/twent/voice/SettingsActivity.kt** - UPDATE REQUIRED
9. ❌ **app/src/main/java/com/twent/voice/utilities/TTSManager.kt** - UPDATE REQUIRED
10. ❌ **app/src/main/java/com/twent/voice/utilities/SpeechCoordinator.kt** - UPDATE REQUIRED

### API Key Manager (3 files)
11. ✅ **app/src/main/java/com/twent/voice/utilities/ApiKeyManager.kt** - Will be deleted

---

## 📝 Step-by-Step Integration

### STEP 1: Update ClarificationAgent.kt

**Location:** `app/src/main/java/com/twent/voice/agents/ClarificationAgent.kt`

**Find:**
```kotlin
import com.twent.voice.api.GeminiApi
```

**Replace with:**
```kotlin
import com.twent.voice.core.providers.UniversalLLMService
```

**Find in the class:**
```kotlin
val geminiApi = GeminiApi(...)
val response = geminiApi.generateContent(...)
```

**Replace with:**
```kotlin
val llmService = UniversalLLMService(context)
if (!llmService.isConfigured()) {
    return ClarificationResult(status = "ERROR", questions = listOf("Please configure API keys in Settings"))
}
val response = llmService.generateContent(...)
```

---

### STEP 2: Update v2/llm/GeminiAPI.kt

**Location:** `app/src/main/java/com/twent/voice/v2/llm/GeminiAPI.kt`

**Option A: Rename and Adapt**
Rename this file to `UniversalLLMAPI.kt` and make it wrap `UniversalLLMService`

**Option B: Replace Usage**
Update `v2/Agent.kt` to use `UniversalLLMService` directly instead of this class

**Recommended: Option B** (simpler)

---

### STEP 3: Update v2/AgentService.kt

**Location:** `app/src/main/java/com/twent/voice/v2/AgentService.kt`

**Find:**
```kotlin
import com.twent.voice.utilities.ApiKeyManager
import com.twent.voice.v2.llm.GeminiApi

// In onCreate():
llmApi = GeminiApi(
    "gemini-2.5-flash",
    apiKeyManager = ApiKeyManager,
    maxRetry = 10
)
```

**Replace with:**
```kotlin
import com.twent.voice.core.providers.UniversalLLMService

// In onCreate():
llmApi = UniversalLLMService(this)

// Add configuration check:
if (!llmApi.isConfigured()) {
    Log.e(TAG, "LLM not configured. Stopping service.")
    Toast.makeText(this, "Please configure API keys in Settings", Toast.LENGTH_LONG).show()
    stopSelf()
    return
}
```

---

### STEP 4: Update v2/Agent.kt

**Location:** `app/src/main/java/com/twent/voice/v2/Agent.kt`

**Find:**
```kotlin
import com.twent.voice.v2.llm.GeminiApi

class Agent(
    // ...
    private val llmApi: GeminiApi,
    // ...
)
```

**Replace with:**
```kotlin
import com.twent.voice.core.providers.UniversalLLMService

class Agent(
    // ...
    private val llmApi: UniversalLLMService,
    // ...
)
```

Note: The interface should remain the same since UniversalLLMService has similar methods.

---

### STEP 5: Update utilities/LLMHelperFunctions.kt

**Location:** `app/src/main/java/com/twent/voice/utilities/LLMHelperFunctions.kt`

**Find:**
```kotlin
import com.twent.voice.api.GeminiApi

suspend fun getReasoningModelApiResponse(
    conversationHistory: List<Pair<String, List<Any>>>
): String? {
    val geminiApi = GeminiApi(...)
    return geminiApi.generateContent(conversationHistory)
}
```

**Replace with:**
```kotlin
import com.twent.voice.core.providers.UniversalLLMService

suspend fun getReasoningModelApiResponse(
    context: Context,
    conversationHistory: List<Pair<String, List<Any>>>
): String? {
    val llmService = UniversalLLMService(context)
    if (!llmService.isConfigured()) {
        Log.e("LLMHelper", "LLM service not configured")
        return null
    }
    return llmService.generateContent(conversationHistory)
}
```

**Update all callers to pass `context` parameter.**

---

### STEP 6: Update utilities/TTSManager.kt

**Location:** `app/src/main/java/com/twent/voice/utilities/TTSManager.kt`

**Find:**
```kotlin
import com.twent.voice.api.GoogleTts

suspend fun speakText(text: String) {
    val audioData = GoogleTts.synthesize(text)
    // play audio
}
```

**Replace with:**
```kotlin
import com.twent.voice.core.providers.UniversalTTSService

private val ttsService = UniversalTTSService(context)

suspend fun speakText(text: String) {
    val audioData = ttsService.synthesize(text)
    if (audioData == null) {
        Log.e(TAG, "TTS failed - not configured or API error")
        return
    }
    // play audio
}
```

---

### STEP 7: Update utilities/SpeechCoordinator.kt

**Location:** `app/src/main/java/com/twent/voice/utilities/SpeechCoordinator.kt`

**Find:**
```kotlin
import com.twent.voice.api.GoogleTts

suspend fun testVoice(text: String, voice: TTSVoice) {
    val audioData = GoogleTts.synthesize(text, voice)
    playAudioData(audioData)
}
```

**Replace with:**
```kotlin
import com.twent.voice.core.providers.UniversalTTSService
import com.twent.voice.core.providers.VoiceProviderConfig

private val ttsService = UniversalTTSService(context)

suspend fun testVoice(text: String, voice: String = "alloy") {
    val audioData = ttsService.synthesize(text, voice)
    if (audioData != null) {
        playAudioData(audioData)
    } else {
        Log.e(TAG, "TTS test failed - check BYOK configuration")
    }
}
```

**Note:** Voice names change from `TTSVoice` enum to simple strings like "alloy", "nova", etc.

---

### STEP 8: Update SettingsActivity.kt

**Location:** `app/src/main/java/com/twent/voice/SettingsActivity.kt`

**Find:**
```kotlin
import com.twent.voice.api.GoogleTts
import com.twent.voice.api.TTSVoice

private lateinit var availableVoices: List<TTSVoice>

// In initialize():
availableVoices = GoogleTts.getAvailableVoices()
```

**Replace with:**
```kotlin
import com.twent.voice.core.providers.UniversalTTSService
import com.twent.voice.core.providers.VoiceProviderConfig
import com.twent.voice.core.providers.ProviderKeyManager

private lateinit var availableVoices: List<String>

// In initialize():
val keyManager = ProviderKeyManager(this)
val provider = keyManager.getSelectedProvider()
availableVoices = if (provider != null) {
    VoiceProviderConfig.getCapabilities(provider).ttsVoices
} else {
    listOf("alloy", "echo", "fable", "onyx", "nova", "shimmer") // defaults
}
```

---

### STEP 9: Remove Hard-coded API Keys

**File:** `app/build.gradle.kts`

**Find and DELETE:**
```kotlin
val apiKeys = localProperties.getProperty("GEMINI_API_KEYS") ?: ""
val googleTtsApiKey = localProperties.getProperty("GOOGLE_TTS_API_KEY") ?: ""
val picovoiceApiKey = localProperties.getProperty("PICOVOICE_ACCESS_KEY") ?: ""
val googlecloudGatewayPicovoice = localProperties.getProperty("GCLOUD_GATEWAY_PICOVOICE_KEY") ?: ""

// In defaultConfig:
buildConfigField("String", "GEMINI_API_KEYS", "\"$apiKeys\"")
buildConfigField("String", "GOOGLE_TTS_API_KEY", "\"$googleTtsApiKey\"")
buildConfigField("String", "PICOVOICE_ACCESS_KEY", "\"$picovoiceApiKey\"")
buildConfigField("String", "GCLOUD_GATEWAY_PICOVOICE_KEY", "\"$googlecloudGatewayPicovoice\"")
```

---

### STEP 10: Remove Legacy Dependencies

**File:** `app/build.gradle.kts`

**Find and DELETE:**
```kotlin
// Remove:
implementation("ai.picovoice:porcupine-android:3.0.2")
```

**File:** `gradle/libs.versions.toml`

**Find and DELETE:**
```toml
generativeai = "0.9.0"

# In [libraries] section:
generativeai = { group = "com.google.ai.client.generativeai", name = "generativeai", version.ref = "generativeai" }
```

**File:** `app/build.gradle.kts`

**Find and DELETE:**
```kotlin
implementation(libs.generativeai)
```

---

### STEP 11: Delete Legacy Files

Run these commands:

```bash
# Delete old API implementations
rm app/src/main/java/com/twent/voice/utilities/ApiKeyManager.kt
rm app/src/main/java/com/twent/voice/api/GeminiApi.kt
rm app/src/main/java/com/twent/voice/api/GoogleTTS.kt
rm app/src/main/java/com/twent/voice/api/PicovoiceKeyManager.kt
rm app/src/main/java/com/twent/voice/api/PorcupineWakeWordDetector.kt
rm app/src/main/java/com/twent/voice/api/WakeWordDetector.kt

# Optional: Delete embedding service if using Gemini embeddings
# rm app/src/main/java/com/twent/voice/api/EmbeddingService.kt
```

---

### STEP 12: Update ConversationalAgentService.kt

**Location:** `app/src/main/java/com/twent/voice/ConversationalAgentService.kt`

**Add at the top of class:**
```kotlin
private val llmService by lazy { UniversalLLMService(this) }
```

**Find all calls to `getReasoningModelApiResponse()` and update:**
```kotlin
// Before:
val rawModelResponse = getReasoningModelApiResponse(conversationHistory)

// After:
val rawModelResponse = getReasoningModelApiResponse(this, conversationHistory)
```

**Add configuration check in onCreate():**
```kotlin
override fun onCreate() {
    super.onCreate()
    
    // Check BYOK configuration
    if (!llmService.isConfigured()) {
        Toast.makeText(
            this, 
            "Please configure API keys in Settings → API Keys (BYOK)", 
            Toast.LENGTH_LONG
        ).show()
        // Optionally redirect to BYOK settings
        stopSelf()
        return
    }
    
    // ... rest of onCreate
}
```

---

## 🧪 Testing Checklist

### Before Testing - Get API Keys

1. **OpenRouter (Recommended for testing - has FREE tier)**
   - Go to https://openrouter.ai
   - Sign up
   - Get API key
   - Free models: `google/gemini-2.0-flash-exp:free`

2. **Alternative: Groq (Free tier)**
   - Go to https://console.groq.com
   - Sign up
   - Get API key
   - Free models: `llama-3.3-70b-versatile`

### Test Procedure

1. **Build the app:**
   ```bash
   ./gradlew assembleDebug
   ```

2. **Install and open app**

3. **Configure BYOK:**
   - Open Settings
   - Tap "🔑 API Keys (BYOK)"
   - Select "OpenRouter" (or your chosen provider)
   - Enter API key
   - Select model (e.g., `google/gemini-2.0-flash-exp:free`)
   - Tap "Save Key"
   - Verify status shows "✓ Ready"

4. **Test Conversation:**
   - Long-press home button (or use app's trigger)
   - Start a conversation
   - Verify AI responds

5. **Test Voice (if provider supports):**
   - Configure AIMLAPI or OpenAI (they support STT/TTS)
   - Test voice input
   - Test voice output

6. **Test Error Handling:**
   - Remove API key
   - Try to use AI features
   - Verify friendly error message

### Expected Behavior

✅ **Success Case:**
- Conversation works
- AI responds using your API key
- Voice works (if supported by provider)
- No errors in logs

❌ **Error Cases:**
- If no API key: Clear error message with link to settings
- If invalid key: API error logged, user-friendly message shown
- If unsupported feature: Graceful fallback or clear message

---

## 📱 User Experience

### First Run (No API Key)
```
User: [Tries to use AI feature]
App: "Please configure API keys in Settings → API Keys (BYOK)"
     [Opens BYOK Settings]
```

### With API Key Configured
```
User: [Uses AI feature]
App: [Works normally, uses user's API key]
     [User monitors their own usage in provider dashboard]
```

---

## 🎓 Best Practices

### Error Handling
```kotlin
private fun checkBYOKConfiguration(): Boolean {
    val llmService = UniversalLLMService(this)
    if (!llmService.isConfigured()) {
        showBYOKConfigurationDialog()
        return false
    }
    return true
}

private fun showBYOKConfigurationDialog() {
    AlertDialog.Builder(this)
        .setTitle("API Configuration Required")
        .setMessage("Please configure your API keys to use AI features.")
        .setPositiveButton("Open Settings") { _, _ ->
            startActivity(Intent(this, BYOKSettingsActivity::class.java))
        }
        .setNegativeButton("Cancel", null)
        .show()
}
```

### Logging
```kotlin
// Good logging for debugging
Log.d(TAG, "Using provider: ${llmService.getCurrentProviderName()}")
Log.d(TAG, "Using model: ${llmService.getCurrentModelName()}")
```

---

## 🐛 Troubleshooting

### Build Errors

**Error: "Unresolved reference: GeminiApi"**
- Solution: You forgot to update an import. Search for `GeminiApi` and replace with `UniversalLLMService`

**Error: "BuildConfig.GEMINI_API_KEYS not found"**
- Solution: Remove all references to `BuildConfig.GEMINI_API_KEYS`

### Runtime Errors

**Error: "LLM service not configured"**
- Solution: User needs to configure API key in BYOK settings
- Show friendly error message

**Error: "API returned 401"**
- Solution: Invalid API key. User needs to check their key in provider dashboard

**Error: "Provider doesn't support STT"**
- Solution: Check `VoiceProviderConfig.getCapabilities()` before calling voice features

---

## ✅ Definition of Done

Phase 0 is complete when:

- [ ] All 13 files updated (no GeminiApi imports)
- [ ] All hard-coded API keys removed from BuildConfig
- [ ] Gemini SDK removed from dependencies
- [ ] Picovoice removed from dependencies
- [ ] App builds without errors
- [ ] BYOK settings UI works
- [ ] API keys save/load correctly
- [ ] Conversation works with at least one provider
- [ ] Voice works with at least one provider (optional)
- [ ] Error handling for unconfigured state works
- [ ] No more "gemini" or "picovoice" in active code (grep clean)

---

## 🎯 Quick Commands

### Search for remaining work:
```bash
# Find GeminiApi usage
grep -r "GeminiApi" app/src/main/java --include="*.kt"

# Find ApiKeyManager usage  
grep -r "ApiKeyManager" app/src/main/java --include="*.kt"

# Find GoogleTts usage
grep -r "GoogleTts" app/src/main/java --include="*.kt"

# Find BuildConfig API keys
grep -r "BuildConfig.GEMINI\|BuildConfig.GOOGLE_TTS" app/src/main/java --include="*.kt"
```

### Build and test:
```bash
# Clean build
./gradlew clean

# Build debug APK
./gradlew assembleDebug

# Install to device
./gradlew installDebug

# Run tests
./gradlew test
```

---

## 🚀 After Completion

Once Phase 0 is done, you'll have:
- ✅ Pure BYOK architecture
- ✅ Multi-provider support
- ✅ No vendor lock-in
- ✅ User controls costs
- ✅ Privacy-first design
- ✅ Ready for Phase 1 (MCP, tools, etc.)

**Estimated completion time: 6-8 hours**

Good luck! 🎉

# Phase 0 BYOK Implementation - Next Steps

## What Has Been Completed ✅

### 1. Core BYOK Architecture (100% Complete)
- ✅ **LLMProvider.kt** - Enum with 6 providers (OpenRouter, AIMLAPI, Groq, Fireworks, Together, OpenAI)
- ✅ **ProviderKeyManager.kt** - Encrypted key storage using EncryptedSharedPreferences
- ✅ **OpenAICompatibleAPI.kt** - Universal client for all OpenAI-compatible APIs
- ✅ **UniversalLLMService.kt** - Drop-in replacement for GeminiApi

### 2. Voice Services (100% Complete)
- ✅ **VoiceProvider.kt** - Voice capabilities configuration
- ✅ **UniversalSTTService.kt** - Speech-to-Text via Whisper APIs
- ✅ **UniversalTTSService.kt** - Text-to-Speech synthesis

### 3. User Interface (100% Complete)
- ✅ **BYOKSettingsActivity.kt** - Full settings UI
- ✅ **activity_byok_settings.xml** - Material Design layout
- ✅ **Navigation button added to SettingsActivity**

### 4. Build Configuration (100% Complete)
- ✅ Added `androidx.security:security-crypto` dependency
- ✅ Updated `AndroidManifest.xml` with new activity
- ✅ Added UI colors
- ✅ Commented out Porcupine dependency (ready for removal)

---

## What Needs To Be Done Next 🔄

### Step 1: Replace GeminiApi with UniversalLLMService

**Files to Update:**

1. **ConversationalAgentService.kt**
   ```kotlin
   // At the top of the class, add:
   private val llmService by lazy { UniversalLLMService(this) }
   
   // Replace all calls like:
   // getReasoningModelApiResponse(conversationHistory)
   // With:
   // llmService.generateContent(conversationHistory)
   ```

2. **v2/AgentService.kt**
   ```kotlin
   // Replace:
   llmApi = GeminiApi("gemini-2.5-flash", ApiKeyManager, 10)
   
   // With:
   llmApi = UniversalLLMService(this)
   ```

3. **utilities/ApiHelpers.kt** (search for any helper functions)
   - Update `getReasoningModelApiResponse()` function

4. **agents/ClarificationAgent.kt**
   ```kotlin
   // Replace GeminiApi usage with UniversalLLMService
   ```

### Step 2: Update Voice Services

**Files to Update:**

1. **utilities/SpeechCoordinator.kt**
   - Replace STT calls with `UniversalSTTService`
   - Replace TTS calls with `UniversalTTSService`

2. **utilities/TTSManager.kt** (if exists)
   - Integrate `UniversalTTSService`

### Step 3: Remove Hard-coded API Keys

**Update `app/build.gradle.kts`:**
```kotlin
// Remove these lines:
buildConfigField("String", "GEMINI_API_KEYS", "\"$apiKeys\"")
buildConfigField("String", "GOOGLE_TTS_API_KEY", "\"$googleTtsApiKey\"")
buildConfigField("String", "PICOVOICE_ACCESS_KEY", "\"$picovoiceApiKey\"")
buildConfigField("String", "GCLOUD_GATEWAY_PICOVOICE_KEY", "\"$googlecloudGatewayPicovoice\"")
```

**Update `local.properties.template`:**
```properties
# Remove old keys, add comment:
# API keys are now managed via BYOK Settings in the app
# No developer API keys needed in local.properties

# Appwrite configuration (still needed for backend)
APPWRITE_PROJECT_ID=your_project_id
APPWRITE_DATABASE_ID=your_database_id
APPWRITE_USERS_COLLECTION_ID=your_users_collection_id
APPWRITE_TASKS_COLLECTION_ID=your_tasks_collection_id
```

### Step 4: Remove Legacy Dependencies

**Update `app/build.gradle.kts`:**
```kotlin
// Remove:
implementation(libs.generativeai)
// implementation("ai.picovoice:porcupine-android:3.0.2") // Already commented

// Remove from imports at the top if present
```

**Update `gradle/libs.versions.toml`:**
```toml
# Remove:
generativeai = "0.9.0"

# Remove from libraries section:
generativeai = { group = "com.google.ai.client.generativeai", name = "generativeai", version.ref = "generativeai" }
```

### Step 5: Delete Legacy Files

```bash
# These files can be deleted after migration:
rm app/src/main/java/com/twent/voice/utilities/ApiKeyManager.kt
rm app/src/main/java/com/twent/voice/api/GeminiApi.kt
rm app/src/main/java/com/twent/voice/api/GoogleTTS.kt
rm app/src/main/java/com/twent/voice/api/PicovoiceKeyManager.kt
rm app/src/main/java/com/twent/voice/api/PorcupineWakeWordDetector.kt
rm app/src/main/java/com/twent/voice/api/WakeWordDetector.kt
rm app/src/main/java/com/twent/voice/api/EmbeddingService.kt  # If using Gemini embeddings
```

### Step 6: Add Error Handling for Unconfigured State

**Create helper in UniversalLLMService.kt:**
```kotlin
fun showConfigurationDialog(context: Context) {
    AlertDialog.Builder(context)
        .setTitle("API Configuration Required")
        .setMessage("Please configure your API keys in Settings → API Keys (BYOK) to use AI features.")
        .setPositiveButton("Open Settings") { _, _ ->
            val intent = Intent(context, BYOKSettingsActivity::class.java)
            context.startActivity(intent)
        }
        .setNegativeButton("Cancel", null)
        .show()
}
```

**Use in ConversationalAgentService.kt:**
```kotlin
override fun onCreate() {
    super.onCreate()
    
    // Check if BYOK is configured
    val llmService = UniversalLLMService(this)
    if (!llmService.isConfigured()) {
        Toast.makeText(this, "Please configure API keys in Settings", Toast.LENGTH_LONG).show()
        // Optionally redirect to settings
        stopSelf()
        return
    }
    
    // ... rest of onCreate
}
```

---

## Testing Checklist 🧪

### Before Removing Old Code:
- [ ] Test that BYOKSettingsActivity opens from Settings
- [ ] Test saving/loading API keys
- [ ] Test provider selection
- [ ] Test model selection
- [ ] Verify encrypted storage (check Android Studio device file explorer)

### After Integration:
- [ ] Test conversation with OpenRouter
- [ ] Test conversation with AIMLAPI
- [ ] Test conversation with Groq
- [ ] Test STT with supported providers
- [ ] Test TTS with supported providers
- [ ] Test vision features with supported providers
- [ ] Test error handling when no API key configured
- [ ] Test error handling for invalid API key
- [ ] Test error handling for rate limits

### Final Verification:
- [ ] App builds without Gemini SDK
- [ ] App builds without Picovoice SDK
- [ ] No BuildConfig references to old API keys
- [ ] Search codebase for "gemini" (case-insensitive) - should only find old comments
- [ ] Search codebase for "picovoice" - should find nothing in active code
- [ ] local.properties.template updated

---

## Migration Strategy

### Recommended Approach: Gradual Migration

**Phase A: Add BYOK alongside existing (Safe)**
1. Keep GeminiApi working
2. Add UniversalLLMService
3. Add configuration check at startup
4. Test BYOK in parallel

**Phase B: Switch to BYOK (Controlled)**
1. Add feature flag to switch between old/new
2. Test thoroughly with BYOK
3. Get user feedback
4. Fix any issues

**Phase C: Remove Legacy (Final)**
1. Remove old API implementations
2. Remove dependencies
3. Remove BuildConfig keys
4. Clean up unused code

### Alternative: All-at-Once (Faster but Riskier)
1. Implement all changes in one go
2. Extensive testing required
3. Higher risk of breaking features
4. Faster to complete

**Recommendation: Use Gradual Migration**

---

## Code Search Queries

Run these to find all places needing updates:

```bash
# Find GeminiApi usage
grep -r "GeminiApi" app/src/main/java --include="*.kt"

# Find ApiKeyManager usage
grep -r "ApiKeyManager" app/src/main/java --include="*.kt"

# Find Google TTS usage
grep -r "GoogleTts" app/src/main/java --include="*.kt"

# Find Picovoice usage
grep -r "Picovoice\|Porcupine" app/src/main/java --include="*.kt"

# Find BuildConfig API key references
grep -r "BuildConfig.GEMINI\|BuildConfig.GOOGLE_TTS\|BuildConfig.PICOVOICE" app/src/main/java --include="*.kt"
```

---

## Example Migration: ConversationalAgentService

**Before:**
```kotlin
private val geminiApi = GeminiApi("gemini-2.5-flash", ApiKeyManager, 2)

suspend fun getModelResponse(history: List<Pair<String, List<Any>>>): String? {
    return geminiApi.generateContent(history)
}
```

**After:**
```kotlin
private val llmService by lazy { UniversalLLMService(this) }

suspend fun getModelResponse(history: List<Pair<String, List<Any>>>): String? {
    // Check configuration first
    if (!llmService.isConfigured()) {
        Log.e(TAG, "LLM service not configured")
        return "Please configure your API keys in Settings → API Keys (BYOK)"
    }
    
    return llmService.generateContent(history)
}
```

---

## Documentation to Update

1. **README.md**
   - Add BYOK setup instructions
   - Update features list
   - Add provider links

2. **User Guide** (in-app or docs)
   - How to get API keys
   - How to configure BYOK
   - Which providers support which features
   - Cost information (user pays)

3. **Developer Guide**
   - How to add new providers
   - How to extend voice capabilities
   - Testing with different providers

---

## Known Issues & Considerations

1. **Vision Support**: Not all providers support vision
   - OpenRouter: ✅ Most models
   - AIMLAPI: ✅ GPT-4V, Claude 3
   - Groq: ❌ No vision yet
   - Solution: Detect capability and gracefully handle

2. **Rate Limits**: Each provider has different limits
   - Should we add rate limit handling?
   - Should we show usage stats?

3. **Streaming**: Not implemented yet
   - All providers support streaming
   - Future enhancement

4. **Cost Tracking**: Users need to monitor their own usage
   - Link to provider dashboards
   - Maybe add local usage counter?

5. **Fallback**: No fallback if user doesn't configure
   - By design: Pure BYOK
   - Must be clear in onboarding

---

## Success Criteria

Phase 0 is complete when:

1. ✅ No hard-coded API keys in code
2. ✅ All AI calls route through user-configured provider
3. ✅ Voice features use user-configured provider
4. ✅ Gemini SDK removed
5. ✅ Picovoice SDK removed
6. ✅ App builds and runs
7. ✅ All core features work with BYOK
8. ✅ Configuration UI is intuitive
9. ✅ Error handling for unconfigured state
10. ✅ Documentation updated

---

## Timeline Estimate

- **Step 1-2 (Integration)**: 2-3 hours
- **Step 3-4 (Cleanup)**: 1 hour
- **Step 5 (Deletion)**: 30 minutes
- **Step 6 (Error Handling)**: 1 hour
- **Testing**: 2-3 hours
- **Documentation**: 1 hour

**Total: ~8-10 hours of focused work**

---

## Questions for User

1. Should we keep a "demo mode" with limited functionality for users who don't configure API keys?
2. Do we want to add usage tracking/stats?
3. Should we implement streaming responses?
4. Do we want to support multiple API keys per provider (for rotation)?
5. Should we add a "test connection" button in BYOK settings?

---

## After Phase 0: Phase 1 Preview

Once Phase 0 is complete, Phase 1 will add:
- Model Context Protocol (MCP) client
- Web search (Tavily, Exa)
- Multimodal generation
- Google Workspace integration
- Ultra-Generalist Agent architecture

Phase 0 is the foundation for everything else!

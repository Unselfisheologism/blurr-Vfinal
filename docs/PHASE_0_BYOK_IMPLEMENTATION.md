# Phase 0: BYOK (Bring Your Own Key) Implementation - IN PROGRESS

## Status: Core Architecture Complete, Integration Pending

This document tracks the implementation of Phase 0 - BYOK architecture and dependency cleanup.

---

## ✅ Completed Components

### 1. Core Provider Architecture

**Created Files:**
- `app/src/main/java/com/blurr/voice/core/providers/LLMProvider.kt`
  - Enum defining all supported providers (OpenRouter, AIMLAPI, Groq, Fireworks, Together, OpenAI)
  - Provider capabilities (streaming, vision, STT, TTS)
  - Base URLs for each provider

- `app/src/main/java/com/blurr/voice/core/providers/ProviderKeyManager.kt`
  - Encrypted storage using Android EncryptedSharedPreferences
  - API key management per provider
  - Selected provider and model persistence
  - Configuration validation

- `app/src/main/java/com/blurr/voice/core/providers/OpenAICompatibleAPI.kt`
  - Universal client for OpenAI-compatible APIs
  - Supports all configured providers
  - Vision model support (multimodal)
  - Retry logic with exponential backoff
  - Model listing capability

- `app/src/main/java/com/blurr/voice/core/providers/UniversalLLMService.kt`
  - Drop-in replacement for GeminiApi
  - Routes to user-configured provider
  - Converts between Gemini and OpenAI message formats
  - Configuration validation

### 2. Voice Services (STT/TTS)

**Created Files:**
- `app/src/main/java/com/blurr/voice/core/providers/VoiceProvider.kt`
  - Voice capabilities configuration per provider
  - STT/TTS model lists
  - Voice options

- `app/src/main/java/com/blurr/voice/core/providers/UniversalSTTService.kt`
  - Speech-to-Text using Whisper APIs
  - Supports OpenAI, AIMLAPI, Groq
  - Audio file transcription

- `app/src/main/java/com/blurr/voice/core/providers/UniversalTTSService.kt`
  - Text-to-Speech synthesis
  - Supports OpenAI, AIMLAPI TTS models
  - Multiple voice options

### 3. User Interface

**Created Files:**
- `app/src/main/java/com/blurr/voice/ui/BYOKSettingsActivity.kt`
  - Provider selection UI
  - API key input (encrypted storage)
  - Model selection dropdown
  - Voice capabilities display
  - Configuration status indicator

- `app/src/main/res/layout/activity_byok_settings.xml`
  - Material Design UI
  - Provider spinner
  - Secure API key input
  - Model selector
  - Voice capabilities card
  - Setup instructions

### 4. Security & Dependencies

**Updated Files:**
- `app/build.gradle.kts`
  - ✅ Added `androidx.security:security-crypto` for EncryptedSharedPreferences
  - ✅ Commented out Porcupine dependency (to be removed after testing)

- `gradle/libs.versions.toml`
  - ✅ Added security-crypto version

- `app/src/main/res/values/colors.xml`
  - ✅ Added BYOK UI colors

- `app/src/main/AndroidManifest.xml`
  - ✅ Registered BYOKSettingsActivity

---

## 🔄 Pending Tasks

### Phase 0A: Integration & Testing (Next Steps)

1. **Add BYOK Settings Button to SettingsActivity**
   - Add navigation button in `activity_settings.xml`
   - Wire up Intent to launch `BYOKSettingsActivity`

2. **Replace GeminiApi Usage**
   - Update `ConversationalAgentService.kt` to use `UniversalLLMService`
   - Update `v2/AgentService.kt` to use `UniversalLLMService`
   - Update utility functions in `utilities/` package
   - Search for all `GeminiApi` imports and replace

3. **Replace Voice API Usage**
   - Update `SpeechCoordinator` to use `UniversalSTTService` and `UniversalTTSService`
   - Replace Google TTS calls with universal service
   - Test voice functionality

4. **Remove Hard-coded API Keys**
   - Remove `GEMINI_API_KEYS` from `BuildConfig`
   - Remove `GOOGLE_TTS_API_KEY` from `BuildConfig`
   - Remove `ApiKeyManager.kt` (old key rotation system)
   - Update `local.properties.template`

5. **Remove Legacy Dependencies**
   - Remove Gemini SDK: `implementation(libs.generativeai)`
   - Remove Porcupine: `implementation("ai.picovoice:porcupine-android:3.0.2")`
   - Remove Google TTS references
   - Clean up unused imports

6. **Testing & Validation**
   - Test each provider (OpenRouter, AIMLAPI, Groq, etc.)
   - Verify encrypted key storage
   - Test voice STT/TTS with supported providers
   - Validate configuration flows
   - Test graceful fallback when not configured

---

## 📋 Migration Checklist

### Code Updates Required

- [ ] ConversationalAgentService.kt
  ```kotlin
  // Replace:
  // val geminiApi = GeminiApi(...)
  // With:
  private val llmService by lazy { UniversalLLMService(this) }
  ```

- [ ] v2/AgentService.kt
  ```kotlin
  // Replace:
  // llmApi = GeminiApi(...)
  // With:
  llmApi = UniversalLLMService(this)
  ```

- [ ] utilities/ApiHelpers.kt (if exists)
  - Replace `getReasoningModelApiResponse()` to use `UniversalLLMService`

- [ ] SpeechCoordinator.kt
  - Replace STT with `UniversalSTTService`
  - Replace TTS with `UniversalTTSService`

### Build Configuration Updates

- [ ] Remove from `app/build.gradle.kts`:
  ```kotlin
  buildConfigField("String", "GEMINI_API_KEYS", ...)
  buildConfigField("String", "GOOGLE_TTS_API_KEY", ...)
  buildConfigField("String", "PICOVOICE_ACCESS_KEY", ...)
  ```

- [ ] Remove from dependencies:
  ```kotlin
  implementation(libs.generativeai)
  implementation("ai.picovoice:porcupine-android:3.0.2")
  ```

### Files to Delete

- [ ] `app/src/main/java/com/blurr/voice/utilities/ApiKeyManager.kt`
- [ ] `app/src/main/java/com/blurr/voice/api/GeminiApi.kt` (after migration)
- [ ] `app/src/main/java/com/blurr/voice/api/GoogleTTS.kt` (after migration)
- [ ] `app/src/main/java/com/blurr/voice/api/PicovoiceKeyManager.kt`
- [ ] `app/src/main/java/com/blurr/voice/api/PorcupineWakeWordDetector.kt`

---

## 🎯 Expected Outcomes

After Phase 0 completion:

1. **No Hard-coded API Keys** ✅ Architecture Ready
   - All API keys stored encrypted locally
   - User provides their own keys via UI

2. **Multi-Provider Support** ✅ Architecture Ready
   - OpenRouter, AIMLAPI, Groq, Fireworks, Together, OpenAI
   - Easy to add more providers

3. **BYOK Voice** ✅ Architecture Ready
   - STT via Whisper (OpenAI/AIMLAPI/Groq)
   - TTS via OpenAI/AIMLAPI models
   - No developer-funded voice APIs

4. **Clean Dependencies** 🔄 Pending
   - Gemini SDK removed
   - Picovoice removed
   - Only essential libraries remain

5. **User Control** ✅ Architecture Ready
   - Users control their API costs
   - Privacy-first: keys never leave device
   - Model selection per provider

---

## 📖 User Guide (To Be Added to App)

### How to Set Up BYOK

1. **Get API Keys:**
   - OpenRouter: Visit [openrouter.ai](https://openrouter.ai)
   - AIMLAPI: Visit [aimlapi.com](https://aimlapi.com)
   - Groq: Visit [console.groq.com](https://console.groq.com)
   - Others as needed

2. **Configure in App:**
   - Open Settings → BYOK Settings
   - Select your provider
   - Enter API key
   - Choose a model
   - Save

3. **Start Using:**
   - All AI features now use your key
   - Monitor usage in your provider dashboard
   - Switch providers anytime

---

## 🔐 Security Notes

- API keys stored using Android EncryptedSharedPreferences
- Keys encrypted with AES256_GCM
- Keys never transmitted to our servers
- Fallback to regular SharedPreferences if encryption unavailable (logs warning)

---

## 🧪 Testing Strategy

1. **Unit Tests** (To be created)
   - ProviderKeyManager encryption/decryption
   - OpenAICompatibleAPI request building
   - Message format conversion

2. **Integration Tests**
   - Test each provider with real API
   - Verify STT/TTS functionality
   - Test error handling and retries

3. **UI Tests**
   - BYOKSettingsActivity flow
   - Key save/load/delete
   - Configuration validation

---

## 📊 Provider Comparison

| Provider | LLM | Vision | STT | TTS | Notes |
|----------|-----|--------|-----|-----|-------|
| OpenRouter | ✅ | ✅ | ❌ | ❌ | Access to 200+ models |
| AIMLAPI | ✅ | ✅ | ✅ | ✅ | All-in-one solution |
| Groq | ✅ | ❌ | ✅ | ❌ | Ultra-fast inference |
| Fireworks | ✅ | ✅ | ❌ | ❌ | Open source models |
| Together | ✅ | ✅ | ❌ | ❌ | Open source focus |
| OpenAI | ✅ | ✅ | ✅ | ✅ | Original API |

---

## 🚀 Next Phase Preview

**Phase 1 - MCP & Core Tools** (After Phase 0)
- Model Context Protocol (MCP) client
- Web search (Tavily, Exa, SerpAPI)
- Multimodal generation
- Google Workspace integration
- Ultra-Generalist AI Agent

---

## Change Log

- **2025-01-XX**: Created core BYOK architecture
- **2025-01-XX**: Added voice services (STT/TTS)
- **2025-01-XX**: Created BYOK Settings UI
- **2025-01-XX**: Integrated with build system

---

## Questions & Decisions

1. **Q: Should we keep Gemini SDK as fallback?**
   - A: No, pure BYOK approach. Users must configure keys.

2. **Q: What if user doesn't configure keys?**
   - A: Show friendly error with link to BYOK settings.

3. **Q: Support offline mode?**
   - A: Phase 2+ feature. Phase 0 requires internet.

4. **Q: Default provider?**
   - A: No default. User must choose and configure.

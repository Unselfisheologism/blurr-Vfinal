# ✅ TODO: Complete Phase 0 BYOK Implementation

## 🎯 Goal
Complete the remaining 30% of Phase 0 to have a fully functional BYOK system.

**Estimated Time: 6-8 hours**

---

## 📝 Checklist

### Part 1: Update LLM Usage (2-3 hours)

- [ ] **File 1: `agents/ClarificationAgent.kt`**
  - [ ] Replace `import com.twent.voice.api.GeminiApi` with `UniversalLLMService`
  - [ ] Update all GeminiApi usage
  - [ ] Add configuration check
  - [ ] Test clarification feature

- [ ] **File 2: `v2/llm/GeminiAPI.kt`**
  - [ ] Decide: Adapt or delete (recommend delete)
  - [ ] If adapting: Wrap UniversalLLMService
  - [ ] Update v2/Agent.kt accordingly

- [ ] **File 3: `v2/AgentService.kt`**
  - [ ] Replace GeminiApi with UniversalLLMService
  - [ ] Add configuration check in onCreate()
  - [ ] Update llmApi initialization
  - [ ] Test agent service

- [ ] **File 4: `v2/Agent.kt`**
  - [ ] Update import statement
  - [ ] Change llmApi type to UniversalLLMService
  - [ ] Test agent functionality

- [ ] **File 5: `utilities/LLMHelperFunctions.kt`**
  - [ ] Add context parameter to functions
  - [ ] Replace GeminiApi with UniversalLLMService
  - [ ] Update all callers to pass context
  - [ ] Test helper functions

- [ ] **File 6: `ConversationalAgentService.kt`**
  - [ ] Add `private val llmService by lazy { UniversalLLMService(this) }`
  - [ ] Add BYOK check in onCreate()
  - [ ] Update all getReasoningModelApiResponse() calls
  - [ ] Test conversation flow

### Part 2: Update Voice Usage (1 hour)

- [ ] **File 7: `utilities/TTSManager.kt`**
  - [ ] Replace GoogleTts with UniversalTTSService
  - [ ] Update voice synthesis calls
  - [ ] Test TTS functionality

- [ ] **File 8: `utilities/SpeechCoordinator.kt`**
  - [ ] Replace GoogleTts with UniversalTTSService
  - [ ] Update testVoice() method
  - [ ] Change voice parameter type (TTSVoice → String)
  - [ ] Test voice coordinator

- [ ] **File 9: `SettingsActivity.kt`**
  - [ ] Update availableVoices type to List<String>
  - [ ] Get voices from VoiceProviderConfig
  - [ ] Update voice picker setup
  - [ ] Test settings screen

### Part 3: Remove Hard-coded Keys (30 minutes)

- [ ] **Update `app/build.gradle.kts`**
  - [ ] Remove `apiKeys` variable
  - [ ] Remove `googleTtsApiKey` variable
  - [ ] Remove `picovoiceApiKey` variable
  - [ ] Remove `googlecloudGatewayPicovoice` variable
  - [ ] Remove corresponding buildConfigField statements
  - [ ] Verify build succeeds

- [ ] **Update `local.properties.template`**
  - [ ] Remove GEMINI_API_KEYS
  - [ ] Remove GOOGLE_TTS_API_KEY
  - [ ] Remove PICOVOICE_ACCESS_KEY
  - [ ] Remove GCLOUD_GATEWAY_PICOVOICE_KEY
  - [ ] Add comment about BYOK

### Part 4: Remove Dependencies (30 minutes)

- [ ] **Update `app/build.gradle.kts`**
  - [ ] Remove `implementation(libs.generativeai)`
  - [ ] Remove `implementation("ai.picovoice:porcupine-android:3.0.2")` (already commented)

- [ ] **Update `gradle/libs.versions.toml`**
  - [ ] Remove `generativeai = "0.9.0"` version
  - [ ] Remove generativeai library entry

- [ ] **Sync and build**
  - [ ] Run `./gradlew clean`
  - [ ] Run `./gradlew assembleDebug`
  - [ ] Fix any compilation errors

### Part 5: Delete Legacy Files (15 minutes)

- [ ] **Delete old implementations:**
  ```bash
  rm app/src/main/java/com/twent/voice/utilities/ApiKeyManager.kt
  rm app/src/main/java/com/twent/voice/api/GeminiApi.kt
  rm app/src/main/java/com/twent/voice/api/GoogleTTS.kt
  rm app/src/main/java/com/twent/voice/api/PicovoiceKeyManager.kt
  rm app/src/main/java/com/twent/voice/api/PorcupineWakeWordDetector.kt
  rm app/src/main/java/com/twent/voice/api/WakeWordDetector.kt
  ```

- [ ] **Remove imports:**
  - [ ] Search: `grep -r "import.*ApiKeyManager" app/src/main/java`
  - [ ] Remove all ApiKeyManager imports
  - [ ] Build and fix errors

### Part 6: Testing (2-3 hours)

- [ ] **Get API Keys**
  - [ ] OpenRouter: https://openrouter.ai (FREE tier)
  - [ ] Get API key
  - [ ] Note free model: `google/gemini-2.0-flash-exp:free`

- [ ] **Test BYOK Settings UI**
  - [ ] Build and install app
  - [ ] Open Settings → "🔑 API Keys (BYOK)"
  - [ ] Select OpenRouter
  - [ ] Enter API key
  - [ ] Select model: `google/gemini-2.0-flash-exp:free`
  - [ ] Click "Save Key"
  - [ ] Verify status shows "✓ Ready"

- [ ] **Test Conversation**
  - [ ] Trigger assistant (long-press home or app trigger)
  - [ ] Say or type: "Hello, can you hear me?"
  - [ ] Verify AI responds
  - [ ] Test 3-4 different conversations
  - [ ] Check logs for any errors

- [ ] **Test Error Handling**
  - [ ] Remove API key from settings
  - [ ] Try to use AI features
  - [ ] Verify friendly error message
  - [ ] Verify redirect to settings works

- [ ] **Test Voice (Optional)**
  - [ ] Configure AIMLAPI or OpenAI (if you have credits)
  - [ ] Test voice input
  - [ ] Test voice output
  - [ ] Or skip if not using voice initially

- [ ] **Test Different Providers**
  - [ ] Try Groq (free): https://console.groq.com
  - [ ] Model: `llama-3.3-70b-versatile`
  - [ ] Verify switching works

### Part 7: Verification (30 minutes)

- [ ] **Code Quality**
  - [ ] Run: `grep -r "GeminiApi" app/src/main/java --include="*.kt"`
  - [ ] Should find 0 results (or only comments)
  - [ ] Run: `grep -r "ApiKeyManager" app/src/main/java --include="*.kt"`
  - [ ] Should find 0 results
  - [ ] Run: `grep -r "GoogleTts" app/src/main/java --include="*.kt"`
  - [ ] Should find 0 results

- [ ] **Build Quality**
  - [ ] No compilation errors
  - [ ] No warnings about missing dependencies
  - [ ] App installs and runs
  - [ ] No crashes on startup

- [ ] **Feature Quality**
  - [ ] BYOK settings work
  - [ ] API keys save/load correctly
  - [ ] Conversation works
  - [ ] Voice works (if tested)
  - [ ] Error messages clear and helpful

### Part 8: Documentation (30 minutes)

- [ ] **Update README.md**
  - [ ] Add BYOK setup section
  - [ ] Add supported providers list
  - [ ] Add links to get API keys
  - [ ] Add screenshots (optional)

- [ ] **Update local.properties.template**
  - [ ] Remove old API key references
  - [ ] Add BYOK comment
  - [ ] Keep Appwrite config

- [ ] **Create User Guide** (optional)
  - [ ] How to get API keys
  - [ ] How to configure BYOK
  - [ ] Which features require which providers
  - [ ] Cost information

---

## 🎯 Success Criteria

Phase 0 is COMPLETE when:

1. ✅ All 13 files updated
2. ✅ No hard-coded API keys in code
3. ✅ No GeminiApi references in active code
4. ✅ No ApiKeyManager references
5. ✅ Gemini SDK removed from dependencies
6. ✅ Picovoice removed from dependencies
7. ✅ App builds without errors
8. ✅ BYOK settings UI works perfectly
9. ✅ Conversation works with at least one provider
10. ✅ Error handling works for unconfigured state

---

## 🚀 Quick Start Commands

### Build and Test
```bash
# Clean build
./gradlew clean

# Build debug
./gradlew assembleDebug

# Install
./gradlew installDebug

# Or all at once
./gradlew clean assembleDebug installDebug
```

### Search for Remaining Work
```bash
# Find GeminiApi usage
grep -r "GeminiApi" app/src/main/java --include="*.kt" | grep -v "//.*GeminiApi"

# Find ApiKeyManager usage
grep -r "ApiKeyManager" app/src/main/java --include="*.kt" | grep -v "//.*ApiKeyManager"

# Find GoogleTts usage
grep -r "GoogleTts" app/src/main/java --include="*.kt" | grep -v "//.*GoogleTts"

# Find BuildConfig API keys
grep -r "BuildConfig.GEMINI\|BuildConfig.GOOGLE_TTS" app/src/main/java --include="*.kt"
```

---

## 📚 Reference Documents

While working, refer to:

1. **INTEGRATION_GUIDE.md** - Detailed step-by-step for each file
2. **PHASE_0_NEXT_STEPS.md** - Code examples and patterns
3. **PHASE_0_BYOK_IMPLEMENTATION.md** - Architecture details

---

## 🐛 Common Issues & Solutions

### Issue: "Unresolved reference: GeminiApi"
**Solution:** Update the import to `UniversalLLMService`

### Issue: "BuildConfig.GEMINI_API_KEYS not found"
**Solution:** Remove all references to BuildConfig API keys

### Issue: "LLM service not configured"
**Solution:** Expected when no API key set. Show user friendly message.

### Issue: Voice tests fail
**Solution:** Check if provider supports STT/TTS. Only AIMLAPI and OpenAI support both.

### Issue: Build fails after removing dependencies
**Solution:** Clean build: `./gradlew clean build`

---

## ⏱️ Time Tracking

Track your progress:

- [ ] Part 1 (LLM): _____ hours (est. 2-3)
- [ ] Part 2 (Voice): _____ hours (est. 1)
- [ ] Part 3 (Keys): _____ hours (est. 0.5)
- [ ] Part 4 (Dependencies): _____ hours (est. 0.5)
- [ ] Part 5 (Cleanup): _____ hours (est. 0.25)
- [ ] Part 6 (Testing): _____ hours (est. 2-3)
- [ ] Part 7 (Verification): _____ hours (est. 0.5)
- [ ] Part 8 (Docs): _____ hours (est. 0.5)

**Total: _____ hours (target: 6-8)**

---

## 🎉 When Done

1. ✅ Check off all items above
2. ✅ Test thoroughly
3. ✅ Commit changes
4. ✅ Update PHASE_0_MIGRATION_COMPLETE.md
5. 🎊 Celebrate! Phase 0 is done!
6. 🚀 Ready for Phase 1!

---

## 💡 Pro Tips

1. **Work in order** - Follow the parts sequentially
2. **Test frequently** - After each major change
3. **Commit often** - So you can rollback if needed
4. **Use free tiers** - OpenRouter and Groq for testing
5. **Check logs** - `adb logcat` is your friend
6. **Keep old code** - Comment out before deleting (initially)
7. **Take breaks** - This is 6-8 hours of focused work

---

## 📞 Need Help?

Refer to these files:
- `INTEGRATION_GUIDE.md` - Detailed instructions
- `PHASE_0_NEXT_STEPS.md` - Step-by-step guide
- `README_BYOK_IMPLEMENTATION.md` - Overview

---

**Last Updated:** 2025-01-XX
**Status:** Ready to Execute
**Next Action:** Start with Part 1, File 1

**Let's finish Phase 0! 🚀**

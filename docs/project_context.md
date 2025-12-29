---
project_name: 'Blurr Mobile AI Super-Assistant'
user_name: 'James Abraham'
date: '2025-12-10'
---

# Project Context for AI Agents

> **CRITICAL:** Read this file completely before implementing ANY code in this project.
> This contains unobvious rules that will prevent bugs and maintain consistency.

---

## Technology Stack & Versions

| Technology | Version | Notes |
|------------|---------|-------|
| Kotlin | 1.9.22 | Primary language |
| Jetpack Compose | Latest stable | UI framework |
| Min SDK | 24 (Android 7.0) | Must support |
| Target SDK | 35 (Android 15) | Latest |
| Room | 2.6.x | Local database |
| OkHttp | Latest stable | HTTP client |
| Gradle | Kotlin DSL | Build system |

---

## 🚨 CRITICAL: DO NOT MODIFY

These files are **PRODUCTION CRITICAL** and must NOT be changed:

| File | Reason |
|------|--------|
| `ScreenInteractionService.kt` | Core phone automation (50KB, battle-tested) |
| `MainActivity.kt` home button logic | Long-press detection for assistant |
| Accessibility Service registration | Play Store compliance |

**If you need to add functionality, create NEW files instead of modifying these.**

---

## Package Structure

All new code MUST go in the correct package:

```
com.blurr.voice/
├── byok/           # FR1-12: API key management
├── mcp/            # FR30: MCP client
├── agent/          # FR19-29: AI agent
├── google/         # FR31-35: Google Workspace
├── apps/           # FR36-41: AI-native apps
├── workflows/      # FR42-47: Workflow automation
├── subscription/   # FR48-52: Monetization
└── data/           # Shared data layer
```

---

## Naming Conventions

### Kotlin Code

```kotlin
// Classes: PascalCase
class AIProviderRouter { }
class BYOKSettingsScreen { }

// Functions: camelCase with verb prefix
fun getApiKey(): String { }
fun sendMessage(text: String) { }
fun validateBalance(): Boolean { }

// Variables: camelCase
val userId: String
val providerBalance: Double

// Constants: SCREAMING_SNAKE
const val MAX_RETRIES = 3
const val DEFAULT_MODEL = "gpt-4"

// Packages: lowercase.dotted
package com.blurr.voice.byok
```

### Database

```kotlin
// Tables: snake_case, singular
@Entity(tableName = "api_key")
@Entity(tableName = "conversation")

// Columns: snake_case
@ColumnInfo(name = "created_at")
@ColumnInfo(name = "provider_name")

// Foreign keys: {table}_id
@ColumnInfo(name = "user_id")
```

### API/JSON

```kotlin
// JSON fields: camelCase
data class ApiResponse(
    val userId: String,
    val createdAt: String  // ISO 8601
)
```

---

## Error Handling Pattern

**ALWAYS use this pattern for errors:**

```kotlin
sealed class Result<T> {
    data class Success<T>(val data: T) : Result<T>()
    data class Error<T>(val error: AIError) : Result<T>()
}

data class AIError(
    val code: String,      // "AUTH_FAILED", "RATE_LIMIT"
    val message: String,   // User-friendly message
    val provider: String?  // "OpenRouter", "Groq", etc.
)
```

**Error Code Prefixes:**
- `AUTH_` — Authentication errors
- `RATE_` — Rate limit errors
- `BALANCE_` — Credit/balance errors
- `NETWORK_` — Connectivity errors
- `PROVIDER_` — AI provider errors

---

## State Management Pattern

**ALWAYS use StateFlow in ViewModels:**

```kotlin
class ExampleViewModel : ViewModel() {
    // Private mutable state
    private val _uiState = MutableStateFlow(ExampleUiState())
    
    // Public immutable state
    val uiState: StateFlow<ExampleUiState> = _uiState.asStateFlow()
    
    // Update state with copy()
    fun updateSomething(value: String) {
        _uiState.update { it.copy(someField = value) }
    }
}

// In Composable:
val uiState by viewModel.uiState.collectAsStateWithLifecycle()
```

---

## BYOK (Bring Your Own Key) Rules

### API Keys MUST:
1. Be encrypted with AES-256 before storage
2. Use Android Keystore for master key
3. NEVER be transmitted to our servers
4. Be stored in EncryptedSharedPreferences

### Provider Routing:
```kotlin
interface AIProvider {
    suspend fun chat(messages: List<Message>): Result<ChatResponse>
    suspend fun getBalance(): Result<Balance>
    val providerName: String
}
```

All AI calls go through `AIProviderRouter` which:
1. Selects correct provider based on user's API key
2. Handles rate limiting per provider
3. Implements retry with exponential backoff
4. Falls back to alternate providers if configured

---

## Testing Requirements

| Test Type | Location | Naming |
|-----------|----------|--------|
| Unit tests | `app/src/test/` | `{Class}Test.kt` |
| Integration | `app/src/androidTest/` | `{Feature}IntegrationTest.kt` |
| UI tests | `app/src/androidTest/` | `{Screen}UITest.kt` |

**Minimum Coverage:**
- All public functions in repositories
- All ViewModel state transitions
- All AIProvider implementations

---

## Anti-Patterns to AVOID

### ❌ DO NOT:

```kotlin
// DON'T store API keys in plain text
val apiKey = sharedPrefs.getString("api_key", "")  // ❌ WRONG

// DON'T make AI calls directly
val response = okHttpClient.newCall(request)  // ❌ WRONG

// DON'T modify state directly
_uiState.value.someField = newValue  // ❌ WRONG

// DON'T use callbacks for async
interface Callback { fun onResult() }  // ❌ WRONG
```

### ✅ DO:

```kotlin
// DO use encrypted storage
val apiKey = encryptedStorage.getApiKey()  // ✅ CORRECT

// DO use AIProviderRouter
val response = aiProviderRouter.chat(messages)  // ✅ CORRECT

// DO use copy() for state updates
_uiState.update { it.copy(someField = newValue) }  // ✅ CORRECT

// DO use coroutines/Flow
suspend fun doSomething(): Result<T>  // ✅ CORRECT
```

---

## Logging Standards

```kotlin
import timber.log.Timber

// DEBUG: Development details (stripped in release)
Timber.d("API call to ${provider.name}")

// INFO: Key user actions
Timber.i("User connected API key for OpenRouter")

// WARN: Recoverable issues
Timber.w("Rate limit hit, retrying in ${backoff}ms")

// ERROR: Failures with stack trace
Timber.e(exception, "Failed to decrypt API key")
```

---

## Play Store Compliance

These MUST be maintained for store approval:

1. **Accessibility Service Disclosure** — Show dialog explaining usage
2. **Foreground Service Notice** — Notification when running workflows
3. **User Data Policy** — BYOK model, keys stored locally
4. **In-App Purchases** — Use Google Play Billing for subscriptions

---

## Quick Reference

| Need to... | Use... |
|------------|--------|
| Make AI call | `aiProviderRouter.chat()` |
| Store API key | `encryptedStorage.saveApiKey()` |
| Update UI state | `_uiState.update { it.copy() }` |
| Handle error | `Result.Error(AIError(...))` |
| Log message | `Timber.d/i/w/e()` |
| Schedule task | `WorkManager` |
| Run long task | `ForegroundService` |

---

**Last Updated:** 2025-12-10  
**Source:** PRD + Architecture documents

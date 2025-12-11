# Story 1.1: Appwrite Auth Migration

Status: review

## Story

As a user,
I want to create an account and login with Appwrite,
so that I can securely access my personal settings and sync data.

## Acceptance Criteria

1. **Sign Up:** Given I am a new user, When I tap "Create Account" and enter email/password (min 8 chars), Then an account is created in Appwrite and I am logged in.
2. **Login:** Given I am an existing user, When I enter credentials and tap Login, Then I am authenticated via Appwrite and redirected to the Home screen.
3. **Session Persistence:** Given I have logged in, When I restart the app, Then my session is restored automatically without re-login.
4. **Logout:** Given I am logged in, When I tap Logout, Then my session is cleared and I am returned to the Login screen.
5. **Error Handling:** Given network is down or credentials are wrong, When I attempt auth, Then a clear error message (from `AIError`) is displayed.
6. **Firebase Removal:** Firebase Authentication logic is replaced by Appwrite (Firebase dependencies can remain for Phase 0 if needed for other features, but Auth path must use Appwrite).

## Tasks / Subtasks

- [x] **Infrastructure Setup** (AC: N/A)
  - [x] Add Appwrite Android SDK dependency to `build.gradle.kts`
  - [x] Configure Appwrite Client in DI module (`AppModule` / Hilt) with Endpoint and Project ID (use secrets gradle plugin or local.properties for ID if possible, or hardcode if public client ID)

- [x] **Data Layer Implementation** (AC: 1, 2, 3, 4, 5)
  - [x] Create `AuthRepository` interface
  - [x] Implement `AppwriteAuthRepository` using `Result<T, AIError>` pattern
  - [x] Map Appwrite exceptions to `AIError.Auth` types

- [x] **Domain/ViewModel Layer** (AC: 1, 2, 3, 4, 5)
  - [x] Create/Update `AuthViewModel`
  - [x] Expose `StateFlow<AuthUiState>`

- [x] **UI Implementation** (AC: 1, 2, 5)
  - [x] Create/Update `LoginScreen` (Compose)
  - [x] Create/Update `SignUpScreen` (Compose)
  - [x] Handle UI loading states and error snackbars

- [x] **Integration** (AC: 3)
  - [x] Update `MainActivity` or root navigation to check session on launch
  - [x] Verify navigation to Home on success

## Dev Notes

### Architecture & Patterns
- **Pattern:** MVVM + Clean Architecture (Repository Pattern).
- **Error Handling:** Use `com.blurr.voice.core.result.Result` (or equivalent defined in Context). Do NOT throw exceptions to UI.
- **State Management:** `ViewModel` holds `_uiState` (`MutableStateFlow`) exposed as `StateFlow`.
- **Dependency Verson:** Check latest Appwrite Android SDK (likely ~4.0.0 or 5.0.0).
- **Brownfield Constraint:** Do NOT modify `ScreenInteractionService`. Ensure Auth changes don't break accessibility service startup (though they should be independent).

### Project Structure Notes
- **New Package:** `com.blurr.voice.auth` (or check existing auth package).
- **DI:** Use Hilt/Dagger if present, or Manual DI if that's the current pattern (Project Context implies Hilt/Koin likely for "StateFlow" modern stack).
- **BYOK:** This is for Appwrite Account (infrastructure), NOT BYOK AI keys. AI keys are stored locally (Epic 1.2), but user account helps sync settings later.

### References
- [Source: docs/project_context.md#Technical Stack]
- [Source: docs/epics.md#Epic 1: BYOK Foundation]
- [Source: docs/architecture.md#Authentication & Security]

## Dev Agent Record

### Context Reference
<!-- Path(s) to story context XML will be added here by context workflow -->

### Agent Model Used
Vertex AI Gemini 1.5 Pro

### Debug Log References
- Infrastructure Setup: Verified in build.gradle.kts
- Auth Flow: Logic implemented in AppwriteAuthRepository
- UI: Replaced LoginActivity with Compose Screens

### Completion Notes List
- Implemented Appwrite Auth (Login, SignUp, Session Management)
- Created `AppwriteManager` singleton for manual DI (Brownfield adaptation)
- Replaced `LoginActivity` XML with Compose `LoginScreen` and `SignUpScreen`
- Updated `MainActivity` to use Appwrite session check instead of Firebase
- Commented out Firebase Firestore logic in `MainActivity` (needs migration in future tasks)

### File List
- gradle/libs.versions.toml
- app/build.gradle.kts
- app/src/main/java/com/blurr/voice/auth/AppwriteManager.kt
- app/src/main/java/com/blurr/voice/MyApplication.kt
- app/src/main/java/com/blurr/voice/core/result/Result.kt
- app/src/main/java/com/blurr/voice/auth/AuthRepository.kt
- app/src/main/java/com/blurr/voice/auth/AppwriteAuthRepository.kt
- app/src/main/java/com/blurr/voice/auth/AuthViewModel.kt
- app/src/main/java/com/blurr/voice/auth/ui/LoginScreen.kt
- app/src/main/java/com/blurr/voice/auth/ui/SignUpScreen.kt
- app/src/main/java/com/blurr/voice/LoginActivity.kt.kt
- app/src/main/java/com/blurr/voice/MainActivity.kt

# Blurr (Panda) - Source Tree Analysis

## Project Structure Overview

```
blurr-Vfinal/
├── .bmad/                    # BMAD methodology configuration
├── .github/                  # GitHub workflows
├── app/                      # Main Android application module
│   ├── src/
│   │   ├── androidTest/      # Android instrumentation tests
│   │   ├── main/            # Main source code
│   │   │   ├── java/com/blurr/voice/  # App package root
│   │   │   ├── res/         # Android resources (108 items)
│   │   │   ├── assets/      # App assets
│   │   │   └── AndroidManifest.xml
│   │   └── test/            # Unit tests (6 items)
│   ├── build.gradle.kts     # App-level build config
│   └── proguard-rules.pro   # Proguard configuration
├── docs/                    # Documentation folder
│   └── sprint-artifacts/    # Sprint-related documents
├── gradle/                  # Gradle wrapper
├── build.gradle.kts         # Root build config
├── settings.gradle.kts      # Project settings
├── local.properties.template # API keys template
├── version.properties       # Version management
├── LICENSE                  # Personal use license
└── README.md               # Project README
```

## Source Code Structure (`com.blurr.voice`)

### Root Level Files (23 files) - Activities & Core Services

| File | Size | Purpose |
|------|------|---------|
| **ConversationalAgentService.kt** | 66KB | Core AI agent service - handles conversation flow |
| **ScreenInteractionService.kt** | 50KB | Accessibility service for UI automation |
| **MainActivity.kt** | 36KB | Main entry point and dashboard |
| **LoginActivity.kt.kt** | 24KB | Authentication and login flow |
| **OnboardingPermissionsActivity.kt** | 21KB | Onboarding flow with permission requests |
| **SettingsActivity.kt** | 16KB | App settings management |
| **MemoriesActivity.kt** | 10KB | User memories/conversation history |
| **PermissionsActivity.kt** | 10KB | Permission handling |
| **DialogueActivity.kt** | 9KB | Interactive dialogue UI |
| **ProPurchaseActivity.kt** | 8KB | In-app purchase flow |
| **AudioWaveView.kt** | 7KB | Audio visualization component |
| **MomentsActivity.kt** | 5KB | Moments feature |
| **RoleRequestActivity.kt** | 5KB | Role/capability requests |
| **MyApplication.kt** | 5KB | Application class |
| **BaseNavigationActivity.kt** | 4KB | Base navigation component |
| **GlowBorderView.kt** | 3KB | UI glow effect component |
| **ChatActivity.kt** | 2KB | Chat interface |
| **MomentsAdapter.kt** | 2KB | Moments list adapter |
| **MemoriesAdapter.kt** | 2KB | Memories list adapter |
| **PandaWidgetProvider.kt** | 2KB | Home screen widget |
| **ChatAdapter.kt** | 2KB | Chat message adapter |
| **AssistEntryActivity.kt** | 1KB | Assistant entry point |
| **PrivacyActivity.kt** | 1KB | Privacy policy display |

### Package Structure (10 packages)

#### `agents/` - AI Agent Implementations
Contains the Operator agent with notepad functionality for task execution.

#### `api/` - API Layer (10 files)
Backend communication, LLM API integration, and network services.
- Gemini API integration
- Google Cloud services
- Proxy configurations

#### `data/` - Data Layer (6 files)
Local data persistence using Room database.
- Memories storage
- Settings persistence
- Conversation history

#### `intents/` - Intent Handlers (6 files)
Android intent processing for various app actions and deep links.

#### `overlay/` - Overlay Components (3 files)
Floating UI overlays for interaction while other apps are in focus.

#### `services/` - Background Services (3 files)
Background processing services beyond the main accessibility service.

#### `triggers/` - Trigger System (13 files)
Wake word detection and various trigger mechanisms.
- Picovoice Porcupine wake word
- UI triggers
- Event-based triggers

#### `ui/` - UI Components (5 files)
Reusable Compose UI components and theming.

#### `utilities/` - Utility Classes (25 files)
Helper functions, extensions, and common utilities.
- String utilities
- Permission helpers
- Network utilities
- Audio processing

#### `v2/` - Version 2 Components (14 files)
Newer implementations and experimental features.

## Critical Directories

| Directory | Description | Importance |
|-----------|-------------|------------|
| `agents/` | Core AI agent logic | 🔴 Critical |
| `api/` | External service integration | 🔴 Critical |
| `triggers/` | Wake word and activation | 🟡 High |
| `services/` | Background processing | 🟡 High |
| `data/` | Local persistence | 🟢 Medium |
| `ui/` | UI components | 🟢 Medium |
| `utilities/` | Helper functions | 🟢 Medium |

## Entry Points

| Entry Point | Type | Description |
|-------------|------|-------------|
| `MainActivity` | Activity | Main dashboard and entry |
| `AssistEntryActivity` | Activity | Quick assist activation |
| `ConversationalAgentService` | Service | Core agent processing |
| `ScreenInteractionService` | AccessibilityService | UI automation |
| `PandaWidgetProvider` | Widget | Home screen widget entry |

## Resource Structure (`res/`)

```
res/
├── drawable/        # Vector assets and images
├── layout/         # XML layouts (legacy)
├── mipmap/         # App icons
├── raw/            # Audio files, prompts
├── values/         # Strings, colors, themes
└── xml/            # Accessibility service config
```

---

*Generated by BMad Document Project Workflow on 2025-12-10*

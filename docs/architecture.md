---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8]
inputDocuments:
  - docs/prd.md
  - docs/index.md
  - docs/project-overview.md
  - docs/source-tree-analysis.md
  - docs/development-guide.md
  - WHATIWANT.md
workflowType: 'architecture'
lastStep: 8
status: 'complete'
completedAt: '2025-12-10'
project_name: 'Twent Mobile AI Super-Assistant'
user_name: 'James Abraham'
date: '2025-12-10'
---

# Architecture Decision Document - Twent Mobile AI Super-Assistant

**Author:** James Abraham  
**Date:** 2025-12-10

---

## Project Context Analysis

### Requirements Overview

**Functional Requirements (55 FRs):**
- 9 capability areas: BYOK, voice, phone automation, AI agent, Google Workspace, AI-native apps (6), workflow automation, subscriptions, admin
- Core agent functionality with tool orchestration
- Multi-provider AI routing with balance tracking
- MCP client protocol compliance for tool extensibility

**Non-Functional Requirements (20+ NFRs):**
- Performance: P95 <3s AI latency, 60fps UI, <100ms accessibility actions
- Security: AES-256 encrypted keys in Android Keystore, TLS 1.3
- Privacy: BYOK keys never transmitted, local-first storage
- Reliability: 99.5% crash-free, 99.9% Accessibility Service uptime
- Compatibility: Android 7.0-15, major OEM skins

**Scale & Complexity:** HIGH
- Primary domain: Android Mobile + AI
- 8-10 major architectural components
- 6 AI-native applications
- 10+ external integration points

### Technical Constraints & Dependencies

1. **Brownfield Constraints:**
   - `ScreenInteractionService.kt` (50KB) — DO NOT MODIFY
   - `ConversationalAgentService.kt` (66KB) — Refactor for BYOK/MCP
   - Firebase → Appwrite migration required
   - Picovoice → BYOK voice migration required

2. **Platform Constraints:**
   - Android Keystore for secure key storage
   - WorkManager for background scheduling
   - Foreground Service for long-running workflows
   - Accessibility Service for phone automation

### Cross-Cutting Concerns

| Concern | Affects | Resolution Strategy |
|---------|---------|---------------------|
| BYOK Routing | Agent, Voice, Media, Apps | Central abstraction layer |
| Error Handling | All providers | Graceful degradation |
| Credential Storage | Keys, OAuth, sessions | Android Keystore |
| Background Tasks | Workflows, triggers | WorkManager + ForegroundService |
| State Persistence | All data | Room + optional Appwrite sync |
| Analytics | All features | Opt-in, privacy-respecting |

---

## Foundation Evaluation (Brownfield)

### Existing Architecture (Preserved)

| Category | Technology | Status |
|----------|------------|--------|
| Language | Kotlin 1.9.22 | ✅ Keep |
| UI | Jetpack Compose | ✅ Keep |
| Architecture | MVVM + Repository | ✅ Keep |
| Database | Room | ✅ Keep |
| HTTP Client | OkHttp | ✅ Keep |
| JSON | Moshi/Gson | ✅ Keep |
| Build | Gradle Kotlin DSL | ✅ Keep |

### Migration Required

| From | To | Rationale |
|------|----|-----------| 
| Firebase Auth | Appwrite Auth | Zero developer-funded compute |
| Firebase Firestore | Appwrite Database | BYOK model alignment |
| Firebase Analytics | Appwrite/Custom | Privacy-first |
| Picovoice Porcupine | BYOK STT | User-provided API keys |

### New Dependencies

| Dependency | Purpose | Phase |
|------------|---------|-------|
| Appwrite SDK | Auth, DB, Storage | Phase 0 |
| MCP Client (custom) | Tool protocol | Phase 1 |
| WorkManager | Scheduled workflows | Phase 3 |
| DataStore (Encrypted) | Secure key storage | Phase 0 |

### Brownfield Constraints

**DO NOT MODIFY:**
- `ScreenInteractionService.kt` — Core phone automation
- `MainActivity.kt` home button detection logic
- Accessibility Service registration flow

**REFACTOR CAREFULLY:**
- `ConversationalAgentService.kt` — Add BYOK routing + MCP client
- API client layer — Multi-provider abstraction

### Modular Extension Strategy

New features added as separate packages:
- `com.twent.voice.byok` — API key management
- `com.twent.voice.mcp` — MCP protocol client
- `com.twent.voice.apps` — AI-native applications
- `com.twent.voice.workflows` — Automation engine

---

## Core Architectural Decisions

### Decision Priority

**Critical (Block Implementation):**
1. BYOK Provider Abstraction Layer
2. Appwrite Migration Strategy
3. Secure Key Storage Architecture
4. MCP Client Implementation

**Important (Shape Architecture):**
1. UI State Management Pattern
2. Background Task Strategy
3. Error Handling Standards

**Deferred (Post-MVP):**
1. Multi-device sync
2. Advanced caching
3. Plugin architecture

### Data Architecture

| Component | Technology | Purpose |
|-----------|------------|---------|
| Local DB | Room 2.6.x | Conversations, workflows |
| Remote DB | Appwrite Database | User profiles, sync |
| Secure Storage | EncryptedDataStore | API keys, tokens |
| Key Protection | Android Keystore | Master encryption key |

### Authentication & Security

| Layer | Implementation |
|-------|----------------|
| User Auth | Appwrite Auth (email, Google OAuth) |
| API Key Storage | AES-256 + Android Keystore |
| OAuth Tokens | Encrypted DataStore |
| Network | TLS 1.3, certificate pinning |

### API & Communication

| Pattern | Implementation | Usage |
|---------|----------------|-------|
| BYOK Routing | `AIProviderRouter` | All AI calls |
| Provider Interface | `AIProvider` sealed interface | OpenRouter, Groq, etc. |
| MCP Client | Custom Kotlin impl | Tool protocol |
| Error Handling | `Result<T, AIError>` | Type-safe errors |
| Streaming | OkHttp SSE | LLM responses |

### Mobile Architecture

| Layer | Technology |
|-------|------------|
| UI | Jetpack Compose + Material 3 |
| State | ViewModel + StateFlow |
| Navigation | Compose Navigation |
| Persistence | Repository pattern with Room |

### Infrastructure

| Component | Technology |
|-----------|------------|
| Background | WorkManager |
| Long-running | ForegroundService |
| Scheduling | WorkManager PeriodicWork |
| Crash Reporting | Sentry/Appwrite |
| Distribution | Google Play Store |

---

## Implementation Patterns & Consistency Rules

### Naming Conventions

**Kotlin/Android:**
- Classes: `PascalCase` (`AIProviderRouter`)
- Functions: `camelCase`, verb prefix (`getApiKey()`)
- Variables: `camelCase` (`userId`)
- Constants: `SCREAMING_SNAKE` (`MAX_RETRIES`)
- Packages: `lowercase.dotted` (`com.twent.voice.byok`)

**Database:**
- Tables: `snake_case`, singular (`api_key`, `conversation`)
- Columns: `snake_case` (`created_at`, `provider_name`)
- Foreign keys: `{table}_id`

**API/JSON:**
- Fields: `camelCase` (`{ "userId": 123 }`)
- Dates: ISO 8601 (`"2025-12-10T21:00:00Z"`)

### Package Structure

```
com.twent.voice/
├── ui/screens/        # Compose screens
├── ui/components/     # Reusable UI
├── viewmodel/         # ViewModels
├── repository/        # Data repositories
├── data/local/        # Room DAOs
├── data/remote/       # API clients
├── byok/              # BYOK feature
├── mcp/               # MCP client
├── apps/              # AI-native apps
└── workflows/         # Automation engine
```

### Error Handling

```kotlin
sealed class Result<T> {
    data class Success<T>(val data: T) : Result<T>()
    data class Error<T>(val error: AIError) : Result<T>()
}
```

**Error Code Prefixes:**
- `AUTH_` — Authentication
- `RATE_` — Rate limits
- `BALANCE_` — Credit/balance
- `NETWORK_` — Connectivity
- `PROVIDER_` — AI provider

### State Management

- ViewModel exposes `StateFlow<UiState>`
- UI collects via `collectAsStateWithLifecycle()`
- Updates: `_uiState.update { it.copy(...) }`

### Logging

| Level | Usage |
|-------|-------|
| DEBUG | Development |
| INFO | Key user actions |
| WARN | Recoverable issues |
| ERROR | Failures + stack trace |

---

## Project Structure & Boundaries

### Package Organization

```
com.twent.voice/
├── services/               # EXISTING - DO NOT MODIFY
│   └── ScreenInteractionService.kt
├── ConversationalAgentService.kt  # Refactor for BYOK/MCP
├── MainActivity.kt                # Add navigation
│
├── byok/                   # FR1-FR12: BYOK Management
│   ├── data/               # ApiKeyEntity, DAO, Repository
│   ├── provider/           # AIProvider interface + impls
│   ├── ui/                 # BYOKSettingsScreen
│   └── voice/              # STT/TTS providers
│
├── mcp/                    # FR30: MCP Client
│   ├── client/             # MCPClient, Transport, Message
│   ├── tools/              # Tool interface, Registry
│   └── server/             # MCPServerConnection
│
├── agent/                  # FR19-FR29: AI Agent
│   ├── core/               # AgentOrchestrator, ToolExecutor
│   ├── tools/              # WebSearch, ImageGen, etc.
│   ├── ui/                 # ChatScreen, ChatViewModel
│   └── reusable/           # ReusableTool storage
│
├── google/                 # FR31-FR35: Google Workspace
│   ├── auth/               # GoogleOAuthManager
│   ├── gmail/              # GmailService
│   ├── calendar/           # CalendarService
│   ├── drive/              # DriveService
│   └── sheets/             # SheetsService
│
├── apps/                   # FR36-FR41: AI-Native Apps
│   ├── common/             # AIAppBase
│   ├── texteditor/
│   ├── spreadsheets/
│   ├── daw/
│   ├── video/
│   ├── mediagen/
│   └── learning/
│
├── workflows/              # FR42-FR47: Workflow Automation
│   ├── engine/             # WorkflowEngine, Executor
│   ├── builder/            # Visual editor UI
│   ├── n8n/                # Import/Export
│   └── triggers/           # Schedule, Email, Calendar
│
├── subscription/           # FR48-FR52: Monetization
│   ├── SubscriptionManager.kt
│   └── UsageLimiter.kt
│
└── data/                   # Shared Data Layer
    ├── local/              # Room database
    └── remote/             # AppwriteClient
```

### Architectural Boundaries

| Boundary | Entry Point | Responsibility |
|----------|-------------|----------------|
| BYOK Router | `AIProviderRouter` | Route AI calls |
| MCP Client | `MCPClient` | External MCP servers |
| Google Auth | `GoogleOAuthManager` | OAuth flow |
| Appwrite | `AppwriteClient` | Auth, DB, Storage |

### FR Category Mapping

| FRs | Category | Package |
|-----|----------|---------|
| FR1-12 | BYOK | `byok/` |
| FR13-18 | Phone Automation | EXISTING |
| FR19-30 | AI Agent | `agent/` |
| FR31-35 | Google | `google/` |
| FR36-41 | Apps | `apps/` |
| FR42-47 | Workflows | `workflows/` |
| FR48-52 | Subscriptions | `subscription/` |

---

## Architecture Validation Results

### Coherence Validation ✅

All technology choices (Kotlin, Compose, Room, OkHttp, Appwrite) work 
together without conflicts. Implementation patterns align with MVVM 
architecture. Brownfield constraints properly documented.

### Requirements Coverage ✅

| Category | FRs | Status |
|----------|-----|--------|
| BYOK | FR1-12 | ✅ 100% |
| Phone Automation | FR13-18 | ✅ PRESERVED |
| AI Agent + MCP | FR19-30 | ✅ 100% |
| Google Workspace | FR31-35 | ✅ 100% |
| AI-Native Apps | FR36-41 | ✅ 100% |
| Workflows | FR42-47 | ✅ 100% |
| Subscriptions | FR48-52 | ✅ 100% |
| System | FR53-55 | ✅ 100% |

**Total:** 55/55 FRs supported

### Implementation Readiness ✅

- All critical decisions documented with versions
- Naming conventions comprehensive
- Error handling patterns defined
- Project structure FR-mapped

### Assessment

**Status:** 🟢 READY FOR IMPLEMENTATION  
**Confidence:** HIGH

**AI Agent Guidelines:**
1. Follow naming conventions exactly
2. Use `Result<T, AIError>` for errors
3. Respect package boundaries
4. DO NOT MODIFY `ScreenInteractionService.kt`

**First Priority:** Phase 0 — Appwrite migration + BYOK settings

---

## Architecture Completion Summary

### Workflow Status

| Metric | Value |
|--------|-------|
| Workflow | Architecture Decision Workflow |
| Status | ✅ COMPLETED |
| Steps Completed | 8/8 |
| Date | 2025-12-10 |
| Document | docs/architecture.md |

### Deliverables

- ✅ Project Context Analysis
- ✅ Foundation Evaluation (Brownfield)
- ✅ Core Architectural Decisions (5 categories)
- ✅ Implementation Patterns & Consistency Rules
- ✅ Project Structure & Boundaries (7 packages)
- ✅ Architecture Validation (100% FR coverage)

### Implementation Handoff

**For AI Agents:**
This document is your complete guide for implementing Twent Mobile AI Super-Assistant. 
Follow all decisions, patterns, and structures exactly as documented.

**Development Sequence:**
1. Initialize Phase 0 (Appwrite migration, BYOK settings)
2. Implement BYOK provider abstraction layer
3. Build MCP client for tool protocol
4. Develop AI agent orchestration
5. Create AI-native applications framework
6. Build workflow automation engine

---

**Architecture Status:** 🟢 READY FOR IMPLEMENTATION

**Next Phase:** Create Epics & Stories using `/bmad-bmm-workflows-create-epics-stories`

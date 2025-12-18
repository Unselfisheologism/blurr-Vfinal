---
title: "AI-Native Apps - Implementation Guide"
project: blurr-Vfinal
phase: "AI-Native Apps Implementation"
version: 1.0
date: 2025-12-18
status: Planning
author: BMAD Method
---

# AI-Native Apps Phase - Implementation Guide

This guide provides detailed technical specifications and implementation patterns for building the six AI-native apps.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Reusability Strategy](#reusability-strategy)
3. [App #1: Text Editor - Technical Spec](#app-1-text-editor)
4. [App #2: Spreadsheets - Technical Spec](#app-2-spreadsheets)
5. [App #3: Media Canvas - Technical Spec](#app-3-media-canvas)
6. [App #4: DAW - Technical Spec](#app-4-daw)
7. [App #5: Learning Platform - Technical Spec](#app-5-learning-platform)
8. [App #6: Video Editor - Technical Spec](#app-6-video-editor)
9. [Common Patterns & Best Practices](#common-patterns)
10. [Testing Strategy](#testing-strategy)

---

## Architecture Overview

### Module Structure

```
app/src/main/java/com/blurr/voice/
├── apps/                           # New directory for AI-native apps
│   ├── base/                       # Shared base classes
│   │   ├── BaseAppActivity.kt      # Common activity patterns
│   │   ├── BaseAppViewModel.kt     # Common VM patterns
│   │   ├── AgentIntegration.kt     # Agent communication layer
│   │   ├── ProGatingManager.kt     # Subscription checks
│   │   └── ExportHelper.kt         # File export utilities
│   ├── texteditor/                 # App #1
│   ├── spreadsheets/               # App #2
│   ├── mediacanvas/                # App #3 (Kotlin wrapper)
│   ├── daw/                        # App #4
│   ├── learning/                   # App #5
│   └── videoeditor/                # App #6
├── tools/                          # Existing - reuse all
├── ui/agent/                       # Existing AgentChatActivity
└── ...                             # Other existing packages
```

### Design Principles

1. **Maximize Reuse**: All apps use existing agent, tools, BYOK infrastructure
2. **Consistent UI**: Follow Material 3 design, Jetpack Compose patterns
3. **Pro Gating**: Consistent subscription checks, upgrade prompts
4. **Performance**: Background processing, progress indicators, caching
5. **Accessibility**: Screen reader support, large text, high contrast

---

## Reusability Strategy

### Existing Components to Leverage

#### 1. Agent & LLM Infrastructure ✅
- `UniversalLLMService`: BYOK for OpenRouter/AIMLAPI
- `ProviderKeyManager`: Secure API key storage
- `AgentChatActivity`: Chat UI pattern (reference for sidebar chats)
- System prompt management (extend per app)

#### 2. Tool Infrastructure ✅
**Media Generation Tools**:
- `ImageGenerationTool` - For text editor image insertion, media canvas
- `VideoGenerationTool` - For video editor, media canvas
- `AudioGenerationTool` - For DAW, video editor background audio
- `MusicGenerationTool` - For DAW, video editor music tracks
- `Model3DGenerationTool` - For media canvas
- `GenerateInfographicTool` - For presentations, documents

**Code Execution Tools**:
- `PythonShellTool` - Critical for spreadsheets (pandas, numpy, matplotlib), DAW (pydub), learning platform (PDF parsing)
- `UnifiedShellTool` (JavaScript) - For custom scripts, web scraping

**Integration Tools**:
- `ComposioTool` - Export to Google Docs/Sheets/Drive, Notion, social media
- `PhoneControlTool` - System integration if needed
- `PerplexitySonarTool` - Web research for learning platform
- `AskUserTool` - Clarifications during workflows

#### 3. UI Components ✅
- `BaseNavigationActivity` - Bottom nav pattern
- Compose UI patterns from existing activities
- Pro upgrade prompts (from `ProPurchaseActivity`)

#### 4. Flutter Module ✅ (App #3 Only)
- Existing workflow editor with fl_nodes
- Extend with media-specific node definitions
- Kotlin-Flutter bridge pattern already established

### What's New to Build

1. **Base App Infrastructure**:
   - `BaseAppActivity` with common nav/Pro gating
   - `BaseAppViewModel` with agent integration patterns
   - `AgentIntegration.kt` for system prompt management per app

2. **App-Specific UIs**:
   - Text editor: Rich text component with toolbar
   - Spreadsheets: Table view with cell editing
   - DAW: Multi-track timeline with audio playback
   - Learning Platform: Document viewer, flashcard UI, quiz UI
   - Video Editor: Video timeline with preview player

3. **Data Models**:
   - Room DB schemas for each app (documents, spreadsheets, projects, etc.)
   - JSON serialization for complex data (workflows, timelines)

4. **Export Logic**:
   - `ExportHelper.kt` wrapping existing tools + Composio

---

## App #1: Text Editor - Technical Spec

### Overview
Rich text editing with AI assistance for rewriting, summarizing, expanding content.

### Tech Stack
- **UI**: Jetpack Compose
- **Architecture**: MVVM (ViewModel + Repository)
- **Storage**: Room DB for documents
- **Agent**: Ultra-generalist with writing system prompt
- **Tools**: AskUserTool (clarifications), ComposioTool (export), PDF generation

### Data Models

```kotlin
// Room entity
@Entity(tableName = "documents")
data class Document(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    val title: String,
    val content: String,  // Markdown format
    val template: String? = null,  // Template used
    val createdAt: Long = System.currentTimeMillis(),
    val updatedAt: Long = System.currentTimeMillis(),
    val version: Int = 1  // For version history (Pro)
)

// UI state
data class TextEditorUiState(
    val document: Document? = null,
    val isLoading: Boolean = false,
    val aiOperationInProgress: Boolean = false,
    val selectedText: String? = null,
    val cursorPosition: Int = 0,
    val operationCount: Int = 0,  // For Pro limits
    val isProUser: Boolean = false
)

// AI operations
enum class TextOperation {
    REWRITE_PROFESSIONAL,
    REWRITE_CASUAL,
    REWRITE_CREATIVE,
    SUMMARIZE_BRIEF,
    SUMMARIZE_DETAILED,
    EXPAND,
    CONTINUE_WRITING,
    FIX_GRAMMAR,
    TRANSLATE
}
```

### System Prompt

```kotlin
val TEXT_EDITOR_SYSTEM_PROMPT = """
You are an AI writing assistant integrated into a text editor.

Your capabilities:
- Rewrite text in different tones (professional, casual, creative)
- Summarize content (brief or detailed)
- Expand on ideas with more detail
- Continue writing from a given point
- Fix grammar and spelling errors
- Translate text to other languages

Guidelines:
- Preserve the user's core message and intent
- Match the requested tone/style precisely
- For summaries, capture key points concisely
- For expansions, add relevant detail without fluff
- Always ask for clarification if the request is ambiguous
- Return ONLY the transformed text, no explanations unless asked

Current operation: {operation}
Selected text: {selectedText}
Additional context: {context}
""".trimIndent()
```

### Key Components


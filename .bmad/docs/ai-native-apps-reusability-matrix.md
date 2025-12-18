---
title: "AI-Native Apps - Component Reusability Matrix"
project: blurr-Vfinal
phase: "AI-Native Apps Implementation"
version: 1.0
date: 2025-12-18
status: Planning
author: BMAD Method
---

# AI-Native Apps - Component Reusability Matrix

This document maps existing components to new AI-native apps, maximizing code reuse.

---

## Reusability Summary

| Component Category | Reuse % | New Build % | Impact |
|-------------------|---------|-------------|---------|
| Agent & LLM Infrastructure | 100% | 0% | High - Core capability |
| Tool Infrastructure | 95% | 5% | High - Primary features |
| UI Framework | 80% | 20% | Medium - New specialized views |
| Data Layer | 30% | 70% | Medium - New schemas needed |
| Export/Integration | 90% | 10% | Medium - Wrapper utilities |

**Overall Reusability**: ~75% (strong leverage of existing infrastructure)

---

## Component Mapping by App

### App #1: Text Editor

| Component | Existing (Reuse) | New (Build) | Notes |
|-----------|------------------|-------------|-------|
| **Agent Core** | ✅ UniversalLLMService | System prompt extension | Rewrite/summarize/expand logic in prompt |
| **Tools** | ✅ AskUserTool, ComposioTool | None | For clarifications and export |
| **UI Framework** | ✅ Compose foundation, BaseNavigationActivity | Rich text editor component, formatting toolbar | Need Markdown support |
| **Data Layer** | ✅ Room DB pattern | Document schema, DAO | New tables for documents |
| **Pro Gating** | ✅ Subscription check logic | Operation counter, limit enforcement | Track daily AI ops |
| **Export** | ✅ PDF generation tool, Composio | Export helper wrapper | Markdown → PDF, Google Docs |

**Reuse Score**: 80%

---

### App #2: Spreadsheets Generator & Editor

| Component | Existing (Reuse) | New (Build) | Notes |
|-----------|------------------|-------------|-------|
| **Agent Core** | ✅ UniversalLLMService | Data analysis system prompt | Natural language → data generation |
| **Tools** | ✅ PythonShellTool, ComposioTool | None | Python for pandas/numpy/matplotlib, Composio for Google Sheets |
| **UI Framework** | ✅ Compose foundation | Table view component (LazyColumn with cells), chart preview | Complex cell editing needed |
| **Data Layer** | ✅ Room DB pattern | Spreadsheet schema, CSV/JSON storage | Store metadata in Room, data in files |
| **Pro Gating** | ✅ Subscription check logic | Spreadsheet count limit, row count limit | 10 sheets free, 1000 rows free |
| **Export** | ✅ Composio (Google Sheets) | CSV/Excel export via Python openpyxl | Python-based export |

**Reuse Score**: 70%

---

### App #3: Multimodal Media Gen Canvas

| Component | Existing (Reuse) | New (Build) | Notes |
|-----------|------------------|-------------|-------|
| **Agent Core** | ✅ UniversalLLMService | Workflow planning system prompt | Suggest node connections, optimize parameters |
| **Tools** | ✅ ALL media tools (Image, Video, Audio, Music, 3D, Infographic), PythonShellTool, UnifiedShellTool | None | All generation tools reused |
| **UI Framework** | ✅ Flutter workflow editor (fl_nodes), Kotlin-Flutter bridge | Media node definitions, execution engine, Kotlin wrapper activity | Extend existing Flutter module |
| **Data Layer** | ✅ JSON serialization pattern | Workflow JSON schema | Save/load workflows |
| **Pro Gating** | ✅ Subscription check logic | Execution count limit, model selection per node | 20 executions/day free |
| **Export** | ✅ Media output storage | Workflow sharing/export | Share workflow JSON |

**Reuse Score**: 85% (highest reuse - leverages all tools)

---

### App #4: DAW (Digital Audio Workstation)

| Component | Existing (Reuse) | New (Build) | Notes |
|-----------|------------------|-------------|-------|
| **Agent Core** | ✅ UniversalLLMService | Music production system prompt | Mixing advice, music theory knowledge |
| **Tools** | ✅ MusicGenerationTool, AudioGenerationTool, PythonShellTool | None | Music gen, audio effects via Python pydub/librosa |
| **UI Framework** | ✅ Compose foundation | Custom multi-track timeline view, waveform preview, playback controls | Complex audio UI needed |
| **Data Layer** | ✅ Room DB pattern | Project schema, audio file management | Store metadata, reference audio files |
| **Pro Gating** | ✅ Subscription check logic | Track count limit, effect library access | 8 tracks free, unlimited Pro |
| **Export** | ✅ Composio (streaming platforms) | MP3/WAV export, stem separation | Audio file export |

**Reuse Score**: 65%

---

### App #5: Learning Platform (NotebookLM-like)

| Component | Existing (Reuse) | New (Build) | Notes |
|-----------|------------------|-------------|-------|
| **Agent Core** | ✅ UniversalLLMService | Educational system prompt, Socratic method | Q&A with citations, study tool generation |
| **Tools** | ✅ PythonShellTool (PDF parsing), AudioGenerationTool (study guides), PerplexitySonarTool (research), ComposioTool | None | PDF/DOCX parsing via Python, audio overviews |
| **UI Framework** | ✅ Compose foundation, chat pattern from AgentChatActivity | Document viewer, flashcard UI, quiz UI, progress tracking | Specialized study interfaces |
| **Data Layer** | ✅ Room DB pattern | Document metadata, knowledge base (text chunking), progress tracking | SQLite FTS for semantic search |
| **Pro Gating** | ✅ Subscription check logic | Document count limit, advanced features | 5 docs free, unlimited Pro |
| **Export** | ✅ ComposioTool | Note export to Google Docs/Notion | Composio-based |

**Reuse Score**: 75%

---

### App #6: Video Editor (CapCut-like)

| Component | Existing (Reuse) | New (Build) | Notes |
|-----------|------------------|-------------|-------|
| **Agent Core** | ✅ UniversalLLMService | Video editing system prompt | Transition/effect suggestions, storytelling guidance |
| **Tools** | ✅ VideoGenerationTool, MusicGenerationTool, PythonShellTool (FFmpeg), ComposioTool | None | Video gen, music, FFmpeg via Python subprocess, social sharing |
| **UI Framework** | ✅ Compose foundation | Multi-track video timeline, video preview player, clip thumbnails | Most complex UI |
| **Data Layer** | ✅ Room DB pattern | Video project schema, clip management | Store metadata, reference video files |
| **Pro Gating** | ✅ Subscription check logic | Resolution limits, export count limits | 720p free, 1080p/4K Pro |
| **Export** | ✅ ComposioTool (YouTube, TikTok) | MP4 export with resolution selection | FFmpeg-based export |

**Reuse Score**: 65%

---

## Tool Usage Matrix

| Tool | Text Editor | Spreadsheets | Media Canvas | DAW | Learning | Video Editor |
|------|-------------|--------------|--------------|-----|----------|--------------|
| **UniversalLLMService** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **PythonShellTool** | ❌ | ✅ (critical) | ✅ (custom nodes) | ✅ (audio effects) | ✅ (PDF parsing) | ✅ (FFmpeg) |
| **UnifiedShellTool** | ❌ | ❌ | ✅ (custom nodes) | ❌ | ❌ | ❌ |
| **ImageGenerationTool** | ⚠️ (optional) | ❌ | ✅ | ❌ | ❌ | ⚠️ (optional) |
| **VideoGenerationTool** | ❌ | ❌ | ✅ | ❌ | ❌ | ✅ |
| **AudioGenerationTool** | ❌ | ❌ | ✅ | ✅ | ✅ (study guides) | ✅ |
| **MusicGenerationTool** | ❌ | ❌ | ✅ | ✅ (critical) | ❌ | ✅ |
| **Model3DGenerationTool** | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ |
| **GenerateInfographicTool** | ⚠️ (optional) | ⚠️ (data viz) | ✅ | ❌ | ❌ | ⚠️ (thumbnails) |
| **ComposioTool** | ✅ (export) | ✅ (Google Sheets) | ❌ | ✅ (streaming) | ✅ (export notes) | ✅ (social media) |
| **AskUserTool** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **PerplexitySonarTool** | ⚠️ (research) | ⚠️ (data research) | ❌ | ❌ | ✅ (research) | ❌ |
| **PhoneControlTool** | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |

✅ = Primary use  
⚠️ = Optional/secondary use  
❌ = Not used

---

## Flutter Module Usage

### Scope
**ONLY App #3 (Media Canvas)** uses Flutter module.

### Rationale
- Flutter module exists for **workflow visual editor** (fl_nodes package)
- fl_nodes provides node-based canvas UI (drag-drop, connections)
- Media Canvas needs node-based interface for multimodal workflows
- All other apps are standard Android UIs → use Kotlin/Compose

### Flutter Module Extension Plan

```
flutter_workflow_editor/lib/
├── workflow_editor_screen.dart           # Existing - workflow editor
├── models/
│   ├── workflow.dart                     # Existing
│   ├── workflow_node.dart                # Existing
│   ├── node_definitions.dart             # Existing - extend with media nodes
│   └── media_node_definitions.dart       # NEW - Image/Video/Audio/Music/3D nodes
├── nodes/
│   ├── unified_shell_node.dart           # Existing
│   ├── composio_node.dart                # Existing
│   ├── mcp_node.dart                     # Existing
│   └── media_nodes.dart                  # NEW - Media-specific nodes
└── services/
    ├── workflow_execution_engine.dart    # Existing - extend for media tools
    └── platform_bridge.dart              # Existing - Kotlin-Flutter bridge
```

### New Media Nodes to Add
1. **ImageGenNode**: Prompt → Image (via ImageGenerationTool)
2. **VideoGenNode**: Prompt → Video (via VideoGenerationTool)
3. **AudioGenNode**: Prompt → Audio (via AudioGenerationTool)
4. **MusicGenNode**: Prompt → Music (via MusicGenerationTool)
5. **Model3DGenNode**: Prompt → 3D model (via Model3DGenerationTool)
6. **InfographicNode**: Data → Infographic (via GenerateInfographicTool)
7. **TransformNode**: Image → Styled image (style transfer, upscale)
8. **ComposeNode**: Multiple inputs → Combined output
9. **ExportNode**: Save output to gallery/storage

### Kotlin Wrapper Activity

```kotlin
// app/src/main/kotlin/com/blurr/voice/apps/mediacanvas/MediaCanvasActivity.kt

class MediaCanvasActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Embed Flutter view with media canvas configuration
        val flutterEngine = FlutterEngineCache.getInstance()
            .get(FLUTTER_ENGINE_ID) ?: createFlutterEngine()
        
        val flutterView = FlutterView(this)
        flutterView.attachToFlutterEngine(flutterEngine)
        
        // Configure method channel for tool execution
        setupToolBridge(flutterEngine)
        
        setContentView(flutterView)
    }
    
    private fun setupToolBridge(engine: FlutterEngine) {
        MethodChannel(engine.dartExecutor.binaryMessenger, "media_canvas/tools")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "executeMediaTool" -> {
                        val toolName = call.argument<String>("toolName")
                        val params = call.argument<Map<String, Any>>("params")
                        executeToolAsync(toolName, params, result)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
```

---

## Database Schema Overview

### Shared Base Tables
- `users` - Existing (Appwrite sync)
- `subscription_status` - Existing (Pro gating)

### App-Specific Tables

#### Text Editor
```sql
CREATE TABLE documents (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    content TEXT NOT NULL,  -- Markdown
    template TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    version INTEGER DEFAULT 1
);

CREATE TABLE document_versions (  -- Pro only
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    document_id INTEGER NOT NULL,
    content TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    FOREIGN KEY (document_id) REFERENCES documents(id)
);
```

#### Spreadsheets
```sql
CREATE TABLE spreadsheets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    data_file_path TEXT NOT NULL,  -- Path to CSV/JSON file
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    row_count INTEGER DEFAULT 0,
    column_count INTEGER DEFAULT 0
);
```

#### Media Canvas
```sql
CREATE TABLE workflows (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    workflow_json TEXT NOT NULL,  -- Serialized workflow
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    execution_count INTEGER DEFAULT 0
);
```

#### DAW
```sql
CREATE TABLE daw_projects (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    project_json TEXT NOT NULL,  -- Track metadata, timeline
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);

CREATE TABLE audio_clips (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL,
    file_path TEXT NOT NULL,
    track_number INTEGER NOT NULL,
    start_time_ms INTEGER NOT NULL,
    duration_ms INTEGER NOT NULL,
    FOREIGN KEY (project_id) REFERENCES daw_projects(id)
);
```

#### Learning Platform
```sql
CREATE TABLE learning_documents (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    file_path TEXT NOT NULL,
    content_text TEXT,  -- Extracted text
    created_at INTEGER NOT NULL,
    processed BOOLEAN DEFAULT FALSE
);

CREATE TABLE flashcards (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    document_id INTEGER NOT NULL,
    question TEXT NOT NULL,
    answer TEXT NOT NULL,
    FOREIGN KEY (document_id) REFERENCES learning_documents(id)
);

CREATE TABLE study_progress (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    document_id INTEGER NOT NULL,
    flashcard_id INTEGER,
    correct_count INTEGER DEFAULT 0,
    incorrect_count INTEGER DEFAULT 0,
    last_reviewed INTEGER,
    FOREIGN KEY (document_id) REFERENCES learning_documents(id)
);
```

#### Video Editor
```sql
CREATE TABLE video_projects (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    project_json TEXT NOT NULL,  -- Timeline, clips, effects
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);

CREATE TABLE video_clips (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL,
    file_path TEXT NOT NULL,
    track_number INTEGER NOT NULL,
    start_time_ms INTEGER NOT NULL,
    duration_ms INTEGER NOT NULL,
    FOREIGN KEY (project_id) REFERENCES video_projects(id)
);
```

---

## Pro Gating Strategy

### Consistent Pattern Across Apps

```kotlin
// app/src/main/java/com/blurr/voice/apps/base/ProGatingManager.kt

class ProGatingManager(
    private val subscriptionRepository: SubscriptionRepository
) {
    suspend fun checkFeatureAccess(
        feature: ProFeature,
        currentUsage: Int
    ): FeatureAccessResult {
        val isProUser = subscriptionRepository.isProUser()
        
        return when (feature) {
            is ProFeature.OperationLimit -> {
                if (isProUser) {
                    FeatureAccessResult.Allowed
                } else {
                    if (currentUsage < feature.freeLimit) {
                        FeatureAccessResult.Allowed
                    } else {
                        FeatureAccessResult.LimitReached(
                            message = "Daily limit reached (${feature.freeLimit}). Upgrade to Pro for unlimited access.",
                            upgradeCtaText = "Upgrade to Pro"
                        )
                    }
                }
            }
            is ProFeature.ExclusiveFeature -> {
                if (isProUser) {
                    FeatureAccessResult.Allowed
                } else {
                    FeatureAccessResult.ProRequired(
                        message = feature.proMessage,
                        upgradeCtaText = "Upgrade to Pro"
                    )
                }
            }
        }
    }
}

sealed class ProFeature {
    data class OperationLimit(val freeLimit: Int) : ProFeature()
    data class ExclusiveFeature(val proMessage: String) : ProFeature()
}

sealed class FeatureAccessResult {
    object Allowed : FeatureAccessResult()
    data class LimitReached(val message: String, val upgradeCtaText: String) : FeatureAccessResult()
    data class ProRequired(val message: String, val upgradeCtaText: String) : FeatureAccessResult()
}
```

### App-Specific Limits

| App | Free Tier Limits | Pro Benefits |
|-----|------------------|--------------|
| **Text Editor** | 50 AI operations/day | Unlimited ops, advanced models, version history |
| **Spreadsheets** | 10 spreadsheets, 1000 rows | Unlimited sheets/rows, ML analysis, Google Sheets |
| **Media Canvas** | 20 workflow executions/day | Unlimited executions, advanced models, custom nodes |
| **DAW** | 8 tracks, basic effects | Unlimited tracks, pro effects, stem separation, streaming |
| **Learning Platform** | 5 documents | Unlimited docs, advanced Q&A, study schedules, export |
| **Video Editor** | 5 exports/month, 720p | Unlimited exports, 1080p/4K, green screen, pro effects |

---

## Export & Integration Patterns

### Export Helper

```kotlin
// app/src/main/java/com/blurr/voice/apps/base/ExportHelper.kt

class ExportHelper(
    private val context: Context,
    private val composioTool: ComposioTool
) {
    // Export to local file
    suspend fun exportToFile(
        content: ByteArray,
        fileName: String,
        mimeType: String
    ): Result<Uri> {
        // Save to app storage or MediaStore
    }
    
    // Export to Google Docs via Composio
    suspend fun exportToGoogleDocs(
        title: String,
        content: String
    ): Result<String> {
        return composioTool.execute(mapOf(
            "action" to "GOOGLEDOCS_CREATE_DOCUMENT",
            "title" to title,
            "content" to content
        ))
    }
    
    // Export to Google Sheets via Composio
    suspend fun exportToGoogleSheets(
        title: String,
        csvData: String
    ): Result<String> {
        return composioTool.execute(mapOf(
            "action" to "GOOGLESHEETS_CREATE_SPREADSHEET",
            "title" to title,
            "data" to csvData
        ))
    }
    
    // Generic Composio action
    suspend fun exportViaComposio(
        action: String,
        params: Map<String, Any>
    ): Result<String> {
        return composioTool.execute(params + ("action" to action))
    }
}
```

---

## Summary

### Key Takeaways

1. **75% Reusability**: Strong leverage of existing agent, tools, and infrastructure
2. **Flutter Minimal**: Only Media Canvas uses Flutter (for node-based UI)
3. **Tool Maximization**: All 20+ existing tools reused across apps
4. **Consistent Patterns**: Shared base classes, Pro gating, export helpers
5. **Python Critical**: PythonShellTool is key enabler for Spreadsheets, DAW, Learning, Video Editor

### Development Efficiency

By maximizing reuse:
- **Faster Development**: 6 apps in 24 weeks (4 weeks/app vs. 8-10 weeks from scratch)
- **Lower Risk**: Proven components, less new code to debug
- **Consistent UX**: Same agent behavior, tool patterns across apps
- **Easier Maintenance**: Shared infrastructure updates benefit all apps

---

**Document Status**: ✅ Complete
**Next Step**: Begin Epic 1 (Foundation) implementation


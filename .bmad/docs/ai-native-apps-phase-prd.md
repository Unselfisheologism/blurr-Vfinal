---
title: "AI-Native Apps Phase - Product Requirements Document"
project: twent-Vfinal
phase: "AI-Native Apps Implementation"
version: 1.0
date: 2025-12-18
status: Planning
author: BMAD Method
stepsCompleted: []
---

# AI-Native Apps Phase - Product Requirements Document

## Executive Summary

This PRD defines the implementation plan for six AI-native applications within the Twent ecosystem. These are dedicated, agent-powered experiences that leverage the existing ultra-generalist agent, tool infrastructure, and workflow engine to provide specialized creative and productivity capabilities. Each app represents a full-screen or modal UI where users can accomplish complex tasks with AI assistance.

### Vision

Transform Twent from a general-purpose AI assistant into a comprehensive AI-native productivity suite, offering specialized experiences for text editing, data analysis, media generation, music production, learning, and video editing—all powered by a unified agent architecture.

### Business Model Alignment

- **Freemium Core**: All apps accessible with basic features
- **Pro Value-Add**: Advanced capabilities, higher limits, premium models
- **Reusability First**: Maximize leverage of existing infrastructure (agent, tools, BYOK, Composio, MCP, workflow engine)

---

## 1. Product Vision & Goals

### 1.1 Strategic Objectives

1. **Differentiation**: Move beyond conversational AI to specialized productivity apps
2. **Retention**: Provide deep, task-specific experiences that keep users engaged
3. **Monetization**: Create clear value tiers for Pro subscriptions
4. **Platform Leverage**: Showcase the power of the generalist agent + tools architecture
5. **User Delight**: Deliver polished, intuitive UIs for complex creative tasks

### 1.2 Success Metrics

| Metric | Target | Timeline |
|--------|--------|----------|
| Apps Launched | 6 apps | 6 months |
| User Engagement | 40% of users try ≥1 app | 3 months post-launch |
| Pro Conversion | 15% app users upgrade to Pro | 6 months |
| Session Duration | 3x increase in avg session time | 3 months |
| User Satisfaction | 4.5+ rating for each app | Ongoing |

### 1.3 Target Users

- **Content Creators**: Writers, bloggers, marketers needing AI-assisted text
- **Data Analysts**: Business users needing spreadsheet generation/analysis
- **Creative Professionals**: Artists, designers, musicians, video editors
- **Students & Educators**: Learners needing AI study assistance
- **Knowledge Workers**: Anyone needing to process documents/data efficiently

---

## 2. App Priority & Rationale

### Priority 1: AI-Native Text Editor
**Rationale**: Highest demand, clearest value prop, easiest to implement with existing tools

### Priority 2: AI-Native Spreadsheets Generator & Editor
**Rationale**: High business value, differentiating feature, leverages Python shell

### Priority 3: AI-Native Multimodal Media Gen Canvas
**Rationale**: Showcases unified tool ecosystem, uses Flutter workflow UI

### Priority 4: AI-Native DAW (Digital Audio Workstation)
**Rationale**: Creative differentiation, leverages music generation tool

### Priority 5: AI-Native Learning Platform (NotebookLM-like)
**Rationale**: Educational market, document processing capabilities

### Priority 6: AI-Native CapCut-like Video Editor
**Rationale**: Complex implementation, builds on video gen tool

---

## 3. Existing Architecture Analysis

### 3.1 Reusable Components

#### Core Infrastructure
- ✅ **Ultra-Generalist Agent**: Full chat interface, multi-turn conversations
- ✅ **UniversalLLMService**: BYOK support (OpenRouter, AIMLAPI)
- ✅ **ProviderKeyManager**: Secure API key management
- ✅ **Tool Infrastructure**: BaseTool, ToolRegistry, parameter validation

#### Available Tools (20+ tools)
- ✅ **Media Generation**: Image, Video, Audio, Music, 3D, Infographic
- ✅ **Code Execution**: Python Shell, JavaScript Shell (UnifiedShellTool)
- ✅ **Search**: Perplexity Sonar (web search)
- ✅ **Integrations**: Composio (Google Workspace, Notion, etc.)
- ✅ **System**: Phone Control, Ask User, Workflow
- ✅ **Document**: PDF, PowerPoint generation capabilities

#### UI Components
- ✅ **AgentChatActivity**: Compose-based chat UI
- ✅ **Flutter Workflow Editor**: fl_nodes-based visual workflow builder
- ✅ **BaseNavigationActivity**: Bottom nav pattern
- ✅ **Pro Gating**: Subscription check infrastructure

### 3.2 Flutter Module Scope

**Use Flutter ONLY for**:
- Workflow visual editor (n8n-like node canvas)
- Node-based multimodal media generation canvas (App #3)

**Use Kotlin/Compose for**:
- All other app UIs (text editor, spreadsheets, DAW, learning, video editor)
- Flutter module integration where needed

**Rationale**: fl_nodes package is Flutter-only; other UIs don't require node-based interfaces.

---

## 4. Functional Requirements by App

### 4.1 App #1: AI-Native Text Editor

#### Core Features
- **Rich Text Editing**: Markdown support, formatting toolbar
- **AI Assistance**:
  - Rewrite (tone: professional, casual, creative)
  - Summarize (brief, detailed)
  - Expand/Elaborate on selected text
  - Continue writing from cursor
  - Fix grammar/spelling
  - Translate (multiple languages)
- **Document Management**: Save/load documents locally (Room DB)
- **Export**: Plain text, Markdown, PDF (via tool), Google Docs (via Composio)
- **Templates**: Blog post, email, essay, report, creative writing

#### User Journey
1. User opens Text Editor from home/nav menu
2. Selects template or starts blank
3. Writes content, highlights text
4. Invokes AI action (contextual menu/toolbar)
5. Agent processes request, returns result inline
6. User continues editing iteratively
7. Saves or exports document

#### Pro Features
- Advanced models (Claude Opus, GPT-4)
- Unlimited AI operations (free: 50/day)
- Export to Google Docs/Notion via Composio
- Custom templates
- Version history

#### Technical Approach
- **Activity**: `TextEditorActivity` (Jetpack Compose)
- **Agent**: Ultra-generalist with system prompt for editing tasks
- **Tools**: Ask User (for clarifications), Composio (export), PDF/PowerPoint (export)
- **Storage**: Room DB for documents, SharedPreferences for drafts

---

### 4.2 App #2: AI-Native Spreadsheets Generator & Editor

#### Core Features
- **Spreadsheet Creation**: Generate from natural language prompts
  - "Create a budget tracker with categories and monthly columns"
  - "Generate sales report with Q1 data: Product A 1000 units, Product B 750 units"
- **Data Manipulation**:
  - Add/remove rows/columns
  - Formula insertion (SUM, AVERAGE, etc.)
  - Sort/filter data
- **AI Analysis**:
  - "What are the top 3 categories by spend?"
  - "Calculate year-over-year growth"
  - "Find anomalies in this data"
- **Visualization**: Generate charts (via Python shell + matplotlib)
- **Export**: CSV, Excel (via Python), Google Sheets (via Composio)

#### User Journey
1. User opens Spreadsheets app
2. Describes desired spreadsheet in natural language
3. Agent uses Python shell to generate CSV/data structure
4. UI displays editable table view
5. User requests analysis/modifications via chat sidebar
6. Agent processes, updates spreadsheet
7. User exports or saves locally

#### Pro Features
- Advanced data analysis (ML predictions, trend analysis)
- Unlimited spreadsheets (free: 10)
- Google Sheets integration
- Custom formulas/macros
- Large datasets (free: 1000 rows, Pro: unlimited)

#### Technical Approach
- **Activity**: `SpreadsheetsActivity` (Jetpack Compose with RecyclerView/LazyColumn)
- **Agent**: System prompt for data analysis, formula generation
- **Tools**: Python Shell (pandas, numpy, matplotlib), Composio (Google Sheets)
- **Storage**: Room DB for spreadsheet metadata, JSON/CSV files for data

---

### 4.3 App #3: AI-Native Multimodal Media Gen Canvas

#### Core Features
- **Visual Workflow Builder**: Drag-and-drop node canvas (fl_nodes)
- **Node Types**:
  - Input: Text prompt, image upload
  - Generate: Image, video, audio, music, 3D model
  - Transform: Style transfer, upscale, colorize
  - Compose: Combine multiple outputs
  - Export: Save to gallery, share
- **Agent Assistance**:
  - "Build a workflow to create a music video from a prompt"
  - Suggest node connections
  - Auto-configure parameters
- **Templates**: Social media post, album art, product mockup, animation

#### User Journey
1. User opens Media Canvas
2. Starts from template or blank canvas
3. Adds nodes from palette (image gen, audio gen, etc.)
4. Connects nodes to define workflow
5. Configures parameters (or asks agent to set them)
6. Executes workflow (sequential node execution)
7. Views results, iterates, exports

#### Pro Features
- Advanced models for generation (Flux, Stable Diffusion XL, etc.)
- Unlimited workflow executions (free: 20/day)
- Custom node creation (Python/JS scripting)
- Workflow sharing/marketplace

#### Technical Approach
- **Activity**: `MediaCanvasActivity` (Kotlin wrapper for Flutter module)
- **Flutter Module**: Workflow editor with fl_nodes
- **Agent**: Workflow planning, parameter optimization
- **Tools**: All media generation tools, Python/JS shell (custom nodes)
- **Storage**: JSON workflow definitions, media outputs in app storage

---

### 4.4 App #4: AI-Native DAW (Digital Audio Workstation)

#### Core Features
- **Track Management**: Multi-track timeline (vocals, instruments, drums, bass)
- **AI Generation**:
  - Generate music from prompt (via MusicGenerationTool)
  - Generate individual stems (drums, bass, melody)
  - AI mixing/mastering suggestions
- **Audio Editing**:
  - Trim, split, fade in/out
  - Volume/pan adjustments
  - Basic effects (reverb, EQ via Python audio libraries)
- **Export**: MP3, WAV, share to streaming platforms (via Composio)

#### User Journey
1. User opens DAW
2. Creates new project or loads existing
3. Adds tracks (AI-generated or imported audio)
4. Arranges on timeline, applies effects
5. Asks agent for mixing advice
6. Exports final mix

#### Pro Features
- Advanced AI music models
- Unlimited track count (free: 8 tracks)
- Professional effects/plugins (via Python audio processing)
- Stem separation (separate vocals/instruments from existing songs)
- Export to Spotify/SoundCloud

#### Technical Approach
- **Activity**: `DAWActivity` (Jetpack Compose with custom timeline view)
- **Agent**: Music theory knowledge, mixing guidance
- **Tools**: Music Generation, Audio Generation, Python Shell (pydub, librosa)
- **Storage**: Audio files in app storage, project JSON metadata

---

### 4.5 App #5: AI-Native Learning Platform (NotebookLM-like)

#### Core Features
- **Document Upload**: PDF, DOCX, TXT, web URLs
- **Content Processing**:
  - Extract text, create knowledge base
  - Generate summaries (chapter-by-chapter, overall)
- **Study Tools**:
  - AI-generated flashcards
  - Practice quizzes (multiple choice, fill-in-blank)
  - Audio study guide (text-to-speech overview)
- **Q&A**: Ask questions about uploaded content
- **Note-Taking**: Annotate documents, AI suggestions

#### User Journey
1. User opens Learning Platform
2. Uploads documents or provides URLs
3. Agent processes, creates knowledge base
4. User selects study mode (flashcards, quiz, Q&A, audio)
5. Agent generates study materials
6. User reviews, asks follow-up questions
7. Tracks progress over time

#### Pro Features
- Unlimited documents (free: 5)
- Advanced Q&A (cite sources, reasoning)
- Custom study schedules (spaced repetition)
- Export notes to Google Docs/Notion

#### Technical Approach
- **Activity**: `LearningPlatformActivity` (Jetpack Compose)
- **Agent**: Educational context, Socratic method prompts
- **Tools**: Python Shell (PDF parsing, NLP), Audio Generation (study guides), Composio (export)
- **Storage**: Room DB for document metadata, vector DB (SQLite FTS) for semantic search

---

### 4.6 App #6: AI-Native CapCut-like Video Editor

#### Core Features
- **Video Timeline**: Import clips, arrange on multi-track timeline
- **AI Features**:
  - Auto-captions (speech-to-text)
  - Smart transitions (AI-suggested based on content)
  - Background music generation
  - Color grading suggestions
  - Generate video from text prompt (via VideoGenerationTool)
- **Editing Tools**:
  - Trim, split, merge clips
  - Add text overlays, stickers
  - Filters/effects
- **Export**: MP4, share to social media (via Composio)

#### User Journey
1. User opens Video Editor
2. Imports clips or generates from prompt
3. Arranges on timeline
4. Asks agent for editing suggestions ("Make this more dramatic")
5. Agent applies transitions, effects, music
6. User previews, iterates
7. Exports final video

#### Pro Features
- Advanced video generation models
- Unlimited exports (free: 720p, Pro: 1080p/4K)
- Green screen removal
- Professional effects library
- Export to YouTube/TikTok

#### Technical Approach
- **Activity**: `VideoEditorActivity` (Jetpack Compose with custom timeline)
- **Agent**: Video editing expertise, storytelling guidance
- **Tools**: Video Generation, Audio/Music Generation, Python Shell (FFmpeg via subprocess)
- **Storage**: Video files in app storage, project JSON

---

## 5. Non-Functional Requirements

### 5.1 Performance
- **App Launch**: <2s to UI ready
- **AI Response**: <10s for typical requests
- **Media Generation**: Progress indicators, background processing
- **Smooth UI**: 60 FPS scrolling, no janky animations

### 5.2 Usability
- **Intuitive**: First-time users complete key task in <3 min
- **Consistent**: Same nav patterns, design language across all apps
- **Accessible**: Support screen readers, large text, high contrast

### 5.3 Security
- **Data Privacy**: All user content stored locally by default
- **API Keys**: Secure storage via ProviderKeyManager
- **Pro Gating**: Server-side validation for Pro features

### 5.4 Scalability
- **Modular Design**: Each app as separate module
- **Tool Reuse**: All apps use same tool infrastructure
- **Agent Reuse**: Same generalist agent with app-specific system prompts

---

## 6. Technical Architecture

### 6.1 Module Structure

```
app/src/main/java/com/twent/voice/
├── apps/
│   ├── texteditor/
│   │   ├── TextEditorActivity.kt
│   │   ├── TextEditorViewModel.kt
│   │   ├── TextEditorUI.kt
│   │   └── models/ (Document, EditAction)
│   ├── spreadsheets/
│   │   ├── SpreadsheetsActivity.kt
│   │   ├── SpreadsheetsViewModel.kt
│   │   ├── SpreadsheetUI.kt
│   │   └── models/ (Spreadsheet, Cell)
│   ├── mediacanvas/
│   │   ├── MediaCanvasActivity.kt (Kotlin wrapper)
│   │   └── FlutterIntegration.kt
│   ├── daw/
│   │   ├── DAWActivity.kt
│   │   ├── DAWViewModel.kt
│   │   ├── TimelineView.kt
│   │   └── models/ (Track, AudioClip)
│   ├── learning/
│   │   ├── LearningPlatformActivity.kt
│   │   ├── LearningViewModel.kt
│   │   └── models/ (Document, Flashcard, Quiz)
│   └── videoeditor/
│       ├── VideoEditorActivity.kt
│       ├── VideoEditorViewModel.kt
│       ├── VideoTimelineView.kt
│       └── models/ (VideoProject, Clip)
└── shared/
    ├── AgentIntegration.kt (common agent interface)
    ├── ProGatingManager.kt (subscription checks)
    └── ExportHelper.kt (file export utilities)
```

### 6.2 Flutter Module Integration (App #3 only)

```
flutter_workflow_editor/lib/
├── media_canvas/
│   ├── media_canvas_screen.dart
│   ├── media_node_definitions.dart (image, video, audio nodes)
│   └── media_execution_engine.dart (executes media workflows)
```

### 6.3 Agent System Prompt Strategy

Each app provides a system prompt extension:

```kotlin
// Example for Text Editor
val textEditorSystemPrompt = """
You are an AI writing assistant within a text editor.
Your capabilities:
- Rewrite text in different tones (professional, casual, creative)
- Summarize selected content
- Expand on ideas
- Fix grammar and spelling
- Translate text

Always preserve user intent. Ask for clarification if ambiguous.
"""
```

### 6.4 Data Flow

```
User Input → Activity → ViewModel → Agent (with system prompt) 
                                    ↓
                            Tool Selection & Execution
                                    ↓
                            Tool Result → Agent Response
                                    ↓
                            ViewModel → UI Update
```

---

## 7. Implementation Roadmap

### Phase 1: Foundation (Weeks 1-2)
- Set up app module structure
- Create shared base classes (BaseAppActivity, BaseAppViewModel)
- Implement common agent integration layer
- Design Pro gating for each app

### Phase 2: App #1 - Text Editor (Weeks 3-5)
- UI implementation (Compose rich text editor)
- Agent integration (rewrite, summarize, expand)
- Document storage (Room DB)
- Export functionality (PDF, Composio)
- Pro gating (model selection, operation limits)

### Phase 3: App #2 - Spreadsheets (Weeks 6-8)
- Table UI (LazyColumn with cell editing)
- Python shell integration (pandas, numpy)
- CSV/JSON data handling
- Chart generation (matplotlib)
- Google Sheets export (Composio)

### Phase 4: App #3 - Media Canvas (Weeks 9-11)
- Flutter module extension (media nodes)
- Kotlin wrapper activity
- Media tool integration (all generation tools)
- Workflow execution engine
- Template library

### Phase 5: App #4 - DAW (Weeks 12-14)
- Timeline UI (custom view with track lanes)
- Audio playback engine
- Music generation integration
- Basic effects (via Python audio libraries)
- Export functionality

### Phase 6: App #5 - Learning Platform (Weeks 15-17)
- Document upload/parsing (PDF, DOCX)
- Knowledge base creation
- Study tool generation (flashcards, quizzes)
- Audio study guides
- Progress tracking

### Phase 7: App #6 - Video Editor (Weeks 18-20)
- Video timeline UI
- Clip import/arrangement
- FFmpeg integration (via Python shell)
- Auto-caption generation
- Export & social sharing

### Phase 8: Polish & Launch (Weeks 21-24)
- Cross-app consistency review
- Performance optimization
- User testing & feedback
- Marketing materials
- Phased rollout (beta → full release)

---

## 8. Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|-----------|
| Flutter integration complexity | High | Limit Flutter to App #3 only, thorough testing |
| Performance issues (media generation) | Medium | Background processing, progress indicators, caching |
| User adoption (too many apps) | Medium | Progressive rollout, in-app discovery, tutorials |
| Pro conversion lower than expected | High | Clear value differentiation, free tier limits, Pro trials |
| Tool API rate limits/costs | Medium | BYOK model, usage tracking, graceful degradation |
| Scope creep (feature requests) | Medium | Strict MVP definition, post-launch iteration roadmap |

---

## 9. Success Criteria

### Launch Criteria (per app)
- ✅ Core features functional
- ✅ Agent integration working reliably
- ✅ Pro gating implemented
- ✅ Export/save functionality tested
- ✅ Performance benchmarks met
- ✅ Accessibility standards (WCAG AA)

### Post-Launch Metrics (3-month targets)
- 30% of active users try at least one AI-native app
- 4.0+ avg rating for each app
- 10% Pro conversion among app users
- 2.5x increase in session duration
- <3% crash rate

---

## 10. Appendix

### 10.1 Reference Documents
- [Current Project Context](../project_context.md)
- [Existing PRD](../prd.md)
- [Existing Epics](../epics.md)
- [fl_nodes Documentation](../../fl_nodes_docs.md)
- [Flutter Workflow Editor](../../flutter_workflow_editor/README.md)

### 10.2 Technology Stack
- **Language**: Kotlin
- **UI**: Jetpack Compose (Kotlin apps), Flutter (Media Canvas)
- **Architecture**: MVVM, Repository pattern
- **DI**: Hilt (existing pattern)
- **Database**: Room
- **Agent**: UniversalLLMService + existing tool infrastructure
- **Build**: Gradle with multi-module setup

### 10.3 Open Questions
1. Should apps have dedicated onboarding tutorials?
2. Cross-app data sharing (e.g., use text editor doc in learning platform)?
3. Offline mode for apps (limited AI features)?
4. App discovery UI (launcher grid vs. nav menu)?

---

**Document Status**: ✅ Ready for Epic Breakdown
**Next Step**: Generate detailed epics and stories for each app

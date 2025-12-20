# AI-Native Apps Module

This module contains all AI-native applications within Twent.

## Structure

```
apps/
├── base/                          # Shared base classes for all apps
│   ├── BaseAppActivity.kt         # Common activity patterns
│   ├── BaseAppViewModel.kt        # Common ViewModel patterns
│   ├── AgentIntegration.kt        # Agent communication layer
│   ├── ProGatingManager.kt        # Subscription checks & limits
│   ├── ExportHelper.kt            # File export utilities
│   └── SystemPrompts.kt           # App-specific system prompts
│
├── texteditor/                    # App #1: AI-Native Text Editor
│   ├── TextEditorActivity.kt
│   ├── TextEditorViewModel.kt
│   ├── models/
│   ├── ui/
│   └── repository/
│
├── spreadsheets/                  # App #2: AI-Native Spreadsheets
│   ├── SpreadsheetsActivity.kt
│   ├── SpreadsheetsViewModel.kt
│   ├── models/
│   ├── ui/
│   └── repository/
│
├── mediacanvas/                   # App #3: Multimodal Media Canvas
│   └── MediaCanvasActivity.kt    # Kotlin wrapper for Flutter module
│
├── daw/                           # App #4: Digital Audio Workstation
│   ├── DAWActivity.kt
│   ├── DAWViewModel.kt
│   ├── models/
│   ├── ui/
│   └── repository/
│
├── learning/                      # App #5: Learning Platform
│   ├── LearningPlatformActivity.kt
│   ├── LearningViewModel.kt
│   ├── models/
│   ├── ui/
│   └── repository/
│
└── videoeditor/                   # App #6: Video Editor
    ├── VideoEditorActivity.kt
    ├── VideoEditorViewModel.kt
    ├── models/
    ├── ui/
    └── repository/
```

## Base Components

### BaseAppActivity
Common activity foundation for all AI-native apps.

**Features**:
- Consistent theming via TwentTheme
- Pro gating integration
- Navigation patterns
- Pro upgrade prompts

**Usage**:
```kotlin
@AndroidEntryPoint
class TextEditorActivity : BaseAppActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setupAppContent()
    }
    
    override fun setupAppContent() {
        setContent {
            AppContent {
                TextEditorScreen()
            }
        }
    }
}
```

### BaseAppViewModel
Common ViewModel foundation for agent integration.

**Features**:
- Agent request handling
- Loading/error state management
- Operation counting for Pro limits
- Coroutine scope management

**Usage**:
```kotlin
class TextEditorViewModel @Inject constructor(
    llmService: UniversalLLMService,
    agent: UltraGeneralistAgent
) : BaseAppViewModel(llmService, agent) {
    
    override fun getSystemPrompt(): String = SystemPrompts.TEXT_EDITOR
    
    fun rewriteText(text: String, tone: String) {
        executeAgentOperation { agent, prompt ->
            agent.processRequest("Rewrite: $text in $tone tone", prompt)
        }
    }
}
```

### ProGatingManager
Manages subscription limits and feature access.

**Features**:
- Operation limits (daily/monthly)
- Resource limits (documents, tracks, etc.)
- Exclusive Pro features
- Automatic limit resets

**Usage**:
```kotlin
val result = proGatingManager.checkFeatureAccess(
    feature = ProFeature.OperationLimit(freeLimit = 50),
    currentUsage = viewModel.operationCount.value
)

when (result) {
    is FeatureAccessResult.Allowed -> // Proceed
    is FeatureAccessResult.LimitReached -> // Show upgrade prompt
    is FeatureAccessResult.ProRequired -> // Show Pro-only message
}
```

### AgentIntegration
Centralizes agent communication with context injection.

**Features**:
- System prompt construction
- Context variable injection
- Streaming support (when available)
- Response formatting

**Usage**:
```kotlin
val result = agentIntegration.executeWithPrompt(
    basePrompt = SystemPrompts.TEXT_EDITOR,
    context = mapOf(
        "operation" to "rewrite",
        "selectedText" to selectedText,
        "tone" to "professional"
    ),
    userRequest = "Rewrite this text"
)
```

### ExportHelper
Handles file exports (local and cloud).

**Features**:
- Local file exports (MediaStore/File)
- Google Docs/Sheets exports (Composio)
- Multiple formats (PDF, CSV, images, etc.)
- Android version compatibility

**Usage**:
```kotlin
// Local export
val result = exportHelper.exportToFile(
    content = documentText.toByteArray(),
    fileName = "my_doc.txt",
    mimeType = "text/plain",
    directory = ExportDirectory.DOCUMENTS
)

// Cloud export
val result = exportHelper.exportToGoogleDocs(
    title = "My Document",
    content = documentText
)
```

## System Prompts

Each app has a specialized system prompt defined in `SystemPrompts` object:

- `SystemPrompts.TEXT_EDITOR` - Writing assistance
- `SystemPrompts.SPREADSHEETS` - Data analysis
- `SystemPrompts.MEDIA_CANVAS` - Workflow building
- `SystemPrompts.DAW` - Music production
- `SystemPrompts.LEARNING_PLATFORM` - Study assistance
- `SystemPrompts.VIDEO_EDITOR` - Video editing

System prompts support context injection using `{variableName}` syntax.

## Pro Gating Limits

### Text Editor
- Free: 50 operations/day
- Pro: Unlimited, advanced models, version history

### Spreadsheets
- Free: 10 spreadsheets, 1000 rows
- Pro: Unlimited sheets/rows, ML analysis

### Media Canvas
- Free: 20 workflow executions/day
- Pro: Unlimited, advanced models, custom nodes

### DAW
- Free: 8 tracks
- Pro: Unlimited tracks, pro effects, stem separation

### Learning Platform
- Free: 5 documents
- Pro: Unlimited docs, advanced Q&A

### Video Editor
- Free: 5 exports/month, 720p
- Pro: Unlimited exports, 1080p/4K, pro effects

## Development Guidelines

1. **Extend Base Classes**: Always extend `BaseAppActivity` and `BaseAppViewModel`
2. **Use Pro Gating**: Check feature access before operations
3. **Reuse Tools**: Use existing tools from `/tools/` package
4. **System Prompts**: Define app-specific prompts in `SystemPrompts`
5. **Export via Helper**: Use `ExportHelper` for all exports
6. **Follow MVVM**: Maintain clean separation (Activity → ViewModel → Repository)
7. **Test Pro Limits**: Verify free tier restrictions work correctly

## Testing

- Unit tests for ViewModels and Repositories
- Integration tests for agent operations
- UI tests for critical user flows
- Pro gating tests for limits and upgrades

## Dependencies

All apps share:
- `UniversalLLMService` - LLM communication
- `UltraGeneralistAgent` - Agent orchestration
- `ToolRegistry` - 20+ tools
- `ComposioTool` - External integrations
- `FreemiumManager` - Subscription management

## Next Steps

1. Implement Epic 2: Text Editor (Priority 1)
2. Implement Epic 3: Spreadsheets (Priority 2)
3. Continue through Epic 7 (Video Editor)
4. Epic 8: Cross-app integration
5. Epic 9: Polish & launch

---

**Status**: Foundation Complete (Epic 1 Story 1.1) ✅

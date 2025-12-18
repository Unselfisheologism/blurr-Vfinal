# Flutter Workflow Editor Module

A fully-featured n8n-like node-based workflow editor for mobile, built with Flutter and designed for the Blurr Voice AI Assistant app.

## Features

### ✅ Complete n8n Feature Parity
- **Triggers**: Manual, Schedule (Pro), Webhook (Pro)
- **Actions**: Composio (2,000+ integrations), MCP servers, Google Workspace, HTTP requests, Code execution
- **System Tools**: UI automation, notification access, phone control (Blurr's unique capabilities)
  - UI Automation: Tap, swipe, scroll, type, screenshot, and more
  - Notification Access: Read and manage Android notifications
  - Phone Control: Open apps, navigate system settings, get screen hierarchy
- **Logic**: If/Else, Switch, Loop, Merge, Split
- **Data**: Variables, Functions, Expressions (Jinja-like syntax)
- **Error Handling**: Error triggers and handlers
- **AI Features**: AI-assisted node creation (Pro), LLM calls
- **Execution**: Real-time workflow execution with live logs
- **Storage**: Save/load workflows locally
- **Export/Import**: JSON format

### 🎨 Mobile-Optimized UI
- **Vertical Layout**: Top-to-bottom node flow (mobile-friendly)
- **Touch Gestures**: Pinch-to-zoom, pan, drag-and-drop
- **Responsive**: Adapts to portrait/landscape
- **Interactive Canvas**: Smooth connections, auto-layout
- **Node Palette**: Categorized, searchable node library
- **Inspector Panel**: Edit node properties in real-time
- **Execution Panel**: Live logs and results

### 🔗 Native Integration
- **Platform Channels**: Kotlin/Swift bridge for native communication
- **Composio Integration**: Access user's connected tools
- **MCP Integration**: Execute MCP server requests
- **Google Workspace**: OAuth-based Gmail, Calendar, Drive integration
- **System Tools**: Direct access to Accessibility Service and Notification Listener
- **Pro Features**: Feature flags for subscription tiers
- **State Sync**: Seamless with native app state

### 🎯 Pro Feature Gating
- **Free**: Manual triggers, basic actions, local storage
- **Pro**: Scheduled triggers, webhooks, AI assist, team collaboration

## Architecture

```
flutter_workflow_editor/
├── lib/
│   ├── main.dart                      # Entry point
│   ├── workflow_editor_screen.dart    # Main screen
│   ├── models/                        # Data models
│   │   ├── workflow.dart
│   │   ├── workflow_node.dart
│   │   ├── workflow_connection.dart
│   │   ├── composio_tool.dart
│   │   ├── mcp_server.dart
│   │   ├── google_workspace_tool.dart
│   │   └── system_tool.dart
│   ├── state/                         # State management
│   │   ├── workflow_state.dart
│   │   └── app_state.dart
│   ├── services/                      # Business logic
│   │   ├── execution_engine.dart
│   │   ├── storage_service.dart
│   │   ├── vertical_layout_engine.dart
│   │   └── platform_bridge.dart
│   ├── widgets/                       # UI components
│   │   ├── workflow_canvas.dart
│   │   ├── node_widget.dart
│   │   ├── node_palette.dart
│   │   ├── node_inspector.dart
│   │   ├── toolbar.dart
│   │   └── execution_panel.dart
│   └── integration/                   # Native bridges
│       └── kotlin_bridge.kt
└── pubspec.yaml
```

## Integration Guide

### Android (Kotlin)

1. **Add Flutter module to your project**:
```gradle
// settings.gradle.kts
setBinding(Binding(settings))
include(":flutter_workflow_editor")
project(":flutter_workflow_editor").projectDir = File("../flutter_workflow_editor/.android")
```

2. **Create FlutterFragment**:
```kotlin
// In your Activity
import io.flutter.embedding.android.FlutterFragment

class WorkflowEditorActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val flutterEngine = FlutterEngineCache.getInstance()
            .get("workflow_editor_engine") ?: createFlutterEngine()
        
        // Create bridge
        val bridge = flutterEngine.createWorkflowEditorBridge(this)
        
        // Add FlutterFragment
        supportFragmentManager
            .beginTransaction()
            .add(R.id.container, FlutterFragment.withCachedEngine("workflow_editor_engine").build())
            .commit()
    }
    
    private fun createFlutterEngine(): FlutterEngine {
        val engine = FlutterEngine(this)
        engine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
        FlutterEngineCache.getInstance().put("workflow_editor_engine", engine)
        return engine
    }
}
```

3. **Add to AndroidManifest.xml**:
```xml
<activity
    android:name=".WorkflowEditorActivity"
    android:theme="@style/Theme.AppCompat"
    android:configChanges="orientation|keyboardHidden|screenSize" />
```

### iOS (Swift) - Future

```swift
// Similar pattern using FlutterViewController
```

## Usage Examples

### Creating a Simple Workflow

```dart
// The user interacts with the UI:
// 1. Drag "Manual Trigger" from palette
// 2. Drag "Composio Action" node
// 3. Connect them by dragging from output port to input port
// 4. Select Composio node, configure in inspector:
//    - Tool: "Gmail"
//    - Action: "send_email"
//    - Parameters: {"to": "user@example.com", "subject": "Test"}
// 5. Click "Execute" in toolbar
// 6. View results in execution panel
```

### Programmatic Access

```dart
// In your Flutter code
final workflowState = context.read<WorkflowState>();

// Create workflow
await workflowState.initialize();

// Add nodes
workflowState.addNode(
  WorkflowNode(
    id: uuid.v4(),
    name: 'Send Email',
    type: NodeType.composioAction,
    parameters: {
      'tool': 'gmail',
      'action': 'send_email',
      'parameters': {'to': 'user@example.com'},
    },
  ),
);

// Execute
await workflowState.executeWorkflow();

// Access results
final results = workflowState.executionResults;
```

## Node Types Reference

### Triggers
- **Manual**: User-initiated execution
- **Schedule** (Pro): Cron-based scheduling
- **Webhook** (Pro): HTTP webhook triggers

### Actions
- **Composio Action**: Execute any Composio integration (2,000+ tools)
- **MCP Action**: Execute MCP server requests
- **HTTP Request**: Make API calls
- **Code**: Run JavaScript/Python code

### Logic
- **If/Else**: Conditional branching
- **Switch**: Multi-way branching
- **Loop**: Iterate over arrays
- **Merge**: Combine multiple inputs
- **Split**: Divide execution paths

### Data
- **Set Variable**: Store data
- **Get Variable**: Retrieve data
- **Function**: Transform data

### AI
- **AI Assist** (Pro): Generate nodes from natural language
- **LLM Call**: Call language models

### Error Handling
- **Error Handler**: Catch and handle errors
- **Error Trigger**: Trigger on specific errors

## Expression Syntax

Use `{{ }}` for dynamic values:

```
# Access node output
{{ node.send_email.messageId }}

# Access variables
{{ myVariable }}

# Conditions
{{ node.output.status }} == "success"

# Loop variables
{{ item }}
{{ index }}
```

## Performance Optimization

- **Lazy Loading**: Nodes rendered only when visible
- **Debounced Updates**: State changes batched
- **Canvas Virtualization**: Large workflows optimized
- **Execution Throttling**: Prevent excessive API calls

## Pro Features

Gated behind subscription:
- Schedule triggers (cron)
- Webhook triggers
- AI-assisted node creation
- Team collaboration (future)
- Workflow sharing (future)
- Advanced error handling
- Unlimited executions

Check in code:
```dart
if (appState.hasFeature('scheduled_triggers')) {
  // Show schedule node
}
```

## Documentation

- [Integration Guide](./INTEGRATION_GUIDE.md) - Detailed integration steps with Android/iOS
- [System Tools Integration Guide](./SYSTEM_TOOLS_INTEGRATION_GUIDE.md) - UI automation, notifications, and phone control
- [System Tools Examples](./SYSTEM_TOOLS_EXAMPLES.md) - Practical workflow examples using system tools
- [Google Workspace Integration](./GOOGLE_WORKSPACE_INTEGRATION.md) - OAuth setup and usage
- [Deployment Guide](./DEPLOYMENT.md) - Production deployment steps
- [Testing Guide](./TESTING_GUIDE.md) - Testing strategies

## Development

### Run standalone (for testing)
```bash
cd flutter_workflow_editor
flutter run
```

### Build for production
```bash
flutter build aar  # Android
flutter build ios-framework  # iOS
```

### Generate JSON serialization
```bash
flutter pub run build_runner build
```

## Testing

```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widgets/

# Integration tests
flutter test integration_test/
```

## Troubleshooting

### Issue: Platform channel not working
- Ensure FlutterEngine is initialized before creating bridge
- Check method channel name matches on both sides

### Issue: Composio tools not loading
- Verify user is signed in to Composio in native app
- Check FreemiumManager.hasComposioAccess() returns true

### Issue: Vertical layout not working
- Verify VerticalLayoutEngine is being called
- Check node positions (y-axis should increment)

### Issue: Nodes not rendering
- Check if workflow is loaded: `workflowState.currentWorkflow != null`
- Verify nodes have valid positions (x, y)

## Contributing

1. Follow Flutter style guide
2. Add tests for new features
3. Update documentation
4. Keep mobile performance in mind

## License

Proprietary - Part of Blurr Voice AI Assistant

## Contact

For issues or questions, contact the Blurr development team.

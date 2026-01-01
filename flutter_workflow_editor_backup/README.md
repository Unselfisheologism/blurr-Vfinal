# Flutter Workflow Editor

**Advanced, original node-based workflow automation system for mobile AI super assistant**

Built with [fl_nodes](https://github.com/WilliamKarolDiCioccio/fl_nodes) as the core rendering engine, this is a custom, mobile-optimized visual workflow editor designed specifically for the Blurr AI assistant app.

## 🎯 Features

### Core Capabilities
- ✅ **Vertical top-to-bottom flow** - Mobile-optimized layout
- ✅ **Rich node types** - 20+ specialized nodes for automation
- ✅ **Unified Shell integration** - Execute Python/JavaScript code directly
- ✅ **Composio integration** - Call user-connected tools dynamically
- ✅ **MCP server integration** - Connect to Model Context Protocol servers
- ✅ **Full execution engine** - Async, stateful, error handling
- ✅ **Mobile-first UX** - Touch-optimized with pinch-zoom, drag, pan
- ✅ **Real-time logs** - Live execution monitoring
- ✅ **Undo/Redo** - Full history management
- ✅ **Pro features** - Scheduling, templates, advanced nodes

### Node Types

#### Triggers
- Manual Trigger - Start workflows manually
- Schedule (Pro) - Cron-based scheduling
- Webhook (Pro) - HTTP webhook triggers

#### Actions
- **Unified Shell** - Execute Python/JavaScript with dynamic packages
- HTTP Request - Make REST API calls
- Composio Action - Call connected integrations
- MCP Action - Execute MCP server tools

#### Logic
- IF/ELSE - Conditional branching
- Switch - Multiple condition routing
- Loop - Iterate over collections
- Merge - Combine execution paths

#### Data
- Set Variable - Store workflow data
- Get Variable - Retrieve stored data
- Transform Data - Map and convert data
- Function - Execute expressions

#### System (Blurr-specific)
- Phone Control - Call, SMS, device functions
- Notification - System notifications
- UI Automation - Accessibility-based automation

#### AI
- AI Assistant - Call ultra-generalist agent
- LLM Call - Direct LLM API calls

#### Error Handling
- Error Handler - Catch and handle errors
- Retry - Retry failed operations

## 🏗️ Architecture

```
flutter_workflow_editor/
├── lib/
│   ├── main.dart                           # Entry point
│   ├── workflow_editor_screen.dart         # Main screen
│   │
│   ├── core/                               # Core systems
│   │   └── vertical_layout_adapter.dart    # Vertical layout engine
│   │
│   ├── models/                             # Data models
│   │   ├── node_definitions.dart           # Node type definitions
│   │   ├── fl_node_prototypes.dart         # FL Nodes prototypes
│   │   ├── workflow.dart                   # Workflow model
│   │   ├── workflow_node.dart              # Node model
│   │   └── workflow_connection.dart        # Connection model
│   │
│   ├── nodes/                              # Node implementations
│   │   ├── unified_shell_node.dart         # Code execution node
│   │   ├── composio_node.dart              # Composio integration
│   │   ├── mcp_node.dart                   # MCP integration
│   │   └── logic_nodes.dart                # Logic node types
│   │
│   ├── services/                           # Business logic
│   │   ├── workflow_execution_engine.dart  # Execution orchestration
│   │   ├── platform_bridge.dart            # Native communication
│   │   ├── storage_service.dart            # Persistence
│   │   └── vertical_layout_engine.dart     # Layout management
│   │
│   ├── state/                              # State management
│   │   ├── app_state.dart                  # Global app state
│   │   └── workflow_state.dart             # Workflow state
│   │
│   └── widgets/                            # UI components
│       ├── fl_workflow_canvas.dart         # FL Nodes canvas
│       ├── node_palette.dart               # Node selector
│       ├── node_inspector.dart             # Property editor
│       ├── toolbar.dart                    # Top toolbar
│       └── execution_panel.dart            # Logs/output panel
│
└── pubspec.yaml                            # Dependencies
```

## 🚀 Getting Started

### Prerequisites

```yaml
# Add to your main app's pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  fl_nodes:
    git:
      url: https://github.com/WilliamKarolDiCioccio/fl_nodes.git
```

### Integration into Android App

#### 1. Add Flutter Module to settings.gradle.kts

```kotlin
// settings.gradle.kts
setBinding(Binding(settings))
include(":app")
includeBuild("flutter_workflow_editor") {
    dependencySubstitution {
        substitute(module("com.blurr:flutter_workflow_editor"))
            .using(project(":"))
    }
}
```

#### 2. Setup Method Channel Handler

```kotlin
// In your MainActivity or Application class
import com.blurr.voice.workflow.WorkflowEditorHandler

class MainActivity : FlutterActivity() {
    private lateinit var workflowHandler: WorkflowEditorHandler
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Initialize workflow handler
        workflowHandler = WorkflowEditorHandler(
            context = this,
            unifiedShellTool = unifiedShellTool,
            composioClient = composioClient,
            composioManager = composioIntegrationManager,
            mcpClient = mcpClient
        )
        
        // Register method channel
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "workflow_editor")
            .setMethodCallHandler(workflowHandler)
    }
}
```

#### 3. Launch Workflow Editor

```kotlin
// Launch as FlutterFragment
val flutterFragment = FlutterFragment.createDefault()

supportFragmentManager
    .beginTransaction()
    .add(R.id.fragment_container, flutterFragment)
    .commit()

// Or launch as FlutterActivity
val intent = FlutterActivity
    .withNewEngine()
    .initialRoute("/workflow_editor")
    .build(this)

startActivity(intent)
```

## 📱 Usage

### Creating a Workflow

1. **Add Trigger Node** - Drag a trigger from the palette
2. **Add Action Nodes** - Chain actions vertically
3. **Connect Nodes** - Drag from output to input ports
4. **Configure Nodes** - Use inspector to set parameters
5. **Run Workflow** - Click Run button to execute

### Using Unified Shell Node

The Unified Shell node exposes the app's powerful code execution capabilities:

```python
# Example: Python data processing
import pandas as pd
import json

# Input data from previous node
data = json.loads(input_data)

# Process with pandas
df = pd.DataFrame(data)
result = df.describe().to_json()

# Output to next node
print(result)
```

```javascript
// Example: JavaScript API call
const axios = require('axios');

async function fetchData() {
    const response = await axios.get('https://api.example.com/data');
    return response.data;
}

const result = await fetchData();
console.log(JSON.stringify(result));
```

## 🔧 Platform Channel API

### Methods Available

```dart
// Unified Shell
executeUnifiedShell(code, language, timeout, inputs)

// Composio
getComposioTools()
executeComposioAction(toolId, actionId, parameters)

// MCP
getMCPServers()
executeMCPTool(serverId, toolId, parameters)

// HTTP
executeHttpRequest(url, method, headers, body)

// Workflow Management
saveWorkflow(workflowId, workflowData)
loadWorkflow(workflowId)
listWorkflows()
exportWorkflow(workflowId)
importWorkflow(workflowJson)
scheduleWorkflow(workflowId, cronExpression, enabled)
```

## 🧪 Testing

```bash
# Run Flutter tests
cd flutter_workflow_editor
flutter test

# Run in standalone mode
flutter run
```

## 📦 Building

```bash
# Generate JSON serialization code
flutter pub run build_runner build

# Build AAR for Android
flutter build aar

# Build as module
flutter build apk --release
```

## 📄 License

Proprietary - Part of Blurr AI Assistant

## 🙏 Acknowledgments

- **fl_nodes** - Core node rendering engine
- **Composio** - Integration platform
- **MCP** - Model Context Protocol

---

**Built with ❤️ for mobile workflow automation**

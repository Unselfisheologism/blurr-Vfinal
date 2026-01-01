# System-Level Tools Integration Guide

## Overview

This guide explains how to use Blurr's unique system-level capabilities (UI automation, notification access, and phone control) within the n8n-style workflow editor.

## Features Added

### 1. **UI Automation Tools**
Access to Android's Accessibility Service for comprehensive UI control:

- **Tap Element** - Click on UI elements by text, resource ID, or coordinates
- **Type Text** - Input text into focused fields
- **Swipe** - Perform swipe gestures in any direction
- **Scroll** - Scroll up or down on the screen
- **Press Back** - Simulate back button press
- **Press Home** - Navigate to home screen
- **Open Notifications** - Open the notification shade
- **Open App** - Launch apps by package name
- **Get Screen Hierarchy** - Extract UI structure as XML
- **Take Screenshot** - Capture the current screen

### 2. **Notification Tools**
Access to Android's Notification Listener Service:

- **Get All Notifications** - Retrieve all active notifications
- **Get App Notifications** - Get notifications from a specific app

### 3. **System Control Tools**
General system-level operations:

- **Get Current Activity** - Get the foreground app package name
- **Open Settings** - Open Android Settings (general or specific pages)

## Architecture

### Component Structure

```
flutter_workflow_editor/
├── lib/
│   ├── models/
│   │   ├── system_tool.dart          # System tool models
│   │   ├── system_tool.g.dart        # Generated JSON serialization
│   │   └── workflow_node.dart        # Extended with system node types
│   ├── services/
│   │   ├── platform_bridge.dart      # Flutter-Kotlin communication
│   │   └── execution_engine.dart     # Workflow execution with system tools
│   ├── state/
│   │   └── app_state.dart            # App state with system tool methods
│   ├── widgets/
│   │   └── node_palette.dart         # Node palette with system tools
│   └── integration/
│       └── kotlin_bridge.kt          # Kotlin bridge implementation
```

### Data Flow

```
User adds System Tool Node
        ↓
Flutter UI (node_palette.dart)
        ↓
WorkflowState stores node
        ↓
User executes workflow
        ↓
ExecutionEngine._executeSystemToolAction()
        ↓
AppState.executeSystemTool()
        ↓
PlatformBridge.executeSystemTool()
        ↓
MethodChannel → Kotlin
        ↓
WorkflowEditorBridge.handleExecuteSystemTool()
        ↓
PhoneControlTool (existing Blurr tool)
        ↓
ScreenInteractionService / Eyes / Finger APIs
        ↓
Result returned to Flutter
```

## Usage

### Adding System Tool Nodes to Workflows

1. **Open the Workflow Editor** from the main Blurr app
2. **Navigate to the "System" category** in the node palette
3. **Click on any system tool** to add it to your workflow
4. **Configure the node parameters** in the inspector panel
5. **Connect nodes** to create your automation flow

### Example: Check WhatsApp Notifications

```dart
Manual Trigger
    ↓
Get App Notifications (packageName: "com.whatsapp")
    ↓
If/Else (condition: notifications.length > 0)
    ↓ (true)
Open App (packageName: "com.whatsapp")
    ↓
Tap Element (text: "Chats")
```

### Example: Take Screenshot and Save

```dart
Manual Trigger
    ↓
Open App (packageName: "com.google.maps")
    ↓
Take Screenshot
    ↓
Save to Variable (name: "screenshot")
```

### Example: Automated App Navigation

```dart
Manual Trigger
    ↓
Open Settings (settingsPage: "wifi")
    ↓
Get Screen Hierarchy
    ↓
Tap Element (text: "Wi-Fi")
    ↓
Swipe (direction: "down")
```

## Permissions

### Required Permissions

System tools require specific Android permissions:

1. **Accessibility Service** (for UI automation tools)
   - Required for: tap, swipe, scroll, type, screenshot, hierarchy, etc.
   - Enable: Settings → Accessibility → Blurr

2. **Notification Listener** (for notification tools)
   - Required for: get notifications, dismiss notifications
   - Enable: Settings → Notification Access → Blurr

### Checking Permissions in Workflows

The execution engine automatically checks permissions before executing system tools:

```dart
// Automatic permission check
if (toolId.startsWith('ui_')) {
  // Check Accessibility Service
  if (!hasPermission) {
    throw Exception('PERMISSION_REQUIRED: Accessibility Service...');
  }
}

if (toolId.startsWith('notif_')) {
  // Check Notification Listener
  if (!hasPermission) {
    throw Exception('PERMISSION_REQUIRED: Notification Listener...');
  }
}
```

### Requesting Permissions Programmatically

```dart
// From Flutter code
final appState = context.read<AppState>();

// Check status
bool hasAccessibility = await appState.checkAccessibilityStatus();
bool hasNotifications = await appState.checkNotificationListenerStatus();

// Request permissions (opens Settings)
if (!hasAccessibility) {
  await appState.requestAccessibilityPermission();
}

if (!hasNotifications) {
  await appState.requestNotificationListenerPermission();
}
```

## Node Configuration

### UI Automation Nodes

#### Tap Element
```json
{
  "toolId": "ui_tap",
  "parameters": {
    "text": "Submit",           // Optional: tap by text
    "resourceId": "button_id",  // Optional: tap by resource ID
    "x": 500,                   // Optional: tap by coordinates
    "y": 800
  }
}
```

#### Type Text
```json
{
  "toolId": "ui_type",
  "parameters": {
    "text": "Hello World"
  }
}
```

#### Swipe
```json
{
  "toolId": "ui_swipe",
  "parameters": {
    "direction": "up",          // "up", "down", "left", "right"
    "fromX": 500,              // Optional: custom start/end coordinates
    "fromY": 1000,
    "toX": 500,
    "toY": 200
  }
}
```

#### Open App
```json
{
  "toolId": "ui_open_app",
  "parameters": {
    "packageName": "com.android.chrome"
  }
}
```

### Notification Nodes

#### Get All Notifications
```json
{
  "toolId": "notif_get_all",
  "parameters": {}
}
```

#### Get App Notifications
```json
{
  "toolId": "notif_get_by_app",
  "parameters": {
    "packageName": "com.whatsapp"
  }
}
```

### System Control Nodes

#### Open Settings
```json
{
  "toolId": "system_open_settings",
  "parameters": {
    "settingsPage": "wifi"      // Optional: "wifi", "bluetooth", "app", "location", "accessibility"
  }
}
```

## Extending System Tools

### Adding New System Tools

1. **Define the tool in `system_tool.dart`:**

```dart
static final myNewTool = SystemTool(
  id: 'my_new_tool',
  name: 'My New Tool',
  description: 'Description of what it does',
  category: SystemToolCategory.systemControl,
  requiresPermission: false,
  parameters: [
    SystemToolParameter(
      name: 'param1',
      type: 'string',
      description: 'Parameter description',
      required: true,
    ),
  ],
);
```

2. **Add execution logic in `kotlin_bridge.kt`:**

```kotlin
private suspend fun executeSystemToolInternal(
    toolId: String,
    parameters: Map<String, Any>
): Map<String, Any> {
    return when (toolId) {
        // ... existing tools ...
        "my_new_tool" -> {
            val param1 = parameters["param1"] as? String ?: ""
            // Your implementation here
            mapOf(
                "success" to true,
                "data" to "result"
            )
        }
        else -> {
            mapOf("success" to false, "error" to "Unknown tool: $toolId")
        }
    }
}
```

3. **Add node template in `node_palette.dart`:**

```dart
NodeTemplate(
  type: NodeType.systemToolAction,
  name: 'My New Tool',
  description: 'Description',
  category: 'System',
  icon: Icons.new_releases,
  color: Colors.teal.shade700,
  inputs: [NodePort(id: 'input', name: 'Input', type: PortType.input)],
  outputs: [NodePort(id: 'output', name: 'Output', type: PortType.output)],
  defaultParameters: {'toolId': 'my_new_tool'},
),
```

## Error Handling

### Permission Errors

```dart
try {
  await executeSystemTool(toolId: 'ui_tap', parameters: {...});
} catch (e) {
  if (e.toString().contains('PERMISSION_REQUIRED')) {
    // Handle permission error
    // Show dialog to user
    // Navigate to settings
  }
}
```

### Tool Execution Errors

```dart
try {
  final result = await executeSystemTool(...);
  if (result['success'] == false) {
    // Handle tool-specific error
    print('Error: ${result['error']}');
  }
} catch (e) {
  // Handle general execution error
}
```

## Best Practices

1. **Always check permissions** before adding system tool nodes to workflows
2. **Use variables** to pass data between nodes
3. **Add error handlers** for robust workflows
4. **Test workflows** with different screen states
5. **Use Get Screen Hierarchy** to debug UI automation issues
6. **Combine with AI tools** for intelligent automation
7. **Save common workflows** as templates

## Integration with Existing Tools

System tools work seamlessly with:

- **Composio integrations** - Automate external services
- **MCP servers** - Access additional capabilities
- **Google Workspace** - Combine with Gmail, Calendar, Drive
- **Built-in AI tools** - Use LLM for intelligent decisions
- **Code nodes** - Custom JavaScript/Python logic

## Example: Complex Automation

```dart
Schedule Trigger (every day at 9 AM)
    ↓
Get All Notifications
    ↓
Set Variable (name: "allNotifications")
    ↓
Loop (items: {{ allNotifications }})
    ↓
If/Else (condition: {{ item.packageName }} == "com.whatsapp")
    ↓ (true)
Open App (packageName: "com.whatsapp")
    ↓
Get Screen Hierarchy
    ↓
AI Assistant (analyze screen and respond to message)
    ↓
Tap Element (text: "Send")
    ↓
Press Home
```

## Troubleshooting

### Issue: "Accessibility Service is not running"

**Solution:**
1. Go to Android Settings
2. Navigate to Accessibility
3. Find Blurr and enable it
4. Restart the app if needed

### Issue: "Notification Listener permission not granted"

**Solution:**
1. Go to Android Settings
2. Navigate to Notification Access or Apps → Special Access → Notification Access
3. Find Blurr and enable it

### Issue: Tool execution returns error

**Solution:**
1. Check the tool parameters are correct
2. Use Get Screen Hierarchy to debug UI state
3. Ensure the app is in the correct state
4. Check logcat for detailed error messages

### Issue: Workflow stops unexpectedly

**Solution:**
1. Add error handler nodes
2. Check permission status before execution
3. Use try-catch in custom code nodes
4. Review execution logs in the execution panel

## Performance Considerations

- **UI automation** operations are synchronous and may take 100-500ms each
- **Screenshot capture** can take 500ms-1s depending on screen size
- **Screen hierarchy extraction** is fast (~50-100ms)
- **Notification access** is instant
- Use **variables** to cache results and avoid repeated operations

## Security & Privacy

- System tools require explicit user permission
- All operations are performed locally on the device
- No data is sent to external servers
- Workflows are stored locally in SharedPreferences
- Users maintain full control over permissions

## Future Enhancements

Planned features:
- [ ] Visual element picker for UI automation
- [ ] Record & playback mode
- [ ] Advanced screen analysis with OCR
- [ ] Gesture recording
- [ ] Conditional UI element finding
- [ ] Screenshot comparison
- [ ] Notification history access
- [ ] System event triggers (screen on/off, battery level, etc.)

## Support

For issues or questions:
- Check the [main documentation](../README.md)
- Review [integration guide](./INTEGRATION_GUIDE.md)
- Check existing [workflow examples](./examples/)
- File issues on GitHub

---

**Last Updated:** 2024
**Version:** 1.0.0

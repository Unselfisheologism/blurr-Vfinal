# Quick Start Guide - Flutter Workflow Editor

Get the workflow editor running in your Twent AI assistant in 5 steps.

## Step 1: Install Dependencies

```bash
cd flutter_workflow_editor
flutter pub get
```

## Step 2: Generate Code

```bash
# Generate JSON serialization code
flutter pub run build_runner build --delete-conflicting-outputs
```

## Step 3: Add to Android App

### Update settings.gradle.kts

```kotlin
// settings.gradle.kts (project root)
include(":app")
include(":flutter_workflow_editor")
project(":flutter_workflow_editor").projectDir = File("flutter_workflow_editor/.android/Flutter")
```

### Update app/build.gradle.kts

```kotlin
dependencies {
    implementation(project(":flutter_workflow_editor"))
    // ... other dependencies
}
```

## Step 4: Initialize in MainActivity

```kotlin
import com.twent.voice.workflow.WorkflowEditorHandler
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Get or create Flutter engine
        val flutterEngine = flutterEngine ?: return
        
        // Create workflow handler
        val handler = WorkflowEditorHandler(
            context = this,
            unifiedShellTool = getUnifiedShellTool(),
            composioClient = getComposioClient(),
            composioManager = getComposioManager(),
            mcpClient = getMCPClient()
        )
        
        // Register method channel
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "workflow_editor"
        ).setMethodCallHandler(handler)
    }
}
```

## Step 5: Launch Workflow Editor

### Option A: As Activity

```kotlin
fun launchWorkflowEditor() {
    val intent = FlutterActivity
        .withNewEngine()
        .initialRoute("/")
        .build(this)
    
    startActivity(intent)
}
```

### Option B: As Fragment

```kotlin
fun showWorkflowEditor() {
    val fragment = FlutterFragment.createDefault()
    
    supportFragmentManager
        .beginTransaction()
        .replace(R.id.fragment_container, fragment)
        .addToBackStack(null)
        .commit()
}
```

## Step 6: Test It

```kotlin
// In your menu or button click
findViewById<Button>(R.id.btn_workflow_editor).setOnClickListener {
    launchWorkflowEditor()
}
```

## Troubleshooting

### Build Errors

**Issue**: `Cannot find fl_nodes package`  
**Fix**: Make sure you have git access to the fl_nodes repo, or download manually

**Issue**: `JSON serialization errors`  
**Fix**: Run `flutter pub run build_runner build --delete-conflicting-outputs`

**Issue**: `Method channel not found`  
**Fix**: Verify WorkflowEditorHandler is registered before Flutter engine starts

### Runtime Errors

**Issue**: `Platform exception: SHELL_ERROR`  
**Fix**: Ensure UnifiedShellTool is properly initialized and passed to handler

**Issue**: `No Composio tools found`  
**Fix**: This is normal if user hasn't connected any integrations yet

**Issue**: `Canvas not rendering`  
**Fix**: Check that fl_nodes is properly imported and pubspec.yaml is correct

## Next Steps

1. **Create Your First Workflow**
   - Open editor
   - Drag "Manual Trigger" from palette
   - Add a "Unified Shell" node
   - Connect them
   - Configure and run

2. **Explore Node Types**
   - Browse all 22 node types in the palette
   - Try Composio integration (if tools connected)
   - Test MCP server integration

3. **Customize**
   - Add custom node types (see README.md)
   - Modify styling in canvas settings
   - Create workflow templates

## Support

For issues or questions:
1. Check `IMPLEMENTATION_SUMMARY.md` for architecture details
2. Review inline code comments
3. Contact development team

---

**You're ready to build powerful mobile workflows! 🚀**

# Flutter Workflow Editor - Integration Guide

Complete guide for integrating the Flutter workflow editor module into the Blurr Voice Android app.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Android Integration](#android-integration)
3. [Platform Channel Setup](#platform-channel-setup)
4. [Composio Integration](#composio-integration)
5. [MCP Integration](#mcp-integration)
6. [Testing](#testing)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Dependencies

**In your root `build.gradle`:**
```gradle
buildscript {
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.0"
    }
}
```

**In your app `build.gradle.kts`:**
```kotlin
dependencies {
    // Flutter module
    implementation(project(":flutter_workflow_editor"))
    
    // Already have these (required for bridge)
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
    implementation("com.google.code.gson:gson:2.13.1")
}
```

---

## Android Integration

### Step 1: Add Flutter Module

**In `settings.gradle.kts`:**
```kotlin
// Add Flutter module
setBinding(Binding(settings))
include(":flutter_workflow_editor")
project(":flutter_workflow_editor").projectDir = 
    File("../flutter_workflow_editor/.android/Flutter")
```

### Step 2: Create WorkflowBridge.kt

Create file: `app/src/main/kotlin/com/blurr/voice/flutter/WorkflowBridge.kt`

```kotlin
package com.blurr.voice.flutter

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.blurr.voice.utilities.FreemiumManager
import com.blurr.voice.integrations.ComposioIntegrationManager
import com.google.gson.Gson
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class WorkflowEditorBridge(
    private val context: Context,
    private val flutterEngine: FlutterEngine
) {
    companion object {
        private const val CHANNEL_NAME = "com.blurr.workflow_editor"
    }

    private val methodChannel = MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        CHANNEL_NAME
    )
    
    private val gson = Gson()
    private val scope = CoroutineScope(Dispatchers.Main)
    private val freemiumManager = FreemiumManager()

    init {
        setupMethodCallHandler()
    }

    private fun setupMethodCallHandler() {
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "getProStatus" -> handleGetProStatus(result)
                "getComposioTools" -> handleGetComposioTools(result)
                "getMcpServers" -> handleGetMcpServers(result)
                "executeComposioAction" -> handleExecuteComposioAction(call, result)
                "executeMcpRequest" -> handleExecuteMcpRequest(call, result)
                "saveWorkflow" -> handleSaveWorkflow(call, result)
                "loadWorkflow" -> handleLoadWorkflow(call, result)
                "getWorkflows" -> handleGetWorkflows(result)
                "showProUpgradeDialog" -> handleShowProUpgradeDialog(call, result)
                else -> result.notImplemented()
            }
        }
    }

    private fun handleGetProStatus(result: MethodChannel.Result) {
        scope.launch {
            try {
                val isPro = withContext(Dispatchers.IO) {
                    freemiumManager.hasComposioAccess()
                }
                result.success(isPro)
            } catch (e: Exception) {
                result.error("PRO_STATUS_ERROR", e.message, null)
            }
        }
    }

    private fun handleGetComposioTools(result: MethodChannel.Result) {
        scope.launch {
            try {
                val manager = ComposioIntegrationManager(context)
                
                val tools = withContext(Dispatchers.IO) {
                    val toolsResult = manager.listAvailableIntegrations()
                    if (toolsResult.isSuccess) {
                        toolsResult.getOrNull() ?: emptyList()
                    } else {
                        emptyList()
                    }
                }

                val toolsList = tools.map { tool ->
                    mapOf(
                        "id" to tool.key,
                        "name" to tool.name,
                        "appKey" to tool.key,
                        "description" to (tool.description ?: ""),
                        "icon" to (tool.logo ?: ""),
                        "connected" to true,
                        "actions" to emptyList<Any>()
                    )
                }

                result.success(toolsList)
            } catch (e: Exception) {
                result.error("COMPOSIO_ERROR", e.message, null)
            }
        }
    }

    private fun handleGetMcpServers(result: MethodChannel.Result) {
        scope.launch {
            try {
                // TODO: Implement MCP server listing
                result.success(emptyList<Map<String, Any>>())
            } catch (e: Exception) {
                result.error("MCP_ERROR", e.message, null)
            }
        }
    }

    private fun handleExecuteComposioAction(
        call: MethodChannel.MethodCall,
        result: MethodChannel.Result
    ) {
        val toolId = call.argument<String>("toolId")
        val actionName = call.argument<String>("actionName")
        val parameters = call.argument<Map<String, Any>>("parameters")

        if (toolId == null || actionName == null || parameters == null) {
            result.error("INVALID_ARGS", "Missing required parameters", null)
            return
        }

        scope.launch {
            try {
                val manager = ComposioIntegrationManager(context)
                
                val actionResult = withContext(Dispatchers.IO) {
                    manager.executeAction(
                        integration = toolId,
                        actionName = actionName,
                        params = parameters,
                        userId = "current_user"
                    )
                }

                if (actionResult.isSuccess) {
                    result.success(actionResult.getOrNull() ?: emptyMap<String, Any>())
                } else {
                    result.error(
                        "COMPOSIO_ACTION_ERROR",
                        actionResult.exceptionOrNull()?.message,
                        null
                    )
                }
            } catch (e: Exception) {
                result.error("COMPOSIO_ACTION_ERROR", e.message, null)
            }
        }
    }

    private fun handleExecuteMcpRequest(
        call: MethodChannel.MethodCall,
        result: MethodChannel.Result
    ) {
        // TODO: Implement MCP request execution
        result.success(mapOf("success" to true))
    }

    private fun handleSaveWorkflow(
        call: MethodChannel.MethodCall,
        result: MethodChannel.Result
    ) {
        val workflow = call.argument<Map<String, Any>>("workflow")
        if (workflow == null) {
            result.error("INVALID_ARGS", "Missing workflow data", null)
            return
        }

        scope.launch {
            try {
                val workflowId = workflow["id"] as? String ?: ""
                val json = gson.toJson(workflow)
                
                withContext(Dispatchers.IO) {
                    val prefs = context.getSharedPreferences("workflows", Context.MODE_PRIVATE)
                    prefs.edit().putString("workflow_$workflowId", json).apply()
                }

                result.success(true)
            } catch (e: Exception) {
                result.error("SAVE_ERROR", e.message, null)
            }
        }
    }

    private fun handleLoadWorkflow(
        call: MethodChannel.MethodCall,
        result: MethodChannel.Result
    ) {
        val workflowId = call.argument<String>("workflowId")
        if (workflowId == null) {
            result.error("INVALID_ARGS", "Missing workflow ID", null)
            return
        }

        scope.launch {
            try {
                val json = withContext(Dispatchers.IO) {
                    val prefs = context.getSharedPreferences("workflows", Context.MODE_PRIVATE)
                    prefs.getString("workflow_$workflowId", null)
                }

                if (json != null) {
                    val workflow = gson.fromJson(json, Map::class.java)
                    result.success(workflow)
                } else {
                    result.success(null)
                }
            } catch (e: Exception) {
                result.error("LOAD_ERROR", e.message, null)
            }
        }
    }

    private fun handleGetWorkflows(result: MethodChannel.Result) {
        scope.launch {
            try {
                val workflows = withContext(Dispatchers.IO) {
                    val prefs = context.getSharedPreferences("workflows", Context.MODE_PRIVATE)
                    prefs.all.entries
                        .filter { it.key.startsWith("workflow_") }
                        .mapNotNull { 
                            try {
                                gson.fromJson(it.value as String, Map::class.java)
                            } catch (e: Exception) {
                                null
                            }
                        }
                }
                result.success(workflows)
            } catch (e: Exception) {
                result.error("GET_WORKFLOWS_ERROR", e.message, null)
            }
        }
    }

    private fun handleShowProUpgradeDialog(
        call: MethodChannel.MethodCall,
        result: MethodChannel.Result
    ) {
        // Navigate to ProPurchaseActivity
        result.success(true)
    }

    fun dispose() {
        methodChannel.setMethodCallHandler(null)
    }
}
```

### Step 3: Create WorkflowEditorActivity

Create: `app/src/main/kotlin/com/blurr/voice/WorkflowEditorActivity.kt`

```kotlin
package com.blurr.voice

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import io.flutter.embedding.android.FlutterFragment
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import com.blurr.voice.flutter.WorkflowEditorBridge

class WorkflowEditorActivity : AppCompatActivity() {
    
    companion object {
        private const val ENGINE_ID = "workflow_editor_engine"
    }
    
    private var bridge: WorkflowEditorBridge? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_workflow_editor)
        
        // Get or create Flutter engine
        val flutterEngine = FlutterEngineCache.getInstance().get(ENGINE_ID)
            ?: createFlutterEngine()
        
        // Create bridge
        bridge = WorkflowEditorBridge(this, flutterEngine)
        
        // Add Flutter fragment
        if (savedInstanceState == null) {
            supportFragmentManager
                .beginTransaction()
                .add(
                    R.id.flutter_container,
                    FlutterFragment.withCachedEngine(ENGINE_ID).build()
                )
                .commit()
        }
    }
    
    private fun createFlutterEngine(): FlutterEngine {
        val engine = FlutterEngine(this)
        
        // Start executing Dart code
        engine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
        
        // Cache the engine
        FlutterEngineCache.getInstance().put(ENGINE_ID, engine)
        
        return engine
    }
    
    override fun onDestroy() {
        super.onDestroy()
        bridge?.dispose()
        
        // Don't destroy engine if finishing activity
        // Keep it cached for reuse
    }
}
```

### Step 4: Create Layout

Create: `app/src/main/res/layout/activity_workflow_editor.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:id="@+id/flutter_container"
    android:layout_width="match_parent"
    android:layout_height="match_parent" />
```

### Step 5: Update AndroidManifest.xml

```xml
<activity
    android:name=".WorkflowEditorActivity"
    android:theme="@style/Theme.AppCompat.NoActionBar"
    android:configChanges="orientation|keyboardHidden|keyboard|screenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
    android:hardwareAccelerated="true"
    android:windowSoftInputMode="adjustResize" />
```

### Step 6: Add Navigation

In your `SettingsActivity` or wherever you want to open the workflow editor:

```kotlin
// Add menu item or button
binding.btnWorkflowEditor.setOnClickListener {
    startActivity(Intent(this, WorkflowEditorActivity::class.java))
}
```

---

## Platform Channel Setup

The bridge handles these methods:

| Method | Description | Returns |
|--------|-------------|---------|
| `getProStatus` | Check if user has Pro subscription | `Boolean` |
| `getComposioTools` | Get list of connected Composio tools | `List<Map>` |
| `getMcpServers` | Get list of connected MCP servers | `List<Map>` |
| `executeComposioAction` | Execute Composio integration action | `Map` |
| `executeMcpRequest` | Execute MCP server request | `Map` |
| `saveWorkflow` | Save workflow to native storage | `Boolean` |
| `loadWorkflow` | Load workflow from native storage | `Map?` |
| `getWorkflows` | Get list of all workflows | `List<Map>` |
| `showProUpgradeDialog` | Show native upgrade dialog | `Boolean` |

---

## Composio Integration

The workflow editor automatically detects Composio tools from your existing integration:

```kotlin
// Your existing ComposioIntegrationManager is used
val manager = ComposioIntegrationManager(context)

// Workflow editor calls:
// 1. listAvailableIntegrations() - to populate node palette
// 2. executeAction() - when workflow runs
```

### Available in Workflow Editor:
- All connected Composio tools appear as node options
- User can drag "Composio Action" node
- Configure tool, action, and parameters in inspector
- Execute during workflow run

---

## MCP Integration

Similar pattern for MCP servers:

```kotlin
// TODO: Implement in WorkflowBridge
private fun handleGetMcpServers(result: MethodChannel.Result) {
    // Get your MCP servers here
    val servers = yourMcpClient.getConnectedServers()
    
    result.success(servers.map { server ->
        mapOf(
            "id" to server.id,
            "name" to server.name,
            "url" to server.url,
            "tools" to server.tools.map { tool ->
                mapOf(
                    "name" to tool.name,
                    "description" to tool.description,
                    "inputSchema" to tool.inputSchema
                )
            }
        )
    })
}

private fun handleExecuteMcpRequest(...) {
    // Execute MCP request
    val result = yourMcpClient.request(serverId, method, params)
    result.success(result)
}
```

---

## Testing

### 1. Test Platform Channel

```kotlin
// In your test
@Test
fun testPlatformChannel() {
    val engine = FlutterEngine(context)
    val bridge = WorkflowEditorBridge(context, engine)
    
    // Test Pro status
    val channel = MethodChannel(engine.dartExecutor, "com.blurr.workflow_editor")
    channel.invokeMethod("getProStatus", null) { result ->
        assertTrue(result is Boolean)
    }
}
```

### 2. Test Workflow Creation

1. Open WorkflowEditorActivity
2. Drag "Manual Trigger" node from palette
3. Verify node appears on canvas
4. Drag "Composio Action" node
5. Connect nodes
6. Configure Composio node (select Gmail tool)
7. Click "Execute"
8. Verify execution logs appear

### 3. Test Composio Execution

1. Create workflow with Composio node
2. Configure: Tool=Gmail, Action=send_email
3. Set parameters: `{"to": "test@example.com", "subject": "Test"}`
4. Execute workflow
5. Verify email sent via Composio

---

## Troubleshooting

### Issue: Flutter module not found

**Solution:**
```bash
cd flutter_workflow_editor
flutter pub get
cd .android
./gradlew build
```

### Issue: Platform channel not responding

**Check:**
1. FlutterEngine initialized before creating bridge
2. Method channel name matches: `com.blurr.workflow_editor`
3. Bridge created with correct engine instance

**Debug:**
```kotlin
// Add logging
methodChannel.setMethodCallHandler { call, result ->
    Log.d("WorkflowBridge", "Method called: ${call.method}")
    // ... handle methods
}
```

### Issue: Composio tools not loading

**Check:**
1. User is signed in to Composio
2. `FreemiumManager.hasComposioAccess()` returns `true` for Pro users
3. `ComposioIntegrationManager.listAvailableIntegrations()` returns data

**Fix:**
```kotlin
// Test Composio directly
val manager = ComposioIntegrationManager(context)
val result = manager.listAvailableIntegrations()
Log.d("Composio", "Tools: ${result.getOrNull()}")
```

### Issue: Workflows not saving

**Check:**
1. SharedPreferences permissions
2. JSON serialization working
3. Workflow ID is valid UUID

**Fix:**
```kotlin
// Test save directly
val prefs = context.getSharedPreferences("workflows", Context.MODE_PRIVATE)
prefs.edit().putString("test", "{}").apply()
val saved = prefs.getString("test", null)
Log.d("Storage", "Saved: $saved")
```

### Issue: App crashes on Flutter fragment

**Solution:**
Ensure `FlutterEngineCache` is properly initialized:
```kotlin
// In Application class
class BlurrApp : Application() {
    override fun onCreate() {
        super.onCreate()
        // Pre-warm Flutter engine
        val engine = FlutterEngine(this)
        engine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
        FlutterEngineCache.getInstance().put("workflow_editor_engine", engine)
    }
}
```

---

## Performance Tips

1. **Pre-warm Flutter engine** in Application.onCreate()
2. **Cache engine** across activity restarts
3. **Lazy load** Composio tools (fetch on demand)
4. **Debounce** save operations (don't save on every change)
5. **Limit** canvas to 100 nodes for performance

---

## Next Steps

1. ✅ Complete Android integration
2. ⏳ Add MCP server integration
3. ⏳ Implement iOS bridge (Swift)
4. ⏳ Add team collaboration (Pro feature)
5. ⏳ Add workflow sharing (Pro feature)
6. ⏳ Add AI-assisted node creation (Pro feature)

---

## Support

For integration issues:
1. Check logs: `adb logcat | grep Flutter`
2. Verify bridge setup
3. Test platform channels independently
4. Check Composio/MCP connections

Contact: Blurr development team

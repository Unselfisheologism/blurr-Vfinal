// Workflow Editor Activity for launching Flutter workflow editor
package com.blurr.voice

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.blurr.voice.flutter.FlutterRuntime
import com.blurr.voice.flutter.WorkflowEditorBridge
import io.flutter.embedding.android.FlutterFragment
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor

/**
 * Activity for hosting the Flutter workflow editor
 * Integrates with Composio, MCP, and Google Workspace
 */
class WorkflowEditorActivity : AppCompatActivity() {
    
    companion object {
        private const val ENGINE_ID = "workflow_editor_engine"
        private const val TAG = "WorkflowEditorActivity"
    }
    
    private var bridge: WorkflowEditorBridge? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (!FlutterRuntime.isAvailable()) {
            FlutterRuntime.showUnavailableScreen(
                activity = this,
                featureTitle = "Workflow Editor",
                featureDescription = "AI-native workflow builder and automation canvas."
            )
            return
        }

        setContentView(R.layout.activity_workflow_editor)

        // Get or create Flutter engine
        val flutterEngine = FlutterEngineCache.getInstance().get(ENGINE_ID)
            ?: createFlutterEngine()

        // Create bridge for platform communication
        bridge = WorkflowEditorBridge(this, flutterEngine)

        // Handle intent extras (workflow_json and auto_execute from AI agent)
        handleIntentExtras()

        // Add Flutter fragment if not already added
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
    
    private fun handleIntentExtras() {
        val workflowJson = intent.getStringExtra("workflow_json")
        val autoExecute = intent.getBooleanExtra("auto_execute", false)
        
        if (workflowJson != null) {
            // Send workflow data to Flutter via bridge
            bridge?.loadWorkflow(workflowJson, autoExecute)
        }
    }
    
    private fun createFlutterEngine(): FlutterEngine {
        val engine = FlutterEngine(this)

        // Ensure we land on the workflow editor route.
        engine.navigationChannel.setInitialRoute("/")

        engine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )

        FlutterEngineCache.getInstance().put(ENGINE_ID, engine)

        return engine
    }
    
    override fun onDestroy() {
        super.onDestroy()
        bridge?.dispose()
        
        // Note: We keep the engine cached for faster reopening
        // If you want to destroy it completely, uncomment:
        // FlutterEngineCache.getInstance().remove(ENGINE_ID)?.destroy()
    }
}

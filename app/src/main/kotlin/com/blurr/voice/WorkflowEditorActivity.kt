// Workflow Editor Activity for launching Flutter workflow editor
package com.twent.voice

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import io.flutter.embedding.android.FlutterFragment
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import com.twent.voice.flutter.WorkflowEditorBridge

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
        // Create new Flutter engine
        val engine = FlutterEngine(this)
        
        // Start executing Dart code
        engine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
        
        // Cache the engine for reuse
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

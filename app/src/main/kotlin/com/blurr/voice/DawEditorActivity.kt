// DAW Editor Activity for launching Flutter DAW editor
package com.blurr.voice

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import io.flutter.embedding.android.FlutterFragment
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import com.blurr.voice.flutter.DawEditorBridge

/**
 * Activity for hosting the Flutter DAW (Digital Audio Workstation) editor
 * AI-native music creation with multi-track timeline, waveform editing, and AI generation
 */
class DawEditorActivity : AppCompatActivity() {
    
    companion object {
        private const val ENGINE_ID = "daw_editor_engine"
        private const val TAG = "DawEditorActivity"
    }
    
    private var bridge: DawEditorBridge? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_daw_editor)
        
        // Get or create Flutter engine
        val flutterEngine = FlutterEngineCache.getInstance().get(ENGINE_ID)
            ?: createFlutterEngine()
        
        // Create bridge for platform communication
        bridge = DawEditorBridge(this, flutterEngine)
        
        // Handle intent extras (project_name, project_path from main app)
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
        val projectName = intent.getStringExtra("project_name")
        val projectPath = intent.getStringExtra("project_path")
        
        if (projectName != null || projectPath != null) {
            // Send project data to Flutter via bridge
            bridge?.loadProject(projectName, projectPath)
        }
    }
    
    private fun createFlutterEngine(): FlutterEngine {
        // Create new Flutter engine
        val engine = FlutterEngine(this)
        
        // Start executing Dart code with DAW entry point
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

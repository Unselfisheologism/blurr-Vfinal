// Spreadsheet Editor Activity for launching Flutter spreadsheet editor
package com.blurr.voice

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import io.flutter.embedding.android.FlutterFragment
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import com.blurr.voice.flutter.SpreadsheetEditorBridge

/**
 * Activity for hosting the Flutter spreadsheet editor
 * Integrates with AI agent for intelligent spreadsheet operations
 */
class SpreadsheetEditorActivity : AppCompatActivity() {
    
    companion object {
        private const val ENGINE_ID = "spreadsheet_editor_engine"
        private const val TAG = "SpreadsheetEditorActivity"
        
        // Intent extras
        const val EXTRA_DOCUMENT_ID = "document_id"
        const val EXTRA_INITIAL_PROMPT = "initial_prompt"
    }
    
    private var bridge: SpreadsheetEditorBridge? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_spreadsheet_editor)
        
        // Get or create Flutter engine
        val flutterEngine = FlutterEngineCache.getInstance().get(ENGINE_ID)
            ?: createFlutterEngine()
        
        // Create bridge for platform communication
        bridge = SpreadsheetEditorBridge(this, flutterEngine)
        
        // Handle intent extras
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
        val documentId = intent.getStringExtra(EXTRA_DOCUMENT_ID)
        val initialPrompt = intent.getStringExtra(EXTRA_INITIAL_PROMPT)
        
        if (documentId != null) {
            // Load existing document
            bridge?.loadDocument(documentId)
        } else if (initialPrompt != null) {
            // Create from AI prompt
            bridge?.createFromPrompt(initialPrompt)
        }
        // Otherwise, create blank spreadsheet (handled by Flutter)
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

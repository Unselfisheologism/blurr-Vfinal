// Media Canvas Activity for launching Flutter media canvas
package com.twent.voice

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import io.flutter.embedding.android.FlutterFragment
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import com.twent.voice.flutter.MediaCanvasBridge

/**
 * Activity for hosting the Flutter multimodal media canvas
 * Epic 4: AI-Native Multimodal Media Generation Canvas
 * Inspired by Jaaz and Refly infinite canvas concepts
 */
class MediaCanvasActivity : AppCompatActivity() {
    
    companion object {
        private const val ENGINE_ID = "media_canvas_engine"
        private const val TAG = "MediaCanvasActivity"
        
        // Intent extras
        const val EXTRA_DOCUMENT_ID = "document_id"
        const val EXTRA_INITIAL_PROMPT = "initial_prompt"
    }
    
    private var bridge: MediaCanvasBridge? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_media_canvas)
        
        // Get or create Flutter engine
        val flutterEngine = FlutterEngineCache.getInstance().get(ENGINE_ID)
            ?: createFlutterEngine()
        
        // Create bridge for platform communication
        bridge = MediaCanvasBridge(this, flutterEngine)
        
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
            // Load existing canvas
            bridge?.loadCanvas(documentId)
        } else if (initialPrompt != null) {
            // Create from AI prompt
            bridge?.createFromPrompt(initialPrompt)
        }
        // Otherwise, create blank canvas (handled by Flutter)
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
        
        // Keep engine cached for faster reopening
        // Uncomment to destroy completely:
        // FlutterEngineCache.getInstance().remove(ENGINE_ID)?.destroy()
    }
}

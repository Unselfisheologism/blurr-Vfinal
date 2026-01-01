// Video Editor Activity for launching Flutter AI-Native Video Editor
package com.blurr.voice

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.blurr.voice.flutter.FlutterRuntime
import com.blurr.voice.flutter.VideoEditorBridge
import io.flutter.embedding.android.FlutterFragment
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor

/**
 * Activity for hosting the Flutter AI-Native Video Editor.
 *
 * Epic 7: CapCut-like multi-track editor with AI tooling and export.
 */
class VideoEditorActivity : AppCompatActivity() {

    companion object {
        private const val ENGINE_ID = "video_editor_engine"
        private const val ROUTE = "/video_editor"
    }

    private var bridge: VideoEditorBridge? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (!FlutterRuntime.isAvailable()) {
            FlutterRuntime.showUnavailableScreen(
                activity = this,
                featureTitle = "AI Video Editor",
                featureDescription = "CapCut-style multi-track editor with AI tooling and export."
            )
            return
        }

        setContentView(R.layout.activity_video_editor)

        val flutterEngine = FlutterEngineCache.getInstance().get(ENGINE_ID) ?: createFlutterEngine()
        // If the engine is reused, ensure we land on the correct route.
        flutterEngine.navigationChannel.pushRoute(ROUTE)
        bridge = VideoEditorBridge(this, flutterEngine)

        if (savedInstanceState == null) {
            supportFragmentManager
                .beginTransaction()
                .add(R.id.flutter_container, FlutterFragment.withCachedEngine(ENGINE_ID).build())
                .commit()
        }
    }

    private fun createFlutterEngine(): FlutterEngine {
        val engine = FlutterEngine(this)

        // Ensure the editor opens directly instead of landing on the module home.
        engine.navigationChannel.setInitialRoute(ROUTE)

        engine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )

        FlutterEngineCache.getInstance().put(ENGINE_ID, engine)
        return engine
    }

    override fun onDestroy() {
        super.onDestroy()
        bridge?.dispose()
    }
}

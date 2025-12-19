package com.blurr.voice

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.blurr.voice.flutter.LearningPlatformBridge
import io.flutter.embedding.android.FlutterFragment
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor

/**
 * Host Activity for the Flutter Learning Hub (AI-Native Learning Platform).
 */
class LearningPlatformActivity : AppCompatActivity() {

    companion object {
        private const val ENGINE_ID = "learning_platform_engine"
        private const val INITIAL_ROUTE = "/learning_hub"
    }

    private var bridge: LearningPlatformBridge? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_learning_platform)

        val engine = FlutterEngineCache.getInstance().get(ENGINE_ID) ?: createFlutterEngine()
        bridge = LearningPlatformBridge(this, engine)

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

        // Ensure the embedded engine boots directly into the Learning Hub.
        engine.navigationChannel.setInitialRoute(INITIAL_ROUTE)
        engine.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())

        FlutterEngineCache.getInstance().put(ENGINE_ID, engine)
        return engine
    }

    override fun onDestroy() {
        super.onDestroy()
        bridge?.dispose()
        // Keep engine cached for faster subsequent opens.
    }
}

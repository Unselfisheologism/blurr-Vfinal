// Learning Platform Activity for Android
package com.blurr.voice.apps.learning

import android.content.Intent
import android.os.Bundle
import android.view.MenuItem
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.blurr.voice.R
import com.blurr.voice.activities.MainActivity
import com.blurr.voice.flutter.LearningPlatformBridge
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor

/**
 * Android Activity for the Learning Platform
 * 
 * Hosts the Flutter module and provides navigation integration
 * with the main Blurr AI app.
 */
class LearningPlatformActivity : AppCompatActivity() {
    
    private var learningBridge: LearningPlatformBridge? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_learning_platform)
        
        setupActionBar()
        initializeFlutterEngine()
        handleIntent(intent)
    }

    private fun setupActionBar() {
        supportActionBar?.apply {
            setDisplayHomeAsUpEnabled(true)
            setDisplayShowHomeEnabled(true)
            title = "Learning Hub"
        }
    }

    private fun initializeFlutterEngine() {
        // Check if we already have a cached engine
        var flutterEngine = FlutterEngineCache.getInstance().get("learning_platform")
        
        if (flutterEngine == null) {
            // Create new Flutter engine for Learning Platform
            flutterEngine = FlutterEngine(this)
            
            // Start the Dart VM and execute the entrypoint
            flutterEngine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
            )
            
            // Cache the engine for reuse
            FlutterEngineCache.getInstance().put("learning_platform", flutterEngine)
        }
        
        // Create the bridge for platform communication
        learningBridge = LearningPlatformBridge(this, flutterEngine)
        
        // Start FlutterActivity with the cached engine
        val flutterActivityIntent = FlutterActivity
            .withCachedEngine("learning_platform")
            .build(this)
            
        startActivity(flutterActivityIntent)
    }

    private fun handleIntent(intent: Intent?) {
        intent?.let {
            when (it.action) {
                Intent.ACTION_VIEW -> {
                    // Handle file sharing from other apps
                    val data = it.data
                    if (data != null) {
                        processSharedDocument(data)
                    }
                }
                "open_document" -> {
                    // Open specific document from file picker
                    val documentPath = it.getStringExtra("document_path")
                    val documentName = it.getStringExtra("document_name")
                    if (documentPath != null) {
                        openSharedDocument(documentPath, documentName)
                    }
                }
                "from_notification" -> {
                    // Handle learning reminder notifications
                    showLearningReminder()
                }
            }
        }
    }

    private fun processSharedDocument(uri: android.net.Uri) {
        Toast.makeText(this, "Processing shared document...", Toast.LENGTH_SHORT).show()
        // Implementation would handle document processing from shared intent
        // For now, just show a toast
    }

    private fun openSharedDocument(filePath: String, fileName: String) {
        Toast.makeText(this, "Opening document: $fileName", Toast.LENGTH_SHORT).show()
        // Implementation would open the specific document in the learning platform
    }

    private fun showLearningReminder() {
        Toast.makeText(this, "Time for your daily study session!", Toast.LENGTH_LONG).show()
        // Implementation would show learning reminder or navigate to today's content
    }

    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent)
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            android.R.id.home -> {
                // Navigate back to main activity
                navigateBackToMain()
                true
            }
            R.id.action_settings -> {
                // Open learning settings
                openLearningSettings()
                true
            }
            R.id.action_help -> {
                // Open learning help
                openLearningHelp()
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }

    private fun navigateBackToMain() {
        val intent = Intent(this, MainActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
        startActivity(intent)
        finish()
    }

    private fun openLearningSettings() {
        // Implementation would open settings for the learning platform
        Toast.makeText(this, "Learning settings coming soon!", Toast.LENGTH_SHORT).show()
    }

    private fun openLearningHelp() {
        // Implementation would open help documentation
        Toast.makeText(this, "Learning help coming soon!", Toast.LENGTH_SHORT).show()
    }

    override fun onBackPressed() {
        // Handle back navigation
        navigateBackToMain()
    }

    override fun onDestroy() {
        super.onDestroy()
        // Clean up resources if needed
        learningBridge = null
    }

    companion object {
        const val ENGINE_ID = "learning_platform"
        
        /**
         * Create intent to launch Learning Platform for a specific document
         */
        fun createIntentForDocument(context: android.content.Context, documentPath: String, documentName: String): Intent {
            return Intent(context, LearningPlatformActivity::class.java).apply {
                action = "open_document"
                putExtra("document_path", documentPath)
                putExtra("document_name", documentName)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            }
        }
        
        /**
         * Create intent to show learning reminder
         */
        fun createReminderIntent(context: android.content.Context): Intent {
            return Intent(context, LearningPlatformActivity::class.java).apply {
                action = "from_notification"
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            }
        }
        
        /**
         * Check if Learning Platform is available
         */
        fun isAvailable(context: android.content.Context): Boolean {
            return true // Learning Platform is always available
        }
    }
}
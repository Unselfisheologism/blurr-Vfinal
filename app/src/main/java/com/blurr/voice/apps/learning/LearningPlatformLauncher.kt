package com.blurr.voice.apps.learning

import android.content.Context
import android.content.Intent

/**
 * Launcher utility for Learning Platform
 * 
 * Provides convenient methods to launch the Learning Platform from anywhere in the app.
 */
object LearningPlatformLauncher {
    
    /**
     * Launch Learning Platform with empty document library
     */
    fun launch(context: Context) {
        val intent = Intent(context, LearningPlatformActivity::class.java)
        context.startActivity(intent)
    }

    /**
     * Launch Learning Platform with a specific document
     */
    fun launchWithDocument(context: Context, documentPath: String, documentName: String) {
        val intent = LearningPlatformActivity.createIntentForDocument(context, documentPath, documentName)
        context.startActivity(intent)
    }

    /**
     * Launch Learning Platform for document processing
     */
    fun launchForProcessing(context: Context, fileUri: String, fileName: String) {
        val intent = Intent(context, LearningPlatformActivity::class.java).apply {
            action = "process_document"
            putExtra("file_uri", fileUri)
            putExtra("file_name", fileName)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
    }

    /**
     * Launch Learning Platform from study reminder
     */
    fun launchReminder(context: Context) {
        val intent = LearningPlatformActivity.createReminderIntent(context)
        context.startActivity(intent)
    }

    /**
     * Launch Learning Platform and check if available
     */
    fun safeLaunch(context: Context, onNotAvailable: (() -> Unit)? = null) {
        if (LearningPlatformActivity.isAvailable(context)) {
            launch(context)
        } else {
            onNotAvailable?.invoke() ?: run {
                // Show default message
                android.widget.Toast.makeText(context, "Learning Platform not available", android.widget.Toast.LENGTH_SHORT).show()
            }
        }
    }
}
package com.blurr.voice.apps.texteditor

import android.content.Context
import android.content.Intent

/**
 * Launcher utility for Text Editor
 * 
 * Provides convenient methods to launch the Text Editor from anywhere in the app.
 */
object TextEditorLauncher {
    
    /**
     * Launch Text Editor with a new empty document
     */
    fun launchNewDocument(context: Context) {
        val intent = Intent(context, TextEditorActivity::class.java)
        context.startActivity(intent)
    }

    /**
     * Launch Text Editor with a specific document
     */
    fun launchDocument(context: Context, documentId: String) {
        val intent = Intent(context, TextEditorActivity::class.java).apply {
            putExtra("documentId", documentId)
        }
        context.startActivity(intent)
    }

    /**
     * Launch Text Editor with template picker
     */
    fun launchWithTemplate(context: Context) {
        val intent = Intent(context, TextEditorActivity::class.java).apply {
            putExtra("startWithTemplate", true)
        }
        context.startActivity(intent)
    }
}

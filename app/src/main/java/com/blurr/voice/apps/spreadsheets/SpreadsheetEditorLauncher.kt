package com.blurr.voice.apps.spreadsheets

import android.content.Context
import android.content.Intent
import com.blurr.voice.SpreadsheetEditorActivity

/**
 * Launcher utility for Spreadsheet Editor
 * 
 * Provides convenient methods to launch the Spreadsheet Editor from anywhere in the app.
 */
object SpreadsheetEditorLauncher {
    
    /**
     * Launch Spreadsheet Editor with a new empty spreadsheet
     */
    fun launchNewSpreadsheet(context: Context) {
        val intent = Intent(context, SpreadsheetEditorActivity::class.java)
        context.startActivity(intent)
    }

    /**
     * Launch Spreadsheet Editor with a specific document
     */
    fun launchSpreadsheet(context: Context, documentId: String) {
        val intent = Intent(context, SpreadsheetEditorActivity::class.java).apply {
            putExtra("documentId", documentId)
        }
        context.startActivity(intent)
    }

    /**
     * Launch Spreadsheet Editor with AI generation mode
     */
    fun launchWithAiGeneration(context: Context, prompt: String? = null) {
        val intent = Intent(context, SpreadsheetEditorActivity::class.java).apply {
            putExtra("startWithAi", true)
            prompt?.let { putExtra("initialPrompt", it) }
        }
        context.startActivity(intent)
    }
}
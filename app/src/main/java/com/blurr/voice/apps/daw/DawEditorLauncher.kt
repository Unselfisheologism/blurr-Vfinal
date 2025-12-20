package com.twent.voice.apps.daw

import android.content.Context
import android.content.Intent

/**
 * Launcher utility for DAW Editor
 * 
 * Provides convenient methods to launch the DAW Editor from anywhere in the app.
 */
object DawEditorLauncher {
    
    /**
     * Launch DAW Editor with a new empty project
     */
    fun launchNewProject(context: Context) {
        val intent = Intent(context, DawEditorActivity::class.java)
        context.startActivity(intent)
    }

    /**
     * Launch DAW Editor with a specific project
     */
    fun launchProject(context: Context, projectName: String) {
        val intent = Intent(context, DawEditorActivity::class.java).apply {
            putExtra("projectName", projectName)
        }
        context.startActivity(intent)
    }

    /**
     * Launch DAW Editor with AI generation mode
     */
    fun launchWithAiGeneration(context: Context) {
        val intent = Intent(context, DawEditorActivity::class.java).apply {
            putExtra("startWithAi", true)
        }
        context.startActivity(intent)
    }
}
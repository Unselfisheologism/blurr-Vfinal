package com.blurr.ai.apps.learning

import android.content.Context
import android.content.Intent

/**
 * Launcher utility for Learning Platform
 * 
 * Provides convenient methods to launch the Learning Platform from anywhere in the app.
 * Following the established pattern from TextEditorLauncher and other AI-native apps.
 */
object LearningPlatformLauncher {
    
    /**
     * Launch Learning Platform with empty state (no documents)
     */
    fun launchEmpty(context: Context) {
        val intent = Intent(context, LearningPlatformActivity::class.java)
        context.startActivity(intent)
    }
    
    /**
     * Launch Learning Platform with a specific document/material
     */
    fun launchWithMaterial(context: Context, materialId: String) {
        val intent = Intent(context, LearningPlatformActivity::class.java).apply {
            putExtra("materialId", materialId)
        }
        context.startActivity(intent)
    }
    
    /**
     * Launch Learning Platform and automatically import a document
     */
    fun launchWithImport(context: Context, documentUri: String, documentType: String) {
        val intent = Intent(context, LearningPlatformActivity::class.java).apply {
            putExtra("documentUri", documentUri)
            putExtra("documentType", documentType)
        }
        context.startActivity(intent)
    }
    
    /**
     * Launch Learning Platform with a specific learning path
     */
    fun launchWithPath(context: Context, pathId: String) {
        val intent = Intent(context, LearningPlatformActivity::class.java).apply {
            putExtra("pathId", pathId)
        }
        context.startActivity(intent)
    }
    
    /**
     * Launch Learning Platform and start quiz generation for a specific material
     */
    fun launchWithQuizGeneration(context: Context, materialId: String, materialTitle: String) {
        val intent = Intent(context, LearningPlatformActivity::class.java).apply {
            putExtra("materialId", materialId)
            putExtra("materialTitle", materialTitle)
            putExtra("autoGenerateQuiz", true)
        }
        context.startActivity(intent)
    }
}
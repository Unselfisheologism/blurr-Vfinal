package com.blurr.voice.apps.learning

import android.content.Context
import android.content.Intent
import com.blurr.voice.LearningPlatformActivity

/**
 * Launcher utility for the AI-Native Learning Platform.
 */
object LearningPlatformLauncher {

    fun launch(context: Context) {
        val intent = Intent(context, LearningPlatformActivity::class.java)
        context.startActivity(intent)
    }
}

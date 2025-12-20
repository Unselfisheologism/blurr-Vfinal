package com.twent.voice.apps.learning

import android.content.Context
import android.content.Intent
import com.twent.voice.LearningPlatformActivity

/**
 * Launcher utility for the AI-Native Learning Platform.
 */
object LearningPlatformLauncher {

    fun launch(context: Context) {
        val intent = Intent(context, LearningPlatformActivity::class.java)
        context.startActivity(intent)
    }
}

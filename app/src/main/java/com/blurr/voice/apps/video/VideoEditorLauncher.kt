package com.twent.voice.apps.video

import android.content.Context
import android.content.Intent
import com.twent.voice.VideoEditorActivity

/**
 * Launcher utility for the AI-Native Video Editor.
 */
object VideoEditorLauncher {

    fun launch(context: Context) {
        val intent = Intent(context, VideoEditorActivity::class.java)
        context.startActivity(intent)
    }
}

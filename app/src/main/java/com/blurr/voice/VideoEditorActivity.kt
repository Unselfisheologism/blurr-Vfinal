package com.twent.voice

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import android.widget.TextView

class VideoEditorActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val view = TextView(this)
        view.text = "Video Editor (Coming Soon)"
        setContentView(view)
    }
}

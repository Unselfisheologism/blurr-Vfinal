package com.twent.voice

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import android.widget.TextView

class MediaCanvasActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val view = TextView(this)
        view.text = "Media Canvas (Coming Soon)"
        setContentView(view)
    }
}

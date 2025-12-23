package com.twent.voice

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import android.widget.TextView

class WorkflowEditorActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val view = TextView(this)
        view.text = "Workflow Editor (Coming Soon - Flutter Module Disabled)"
        setContentView(view)
    }
}

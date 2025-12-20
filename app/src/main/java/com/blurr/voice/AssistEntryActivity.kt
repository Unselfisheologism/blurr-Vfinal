package com.twent.voice

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.core.content.ContextCompat

class AssistEntryActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleAssistLaunch(intent)
        // No UI — finish immediately
        finish()
    }

    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        handleAssistLaunch(intent)
        finish()
    }

    private fun handleAssistLaunch(intent: Intent?) {
        Log.d("AssistEntryActivity", "Assistant invoked via ACTION_ASSIST (home button long press)")

        // Launch Ultra-Generalist Agent Chat UI
        val chatIntent = Intent(this, com.twent.voice.ui.agent.AgentChatActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("source", "home_button_long_press")
        }
        startActivity(chatIntent)
        
        Log.d("AssistEntryActivity", "Launched AgentChatActivity")
    }
}

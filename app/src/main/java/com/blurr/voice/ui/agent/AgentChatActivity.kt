package com.blurr.voice.ui.agent

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import android.util.Log

/**
 * Agent Chat Activity - 1-Chat-UI Interface
 * 
 * Launched via home button long press (ACTION_ASSIST)
 * Provides unified interface to Ultra-Generalist Agent
 */
class AgentChatActivity : ComponentActivity() {
    
    private val viewModel: AgentChatViewModel by viewModels()
    
    companion object {
        private const val TAG = "AgentChatActivity"
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val source = intent.getStringExtra("source") ?: "unknown"
        Log.d(TAG, "AgentChatActivity started from: $source")
        
        setContent {
            MaterialTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    AgentChatScreen(
                        viewModel = viewModel,
                        onBack = { finish() }
                    )
                }
            }
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "AgentChatActivity destroyed")
    }
}

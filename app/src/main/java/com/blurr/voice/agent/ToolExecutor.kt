package com.blurr.voice.agent

import android.content.Context
import com.blurr.voice.agents.AgentFactory

/**
 * Lightweight wrapper used by Flutter bridges.
 *
 * The Flutter layer expects a simple "executeTask" entrypoint which returns a string.
 */
class ToolExecutor(private val context: Context) {

    suspend fun executeTask(prompt: String): String {
        return AgentFactory.getAgent(context).processMessage(prompt).text
    }
}

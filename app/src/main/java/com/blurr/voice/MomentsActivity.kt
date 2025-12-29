package com.blurr.voice

import android.os.Bundle
import android.view.View
import android.widget.LinearLayout
import android.widget.TextView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.blurr.voice.data.AppwriteDb
import com.blurr.voice.data.TaskHistoryItem
import com.blurr.voice.utilities.Logger
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.time.Instant
import java.util.Date

class MomentsActivity : BaseNavigationActivity() {
    
    private lateinit var recyclerView: RecyclerView
    private lateinit var emptyState: LinearLayout
    private lateinit var adapter: MomentsAdapter
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_moments_content)
        
        // Setup back button
        findViewById<TextView>(R.id.back_button).setOnClickListener {
            finish()
        }
        
        // Initialize views
        recyclerView = findViewById(R.id.task_history_recycler_view)
        emptyState = findViewById(R.id.empty_state)
        
        // Setup RecyclerView
        recyclerView.layoutManager = LinearLayoutManager(this)
        adapter = MomentsAdapter(emptyList())
        recyclerView.adapter = adapter
        
        // Load task history
        loadTaskHistory()
    }
    
    private fun loadTaskHistory() {
        CoroutineScope(Dispatchers.Main).launch {
            try {
                val uid = AppwriteDb.getCurrentUserIdOrNull()
                if (uid == null) {
                    showEmptyState()
                    return@launch
                }
                val doc = AppwriteDb.getUserDocumentOrNull(uid)
                if (doc == null) {
                    showEmptyState()
                    return@launch
                }
                val taskHistoryData = doc.data["taskHistory"] as? List<Map<String, Any>>
                if (taskHistoryData.isNullOrEmpty()) {
                    showEmptyState()
                    return@launch
                }
                val history = taskHistoryData.mapNotNull { map ->
                    try {
                        val startedAtStr = map["startedAt"] as? String
                        val completedAtStr = map["completedAt"] as? String
                        val startedAt = startedAtStr?.let { runCatching { Date.from(Instant.parse(it)) }.getOrNull() }
                        val completedAt = completedAtStr?.let { runCatching { Date.from(Instant.parse(it)) }.getOrNull() }
                        TaskHistoryItem(
                            task = map["task"] as? String ?: "",
                            status = map["status"] as? String ?: "",
                            startedAt = startedAt,
                            completedAt = completedAt,
                            success = (map["success"] as? Boolean),
                            errorMessage = map["errorMessage"] as? String
                        )
                    } catch (e: Exception) {
                        Logger.e("MomentsActivity", "Error parsing task history item", e)
                        null
                    }
                }.sortedByDescending { it.startedAt ?: Date(0) }

                if (history.isNotEmpty()) {
                    showTaskHistory(history)
                } else {
                    showEmptyState()
                }
            } catch (e: Exception) {
                Logger.e("MomentsActivity", "Error loading task history", e)
                showEmptyState()
            }
        }
    }
    
    private fun showTaskHistory(taskHistory: List<TaskHistoryItem>) {
        adapter = MomentsAdapter(taskHistory)
        recyclerView.adapter = adapter
        recyclerView.visibility = View.VISIBLE
        emptyState.visibility = View.GONE
    }
    
    private fun showEmptyState() {
        recyclerView.visibility = View.GONE
        emptyState.visibility = View.VISIBLE
    }
    
    override fun getContentLayoutId(): Int = R.layout.activity_moments_content
    
    override fun getCurrentNavItem(): BaseNavigationActivity.NavItem = BaseNavigationActivity.NavItem.MOMENTS
}

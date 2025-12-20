package com.twent.voice.agents

import android.content.Context
import android.graphics.Bitmap
import android.util.Log
import com.twent.voice.data.TwentDatabase
import com.twent.voice.data.models.Conversation
import com.twent.voice.data.models.Message
import com.twent.voice.data.models.MessageRole
import com.twent.voice.tools.ToolResult
import com.google.ai.client.generativeai.type.TextPart
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import java.io.File
import java.io.FileOutputStream
import java.util.*

/**
 * Manages conversation context for the Ultra-Generalist Agent
 * 
 * Handles multi-turn conversation history, message persistence,
 * and context preparation for LLM calls.
 */
class ConversationManager(
    private val context: Context
) {
    private val database = TwentDatabase.getDatabase(context)
    private val conversationDao = database.conversationDao()
    
    private var currentConversationId: String? = null
    private val messageCache = mutableListOf<Message>()
    
    companion object {
        private const val TAG = "ConversationManager"
        private const val MAX_CONTEXT_MESSAGES = 50  // Limit conversation history
        private const val IMAGE_DIR = "conversation_images"
    }
    
    /**
     * Create new conversation
     */
    suspend fun createConversation(title: String = "New Conversation"): String {
        val conversation = Conversation.create(title)
        conversationDao.insertConversation(conversation)
        
        currentConversationId = conversation.id
        messageCache.clear()
        
        Log.d(TAG, "Created conversation: ${conversation.id}")
        return conversation.id
    }
    
    /**
     * Load existing conversation
     */
    suspend fun loadConversation(conversationId: String): Boolean {
        val conversation = conversationDao.getConversation(conversationId)
        if (conversation == null) {
            Log.w(TAG, "Conversation not found: $conversationId")
            return false
        }
        
        currentConversationId = conversationId
        messageCache.clear()
        messageCache.addAll(conversationDao.getMessages(conversationId))
        
        Log.d(TAG, "Loaded conversation: $conversationId with ${messageCache.size} messages")
        return true
    }
    
    /**
     * Get current conversation ID
     */
    fun getCurrentConversationId(): String? = currentConversationId
    
    /**
     * Ensure we have an active conversation
     */
    private suspend fun ensureConversation(): String {
        if (currentConversationId == null) {
            return createConversation()
        }
        return currentConversationId!!
    }
    
    /**
     * Add user message to conversation
     */
    suspend fun addUserMessage(
        content: String,
        images: List<Bitmap> = emptyList()
    ): Message {
        val conversationId = ensureConversation()
        
        // Save images to local storage and get URIs
        val imageUris = images.map { saveImage(it) }
        
        val message = Message.user(
            conversationId = conversationId,
            content = content,
            images = imageUris
        )
        
        conversationDao.addMessageAndUpdate(message)
        messageCache.add(message)
        
        // Auto-generate title from first user message
        if (messageCache.size == 1) {
            val title = generateTitle(content)
            conversationDao.updateTitle(conversationId, title)
        }
        
        Log.d(TAG, "Added user message to $conversationId")
        return message
    }
    
    /**
     * Add assistant response to conversation
     */
    suspend fun addAssistantMessage(
        content: String,
        tokenCount: Int = 0
    ): Message {
        val conversationId = ensureConversation()
        
        val message = Message.assistant(
            conversationId = conversationId,
            content = content,
            tokenCount = tokenCount
        )
        
        conversationDao.addMessageAndUpdate(message)
        messageCache.add(message)
        
        Log.d(TAG, "Added assistant message to $conversationId")
        return message
    }
    
    /**
     * Add tool result to conversation
     */
    suspend fun addToolResult(
        toolName: String,
        result: ToolResult
    ): Message {
        val conversationId = ensureConversation()
        
        val message = Message.tool(
            conversationId = conversationId,
            toolName = toolName,
            result = result.getDataAsString(),
            success = result.success
        )
        
        conversationDao.addMessageAndUpdate(message)
        messageCache.add(message)
        
        Log.d(TAG, "Added tool result to $conversationId: $toolName")
        return message
    }
    
    /**
     * Add system message to conversation
     */
    suspend fun addSystemMessage(content: String): Message {
        val conversationId = ensureConversation()
        
        val message = Message.system(
            conversationId = conversationId,
            content = content
        )
        
        conversationDao.addMessageAndUpdate(message)
        messageCache.add(message)
        
        Log.d(TAG, "Added system message to $conversationId")
        return message
    }
    
    /**
     * Get conversation context for LLM
     * Returns list of (role, content) pairs
     */
    fun getContext(): List<Pair<String, List<Any>>> {
        // Limit context to prevent token overflow
        val recentMessages = if (messageCache.size > MAX_CONTEXT_MESSAGES) {
            messageCache.takeLast(MAX_CONTEXT_MESSAGES)
        } else {
            messageCache
        }
        
        return recentMessages.map { message ->
            val role = when (message.role) {
                MessageRole.USER -> "user"
                MessageRole.ASSISTANT -> "assistant"
                MessageRole.TOOL -> "assistant"  // Tool results as assistant messages
                MessageRole.SYSTEM -> "system"
            }
            
            // Build content list (text + images)
            val contentList = mutableListOf<Any>()
            
            // Add text content
            if (message.content.isNotEmpty()) {
                contentList.add(TextPart(message.content))
            }
            
            // Add images if present
            if (message.hasImages()) {
                // Images would be loaded here for vision models
                // For now, just note their presence in text
                contentList.add(TextPart("[${message.getImageUris().size} image(s) attached]"))
            }
            
            role to contentList
        }
    }
    
    /**
     * Get simple text context (for non-vision models)
     */
    fun getTextContext(): List<Pair<String, String>> {
        val recentMessages = if (messageCache.size > MAX_CONTEXT_MESSAGES) {
            messageCache.takeLast(MAX_CONTEXT_MESSAGES)
        } else {
            messageCache
        }
        
        return recentMessages.map { message ->
            val role = when (message.role) {
                MessageRole.USER -> "user"
                MessageRole.ASSISTANT -> "assistant"
                MessageRole.TOOL -> "assistant"
                MessageRole.SYSTEM -> "system"
            }
            
            var content = message.content
            if (message.hasImages()) {
                content += "\n[${message.getImageUris().size} image(s) attached]"
            }
            
            role to content
        }
    }
    
    /**
     * Get all messages in current conversation
     */
    fun getAllMessages(): List<Message> {
        return messageCache.toList()
    }
    
    /**
     * Get message count
     */
    fun getMessageCount(): Int {
        return messageCache.size
    }
    
    /**
     * Clear current conversation from memory (keeps in database)
     */
    fun clearCache() {
        messageCache.clear()
        currentConversationId = null
        Log.d(TAG, "Cleared conversation cache")
    }
    
    /**
     * Delete conversation and all messages
     */
    suspend fun deleteConversation(conversationId: String) {
        val conversation = conversationDao.getConversation(conversationId)
        if (conversation != null) {
            conversationDao.deleteConversation(conversation)
            
            if (currentConversationId == conversationId) {
                clearCache()
            }
            
            Log.d(TAG, "Deleted conversation: $conversationId")
        }
    }
    
    /**
     * Get all conversations
     */
    fun getAllConversations(): Flow<List<Conversation>> {
        return conversationDao.getAllConversations()
    }
    
    /**
     * Get recent conversations
     */
    fun getRecentConversations(limit: Int = 20): Flow<List<Conversation>> {
        return conversationDao.getRecentConversations(limit)
    }
    
    /**
     * Search conversations
     */
    fun searchConversations(query: String): Flow<List<Conversation>> {
        return conversationDao.searchConversations(query)
    }
    
    /**
     * Update conversation title
     */
    suspend fun updateTitle(conversationId: String, title: String) {
        conversationDao.updateTitle(conversationId, title)
        Log.d(TAG, "Updated title for $conversationId: $title")
    }
    
    /**
     * Pin/unpin conversation
     */
    suspend fun setPinned(conversationId: String, pinned: Boolean) {
        conversationDao.setPinned(conversationId, pinned)
        Log.d(TAG, "${if (pinned) "Pinned" else "Unpinned"} conversation: $conversationId")
    }
    
    /**
     * Archive/unarchive conversation
     */
    suspend fun setArchived(conversationId: String, archived: Boolean) {
        conversationDao.setArchived(conversationId, archived)
        Log.d(TAG, "${if (archived) "Archived" else "Unarchived"} conversation: $conversationId")
    }
    
    /**
     * Get total token count for conversation
     */
    suspend fun getTotalTokenCount(conversationId: String): Int {
        return conversationDao.getTotalTokenCount(conversationId)
    }
    
    /**
     * Export conversation as text
     */
    suspend fun exportConversation(conversationId: String): String {
        val messages = conversationDao.getMessages(conversationId)
        val conversation = conversationDao.getConversation(conversationId)
        
        return buildString {
            appendLine("Conversation: ${conversation?.title ?: "Untitled"}")
            appendLine("Created: ${Date(conversation?.createdAt ?: 0)}")
            appendLine("Messages: ${messages.size}")
            appendLine()
            appendLine("=" .repeat(50))
            appendLine()
            
            messages.forEach { message ->
                appendLine("[${message.role}] ${Date(message.timestamp)}")
                appendLine(message.content)
                if (message.hasImages()) {
                    appendLine("  (${message.getImageUris().size} image(s))")
                }
                appendLine()
            }
        }
    }
    
    /**
     * Save image to local storage
     */
    private fun saveImage(bitmap: Bitmap): String {
        val imageDir = File(context.filesDir, IMAGE_DIR)
        if (!imageDir.exists()) {
            imageDir.mkdirs()
        }
        
        val filename = "img_${System.currentTimeMillis()}_${UUID.randomUUID()}.jpg"
        val file = File(imageDir, filename)
        
        FileOutputStream(file).use { out ->
            bitmap.compress(Bitmap.CompressFormat.JPEG, 90, out)
        }
        
        return file.absolutePath
    }
    
    /**
     * Generate conversation title from first message
     */
    private fun generateTitle(firstMessage: String): String {
        // Take first 50 characters or first sentence
        val cleaned = firstMessage.trim().replace("\n", " ")
        return if (cleaned.length > 50) {
            cleaned.take(47) + "..."
        } else {
            cleaned
        }
    }
}

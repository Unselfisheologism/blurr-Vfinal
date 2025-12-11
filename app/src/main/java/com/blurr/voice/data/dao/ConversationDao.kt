package com.blurr.voice.data.dao

import androidx.room.*
import com.blurr.voice.data.models.Conversation
import com.blurr.voice.data.models.ConversationWithMessages
import com.blurr.voice.data.models.Message
import kotlinx.coroutines.flow.Flow

/**
 * Data Access Object for Conversations
 */
@Dao
interface ConversationDao {
    
    // ============ Conversation Queries ============
    
    /**
     * Get all conversations ordered by update time (most recent first)
     */
    @Query("SELECT * FROM conversations ORDER BY isPinned DESC, updatedAt DESC")
    fun getAllConversations(): Flow<List<Conversation>>
    
    /**
     * Get conversation by ID
     */
    @Query("SELECT * FROM conversations WHERE id = :conversationId")
    suspend fun getConversation(conversationId: String): Conversation?
    
    /**
     * Get conversation with messages
     */
    @Transaction
    @Query("SELECT * FROM conversations WHERE id = :conversationId")
    suspend fun getConversationWithMessages(conversationId: String): ConversationWithMessages?
    
    /**
     * Get recent conversations (limit)
     */
    @Query("SELECT * FROM conversations WHERE isArchived = 0 ORDER BY updatedAt DESC LIMIT :limit")
    fun getRecentConversations(limit: Int = 20): Flow<List<Conversation>>
    
    /**
     * Get pinned conversations
     */
    @Query("SELECT * FROM conversations WHERE isPinned = 1 ORDER BY updatedAt DESC")
    fun getPinnedConversations(): Flow<List<Conversation>>
    
    /**
     * Get archived conversations
     */
    @Query("SELECT * FROM conversations WHERE isArchived = 1 ORDER BY updatedAt DESC")
    fun getArchivedConversations(): Flow<List<Conversation>>
    
    /**
     * Search conversations by title
     */
    @Query("SELECT * FROM conversations WHERE title LIKE '%' || :query || '%' ORDER BY updatedAt DESC")
    fun searchConversations(query: String): Flow<List<Conversation>>
    
    /**
     * Get conversations by tag
     */
    @Query("SELECT * FROM conversations WHERE tags LIKE '%' || :tag || '%' ORDER BY updatedAt DESC")
    fun getConversationsByTag(tag: String): Flow<List<Conversation>>
    
    /**
     * Insert conversation
     */
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertConversation(conversation: Conversation)
    
    /**
     * Update conversation
     */
    @Update
    suspend fun updateConversation(conversation: Conversation)
    
    /**
     * Delete conversation (cascade deletes messages)
     */
    @Delete
    suspend fun deleteConversation(conversation: Conversation)
    
    /**
     * Delete all conversations
     */
    @Query("DELETE FROM conversations")
    suspend fun deleteAllConversations()
    
    /**
     * Update conversation title
     */
    @Query("UPDATE conversations SET title = :title, updatedAt = :timestamp WHERE id = :conversationId")
    suspend fun updateTitle(conversationId: String, title: String, timestamp: Long = System.currentTimeMillis())
    
    /**
     * Update message count
     */
    @Query("UPDATE conversations SET messageCount = :count, updatedAt = :timestamp WHERE id = :conversationId")
    suspend fun updateMessageCount(conversationId: String, count: Int, timestamp: Long = System.currentTimeMillis())
    
    /**
     * Pin/unpin conversation
     */
    @Query("UPDATE conversations SET isPinned = :pinned, updatedAt = :timestamp WHERE id = :conversationId")
    suspend fun setPinned(conversationId: String, pinned: Boolean, timestamp: Long = System.currentTimeMillis())
    
    /**
     * Archive/unarchive conversation
     */
    @Query("UPDATE conversations SET isArchived = :archived, updatedAt = :timestamp WHERE id = :conversationId")
    suspend fun setArchived(conversationId: String, archived: Boolean, timestamp: Long = System.currentTimeMillis())
    
    // ============ Message Queries ============
    
    /**
     * Get all messages for conversation
     */
    @Query("SELECT * FROM messages WHERE conversationId = :conversationId ORDER BY timestamp ASC")
    suspend fun getMessages(conversationId: String): List<Message>
    
    /**
     * Get messages as Flow (live updates)
     */
    @Query("SELECT * FROM messages WHERE conversationId = :conversationId ORDER BY timestamp ASC")
    fun getMessagesFlow(conversationId: String): Flow<List<Message>>
    
    /**
     * Get recent messages (limit)
     */
    @Query("SELECT * FROM messages WHERE conversationId = :conversationId ORDER BY timestamp DESC LIMIT :limit")
    suspend fun getRecentMessages(conversationId: String, limit: Int): List<Message>
    
    /**
     * Get message by ID
     */
    @Query("SELECT * FROM messages WHERE id = :messageId")
    suspend fun getMessage(messageId: String): Message?
    
    /**
     * Get last message in conversation
     */
    @Query("SELECT * FROM messages WHERE conversationId = :conversationId ORDER BY timestamp DESC LIMIT 1")
    suspend fun getLastMessage(conversationId: String): Message?
    
    /**
     * Insert message
     */
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertMessage(message: Message)
    
    /**
     * Insert multiple messages
     */
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertMessages(messages: List<Message>)
    
    /**
     * Update message
     */
    @Update
    suspend fun updateMessage(message: Message)
    
    /**
     * Delete message
     */
    @Delete
    suspend fun deleteMessage(message: Message)
    
    /**
     * Delete all messages for conversation
     */
    @Query("DELETE FROM messages WHERE conversationId = :conversationId")
    suspend fun deleteAllMessages(conversationId: String)
    
    /**
     * Get message count for conversation
     */
    @Query("SELECT COUNT(*) FROM messages WHERE conversationId = :conversationId")
    suspend fun getMessageCount(conversationId: String): Int
    
    /**
     * Get total token count for conversation
     */
    @Query("SELECT SUM(tokenCount) FROM messages WHERE conversationId = :conversationId")
    suspend fun getTotalTokenCount(conversationId: String): Int
    
    // ============ Combined Operations ============
    
    /**
     * Create conversation with initial message
     */
    @Transaction
    suspend fun createConversationWithMessage(conversation: Conversation, message: Message) {
        insertConversation(conversation)
        insertMessage(message)
        updateMessageCount(conversation.id, 1)
    }
    
    /**
     * Add message and update conversation
     */
    @Transaction
    suspend fun addMessageAndUpdate(message: Message) {
        insertMessage(message)
        val count = getMessageCount(message.conversationId)
        updateMessageCount(message.conversationId, count)
    }
}

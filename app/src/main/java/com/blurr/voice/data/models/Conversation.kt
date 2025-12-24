package com.twent.voice.data.models

import androidx.room.Embedded
import androidx.room.Entity
import androidx.room.PrimaryKey
import androidx.room.Relation
import androidx.room.TypeConverters


/**
 * Conversation entity for Room database
 * 
 * Represents a conversation session with the Ultra-Generalist Agent.
 * Contains metadata and references to messages.
 */
@Entity(tableName = "conversations")
data class Conversation(
    @PrimaryKey
    val id: String,
    
    /**
     * Display title for the conversation
     * Generated from first user message or set manually
     */
    val title: String,
    
    /**
     * Timestamp when conversation was created
     */
    val createdAt: Long = System.currentTimeMillis(),
    
    /**
     * Timestamp of last update
     */
    val updatedAt: Long = System.currentTimeMillis(),
    
    /**
     * Number of messages in conversation (cached)
     */
    val messageCount: Int = 0,
    
    /**
     * Whether conversation is archived
     */
    val isArchived: Boolean = false,
    
    /**
     * Whether conversation is pinned to top
     */
    val isPinned: Boolean = false,
    
    /**
     * Optional tags for organization
     */
    val tags: String? = null  // Comma-separated tags
) {
    companion object {
        /**
         * Create new conversation with generated ID
         */
        fun create(title: String = "New Conversation"): Conversation {
            return Conversation(
                id = generateId(),
                title = title,
                createdAt = System.currentTimeMillis(),
                updatedAt = System.currentTimeMillis()
            )
        }
        
        /**
         * Generate unique conversation ID
         */
        private fun generateId(): String {
            return "conv_${System.currentTimeMillis()}_${(0..999).random()}"
        }
    }
    
    /**
     * Get tags as list
     */
    fun getTagList(): List<String> {
        return tags?.split(",")?.map { it.trim() }?.filter { it.isNotEmpty() } ?: emptyList()
    }
    
    /**
     * Check if conversation has specific tag
     */
    fun hasTag(tag: String): Boolean {
        return getTagList().contains(tag)
    }
    
    /**
     * Add tag to conversation
     */
    fun addTag(tag: String): Conversation {
        val currentTags = getTagList().toMutableList()
        if (!currentTags.contains(tag)) {
            currentTags.add(tag)
        }
        return copy(tags = currentTags.joinToString(","))
    }
    
    /**
     * Remove tag from conversation
     */
    fun removeTag(tag: String): Conversation {
        val currentTags = getTagList().toMutableList()
        currentTags.remove(tag)
        return copy(tags = currentTags.joinToString(","))
    }
}

/**
 * Conversation with messages (for queries)
 */
data class ConversationWithMessages(
    @Embedded
    val conversation: Conversation,
    @Relation(
        parentColumn = "id",
        entityColumn = "conversationId",
        entity = Message::class
    )
    val messages: List<Message>
) {
    /**
     * Get user messages only
     */
    fun getUserMessages(): List<Message> {
        return messages.filter { it.role == MessageRole.USER }
    }
    
    /**
     * Get assistant messages only
     */
    fun getAssistantMessages(): List<Message> {
        return messages.filter { it.role == MessageRole.ASSISTANT }
    }
    
    /**
     * Get tool results only
     */
    fun getToolResults(): List<Message> {
        return messages.filter { it.role == MessageRole.TOOL }
    }
    
    /**
     * Get message count
     */
    fun getMessageCount(): Int {
        return messages.size
    }
    
    /**
     * Get last message
     */
    fun getLastMessage(): Message? {
        return messages.lastOrNull()
    }
    
    /**
     * Check if conversation is empty
     */
    fun isEmpty(): Boolean {
        return messages.isEmpty()
    }
}

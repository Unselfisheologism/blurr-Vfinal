package com.twent.voice.data.models

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.PrimaryKey
import androidx.room.TypeConverters
import com.twent.voice.data.converters.MessageContentConverter

/**
 * Message entity for Room database
 * 
 * Represents a single message in a conversation.
 * Can be user, assistant, tool, or system message.
 */
@Entity(
    tableName = "messages",
    foreignKeys = [
        ForeignKey(
            entity = Conversation::class,
            parentColumns = ["id"],
            childColumns = ["conversationId"],
            onDelete = ForeignKey.CASCADE
        )
    ],
    indices = [
        Index("conversationId"),
        Index("timestamp")
    ]
)
@TypeConverters(MessageContentConverter::class)
data class Message(
    @PrimaryKey
    val id: String,
    
    /**
     * ID of conversation this message belongs to
     */
    val conversationId: String,
    
    /**
     * Role of message sender
     */
    val role: MessageRole,
    
    /**
     * Text content of message
     */
    val content: String,
    
    /**
     * Additional content items (images, files, etc.)
     */
    val contentItems: List<MessageContentItem> = emptyList(),
    
    /**
     * Timestamp when message was created
     */
    val timestamp: Long = System.currentTimeMillis(),
    
    /**
     * Optional metadata (tool name, error info, etc.)
     */
    val metadata: String? = null,  // JSON string
    
    /**
     * Whether this message is an error
     */
    val isError: Boolean = false,
    
    /**
     * Token count for this message (for cost tracking)
     */
    val tokenCount: Int = 0
) {
    companion object {
        /**
         * Create user message
         */
        fun user(
            conversationId: String,
            content: String,
            images: List<String> = emptyList()
        ): Message {
            val contentItems = images.map { 
                MessageContentItem(type = ContentType.IMAGE, data = it) 
            }
            
            return Message(
                id = generateId(),
                conversationId = conversationId,
                role = MessageRole.USER,
                content = content,
                contentItems = contentItems
            )
        }
        
        /**
         * Create assistant message
         */
        fun assistant(
            conversationId: String,
            content: String,
            tokenCount: Int = 0
        ): Message {
            return Message(
                id = generateId(),
                conversationId = conversationId,
                role = MessageRole.ASSISTANT,
                content = content,
                tokenCount = tokenCount
            )
        }
        
        /**
         * Create tool result message
         */
        fun tool(
            conversationId: String,
            toolName: String,
            result: String,
            success: Boolean = true
        ): Message {
            return Message(
                id = generateId(),
                conversationId = conversationId,
                role = MessageRole.TOOL,
                content = result,
                metadata = """{"tool_name": "$toolName", "success": $success}""",
                isError = !success
            )
        }
        
        /**
         * Create system message
         */
        fun system(
            conversationId: String,
            content: String
        ): Message {
            return Message(
                id = generateId(),
                conversationId = conversationId,
                role = MessageRole.SYSTEM,
                content = content
            )
        }
        
        /**
         * Generate unique message ID
         */
        private fun generateId(): String {
            return "msg_${System.currentTimeMillis()}_${(0..9999).random()}"
        }
    }
    
    /**
     * Check if message has images
     */
    fun hasImages(): Boolean {
        return contentItems.any { it.type == ContentType.IMAGE }
    }
    
    /**
     * Get image URIs
     */
    fun getImageUris(): List<String> {
        return contentItems
            .filter { it.type == ContentType.IMAGE }
            .map { it.data }
    }
    
    /**
     * Check if message has files
     */
    fun hasFiles(): Boolean {
        return contentItems.any { it.type == ContentType.FILE }
    }
    
    /**
     * Get file URIs
     */
    fun getFileUris(): List<String> {
        return contentItems
            .filter { it.type == ContentType.FILE }
            .map { it.data }
    }
}

/**
 * Message role enum
 */
enum class MessageRole {
    USER,       // User input
    ASSISTANT,  // AI response
    TOOL,       // Tool execution result
    SYSTEM      // System message
}

/**
 * Message content item (image, file, etc.)
 */
data class MessageContentItem(
    val type: ContentType,
    val data: String,      // URI or base64 data
    val mimeType: String? = null,
    val filename: String? = null
)

/**
 * Content type enum
 */
enum class ContentType {
    TEXT,
    IMAGE,
    FILE,
    AUDIO,
    VIDEO
}

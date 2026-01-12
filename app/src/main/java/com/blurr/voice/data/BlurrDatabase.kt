package com.blurr.voice.data

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import com.blurr.voice.data.dao.ConversationDao
import com.blurr.voice.data.dao.MemoryDao
import com.blurr.voice.data.models.Conversation
import com.blurr.voice.data.models.Message
import com.blurr.voice.data.Memory

/**
 * Room Database for Blurr AI Assistant
 * 
 * Manages conversations, messages, memories, and other persistent data.
 * This is a unified database that replaces both AppDatabase and BlurrDatabase.
 */
@Database(
    entities = [
        Conversation::class,
        Message::class,
        Memory::class
    ],
    version = 3, // Incremented version for migration
    exportSchema = false
)
abstract class BlurrDatabase : RoomDatabase() {
    
    abstract fun conversationDao(): ConversationDao
    abstract fun memoryDao(): MemoryDao
    
    companion object {
        private const val DATABASE_NAME = "blurr_unified_database"
        
        @Volatile
        private var INSTANCE: BlurrDatabase? = null
        
        /**
         * Get database instance (singleton)
         */
        fun getDatabase(context: Context): BlurrDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    BlurrDatabase::class.java,
                    DATABASE_NAME
                )
                    .fallbackToDestructiveMigration()  // For development
                    .build()
                
                INSTANCE = instance
                instance
            }
        }
    }
}

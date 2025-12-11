package com.blurr.voice.data

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import com.blurr.voice.data.dao.ConversationDao
import com.blurr.voice.data.models.Conversation
import com.blurr.voice.data.models.Message

/**
 * Room Database for Blurr AI Assistant
 * 
 * Manages conversations, messages, and other persistent data.
 */
@Database(
    entities = [
        Conversation::class,
        Message::class
    ],
    version = 1,
    exportSchema = true
)
abstract class BlurrDatabase : RoomDatabase() {
    
    abstract fun conversationDao(): ConversationDao
    
    companion object {
        private const val DATABASE_NAME = "blurr_database"
        
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

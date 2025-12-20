package com.twent.voice.data

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import com.twent.voice.data.dao.ConversationDao
import com.twent.voice.data.models.Conversation
import com.twent.voice.data.models.Message

/**
 * Room Database for Twent AI Assistant
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
abstract class TwentDatabase : RoomDatabase() {
    
    abstract fun conversationDao(): ConversationDao
    
    companion object {
        private const val DATABASE_NAME = "twent_database"
        
        @Volatile
        private var INSTANCE: TwentDatabase? = null
        
        /**
         * Get database instance (singleton)
         */
        fun getDatabase(context: Context): TwentDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    TwentDatabase::class.java,
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

package com.blurr.voice.data.converters

import androidx.room.TypeConverter

/**
 * Room type converter for timestamps
 */
class TimestampConverter {
    
    @TypeConverter
    fun fromTimestamp(value: Long?): Long {
        return value ?: 0L
    }
    
    @TypeConverter
    fun toTimestamp(timestamp: Long?): Long {
        return timestamp ?: System.currentTimeMillis()
    }
}

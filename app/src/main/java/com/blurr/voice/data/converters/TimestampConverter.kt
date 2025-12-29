package com.blurr.voice.data.converters

import androidx.room.TypeConverter

/**
 * Room type converter for timestamps
 */
class TimestampConverter {
    
    @TypeConverter
    fun fromLong(value: Long?): Long? {
        return value
    }
    
    @TypeConverter
    fun toLong(value: Long?): Long? {
        return value
    }
}

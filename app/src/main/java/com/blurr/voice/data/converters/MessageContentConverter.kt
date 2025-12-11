package com.blurr.voice.data.converters

import androidx.room.TypeConverter
import com.blurr.voice.data.models.ContentType
import com.blurr.voice.data.models.MessageContentItem
import org.json.JSONArray
import org.json.JSONObject

/**
 * Room type converter for MessageContentItem list
 */
class MessageContentConverter {
    
    @TypeConverter
    fun fromContentItemList(items: List<MessageContentItem>?): String? {
        if (items.isNullOrEmpty()) return null
        
        val jsonArray = JSONArray()
        items.forEach { item ->
            val jsonObject = JSONObject().apply {
                put("type", item.type.name)
                put("data", item.data)
                item.mimeType?.let { put("mimeType", it) }
                item.filename?.let { put("filename", it) }
            }
            jsonArray.put(jsonObject)
        }
        
        return jsonArray.toString()
    }
    
    @TypeConverter
    fun toContentItemList(json: String?): List<MessageContentItem>? {
        if (json.isNullOrEmpty()) return emptyList()
        
        return try {
            val jsonArray = JSONArray(json)
            val items = mutableListOf<MessageContentItem>()
            
            for (i in 0 until jsonArray.length()) {
                val jsonObject = jsonArray.getJSONObject(i)
                val item = MessageContentItem(
                    type = ContentType.valueOf(jsonObject.getString("type")),
                    data = jsonObject.getString("data"),
                    mimeType = jsonObject.optString("mimeType", null),
                    filename = jsonObject.optString("filename", null)
                )
                items.add(item)
            }
            
            items
        } catch (e: Exception) {
            emptyList()
        }
    }
}

package com.blurr.voice.utilities

import android.graphics.Bitmap
import com.blurr.voice.core.providers.UniversalLLMService
import android.content.Context
import com.google.ai.client.generativeai.type.ImagePart
import com.google.ai.client.generativeai.type.TextPart

fun addResponse(
    role: String,
    prompt: String,
    chatHistory: List<Pair<String, List<Any>>>,
    imageBitmap: Bitmap? = null // MODIFIED: Accepts a Bitmap directly
): List<Pair<String, List<Any>>> {
    val updatedChat = chatHistory.toMutableList()

    val messageParts = mutableListOf<Any>()
    messageParts.add(TextPart(prompt))

    if (imageBitmap != null) {
        messageParts.add(ImagePart(imageBitmap))
    }

    updatedChat.add(Pair(role, messageParts))
    return updatedChat
}

fun addResponsePrePost(
    role: String,
    prompt: String,
    chatHistory: List<Pair<String, List<Any>>>,
    imageBefore: Bitmap? = null, // MODIFIED: Accepts a Bitmap
    imageAfter: Bitmap? = null  // MODIFIED: Accepts a Bitmap
): List<Pair<String, List<Any>>> {
    val updatedChat = chatHistory.toMutableList()
    val messageParts = mutableListOf<Any>()

    messageParts.add(TextPart(prompt))

    // Attach "before" image directly if available
    imageBefore?.let {
        messageParts.add(ImagePart(it))
    }

    // Attach "after" image directly if available
    imageAfter?.let {
        messageParts.add(ImagePart(it))
    }

    updatedChat.add(Pair(role, messageParts))
    return updatedChat
}

suspend fun getReasoningModelApiResponse(
    context: Context,
    chat: List<Pair<String, List<Any>>>,
): String? {
    val llmService = UniversalLLMService(context)
    if (!llmService.isConfigured()) {
        android.util.Log.e("LLMHelper", "LLM service not configured")
        return null
    }
    return llmService.generateContent(chat)
}


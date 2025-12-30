package com.google.ai.client.generativeai.type

/**
 * Minimal stub for the Google Generative AI SDK's Content.
 */
data class Content(
    val role: String,
    val parts: List<Any>
)

class ContentBuilder {
    private val parts = mutableListOf<Any>()

    fun text(value: String) {
        parts.add(TextPart(value))
    }

    internal fun build(role: String): Content = Content(role = role, parts = parts.toList())
}

/**
 * Minimal stub for the `content {}` DSL used by the official SDK.
 */
fun content(role: String, block: ContentBuilder.() -> Unit): Content {
    val builder = ContentBuilder()
    builder.block()
    return builder.build(role)
}

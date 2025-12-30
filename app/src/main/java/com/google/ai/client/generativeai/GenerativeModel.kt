package com.google.ai.client.generativeai

import com.google.ai.client.generativeai.type.Content
import com.google.ai.client.generativeai.type.GenerationConfig
import com.google.ai.client.generativeai.type.RequestOptions

/**
 * Minimal stub for the Google Generative AI SDK's GenerativeModel.
 *
 * The project uses a BYOK/OpenAI-compatible stack by default. This stub exists so the
 * codebase can compile without bundling the official Google AI SDK.
 */
class GenerativeModel(
    @Suppress("UNUSED_PARAMETER") val modelName: String,
    @Suppress("UNUSED_PARAMETER") val apiKey: String,
    @Suppress("UNUSED_PARAMETER") val generationConfig: GenerationConfig? = null,
    @Suppress("UNUSED_PARAMETER") val requestOptions: RequestOptions? = null
) {

    suspend fun generateContent(@Suppress("UNUSED_PARAMETER") vararg contents: Content): GenerateContentResponse {
        throw UnsupportedOperationException("Google Generative AI SDK is not available in this build.")
    }
}

class GenerateContentResponse(
    val text: String? = null,
    val promptFeedback: PromptFeedback? = null
)

class PromptFeedback(
    val blockReason: BlockReason? = null
)

enum class BlockReason {
    UNSPECIFIED
}

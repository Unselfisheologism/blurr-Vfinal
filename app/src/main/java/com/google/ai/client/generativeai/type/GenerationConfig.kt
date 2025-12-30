package com.google.ai.client.generativeai.type

/**
 * Minimal stub for the Google Generative AI SDK's GenerationConfig.
 */
class GenerationConfig private constructor(
    val responseMimeType: String?
) {
    class Builder {
        var responseMimeType: String? = null

        fun build(): GenerationConfig = GenerationConfig(responseMimeType)
    }

    companion object {
        @JvmStatic
        fun builder(): Builder = Builder()
    }
}

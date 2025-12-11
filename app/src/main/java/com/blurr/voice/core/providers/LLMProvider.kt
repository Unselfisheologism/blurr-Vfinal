package com.blurr.voice.core.providers

/**
 * Enum representing supported LLM providers for BYOK (Bring Your Own Key)
 */
enum class LLMProvider(
    val displayName: String,
    val baseUrl: String,
    val supportsStreaming: Boolean = true,
    val supportsVision: Boolean = true,
    val supportsSTT: Boolean = false,
    val supportsTTS: Boolean = false
) {
    OPENROUTER(
        displayName = "OpenRouter",
        baseUrl = "https://openrouter.ai/api/v1",
        supportsStreaming = true,
        supportsVision = true,
        supportsSTT = false,
        supportsTTS = false
    ),
    AIMLAPI(
        displayName = "AIMLAPI.com",
        baseUrl = "https://api.aimlapi.com/v1",
        supportsStreaming = true,
        supportsVision = true,
        supportsSTT = true,
        supportsTTS = true
    ),
    GROQ(
        displayName = "Groq",
        baseUrl = "https://api.groq.com/openai/v1",
        supportsStreaming = true,
        supportsVision = false,
        supportsSTT = true,
        supportsTTS = false
    ),
    FIREWORKS(
        displayName = "Fireworks AI",
        baseUrl = "https://api.fireworks.ai/inference/v1",
        supportsStreaming = true,
        supportsVision = true,
        supportsSTT = false,
        supportsTTS = false
    ),
    TOGETHER(
        displayName = "Together AI",
        baseUrl = "https://api.together.xyz/v1",
        supportsStreaming = true,
        supportsVision = true,
        supportsSTT = false,
        supportsTTS = false
    ),
    OPENAI(
        displayName = "OpenAI",
        baseUrl = "https://api.openai.com/v1",
        supportsStreaming = true,
        supportsVision = true,
        supportsSTT = true,
        supportsTTS = true
    );

    companion object {
        fun fromString(name: String): LLMProvider? {
            return values().find { it.name.equals(name, ignoreCase = true) }
        }
    }
}

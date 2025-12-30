package com.blurr.voice.api

/**
 * Text-to-Speech voice options
 * These map to voice names supported by TTS providers (OpenAI, AIMLAPI, etc.)
 */
enum class TTSVoice(val voiceName: String) {
    // OpenAI/AIMLAPI compatible voices
    ALLOY("alloy"),
    ECHO("echo"),
    FABLE("fable"),
    ONYX("onyx"),
    NOVA("nova"),
    SHIMMER("shimmer"),
    
    // Legacy Chirp voices (mapped to compatible alternatives)
    CHIRP_LAOMEDEIA("nova"),
    CHIRP_PUCK("alloy"),
    CHIRP_CHARON("onyx"),
    CHIRP_FENRIR("fable");
    
    companion object {
        /**
         * Get voice name from enum
         */
        fun fromName(name: String): TTSVoice {
            return entries.find { it.name == name } ?: ALLOY
        }
    }
}

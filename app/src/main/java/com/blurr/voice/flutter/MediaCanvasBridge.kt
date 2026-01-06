package com.blurr.voice.flutter;

/**
 * Stub MediaCanvas bridge for Android builds without Flutter SDK.
 * Provides minimal compatibility for MediaCanvas functionality.
 */
class MediaCanvasBridge {
    
    /**
     * Stub method for initializing MediaCanvas
     */
    fun initializeMediaCanvas() {
        // Stub implementation
    }
    
    /**
     * Stub method for media operations
     */
    fun performMediaOperation(operation: String, data: Any?): Any? {
        return null
    }
    
    /**
     * Stub method for getting media canvas status
     */
    fun isMediaCanvasReady(): Boolean {
        return false
    }
}
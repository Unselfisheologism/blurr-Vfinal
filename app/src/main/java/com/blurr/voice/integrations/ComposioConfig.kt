package com.blurr.voice.integrations

/**
 * Composio Configuration
 * 
 * Story 4.14: Composio Integration
 * 
 * Store Composio API key and configuration.
 * Sign up at: https://composio.dev
 * Plan: Scale Plan ($499/month for 5M calls)
 */
object ComposioConfig {
    
    /**
     * Composio API Key
     * 
     * Get from: https://app.composio.dev/settings/api-keys
     * 
     * TODO: Move to secure storage or build config for production
     */
    const val API_KEY = "YOUR_COMPOSIO_API_KEY_HERE"
    
    /**
     * Composio API Base URL
     */
    const val BASE_URL = "https://backend.composio.dev/api/v1/"
    
    /**
     * Enable debug logging
     */
    const val DEBUG = true
    
    /**
     * Connection timeout (seconds)
     */
    const val TIMEOUT_SECONDS = 30L
}

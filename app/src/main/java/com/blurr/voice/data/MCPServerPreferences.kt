package com.blurr.voice.data

import android.content.Context
import android.content.SharedPreferences
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken

/**
 * Preferences for storing MCP server configurations
 *
 * Persists server names, URLs, and transport types.
 * Allows auto-reconnection on app restart.
 */
class MCPServerPreferences(private val context: Context) {

    private val prefs: SharedPreferences =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    private val gson = Gson()

    companion object {
        private const val PREFS_NAME = "mcp_servers"
        private const val KEY_SERVERS = "configured_servers"
    }

    /**
     * Data class for MCP server configuration
     */
    data class MCPServerConfig(
        val name: String,
        val url: String,
        val transport: String, // "http", "sse", "stdio"
        val enabled: Boolean = true,
        val lastConnected: Long? = null
    )

    /**
     * Save a server configuration
     */
    fun saveServer(config: MCPServerConfig) {
        val servers = getServers().toMutableList()

        // Remove existing server with same name
        servers.removeAll { it.name == config.name }

        // Add new/updated server
        servers.add(config)

        prefs.edit().apply {
            putString(KEY_SERVERS, gson.toJson(servers))
            apply()
        }

        android.util.Log.d("MCPServerPreferences", "Saved server: ${config.name}")
    }

    /**
     * Remove a server configuration
     */
    fun removeServer(serverName: String) {
        val servers = getServers().toMutableList()

        servers.removeAll { it.name == serverName }

        prefs.edit().apply {
            putString(KEY_SERVERS, gson.toJson(servers))
            apply()
        }

        android.util.Log.d("MCPServerPreferences", "Removed server: $serverName")
    }

    /**
     * Get all saved server configurations
     */
    fun getServers(): List<MCPServerConfig> {
        val json = prefs.getString(KEY_SERVERS, "[]") ?: "[]"

        return try {
            val type = object : TypeToken<List<MCPServerConfig>>() {}.type
            gson.fromJson<List<MCPServerConfig>>(json, type) ?: emptyList()
        } catch (e: Exception) {
            android.util.Log.e("MCPServerPreferences", "Failed to parse servers", e)
            emptyList()
        }
    }

    /**
     * Get enabled server configurations
     */
    fun getEnabledServers(): List<MCPServerConfig> {
        return getServers().filter { it.enabled }
    }

    /**
     * Get server configuration by name
     */
    fun getServer(name: String): MCPServerConfig? {
        return getServers().firstOrNull { it.name == name }
    }

    /**
     * Update server enabled status
     */
    fun setServerEnabled(name: String, enabled: Boolean) {
        val server = getServer(name) ?: return
        saveServer(server.copy(enabled = enabled))
    }

    /**
     * Update last connected timestamp
     */
    fun updateLastConnected(name: String, timestamp: Long = System.currentTimeMillis()) {
        val server = getServer(name) ?: return
        saveServer(server.copy(lastConnected = timestamp))
    }

    /**
     * Clear all server configurations
     */
    fun clearAll() {
        prefs.edit().apply {
            remove(KEY_SERVERS)
            apply()
        }

        android.util.Log.d("MCPServerPreferences", "Cleared all server configurations")
    }

    /**
     * Count configured servers
     */
    fun count(): Int {
        return getServers().size
    }

    /**
     * Check if any servers are configured
     */
    fun hasConfiguredServers(): Boolean {
        return count() > 0
    }
}

// Extension data class for server connection info (matching Flutter's MCPServerConnection)
data class MCPServerConnection(
    val name: String,
    val url: String,
    val transport: String,
    val connected: Boolean = false,
    val tools: List<Map<String, Any>> = emptyList(),
    val serverInfo: Map<String, Any>? = null
)

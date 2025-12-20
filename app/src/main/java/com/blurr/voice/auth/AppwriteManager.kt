package com.twent.voice.auth

import android.content.Context
import com.twent.voice.BuildConfig
import io.appwrite.Client
import io.appwrite.services.Account
import io.appwrite.services.Databases

object AppwriteManager {
    private var _client: Client? = null
    val client: Client
        get() = _client ?: throw IllegalStateException("AppwriteManager not initialized")

    private var _account: Account? = null
    val account: Account
        get() = _account ?: throw IllegalStateException("AppwriteManager not initialized")

    private var _databases: Databases? = null
    val databases: Databases
        get() = _databases ?: throw IllegalStateException("AppwriteManager not initialized")

    fun init(context: Context) {
        if (_client != null) return

        _client = Client(context)
            .setEndpoint("https://cloud.appwrite.io/v1")
            .setProject(BuildConfig.APPWRITE_PROJECT_ID)
            .setSelfSigned(BuildConfig.DEBUG) // Allow self-signed certs in debug
        _account = Account(_client!!)
        _databases = Databases(_client!!)
    }
}

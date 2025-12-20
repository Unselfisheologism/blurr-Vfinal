package com.twent.voice.data

import com.twent.voice.BuildConfig
import com.twent.voice.auth.AppwriteManager
import io.appwrite.ID
import io.appwrite.exceptions.AppwriteException
import io.appwrite.models.Document
import io.appwrite.services.Databases

object AppwriteDb {
    private val databases: Databases get() = AppwriteManager.databases

    suspend fun getCurrentUserIdOrNull(): String? = try {
        AppwriteManager.account.get().id
    } catch (e: Exception) {
        null
    }

    suspend fun getUserDocumentOrNull(userId: String): Document<Map<String, Any>>? = try {
        databases.getDocument(
            databaseId = BuildConfig.APPWRITE_DATABASE_ID,
            collectionId = BuildConfig.APPWRITE_USERS_COLLECTION_ID,
            documentId = userId
        )
    } catch (e: AppwriteException) {
        if (e.code == 404) null else throw e
    }

    suspend fun createUserDocument(userId: String, data: Map<String, Any>): Document<Map<String, Any>> =
        databases.createDocument(
            databaseId = BuildConfig.APPWRITE_DATABASE_ID,
            collectionId = BuildConfig.APPWRITE_USERS_COLLECTION_ID,
            documentId = ID.custom(userId),
            data = data
        )

    suspend fun updateUserDocument(userId: String, data: Map<String, Any>): Document<Map<String, Any>> =
        databases.updateDocument(
            databaseId = BuildConfig.APPWRITE_DATABASE_ID,
            collectionId = BuildConfig.APPWRITE_USERS_COLLECTION_ID,
            documentId = userId,
            data = data
        )

    suspend fun appendToUserArrayField(userId: String, field: String, entry: Map<String, Any>) {
        val doc = getUserDocumentOrNull(userId)
        val current = (doc?.data?.get(field) as? List<Map<String, Any>>)?.toMutableList() ?: mutableListOf()
        current.add(entry)
        updateUserDocument(userId, mapOf(field to current))
    }
}

package com.blurr.voice.auth

import com.blurr.voice.core.result.AIError
import com.blurr.voice.core.result.Result
import io.appwrite.exceptions.AppwriteException
import io.appwrite.ID
import io.appwrite.models.Session
import io.appwrite.models.User
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

import io.appwrite.services.Account

class AppwriteAuthRepository(
    private val accountService: Account = AppwriteManager.account
) : AuthRepository {

    @Suppress("UNCHECKED_CAST")
    override suspend fun signUp(email: String, password: String): Result<User<Map<String, Any>>> = withContext(Dispatchers.IO) {
        try {
            val user = accountService.create(
                userId = ID.unique(),
                email = email,
                password = password
            )
            // Assuming default prefs are Map<String, Any>
            Result.Success(user as User<Map<String, Any>>)
        } catch (e: AppwriteException) {
            Result.Error(mapException(e))
        } catch (e: Exception) {
            Result.Error(AIError(AIError.UNKNOWN, e.message ?: "Unknown error"))
        }
    }

    override suspend fun login(email: String, password: String): Result<Session> = withContext(Dispatchers.IO) {
        try {
            val session = accountService.createEmailPasswordSession(email, password)
            Result.Success(session)
        } catch (e: AppwriteException) {
            Result.Error(mapException(e))
        } catch (e: Exception) {
            Result.Error(AIError(AIError.UNKNOWN, e.message ?: "Unknown error"))
        }
    }

    override suspend fun logout(): Result<Unit> = withContext(Dispatchers.IO) {
        try {
            accountService.deleteSession("current")
            Result.Success(Unit)
        } catch (e: AppwriteException) {
            Result.Error(mapException(e))
        } catch (e: Exception) {
            Result.Error(AIError(AIError.UNKNOWN, e.message ?: "Unknown error"))
        }
    }

    @Suppress("UNCHECKED_CAST")
    override suspend fun getCurrentUser(): Result<User<Map<String, Any>>> = withContext(Dispatchers.IO) {
        try {
            val user = accountService.get()
            Result.Success(user as User<Map<String, Any>>)
        } catch (e: AppwriteException) {
            Result.Error(mapException(e))
        } catch (e: Exception) {
            Result.Error(AIError(AIError.UNKNOWN, e.message ?: "Unknown error"))
        }
    }

    override suspend fun checkSession(): Result<Boolean> = withContext(Dispatchers.IO) {
        try {
            accountService.getSession("current")
            Result.Success(true)
        } catch (e: AppwriteException) {
            // 401 usually means unauthenticated (fetched session failure)
            if (e.code == 401) {
                Result.Success(false)
            } else {
                Result.Error(mapException(e))
            }
        } catch (e: Exception) {
            Result.Error(AIError(AIError.UNKNOWN, e.message ?: "Unknown error"))
        }
    }

    private fun mapException(e: AppwriteException): AIError {
        return when (e.code) {
            401 -> AIError(AIError.AUTH_FAILED, "Invalid credentials or session expired")
            409 -> AIError(AIError.AUTH_USER_EXISTS, "User with this email already exists")
            429 -> AIError(AIError.UNKNOWN, "Rate limit exceeded. Please try again later.", "Appwrite")
            else -> AIError(AIError.UNKNOWN, e.message ?: "Appwrite error", "Appwrite")
        }
    }
}

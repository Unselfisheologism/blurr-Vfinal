package com.twent.voice.auth

import com.twent.voice.core.result.Result
import io.appwrite.models.User
import io.appwrite.models.Session

interface AuthRepository {
    suspend fun signUp(email: String, password: String): Result<User<Map<String, Any>>>
    suspend fun login(email: String, password: String): Result<Session>
    suspend fun logout(): Result<Unit>
    suspend fun getCurrentUser(): Result<User<Map<String, Any>>>
    suspend fun checkSession(): Result<Boolean>
    
    // OAuth methods
    suspend fun loginWithGoogle(redirectUrl: String): Result<String>
    suspend fun loginWithFacebook(redirectUrl: String): Result<String>
    suspend fun loginWithGithub(redirectUrl: String): Result<String>
    suspend fun loginWithApple(redirectUrl: String): Result<String>
}

package com.twent.voice.auth

import android.accounts.Account
import android.content.Context
import android.content.Intent
import android.util.Log
import com.google.android.gms.auth.GoogleAuthUtil
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInAccount
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.common.api.Scope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/**
 * Google OAuth Authentication Manager
 * 
 * Story 4.13: Google OAuth Integration (FREE - uses user quotas)
 * 
 * Handles Google Sign-In for Workspace APIs (Gmail, Calendar, Drive).
 * Uses user's credentials (not project credentials) for FREE API access.
 * 
 * Cost: $0 regardless of user count ✅
 * Each user gets their own quota (250 units/sec, 1M queries/day)
 */
class GoogleAuthManager(private val context: Context) {
    
    companion object {
        private const val TAG = "GoogleAuthManager"
        const val RC_SIGN_IN = 9001
        
        // OAuth scopes for Google Workspace
        private val SCOPES = listOf(
            "https://www.googleapis.com/auth/gmail.readonly",
            "https://www.googleapis.com/auth/gmail.compose",
            "https://www.googleapis.com/auth/gmail.send",
            "https://www.googleapis.com/auth/calendar",
            "https://www.googleapis.com/auth/calendar.events",
            "https://www.googleapis.com/auth/drive.file",
            "https://www.googleapis.com/auth/drive.readonly"
        )
    }
    
    private val sharedPrefs = context.getSharedPreferences("google_auth", Context.MODE_PRIVATE)
    
    /**
     * Build Google Sign-In options with required scopes
     */
    private fun buildSignInOptions(): GoogleSignInOptions {
        return GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestEmail()
            .requestScopes(
                Scope(SCOPES[0]),
                *SCOPES.drop(1).map { Scope(it) }.toTypedArray()
            )
            .build()
    }
    
    /**
     * Get Google Sign-In client
     */
    fun getSignInClient(): GoogleSignInClient {
        return GoogleSignIn.getClient(context, buildSignInOptions())
    }
    
    /**
     * Get sign-in intent for activity
     */
    fun getSignInIntent(): Intent {
        return getSignInClient().signInIntent
    }
    
    /**
     * Check if user is signed in
     */
    fun isSignedIn(): Boolean {
        return GoogleSignIn.getLastSignedInAccount(context) != null
    }
    
    /**
     * Get currently signed-in account
     */
    fun getSignedInAccount(): GoogleSignInAccount? {
        return GoogleSignIn.getLastSignedInAccount(context)
    }
    
    /**
     * Get user's email
     */
    fun getUserEmail(): String? {
        return getSignedInAccount()?.email
    }
    
    /**
     * Get user's display name
     */
    fun getUserName(): String? {
        return getSignedInAccount()?.displayName
    }
    
    /**
     * Handle sign-in result from activity
     */
    suspend fun handleSignInResult(data: Intent?): Result<GoogleSignInAccount> = withContext(Dispatchers.IO) {
        try {
            val task = GoogleSignIn.getSignedInAccountFromIntent(data)
            val account = task.getResult(ApiException::class.java)
            
            if (account != null) {
                Log.d(TAG, "Sign-in successful: ${account.email}")
                
                // Save sign-in state
                sharedPrefs.edit()
                    .putBoolean("is_signed_in", true)
                    .putString("user_email", account.email)
                    .putString("user_name", account.displayName)
                    .apply()
                
                Result.success(account)
            } else {
                Result.failure(Exception("Account is null"))
            }
        } catch (e: ApiException) {
            Log.e(TAG, "Sign-in failed: ${e.statusCode}", e)
            Result.failure(e)
        } catch (e: Exception) {
            Log.e(TAG, "Sign-in error", e)
            Result.failure(e)
        }
    }
    
    /**
     * Get OAuth access token for API calls
     * 
     * This token is automatically refreshed by Google Play Services.
     * Uses user's quota (not project quota) - FREE!
     */
    suspend fun getAccessToken(): Result<String> = withContext(Dispatchers.IO) {
        try {
            val account = getSignedInAccount()
                ?: return@withContext Result.failure(Exception("Not signed in"))
            
            val token = GoogleAuthUtil.getToken(
                context,
                account.account,
                "oauth2:${SCOPES.joinToString(" ")}"
            )
            
            Log.d(TAG, "Access token retrieved successfully")
            Result.success(token)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to get access token", e)
            Result.failure(e)
        }
    }
    
    /**
     * Get Account object for Google API client
     */
    fun getAccount(): Account? {
        return getSignedInAccount()?.account
    }
    
    /**
     * Refresh access token if needed
     * 
     * Google Play Services handles this automatically,
     * but you can call this to force a refresh.
     */
    suspend fun refreshToken(): Result<String> = withContext(Dispatchers.IO) {
        try {
            val account = getSignedInAccount()
                ?: return@withContext Result.failure(Exception("Not signed in"))
            
            // Invalidate old token
            val oldToken = GoogleAuthUtil.getToken(
                context,
                account.account,
                "oauth2:${SCOPES.joinToString(" ")}"
            )
            GoogleAuthUtil.invalidateToken(context, oldToken)
            
            // Get new token
            val newToken = GoogleAuthUtil.getToken(
                context,
                account.account,
                "oauth2:${SCOPES.joinToString(" ")}"
            )
            
            Log.d(TAG, "Token refreshed successfully")
            Result.success(newToken)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to refresh token", e)
            Result.failure(e)
        }
    }
    
    /**
     * Sign out user
     */
    suspend fun signOut(): Result<Unit> = withContext(Dispatchers.IO) {
        try {
            getSignInClient().signOut().await()
            
            // Clear saved state
            sharedPrefs.edit()
                .clear()
                .apply()
            
            Log.d(TAG, "Sign-out successful")
            Result.success(Unit)
        } catch (e: Exception) {
            Log.e(TAG, "Sign-out failed", e)
            Result.failure(e)
        }
    }
    
    /**
     * Revoke access (disconnect account)
     */
    suspend fun revokeAccess(): Result<Unit> = withContext(Dispatchers.IO) {
        try {
            getSignInClient().revokeAccess().await()
            
            // Clear saved state
            sharedPrefs.edit()
                .clear()
                .apply()
            
            Log.d(TAG, "Access revoked successfully")
            Result.success(Unit)
        } catch (e: Exception) {
            Log.e(TAG, "Revoke access failed", e)
            Result.failure(e)
        }
    }
    
    /**
     * Check if specific scope is granted
     */
    fun hasScope(scope: String): Boolean {
        val account = getSignedInAccount() ?: return false
        return account.grantedScopes.contains(Scope(scope))
    }
    
    /**
     * Get all granted scopes
     */
    fun getGrantedScopes(): Set<Scope> {
        return getSignedInAccount()?.grantedScopes ?: emptySet()
    }
}

/**
 * Extension function to await Google Sign-In tasks
 */
private suspend fun <T> com.google.android.gms.tasks.Task<T>.await(): T {
    return kotlinx.coroutines.tasks.await(this)
}

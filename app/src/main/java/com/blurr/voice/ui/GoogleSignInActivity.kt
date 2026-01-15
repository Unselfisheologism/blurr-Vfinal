package com.blurr.voice.ui

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import com.blurr.voice.R
import com.blurr.voice.auth.GoogleAuthManager
import kotlinx.coroutines.launch

/**
 * Google Sign-In Activity
 * 
 * Story 4.13: Google OAuth Integration
 * 
 * Handles Google Sign-In for Workspace APIs.
 * Uses user's credentials for FREE API access.
 */
class GoogleSignInActivity : AppCompatActivity() {
    
    companion object {
        private const val TAG = "GoogleSignInActivity"
        const val EXTRA_AUTO_SIGN_IN = "auto_sign_in"
        const val EXTRA_REQUESTED_SCOPES = "requested_scopes"
    }
    
    private lateinit var authManager: GoogleAuthManager
    
    private val signInLauncher = registerForActivityResult(
        ActivityResultContracts.StartActivityForResult()
    ) { result ->
        if (result.resultCode == Activity.RESULT_OK) {
            handleSignInResult(result.data)
        } else {
            Log.w(TAG, "Sign-in cancelled or failed")
            Toast.makeText(this, "Sign-in cancelled", Toast.LENGTH_SHORT).show()
            finish()
        }
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_google_sign_in)

        authManager = GoogleAuthManager(this)

        val requestedScopes = intent.getStringArrayListExtra(EXTRA_REQUESTED_SCOPES)?.toList().orEmpty()

        findViewById<com.google.android.gms.common.SignInButton>(R.id.sign_in_button)
            .setOnClickListener {
                initiateSignIn(requestedScopes)
            }

        // If already signed in, only finish early if all requested scopes are already granted.
        if (authManager.isSignedIn()) {
            val email = authManager.getUserEmail()
            val hasRequestedScopes = requestedScopes.isEmpty() || requestedScopes.all { authManager.hasScope(it) }

            Log.d(TAG, "Already signed in: $email (hasRequestedScopes=$hasRequestedScopes)")

            if (hasRequestedScopes) {
                Toast.makeText(this, "Already signed in as $email", Toast.LENGTH_SHORT).show()
                setResult(Activity.RESULT_OK)
                finish()
                return
            }
        }

        // Auto sign-in if requested
        if (intent.getBooleanExtra(EXTRA_AUTO_SIGN_IN, false)) {
            initiateSignIn(requestedScopes)
        }
    }
    
    private fun initiateSignIn(requestedScopes: List<String>) {
        Log.d(TAG, "Initiating Google Sign-In (requestedScopes=${requestedScopes.size})")
        val signInIntent = if (requestedScopes.isEmpty()) {
            authManager.getSignInIntent()
        } else {
            authManager.getSignInIntent(requestedScopes)
        }
        signInLauncher.launch(signInIntent)
    }
    
    private fun handleSignInResult(data: Intent?) {
        lifecycleScope.launch {
            val result = authManager.handleSignInResult(data)
            
            if (result.isSuccess) {
                val account = result.getOrNull()
                Log.d(TAG, "Sign-in successful: ${account?.email}")
                Toast.makeText(
                    this@GoogleSignInActivity,
                    "Signed in as ${account?.displayName}",
                    Toast.LENGTH_LONG
                ).show()
                
                setResult(Activity.RESULT_OK)
                finish()
            } else {
                val error = result.exceptionOrNull()
                Log.e(TAG, "Sign-in failed", error)
                Toast.makeText(
                    this@GoogleSignInActivity,
                    "Sign-in failed: ${error?.message}",
                    Toast.LENGTH_LONG
                ).show()
                
                setResult(Activity.RESULT_CANCELED)
                finish()
            }
        }
    }
    
    fun signOut() {
        lifecycleScope.launch {
            val result = authManager.signOut()
            if (result.isSuccess) {
                Toast.makeText(this@GoogleSignInActivity, "Signed out", Toast.LENGTH_SHORT).show()
            }
        }
    }
}

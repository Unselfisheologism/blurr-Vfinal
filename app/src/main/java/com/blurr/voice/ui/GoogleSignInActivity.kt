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
        
        // Check if already signed in
        if (authManager.isSignedIn()) {
            val email = authManager.getUserEmail()
            Log.d(TAG, "Already signed in: $email")
            Toast.makeText(this, "Already signed in as $email", Toast.LENGTH_SHORT).show()
            setResult(Activity.RESULT_OK)
            finish()
            return
        }
        
        // Auto sign-in if requested
        if (intent.getBooleanExtra(EXTRA_AUTO_SIGN_IN, false)) {
            initiateSignIn()
        }
    }
    
    private fun initiateSignIn() {
        Log.d(TAG, "Initiating Google Sign-In")
        val signInIntent = authManager.getSignInIntent()
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

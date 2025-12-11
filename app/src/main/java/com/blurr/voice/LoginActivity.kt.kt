package com.blurr.voice

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.runtime.*
import androidx.lifecycle.lifecycleScope
import com.blurr.voice.auth.ui.LoginScreen
import com.blurr.voice.auth.ui.SignUpScreen
import com.blurr.voice.utilities.OnboardingManager
import kotlinx.coroutines.launch

class LoginActivity : ComponentActivity() {

    enum class AuthScreen { Login, SignUp }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // TODO: Check if session exists automatically in ViewModel or here?
        // ViewModel checks session on init. If logged in, we should navigate.
        // Usually Activity should observe that state too.
        // For now, we'll let the Screen handle the "Success" event which might fire immediately if session check passes.
        
        setContent {
            // Simple Theme wrapper - replace with actual AppTheme if available
            androidx.compose.material3.MaterialTheme {
                var currentScreen by remember { mutableStateOf(AuthScreen.Login) }

                when (currentScreen) {
                    AuthScreen.Login -> LoginScreen(
                        onNavigateToSignUp = { currentScreen = AuthScreen.SignUp },
                        onLoginSuccess = { onAuthSuccess() }
                    )
                    AuthScreen.SignUp -> SignUpScreen(
                        onNavigateToLogin = { currentScreen = AuthScreen.Login },
                        onSignUpSuccess = { onAuthSuccess() }
                    )
                }
            }
        }
    }

    private fun onAuthSuccess() {
        lifecycleScope.launch {
            val onboardingManager = OnboardingManager(this@LoginActivity)
            if (onboardingManager.isOnboardingCompleted()) {
                startActivity(Intent(this@LoginActivity, MainActivity::class.java))
            } else {
                startActivity(Intent(this@LoginActivity, OnboardingPermissionsActivity::class.java))
            }
            finish()
        }
    }
}

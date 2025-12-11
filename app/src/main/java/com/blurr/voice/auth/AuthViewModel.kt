package com.blurr.voice.auth

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.blurr.voice.core.result.Result
import com.blurr.voice.core.result.AIError
import io.appwrite.models.User
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

data class AuthUiState(
    val isLoading: Boolean = false,
    val isLoggedIn: Boolean = false,
    val user: User<Map<String, Any>>? = null,
    val error: AIError? = null,
    val authSuccess: Boolean = false
)

class AuthViewModel(
    private val authRepository: AuthRepository = AppwriteAuthRepository()
) : ViewModel() {

    private val _uiState = MutableStateFlow(AuthUiState())
    val uiState: StateFlow<AuthUiState> = _uiState.asStateFlow()

    init {
        checkSession()
    }

    private fun checkSession() {
        _uiState.update { it.copy(isLoading = true) }
        viewModelScope.launch {
            // getCurrentUser succeeds only if session exists
            when (val result = authRepository.getCurrentUser()) {
                is Result.Success -> {
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            isLoggedIn = true,
                            user = result.data,
                            error = null
                        )
                    }
                }
                is Result.Error -> {
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            isLoggedIn = false,
                            user = null,
                            error = null
                        )
                    }
                }
            }
        }
    }

    fun login(email: String, pass: String) {
        if (email.isBlank() || pass.isBlank()) {
            _uiState.update { it.copy(error = AIError(AIError.AUTH_INVALID_CREDENTIALS, "Email and password required")) }
            return
        }

        _uiState.update { it.copy(isLoading = true, error = null) }
        viewModelScope.launch {
            when (val result = authRepository.login(email, pass)) {
                is Result.Success -> {
                    // Fetch user details to complete login state
                    loadUser()
                }
                is Result.Error -> {
                    _uiState.update { it.copy(isLoading = false, error = result.error) }
                }
            }
        }
    }

    fun signUp(email: String, pass: String) {
         if (email.isBlank() || pass.isBlank()) {
            _uiState.update { it.copy(error = AIError(AIError.AUTH_INVALID_CREDENTIALS, "Email and password required")) }
            return
        }

        _uiState.update { it.copy(isLoading = true, error = null) }
        viewModelScope.launch {
            when (val result = authRepository.signUp(email, pass)) {
                is Result.Success -> {
                    // Automatically login after signup
                    login(email, pass)
                }
                is Result.Error -> {
                    _uiState.update { it.copy(isLoading = false, error = result.error) }
                }
            }
        }
    }

    fun logout() {
        _uiState.update { it.copy(isLoading = true) }
        viewModelScope.launch {
            authRepository.logout()
            _uiState.update { AuthUiState(isLoading = false) } // Reset completely
        }
    }

    private fun loadUser() {
        viewModelScope.launch {
            when (val result = authRepository.getCurrentUser()) {
                is Result.Success -> {
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            isLoggedIn = true,
                            user = result.data,
                            authSuccess = true
                        )
                    }
                }
                is Result.Error -> {
                    // Should rarely happen if login succeeded
                    _uiState.update { it.copy(isLoading = false, error = result.error) }
                }
            }
        }
    }

    fun clearError() {
        _uiState.update { it.copy(error = null) }
    }
    
    fun resetAuthSuccess() {
        _uiState.update { it.copy(authSuccess = false) }
    }
}

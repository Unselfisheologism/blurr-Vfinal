package io.flutter.plugin.common;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * Stub implementation of Flutter's MethodChannel.Result for build compatibility.
 * Provides concrete implementations of the Result interface methods.
 */
public class MethodChannelResult implements MethodChannel.Result {
    private boolean successCalled = false;
    private boolean errorCalled = false;
    private boolean notImplementedCalled = false;
    private Object lastResult;
    private String lastErrorCode;
    private String lastErrorMessage;
    private Object lastErrorDetails;

    @Override
    public void success(@Nullable Object result) {
        successCalled = true;
        lastResult = result;
    }

    @Override
    public void error(@NonNull String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
        errorCalled = true;
        lastErrorCode = errorCode;
        lastErrorMessage = errorMessage;
        lastErrorDetails = errorDetails;
    }

    @Override
    public void notImplemented() {
        notImplementedCalled = true;
    }

    // Additional helper methods for compatibility
    public Object getLastResult() {
        return lastResult;
    }

    public String getLastErrorCode() {
        return lastErrorCode;
    }

    public String getLastErrorMessage() {
        return lastErrorMessage;
    }

    public Object getLastErrorDetails() {
        return lastErrorDetails;
    }

    public boolean wasSuccessCalled() {
        return successCalled;
    }

    public boolean wasErrorCalled() {
        return errorCalled;
    }

    public boolean wasNotImplementedCalled() {
        return notImplementedCalled;
    }

    public boolean wasSuccessful() {
        return successCalled && !errorCalled && !notImplementedCalled;
    }
}
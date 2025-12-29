package io.flutter.plugin.common;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

/**
 * Stub implementation of Flutter's MethodChannel for build compatibility.
 */
public class MethodChannel {

    public interface Result {
        void success(@Nullable Object result);
        void error(@NonNull String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails);
        void notImplemented();
    }

    public interface MethodCallHandler {
        void onMethodCall(@NonNull MethodCall call, @NonNull Result result);
    }

    public MethodChannel(@NonNull Object messenger, @NonNull String name) {
        // no-op
    }

    public void setMethodCallHandler(@Nullable MethodCallHandler handler) {
        // no-op
    }

    public void invokeMethod(@NonNull String method, @Nullable Object arguments) {
        // no-op
    }

    public void invokeMethod(@NonNull String method, @Nullable Object arguments, @Nullable Result callback) {
        // no-op
    }
}

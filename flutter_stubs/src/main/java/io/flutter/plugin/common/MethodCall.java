package io.flutter.plugin.common;

import androidx.annotation.Nullable;
import java.util.Map;

/**
 * Stub implementation of Flutter's MethodCall for build compatibility.
 * This is a placeholder to allow the Android code to compile when Flutter is not available.
 */
public class MethodCall {
    public final String method;
    public final Object arguments;

    public MethodCall(String method, Object arguments) {
        this.method = method;
        this.arguments = arguments;
    }

    @Nullable
    @SuppressWarnings("unchecked")
    public <T> T arguments() {
        return (T) arguments;
    }

    @Nullable
    @SuppressWarnings("unchecked")
    public <T> T argument(String key) {
        if (arguments instanceof Map) {
            return (T) ((Map) arguments).get(key);
        }
        return null;
    }

    public boolean hasArgument(String key) {
        if (arguments instanceof Map) {
            return ((Map) arguments).containsKey(key);
        }
        return false;
    }

    /**
     * Additional stub methods for compatibility
     */
    public String methodName() {
        return method;
    }

    public Object methodArguments() {
        return arguments;
    }

    /**
     * Helper method to get method as String
     */
    public String getMethod() {
        return method;
    }

    /**
     * Helper method to get arguments as Object
     */
    public Object getArguments() {
        return arguments;
    }
}

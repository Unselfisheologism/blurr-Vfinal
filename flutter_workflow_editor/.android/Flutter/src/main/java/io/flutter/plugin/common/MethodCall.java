package io.flutter.plugin.common;

import java.util.Map;

/**
 * Minimal MethodCall stub for compilation without Flutter SDK
 */
public class MethodCall {
    
    private final String method;
    private final Map<String, Object> arguments;
    
    public MethodCall(String method, Map<String, Object> arguments) {
        this.method = method;
        this.arguments = arguments;
    }
    
    public String method() {
        return method;
    }
    
    public <T> T argument(String key) {
        if (arguments == null) {
            return null;
        }
        return (T) arguments.get(key);
    }
    
    public Map<String, Object> arguments() {
        return arguments;
    }
}
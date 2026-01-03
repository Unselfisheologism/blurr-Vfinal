package io.flutter.plugin.common;

/**
 * Minimal MethodChannel stub for compilation without Flutter SDK
 */
public class MethodChannel {
    
    public MethodChannel(Object messenger, String name) {
        // Empty constructor
    }
    
    public void setMethodCallHandler(MethodChannel.MethodCallHandler handler) {
        // No-op for stub
    }
    
    public interface MethodCallHandler {
        void onMethodCall(MethodCall call, Result result);
    }
    
    public interface Result {
        void success(Object result);
        void error(String errorCode, String errorMessage, Object errorDetails);
        void notImplemented();
    }
}
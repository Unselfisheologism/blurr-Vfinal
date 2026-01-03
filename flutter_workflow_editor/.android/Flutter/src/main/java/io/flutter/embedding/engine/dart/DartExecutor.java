package io.flutter.embedding.engine.dart;

/**
 * Minimal DartExecutor stub for compilation without Flutter SDK
 */
public class DartExecutor {
    
    public void executeDartEntrypoint(DartEntrypoint dartEntrypoint) {
        // No-op for stub
    }
    
    public Object getBinaryMessenger() {
        return new Object(); // Return dummy binary messenger
    }
    
    public static class DartEntrypoint {
        public static DartEntrypoint createDefault() {
            return new DartEntrypoint();
        }
    }
}
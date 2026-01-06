package io.flutter.embedding.engine.dart;

import androidx.annotation.NonNull;

/**
 * Stub implementation of Flutter's DartExecutor for build compatibility.
 */
public class DartExecutor {

    public final Object binaryMessenger = new Object();

    public static class DartEntrypoint {
        public static DartEntrypoint createDefault() {
            return new DartEntrypoint();
        }
    }

    public Object getBinaryMessenger() {
        return binaryMessenger;
    }

    public void executeDartEntrypoint(@NonNull DartEntrypoint entrypoint) {
        // no-op
    }

    /**
     * Additional stub methods for compatibility
     */
    public Object binaryMessenger() {
        return binaryMessenger;
    }

    public boolean isRunning() {
        return false;
    }

    public void onAttached() {
        // no-op
    }

    public void onDetached() {
        // no-op
    }
}

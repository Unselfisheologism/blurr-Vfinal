package io.flutter.embedding.engine;

import android.content.Context;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.NavigationChannel;

/**
 * Stub implementation of Flutter's FlutterEngine for build compatibility.
 */
public class FlutterEngine {
    private final DartExecutor dartExecutor;
    private final NavigationChannel navigationChannel;

    public FlutterEngine(@NonNull Context context) {
        this.dartExecutor = new DartExecutor();
        this.navigationChannel = new NavigationChannel();
    }

    @NonNull
    public DartExecutor getDartExecutor() {
        return dartExecutor;
    }

    @NonNull
    public NavigationChannel getNavigationChannel() {
        return navigationChannel;
    }

    public void destroy() {
        // no-op
    }

    /**
     * Additional stub methods for compatibility
     */
    public NavigationChannel navigationChannel() {
        return navigationChannel;
    }

    public DartExecutor dartExecutor() {
        return dartExecutor;
    }

    public void getLifecycle() {
        // no-op
    }
}

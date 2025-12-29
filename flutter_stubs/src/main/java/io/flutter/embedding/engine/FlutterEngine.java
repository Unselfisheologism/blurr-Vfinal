package io.flutter.embedding.engine;

import android.content.Context;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.dart.DartExecutor;

/**
 * Stub implementation of Flutter's FlutterEngine for build compatibility.
 */
public class FlutterEngine {
    public final DartExecutor dartExecutor;
    public final NavigationChannel navigationChannel;

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
}

package io.flutter.embedding.android;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import android.view.View;
import io.flutter.embedding.engine.FlutterEngine;

/**
 * Stub implementation of FlutterView for build compatibility.
 */
public class FlutterView extends View {
    private FlutterEngine flutterEngine;

    public FlutterView(@NonNull Context context) {
        super(context);
    }

    public FlutterView(@NonNull Context context, @Nullable FlutterEngine engine) {
        super(context);
        this.flutterEngine = engine;
    }

    @Nullable
    public FlutterEngine getFlutterEngine() {
        return flutterEngine;
    }

    /**
     * Additional stub methods for compatibility
     */
    public void attachToFlutterEngine(@NonNull FlutterEngine engine) {
        this.flutterEngine = engine;
    }

    public void detachFromFlutterEngine() {
        this.flutterEngine = null;
    }

    public boolean isAttachedToFlutterEngine() {
        return flutterEngine != null;
    }
}
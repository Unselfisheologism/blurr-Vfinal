package io.flutter.embedding.android;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.embedding.engine.FlutterEngine;

/**
 * Stub implementation of FlutterView for build compatibility.
 */
public class FlutterView extends FrameLayout {

    public FlutterView(@NonNull Context context) {
        super(context);
    }

    public FlutterView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public void attachToFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        // no-op
    }

    public void detachFromFlutterEngine() {
        // no-op
    }
}

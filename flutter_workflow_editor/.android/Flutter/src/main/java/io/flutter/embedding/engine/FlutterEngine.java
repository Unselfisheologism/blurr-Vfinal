package io.flutter.embedding.engine;

import android.content.Context;
import io.flutter.embedding.engine.dart.DartExecutor;

/**
 * Minimal FlutterEngine stub for compilation without Flutter SDK
 */
public class FlutterEngine {
    
    public final DartExecutor dartExecutor;
    
    public FlutterEngine(Context context) {
        this.dartExecutor = new DartExecutor();
    }
    
    public void destroy() {
        // No-op for stub
    }
}
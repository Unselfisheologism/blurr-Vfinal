package io.flutter.embedding.android;

import android.content.Context;
import android.os.Bundle;
import androidx.fragment.app.Fragment;

/**
 * Minimal FlutterFragment stub for compilation without Flutter SDK
 */
public class FlutterFragment extends Fragment {
    
    public static FlutterFragment withCachedEngine(String engineId) {
        return new FlutterFragment();
    }
    
    public FlutterFragment() {
        // Empty constructor
    }
    
    public static class CachedEngineFragmentBuilder {
        public FlutterFragment build() {
            return new FlutterFragment();
        }
    }
}
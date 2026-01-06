package io.flutter.embedding.android;

import android.content.Context;
import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;

/**
 * Stub implementation of FlutterFragment for build compatibility.
 */
public class FlutterFragment extends Fragment {
    private FlutterEngine flutterEngine;

    public FlutterFragment() {
        // Default constructor
    }

    @Nullable
    public FlutterEngine getFlutterEngine() {
        return flutterEngine;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        flutterEngine = new FlutterEngine(requireContext());
    }

    @Override
    public void onDestroy() {
        if (flutterEngine != null) {
            flutterEngine.destroy();
        }
        super.onDestroy();
    }

    /**
     * Additional stub methods for compatibility
     */
    public static FlutterEngine provideFlutterEngine(@NonNull Context context) {
        return new FlutterEngine(context);
    }

    public DartExecutor getDartExecutor() {
        return flutterEngine != null ? flutterEngine.getDartExecutor() : null;
    }
}
package io.flutter.embedding.android;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;

/**
 * Stub implementation of FlutterFragment for build compatibility.
 */
public class FlutterFragment extends Fragment {

    public static class Builder {
        private String engineId;

        public Builder() {
        }

        public Builder engineId(@NonNull String engineId) {
            this.engineId = engineId;
            return this;
        }

        public FlutterFragment build() {
            return new FlutterFragment();
        }
    }

    public static Builder withCachedEngine(@NonNull String engineId) {
        return new Builder().engineId(engineId);
    }

    public static Builder withNewEngine() {
        return new Builder();
    }
}

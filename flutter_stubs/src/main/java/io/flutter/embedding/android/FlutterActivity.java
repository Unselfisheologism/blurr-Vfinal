package io.flutter.embedding.android;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import androidx.annotation.NonNull;

/**
 * Stub implementation of FlutterActivity for build compatibility.
 */
public class FlutterActivity extends Activity {
    
    @NonNull
    public static CachedEngineIntentBuilder withCachedEngine(@NonNull String engineId) {
        return new CachedEngineIntentBuilder(engineId);
    }
    
    public static class CachedEngineIntentBuilder {
        private final String engineId;
        
        public CachedEngineIntentBuilder(@NonNull String engineId) {
            this.engineId = engineId;
        }
        
        @NonNull
        public Intent build(@NonNull Context context) {
            Intent intent = new Intent(context, FlutterActivity.class);
            intent.putExtra("cached_engine_id", engineId);
            return intent;
        }
    }
}

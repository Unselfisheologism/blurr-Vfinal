package io.flutter.embedding.engine;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Stub implementation of FlutterEngineCache for build compatibility.
 */
public class FlutterEngineCache {
    private static final FlutterEngineCache INSTANCE = new FlutterEngineCache();
    private final ConcurrentHashMap<String, FlutterEngine> cache = new ConcurrentHashMap<>();

    @NonNull
    public static FlutterEngineCache getInstance() {
        return INSTANCE;
    }

    @Nullable
    public FlutterEngine get(@NonNull String engineId) {
        return cache.get(engineId);
    }

    public void put(@NonNull String engineId, @NonNull FlutterEngine engine) {
        cache.put(engineId, engine);
    }

    @Nullable
    public FlutterEngine remove(@NonNull String engineId) {
        return cache.remove(engineId);
    }

    public void clear() {
        cache.clear();
    }

    public boolean contains(@NonNull String engineId) {
        return cache.containsKey(engineId);
    }

    public int size() {
        return cache.size();
    }

    public boolean isEmpty() {
        return cache.isEmpty();
    }
}
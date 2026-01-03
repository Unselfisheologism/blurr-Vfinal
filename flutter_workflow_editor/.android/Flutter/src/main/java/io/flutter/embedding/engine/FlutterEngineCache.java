package io.flutter.embedding.engine;

import java.util.HashMap;
import java.util.Map;

/**
 * Minimal FlutterEngineCache stub for compilation without Flutter SDK
 */
public class FlutterEngineCache {
    
    private static FlutterEngineCache instance;
    private final Map<String, FlutterEngine> engines = new HashMap<>();
    
    public static FlutterEngineCache getInstance() {
        if (instance == null) {
            instance = new FlutterEngineCache();
        }
        return instance;
    }
    
    public FlutterEngine get(String engineId) {
        return engines.get(engineId);
    }
    
    public void put(String engineId, FlutterEngine engine) {
        engines.put(engineId, engine);
    }
    
    public boolean contains(String engineId) {
        return engines.containsKey(engineId);
    }
}
package com.blurr.voice.flutter;

/**
 * Stub Flutter runtime for Android builds without Flutter SDK.
 * This provides minimal compatibility for Flutter-related imports.
 */
public class FlutterRuntime {
    
    /**
     * Stub method to check if Flutter is available
     */
    public static boolean isFlutterAvailable() {
        return false;
    }
    
    /**
     * Stub method to initialize Flutter
     */
    public static boolean initializeFlutter() {
        return false;
    }
    
    /**
     * Stub method to get Flutter version
     */
    public static String getFlutterVersion() {
        return "1.0.0-stub";
    }
    
    /**
     * Stub method to check Flutter engine status
     */
    public static boolean isFlutterEngineRunning() {
        return false;
    }
}
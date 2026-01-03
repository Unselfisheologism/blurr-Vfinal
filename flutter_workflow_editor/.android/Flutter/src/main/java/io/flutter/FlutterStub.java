package io.flutter;

/**
 * Minimal Flutter stub class to allow compilation without full Flutter SDK
 * This provides basic Flutter functionality for the AAR build
 */
public class FlutterStub {
    
    public static boolean isFlutterAvailable() {
        return false; // Flutter not available in this build
    }
    
    public static String getFlutterVersion() {
        return "1.0.0-stub";
    }
}
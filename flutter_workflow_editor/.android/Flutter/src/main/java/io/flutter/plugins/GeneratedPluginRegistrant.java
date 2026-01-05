package io.flutter.plugins;

import io.flutter.embedding.engine.FlutterEngine;

/**
 * Stub implementation to prevent Flutter AAR build issues in CI.
 * When building the full app, the real Flutter module integration handles plugin registration natively.
 * This stub prevents "package does not exist" errors during compilation.
 */
public class GeneratedPluginRegistrant {
    public static void registerWith(FlutterEngine flutterEngine) {
        // Stub implementation - no actual plugin registration needed here.
        // The real plugins are registered through the Flutter module integration in the app.
    }
}

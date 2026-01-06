package com.blurr.voice.apps.daw;

import android.content.Context;
import android.content.Intent;

/**
 * Stub DawEditor launcher for Android builds without Flutter SDK.
 */
class DawEditorLauncher {
    
    public static void launchDawEditor(Context context) {
        // Stub implementation
    }
    
    public static Intent createDawEditorIntent(Context context) {
        return new Intent();
    }
    
    public static boolean isDawEditorAvailable() {
        return false;
    }
}
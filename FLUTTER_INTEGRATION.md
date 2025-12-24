# Flutter Workflow Editor Integration

This document explains how the Flutter workflow editor module is integrated into the Android app.

## Overview

The `flutter_workflow_editor` module provides a visual node-based workflow editor for the Panda app. It's built with Flutter and integrated into the native Android app as a library module.

## Current Status

✅ **Module Re-enabled** - The Flutter module has been re-enabled and successfully integrated into the Android build system.

### What was changed:

1. **Converted to Kotlin DSL**: All Gradle build files in the Flutter module have been converted from Groovy to Kotlin DSL for consistency with the main project.

2. **Conditional Flutter SDK Support**: The module now gracefully handles both scenarios:
   - **With Flutter SDK**: Builds the full Flutter module with all Flutter features
   - **Without Flutter SDK**: Builds a stub module that allows the Android app to compile successfully

3. **Fixed Repository Conflicts**: Removed duplicate repository declarations that were causing warnings with Gradle's `preferSettings` mode.

4. **Fixed Manifest**: Removed deprecated `package` attribute from AndroidManifest.xml.

## File Structure

```
flutter_workflow_editor/
├── .android/
│   ├── Flutter/
│   │   ├── build.gradle.kts          # Flutter module build (Kotlin DSL)
│   │   ├── build.gradle.backup       # Original Groovy version (backup)
│   │   ├── build.gradle.stub         # Stub implementation reference
│   │   └── src/
│   │       └── main/
│   │           └── AndroidManifest.xml
│   ├── build.gradle.kts              # Subproject build (Kotlin DSL)
│   ├── build.gradle.backup           # Original Groovy version (backup)
│   ├── local.properties              # Flutter SDK configuration
│   ├── settings.gradle.kts           # Subproject settings (Kotlin DSL)
│   ├── settings.gradle.backup        # Original Groovy version (backup)
│   └── include_flutter.groovy        # Groovy script (no longer used)
├── lib/                              # Flutter source code
├── pubspec.yaml                      # Flutter dependencies
└── prepare_android.sh               # Setup script
```

## Integration Points

### 1. settings.gradle.kts (Root Project)

The Flutter module is conditionally included:

```kotlin
val flutterProjectDir = file("flutter_workflow_editor")
if (flutterProjectDir.exists()) {
    val flutterAndroidDir = File(flutterProjectDir, ".android")
    if (flutterAndroidDir.exists()) {
        include(":flutter_workflow_editor")
        project(":flutter_workflow_editor").projectDir = flutterAndroidDir
    }
}
```

### 2. app/build.gradle.kts (Dependencies)

The Flutter module is added as a project dependency:

```kotlin
dependencies {
    implementation(project(":flutter_workflow_editor"))
    // ... other dependencies
}
```

## Configuration

### Flutter SDK Setup

To build the full Flutter module (not just the stub):

1. Install Flutter SDK on your development machine
2. Update `flutter_workflow_editor/.android/local.properties`:

```properties
flutter.sdk=/path/to/your/flutter/sdk
```

3. Run the preparation script:

```bash
cd flutter_workflow_editor
./prepare_android.sh
```

### Without Flutter SDK

If Flutter SDK is not available:
- Leave `flutter.sdk` empty in `local.properties`
- The module will build as a stub, allowing the Android app to compile
- The Flutter workflow editor UI will not be available at runtime

## Building

### Build Flutter Module Only:

```bash
./gradlew :flutter_workflow_editor:assembleDebug
```

### Build Android App with Flutter Module:

```bash
./gradlew :app:assembleDebug
```

## Troubleshooting

### Issue: "Flutter SDK not found"

**Solution:**
1. Ensure Flutter SDK is installed
2. Update `flutter_workflow_editor/.android/local.properties` with the SDK path
3. Verify the path exists and is accessible

### Issue: Repository conflict warnings

**Solution:**
- These warnings have been addressed by removing repository declarations from the Flutter module's build.gradle.kts
- All repositories are now configured in the root settings.gradle.kts

### Issue: Build fails in CI environment

**Solution:**
- Ensure CI environment has Flutter SDK installed if you need the Flutter module
- Otherwise, the stub module will allow the build to proceed

## Migration Notes

### Groovy to Kotlin DSL Changes:

1. **build.gradle → build.gradle.kts**:
   - Converted `apply plugin:` to `plugins {}` block
   - Changed string-based dependencies to Kotlin DSL syntax
   - Updated property access syntax

2. **settings.gradle → settings.gradle.kts**:
   - Converted Groovy `include` syntax to Kotlin
   - Removed Groovy-specific `setBinding()` calls
   - Manually included Flutter subproject instead of using Groovy script

3. **Flutter/build.gradle → Flutter/build.gradle.kts**:
   - Added conditional Flutter SDK loading
   - Graceful fallback to stub module when SDK unavailable
   - Used reflection to configure Flutter extension when available

## Future Enhancements

### To fully enable Flutter features:

1. Ensure Flutter SDK is available in the build environment
2. Configure proper Flutter version in `local.properties`:
   ```properties
   flutter.sdk=/path/to/flutter
   flutter.versionCode=1
   flutter.versionName=1.0
   ```
3. Run `flutter pub get` in the `flutter_workflow_editor` directory
4. Build the Flutter module to generate native Android code

### To integrate Flutter UI in the app:

The Flutter module will provide:
- A FlutterEngine instance for the workflow editor
- Method channels for communication between Android and Flutter
- Visual workflow editor components

## Related Files

- `/home/engine/project/settings.gradle.kts` - Root project settings
- `/home/engine/project/app/build.gradle.kts` - App dependencies
- `/home/engine/project/flutter_workflow_editor/.android/Flutter/build.gradle.kts` - Flutter module
- `/home/engine/project/gradle/libs.versions.toml` - Version catalog

## Support

For issues related to:
- **Gradle/Kotlin DSL**: Check this document and build files
- **Flutter configuration**: Refer to Flutter documentation
- **Integration**: See the integration points section above

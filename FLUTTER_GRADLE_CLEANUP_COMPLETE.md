# Flutter Gradle Configuration Cleanup

## Problem
The build was failing with the error:
```
Project with path ':flutter' could not be found in project ':flutter_workflow_editor'
```

This error occurred at `flutter_workflow_editor/.android/app/build.gradle` line 36 in the `flutter { source '../..' }` block.

## Root Cause
The Flutter module's `.android` directory contained a complete standalone Gradle project structure with its own:
- `settings.gradle` - configured plugin management and included `:app` as a separate project
- `build.gradle` - defined buildscript dependencies and allprojects repositories
- `gradle.properties` - configured Gradle daemon and JVM settings
- `gradlew`/`gradlew.bat` - Gradle wrapper scripts
- `gradle/` directory - Gradle wrapper distribution
- `init.gradle` - additional Gradle initialization

When the main project's `settings.gradle.kts` included `:flutter_workflow_editor` (pointing to `flutter_workflow_editor/.android/app`), these redundant Gradle configuration files created conflicts. The Flutter Gradle plugin (`dev.flutter.flutter-gradle-plugin`) was being applied to a project structure that had its own independent build configuration, leading to the plugin trying to resolve a `:flutter` subproject that didn't exist.

## Solution
Removed all redundant Gradle configuration from `flutter_workflow_editor/.android/`:

### Deleted Files:
1. `settings.gradle` - Main `settings.gradle.kts` now manages all project structure
2. `build.gradle` - Main `build.gradle.kts` already handles build configuration
3. `gradle.properties` - Main project's `gradle.properties` applies to all subprojects
4. `gradlew` / `gradlew.bat` - Not needed for subprojects
5. `gradle/` directory - Not needed for subprojects
6. `init.gradle` - Main project already configures repositories

### Remaining Files:
The only files remaining in `flutter_workflow_editor/.android/` are:
- `app/build.gradle` - Required for Android library configuration with Flutter plugin
- `app/proguard-rules.pro` - ProGuard rules for the Flutter module
- `app/src/` - Source code directory

## How It Works Now

### Main Project Configuration
The main `settings.gradle.kts`:
1. Checks if Flutter SDK is available
2. Includes `:flutter_workflow_editor` pointing to `flutter_workflow_editor/.android/app`
3. Enforces evaluation order with `evaluationDependsOn(":flutter_workflow_editor")` for the app project
4. Falls back to `:flutter_stubs` if Flutter SDK is not available

### Flutter Module Configuration
The `flutter_workflow_editor/.android/app/build.gradle`:
1. Applies the Flutter Gradle plugin (`dev.flutter.flutter-gradle-plugin`)
2. Configures the Android library
3. Points to the Flutter module root with `flutter { source '../..' }`

### Build Flow
1. Gradle reads main `settings.gradle.kts`
2. Includes `:flutter_workflow_editor` as an Android library subproject
3. Evaluates `:flutter_workflow_editor` before `:app` (enforced by `evaluationDependsOn`)
4. Applies Flutter plugin to `:flutter_workflow_editor`
5. Flutter plugin handles all Flutter integration internally without needing a `:flutter` subproject

## Benefits
- **Single source of truth**: All build configuration is managed from the main project
- **No conflicts**: No duplicate Gradle settings or build configurations
- **Simpler structure**: Only essential files remain in the Flutter module's `.android` directory
- **Cleaner integration**: Flutter plugin operates without interference from stale wrapper configuration

## Future Maintenance
When adding or modifying Flutter plugins:
1. Edit `flutter_workflow_editor/pubspec.yaml` to add Flutter dependencies
2. The Flutter Gradle plugin automatically handles plugin registration
3. No manual configuration of `GeneratedPluginRegistrant.java` is needed

Do NOT recreate the following files in `flutter_workflow_editor/.android/`:
- `settings.gradle`
- `build.gradle`
- `gradle.properties`
- `gradlew` / `gradlew.bat`
- `gradle/` directory
- `init.gradle`

These files are managed by the main project's Gradle configuration.

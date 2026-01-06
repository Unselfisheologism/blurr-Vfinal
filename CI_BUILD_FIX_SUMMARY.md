# GitHub Actions Workflow Fix Summary

## Problem
The GitHub Actions workflow was failing with the error:
```
Project with path ':flutter' could not be found in project ':flutter_workflow_editor'
```

This occurred because the Flutter Gradle plugin expects a `:flutter` project reference when the Flutter module's `.android/app` directory is built as a standalone Android project.

## Root Cause
The `flutter_workflow_editor/.android/settings.gradle` only includes the `:app` subproject (the library module at `.android/app`), but no `:flutter` project. The Flutter Gradle plugin requires this reference during project evaluation.

## Solution
The workflow has been updated to build from the repository root instead of treating the Flutter module's `.android` directory as a standalone Android project.

### Key Changes to `.github/workflows/build-apk.yml`

1. **Added Flutter SDK Configuration (lines 54-61)**
   - Creates `local.properties` at the repository root with `flutter.sdk` property
   - Ensures the root `settings.gradle.kts` can find and include the Flutter module

2. **Updated Flutter Module Preparation (lines 64-74)**
   - Creates `local.properties` in `flutter_workflow_editor/.android/`
   - Ensures the Android wrapper can reference the Flutter SDK

3. **Updated Debug Build (lines 90-96)**
   - Changed from `./gradlew clean assembleDebug` to `./gradlew clean :app:assembleDebug`
   - Builds from repository root with explicit task reference
   - Added FLUTTER_ROOT environment variable
   - Added debug logging

4. **Updated Release Build (lines 106-117)**
   - Changed from `./gradlew clean assembleRelease` to `./gradlew clean :app:assembleRelease`
   - Builds from repository root with explicit task reference
   - Added FLUTTER_ROOT environment variable
   - Added debug logging

## How It Works

### Root Build System Integration
The repository root's `settings.gradle.kts` (lines 64-93) conditionally includes the Flutter module:

```kotlin
if (flutterGradlePluginDir != null
    && flutterGradlePluginDir.exists()
    && flutterAndroidProjectDir.exists()
) {
    include(":flutter_workflow_editor")
    project(":flutter_workflow_editor").projectDir = flutterAndroidProjectDir
}
```

### App Module Integration
The `app/build.gradle.kts` (lines 191-195) links to the Flutter module:

```kotlin
if (rootProject.findProject(":flutter_workflow_editor") != null) {
    implementation(project(":flutter_workflow_editor"))
}
```

## Benefits

1. ✅ **Eliminates `:flutter` project reference errors** - The Flutter Gradle plugin is invoked through the proper build system
2. ✅ **Proper Gradle 8+ lifecycle** - Root settings.gradle.kts ensures correct evaluation order
3. ✅ **Conditional Flutter integration** - Builds work with or without Flutter SDK via `:flutter_stubs` fallback
4. ✅ **Clean separation of concerns** - Android wrapper is minimal, main build system handles integration

## Workflow Commands

### ❌ WRONG (causes error):
```bash
cd flutter_workflow_editor/.android && ./gradlew app:assembleRelease
```

### ✅ CORRECT:
```bash
./gradlew :app:assembleDebug   # From repository root
./gradlew :app:assembleRelease  # From repository root
```

### What Does `:app:assembleDebug` Build?

The `:app` module is the **main Android application module** that contains:
- ✅ All Kotlin source code (app/src/main/kotlin/)
- ✅ All Java source code (app/src/main/java/)
- ✅ All resources, layouts, and assets
- ✅ AndroidManifest.xml
- ✅ All dependencies including `:flutter_workflow_editor`

When you run `./gradlew :app:assembleDebug`, Gradle:
1. First builds all dependencies (`:flutter_workflow_editor`, `:flutter_stubs`)
2. Then compiles all Kotlin and Java code in `:app`
3. Processes all resources
4. Produces the final APK

**Both commands work correctly:**
- `./gradlew assembleDebug` - Runs on all modules (less specific)
- `./gradlew :app:assembleDebug` - Targets the app module explicitly (recommended)

The `:app:` prefix doesn't limit the build - it's just being explicit about which module produces the APK.

## Environment Variables
- `FLUTTER_ROOT`: Set by `subosito/flutter-action@v2`
- `ANDROID_HOME`: Set by `android-actions/setup-android@v3`
- Both are propagated to Gradle build steps

## Testing
To test the workflow locally:
1. Ensure Flutter SDK is installed and in PATH
2. Set `FLUTTER_ROOT` environment variable
3. Run from repository root:
   ```bash
   ./gradlew :app:assembleDebug
   ```

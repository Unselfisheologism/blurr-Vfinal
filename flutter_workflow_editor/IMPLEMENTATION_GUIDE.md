# Flutter Workflow Editor - Generate Android Artifacts

This guide explains how to generate the Flutter Android artifacts required to integrate the workflow editor into the Blurr Android app.

## Table of Contents
1. [Why This Is Needed](#why-this-is-needed)
2. [Prerequisites](#prerequisites)
3. [Quick Start](#quick-start)
4. [Detailed Steps](#detailed-steps)
5. [Verifying the Build](#verifying-the-build)
6. [Building the Android App](#building-the-android-app)
7. [Troubleshooting](#troubleshooting)
8. [Common Issues](#common-issues)

---

## Why This Is Needed

When integrating a Flutter module into an existing Android app (add-to-app), Flutter needs to generate native Android artifacts that the Android build system can use. These artifacts include:

- **AAR (Android Archive)** files containing compiled Flutter engine
- **Native libraries** (libflutter.so) for different CPU architectures
- **Dart code** compiled to kernel_blob.bin
- **Flutter assets** (fonts, images, etc.)
- **Gradle build configuration** for the Flutter module

Without these artifacts, the Android app cannot:
- Include the Flutter engine in the APK
- Render Flutter UI
- Execute Dart code
- Use Flutter features

The error message "this build does not include the embedded Flutter module" appears when these artifacts are missing.

---

## Prerequisites

### Required Software

1. **Flutter SDK** (version 3.10.0 or higher)
   ```bash
   # Check if Flutter is installed
   flutter --version
   ```

2. **Android SDK** with API level 35
   ```bash
   # Set Android SDK path if needed
   export ANDROID_HOME=/path/to/android/sdk
   export ANDROID_SDK_ROOT=$ANDROID_HOME
   ```

3. **Java Development Kit (JDK) 17**
   ```bash
   java -version
   ```

4. **Git** (for fetching the fl_nodes dependency)
   ```bash
   git --version
   ```

### Required Permissions

- Write access to the `flutter_workflow_editor` directory
- Network access to:
  - GitHub (for fl_nodes package)
  - Maven Central (for Flutter dependencies)
  - pub.dev (for Flutter packages)

---

## Quick Start

### For Development (Debug Build)

```bash
cd flutter_workflow_editor
flutter pub get
flutter build aar --debug
cd ..
./gradlew clean assembleDebug
```

### For Production (Release Build)

```bash
cd flutter_workflow_editor
flutter pub get
flutter build aar --release
cd ..
./gradlew clean assembleRelease
```

---

## Detailed Steps

### Step 1: Navigate to Flutter Module

```bash
cd /home/engine/project/flutter_workflow_editor
```

### Step 2: Install Flutter Dependencies

```bash
flutter pub get
```

**Expected Output:**
```
Resolving dependencies...
  fl_nodes 1.0.0 from git https://github.com/WilliamKarolDiCioccio/fl_nodes.git at main
  flutter 0.0.0 from sdk flutter
  ...
Got dependencies!
```

**What This Does:**
- Downloads Flutter packages from pub.dev
- Fetches the fl_nodes package from GitHub
- Creates `.dart_tool/package_config.json` with dependency information

### Step 3: Generate JSON Serialization Code (Optional but Recommended)

If your Dart code uses `@JsonSerializable` annotations:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**What This Does:**
- Generates `*.g.dart` files for JSON serialization
- Creates `*.freezed.dart` files if using freezed package
- Required for models in `lib/models/`

**Expected Output:**
```
[INFO] Generating build script...
[INFO] Generating build script completed, took 2.3s
[INFO] Initializing inputs
[INFO] Building new asset graph...
[INFO] Building new asset graph completed, took 1.5s
[INFO] Build completed!
```

### Step 4: Build Flutter Android Artifacts

#### Option A: Debug Build (Faster, larger APK)

```bash
flutter build aar --debug
```

#### Option B: Release Build (Smaller, optimized APK)

```bash
flutter build aar --release
```

#### Option C: Profile Build (For performance profiling)

```bash
flutter build aar --profile
```

**What This Does:**
1. Compiles Dart code to native machine code (AOT)
2. Packages Flutter engine for Android (libflutter.so)
3. Creates AAR files for each build variant
4. Generates the `.android/Flutter` directory structure

**Expected Output:**
```
Building plugin fl_nodes...
Building plugin flutter_svg...
Building plugin provider...
...
Running Gradle task 'assembleDebug'...                 

Successfully built 2 AAR files.
Debug AAR:     build/host/outputs/repo/com/blurr/workflow_editor/flutter_debug/1.0.0/flutter_debug-1.0.0.aar
Release AAR:   build/host/outputs/repo/com/blurr/workflow_editor/flutter_release/1.0.0/flutter_release-1.0.0.aar

To embed these build artifacts into your host app, add the following to your app's build.gradle:

android {
    compileOptions {
        sourceCompatibility = 1.8
        targetCompatibility = 1.8
    }
}

dependencies {
    debugImplementation 'com.blurr.workflow_editor:flutter_debug:1.0.0'
    releaseImplementation 'com.blurr.workflow_editor:flutter_release:1.0.0'
}
```

### Step 5: Verify Generated Files

```bash
ls -la .android/Flutter/
```

**Expected Output:**
```
total 64
drwxr-xr-x  5 user user  4096 Jan  1 12:00 .
drwxr-xr-x 10 user user  4096 Jan  1 12:00 ..
-rw-r--r--  1 user user  1000 Jan  1 12:00 build.gradle
-rw-r--r--  1 user user   300 Jan  1 12:00 settings.gradle
drwxr-xr-x  2 user user  4096 Jan  1 12:00 src
drwxr-xr-x  2 user user  4096 Jan  1 12:00 libs
```

Check for AAR files:
```bash
find build/host/outputs/repo -name "*.aar"
```

**Expected Output:**
```
build/host/outputs/repo/com/blurr/workflow_editor/flutter_debug/1.0.0/flutter_debug-1.0.0.aar
build/host/outputs/repo/com/blurr/workflow_editor/flutter_release/1.0.0/flutter_release-1.0.0.aar
```

### Step 6: Verify Android Project Integration

Check that the module will be included:

```bash
cd /home/engine/project
./gradlew projects | grep flutter
```

**Expected Output:**
```
Root project 'blurr'
+--- Project ':app'
+--- Project ':flutter_stubs'
+--- Project ':flutter_workflow_editor'
```

If you don't see `:flutter_workflow_editor`, check the settings.gradle.kts error messages:
```bash
./gradlew projects 2>&1 | grep -i flutter
```

---

## Verifying the Build

### 1. Check Gradle Sync

```bash
./gradlew :flutter_workflow_editor:tasks --all
```

This should list all available tasks for the Flutter module.

### 2. Check Dependencies

```bash
./gradlew :app:dependencies | grep flutter
```

**Expected Output:**
```
+--- project :flutter_workflow_editor
|    +--- io.flutter:flutter_embedding_debug:1.0.0-*
|    +--- io.flutter:flutter_embedding_release:1.0.0-*
|    +--- io.flutter:armeabi_v7a_debug:1.0.0-*
|    +--- io.flutter:armeabi_v7a_release:1.0.0-*
|    +--- io.flutter:arm64_v8a_debug:1.0.0-*
|    +--- io.flutter:arm64_v8a_release:1.0.0-*
|    +--- io.flutter:x86_64_debug:1.0.0-*
|    +--- io.flutter:x86_64_release:1.0.0-*
```

### 3. Check Flutter Runtime Detection

The `FlutterRuntime.isAvailable()` check should now pass:

```kotlin
// In FlutterRuntime.kt
fun isAvailable(): Boolean {
    return runCatching {
        Class.forName("io.flutter.embedding.engine.loader.FlutterLoader")
    }.isSuccess
    // Should return true after artifacts are generated
}
```

---

## Building the Android App

### Debug Build

```bash
cd /home/engine/project
./gradlew clean assembleDebug
```

### Release Build

```bash
cd /home/engine/project
./gradlew clean assembleRelease
```

### Install on Device

```bash
# Install debug APK
adb install -r app/build/outputs/apk/debug/app-debug.apk

# Or install release APK
adb install -r app/build/outputs/apk/release/app-release.apk
```

### Test the Flutter Module

1. Open the Blurr app
2. Navigate to Settings
3. Click "Workflow Editor" button
4. **Expected Result:** Flutter workflow editor should open with full UI

If you see the error screen instead, the artifacts were not generated correctly or the module is not being included in the build.

---

## Troubleshooting

### Issue: "flutter: command not found"

**Cause:** Flutter SDK is not installed or not in PATH

**Solution:**
```bash
# Install Flutter (Linux)
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

### Issue: "No .android directory generated"

**Cause:** `flutter build aar` command failed or was not run

**Solution:**
1. Run `flutter clean` in the flutter_workflow_editor directory
2. Run `flutter pub get` again
3. Run `flutter build aar --debug`
4. Check the output for errors

### Issue: "Module :flutter_workflow_editor not found"

**Cause:** The .android/Flutter directory doesn't exist, so settings.gradle.kts skips it

**Solution:**
1. Check if directory exists: `ls -la flutter_workflow_editor/.android/`
2. If not, re-run `flutter build aar`
3. Check settings.gradle.kts console output for messages

### Issue: "Build failed: Could not find fl_nodes"

**Cause:** Cannot fetch the fl_nodes package from GitHub

**Solution:**
```bash
# Test git access
git ls-remote https://github.com/WilliamKarolDiCioccio/fl_nodes.git

# If blocked, configure git proxy or SSH
git config --global http.proxy http://proxy.example.com:8080
```

### Issue: "Dart compilation error"

**Cause:** Missing generated files or syntax errors

**Solution:**
```bash
# Regenerate code
flutter pub run build_runner build --delete-conflicting-outputs

# Check for errors
flutter analyze
```

### Issue: "Out of memory during build"

**Cause:** Flutter build needs more heap memory

**Solution:**
```bash
# Increase Gradle heap
export GRADLE_OPTS="-Xmx4g -XX:MaxPermSize=512m"

# Then build
flutter build aar
```

### Issue: "App crashes when opening workflow editor"

**Cause:** Method channel mismatch or missing dependencies

**Solution:**
1. Check logs: `adb logcat | grep -i flutter`
2. Verify channel name matches in Dart and Kotlin
3. Ensure WorkflowEditorHandler is registered in MainActivity

### Issue: "Flutter stubs used instead of real module"

**Cause:** flutter_stubs dependency is taking precedence

**Solution:**
In `app/build.gradle.kts`, verify the dependency order:
```kotlin
dependencies {
    // Real Flutter module (should be first)
    implementation(project(":flutter_workflow_editor"))
    
    // Only use stubs if Flutter module is not available
    // implementation(project(":flutter_stubs"))
}
```

---

## Common Issues and Solutions

### Build Configuration Issues

#### 1. API Version Mismatch

**Error:** `compileSdkVersion is not available`

**Solution:**
Ensure `flutter_workflow_editor/.android/Flutter/build.gradle` matches your Android SDK:
```kotlin
android {
    compileSdkVersion 35  // Must match your project
    defaultConfig {
        minSdkVersion 24
        targetSdkVersion 35
    }
}
```

#### 2. Java Version Mismatch

**Error:** `Unsupported class file major version`

**Solution:**
```bash
# Set Java 17
export JAVA_HOME=/path/to/java-17
java -version  # Should show 17.x.x

# Then rebuild
flutter clean
flutter build aar
```

#### 3. Gradle Version Issues

**Error:** `Gradle version X is required`

**Solution:**
The Gradle wrapper version is managed by Flutter. If you need to update:
```bash
cd flutter_workflow_editor/.android
./gradlew wrapper --gradle-version=8.0
```

### Dependency Issues

#### 4. Duplicate Classes

**Error:** `Duplicate class io.flutter.embedding.*`

**Cause:** Both flutter_stubs and real Flutter module included

**Solution:**
Remove flutter_stubs from dependencies in `app/build.gradle.kts`:
```kotlin
dependencies {
    // Remove this line:
    // implementation(project(":flutter_stubs"))
    
    // Keep this:
    implementation(project(":flutter_workflow_editor"))
}
```

#### 5. Missing Native Libraries

**Error:** `java.lang.UnsatisfiedLinkError: dlopen failed: library "libflutter.so" not found`

**Cause:** AAR files don't contain native libraries

**Solution:**
Rebuild with proper architecture:
```bash
flutter build aar --release
# Ensure you have arm64-v8a, armeabi-v7a, x86_64
```

### Runtime Issues

#### 6. "Flutter engine not available" Error

**Cause:** FlutterLoader class not found (same as original issue)

**Solution:**
1. Verify artifacts were built: `find flutter_workflow_editor -name "*.aar"`
2. Verify module included: `./gradlew projects | grep flutter`
3. Clean rebuild: `./gradlew clean assembleDebug`

#### 7. Method Channel Not Found

**Error:** `MissingMethodException: No method found 'methodName'`

**Cause:** Channel name mismatch

**Solution:**
Check these match exactly:
- Dart: `const channel = MethodChannel('workflow_editor');`
- Kotlin: `MethodChannel(messenger, "workflow_editor")`

---

## Advanced Options

### Generating Specific Architectures Only

```bash
# Only arm64-v8a (most devices)
flutter build aar --release --target-platform android-arm64

# Only x86_64 (emulators)
flutter build aar --release --target-platform android-x64

# Multiple architectures
flutter build aar --release \
  --target-platform android-arm64,android-x64,android-arm
```

### Custom Build Configurations

To customize build settings, edit:
`flutter_workflow_editor/.android/Flutter/build.gradle`

```kotlin
android {
    compileSdkVersion 35
    
    defaultConfig {
        minSdkVersion 24
        targetSdkVersion 35
        versionCode 1
        versionName "1.0.0"
    }
    
    buildTypes {
        release {
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt')
        }
    }
}
```

### Split APKs for Smaller Downloads

In your app's `build.gradle.kts`:
```kotlin
android {
    splits {
        abi {
            enable true
            reset()
            include 'arm64-v8a', 'armeabi-v7a', 'x86_64'
            universalApk false
        }
    }
}
```

---

## Maintenance

### When to Regenerate Artifacts

You need to regenerate Flutter artifacts when:

1. **Flutter code changes**
   - Modified any .dart files in `lib/`
   - Added/removed dependencies in `pubspec.yaml`

2. **Platform channel changes**
   - Added new methods to WorkflowEditorHandler
   - Changed method signatures

3. **Flutter version changes**
   - Upgraded Flutter SDK
   - Changed Flutter channel (stable, beta, dev)

4. **Dependency updates**
   - Updated fl_nodes package
   - Updated other Flutter packages

### Regeneration Workflow

```bash
# Navigate to Flutter module
cd flutter_workflow_editor

# Clean previous builds
flutter clean

# Get latest dependencies
flutter pub get

# Regenerate code (if needed)
flutter pub run build_runner build --delete-conflicting-outputs

# Build artifacts
flutter build aar --release

# Rebuild Android app
cd ..
./gradlew clean assembleRelease
```

---

## Verification Checklist

Before testing, verify:

- [ ] `flutter_workflow_editor/.android/Flutter/` directory exists
- [ ] AAR files exist in `build/host/outputs/repo/`
- [ ] Gradle projects list includes `:flutter_workflow_editor`
- [ ] App dependencies show `project :flutter_workflow_editor`
- [ ] No compilation errors in Android build
- [ ] APK size increased by ~15-20 MB (Flutter engine + Dart code)
- [ ] `FlutterRuntime.isAvailable()` returns `true`

---

## Getting Help

If you encounter issues not covered here:

1. **Check Flutter documentation:**
   - https://docs.flutter.dev/add-to-app/android/project-setup
   - https://docs.flutter.dev/deployment/android

2. **Check Gradle logs:**
   ```bash
   ./gradlew clean assembleDebug --stacktrace --info
   ```

3. **Check Flutter logs:**
   ```bash
   flutter build aar --verbose
   ```

4. **Check device logs:**
   ```bash
   adb logcat | grep -E "(Flutter|Blurr|WorkflowEditor)"
   ```

---

## Summary

1. **Run `flutter pub get`** to install dependencies
2. **Run `flutter build aar --debug`** (or `--release`) to generate artifacts
3. **Verify** `.android/Flutter/` directory was created
4. **Rebuild** Android app with `./gradlew clean assembleDebug`
5. **Test** by opening the workflow editor in the app

The generated artifacts will be automatically included in your Android app's build, eliminating the "this build does not include the embedded Flutter module" error.

---

**Note:** This process only needs to be run once when setting up the project, or whenever you modify the Flutter code or dependencies. For day-to-day development, you can rely on the Gradle build system to pick up changes.

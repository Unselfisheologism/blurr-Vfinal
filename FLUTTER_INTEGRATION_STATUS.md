# Flutter Module Integration Status

## Status

✅ **Gradle integration is configured**.

- The Android app will use the **real Flutter module** when the Flutter-generated Android project exists at `flutter_workflow_editor/.android/Flutter`.
- If that directory is not present (or Flutter hasn’t been set up on the build machine yet), the app will **fall back to** `:flutter_stubs` so the project can still compile.

This makes the repo buildable in environments without Flutter, while still enabling full Flutter functionality once you generate the Flutter artifacts.

---

## What’s in the repo

### Android side
- `settings.gradle.kts` conditionally includes `:flutter_workflow_editor` **only when** `flutter_workflow_editor/.android/Flutter` exists.
- `app/build.gradle.kts` conditionally depends on:
  - `implementation(project(":flutter_workflow_editor"))` when present
  - otherwise `implementation(project(":flutter_stubs"))`

### Flutter side
- `flutter_workflow_editor/` contains the real Flutter module Dart code (`lib/` + `pubspec.yaml`).

---

## Enable AI-native apps with real Flutter UI

### Step 1: Install Flutter SDK (on the build machine)
Install Flutter (stable) and confirm it works:

```bash
flutter doctor
```

### Step 2: Generate Flutter Android artifacts
From the repo root:

```bash
cd flutter_workflow_editor
flutter pub get
flutter build aar --release
```

After this, you should have:
- `flutter_workflow_editor/.android/Flutter/` (Gradle project used by the host Android build)
- A local Maven repo under `flutter_workflow_editor/build/host/outputs/repo/` (AAR outputs)

### Step 3: Build the Android app
From the repo root:

```bash
./gradlew clean
./gradlew assembleDebug
# or
./gradlew assembleRelease
```

### Step 4: Install + test
```bash
adb install app/build/outputs/apk/debug/app-debug.apk
```

---

## Runtime behavior

- Without Flutter artifacts: AI-native apps will show the "Flutter not embedded" error screen (expected), because `FlutterRuntime.isAvailable()` will be `false`.
- After generating artifacts + rebuilding: Flutter classes (including `FlutterLoader`) are present and the Flutter-based editors should open normally.

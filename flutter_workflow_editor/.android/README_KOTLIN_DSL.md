# Flutter workflow editor Android submodule
# This directory contains the Android integration for the Flutter workflow editor

The following files have been converted from Groovy to Kotlin DSL for better compatibility:
- build.gradle -> build.gradle.kts
- settings.gradle -> settings.gradle.kts
- Flutter/build.gradle -> Flutter/build.gradle.kts

Original files have been backed up with .backup extension.

## Configuration Requirements

The `local.properties` file must contain a valid `flutter.sdk` path pointing to your Flutter SDK installation.

Example:
```
flutter.sdk=/usr/local/flutter
```

## Build Notes

1. The Flutter module uses the Flutter Gradle plugin which is applied at runtime
2. The module generates an Android library that can be included in the host app
3. The plugin applies the Flutter tooling gradle script from the Flutter SDK

## Troubleshooting

If you encounter build errors related to Flutter:
1. Ensure Flutter SDK is properly installed
2. Verify the path in local.properties is correct
3. Run `flutter pub get` in the flutter_workflow_editor directory to generate dependencies

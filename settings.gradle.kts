pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        maven("https://jitpack.io")
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
        maven("https://jitpack.io")
    }
}

rootProject.name = "blurr"
include(":app")
include(":flutter_stubs")

// Flutter module integration
// NOTE: flutter_workflow_editor is not included because the Flutter SDK
// and proper AAR artifacts are not available in this environment.
// 
// To enable Flutter integration:
// 1. Install Flutter SDK: https://flutter.dev/docs/get-started/install
// 2. cd flutter_workflow_editor && flutter pub get && flutter build aar --release
// 3. This will create .android/Flutter directory with proper Gradle files
// 4. Then uncomment the code below to include the Flutter module:
//
// val flutterProjectDir = file("flutter_workflow_editor")
// if (flutterProjectDir.isDirectory) {
//     val flutterAndroidPath = File(flutterProjectDir, ".android/Flutter")
//     if (flutterAndroidPath.isDirectory) {
//         include(":flutter_workflow_editor")
//         project(":flutter_workflow_editor").projectDir = flutterAndroidPath
//         println("✓ Flutter module included from: ${flutterAndroidPath.absolutePath}")
//     } else {
//         println("ℹ Flutter artifacts not found at: ${flutterAndroidPath.absolutePath}")
//         println("  Using flutter_stubs for compilation.")
//     }
// } else {
//     println("ℹ flutter_workflow_editor directory not found, using flutter_stubs.")
// }

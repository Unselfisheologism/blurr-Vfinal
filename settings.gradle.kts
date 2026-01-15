pluginManagement {
    val flutterSdkPath = System.getenv("FLUTTER_ROOT") ?: System.getenv("FLUTTER_HOME") ?: run {
        val properties = java.util.Properties()
        val propertiesFile = file("local.properties")
        if (propertiesFile.exists()) {
            propertiesFile.inputStream().use { properties.load(it) }
        }
        properties.getProperty("flutter.sdk")
    }

    if (flutterSdkPath != null) {
        val flutterPluginPath = file("$flutterSdkPath/packages/flutter_tools/gradle")
        if (flutterPluginPath.exists()) {
            includeBuild(flutterPluginPath)
        }
    }

    repositories {
        // Prioritize Google's Maven repository first - it has Kotlin and Android artifacts cached
        google()

        // Flutter engine artifacts (io.flutter:*), required when building the Flutter module as a Gradle subproject
        maven("https://storage.googleapis.com/download.flutter.io")

        gradlePluginPortal()
        // Maven Central as fallback - repository order ensures Google's Maven is checked first
        mavenCentral()
        maven("https://jitpack.io")
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        // Google's Maven is the primary source for all Kotlin and Android dependencies
        google()

        // Flutter engine artifacts (io.flutter:*), required for :flutter_workflow_editor dependency resolution
        maven("https://storage.googleapis.com/download.flutter.io")

        maven("https://jitpack.io")

        // Maven Central as fallback - repository order ensures Google's Maven is checked first
        mavenCentral()

        // Chaquo Maven for Python integration
        maven("https://chaquo.com/maven")
    }
}

rootProject.name = "blurr"
include(":app")
include(":flutter_stubs")

// Flutter module integration
//
// Only include the real Flutter module if a Flutter SDK is configured for this build.
// This keeps local/CI builds without Flutter working via :flutter_stubs.
//
// We include the Flutter module's Android library project (".android/Flutter").
// The sibling ".android/app" project is just a generated host app used by the Flutter tool
// and is not suitable to be depended on by our Android app module.
val flutterProjectDir = file("flutter_workflow_editor")
val flutterAndroidProjectDir = File(flutterProjectDir, ".android/Flutter")
val flutterPluginsDependenciesFile = File(flutterProjectDir, ".flutter-plugins-dependencies")

val flutterSdkPathForModule = System.getenv("FLUTTER_ROOT")
    ?: System.getenv("FLUTTER_HOME")
    ?: run {
        val properties = java.util.Properties()
        val propertiesFile = file("local.properties")
        if (propertiesFile.exists()) {
            propertiesFile.inputStream().use { properties.load(it) }
        }
        properties.getProperty("flutter.sdk")
    }

val flutterGradlePluginDir = flutterSdkPathForModule?.let { File(it, "packages/flutter_tools/gradle") }

// Include the Flutter module only when Flutter SDK is available and the Flutter module
// has been prepared (at minimum: `flutter pub get`, which generates .flutter-plugins-dependencies).
// Otherwise fall back to :flutter_stubs so Android-only builds can still compile.
if (flutterGradlePluginDir != null
    && flutterGradlePluginDir.exists()
    && flutterAndroidProjectDir.exists()
    && flutterPluginsDependenciesFile.exists()
) {
    include(":flutter_workflow_editor")
    project(":flutter_workflow_editor").projectDir = flutterAndroidProjectDir

    // Enforce Gradle 8+ evaluation order: ensure :flutter_workflow_editor is evaluated
    // before :app. The Flutter Gradle plugin wires projects together using afterEvaluate
    // callbacks and will fail if the host app finishes evaluation too early.
    gradle.beforeProject {
        if (project.name == "app") {
            evaluationDependsOn(":flutter_workflow_editor")
        }
    }
}

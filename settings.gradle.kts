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
        // Prioritize Google's Maven repository first
        google()

        // Flutter engine artifacts (io.flutter:*), required when building the Flutter module as a Gradle subproject
        maven("https://storage.googleapis.com/download.flutter.io")

        gradlePluginPortal()
        // Use Maven Central but prioritize Google's repository
        mavenCentral()
        maven("https://jitpack.io")
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        // Prioritize Google's Maven repository first
        google()

        // Flutter engine artifacts (io.flutter:*), required for :flutter_workflow_editor dependency resolution
        maven("https://storage.googleapis.com/download.flutter.io")
        
        // Add Maven Central with proper configuration
        mavenCentral {
            content {
                includeGroup("org.jetbrains.kotlin")
                includeGroup("org.jetbrains.kotlinx")
                includeGroup("com.squareup")
                includeGroup("org.ow2.asm")
            }
        }
        
        maven("https://jitpack.io")
        
        // Add additional mirrors for reliability
        maven("https://maven.google.com")
        maven("https://repo1.maven.org/maven2")
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
// We point Gradle at the Flutter module's Android library project (".android/app").
// The ".android/Flutter" directory is an artifact of AAR generation and can contain a
// GeneratedPluginRegistrant.java that references plugins not on the classpath when used as
// a standalone Gradle project. We exclude it and let the Flutter Gradle plugin handle
// plugin registration internally through the :flutter_workflow_editor project.
val flutterProjectDir = file("flutter_workflow_editor")
val flutterAndroidProjectDir = File(flutterProjectDir, ".android")

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

// Include only the Android wrapper project (.android/app). The Flutter Gradle plugin
// handles all Flutter integration internally without needing to compile the
// .android/Flutter subproject separately.
//
// If the Android wrapper project is missing,
// skip including the real module and fall back to :flutter_stubs.
// This ensures the build doesn't fail if "flutter pub get" hasn't been run yet.
if (flutterGradlePluginDir != null
    && flutterGradlePluginDir.exists()
    && flutterAndroidProjectDir.exists()
) {
    include(":flutter_workflow_editor")
    project(":flutter_workflow_editor").projectDir = flutterAndroidProjectDir

    // Enforce Gradle 8+ evaluation order: ensure :flutter_workflow_editor is evaluated
    // before :app. The Flutter Gradle plugin registers afterEvaluate callbacks that need
    // to execute in a specific order. Without this enforcement, :app can be evaluated
    // before :flutter_workflow_editor, causing the Flutter plugin to fail with
    // "Project with path ':flutter' could not be found in project ':flutter_workflow_editor'"
    gradle.beforeProject {
        if (project.name == "app") {
            evaluationDependsOn(":flutter_workflow_editor")
        }
    }
}

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
// When Flutter artifacts are generated with `flutter build aar`, this will automatically
// include the flutter_workflow_editor module for full Flutter functionality
val flutterProjectDir = file("flutter_workflow_editor")
if (flutterProjectDir.isDirectory) {
    val flutterAndroidPath = File(flutterProjectDir, ".android/Flutter")
    if (flutterAndroidPath.isDirectory) {
        include(":flutter_workflow_editor")
        project(":flutter_workflow_editor").projectDir = flutterAndroidPath
        println("✓ Flutter module included from: ${flutterAndroidPath.absolutePath}")
    } else {
        // Flutter stubs are used when artifacts aren't generated
        println("ℹ Flutter artifacts not found at: ${flutterAndroidPath.absolutePath}")
        println("  Using flutter_stubs for compilation. Run 'flutter build aar' in flutter_workflow_editor to enable Flutter features.")
    }
} else {
    println("ℹ flutter_workflow_editor directory not found, using flutter_stubs.")
}
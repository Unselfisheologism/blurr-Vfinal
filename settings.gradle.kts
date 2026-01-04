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
val flutterProjectDir = file("flutter_workflow_editor")
val androidProjectPath = if (File(flutterProjectDir, ".android/Flutter").exists()) {
    File(flutterProjectDir, ".android/Flutter")
} else {
    File(flutterProjectDir, ".android/app")
}
include(":flutter_workflow_editor")
project(":flutter_workflow_editor").projectDir = androidProjectPath

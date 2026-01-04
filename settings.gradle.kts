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
    }
}

rootProject.name = "blurr"
include(":app")
include(":flutter_stubs")

// Flutter module integration
val flutterProjectDir = file("flutter_workflow_editor")
val androidProjectPath = File(flutterProjectDir, ".android/Flutter")
include(":flutter_workflow_editor")
project(":flutter_workflow_editor").projectDir = androidProjectPath

pluginManagement {
    repositories {
        google {
            content {
                includeGroupByRegex("com\\.android.*")
                includeGroupByRegex("com\\.google.*")
                includeGroupByRegex("androidx.*")
            }
        }
        mavenCentral()
        gradlePluginPortal()
        maven("https://jitpack.io")
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        maven("https://jitpack.io")
    }
}

rootProject.name = "twent"
include(":app")

// Include the Flutter workflow editor module
val flutterProjectDir = file("flutter_workflow_editor")
if (flutterProjectDir.exists()) {
    val flutterAndroidDir = File(flutterProjectDir, ".android")
    if (flutterAndroidDir.exists()) {
        include(":flutter_workflow_editor")
        project(":flutter_workflow_editor").projectDir = flutterAndroidDir
    } else {
        println("Flutter workflow editor Android project not found at: ${flutterAndroidDir.absolutePath}")
        println("Skipping inclusion of flutter_workflow_editor module.")
    }
} else {
    println("Flutter workflow editor directory not found, skipping inclusion.")
}

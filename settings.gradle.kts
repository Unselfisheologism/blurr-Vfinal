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
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
        maven("https://jitpack.io")
    }
}

rootProject.name = "twent"
include(":app")

// Check if flutter_workflow_editor exists before including it
if (file("flutter_workflow_editor").exists()) {
    // Only include if the Flutter Android build directory exists
    val flutterProjectDir = file("flutter_workflow_editor")
    val androidProjectPath = File(flutterProjectDir, ".android/Flutter")
    
    if (androidProjectPath.exists()) {
        include(":flutter_workflow_editor")
        project(":flutter_workflow_editor").projectDir = androidProjectPath
    } else {
        println("Flutter workflow editor Android project not found at: ${'$'}{androidProjectPath.absolutePath}")
        println("Skipping inclusion of flutter_workflow_editor module.")
    }
} else {
    println("Flutter workflow editor directory not found, skipping inclusion.")
}
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
val flutterProjectDir = file("flutter_workflow_editor")
val androidProjectPath = File(flutterProjectDir, ".android/Flutter")
include(":flutter_workflow_editor")
project(":flutter_workflow_editor").projectDir = androidProjectPath

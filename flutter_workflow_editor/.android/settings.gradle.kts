// Generated file. Converted to Kotlin DSL

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "flutter_workflow_editor"

// Manually include the Flutter module instead of using the Groovy script
include(":flutter")
project(":flutter").projectDir = File(rootDir, "Flutter")

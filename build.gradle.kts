// Top-level build file where you can add configuration options common to all sub-projects/modules.
buildscript {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://chaquo.com/maven") }
        maven { url = uri("https://maven.google.com") }
    }
    dependencies {
        classpath("com.chaquo.python:gradle:17.0.0")
    }
}

plugins {
    alias(libs.plugins.android.application) apply false
    alias(libs.plugins.kotlin.android) apply false
    alias(libs.plugins.kotlin.compose) apply false
}

// Work around Gradle 8+ strict lifecycle checks:
// The Flutter Gradle plugin may register `afterEvaluate` callbacks on the Android app project.
// If the app project is evaluated before the Flutter module project, Gradle throws:
// "Cannot run Project.afterEvaluate(Action) when the project is already evaluated."
//
// Ensuring the Flutter module is evaluated first keeps the plugin's configuration safe.
gradle.beforeProject {
    if (path == ":app") {
        evaluationDependsOn(":flutter_workflow_editor")
    }
}

// allprojects {
//     repositories {
//         google()
//         mavenCentral()
//         maven { url = uri("https://chaquo.com/maven") }
//     }
// }

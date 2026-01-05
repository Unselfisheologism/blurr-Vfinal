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
//
// The Flutter Gradle plugin wires together the Flutter module project (:flutter_workflow_editor)
// and the host app (:app). Internally it uses `afterEvaluate` callbacks.
//
// Gradle 8+ throws if a plugin tries to register an `afterEvaluate` callback on a project that
// has already finished evaluation:
// "Cannot run Project.afterEvaluate(Action) when the project is already evaluated."
//
// Ensure the Flutter module is evaluated before the host app to keep the plugin
// configuration lifecycle-safe.
gradle.beforeProject {
    if (path == ":app" && rootProject.findProject(":flutter_workflow_editor") != null) {
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

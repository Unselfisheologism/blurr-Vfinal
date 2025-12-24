// Generated file. Converted to Kotlin DSL for compatibility

import java.io.File
import java.util.Properties

// Try to load Flutter SDK configuration
val localProperties = Properties()
val localPropertiesFile = rootProject.file(".android/local.properties")
var flutterRoot: String? = null
var useFlutterPlugin = false

if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { stream ->
        localProperties.load(stream)
    }
    flutterRoot = localProperties.getProperty("flutter.sdk")
    if (!flutterRoot.isNullOrEmpty() && File(flutterRoot).exists()) {
        useFlutterPlugin = true
        println("✅ Flutter SDK found at: $flutterRoot - Using full Flutter module")
    } else {
        println("⚠️  Flutter SDK not configured - Using stub Flutter module")
    }
} else {
    println("⚠️  local.properties not found - Using stub Flutter module")
}

val flutterVersionCode = localProperties.getProperty("flutter.versionCode") ?: "1"
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"

plugins {
    id("com.android.library")
}

// Only apply Flutter plugin if SDK is available
if (useFlutterPlugin) {
    apply(from = "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle")
}

group = "com.twent.workflow_editor"
version = "1.0"

android {
    namespace = "com.twent.workflow_editor"
    compileSdk = 35
    ndkVersion = "25.1.8937393"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    defaultConfig {
        minSdk = 24
        targetSdk = 35
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
    }

    buildFeatures {
        buildConfig = true
    }
}

// Only configure Flutter block if plugin is available
if (useFlutterPlugin) {
    try {
        // Use reflection to access Flutter extension
        val flutterExtension = project.extensions.findByName("flutter")
        if (flutterExtension != null) {
            val extensionClass = flutterExtension.javaClass
            val sourceMethod = extensionClass.getMethod("setSource", String::class.java)
            sourceMethod.invoke(flutterExtension, "../..")
            println("✅ Flutter source configured")
        }
    } catch (e: Exception) {
        println("⚠️  Could not configure Flutter extension: ${e.message}")
    }
}


import java.io.FileInputStream
import java.io.FileOutputStream
import java.util.Properties

plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.compose)
    alias(libs.plugins.ksp)
    id("org.jetbrains.kotlin.plugin.serialization") version "2.2.10"
    id("com.chaquo.python")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(FileInputStream(localPropertiesFile))
}

// Load version properties
val versionProps = Properties()
val versionPropsFile = rootProject.file("version.properties")
if (versionPropsFile.exists()) {
    versionProps.load(FileInputStream(versionPropsFile))
}

android {
    namespace = "com.twent.voice"
    compileSdk = 35

    // Phase 0: API keys now managed via BYOK Settings in the app
    val tavilyApiKeys = localProperties.getProperty("TAVILY_API") ?: ""
    val mem0ApiKey = localProperties.getProperty("MEM0_API") ?: ""
    val googlecloudGatewayURL = localProperties.getProperty("GCLOUD_GATEWAY_URL") ?: ""
    val googlecloudProxyURL = localProperties.getProperty("GCLOUD_PROXY_URL") ?: ""
    val googlecloudProxyURLKey = localProperties.getProperty("GCLOUD_PROXY_URL_KEY") ?: ""
    val revenueCatSDK = localProperties.getProperty("REVENUE_CAT_PUBLIC_URL") ?: ""
    val revenueCatApiKey = localProperties.getProperty("REVENUECAT_API_KEY") ?: ""
    val appwriteProjectId = localProperties.getProperty("APPWRITE_PROJECT_ID") ?: "67543c7001402067d7" // Default/Placeholder
    val appwriteDatabaseId = localProperties.getProperty("APPWRITE_DATABASE_ID") ?: "" // REQUIRED: set in local.properties
    val appwriteUsersCollectionId = localProperties.getProperty("APPWRITE_USERS_COLLECTION_ID") ?: "" // REQUIRED
    val appwriteTasksCollectionId = localProperties.getProperty("APPWRITE_TASKS_COLLECTION_ID") ?: "" // REQUIRED

    val debugSha1 = "D0:A1:49:03:FD:B5:37:DF:B5:36:51:B1:66:AE:70:11:E2:59:08:33"

    defaultConfig {
        applicationId = "com.twent.voice"
        minSdk = 24
        targetSdk = 35
        versionCode = versionProps.getProperty("VERSION_CODE", "13").toInt()
        versionName = versionProps.getProperty("VERSION_NAME", "1.0.13")

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"

        // Common build config fields - applies to all build types
         buildConfigField("String", "APPWRITE_DATABASE_ID", "\"$appwriteDatabaseId\"")
         buildConfigField("String", "APPWRITE_USERS_COLLECTION_ID", "\"$appwriteUsersCollectionId\"")
         buildConfigField("String", "APPWRITE_TASKS_COLLECTION_ID", "\"$appwriteTasksCollectionId\"")
        // Phase 0: Removed hard-coded API keys (GEMINI_API_KEYS, GOOGLE_TTS_API_KEY, PICOVOICE_ACCESS_KEY)
        buildConfigField("String", "TAVILY_API", "\"$tavilyApiKeys\"")
        buildConfigField("String", "MEM0_API", "\"$mem0ApiKey\"")
        buildConfigField("boolean", "ENABLE_DIRECT_APP_OPENING", "true")
        buildConfigField("boolean", "SPEAK_INSTRUCTIONS", "true")
        buildConfigField("String", "GCLOUD_GATEWAY_URL", "\"$googlecloudGatewayURL\"")
        buildConfigField("String", "GCLOUD_PROXY_URL", "\"$googlecloudProxyURL\"")
        buildConfigField("String", "GCLOUD_PROXY_URL_KEY", "\"$googlecloudProxyURLKey\"")
        buildConfigField("boolean", "ENABLE_LOGGING", "true")
        buildConfigField("String", "APPWRITE_PROJECT_ID", "\"$appwriteProjectId\"")
        
        // Chaquopy Python configuration
        ndk {
            abiFilters.addAll(listOf("armeabi-v7a", "arm64-v8a", "x86", "x86_64"))
        }
        
        // TODO: Chaquopy python DSL configuration - needs proper Kotlin DSL setup
        // Python configuration is handled by the Chaquopy plugin
        // For now, Python packages are installed at runtime via pip
        // Pre-installed packages: ffmpeg-python, Pillow, pypdf, python-pptx, python-docx, openpyxl, pandas, numpy, requests

    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            // Debug-specific field only
            buildConfigField("String", "SHA1_FINGERPRINT", "\"$debugSha1\"")
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = "11"
    }
    buildFeatures {
        compose = true
        viewBinding = true
        buildConfig = true
    }
}
val libsuVersion = "6.0.0"

dependencies {
    // Flutter workflow editor module - commented out since the module doesn't exist in expected location
    // implementation(project(":flutter_workflow_editor"))

    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.lifecycle.runtime.ktx)
    implementation(libs.androidx.activity.compose)
    implementation("androidx.activity:activity-ktx:1.8.2")
    implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:2.7.0")
    implementation(platform(libs.androidx.compose.bom))
    implementation(libs.androidx.ui)
    implementation(libs.androidx.ui.graphics)
    implementation(libs.androidx.ui.tooling.preview)
    implementation(libs.androidx.material3)
    implementation(libs.androidx.appcompat)
    // Phase 0: Removed Gemini SDK (now using BYOK with UniversalLLMService)
    // implementation(libs.generativeai)
    testImplementation(libs.junit)
    androidTestImplementation(libs.androidx.junit)
    androidTestImplementation(libs.androidx.espresso.core)
    androidTestImplementation(platform(libs.androidx.compose.bom))
    androidTestImplementation(libs.androidx.ui.test.junit4)
    debugImplementation(libs.androidx.ui.tooling)
    debugImplementation(libs.androidx.ui.test.manifest)
    implementation("com.google.android.material:material:1.11.0") // or latest

    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
    implementation("com.squareup.okhttp3:okhttp:5.0.0-alpha.16")
    implementation("com.squareup.moshi:moshi:1.15.0")
    implementation("com.google.code.gson:gson:2.13.1")
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.3")
    // https://mvnrepository.com/artifact/androidx.test.uiautomator/uiautomator
    implementation("androidx.test.uiautomator:uiautomator:2.3.0")

    // Porcupine Wake Word Engine - TODO: Remove after BYOK voice implementation
    // implementation("ai.picovoice:porcupine-android:3.0.2")
    
    // EncryptedSharedPreferences for secure key storage
    implementation("androidx.security:security-crypto:1.1.0-alpha06")
    
    // FFmpeg for Android (native binary for video/audio processing)
    implementation("com.arthenica:ffmpeg-kit-full:5.1")

    // Room database dependencies
    implementation("androidx.room:room-runtime:2.6.1")
    implementation("androidx.room:room-ktx:2.6.1")
    ksp("androidx.room:room-compiler:2.6.1")
    // Import the Firebase BoM

    // Add the dependency for the Firebase Authentication library
    // Add the dependency for the Google Play services library
    implementation(libs.play.services.auth)

    implementation("androidx.recyclerview:recyclerview:1.3.2")
    implementation("com.android.billingclient:billing-ktx:7.0.0")

    // Appwrite SDK - explicitly add platform dependency for OkHttp BOM to fix AGP 8.9.2 resolution
    implementation(platform("com.squareup.okhttp3:okhttp-bom:4.12.0"))
    implementation(libs.appwrite.sdk)
    
    // JavaScript execution engine (Phase 2: Story 4.12 - Multi-language shell)
    implementation("org.mozilla:rhino:1.7.14")
    
    // Google OAuth & APIs (Story 4.13-4.16 - Hybrid Integration Strategy)
    // FREE for unlimited users via user OAuth!
    implementation("com.google.android.gms:play-services-auth:20.7.0")
    implementation("com.google.api-client:google-api-client-android:2.2.0")
    implementation("com.google.http-client:google-http-client-gson:1.43.3")
    
    // Google Workspace APIs (Gmail, Calendar, Drive)
    implementation("com.google.apis:google-api-services-gmail:v1-rev20220404-2.0.0")
    implementation("com.google.apis:google-api-services-calendar:v3-rev20220715-2.0.0")
    implementation("com.google.apis:google-api-services-drive:v3-rev20220815-2.0.0")
    
    // JavaMail for Gmail MIME message creation (Story 4.15)
    implementation("com.sun.mail:android-mail:1.6.7")
    implementation("com.sun.mail:android-activation:1.6.7")
}

// Task to increment version for release builds
tasks.register("incrementVersion") {
    doLast {
        val versionFile = rootProject.file("version.properties")
        val props = Properties()
        props.load(FileInputStream(versionFile))

        val currentVersionCode = props.getProperty("VERSION_CODE").toInt()
        val currentVersionName = props.getProperty("VERSION_NAME")

        // Increment version code
        val newVersionCode = currentVersionCode + 1

        // Increment patch version in semantic versioning (x.y.z -> x.y.z+1)
        val versionParts = currentVersionName.split(".")
        val newPatchVersion = if (versionParts.size >= 3) {
            versionParts[2].toInt() + 1
        } else {
            1
        }
        val newVersionName = if (versionParts.size >= 2) {
            "${versionParts[0]}.${versionParts[1]}.$newPatchVersion"
        } else {
            "1.0.$newPatchVersion"
        }

        // Update properties
        props.setProperty("VERSION_CODE", newVersionCode.toString())
        props.setProperty("VERSION_NAME", newVersionName)

        // Save back to file with comments
        val output = FileOutputStream(versionFile)
        output.use { fileOutput ->
            fileOutput.write("# Version configuration for Twent Android App\n".toByteArray())
            fileOutput.write("# This file is automatically updated during release builds\n".toByteArray())
            fileOutput.write("# Do not modify manually - use Gradle tasks to update versions\n\n".toByteArray())
            fileOutput.write("# Current version code (integer - increments by 1 each release)\n".toByteArray())
            fileOutput.write("VERSION_CODE=$newVersionCode\n\n".toByteArray())
            fileOutput.write("# Current version name (semantic version - increments patch number each release)\n".toByteArray())
            fileOutput.write("VERSION_NAME=$newVersionName".toByteArray())
        }

        println("Version incremented to: versionCode=$newVersionCode, versionName=$newVersionName")
    }
}

// Make release builds automatically increment version
tasks.whenTaskAdded {
    if (name == "assembleRelease" || name == "bundleRelease") {
        dependsOn("incrementVersion")
    }
}
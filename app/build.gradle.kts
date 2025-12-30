import java.util.Properties
import java.io.FileInputStream
import java.io.FileOutputStream

plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.compose)
    alias(libs.plugins.ksp)
    id("org.jetbrains.kotlin.plugin.serialization") version "2.1.0"
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
    namespace = "com.blurr.voice"
    compileSdk = 35

    val debugSha1 = "D0:A1:49:03:FD:B5:37:DF:B5:36:51:B1:66:AE:70:11:E2:59:08:33"

    defaultConfig {
        applicationId = "com.blurr.voice"
        minSdk = 24
        targetSdk = 35
        versionCode = versionProps.getProperty("VERSION_CODE", "13").toInt()
        versionName = versionProps.getProperty("VERSION_NAME", "1.0.13")

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        
        // Common build config fields - applies to all build types
        
        buildConfigField("boolean", "ENABLE_DIRECT_APP_OPENING", "true")

        buildConfigField("boolean", "SPEAK_INSTRUCTIONS", "true")

        // Appwrite configuration
        buildConfigField("String", "APPWRITE_PUBLIC_ENDPOINT", "\"https://cloud.appwrite.io/v1\"")
        buildConfigField("String", "APPWRITE_PROJECT_ID", "\"blurr\"")
        buildConfigField("String", "APPWRITE_DATABASE_ID", "\"blurr-db\"")
        buildConfigField("String", "APPWRITE_USERS_COLLECTION_ID", "\"users\"")
        buildConfigField("String", "APPWRITE_CONVERSATIONS_COLLECTION_ID", "\"conversations\"")
        buildConfigField("String", "APPWRITE_WORKFLOWS_COLLECTION_ID", "\"workflows\"")
        buildConfigField("boolean", "DEBUG", "true")

        buildConfigField("boolean", "ENABLE_LOGGING", "true")

        // Legacy proxy configuration (now unused but kept for compatibility)
        buildConfigField("String", "GCLOUD_PROXY_URL", "\"\"")
        buildConfigField("String", "GCLOUD_PROXY_URL_KEY", "\"\"")

    }

    signingConfigs {
        create("release") {
            storeFile = file("../keystore.jks")
            storePassword = System.getenv("SIGNING_PASSWORD") ?: ""
            keyAlias = System.getenv("KEY_ALIAS") ?: ""
            keyPassword = System.getenv("KEY_PASSWORD") ?: ""
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("release")
        }
        debug {
            // Debug-specific field only
            buildConfigField("String", "SHA1_FINGERPRINT", "\"$debugSha1\"")
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }
    buildFeatures {
        compose = true
        viewBinding = true
        buildConfig = true
    }
    lint {
        disable.add("NullSafeMutableLiveData")
    }
}

val libsuVersion = "6.0.0"

dependencies {

    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.lifecycle.runtime.ktx)
    implementation(libs.androidx.activity.compose)
    implementation(platform(libs.androidx.compose.bom))
    implementation(libs.androidx.ui)
    implementation(libs.androidx.ui.graphics)
    implementation(libs.androidx.ui.tooling.preview)
    implementation(libs.androidx.material3)
    implementation(libs.androidx.appcompat)
    
    testImplementation(libs.junit)
    androidTestImplementation(libs.androidx.junit)
    androidTestImplementation(libs.androidx.espresso.core)
    androidTestImplementation(platform(libs.androidx.compose.bom))
    androidTestImplementation(libs.androidx.ui.test.junit4)
    debugImplementation(libs.androidx.ui.tooling)
    debugImplementation(libs.androidx.ui.test.manifest)
    implementation("com.google.android.material:material:1.11.0") // or latest

    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
    implementation("com.squareup.moshi:moshi:1.15.0")
    implementation("com.google.code.gson:gson:2.13.1")
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.3")
    // https://mvnrepository.com/artifact/androidx.test.uiautomator/uiautomator
    implementation("androidx.test.uiautomator:uiautomator:2.3.0")

    // Remove Browser dependency for CustomTabsIntent since we're using popup WebView
    // implementation("androidx.browser:browser:1.8.0")
    
    // Appwrite SDK for backend services
    implementation(libs.appwrite.sdk) {
        exclude(group = "com.squareup.okhttp3", module = "okhttp-bom")
    }
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
    implementation("com.squareup.okhttp3:logging-interceptor:4.12.0")
    
    // Google Sign-In for OAuth authentication
    implementation(libs.play.services.auth)
    implementation(libs.play.services.basement)
    
    // Firebase for analytics and auth
    implementation(platform("com.google.firebase:firebase-bom:33.7.0"))
    implementation("com.google.firebase:firebase-analytics-ktx")
    implementation("com.google.firebase:firebase-auth-ktx")
    
    // Google Play Billing
    implementation("com.android.billingclient:billing:6.2.0")
    implementation("com.android.billingclient:billing-ktx:6.2.0")
    
    // Room database dependencies
    implementation("androidx.room:room-runtime:2.6.1")
    implementation("androidx.room:room-ktx:2.6.1")
    ksp("androidx.room:room-compiler:2.6.1")
    implementation("androidx.recyclerview:recyclerview:1.3.2")
    
    // Lifecycle ViewModel Compose
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.9.0")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.9.0")
    
    // Compose Material Icons Extended (for KeyboardVoice and other icons)
    implementation("androidx.compose.material:material-icons-extended:1.7.6")
    
    // Security/Crypto for encrypted preferences
    implementation(libs.security.crypto)
    
    // Mozilla Rhino for JavaScript execution
    implementation("org.mozilla:rhino:1.7.14")
    
    // FFmpeg Kit for video processing
    implementation("com.arthenica:ffmpeg-kit-full:5.1")
    
    // Flutter stubs: allow compilation when Flutter SDK/artifacts are not available.
    // When integrating a real Flutter module, remove this and depend on the generated Flutter module.
    implementation(project(":flutter_stubs"))
}

# KSP Plugin Resolution Fix

## Problem
The KSP (Kotlin Symbol Processing) plugin version `2.2.0-1.0.29` was not found in Maven repositories, causing the build to fail with:

```
Plugin [id: 'com.google.devtools.ksp', version: '2.2.0-1.0.29'] was not found in any of the following sources
```

## Root Cause
The KSP version format is `<kotlin-version>-<ksp-version>`, and version `2.2.0-1.0.29` does not exist in the Maven Central repository.

## Solution Applied

### 1. Updated KSP Version in Version Catalog
**File**: `gradle/libs.versions.toml`

Changed:
```toml
ksp = "2.2.0-1.0.29"
```

To:
```toml
ksp = "2.2.0-2.0.2"
```

The version `2.2.0-2.0.2` is the correct KSP version for Kotlin 2.2.0.

### 2. Added KSP Plugin to Root Build File
**File**: `build.gradle.kts`

Added the KSP plugin declaration to the plugins block:
```kotlin
plugins {
    alias(libs.plugins.android.application) apply false
    alias(libs.plugins.kotlin.android) apply false
    alias(libs.plugins.kotlin.compose) apply false
    alias(libs.plugins.kotlin.serialization) apply false
    alias(libs.plugins.ksp) apply false  // Added
}
```

When using the plugins DSL with a version catalog, plugins should be declared in the top-level `build.gradle.kts` with `apply false`, then applied in the module-level build file.

## Verification

After the fix, the KSP plugin is now properly resolved and the following KSP tasks are available:
- `kspDebugAndroidTestKotlin`
- `kspDebugKotlin`
- `kspDebugUnitTestKotlin`
- `kspReleaseKotlin`
- `kspReleaseUnitTestKotlin`

Build status: ✅ BUILD SUCCESSFUL

## Version Compatibility Matrix

| Kotlin Version | KSP Version |
|---------------|-------------|
| 2.2.0         | 2.2.0-2.0.2 |

This combination ensures:
- Room annotation processing works correctly
- KSP2 is enabled by default
- Full compatibility with Kotlin 2.2.0 language features

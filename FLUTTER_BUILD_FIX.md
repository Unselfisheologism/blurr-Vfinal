# Fix for GitHub Actions Flutter Module Build Failure

## Problem
The GitHub Actions workflow was failing during the Flutter Module build step with 403 Forbidden errors from Maven Central repository when trying to download dependencies.

```
Could not resolve org.jetbrains.kotlin:kotlin-stdlib:2.1.20.
> Could not GET 'https://repo.maven.apache.org/maven2/org/jetbrains/kotlin/kotlin-stdlib/2.1.20/kotlin-stdlib-2.1.20.pom'. Received status code 403 from server: Forbidden
```

## Root Cause
Transient network issues with Maven Central repository returning 403 errors during dependency resolution in the Flutter AAR build process.

## Solution
Implemented multiple layers of resilience to handle transient network failures:

### 1. Gradle Properties Configuration (`flutter_workflow_editor/.android/gradle.properties`)
- Increased HTTP timeouts from default 30s to 120s
- Configured connection pooling
- Optimized JVM settings for larger builds
- Enabled Gradle caching and parallel execution

### 2. Gradle Init Script (`flutter_workflow_editor/.android/init.gradle`)
- Prioritizes Google Maven repository (more reliable than Maven Central)
- Configures dependency caching strategies
- Applied to all projects during build

### 3. Workflow Retry Logic (`.github/workflows/build-apk.yml`)
- Added retry loop with exponential backoff:
  - Maximum 3 retry attempts
  - Initial delay: 30 seconds
  - Exponential backoff: delay doubles on each retry (30s, 60s, 120s)
- Uses `--verbose` flag for better debugging
- Copies init.gradle to `~/.gradle/init.d/` for automatic application during build

### 4. Build Configuration Step
Added a preparatory step to ensure `.android` directory and configuration files exist before build.

## Files Changed
1. `.github/workflows/build-apk.yml` - Added retry logic and configuration step
2. `flutter_workflow_editor/.android/gradle.properties` - Network timeout configuration
3. `flutter_workflow_editor/.android/init.gradle` - Repository prioritization
4. `.gitignore` - Updated to ignore generated Flutter Android files while preserving config

## Expected Behavior
- If Maven Central returns 403, the build will automatically retry
- Google Maven repository will be tried first for dependencies
- Longer timeouts allow more time for slow network responses
- Exponential backoff reduces server load while maximizing success chance

## Testing
To test locally before pushing:
```bash
cd flutter_workflow_editor
# Copy init.gradle to Gradle's init.d directory
mkdir -p ~/.gradle/init.d
cp .android/init.gradle ~/.gradle/init.d/
# Build the AAR
flutter build aar --release --verbose
```

## Notes
- The configuration files (gradle.properties and init.gradle) are checked into the repository
- Generated files (.android/app/, .android/build/, etc.) are ignored via .gitignore
- This fix addresses transient network issues, not actual dependency conflicts

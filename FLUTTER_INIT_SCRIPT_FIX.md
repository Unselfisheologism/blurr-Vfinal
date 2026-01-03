# Flutter AAR Build Init Script Error - Fix Applied

## Problem
The GitHub Actions workflow was failing with the following error:
```
Could not find an option named "--init-script".
Run 'flutter -h' (or 'flutter <command> -h') for available flutter commands and options.
```

## Root Cause
The workflow was attempting to use `--init-script=.android/init.gradle` as a parameter to the `flutter build aar` command:
```bash
flutter build aar --release --verbose --init-script=.android/init.gradle
```

However, `--init-script` is a **Gradle** option, not a Flutter CLI option. Flutter CLI does not support this parameter.

## Solution
The fix involves placing the `init.gradle` script in Gradle's standard initialization directory (`~/.gradle/init.d/`) where it will be automatically picked up by all Gradle builds, including those triggered by Flutter.

### Changes Made

1. **`.github/workflows/build-apk.yml`** (Line 58-63)
   - Added step to copy `init.gradle` to `~/.gradle/init.d/` directory
   - Removed invalid `--init-script=.android/init.gradle` from the flutter command
   - The command now correctly uses: `flutter build aar --release --verbose`

2. **`FLUTTER_BUILD_FIX.md`**
   - Updated documentation to reflect correct usage
   - Updated testing instructions

3. **`flutter_workflow_editor/.android/init.gradle`**
   - Updated usage comment to show correct approach

### How It Works
Gradle automatically applies all `.gradle` files found in the `~/.gradle/init.d/` directory to every build. By copying our `init.gradle` file there before running the Flutter AAR build, we ensure:
- Google Maven repository is prioritized (more reliable than Maven Central)
- Dependency caching is properly configured
- Repository resolution strategy is applied to all projects

This achieves the same goal as the intended `--init-script` parameter would have, but using Gradle's standard mechanism.

## Files Modified
1. `.github/workflows/build-apk.yml` - Fixed Flutter build command
2. `FLUTTER_BUILD_FIX.md` - Updated documentation
3. `flutter_workflow_editor/.android/init.gradle` - Updated usage comment

## Testing
The fix can be verified by running:
```bash
cd flutter_workflow_editor
mkdir -p ~/.gradle/init.d
cp .android/init.gradle ~/.gradle/init.d/
flutter build aar --release --verbose
```

## Expected Outcome
The Flutter AAR build will now succeed without the invalid `--init-script` error, while still benefiting from the Gradle configuration in `init.gradle`.

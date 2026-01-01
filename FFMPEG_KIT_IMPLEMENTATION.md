# FFmpeg Kit 16KB Implementation

## Overview
This project uses the community-maintained fork of FFmpegKit from moizhassan, which provides 16KB page size support required for Android API 35+.

## Dependency Declaration

### Maven Coordinates
```
Group: com.moizhassan.ffmpeg
Artifact: ffmpeg-kit-16kb
Version: 6.1.1
```

### In build.gradle.kts
```kotlin
implementation("com.moizhassan.ffmpeg:ffmpeg-kit-16kb:6.1.1")
```

## Package Structure

The moizhassan fork maintains the **same package structure** as the original arthenica library:

```kotlin
import com.arthenica.ffmpegkit.FFmpegKit
import com.arthenica.ffmpegkit.ReturnCode
import com.arthenica.ffmpegkit.FFmpegSession
```

**Note:** Only the Maven coordinates changed (`com.moizhassan.ffmpeg`), not the Java/Kotlin package names (`com.arthenica.ffmpegkit`).

## API Usage

### Execute FFmpeg Commands
```kotlin
private fun runFfmpeg(cmd: String) {
    val session = FFmpegKit.execute(cmd)
    if (!ReturnCode.isSuccess(session.returnCode)) {
        val output = session.output
        val state = session.state
        val rc = session.returnCode
        throw IllegalStateException("FFmpeg failed (state=$state, rc=$rc): $output")
    }
}
```

### Session Object Properties
- `session.returnCode` - The return code of the execution
- `session.output` - Console output generated
- `session.state` - Execution state (running/completed)
- `session.sessionId` - Unique session identifier
- `session.command` - Command that was executed
- `session.startTime` / `session.endTime` - Timing information

## Implementation Location

Primary implementation is in:
- `app/src/main/kotlin/com/blurr/voice/flutter/VideoEditorBridge.kt`

This bridge handles:
- Video timeline rendering and compositing
- FFmpeg command execution for video processing
- Multiple video/audio track support
- Transitions, overlays, and caption burn-in

## References

- **Source Repository:** https://github.com/moizhassan/ffmpeg-kit-android-16kb
- **Maven Central:** https://central.sonatype.com/artifact/com.moizhassan.ffmpeg/ffmpeg-kit-16kb
- **Original FFmpegKit:** https://github.com/arthenica/ffmpeg-kit (retired)
- **Android Documentation:** Original arthenica API documentation applies

## Key Points

1. ✅ Uses proper session-based API from original FFmpegKit
2. ✅ Maintains compatibility with original arthenica package structure
3. ✅ Supports Android API 35+ with 16KB page size requirement
4. ✅ Version 6.1.1 is the latest stable release
5. ✅ Licensed under LGPL v3.0 (GPL v3.0 for GPL packages)

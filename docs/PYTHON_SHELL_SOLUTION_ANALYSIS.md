# Python Shell Tool Solution - Analysis

**Date**: December 2024  
**Concept**: Give AI agent access to Python shell with FFmpeg, ImageMagick, and other utilities

---

## The Concept

Instead of creating separate tools for every operation, give the AI agent a **Python execution environment** where it can:
- Run FFmpeg commands for video/audio
- Use ImageMagick for image processing
- Use PyPDF2/pypdf for PDF operations
- Use pandas for data processing
- Run any Python code for file operations
- Install and use Python packages dynamically

**Key Insight**: The AI agent writes and executes Python code to solve problems!

---

## Why This is BRILLIANT

### 1. **Unified Generic Approach** ✅
Instead of:
- VideoEditorTool
- AudioMixerTool
- ImageComposerTool
- PDFMergerTool
- DocumentConverterTool
- ... 50 more tools

We have:
- **ONE PythonShellTool** that can do EVERYTHING

### 2. **Unlimited Flexibility** ✅
The AI can:
- Combine operations in creative ways
- Handle edge cases dynamically
- Experiment and retry
- Learn from errors
- Solve problems we didn't anticipate

### 3. **Natural for AI** ✅
Modern LLMs (GPT-4, Claude, etc.) are **excellent at writing Python code**:
- They understand ffmpeg syntax
- They know imagemagick commands
- They can debug their own code
- They can read error messages and fix issues

### 4. **Future-Proof** ✅
As new libraries/tools emerge:
- No need to update app
- AI can use new Python packages
- Community creates solutions
- Agent learns from examples

### 5. **Powerful Ecosystem** ✅
Python has libraries for EVERYTHING:
- **FFmpeg**: video/audio (ffmpeg-python, subprocess)
- **Pillow/PIL**: image processing
- **ImageMagick**: advanced image operations
- **PyPDF2/pypdf**: PDF manipulation
- **python-docx**: Word documents
- **openpyxl**: Excel files
- **beautifulsoup4**: Web scraping
- **pandas**: data processing
- **numpy**: numerical operations
- **matplotlib**: charts and graphs

---

## Technical Implementation

### Chaquopy for Android

**What is Chaquopy**:
- Runs Python on Android
- Full Python 3 support
- Can use pip packages
- Native performance
- Well-maintained

**Installation**:
```gradle
plugins {
    id 'com.chaquo.python' version '14.0.2'
}

android {
    defaultConfig {
        python {
            version "3.8"
            pip {
                install "ffmpeg-python"
                install "Pillow"
                install "pypdf"
                install "python-docx"
                install "requests"
            }
        }
    }
}
```

### FFmpeg on Android

**Options**:

#### Option 1: ffmpeg-python (via Chaquopy) ⭐ BEST
```python
import ffmpeg

# Create video from images
(
    ffmpeg
    .input('image1.png', loop=1, t=3)
    .input('image2.png', loop=1, t=3)
    .concat()
    .output('output.mp4')
    .run()
)

# Overlay audio
(
    ffmpeg
    .input('video.mp4')
    .input('music.mp3')
    .input('voiceover.mp3')
    .filter('amix', inputs=2, duration='longest')
    .output('final.mp4')
    .run()
)
```

**Pros**:
- ✅ Pythonic API
- ✅ Easy to use from Python
- ✅ LLMs know this library well
- ✅ Clean, readable code

#### Option 2: ffmpeg-kit-android (via subprocess)
```python
import subprocess

subprocess.run([
    'ffmpeg',
    '-i', 'video.mp4',
    '-i', 'audio.mp3',
    '-c:v', 'copy',
    'output.mp4'
])
```

**Pros**:
- ✅ Full ffmpeg binary
- ✅ Native Android performance
- ✅ All ffmpeg features

#### Option 3: Both! (Recommended)
- Use ffmpeg-python for complex operations (better API)
- Use ffmpeg-kit-android as the backend engine
- Best of both worlds

---

## Tool Design

### PythonShellTool Implementation

```kotlin
class PythonShellTool(
    private val context: Context
) : BaseTool() {
    
    override val name = "python_shell"
    
    override val description = 
        "Execute Python code to process files, manipulate media, convert formats, " +
        "merge documents, and perform any computational task. Has access to " +
        "FFmpeg (video/audio), Pillow (images), PyPDF (PDFs), and many other libraries. " +
        "Can run any Python code including file operations, data processing, and " +
        "command-line utilities."
    
    override val parameters = listOf(
        ToolParameter(
            name = "code",
            type = "string",
            description = "Python code to execute. Can be multi-line. " +
                    "Files are in /cache directory. Return result as string or print output.",
            required = true
        ),
        ToolParameter(
            name = "timeout",
            type = "number",
            description = "Maximum execution time in seconds (default: 60)",
            required = false
        ),
        ToolParameter(
            name = "working_directory",
            type = "string",
            description = "Working directory for file operations (default: /cache)",
            required = false
        )
    )
    
    private val python = Python.getInstance()
    
    override suspend fun execute(
        params: Map<String, Any>,
        context: List<ToolResult>
    ): ToolResult = withContext(Dispatchers.IO) {
        try {
            val code = getRequiredParam<String>(params, "code")
            val timeout = getOptionalParam<Int>(params, "timeout", 60)
            val workingDir = getOptionalParam<String>(params, "working_directory", 
                this@PythonShellTool.context.cacheDir.absolutePath)
            
            // Setup Python environment
            val pythonModule = python.getModule("__main__")
            
            // Set working directory
            pythonModule.callAttr("__builtins__", "setattr", "os", "chdir", workingDir)
            
            // Execute code with timeout
            val result = withTimeout(timeout * 1000L) {
                val output = pythonModule.callAttr("eval", code)
                output?.toString() ?: "Code executed successfully"
            }
            
            ToolResult.success(
                toolName = name,
                result = result,
                data = mapOf(
                    "output" to result,
                    "working_directory" to workingDir
                )
            )
            
        } catch (e: TimeoutCancellationException) {
            ToolResult.failure(
                toolName = name,
                error = "Python code execution timed out after ${params["timeout"]} seconds"
            )
        } catch (e: Exception) {
            ToolResult.failure(
                toolName = name,
                error = "Python error: ${e.message}\n${e.stackTraceToString()}"
            )
        }
    }
}
```

---

## Real-World Examples

### Example 1: Music Video Compilation

**Agent receives**:
- image1.png (product photo)
- infographic.png (specs)
- music.mp3 (30s)
- voiceover.mp3 (20s)

**Agent generates Python code**:
```python
import ffmpeg

# Create slideshow from images (3 seconds each)
image1 = ffmpeg.input('image1.png', loop=1, t=3)
image2 = ffmpeg.input('infographic.png', loop=1, t=4)

# Concatenate images into video
video = ffmpeg.concat(image1, image2, v=1, a=0)

# Load audio tracks
music = ffmpeg.input('music.mp3').audio.filter('volume', 0.6)
voice = ffmpeg.input('voiceover.mp3').audio.filter('volume', 1.0)

# Mix audio
mixed_audio = ffmpeg.filter([music, voice], 'amix', inputs=2, duration='first')

# Combine video and audio
output = ffmpeg.output(
    video, 
    mixed_audio,
    'final_video.mp4',
    vcodec='libx264',
    acodec='aac'
)

# Execute
output.run(overwrite_output=True)

print("Video created: final_video.mp4")
```

**Result**: Perfect music video with synced audio!

---

### Example 2: Image Collage Creation

```python
from PIL import Image

# Load images
images = [
    Image.open('phone1.png'),
    Image.open('phone2.png'),
    Image.open('phone3.png'),
    Image.open('phone4.png')
]

# Create 2x2 grid
width, height = images[0].size
collage = Image.new('RGB', (width * 2, height * 2))

# Paste images
collage.paste(images[0], (0, 0))
collage.paste(images[1], (width, 0))
collage.paste(images[2], (0, height))
collage.paste(images[3], (width, height))

# Save
collage.save('collage.png')

print("Collage created: collage.png")
```

---

### Example 3: PDF Merger

```python
from pypdf import PdfMerger

merger = PdfMerger()

# Add PDFs
merger.append('report1.pdf')
merger.append('report2.pdf')
merger.append('appendix.pdf')

# Write merged PDF
merger.write('complete_report.pdf')
merger.close()

print("PDFs merged: complete_report.pdf")
```

---

### Example 4: Audio Normalization

```python
import ffmpeg

# Normalize audio volume
(
    ffmpeg
    .input('voiceover.mp3')
    .filter('loudnorm')
    .output('voiceover_normalized.mp3')
    .run(overwrite_output=True)
)

print("Audio normalized")
```

---

### Example 5: Image Watermarking

```python
from PIL import Image, ImageDraw, ImageFont

# Load image
img = Image.open('product.png')
draw = ImageDraw.Draw(img)

# Add watermark
font = ImageFont.truetype('/system/fonts/Roboto-Regular.ttf', 40)
draw.text((10, 10), 'Twent AI', fill='white', font=font)

# Save
img.save('product_watermarked.png')

print("Watermark added")
```

---

## Advantages Over Individual Tools

### Flexibility Comparison

**Individual Tools Approach**:
```
User: "Create video with images fading in, music at 60%, voiceover at 80%, add 'Winner 2025' text at 5s"

Problem: Would need:
- VideoEditorTool (with fade support)
- AudioMixerTool (with volume control)
- TextOverlayTool (with timing)

If ANY of these don't support exact feature → fails
```

**Python Shell Approach**:
```
User: Same request

Agent writes Python code:
- Uses ffmpeg-python for everything
- Can handle ANY requirement
- Can experiment and adapt
- Can fix errors dynamically

Success guaranteed (if technically possible)
```

---

### Problem Solving Comparison

**Scenario**: User wants video with custom transition

**Individual Tools**:
```
Tool: video_editor
Parameters: { transition: "custom" }
→ Error: "Custom transition not supported"
→ Agent is stuck
```

**Python Shell**:
```
Agent thinks: "I need custom transition. Let me write FFmpeg code..."

import ffmpeg
# Creates custom transition using xfade filter
(
    ffmpeg
    .input('clip1.mp4')
    .input('clip2.mp4')
    .filter('xfade', transition='smoothleft', duration=1, offset=3)
    .output('output.mp4')
    .run()
)

→ Success! Any transition possible
```

---

## System Prompt Integration

### Enhanced System Prompt

```
You have access to a Python execution environment with the following capabilities:

MEDIA PROCESSING:
- FFmpeg (ffmpeg-python): Video/audio editing, conversion, merging
- Pillow (PIL): Image processing, editing, creation
- ImageMagick (via subprocess): Advanced image operations

DOCUMENT PROCESSING:
- pypdf: PDF reading, merging, splitting
- python-docx: Word document creation/editing
- openpyxl: Excel file operations

DATA PROCESSING:
- pandas: Data analysis, CSV/Excel processing
- numpy: Numerical computations
- matplotlib: Chart and graph generation

FILE OPERATIONS:
- os, shutil: File/directory operations
- pathlib: Path manipulation
- subprocess: Execute system commands

When you need to process files, write Python code using these libraries.
Working directory: /cache/generated_*
All generated media files are available in this directory.

EXAMPLES:

Create video from images:
```python
import ffmpeg
image1 = ffmpeg.input('image1.png', loop=1, t=3)
image2 = ffmpeg.input('image2.png', loop=1, t=3)
ffmpeg.concat(image1, image2).output('video.mp4').run()
```

Mix audio tracks:
```python
import ffmpeg
music = ffmpeg.input('music.mp3').audio.filter('volume', 0.6)
voice = ffmpeg.input('voice.mp3').audio.filter('volume', 1.0)
ffmpeg.filter([music, voice], 'amix').output('mixed.mp3').run()
```

Merge PDFs:
```python
from pypdf import PdfMerger
merger = PdfMerger()
merger.append('doc1.pdf')
merger.append('doc2.pdf')
merger.write('merged.pdf')
```

Process images:
```python
from PIL import Image
img = Image.open('photo.jpg')
img = img.resize((800, 600))
img = img.filter(ImageFilter.SHARPEN)
img.save('processed.jpg')
```

You can execute any Python code. Be creative and solve problems dynamically!
```

---

## Implementation Plan

### Story 4.18: Python Shell Tool (Revised)

**Time**: 3 days

**Day 1: Setup**
- Integrate Chaquopy
- Setup Python environment
- Install core libraries (ffmpeg-python, Pillow, pypdf)
- Test basic execution

**Day 2: Tool Implementation**
- Create PythonShellTool class
- Implement code execution
- Add timeout handling
- Add error capture
- File path management

**Day 3: Testing & Integration**
- Test with FFmpeg operations
- Test with image processing
- Test with PDF operations
- Update system prompt
- Integration testing with agent

### Dependencies to Add

```gradle
// build.gradle (project)
buildscript {
    repositories {
        maven { url "https://chaquo.com/maven" }
    }
    dependencies {
        classpath "com.chaquo.python:gradle:14.0.2"
    }
}

// build.gradle (app)
plugins {
    id 'com.chaquo.python'
}

android {
    defaultConfig {
        ndk {
            abiFilters "armeabi-v7a", "arm64-v8a", "x86", "x86_64"
        }
        
        python {
            version "3.8"
            
            pip {
                // Core utilities
                install "ffmpeg-python"
                install "Pillow"
                install "pypdf"
                install "python-docx"
                install "openpyxl"
                
                // Data processing
                install "pandas"
                install "numpy"
                
                // Optional but useful
                install "requests"
                install "beautifulsoup4"
            }
        }
    }
}

// FFmpeg binary for Android
dependencies {
    implementation 'com.arthenica:ffmpeg-kit-full:5.1'
}
```

### File Structure

```
app/src/main/python/
  └── utils/
      ├── __init__.py
      ├── video_utils.py      # Helper functions for video
      ├── audio_utils.py      # Helper functions for audio
      ├── image_utils.py      # Helper functions for images
      └── document_utils.py   # Helper functions for documents

app/src/main/java/com/twent/voice/tools/
  └── PythonShellTool.kt
```

---

## Advantages Summary

### ✅ Pros:
1. **One tool does everything** - No need for 20+ specialized tools
2. **Unlimited flexibility** - Can handle any requirement
3. **Future-proof** - New Python packages work automatically
4. **Natural for AI** - LLMs excel at writing Python code
5. **Powerful ecosystem** - Access to thousands of libraries
6. **Self-debugging** - AI can fix its own code errors
7. **Creative solutions** - AI can combine operations uniquely
8. **Smaller app** - Less Kotlin code to maintain

### ⚠️ Cons:
1. **App size** - Chaquopy + Python libs (~60-80MB)
2. **Security** - Need to sandbox Python execution
3. **Performance** - Python slower than native (but FFmpeg is native)
4. **Complexity** - More complex than simple tools
5. **Testing** - Harder to test (infinite possibilities)

---

## Security Considerations

### Sandboxing Required

```kotlin
class PythonShellTool {
    private fun setupSandbox() {
        // Restrict file access
        val allowedDirs = listOf(
            context.cacheDir.absolutePath,
            context.filesDir.absolutePath
        )
        
        // Disable dangerous modules
        val blockedModules = listOf(
            "socket",
            "urllib",
            "http",
            "subprocess" // Optional: allow only for ffmpeg
        )
        
        // Set resource limits
        // CPU time, memory, disk space
    }
}
```

### What to Allow/Block

**✅ Allow**:
- File operations in app directories
- FFmpeg via ffmpeg-python
- Image processing with Pillow
- PDF operations with pypdf
- Data processing with pandas

**❌ Block**:
- Network access (unless needed)
- System commands (except whitelisted)
- Access to other apps' data
- Infinite loops (use timeout)

---

## Recommendation

### ✅ YES! Use Python Shell Approach

**Why**:
1. More powerful than individual tools
2. More flexible and future-proof
3. Natural for AI agents (LLMs excel at Python)
4. Smaller codebase to maintain
5. Unlimited possibilities

**Implementation**:
1. Add Story 4.18: Python Shell Tool (3 days)
2. Remove stories 4.19 (Audio Mixer) and 4.20 (Image Composer)
3. Python shell replaces ALL asset processing needs

**Updated Timeline**:
- Phase 1: 25 stories (was 27)
- Time: 11 days (was 13)
- Net: -2 stories, -2 days!

---

## Next Steps

1. ✅ Add Chaquopy to build.gradle
2. ✅ Implement PythonShellTool
3. ✅ Test with FFmpeg operations
4. ✅ Update system prompt with Python examples
5. ✅ Test complete music video workflow

---

**This is a MUCH BETTER solution! Shall we implement it?**

- Implement Python Shell Tool as Story 4.18?
- Keep individual tools approach?
- Hybrid (both Python + specialized tools)?

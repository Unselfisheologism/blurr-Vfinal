# Python Shell Tool - Dynamic Package Installation Plan

**Date**: December 2024  
**Feature**: AI can install Python packages dynamically as needed

---

## The Vision

### Pre-installed Core Libraries (Always Available)
```python
# Media Processing (Core)
ffmpeg-python      # Video/audio editing
Pillow            # Image processing
pypdf             # PDF manipulation

# Documents
python-docx       # Word documents
openpyxl          # Excel files

# Data Processing
pandas            # Data analysis
numpy             # Numerical operations

# Utilities
requests          # HTTP requests (for downloads)
```

### Dynamic Installation (On-Demand)
```python
# Examples of what AI could install:
moviepy           # Advanced video editing
pydub             # Audio manipulation
reportlab         # PDF generation
matplotlib        # Charts and graphs
opencv-python     # Computer vision
pytesseract       # OCR (text from images)
beautifulsoup4    # Web scraping
scikit-learn      # Machine learning
... and 400,000+ more packages!
```

---

## User Experience Flow

### Scenario 1: Core Libraries Sufficient (Fast)
```
User: "Create video from these 3 images with music"

Agent: Uses pre-installed ffmpeg-python
→ Executes immediately (0s wait)
→ Video ready in 5-10 seconds
```

### Scenario 2: Needs Additional Library (Slower)
```
User: "Extract text from this image using OCR"

Agent thinks: "I need pytesseract for OCR"
Agent checks: pytesseract not installed
Agent installs: pip install pytesseract

→ Shows dismissible toast: "Installing required library, this may take 30-60 seconds..."
→ Installation completes
→ Executes OCR code
→ Returns extracted text
```

### Scenario 3: AI Asks Perplexity for Best Library
```
User: "Generate QR code for this URL"

Agent thinks: "I need a QR code library. Let me ask Perplexity..."

Agent calls: web_search("best python library for QR code generation")
Perplexity suggests: "qrcode library is most popular"

Agent: pip install qrcode
→ Toast notification
→ Generates QR code
```

---

## Implementation Architecture

### Enhanced PythonShellTool

```kotlin
class PythonShellTool(
    private val context: Context
) : BaseTool() {
    
    companion object {
        private const val TAG = "PythonShellTool"
        
        // Pre-installed core libraries
        private val CORE_LIBRARIES = setOf(
            "ffmpeg-python",
            "Pillow",
            "pypdf",
            "python-docx",
            "openpyxl",
            "pandas",
            "numpy",
            "requests"
        )
        
        // Cache of installed packages
        private val installedPackages = mutableSetOf<String>()
        
        init {
            installedPackages.addAll(CORE_LIBRARIES)
        }
    }
    
    override val name = "python_shell"
    
    override val description = 
        "Execute Python code with access to pre-installed libraries (ffmpeg-python, Pillow, " +
        "pypdf, pandas, numpy, etc.) OR install additional packages on-demand using pip. " +
        "Can install any Python package from PyPI. Use web_search tool to find best libraries " +
        "for specific tasks. Note: Package installation takes 30-60 seconds."
    
    override val parameters = listOf(
        ToolParameter(
            name = "code",
            type = "string",
            description = "Python code to execute. Can use pre-installed libraries immediately. " +
                    "For new libraries, use: pip_install('package_name') before importing.",
            required = true
        ),
        ToolParameter(
            name = "packages_to_install",
            type = "array",
            description = "List of packages to install before executing code (optional). " +
                    "Example: ['qrcode', 'matplotlib']. Installation takes 30-60s per package.",
            required = false
        ),
        ToolParameter(
            name = "timeout",
            type = "number",
            description = "Execution timeout in seconds (default: 60, max: 300 for installations)",
            required = false
        )
    )
    
    override suspend fun execute(
        params: Map<String, Any>,
        context: List<ToolResult>
    ): ToolResult = withContext(Dispatchers.IO) {
        try {
            val code = getRequiredParam<String>(params, "code")
            val packagesToInstall = getOptionalParam<List<String>>(params, "packages_to_install", emptyList())
            val timeout = getOptionalParam<Int>(params, "timeout", 60)
            
            // Step 1: Install packages if needed
            if (packagesToInstall.isNotEmpty()) {
                installPackages(packagesToInstall)
            }
            
            // Step 2: Check if code requests installations
            val requestedPackages = extractPackageInstallRequests(code)
            if (requestedPackages.isNotEmpty()) {
                installPackages(requestedPackages)
            }
            
            // Step 3: Execute code
            val result = executePythonCode(code, timeout)
            
            ToolResult.success(
                toolName = name,
                result = result,
                data = mapOf(
                    "output" to result,
                    "installed_packages" to installedPackages.toList()
                )
            )
            
        } catch (e: Exception) {
            ToolResult.failure(
                toolName = name,
                error = "Python execution error: ${e.message}"
            )
        }
    }
    
    /**
     * Install Python packages with user notification
     */
    private suspend fun installPackages(packages: List<String>) {
        val newPackages = packages.filter { it !in installedPackages }
        
        if (newPackages.isEmpty()) {
            Log.d(TAG, "All packages already installed")
            return
        }
        
        // Show toast notification
        withContext(Dispatchers.Main) {
            Toast.makeText(
                context,
                "Installing ${newPackages.size} package(s). This may take 30-60 seconds...",
                Toast.LENGTH_LONG
            ).show()
            
            // Show notification for longer tasks
            showProgressNotification(
                title = "Installing Python Packages",
                message = "Installing: ${newPackages.joinToString(", ")}"
            )
        }
        
        try {
            newPackages.forEach { packageName ->
                Log.d(TAG, "Installing package: $packageName")
                
                val startTime = System.currentTimeMillis()
                installPackage(packageName)
                val duration = System.currentTimeMillis() - startTime
                
                installedPackages.add(packageName)
                Log.d(TAG, "Package $packageName installed in ${duration}ms")
            }
            
            // Dismiss notification
            withContext(Dispatchers.Main) {
                dismissProgressNotification()
                Toast.makeText(
                    context,
                    "Packages installed successfully",
                    Toast.LENGTH_SHORT
                ).show()
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Package installation failed", e)
            withContext(Dispatchers.Main) {
                dismissProgressNotification()
                Toast.makeText(
                    context,
                    "Package installation failed: ${e.message}",
                    Toast.LENGTH_LONG
                ).show()
            }
            throw e
        }
    }
    
    /**
     * Install single package using pip
     */
    private fun installPackage(packageName: String) {
        val python = Python.getInstance()
        val pip = python.getModule("pip")
        
        // Execute: pip install packageName
        pip.callAttr("main", listOf("install", packageName))
    }
    
    /**
     * Extract package installation requests from code
     * Looks for: pip_install('package_name')
     */
    private fun extractPackageInstallRequests(code: String): List<String> {
        val regex = """pip_install\(['"]([^'"]+)['"]\)""".toRegex()
        return regex.findAll(code).map { it.groupValues[1] }.toList()
    }
    
    /**
     * Execute Python code with timeout
     */
    private suspend fun executePythonCode(code: String, timeout: Int): String {
        return withTimeout(timeout * 1000L) {
            val python = Python.getInstance()
            val module = python.getModule("__main__")
            
            // Inject helper function for installations
            val wrappedCode = """
import sys
import subprocess

def pip_install(package):
    '''Install package if not already installed'''
    try:
        __import__(package)
        print(f"Package {package} already installed")
    except ImportError:
        print(f"Installing {package}...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", package])
        print(f"Package {package} installed successfully")

# User code
$code
            """.trimIndent()
            
            val result = module.callAttr("exec", wrappedCode)
            result?.toString() ?: "Code executed successfully"
        }
    }
    
    /**
     * Show progress notification
     */
    private fun showProgressNotification(title: String, message: String) {
        // Implementation using NotificationManager
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        
        val notification = NotificationCompat.Builder(context, "python_shell_channel")
            .setSmallIcon(R.drawable.ic_python)
            .setContentTitle(title)
            .setContentText(message)
            .setProgress(0, 0, true) // Indeterminate progress
            .setOngoing(true)
            .build()
        
        notificationManager.notify(NOTIFICATION_ID, notification)
    }
    
    private fun dismissProgressNotification() {
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancel(NOTIFICATION_ID)
    }
    
    companion object {
        private const val NOTIFICATION_ID = 1001
    }
}
```

---

## Enhanced System Prompt

```
PYTHON EXECUTION ENVIRONMENT

You have access to a Python 3.8+ environment with these PRE-INSTALLED libraries:

CORE LIBRARIES (Always available, instant execution):
- ffmpeg-python: Video/audio editing, format conversion
- Pillow (PIL): Image processing, manipulation, creation
- pypdf: PDF reading, merging, splitting
- python-docx: Word document creation/editing
- openpyxl: Excel file operations
- pandas: Data analysis, CSV processing
- numpy: Numerical computations
- requests: HTTP requests

DYNAMIC PACKAGE INSTALLATION:
You can install ANY Python package from PyPI on-demand:
- Use web_search to find the best library for a task
- Install packages using: pip_install('package_name')
- Note: Installation takes 30-60 seconds (user will see notification)
- Installed packages remain available for future requests

EXAMPLES:

Using pre-installed library (instant):
```python
import ffmpeg
video = ffmpeg.input('video.mp4')
audio = ffmpeg.input('audio.mp3')
ffmpeg.output(video, audio, 'output.mp4').run()
```

Installing and using new library:
```python
pip_install('qrcode')
import qrcode

qr = qrcode.QRCode()
qr.add_data('https://example.com')
qr.make_image().save('qr.png')
```

Finding best library with web search:
Step 1: Use web_search("best python library for barcode generation")
Step 2: Based on result, install recommended library
Step 3: Use the library

INSTALLATION GUIDELINES:
- Use pre-installed libraries when possible (faster)
- For specialized tasks, search for best library first
- Install only what you need
- User will see "Installing... may take 30-60s" notification
```

---

## Agent Workflow Examples

### Example 1: Simple Task (Pre-installed Library)

```
User: "Create slideshow from these 3 images with music"

Agent thinks:
- Need video editing → ffmpeg-python (pre-installed ✅)
- No installation needed

Agent executes:
{
  "tool": "python_shell",
  "parameters": {
    "code": "
import ffmpeg
img1 = ffmpeg.input('image1.png', loop=1, t=3)
img2 = ffmpeg.input('image2.png', loop=1, t=3)
img3 = ffmpeg.input('image3.png', loop=1, t=3)
video = ffmpeg.concat(img1, img2, img3, v=1, a=0)
music = ffmpeg.input('music.mp3')
ffmpeg.output(video, music, 'slideshow.mp4').run()
    "
  }
}

Result: Slideshow created (5 seconds, no installation wait)
```

### Example 2: Needs New Library (With Installation)

```
User: "Generate a QR code for this website URL"

Agent thinks:
- Need QR code generation → not in pre-installed libraries
- Let me search for best library

Agent calls web_search:
{
  "tool": "web_search",
  "parameters": {
    "query": "best python library for QR code generation"
  }
}

Perplexity returns: "qrcode library is most popular and reliable"

Agent executes:
{
  "tool": "python_shell",
  "parameters": {
    "code": "
pip_install('qrcode')
import qrcode

qr = qrcode.QRCode(version=1, box_size=10, border=5)
qr.add_data('https://twent.app')
qr.make(fit=True)
img = qr.make_image(fill_color='black', back_color='white')
img.save('qr_code.png')
print('QR code generated: qr_code.png')
    ",
    "packages_to_install": ["qrcode"]
  }
}

User sees: "Installing required library, this may take 30-60 seconds..."
→ Installation completes (45 seconds)
→ QR code generated
→ Future QR requests are instant (library cached)
```

### Example 3: OCR (Complex Use Case)

```
User: "Extract text from this image"

Agent thinks:
- Need OCR → not in pre-installed libraries
- Let me search for best option

Agent calls web_search:
{
  "tool": "web_search",
  "parameters": {
    "query": "best python OCR library pytesseract vs easyocr"
  }
}

Perplexity: "pytesseract is lightweight, easyocr is more accurate but slower"

Agent chooses: pytesseract (faster for user)

Agent executes:
{
  "tool": "python_shell",
  "parameters": {
    "code": "
pip_install('pytesseract')
from PIL import Image
import pytesseract

image = Image.open('document.png')
text = pytesseract.image_to_string(image)
print('Extracted text:')
print(text)
    ",
    "packages_to_install": ["pytesseract"]
  }
}

User sees notification → Installs → Extracts text
Future OCR requests: Instant (library cached)
```

### Example 4: Data Visualization (Multiple Packages)

```
User: "Create a bar chart from this CSV data"

Agent thinks:
- Need CSV reading → pandas (pre-installed ✅)
- Need chart creation → matplotlib (not installed ❌)

Agent executes:
{
  "tool": "python_shell",
  "parameters": {
    "code": "
pip_install('matplotlib')
import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv('data.csv')
df.plot(kind='bar', x='category', y='value')
plt.savefig('chart.png')
plt.close()
print('Chart created: chart.png')
    ",
    "packages_to_install": ["matplotlib"]
  }
}

User sees: "Installing 1 package(s). This may take 30-60 seconds..."
→ matplotlib installs (40 seconds)
→ Chart generated
→ Future chart requests: Instant
```

---

## UI/UX Design

### Toast Notification

```kotlin
// Dismissible toast for quick installations (1 package)
Toast.makeText(
    context,
    "Installing required library, this may take 30-60 seconds...",
    Toast.LENGTH_LONG  // 3.5 seconds display
).show()
```

### Progress Notification (Multiple Packages)

```kotlin
// For longer installations (multiple packages)
NotificationCompat.Builder(context, CHANNEL_ID)
    .setSmallIcon(R.drawable.ic_python)
    .setContentTitle("Installing Python Packages")
    .setContentText("Installing: qrcode, matplotlib, opencv-python")
    .setProgress(0, 0, true)  // Indeterminate
    .setOngoing(true)  // Can't be dismissed during install
    .build()

// After completion
.setContentText("Installation complete")
.setProgress(0, 0, false)
.setOngoing(false)  // Now dismissible
```

### Visual Feedback Timeline

```
User sends request
    ↓
Agent analyzes (1-2 seconds)
    ↓
Agent realizes needs new library
    ↓
[TOAST APPEARS: "Installing library, may take 30-60s..."]
    ↓
[NOTIFICATION: "Installing Python Packages" with spinner]
    ↓
Package downloads (15-30 seconds)
    ↓
Package installs (10-20 seconds)
    ↓
[NOTIFICATION: "Installation complete" ✅]
    ↓
Code executes (2-10 seconds)
    ↓
Result returned
```

---

## Package Installation Performance

### Typical Installation Times

| Package | Size | Installation Time |
|---------|------|-------------------|
| qrcode | 60KB | ~15 seconds |
| matplotlib | 35MB | ~45 seconds |
| opencv-python | 90MB | ~90 seconds |
| pytesseract | 2MB | ~20 seconds |
| beautifulsoup4 | 350KB | ~18 seconds |
| scikit-learn | 60MB | ~75 seconds |

### Optimization Strategies

1. **Pre-compile popular packages** (in Chaquopy config)
2. **Cache installations** (persist across app sessions)
3. **Smart suggestions** (AI recommends lighter alternatives)
4. **Batch installations** (install multiple at once)

---

## Caching Strategy

### Package Cache Management

```kotlin
object PackageCache {
    private val cacheFile = File(context.filesDir, "installed_packages.json")
    
    fun loadCache(): Set<String> {
        if (!cacheFile.exists()) return emptySet()
        val json = cacheFile.readText()
        return Json.decodeFromString(json)
    }
    
    fun saveCache(packages: Set<String>) {
        val json = Json.encodeToString(packages)
        cacheFile.writeText(json)
    }
    
    fun isInstalled(packageName: String): Boolean {
        return loadCache().contains(packageName)
    }
}
```

### Benefits:
- Packages installed once, available forever
- Survives app restarts
- No re-download needed
- Instant execution on subsequent uses

---

## Implementation Plan

### Phase 1: Core Setup (Day 1)
**Tasks**:
- Integrate Chaquopy
- Configure pre-installed core libraries
- Test basic Python execution
- Implement PythonShellTool skeleton

**Deliverables**:
- Chaquopy integrated
- Core libraries available
- Basic code execution works

### Phase 2: Dynamic Installation (Day 2)
**Tasks**:
- Implement pip_install() function
- Add package detection from code
- Implement toast notifications
- Implement progress notifications
- Add package caching

**Deliverables**:
- Dynamic package installation works
- User sees notifications
- Packages cached and reused

### Phase 3: Testing & Integration (Day 3)
**Tasks**:
- Test with ffmpeg (video compilation)
- Test with new package (qrcode)
- Test with multiple packages (matplotlib + seaborn)
- Update system prompt
- Integration with agent

**Deliverables**:
- End-to-end workflows tested
- System prompt updated
- Agent can use dynamically

### Phase 4: Optimization (Day 4 - Optional)
**Tasks**:
- Pre-compile popular packages
- Optimize installation speed
- Add installation progress percentage
- Error handling improvements

**Deliverables**:
- Faster installations
- Better user feedback
- Production ready

---

## Security Considerations

### Package Whitelisting (Optional)

```kotlin
// Only allow packages from curated list
private val ALLOWED_PACKAGES = setOf(
    // Media
    "moviepy", "pydub", "opencv-python", "pytesseract",
    // Charts
    "matplotlib", "seaborn", "plotly",
    // Documents
    "reportlab", "python-pptx", "xlsxwriter",
    // Data
    "scipy", "scikit-learn", "statsmodels",
    // Utilities
    "qrcode", "barcode", "pillow", "beautifulsoup4"
)

fun isPackageAllowed(packageName: String): Boolean {
    return packageName in ALLOWED_PACKAGES || 
           packageName.startsWith("opencv") ||
           packageName.startsWith("scikit")
}
```

### Sandboxing

```kotlin
// Restrict package functionality
- No network access (requests only for downloads)
- No system calls (except whitelisted)
- No file access outside app directories
- Resource limits (CPU, memory, disk)
```

---

## Gradle Configuration

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
            
            // Pre-installed core libraries
            pip {
                install "ffmpeg-python==0.2.0"
                install "Pillow==10.0.0"
                install "pypdf==3.15.0"
                install "python-docx==0.8.11"
                install "openpyxl==3.1.2"
                install "pandas==2.0.3"
                install "numpy==1.24.3"
                install "requests==2.31.0"
            }
            
            // Enable dynamic installation
            buildPython "python3.8"
        }
    }
    
    // Increase APK size limit
    splits {
        abi {
            enable true
            reset()
            include "armeabi-v7a", "arm64-v8a", "x86", "x86_64"
            universalApk true
        }
    }
}

dependencies {
    // FFmpeg for Android (native binary)
    implementation 'com.arthenica:ffmpeg-kit-full:5.1'
}
```

---

## Priority Order (Updated)

### Phase 1 Stories:

1. **Story 4.17: Phone Control Tool** (1 day) 🔥
   - Wrap existing ScreenInteractionService
   - No impact on existing functionality
   - Highest priority

2. **Story 4.18: Python Shell Tool** (4 days) 🔥🔥
   - Day 1: Core setup + pre-installed libraries
   - Day 2: Dynamic package installation
   - Day 3: Testing & integration
   - Day 4: Optimization (optional)

3. Rest of Phase 1 (Google, Documents) (7 days)

**Total**: 12 days

---

## Success Criteria

### Must Have:
- ✅ Pre-installed core libraries work instantly
- ✅ Dynamic package installation works
- ✅ User sees clear notifications
- ✅ Packages are cached and reused
- ✅ Agent can search for best libraries
- ✅ Error handling for failed installations

### Nice to Have:
- ✅ Installation progress percentage
- ✅ Pre-compiled popular packages
- ✅ Package size estimation
- ✅ Installation time prediction

---

## Recommendation

### ✅ Implement with Dynamic Installation

**Why**:
1. ✅ Unlimited flexibility (400,000+ packages available)
2. ✅ Pre-installed core = instant for common tasks
3. ✅ On-demand install = handles edge cases
4. ✅ User notification = clear expectation setting
5. ✅ Caching = fast after first install
6. ✅ AI can research best libraries = optimal solutions

**Trade-offs Accepted**:
- ⚠️ 30-60 second wait for new packages (but only once!)
- ⚠️ User sees notification (but it's dismissible and clear)
- ⚠️ Slightly more complex (but much more powerful)

---

**This approach gives us the best of both worlds: Speed for common tasks, unlimited capability for edge cases!**

**Ready to implement? Start with Phone Control Tool (Story 4.17) first?**

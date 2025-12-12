# Phase 2: JavaScript Shell Support - Implementation Plan

## Overview

Transform PythonShellTool into a **multi-language UnifiedShellTool** that supports both Python and JavaScript execution on Android.

---

## JavaScript Engine Options for Android

### 1. **Rhino (RECOMMENDED)** ✅
- **Pros**:
  - Pure Java implementation (100% Android compatible)
  - Mature, stable (Mozilla project)
  - Easy to embed
  - Good npm package support via Nashorn compatibility
  - Can load JavaScript libraries from strings
  - No native dependencies
  - Small size (~1-2 MB)
  
- **Cons**:
  - Slightly slower than V8
  - ES6+ support limited (but sufficient for D3.js)

- **Gradle**: `implementation "org.mozilla:rhino:1.7.14"`

### 2. J2V8
- **Pros**: Fast (V8 engine), good performance
- **Cons**: Native library (larger APK), architecture-specific builds, harder to maintain

### 3. QuickJS Android
- **Pros**: Lightweight, ES6+ support
- **Cons**: Less mature, smaller ecosystem

### 4. GraalVM JavaScript
- **Pros**: Full ES6+ support, fast
- **Cons**: Very large (50+ MB), overkill for our use case

**Decision**: Use **Rhino** for reliability, compatibility, and ease of implementation.

---

## Architecture Design

### Before (Python-only)
```
PythonShellTool
└── Chaquopy (Python execution)
    └── Python libraries
```

### After (Multi-language)
```
UnifiedShellTool
├── LanguageDetector (auto-detect from code)
├── PythonExecutor
│   └── Chaquopy
│       └── Python libraries (ffmpeg, Pillow, pypdf, python-pptx, etc.)
└── JavaScriptExecutor
    └── Rhino Engine
        └── JavaScript libraries (D3.js, Chart.js, etc.)
```

---

## Implementation Steps

### Step 1: Add Rhino Dependency
**File**: `app/build.gradle.kts`

```kotlin
dependencies {
    // ... existing dependencies
    
    // JavaScript execution engine (Phase 2: Story 4.12)
    implementation("org.mozilla:rhino:1.7.14")
}
```

### Step 2: Create Language Detector
**New File**: `app/src/main/java/com/blurr/voice/tools/shell/LanguageDetector.kt`

```kotlin
enum class ShellLanguage {
    PYTHON,
    JAVASCRIPT,
    UNKNOWN
}

object LanguageDetector {
    fun detectLanguage(code: String): ShellLanguage {
        val trimmed = code.trim()
        
        // JavaScript indicators
        val jsPatterns = listOf(
            "const ", "let ", "var ",
            "function ", "=>",
            "console.log",
            "document.", "window.",
            "require(", "import ",
            ".map(", ".filter(", ".reduce(",
            "d3.", "chart."
        )
        
        // Python indicators
        val pythonPatterns = listOf(
            "import ", "from ",
            "def ", "class ",
            "print(", "input(",
            "if __name__",
            "self.", "super().",
            "pip_install("
        )
        
        val jsScore = jsPatterns.count { trimmed.contains(it, ignoreCase = true) }
        val pyScore = pythonPatterns.count { trimmed.contains(it, ignoreCase = true) }
        
        return when {
            jsScore > pyScore -> ShellLanguage.JAVASCRIPT
            pyScore > jsScore -> ShellLanguage.PYTHON
            trimmed.contains("python", ignoreCase = true) -> ShellLanguage.PYTHON
            trimmed.contains("javascript", ignoreCase = true) -> ShellLanguage.JAVASCRIPT
            else -> ShellLanguage.UNKNOWN
        }
    }
}
```

### Step 3: Create JavaScript Executor
**New File**: `app/src/main/java/com/blurr/voice/tools/shell/JavaScriptExecutor.kt`

```kotlin
class JavaScriptExecutor(private val context: Context) {
    
    private val rhinoContext: Context by lazy {
        Context.enter().apply {
            optimizationLevel = -1 // Interpreted mode for Android
            languageVersion = Context.VERSION_ES6
        }
    }
    
    private val scope: Scriptable by lazy {
        rhinoContext.initStandardObjects()
    }
    
    init {
        setupConsole()
        loadPreInstalledLibraries()
    }
    
    fun execute(code: String): ExecutionResult {
        return try {
            val result = rhinoContext.evaluateString(scope, code, "script", 1, null)
            val output = Context.toString(result)
            
            ExecutionResult.success(output)
        } catch (e: Exception) {
            ExecutionResult.error(e.message ?: "JavaScript execution failed", e)
        }
    }
    
    private fun setupConsole() {
        val console = rhinoContext.newObject(scope)
        scope.put("console", scope, console)
        
        val log = object : BaseFunction() {
            override fun call(
                cx: Context,
                scope: Scriptable,
                thisObj: Scriptable?,
                args: Array<Any>
            ): Any {
                val message = args.joinToString(" ") { Context.toString(it) }
                Log.d("JavaScriptExecutor", message)
                return message
            }
        }
        console.put("log", console, log)
    }
    
    private fun loadPreInstalledLibraries() {
        // Load D3.js and other libraries from assets
        try {
            val d3js = context.assets.open("js/d3.min.js").bufferedReader().use { it.readText() }
            rhinoContext.evaluateString(scope, d3js, "d3.js", 1, null)
        } catch (e: Exception) {
            Log.w("JavaScriptExecutor", "Could not load D3.js: ${e.message}")
        }
    }
    
    fun cleanup() {
        try {
            Context.exit()
        } catch (e: Exception) {
            // Already exited
        }
    }
}

data class ExecutionResult(
    val success: Boolean,
    val output: String,
    val error: String? = null,
    val exception: Throwable? = null
) {
    companion object {
        fun success(output: String) = ExecutionResult(true, output)
        fun error(message: String, exception: Throwable? = null) = 
            ExecutionResult(false, "", message, exception)
    }
}
```

### Step 4: Create Python Executor (Extract from PythonShellTool)
**New File**: `app/src/main/java/com/blurr/voice/tools/shell/PythonExecutor.kt`

```kotlin
class PythonExecutor(private val context: Context) {
    
    private val python = Python.getInstance()
    
    fun execute(code: String): ExecutionResult {
        return try {
            val module = python.getModule("__main__")
            
            // Capture output
            val output = StringBuilder()
            
            // Execute code
            python.getModule("io").callAttr("StringIO").use { stringIO ->
                // ... existing Python execution logic
            }
            
            ExecutionResult.success(output.toString())
        } catch (e: Exception) {
            ExecutionResult.error(e.message ?: "Python execution failed", e)
        }
    }
    
    fun installPackage(packageName: String): Boolean {
        // ... existing pip_install logic
    }
}
```

### Step 5: Create Unified Shell Tool
**Rename & Refactor**: `PythonShellTool.kt` → `UnifiedShellTool.kt`

```kotlin
class UnifiedShellTool(
    private val context: Context
) : Tool {
    
    override val name: String = "unified_shell"
    
    override val description: String = 
        "Execute Python or JavaScript code to process files, create visualizations, " +
        "and perform computational tasks. Supports BOTH languages with automatic detection. " +
        "Python: Pre-installed libraries (ffmpeg-python, Pillow, pypdf, python-pptx, pandas, numpy). " +
        "JavaScript: Pre-installed libraries (D3.js for data visualization). " +
        "Perfect for infographics, charts, data processing, media editing, etc."
    
    private val pythonExecutor = PythonExecutor(context)
    private val jsExecutor = JavaScriptExecutor(context)
    
    override suspend fun execute(params: Map<String, Any>): ToolResult {
        val code = params["code"] as? String
            ?: return ToolResult.error("code parameter required")
        
        // Detect language
        val language = params["language"] as? String
            ?: LanguageDetector.detectLanguage(code).name.lowercase()
        
        return when (language.lowercase()) {
            "python", "py" -> executePython(code)
            "javascript", "js" -> executeJavaScript(code)
            else -> ToolResult.error("Unsupported language: $language. Use 'python' or 'javascript'")
        }
    }
    
    private suspend fun executePython(code: String): ToolResult {
        val result = pythonExecutor.execute(code)
        return if (result.success) {
            ToolResult.success(name, result.output)
        } else {
            ToolResult.error(result.error ?: "Execution failed")
        }
    }
    
    private suspend fun executeJavaScript(code: String): ToolResult {
        val result = jsExecutor.execute(code)
        return if (result.success) {
            ToolResult.success(name, result.output)
        } else {
            ToolResult.error(result.error ?: "Execution failed")
        }
    }
}
```

---

## D3.js Integration

### Download D3.js
**Location**: `app/src/main/assets/js/d3.min.js`

Download from: https://d3js.org/d3.v7.min.js

### D3.js for SVG Generation (Server-side)

Since Android doesn't have DOM, we'll use D3.js with:
1. **jsdom** polyfill (lightweight DOM implementation)
2. **Canvas/SVG string generation** (build SVG as strings)

**Alternative Approach**: Use D3.js to generate SVG strings, then render with Android's SVG libraries.

---

## Updated Documentation

### unified_shell_guide.md

```markdown
# Unified Shell Guide (Python + JavaScript)

The agent has access to a multi-language shell that supports both Python and JavaScript.

## Language Selection

The shell AUTO-DETECTS the language from your code. You can also specify explicitly:

```json
{
  "tool": "unified_shell",
  "params": {
    "code": "console.log('Hello from JS')",
    "language": "javascript"
  }
}
```

## Python Examples
[... keep all existing Python examples ...]

## JavaScript Examples

### Basic JavaScript
```javascript
const message = "Hello from JavaScript!";
console.log(message);

const numbers = [1, 2, 3, 4, 5];
const sum = numbers.reduce((a, b) => a + b, 0);
console.log("Sum:", sum);
```

### D3.js Data Visualization
```javascript
// D3.js is pre-installed!
const data = [30, 86, 168, 281, 303, 365];

// Create SVG string
const svg = `
<svg width="500" height="300">
  ${data.map((d, i) => 
    `<rect x="${i * 70}" y="${300 - d}" width="60" height="${d}" fill="steelblue"/>`
  ).join('')}
</svg>
`;

console.log(svg);
// Save SVG to file
// fs.writeFileSync('chart.svg', svg);
```
```

---

## Testing Strategy

### Unit Tests
- [ ] LanguageDetector correctly identifies Python code
- [ ] LanguageDetector correctly identifies JavaScript code
- [ ] PythonExecutor executes simple Python
- [ ] JavaScriptExecutor executes simple JavaScript
- [ ] UnifiedShellTool routes to correct executor

### Integration Tests
- [ ] Python code with imports works
- [ ] JavaScript code with D3.js works
- [ ] Auto-detection works without explicit language param
- [ ] Error handling for both languages
- [ ] Console.log output captured correctly

---

## Migration Path

1. ✅ Keep PythonShellTool working (backward compatibility)
2. ✅ Add UnifiedShellTool alongside
3. ✅ Update agent prompt to prefer unified_shell
4. ⏳ Deprecate python_shell in future (optional)

---

## File Structure

```
app/src/main/java/com/blurr/voice/tools/
├── shell/
│   ├── LanguageDetector.kt
│   ├── PythonExecutor.kt
│   ├── JavaScriptExecutor.kt
│   └── ExecutionResult.kt
├── PythonShellTool.kt (keep for backward compat)
└── UnifiedShellTool.kt (new)

app/src/main/assets/
├── prompts/
│   ├── python_shell_guide.md (existing)
│   └── unified_shell_guide.md (new)
└── js/
    ├── d3.min.js
    └── (other JS libraries)
```

---

## Next Steps After Implementation

1. Test Python execution (ensure no regression)
2. Test JavaScript execution (simple examples)
3. Test D3.js loading and basic usage
4. Update system prompt
5. Create comprehensive JavaScript examples
6. Ready for Phase 3: Story 4.12 final implementation

---

**READY TO IMPLEMENT!**

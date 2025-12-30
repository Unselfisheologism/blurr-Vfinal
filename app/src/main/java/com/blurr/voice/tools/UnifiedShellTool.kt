package com.blurr.voice.tools

import android.content.Context
import android.util.Log
import com.blurr.voice.tools.shell.ExecutionResult
import com.blurr.voice.tools.shell.JavaScriptExecutor
import com.blurr.voice.tools.shell.LanguageDetector
import com.blurr.voice.tools.shell.PythonExecutor
import com.blurr.voice.tools.shell.ShellLanguage
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/**
 * Unified Shell Tool - Execute Python or JavaScript code
 * 
 * Automatically detects language or accepts explicit language parameter.
 * 
 * Supports:
 * - Python 3.8 (via Chaquopy)
 * - JavaScript ES6 (via Rhino)
 * - Pre-installed libraries for both languages
 * - Console output capture
 * - File system access
 */
class UnifiedShellTool(
    private val context: Context
) : BaseTool() {

    companion object {
        private const val TAG = "UnifiedShellTool"
    }

    override val name: String = "unified_shell"

    override val description: String = """
        Execute Python or JavaScript code to process files, create visualizations, and perform 
        computational tasks. Supports BOTH languages with automatic detection or explicit specification.
        
        **Python**: Pre-installed libraries (ffmpeg-python, Pillow, pypdf, python-pptx, pandas, numpy, 
        requests). Can pip_install additional packages on-demand.
        
        **JavaScript**: Pre-installed libraries (D3.js for data visualization). Includes console.log, 
        file system access (fs.writeFile, fs.readFile), and ES6 support.
        
        **Auto-detection**: The tool automatically detects whether code is Python or JavaScript based on 
        syntax patterns (const/let/var, import/from, function/def, etc.).
        
        **Use cases**: Data processing, chart generation, infographics (D3.js), document creation (PDFs, 
        PowerPoint), media editing (ffmpeg), web scraping, API calls, file operations.
        
        **Parameters**:
        - code (required): The code to execute
        - language (optional): "python" or "javascript" to override auto-detection
    """.trimIndent()

    override val parameters: List<ToolParameter> = listOf(
        ToolParameter(
            name = "code",
            type = "string",
            description = "The Python or JavaScript code to execute.",
            required = true
        ),
        ToolParameter(
            name = "language",
            type = "string",
            description = "Optional: 'python' or 'javascript' to override auto-detection",
            required = false,
            enum = listOf("python", "javascript", "py", "js", "auto")
        )
    )

    private val pythonExecutor by lazy { PythonExecutor(context) }
    private val jsExecutor by lazy { JavaScriptExecutor(context) }

    override suspend fun execute(
        params: Map<String, Any>,
        context: List<ToolResult>
    ): ToolResult = withContext(Dispatchers.IO) {
        val validation = validateParameters(params)
        if (validation.isFailure) {
            return@withContext ToolResult.error(name, validation.exceptionOrNull()?.message ?: "Invalid parameters")
        }
        val code = params["code"] as? String
            ?: return@withContext ToolResult.error(
                toolName = name,
                error = "Missing required parameter: code"
            )
        
        // Detect or get explicit language
        val languageParam = params["language"] as? String
        val language = if (languageParam != null) {
            LanguageDetector.fromString(languageParam)
        } else {
            LanguageDetector.detectLanguage(code)
        }
        
        Log.d(TAG, "Detected language: $language")
        
        // Execute based on language
        when (language) {
            ShellLanguage.PYTHON -> executePython(code)
            ShellLanguage.JAVASCRIPT -> executeJavaScript(code)
            ShellLanguage.UNKNOWN -> {
                // Default to Python if unsure (backward compatibility)
                Log.w(TAG, "Could not detect language, defaulting to Python")
                executePython(code)
            }
        }
    }
    
    /**
     * Execute Python code
     */
    private suspend fun executePython(code: String): ToolResult = withContext(Dispatchers.IO) {
        Log.d(TAG, "Executing Python code")
        
        val result = pythonExecutor.execute(code)
        
        return@withContext if (result.success) {
            ToolResult.success(
                toolName = name,
                result = result.output,
                data = mapOf(
                    "language" to "python",
                    "execution_time_ms" to result.executionTimeMs
                )
            )
        } else {
            ToolResult.error(
                toolName = name,
                error = result.error ?: "Python execution failed"
            )
        }
    }
    
    /**
     * Execute JavaScript code
     */
    private suspend fun executeJavaScript(code: String): ToolResult = withContext(Dispatchers.IO) {
        Log.d(TAG, "Executing JavaScript code")
        
        val result = jsExecutor.execute(code)
        
        return@withContext if (result.success) {
            ToolResult.success(
                toolName = name,
                result = result.output,
                data = mapOf(
                    "language" to "javascript",
                    "execution_time_ms" to result.executionTimeMs
                )
            )
        } else {
            ToolResult.error(
                toolName = name,
                error = result.error ?: "JavaScript execution failed"
            )
        }
    }
    
    /**
     * Get tool schema for LLM
     */
    fun getSchema(): Map<String, Any> = mapOf(
        "name" to name,
        "description" to description,
        "parameters" to mapOf(
            "type" to "object",
            "properties" to mapOf(
                "code" to mapOf(
                    "type" to "string",
                    "description" to "The Python or JavaScript code to execute. Language will be auto-detected."
                ),
                "language" to mapOf(
                    "type" to "string",
                    "description" to "Optional: 'python' or 'javascript' to override auto-detection",
                    "enum" to listOf("python", "javascript", "py", "js")
                )
            ),
            "required" to listOf("code")
        )
    )
}

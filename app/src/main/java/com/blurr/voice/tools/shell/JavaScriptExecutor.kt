package com.twent.voice.tools.shell

import android.content.Context
import android.util.Log
import org.mozilla.javascript.BaseFunction
import org.mozilla.javascript.Scriptable
import org.mozilla.javascript.Context as RhinoContext

/**
 * Executes JavaScript code using Rhino engine
 * 
 * Supports:
 * - ES5 JavaScript
 * - console.log output
 * - Pre-installed libraries (D3.js, etc.)
 * - File system access via Android APIs
 */
class JavaScriptExecutor(private val context: Context) {
    
    companion object {
        private const val TAG = "JavaScriptExecutor"
    }
    
    private var rhinoContext: RhinoContext? = null
    private var scope: Scriptable? = null
    private val outputBuffer = StringBuilder()
    
    /**
     * Initialize Rhino context and scope
     */
    private fun initializeContext() {
        if (rhinoContext == null) {
            rhinoContext = RhinoContext.enter().apply {
                // Interpreted mode for Android (no JIT compilation)
                optimizationLevel = -1
                // ES6 language version
                languageVersion = RhinoContext.VERSION_ES6
            }
            
            scope = rhinoContext!!.initStandardObjects()
            
            setupConsole()
            setupFileSystem()
            loadPreInstalledLibraries()
        }
    }
    
    /**
     * Execute JavaScript code
     */
    fun execute(code: String): ExecutionResult {
        val startTime = System.currentTimeMillis()
        outputBuffer.clear()
        
        return try {
            initializeContext()
            
            val result = rhinoContext!!.evaluateString(
                scope,
                code,
                "script.js",
                1,
                null
            )
            
            val output = if (outputBuffer.isNotEmpty()) {
                outputBuffer.toString()
            } else {
                RhinoContext.toString(result)
            }
            
            val executionTime = System.currentTimeMillis() - startTime
            ExecutionResult.success(output, executionTime)
            
        } catch (e: Exception) {
            Log.e(TAG, "JavaScript execution error", e)
            val executionTime = System.currentTimeMillis() - startTime
            ExecutionResult.error(
                "JavaScript Error: ${e.message ?: "Unknown error"}\n${e.stackTraceToString()}",
                e
            ).copy(executionTimeMs = executionTime)
        }
    }
    
    /**
     * Setup console object for logging
     */
    private fun setupConsole() {
        val console = rhinoContext!!.newObject(scope)
        scope!!.put("console", scope, console)
        
        // console.log
        val logFunction = object : BaseFunction() {
            override fun call(
                cx: RhinoContext,
                scope: Scriptable,
                thisObj: Scriptable?,
                args: Array<Any>
            ): Any {
                val message = args.joinToString(" ") { RhinoContext.toString(it) }
                outputBuffer.append(message).append("\n")
                Log.d(TAG, "JS console.log: $message")
                return message
            }
        }
        console.put("log", console, logFunction)
        
        // console.error
        val errorFunction = object : BaseFunction() {
            override fun call(
                cx: RhinoContext,
                scope: Scriptable,
                thisObj: Scriptable?,
                args: Array<Any>
            ): Any {
                val message = args.joinToString(" ") { RhinoContext.toString(it) }
                outputBuffer.append("[ERROR] ").append(message).append("\n")
                Log.e(TAG, "JS console.error: $message")
                return message
            }
        }
        console.put("error", console, errorFunction)
        
        // console.warn
        val warnFunction = object : BaseFunction() {
            override fun call(
                cx: RhinoContext,
                scope: Scriptable,
                thisObj: Scriptable?,
                args: Array<Any>
            ): Any {
                val message = args.joinToString(" ") { RhinoContext.toString(it) }
                outputBuffer.append("[WARN] ").append(message).append("\n")
                Log.w(TAG, "JS console.warn: $message")
                return message
            }
        }
        console.put("warn", console, warnFunction)
    }
    
    /**
     * Setup file system access (basic read/write)
     */
    private fun setupFileSystem() {
        val fs = rhinoContext!!.newObject(scope)
        scope!!.put("fs", scope, fs)
        
        // fs.writeFile(path, content)
        val writeFileFunction = object : BaseFunction() {
            override fun call(
                cx: RhinoContext,
                scope: Scriptable,
                thisObj: Scriptable?,
                args: Array<Any>
            ): Any {
                if (args.size < 2) {
                    throw IllegalArgumentException("fs.writeFile requires path and content")
                }
                
                val path = RhinoContext.toString(args[0])
                val content = RhinoContext.toString(args[1])
                
                val file = java.io.File(context.cacheDir, path)
                file.parentFile?.mkdirs()
                file.writeText(content)
                
                outputBuffer.append("File written: ${file.absolutePath}\n")
                return file.absolutePath
            }
        }
        fs.put("writeFile", fs, writeFileFunction)
        
        // fs.readFile(path)
        val readFileFunction = object : BaseFunction() {
            override fun call(
                cx: RhinoContext,
                scope: Scriptable,
                thisObj: Scriptable?,
                args: Array<Any>
            ): Any {
                if (args.isEmpty()) {
                    throw IllegalArgumentException("fs.readFile requires path")
                }
                
                val path = RhinoContext.toString(args[0])
                val file = java.io.File(context.cacheDir, path)
                
                if (!file.exists()) {
                    throw java.io.FileNotFoundException("File not found: $path")
                }
                
                return file.readText()
            }
        }
        fs.put("readFile", fs, readFileFunction)
    }
    
    /**
     * Load pre-installed JavaScript libraries
     */
    private fun loadPreInstalledLibraries() {
        // Load D3.js if available in assets
        try {
            val d3js = context.assets.open("js/d3.min.js").bufferedReader().use { it.readText() }
            rhinoContext!!.evaluateString(scope, d3js, "d3.js", 1, null)
            Log.d(TAG, "D3.js loaded successfully")
        } catch (e: Exception) {
            Log.w(TAG, "D3.js not found in assets (will be added in Phase 3): ${e.message}")
        }
        
        // Load other libraries as needed
        // Chart.js, etc.
    }
    
    /**
     * Clean up resources
     */
    fun cleanup() {
        try {
            rhinoContext?.let {
                RhinoContext.exit()
                rhinoContext = null
                scope = null
            }
        } catch (e: Exception) {
            Log.w(TAG, "Error during cleanup: ${e.message}")
        }
    }
}

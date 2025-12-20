package com.twent.voice.tools.shell

import android.content.Context
import android.util.Log
import com.chaquo.python.Python
import com.chaquo.python.PyException

/**
 * Executes Python code using Chaquopy
 * 
 * Supports:
 * - Python 3.8
 * - Pre-installed libraries (ffmpeg-python, Pillow, pypdf, python-pptx, etc.)
 * - Dynamic pip_install for additional packages
 */
class PythonExecutor(private val context: Context) {
    
    companion object {
        private const val TAG = "PythonExecutor"
        
        // Pre-installed core libraries
        private val CORE_LIBRARIES = setOf(
            "ffmpeg-python",
            "Pillow",
            "pypdf",
            "python-pptx",
            "python-docx",
            "openpyxl",
            "pandas",
            "numpy",
            "requests"
        )
    }
    
    private val python: Python by lazy {
        Python.getInstance()
    }
    
    /**
     * Execute Python code
     */
    fun execute(code: String): ExecutionResult {
        val startTime = System.currentTimeMillis()
        
        return try {
            // Get main module
            val mainModule = python.getModule("__main__")
            
            // Capture stdout
            val io = python.getModule("io")
            val sys = python.getModule("sys")
            val stringIO = io.callAttr("StringIO")
            
            sys.put("stdout", stringIO)
            
            // Execute code
            python.getModule("builtins").callAttr("exec", code, mainModule)
            
            // Get output
            val output = stringIO.callAttr("getvalue").toString()
            
            val executionTime = System.currentTimeMillis() - startTime
            ExecutionResult.success(output, executionTime)
            
        } catch (e: PyException) {
            Log.e(TAG, "Python execution error", e)
            val executionTime = System.currentTimeMillis() - startTime
            ExecutionResult.error(
                "Python Error: ${e.message ?: "Unknown error"}",
                e
            ).copy(executionTimeMs = executionTime)
        } catch (e: Exception) {
            Log.e(TAG, "Python execution error", e)
            val executionTime = System.currentTimeMillis() - startTime
            ExecutionResult.error(
                "Python Error: ${e.message ?: "Unknown error"}",
                e
            ).copy(executionTimeMs = executionTime)
        }
    }
    
    /**
     * Install a Python package using pip
     */
    fun installPackage(packageName: String): Boolean {
        return try {
            val pip = python.getModule("pip")
            pip.callAttr("main", listOf("install", packageName))
            Log.d(TAG, "Successfully installed package: $packageName")
            true
        } catch (e: Exception) {
            Log.e(TAG, "Failed to install package: $packageName", e)
            false
        }
    }
    
    /**
     * Check if a package is already installed
     */
    fun isPackageInstalled(packageName: String): Boolean {
        return try {
            python.getModule(packageName)
            true
        } catch (e: Exception) {
            false
        }
    }
    
    /**
     * Check if a package is in core libraries (pre-installed)
     */
    fun isCoreLibrary(packageName: String): Boolean {
        return CORE_LIBRARIES.contains(packageName)
    }
}

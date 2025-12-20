package com.twent.voice.tools

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.util.Log
import android.widget.Toast
import androidx.core.app.NotificationCompat
import com.twent.voice.R
import com.chaquo.python.Python
import com.chaquo.python.PyException
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeout
import org.json.JSONArray
import org.json.JSONObject
import java.io.File

/**
 * Python Shell Tool - Story 4.18
 * 
 * Executes Python code with access to pre-installed libraries (ffmpeg-python, Pillow, pypdf, etc.)
 * and dynamic package installation for any PyPI package.
 * 
 * This tool enables unlimited flexibility for:
 * - Video/audio compilation and editing (FFmpeg)
 * - Image processing and composition (Pillow)
 * - PDF manipulation and merging (pypdf)
 * - Document generation (python-docx, openpyxl)
 * - Data processing (pandas, numpy)
 * - And any other Python package from PyPI!
 * 
 * Pre-installed Core Libraries (instant execution):
 * - ffmpeg-python: Video/audio editing
 * - Pillow: Image processing
 * - pypdf: PDF manipulation
 * - python-docx: Word documents
 * - openpyxl: Excel files
 * - pandas: Data analysis
 * - numpy: Numerical operations
 * - requests: HTTP requests
 * 
 * Dynamic Installation:
 * Agent can install any package on-demand using pip_install('package_name')
 * Installation takes 30-60 seconds but packages are cached permanently.
 */
class PythonShellTool(
    private val context: Context
) : BaseTool() {
    
    companion object {
        private const val TAG = "PythonShellTool"
        private const val NOTIFICATION_CHANNEL_ID = "python_shell_channel"
        private const val NOTIFICATION_ID = 1001
        
        // Pre-installed core libraries
        private val CORE_LIBRARIES = setOf(
            "ffmpeg-python",
            "Pillow",
            "pypdf",
            "python-pptx",  // Story 4.11: PowerPoint generation
            "python-docx",
            "openpyxl",
            "pandas",
            "numpy",
            "requests"
        )
        
        // Cache of installed packages (loaded from storage)
        private val installedPackages = mutableSetOf<String>()
        
        init {
            installedPackages.addAll(CORE_LIBRARIES)
        }
    }
    
    private val python: Python by lazy {
        if (!Python.isStarted()) {
            Python.start(com.chaquo.python.android.AndroidPlatform(context))
        }
        Python.getInstance()
    }
    
    private val notificationManager by lazy {
        context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    }
    
    init {
        createNotificationChannel()
        loadInstalledPackagesCache()
    }
    
    override val name: String = "python_shell"
    
    override val description: String = 
        "Execute Python code to process files, edit media, convert formats, and perform any " +
        "computational task. Has access to PRE-INSTALLED libraries (ffmpeg-python, Pillow, " +
        "pypdf, python-pptx, pandas, numpy, etc.) for instant execution, OR can install additional packages " +
        "on-demand from PyPI (takes 30-60 seconds but cached permanently). " +
        "Use web_search to find best libraries for specific tasks. " +
        "Perfect for video compilation, audio mixing, image editing, PDF generation, PowerPoint creation, data processing, etc."
    
    override val parameters: List<ToolParameter> = listOf(
        ToolParameter(
            name = "code",
            type = "string",
            description = "Python code to execute. Can use pre-installed libraries immediately. " +
                    "For new packages, use: pip_install('package_name') before importing. " +
                    "Working directory: /cache/generated_*. All generated media files available there.",
            required = true
        ),
        ToolParameter(
            name = "packages_to_install",
            type = "array",
            description = "List of packages to install before executing code (optional). " +
                    "Example: ['qrcode', 'matplotlib']. Installation takes 30-60s per package. " +
                    "User will see notification during installation.",
            required = false
        ),
        ToolParameter(
            name = "timeout",
            type = "number",
            description = "Execution timeout in seconds (default: 60, max: 300 for installations)",
            required = false
        ),
        ToolParameter(
            name = "working_directory",
            type = "string",
            description = "Working directory for file operations (default: /cache)",
            required = false
        )
    )
    
    override suspend fun execute(
        params: Map<String, Any>,
        context: List<ToolResult>
    ): ToolResult {
        return try {
            // Validate parameters
            validateParameters(params).getOrThrow()
            
            // Extract parameters
            val code = getRequiredParam<String>(params, "code")
            val packagesToInstall = getOptionalParam<List<String>>(params, "packages_to_install", emptyList())
            val timeout = getOptionalParam<Int>(params, "timeout", 60).coerceIn(10, 300)
            val workingDir = getOptionalParam(params, "working_directory", 
                this.context.cacheDir.absolutePath)
            
            Log.d(TAG, "Executing Python code with timeout=$timeout, workingDir=$workingDir")
            
            // Step 1: Install packages if needed
            if (packagesToInstall.isNotEmpty()) {
                installPackages(packagesToInstall)
            }
            
            // Step 2: Check if code requests installations (pip_install calls)
            val requestedPackages = extractPackageInstallRequests(code)
            if (requestedPackages.isNotEmpty()) {
                installPackages(requestedPackages)
            }
            
            // Step 3: Execute Python code
            val result = executePythonCode(code, workingDir, timeout)
            
            ToolResult.success(
                toolName = name,
                result = result,
                data = mapOf(
                    "output" to result,
                    "working_directory" to workingDir,
                    "installed_packages" to installedPackages.toList()
                )
            )
            
        } catch (e: kotlinx.coroutines.TimeoutCancellationException) {
            ToolResult.failure(
                toolName = name,
                error = "Python code execution timed out after ${params["timeout"]} seconds"
            )
        } catch (e: PyException) {
            ToolResult.failure(
                toolName = name,
                error = "Python error: ${e.message}\n${e.stackTraceToString()}"
            )
        } catch (e: Exception) {
            Log.e(TAG, "Python execution error", e)
            ToolResult.failure(
                toolName = name,
                error = "Python execution error: ${e.message}"
            )
        }
    }
    
    /**
     * Execute Python code with timeout
     */
    private suspend fun executePythonCode(
        code: String,
        workingDir: String,
        timeout: Int
    ): String = withContext(Dispatchers.IO) {
        withTimeout(timeout * 1000L) {
            try {
                val module = python.getModule("__main__")
                
                // Inject helper functions and setup
                val wrappedCode = """
import sys
import os
import subprocess
from io import StringIO

# Set working directory
os.chdir('$workingDir')

# Helper function for package installation
def pip_install(package):
    '''Install package if not already installed'''
    try:
        __import__(package.replace('-', '_'))
        print(f"Package {package} already installed")
        return True
    except ImportError:
        print(f"Installing {package}...")
        try:
            subprocess.check_call([sys.executable, "-m", "pip", "install", package])
            print(f"Package {package} installed successfully")
            return True
        except Exception as e:
            print(f"Failed to install {package}: {e}")
            return False

# Capture stdout
_stdout = StringIO()
sys.stdout = _stdout

try:
    # User code
$code

    # Get captured output
    sys.stdout = sys.__stdout__
    output = _stdout.getvalue()
    if output:
        print(output)
    else:
        print("Code executed successfully")
        
except Exception as e:
    sys.stdout = sys.__stdout__
    print(f"Error: {type(e).__name__}: {str(e)}")
    import traceback
    traceback.print_exc()
                """.trimIndent()
                
                // Execute code
                module.callAttr("exec", wrappedCode)
                
                // Get output (Python prints will be captured in Android logs)
                "Code executed successfully. Check logs for output."
                
            } catch (e: PyException) {
                throw e
            } catch (e: Exception) {
                throw Exception("Python execution failed: ${e.message}", e)
            }
        }
    }
    
    /**
     * Install Python packages with user notification
     */
    private suspend fun installPackages(packages: List<String>) = withContext(Dispatchers.IO) {
        val newPackages = packages.filter { it !in installedPackages }
        
        if (newPackages.isEmpty()) {
            Log.d(TAG, "All packages already installed")
            return@withContext
        }
        
        // Show toast notification
        withContext(Dispatchers.Main) {
            Toast.makeText(
                context,
                "Installing ${newPackages.size} package(s). This may take 30-60 seconds...",
                Toast.LENGTH_LONG
            ).show()
        }
        
        // Show progress notification
        showProgressNotification(
            title = "Installing Python Packages",
            message = "Installing: ${newPackages.joinToString(", ")}"
        )
        
        try {
            newPackages.forEach { packageName ->
                Log.d(TAG, "Installing package: $packageName")
                
                val startTime = System.currentTimeMillis()
                installPackage(packageName)
                val duration = System.currentTimeMillis() - startTime
                
                installedPackages.add(packageName)
                Log.d(TAG, "Package $packageName installed in ${duration}ms")
            }
            
            // Save cache
            saveInstalledPackagesCache()
            
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
        try {
            val pip = python.getModule("pip")
            pip.callAttr("main", listOf("install", packageName))
        } catch (e: Exception) {
            // Fallback: Use subprocess
            val process = Runtime.getRuntime().exec(
                arrayOf("python3", "-m", "pip", "install", packageName)
            )
            val exitCode = process.waitFor()
            if (exitCode != 0) {
                throw Exception("pip install failed with exit code $exitCode")
            }
        }
    }
    
    /**
     * Extract package installation requests from code
     * Looks for: pip_install('package_name') or pip_install("package_name")
     */
    private fun extractPackageInstallRequests(code: String): List<String> {
        val regex = """pip_install\(['"]([^'"]+)['"]\)""".toRegex()
        return regex.findAll(code).map { it.groupValues[1] }.toList()
    }
    
    /**
     * Create notification channel for package installations
     */
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                "Python Package Installation",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows progress when installing Python packages"
            }
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    /**
     * Show progress notification for package installation
     */
    private fun showProgressNotification(title: String, message: String) {
        val notification = NotificationCompat.Builder(context, NOTIFICATION_CHANNEL_ID)
            .setSmallIcon(android.R.drawable.stat_sys_download)
            .setContentTitle(title)
            .setContentText(message)
            .setProgress(0, 0, true) // Indeterminate progress
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
        
        notificationManager.notify(NOTIFICATION_ID, notification)
    }
    
    /**
     * Dismiss progress notification
     */
    private fun dismissProgressNotification() {
        notificationManager.cancel(NOTIFICATION_ID)
    }
    
    /**
     * Load installed packages cache from storage
     */
    private fun loadInstalledPackagesCache() {
        try {
            val cacheFile = File(context.filesDir, "installed_python_packages.json")
            if (cacheFile.exists()) {
                val json = cacheFile.readText()
                val jsonArray = JSONArray(json)
                for (i in 0 until jsonArray.length()) {
                    installedPackages.add(jsonArray.getString(i))
                }
                Log.d(TAG, "Loaded ${installedPackages.size} cached packages")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to load package cache", e)
        }
    }
    
    /**
     * Save installed packages cache to storage
     */
    private fun saveInstalledPackagesCache() {
        try {
            val cacheFile = File(context.filesDir, "installed_python_packages.json")
            val jsonArray = JSONArray(installedPackages.toList())
            cacheFile.writeText(jsonArray.toString())
            Log.d(TAG, "Saved ${installedPackages.size} packages to cache")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to save package cache", e)
        }
    }
}

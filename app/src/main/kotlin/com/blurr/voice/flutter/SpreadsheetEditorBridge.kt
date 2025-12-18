// Platform bridge for Spreadsheet Editor communication
package com.blurr.voice.flutter

import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.json.JSONObject
import com.blurr.voice.agent.ToolExecutor

/**
 * Bridge for communication between Kotlin (Android) and Flutter (Spreadsheet Editor)
 * Handles:
 * - Loading/creating spreadsheets
 * - AI agent integration for spreadsheet operations
 * - File picker for import/export
 */
class SpreadsheetEditorBridge(
    private val context: Context,
    flutterEngine: FlutterEngine
) {
    companion object {
        private const val CHANNEL = "com.blurr.spreadsheet_editor/bridge"
        private const val TAG = "SpreadsheetEditorBridge"
    }

    private val methodChannel: MethodChannel = MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        CHANNEL
    )
    
    private val toolExecutor: ToolExecutor by lazy {
        ToolExecutor(context)
    }

    init {
        setupMethodCallHandler()
    }

    private fun setupMethodCallHandler() {
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "executeAgentTask" -> {
                    val prompt = call.argument<String>("prompt")
                    if (prompt != null) {
                        executeAgentTask(prompt, result)
                    } else {
                        result.error("INVALID_ARGS", "Prompt is required", null)
                    }
                }
                
                "pickFile" -> {
                    pickFile(result)
                }
                
                "saveFile" -> {
                    val fileName = call.argument<String>("fileName")
                    val content = call.argument<ByteArray>("content")
                    if (fileName != null && content != null) {
                        saveFile(fileName, content, result)
                    } else {
                        result.error("INVALID_ARGS", "fileName and content required", null)
                    }
                }
                
                "shareFile" -> {
                    val filePath = call.argument<String>("filePath")
                    if (filePath != null) {
                        shareFile(filePath, result)
                    } else {
                        result.error("INVALID_ARGS", "filePath is required", null)
                    }
                }
                
                "checkProStatus" -> {
                    checkProStatus(result)
                }
                
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    /**
     * Execute AI agent task for spreadsheet operations
     */
    private fun executeAgentTask(prompt: String, result: MethodChannel.Result) {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                Log.d(TAG, "Executing agent task: $prompt")
                
                // Execute task using ToolExecutor
                val response = toolExecutor.executeTask(prompt)
                
                CoroutineScope(Dispatchers.Main).launch {
                    result.success(
                        mapOf(
                            "success" to true,
                            "result" to response
                        )
                    )
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error executing agent task", e)
                CoroutineScope(Dispatchers.Main).launch {
                    result.success(
                        mapOf(
                            "success" to false,
                            "error" to e.message
                        )
                    )
                }
            }
        }
    }

    /**
     * Pick file for import
     */
    private fun pickFile(result: MethodChannel.Result) {
        // TODO: Implement file picker
        // Use Intent.ACTION_GET_CONTENT with MIME type for Excel files
        result.error("NOT_IMPLEMENTED", "File picker not yet implemented", null)
    }

    /**
     * Save file to device
     */
    private fun saveFile(fileName: String, content: ByteArray, result: MethodChannel.Result) {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val file = java.io.File(context.getExternalFilesDir(null), fileName)
                file.writeBytes(content)
                
                CoroutineScope(Dispatchers.Main).launch {
                    result.success(
                        mapOf(
                            "success" to true,
                            "filePath" to file.absolutePath
                        )
                    )
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error saving file", e)
                CoroutineScope(Dispatchers.Main).launch {
                    result.error("SAVE_ERROR", e.message, null)
                }
            }
        }
    }

    /**
     * Share file using Android share sheet
     */
    private fun shareFile(filePath: String, result: MethodChannel.Result) {
        // TODO: Implement file sharing
        // Use Intent.ACTION_SEND with FileProvider
        result.error("NOT_IMPLEMENTED", "File sharing not yet implemented", null)
    }

    /**
     * Check Pro subscription status
     */
    private fun checkProStatus(result: MethodChannel.Result) {
        try {
            // TODO: Integrate with FreemiumManager
            result.success(
                mapOf(
                    "isPro" to false,
                    "features" to mapOf(
                        "aiGeneration" to false,
                        "advancedFormulas" to false,
                        "charts" to false
                    )
                )
            )
        } catch (e: Exception) {
            Log.e(TAG, "Error checking Pro status", e)
            result.error("PRO_CHECK_ERROR", e.message, null)
        }
    }

    /**
     * Load existing document
     * Called from Activity when launched with document ID
     */
    fun loadDocument(documentId: String) {
        methodChannel.invokeMethod(
            "loadDocument",
            mapOf("documentId" to documentId)
        )
    }

    /**
     * Create spreadsheet from AI prompt
     * Called from Activity when launched with prompt
     */
    fun createFromPrompt(prompt: String) {
        methodChannel.invokeMethod(
            "createFromPrompt",
            mapOf("prompt" to prompt)
        )
    }

    /**
     * Dispose resources
     */
    fun dispose() {
        methodChannel.setMethodCallHandler(null)
    }
}

package com.twent.voice.apps.base

import android.content.ContentValues
import android.content.Context
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import com.twent.voice.tools.ComposioTool
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileOutputStream

/**
 * Helper class for exporting content from AI-native apps.
 * 
 * Provides:
 * - Local file exports (MediaStore for Android 10+, File for older)
 * - Integration exports via Composio (Google Docs, Sheets, Drive, etc.)
 * - Common export formats (PDF, CSV, images, audio, video)
 * 
 * Usage:
 * ```kotlin
 * // Export to local file
 * val uri = exportHelper.exportToFile(
 *     content = "Document content".toByteArray(),
 *     fileName = "my_document.txt",
 *     mimeType = "text/plain",
 *     directory = ExportDirectory.DOCUMENTS
 * )
 * 
 * // Export to Google Docs
 * val result = exportHelper.exportToGoogleDocs(
 *     title = "My Document",
 *     content = "Document content"
 * )
 * ```
 */
class ExportHelper(
    private val context: Context,
    private val composioTool: ComposioTool
) {

    /**
     * Export content to a local file.
     * 
     * @param content Byte array of content to export
     * @param fileName Name of the file (with extension)
     * @param mimeType MIME type of the content
     * @param directory Target directory (Documents, Pictures, Movies, etc.)
     * @return Uri of the saved file, or null if failed
     */
    suspend fun exportToFile(
        content: ByteArray,
        fileName: String,
        mimeType: String,
        directory: ExportDirectory = ExportDirectory.DOCUMENTS
    ): ExportResult = withContext(Dispatchers.IO) {
        try {
            val uri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                // Use MediaStore for Android 10+
                exportViaMediaStore(content, fileName, mimeType, directory)
            } else {
                // Use legacy file system for older Android
                exportViaFileSystem(content, fileName, directory)
            }
            
            if (uri != null) {
                ExportResult.Success(uri, fileName)
            } else {
                ExportResult.Error("Failed to save file")
            }
        } catch (e: Exception) {
            ExportResult.Error(e.message ?: "Export failed")
        }
    }

    /**
     * Export via MediaStore (Android 10+).
     */
    private fun exportViaMediaStore(
        content: ByteArray,
        fileName: String,
        mimeType: String,
        directory: ExportDirectory
    ): Uri? {
        val contentValues = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
            put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
            put(MediaStore.MediaColumns.RELATIVE_PATH, directory.path)
        }

        val collection = when (directory) {
            ExportDirectory.DOCUMENTS -> MediaStore.Files.getContentUri("external")
            ExportDirectory.PICTURES -> MediaStore.Images.Media.getContentUri("external")
            ExportDirectory.MOVIES -> MediaStore.Video.Media.getContentUri("external")
            ExportDirectory.MUSIC -> MediaStore.Audio.Media.getContentUri("external")
            ExportDirectory.DOWNLOADS -> MediaStore.Downloads.EXTERNAL_CONTENT_URI
        }

        val uri = context.contentResolver.insert(collection, contentValues)
        
        uri?.let {
            context.contentResolver.openOutputStream(it)?.use { outputStream ->
                outputStream.write(content)
                outputStream.flush()
            }
        }
        
        return uri
    }

    /**
     * Export via file system (Android < 10).
     */
    @Suppress("DEPRECATION")
    private fun exportViaFileSystem(
        content: ByteArray,
        fileName: String,
        directory: ExportDirectory
    ): Uri? {
        val dir = when (directory) {
            ExportDirectory.DOCUMENTS -> Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS)
            ExportDirectory.PICTURES -> Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
            ExportDirectory.MOVIES -> Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES)
            ExportDirectory.MUSIC -> Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MUSIC)
            ExportDirectory.DOWNLOADS -> Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
        }

        if (!dir.exists()) {
            dir.mkdirs()
        }

        val file = File(dir, fileName)
        FileOutputStream(file).use { outputStream ->
            outputStream.write(content)
            outputStream.flush()
        }

        return Uri.fromFile(file)
    }

    /**
     * Export text document to Google Docs via Composio.
     */
    suspend fun exportToGoogleDocs(
        title: String,
        content: String
    ): ExportResult = withContext(Dispatchers.IO) {
        try {
            val result = composioTool.execute(mapOf(
                "action" to "GOOGLEDOCS_CREATE_DOCUMENT",
                "title" to title,
                "content" to content
            ))

            when (result) {
                is com.twent.voice.tools.Tool.ToolResult.Success -> {
                    // Extract document URL from result if available
                    ExportResult.Success(null, title, result.result)
                }
                is com.twent.voice.tools.Tool.ToolResult.Error -> {
                    ExportResult.Error(result.error)
                }
            }
        } catch (e: Exception) {
            ExportResult.Error(e.message ?: "Failed to export to Google Docs")
        }
    }

    /**
     * Export spreadsheet data to Google Sheets via Composio.
     */
    suspend fun exportToGoogleSheets(
        title: String,
        csvData: String
    ): ExportResult = withContext(Dispatchers.IO) {
        try {
            val result = composioTool.execute(mapOf(
                "action" to "GOOGLESHEETS_CREATE_SPREADSHEET",
                "title" to title,
                "data" to csvData
            ))

            when (result) {
                is com.twent.voice.tools.Tool.ToolResult.Success -> {
                    ExportResult.Success(null, title, result.result)
                }
                is com.twent.voice.tools.Tool.ToolResult.Error -> {
                    ExportResult.Error(result.error)
                }
            }
        } catch (e: Exception) {
            ExportResult.Error(e.message ?: "Failed to export to Google Sheets")
        }
    }

    /**
     * Generic Composio export action.
     */
    suspend fun exportViaComposio(
        action: String,
        params: Map<String, Any>
    ): ExportResult = withContext(Dispatchers.IO) {
        try {
            val result = composioTool.execute(params + ("action" to action))

            when (result) {
                is com.twent.voice.tools.Tool.ToolResult.Success -> {
                    ExportResult.Success(null, params["title"]?.toString() ?: "Export", result.result)
                }
                is com.twent.voice.tools.Tool.ToolResult.Error -> {
                    ExportResult.Error(result.error)
                }
            }
        } catch (e: Exception) {
            ExportResult.Error(e.message ?: "Export via Composio failed")
        }
    }

    /**
     * Export to app's internal storage (for temporary/cache files).
     */
    suspend fun exportToAppStorage(
        content: ByteArray,
        fileName: String,
        subdirectory: String = ""
    ): ExportResult = withContext(Dispatchers.IO) {
        try {
            val dir = if (subdirectory.isNotEmpty()) {
                File(context.filesDir, subdirectory).apply { mkdirs() }
            } else {
                context.filesDir
            }

            val file = File(dir, fileName)
            FileOutputStream(file).use { outputStream ->
                outputStream.write(content)
                outputStream.flush()
            }

            ExportResult.Success(Uri.fromFile(file), fileName)
        } catch (e: Exception) {
            ExportResult.Error(e.message ?: "Failed to save to app storage")
        }
    }
}

/**
 * Target directories for exports.
 */
enum class ExportDirectory(val path: String) {
    DOCUMENTS(Environment.DIRECTORY_DOCUMENTS),
    PICTURES(Environment.DIRECTORY_PICTURES),
    MOVIES(Environment.DIRECTORY_MOVIES),
    MUSIC(Environment.DIRECTORY_MUSIC),
    DOWNLOADS(Environment.DIRECTORY_DOWNLOADS)
}

/**
 * Result of an export operation.
 */
sealed class ExportResult {
    /**
     * Successful export.
     * @param uri Local file URI (null for cloud exports)
     * @param fileName Name of the exported file
     * @param cloudUrl URL of cloud resource (for Composio exports)
     */
    data class Success(
        val uri: Uri?,
        val fileName: String,
        val cloudUrl: String? = null
    ) : ExportResult()

    /**
     * Export failed.
     */
    data class Error(val message: String) : ExportResult()
}

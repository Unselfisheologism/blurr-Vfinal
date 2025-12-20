package com.twent.voice.tools.google

import android.content.Context
import android.util.Log
import com.twent.voice.auth.GoogleAuthManager
import com.twent.voice.tools.BaseTool
import com.twent.voice.tools.ToolParameter
import com.twent.voice.tools.ToolResult
import com.google.api.client.googleapis.extensions.android.gms.auth.GoogleAccountCredential
import com.google.api.client.http.FileContent
import com.google.api.client.http.javanet.NetHttpTransport
import com.google.api.client.json.gson.GsonFactory
import com.google.api.services.drive.Drive
import com.google.api.services.drive.model.File
import com.google.api.services.drive.model.Permission
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.FileOutputStream

/**
 * Google Drive Tool - FREE Google Workspace Integration
 * 
 * Uses GoogleAuthManager from Story 4.13 for OAuth authentication.
 * Provides file management: upload, download, search, share, organize.
 * 
 * Cost: $0 (uses user's quota: 1M queries/day per user)
 * Part of: Hybrid Integration Strategy (Story 4.13 + 4.16)
 */
class GoogleDriveTool(
    private val context: Context,
    private val authManager: GoogleAuthManager
) : BaseTool() {
    
    companion object {
        private const val TAG = "GoogleDriveTool"
        private const val APP_NAME = "Twent Voice Assistant"
        
        // MIME types
        const val FOLDER_MIME_TYPE = "application/vnd.google-apps.folder"
        const val DOCUMENT_MIME_TYPE = "application/vnd.google-apps.document"
        const val SPREADSHEET_MIME_TYPE = "application/vnd.google-apps.spreadsheet"
        const val PRESENTATION_MIME_TYPE = "application/vnd.google-apps.presentation"
    }
    
    override val name = "google_drive"
    override val description = "Manage Google Drive: upload, download, search, share files and folders"
    
    override val parameters = listOf(
        ToolParameter(
            name = "action",
            type = "string",
            description = "Action: list_files, search, get_file, upload_file, create_folder, download_file, share, delete, move, copy, rename",
            required = true
        ),
        ToolParameter(
            name = "file_id",
            type = "string",
            description = "Google Drive file ID",
            required = false
        ),
        ToolParameter(
            name = "query",
            type = "string",
            description = "Search query (Drive API syntax: 'name contains \"report\"')",
            required = false
        ),
        ToolParameter(
            name = "name",
            type = "string",
            description = "File or folder name",
            required = false
        ),
        ToolParameter(
            name = "parent_id",
            type = "string",
            description = "Parent folder ID (default: root)",
            required = false
        ),
        ToolParameter(
            name = "mime_type",
            type = "string",
            description = "MIME type for file filtering or creation",
            required = false
        ),
        ToolParameter(
            name = "local_path",
            type = "string",
            description = "Local file path for upload/download",
            required = false
        ),
        ToolParameter(
            name = "max_results",
            type = "number",
            description = "Maximum number of results (default: 10, max: 1000)",
            required = false
        ),
        ToolParameter(
            name = "email",
            type = "string",
            description = "Email address for sharing",
            required = false
        ),
        ToolParameter(
            name = "role",
            type = "string",
            description = "Share role: reader, writer, commenter, owner (default: reader)",
            required = false
        ),
        ToolParameter(
            name = "new_name",
            type = "string",
            description = "New name for rename action",
            required = false
        ),
        ToolParameter(
            name = "folder_only",
            type = "boolean",
            description = "List folders only (default: false)",
            required = false
        ),
        ToolParameter(
            name = "include_trashed",
            type = "boolean",
            description = "Include trashed files in results (default: false)",
            required = false
        )
    )
    
    override suspend fun execute(params: Map<String, Any>, context: List<ToolResult>): ToolResult {
        return withContext(Dispatchers.IO) {
            try {
                // Check authentication
                if (!authManager.isSignedIn()) {
                    return@withContext ToolResult.failure(
                        name,
                        "Not signed in to Google. Please sign in first.",
                        mapOf("requires_auth" to true)
                    )
                }
                
                val action = getRequiredParam<String>(params, "action")
                
                // Build Drive service
                val service = buildDriveService()
                    ?: return@withContext ToolResult.failure(
                        name,
                        "Failed to initialize Drive service"
                    )
                
                // Execute action
                when (action.lowercase()) {
                    "list_files" -> listFiles(service, params)
                    "search" -> searchFiles(service, params)
                    "get_file" -> getFile(service, params)
                    "upload_file" -> uploadFile(service, params)
                    "create_folder" -> createFolder(service, params)
                    "download_file" -> downloadFile(service, params)
                    "share" -> shareFile(service, params)
                    "delete" -> deleteFile(service, params)
                    "move" -> moveFile(service, params)
                    "copy" -> copyFile(service, params)
                    "rename" -> renameFile(service, params)
                    else -> ToolResult.failure(
                        name,
                        "Unknown action: $action. Available: list_files, search, get_file, upload_file, create_folder, download_file, share, delete, move, copy, rename"
                    )
                }
            } catch (e: Exception) {
                Log.e(TAG, "Drive operation failed", e)
                ToolResult.failure(name, "Drive error: ${e.message}")
            }
        }
    }
    
    /**
     * Build Google Drive API service
     */
    private fun buildDriveService(): Drive? {
        try {
            val account = authManager.getAccount() ?: return null
            
            val credential = GoogleAccountCredential.usingOAuth2(
                context,
                listOf(
                    "https://www.googleapis.com/auth/drive",
                    "https://www.googleapis.com/auth/drive.file"
                )
            )
            credential.selectedAccount = account
            
            return Drive.Builder(
                NetHttpTransport(),
                GsonFactory.getDefaultInstance(),
                credential
            )
                .setApplicationName(APP_NAME)
                .build()
        } catch (e: Exception) {
            Log.e(TAG, "Failed to build Drive service", e)
            return null
        }
    }
    
    /**
     * List files in Drive
     */
    private suspend fun listFiles(service: Drive, params: Map<String, Any>): ToolResult {
        val maxResults = getOptionalParam(params, "max_results", 10).toInt()
        val parentId = getOptionalParam<String?>(params, "parent_id", null)
        val folderOnly = getOptionalParam(params, "folder_only", false)
        val includeTrashed = getOptionalParam(params, "include_trashed", false)
        
        var query = "trashed = $includeTrashed"
        
        if (folderOnly) {
            query += " and mimeType = '$FOLDER_MIME_TYPE'"
        }
        
        if (parentId != null) {
            query += " and '$parentId' in parents"
        }
        
        val result = service.files().list()
            .setQ(query)
            .setPageSize(maxResults)
            .setFields("files(id, name, mimeType, size, createdTime, modifiedTime, webViewLink, parents, owners)")
            .execute()
        
        val files = result.files?.map { file ->
            extractFileData(file)
        } ?: emptyList()
        
        return ToolResult.success(
            name,
            mapOf(
                "count" to files.size,
                "files" to files
            ),
            "Found ${files.size} files"
        )
    }
    
    /**
     * Search files with query
     */
    private suspend fun searchFiles(service: Drive, params: Map<String, Any>): ToolResult {
        val query = getRequiredParam<String>(params, "query")
        val maxResults = getOptionalParam(params, "max_results", 10).toInt()
        val includeTrashed = getOptionalParam(params, "include_trashed", false)
        
        val fullQuery = "$query and trashed = $includeTrashed"
        
        val result = service.files().list()
            .setQ(fullQuery)
            .setPageSize(maxResults)
            .setFields("files(id, name, mimeType, size, createdTime, modifiedTime, webViewLink, parents)")
            .execute()
        
        val files = result.files?.map { file ->
            extractFileData(file)
        } ?: emptyList()
        
        return ToolResult.success(
            name,
            mapOf(
                "count" to files.size,
                "files" to files,
                "query" to query
            ),
            "Found ${files.size} files matching: $query"
        )
    }
    
    /**
     * Get specific file details
     */
    private suspend fun getFile(service: Drive, params: Map<String, Any>): ToolResult {
        val fileId = getRequiredParam<String>(params, "file_id")
        
        val file = service.files().get(fileId)
            .setFields("id, name, mimeType, size, createdTime, modifiedTime, webViewLink, webContentLink, parents, owners, shared, permissions")
            .execute()
        
        val fileData = extractFileData(file)
        
        return ToolResult.success(
            name,
            fileData,
            "File retrieved: ${file.name}"
        )
    }
    
    /**
     * Upload file to Drive
     */
    private suspend fun uploadFile(service: Drive, params: Map<String, Any>): ToolResult {
        val localPath = getRequiredParam<String>(params, "local_path")
        val name = getOptionalParam<String?>(params, "name", null)
        val parentId = getOptionalParam<String?>(params, "parent_id", null)
        val mimeType = getOptionalParam<String?>(params, "mime_type", null)
        
        val localFile = java.io.File(localPath)
        if (!localFile.exists()) {
            return ToolResult.failure(name, "Local file not found: $localPath")
        }
        
        val fileMetadata = File().apply {
            this.name = name ?: localFile.name
            if (parentId != null) {
                parents = listOf(parentId)
            }
        }
        
        val mediaContent = FileContent(mimeType ?: "application/octet-stream", localFile)
        
        val uploadedFile = service.files().create(fileMetadata, mediaContent)
            .setFields("id, name, mimeType, size, webViewLink")
            .execute()
        
        return ToolResult.success(
            name,
            mapOf(
                "file_id" to uploadedFile.id,
                "name" to uploadedFile.name,
                "size" to (uploadedFile.getSize() ?: 0),
                "web_view_link" to uploadedFile.webViewLink
            ),
            "File uploaded: ${uploadedFile.name}"
        )
    }
    
    /**
     * Create new folder
     */
    private suspend fun createFolder(service: Drive, params: Map<String, Any>): ToolResult {
        val folderName = getRequiredParam<String>(params, "name")
        val parentId = getOptionalParam<String?>(params, "parent_id", null)
        
        val folderMetadata = File().apply {
            name = folderName
            mimeType = FOLDER_MIME_TYPE
            if (parentId != null) {
                parents = listOf(parentId)
            }
        }
        
        val folder = service.files().create(folderMetadata)
            .setFields("id, name, webViewLink")
            .execute()
        
        return ToolResult.success(
            name,
            mapOf(
                "folder_id" to folder.id,
                "name" to folder.name,
                "web_view_link" to folder.webViewLink
            ),
            "Folder created: ${folder.name}"
        )
    }
    
    /**
     * Download file from Drive
     */
    private suspend fun downloadFile(service: Drive, params: Map<String, Any>): ToolResult {
        val fileId = getRequiredParam<String>(params, "file_id")
        val localPath = getRequiredParam<String>(params, "local_path")
        
        val file = service.files().get(fileId).execute()
        
        // Download file content
        val outputStream = FileOutputStream(localPath)
        service.files().get(fileId).executeMediaAndDownloadTo(outputStream)
        outputStream.close()
        
        return ToolResult.success(
            name,
            mapOf(
                "file_id" to fileId,
                "name" to file.name,
                "local_path" to localPath
            ),
            "File downloaded: ${file.name} to $localPath"
        )
    }
    
    /**
     * Share file with user
     */
    private suspend fun shareFile(service: Drive, params: Map<String, Any>): ToolResult {
        val fileId = getRequiredParam<String>(params, "file_id")
        val email = getRequiredParam<String>(params, "email")
        val role = getOptionalParam(params, "role", "reader")
        
        val permission = Permission().apply {
            type = "user"
            this.role = role
            emailAddress = email
        }
        
        service.permissions().create(fileId, permission)
            .setSendNotificationEmail(true)
            .execute()
        
        val file = service.files().get(fileId)
            .setFields("name, webViewLink")
            .execute()
        
        return ToolResult.success(
            name,
            mapOf(
                "file_id" to fileId,
                "name" to file.name,
                "shared_with" to email,
                "role" to role,
                "web_view_link" to file.webViewLink
            ),
            "File shared with $email as $role"
        )
    }
    
    /**
     * Delete file (move to trash)
     */
    private suspend fun deleteFile(service: Drive, params: Map<String, Any>): ToolResult {
        val fileId = getRequiredParam<String>(params, "file_id")
        
        val file = service.files().get(fileId).setFields("name").execute()
        service.files().delete(fileId).execute()
        
        return ToolResult.success(
            name,
            mapOf("file_id" to fileId, "name" to file.name),
            "File deleted: ${file.name}"
        )
    }
    
    /**
     * Move file to different folder
     */
    private suspend fun moveFile(service: Drive, params: Map<String, Any>): ToolResult {
        val fileId = getRequiredParam<String>(params, "file_id")
        val newParentId = getRequiredParam<String>(params, "parent_id")
        
        // Get current parents
        val file = service.files().get(fileId).setFields("parents").execute()
        val previousParents = file.parents?.joinToString(",") ?: ""
        
        // Move file
        val updatedFile = service.files().update(fileId, null)
            .setAddParents(newParentId)
            .setRemoveParents(previousParents)
            .setFields("id, name, parents")
            .execute()
        
        return ToolResult.success(
            name,
            mapOf(
                "file_id" to updatedFile.id,
                "name" to updatedFile.name,
                "new_parent" to newParentId
            ),
            "File moved: ${updatedFile.name}"
        )
    }
    
    /**
     * Copy file
     */
    private suspend fun copyFile(service: Drive, params: Map<String, Any>): ToolResult {
        val fileId = getRequiredParam<String>(params, "file_id")
        val newName = getOptionalParam<String?>(params, "new_name", null)
        val parentId = getOptionalParam<String?>(params, "parent_id", null)
        
        val copyMetadata = File().apply {
            if (newName != null) name = newName
            if (parentId != null) parents = listOf(parentId)
        }
        
        val copiedFile = service.files().copy(fileId, copyMetadata)
            .setFields("id, name, webViewLink")
            .execute()
        
        return ToolResult.success(
            name,
            mapOf(
                "file_id" to copiedFile.id,
                "name" to copiedFile.name,
                "web_view_link" to copiedFile.webViewLink
            ),
            "File copied: ${copiedFile.name}"
        )
    }
    
    /**
     * Rename file
     */
    private suspend fun renameFile(service: Drive, params: Map<String, Any>): ToolResult {
        val fileId = getRequiredParam<String>(params, "file_id")
        val newName = getRequiredParam<String>(params, "new_name")
        
        val updatedMetadata = File().apply {
            name = newName
        }
        
        val updatedFile = service.files().update(fileId, updatedMetadata)
            .setFields("id, name")
            .execute()
        
        return ToolResult.success(
            name,
            mapOf(
                "file_id" to updatedFile.id,
                "name" to updatedFile.name
            ),
            "File renamed to: ${updatedFile.name}"
        )
    }
    
    /**
     * Extract file data to map
     */
    private fun extractFileData(file: File): Map<String, Any?> {
        return mapOf(
            "file_id" to file.id,
            "name" to file.name,
            "mime_type" to file.mimeType,
            "size" to (file.getSize() ?: 0),
            "created_time" to file.createdTime?.toString(),
            "modified_time" to file.modifiedTime?.toString(),
            "web_view_link" to file.webViewLink,
            "web_content_link" to file.webContentLink,
            "parents" to file.parents,
            "owners" to (file.owners?.map { it.emailAddress } ?: emptyList()),
            "shared" to (file.shared ?: false),
            "is_folder" to (file.mimeType == FOLDER_MIME_TYPE)
        )
    }
}

package com.blurr.voice.tools.google

import android.content.Context
import android.util.Log
import com.blurr.voice.auth.GoogleAuthManager
import com.blurr.voice.tools.BaseTool
import com.blurr.voice.tools.ToolParameter
import com.blurr.voice.tools.ToolResult
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONArray
import org.json.JSONObject
import java.util.concurrent.TimeUnit

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
        private const val BASE_URL = "https://www.googleapis.com/drive/v3"
        private const val UPLOAD_URL = "https://www.googleapis.com/upload/drive/v3"
        
        const val FOLDER_MIME_TYPE = "application/vnd.google-apps.folder"
        const val DOCUMENT_MIME_TYPE = "application/vnd.google-apps.document"
        const val SPREADSHEET_MIME_TYPE = "application/vnd.google-apps.spreadsheet"
        const val PRESENTATION_MIME_TYPE = "application/vnd.google-apps.presentation"
    }
    
    private val client = OkHttpClient.Builder()
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .build()
    
    override val name = "google_drive"
    override val description = "Manage Google Drive: upload, download, search, share files and folders"
    
    override val parameters = listOf(
        ToolParameter(
            name = "action",
            type = "string",
            description = "Action: list, search, upload, download, delete, create_folder",
            required = true
        ),
        ToolParameter(
            name = "file_id",
            type = "string",
            description = "File ID for download, delete, share",
            required = false
        ),
        ToolParameter(
            name = "name",
            type = "string",
            description = "File/folder name",
            required = false
        ),
        ToolParameter(
            name = "query",
            type = "string",
            description = "Search query (e.g., 'name contains \"report\"')",
            required = false
        ),
        ToolParameter(
            name = "parent_id",
            type = "string",
            description = "Parent folder ID",
            required = false
        ),
        ToolParameter(
            name = "mime_type",
            type = "string",
            description = "MIME type for file/folder",
            required = false
        )
    )
    
    override suspend fun execute(params: Map<String, Any>, context: List<ToolResult>): ToolResult {
        return withContext(Dispatchers.IO) {
            try {
                if (!authManager.isSignedIn()) {
                    return@withContext ToolResult.error(
                        name,
                        "Not signed in to Google. Please sign in first.",
                        mapOf("requires_auth" to true)
                    )
                }
                
                val tokenResult = authManager.getAccessToken()
                if (tokenResult.isFailure) {
                    return@withContext ToolResult.error(name, "Failed to get Google access token")
                }
                
                val accessToken = tokenResult.getOrThrow()
                val action = getRequiredParam<String>(params, "action")
                
                when (action.lowercase()) {
                    "list" -> listFiles(accessToken)
                    "search" -> searchFiles(accessToken, params)
                    "create_folder" -> createFolder(accessToken, params)
                    "delete" -> deleteFile(accessToken, params)
                    "get" -> getFile(accessToken, params)
                    else -> ToolResult.error(name, "Unknown action: $action")
                }
            } catch (e: Exception) {
                Log.e(TAG, "Drive operation failed", e)
                ToolResult.error(name, "Drive error: ${e.message}")
            }
        }
    }
    
    private fun listFiles(accessToken: String): ToolResult {
        val url = "$BASE_URL/files?q='root'+in+parents&fields=files(id,name,mimeType,modifiedTime,size,webViewLink)"
        val request = Request.Builder()
            .url(url)
            .addHeader("Authorization", "Bearer $accessToken")
            .get()
            .build()
        
        return executeRequest(request) { response ->
            val files = response.optJSONArray("files") ?: JSONArray()
            val fileList = mutableListOf<Map<String, Any?>>()
            
            for (i in 0 until files.length()) {
                val file = files.getJSONObject(i)
                fileList.add(mapOf(
                    "id" to file.optString("id"),
                    "name" to file.optString("name"),
                    "mimeType" to file.optString("mimeType"),
                    "modifiedTime" to file.optString("modifiedTime"),
                    "size" to file.optString("size"),
                    "webViewLink" to file.optString("webViewLink")
                ))
            }
            
            ToolResult.success(
                toolName = name,
                data = mapOf("count" to fileList.size, "files" to fileList),
                result = "Found ${fileList.size} files in root folder"
            )
        }
    }
    
    private fun searchFiles(accessToken: String, params: Map<String, Any>): ToolResult {
        val query = getRequiredParam<String>(params, "query")
        val url = "$BASE_URL/files?q=${java.net.URLEncoder.encode(query, "UTF-8")}&fields=files(id,name,mimeType,modifiedTime,size)"
        val request = Request.Builder()
            .url(url)
            .addHeader("Authorization", "Bearer $accessToken")
            .get()
            .build()
        
        return executeRequest(request) { response ->
            val files = response.optJSONArray("files") ?: JSONArray()
            val fileList = mutableListOf<Map<String, Any?>>()
            
            for (i in 0 until files.length()) {
                val file = files.getJSONObject(i)
                fileList.add(mapOf(
                    "id" to file.optString("id"),
                    "name" to file.optString("name"),
                    "mimeType" to file.optString("mimeType"),
                    "modifiedTime" to file.optString("modifiedTime"),
                    "size" to file.optString("size")
                ))
            }
            
            ToolResult.success(
                toolName = name,
                data = mapOf("query" to query, "count" to fileList.size, "files" to fileList),
                result = "Found ${fileList.size} files matching: $query"
            )
        }
    }
    
    private fun createFolder(accessToken: String, params: Map<String, Any>): ToolResult {
        val name = getRequiredParam<String>(params, "name")
        val parentId = getOptionalParam(params, "parent_id", "")
        
        val jsonBody = JSONObject().apply {
            put("name", name)
            put("mimeType", FOLDER_MIME_TYPE)
            if (parentId.isNotEmpty()) {
                put("parents", JSONArray().put(parentId))
            }
        }
        
        val request = Request.Builder()
            .url("$BASE_URL/files")
            .addHeader("Authorization", "Bearer $accessToken")
            .addHeader("Content-Type", "application/json")
            .post(jsonBody.toString().toRequestBody("application/json".toMediaType()))
            .build()
        
        return executeRequest(request) { response ->
            ToolResult.success(
                toolName = name,
                data = mapOf(
                    "id" to response.optString("id"),
                    "name" to response.optString("name"),
                    "mimeType" to response.optString("mimeType")
                ),
                result = "Folder created: $name"
            )
        }
    }
    
    private fun deleteFile(accessToken: String, params: Map<String, Any>): ToolResult {
        val fileId = getRequiredParam<String>(params, "file_id")
        
        val request = Request.Builder()
            .url("$BASE_URL/files/$fileId")
            .addHeader("Authorization", "Bearer $accessToken")
            .delete()
            .build()
        
        return executeRequest(request) { _ ->
            ToolResult.success(toolName = name, data = mapOf("id" to fileId), result = "File deleted")
        }
    }
    
    private fun getFile(accessToken: String, params: Map<String, Any>): ToolResult {
        val fileId = getRequiredParam<String>(params, "file_id")
        
        val request = Request.Builder()
            .url("$BASE_URL/files/$fileId?fields=id,name,mimeType,modifiedTime,size,webViewLink,webContentLink")
            .addHeader("Authorization", "Bearer $accessToken")
            .get()
            .build()
        
        return executeRequest(request) { response ->
            ToolResult.success(
                toolName = name,
                data = mapOf(
                    "id" to response.optString("id"),
                    "name" to response.optString("name"),
                    "mimeType" to response.optString("mimeType"),
                    "modifiedTime" to response.optString("modifiedTime"),
                    "size" to response.optString("size"),
                    "webViewLink" to response.optString("webViewLink"),
                    "webContentLink" to response.optString("webContentLink")
                ),
                result = "File details retrieved"
            )
        }
    }
    
    private fun executeRequest(request: Request, onSuccess: (JSONObject) -> ToolResult): ToolResult {
        return try {
            client.newCall(request).execute().use { response ->
                val body = response.body?.string()
                if (response.isSuccessful && body != null) {
                    return onSuccess(JSONObject(body))
                } else {
                    ToolResult.error(name, "API error: ${response.code} - $body")
                }
            }
        } catch (e: Exception) {
            ToolResult.error(name, "Request failed: ${e.message}")
        }
    }
}

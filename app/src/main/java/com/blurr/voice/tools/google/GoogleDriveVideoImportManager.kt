package com.blurr.voice.tools.google

import android.content.Context
import android.util.Log
import com.blurr.voice.auth.GoogleAuthManager
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import okhttp3.OkHttpClient
import okhttp3.Request
import org.json.JSONObject
import java.io.File
import java.io.FileOutputStream
import java.net.URLEncoder
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.TimeUnit

object GoogleDriveVideoImportManager {

    private const val TAG = "GDriveVideoImport"
    private const val DRIVE_BASE_URL = "https://www.googleapis.com/drive/v3"

    private val driveScopes = listOf(
        "https://www.googleapis.com/auth/drive.readonly",
        "https://www.googleapis.com/auth/drive.metadata.readonly",
    )

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    private val client = OkHttpClient.Builder()
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(0, TimeUnit.SECONDS) // downloads can be long
        .build()

    private val imports = ConcurrentHashMap<String, ImportStatus>()

    data class DriveVideoFile(
        val id: String,
        val name: String,
        val mimeType: String,
        val size: Long?,
        val createdTime: String?,
        val webViewLink: String?,
    ) {
        fun toMap(): Map<String, Any?> {
            return mapOf(
                "id" to id,
                "name" to name,
                "mimeType" to mimeType,
                "size" to size,
                "createdTime" to createdTime,
                "webViewLink" to webViewLink,
            )
        }
    }

    class ImportStatus(
        val fileId: String,
        val name: String?,
        val mimeType: String?,
        val size: Long?,
        val createdTime: String?,
        val webViewLink: String?,
    ) {
        @Volatile
        var status: String = "queued" // queued | downloading | completed | error

        @Volatile
        var progress: Double = 0.0

        @Volatile
        var bytesDownloaded: Long = 0

        @Volatile
        var totalBytes: Long? = null

        @Volatile
        var localPath: String? = null

        @Volatile
        var error: String? = null

        fun toMap(): Map<String, Any?> {
            return mapOf(
                "fileId" to fileId,
                "name" to name,
                "mimeType" to mimeType,
                "size" to size,
                "createdTime" to createdTime,
                "webViewLink" to webViewLink,
                "status" to status,
                "progress" to progress,
                "bytesDownloaded" to bytesDownloaded,
                "totalBytes" to totalBytes,
                "localPath" to localPath,
                "error" to error,
            )
        }
    }

    fun getImportStatus(fileId: String): ImportStatus? = imports[fileId]

    suspend fun listVideoFiles(
        authManager: GoogleAuthManager,
        pageSize: Int = 100,
        maxPages: Int = 5,
    ): Result<List<DriveVideoFile>> {
        val token = authManager.getAccessToken(driveScopes).getOrElse {
            return Result.failure(it)
        }

        val out = mutableListOf<DriveVideoFile>()
        var pageToken: String? = null
        var page = 0

        while (page < maxPages) {
            val q = "mimeType contains 'video/' and trashed = false"
            val encodedQ = URLEncoder.encode(q, "UTF-8")

            val url = buildString {
                append("$DRIVE_BASE_URL/files")
                append("?pageSize=$pageSize")
                append("&q=$encodedQ")
                append("&fields=nextPageToken,files(id,name,mimeType,size,createdTime,webViewLink)")
                if (!pageToken.isNullOrBlank()) {
                    val encodedPageToken = URLEncoder.encode(pageToken, "UTF-8")
                    append("&pageToken=$encodedPageToken")
                }
            }

            val request = Request.Builder()
                .url(url)
                .addHeader("Authorization", "Bearer $token")
                .get()
                .build()

            val response = executeWithRetry(authManager) { currentToken ->
                request.newBuilder()
                    .header("Authorization", "Bearer $currentToken")
                    .build()
            }

            if (response.isFailure) return Result.failure(response.exceptionOrNull()!!)
            val json = response.getOrThrow()

            val files = json.optJSONArray("files")
            if (files != null) {
                for (i in 0 until files.length()) {
                    val f = files.optJSONObject(i) ?: continue
                    val mime = f.optString("mimeType")
                    if (!mime.startsWith("video/")) continue

                    out.add(
                        DriveVideoFile(
                            id = f.optString("id"),
                            name = f.optString("name"),
                            mimeType = mime,
                            size = f.optString("size").toLongOrNull(),
                            createdTime = f.optString("createdTime").ifBlank { null },
                            webViewLink = f.optString("webViewLink").ifBlank { null },
                        )
                    )
                }
            }

            pageToken = json.optString("nextPageToken").ifBlank { null }
            if (pageToken == null) break
            page++
        }

        return Result.success(out)
    }

    suspend fun startImport(
        context: Context,
        authManager: GoogleAuthManager,
        fileId: String,
    ): Result<ImportStatus> {
        val existing = imports[fileId]
        if (existing != null && (existing.status == "queued" || existing.status == "downloading")) {
            return Result.success(existing)
        }

        val metadataResult = getFileMetadata(authManager, fileId)
        if (metadataResult.isFailure) return Result.failure(metadataResult.exceptionOrNull()!!)
        val metadata = metadataResult.getOrThrow()

        val mimeType = metadata.mimeType ?: ""
        if (!mimeType.startsWith("video/")) {
            return Result.failure(IllegalArgumentException("File is not a video"))
        }

        val status = ImportStatus(
            fileId = fileId,
            name = metadata.name,
            mimeType = metadata.mimeType,
            size = metadata.size,
            createdTime = metadata.createdTime,
            webViewLink = metadata.webViewLink,
        )

        imports[fileId] = status

        scope.launch {
            downloadToLocal(context, authManager, fileId, status)
        }

        return Result.success(status)
    }

    private suspend fun getFileMetadata(authManager: GoogleAuthManager, fileId: String): Result<ImportStatus> {
        val token = authManager.getAccessToken(driveScopes).getOrElse {
            return Result.failure(it)
        }

        val url = "$DRIVE_BASE_URL/files/$fileId?fields=id,name,mimeType,size,createdTime,webViewLink"

        val request = Request.Builder()
            .url(url)
            .addHeader("Authorization", "Bearer $token")
            .get()
            .build()

        val response = executeWithRetry(authManager) { currentToken ->
            request.newBuilder().header("Authorization", "Bearer $currentToken").build()
        }

        if (response.isFailure) return Result.failure(response.exceptionOrNull()!!)
        val json = response.getOrThrow()

        return Result.success(
            ImportStatus(
                fileId = fileId,
                name = json.optString("name").ifBlank { null },
                mimeType = json.optString("mimeType").ifBlank { null },
                size = json.optString("size").toLongOrNull(),
                createdTime = json.optString("createdTime").ifBlank { null },
                webViewLink = json.optString("webViewLink").ifBlank { null },
            )
        )
    }

    private suspend fun downloadToLocal(
        context: Context,
        authManager: GoogleAuthManager,
        fileId: String,
        status: ImportStatus,
    ) {
        try {
            status.status = "downloading"
            status.error = null

            val token = authManager.getAccessToken(driveScopes).getOrElse {
                throw it
            }

            val downloadUrl = "$DRIVE_BASE_URL/files/$fileId?alt=media"

            val dir = File(context.getExternalFilesDir(null), "drive_imports").apply { mkdirs() }
            val desiredName = sanitizeFileName(status.name ?: "drive_video_$fileId.mp4")
            val outFile = uniqueFile(dir, desiredName)

            val requestBase = Request.Builder()
                .url(downloadUrl)
                .addHeader("Authorization", "Bearer $token")
                .get()
                .build()

            val response = executeStreamWithRetry(authManager) { currentToken ->
                requestBase.newBuilder().header("Authorization", "Bearer $currentToken").build()
            }

            response.use { res ->
                if (!res.isSuccessful) {
                    val msg = res.body?.string()
                    throw IllegalStateException("Drive download failed: ${res.code} ${msg ?: ""}")
                }

                val body = res.body ?: throw IllegalStateException("Empty response body")
                val total = body.contentLength().takeIf { it > 0 } ?: status.size
                status.totalBytes = total

                body.byteStream().use { input ->
                    FileOutputStream(outFile).use { output ->
                        val buffer = ByteArray(DEFAULT_BUFFER_SIZE)
                        var read: Int
                        while (true) {
                            read = input.read(buffer)
                            if (read <= 0) break
                            output.write(buffer, 0, read)

                            status.bytesDownloaded += read.toLong()
                            val denom = status.totalBytes
                            if (denom != null && denom > 0) {
                                status.progress = (status.bytesDownloaded.toDouble() / denom.toDouble()).coerceIn(0.0, 1.0)
                            }
                        }
                    }
                }
            }

            status.localPath = outFile.absolutePath
            status.progress = 1.0
            status.status = "completed"
        } catch (e: Exception) {
            Log.e(TAG, "Import failed: $fileId", e)
            status.status = "error"
            status.error = e.message ?: "Import failed"
        }
    }

    private fun sanitizeFileName(input: String): String {
        val trimmed = input.trim().ifBlank { "drive_video.mp4" }
        // Keep it simple and filesystem-safe for Android.
        val safe = trimmed.replace(Regex("[^a-zA-Z0-9._ -]"), "_")
        return safe.take(120)
    }

    private fun uniqueFile(dir: File, name: String): File {
        val dot = name.lastIndexOf('.')
        val base = if (dot > 0) name.substring(0, dot) else name
        val ext = if (dot > 0 && dot < name.length - 1) name.substring(dot + 1) else "mp4"

        var attempt = 0
        while (true) {
            val candidate = if (attempt == 0) {
                File(dir, name)
            } else {
                File(dir, "${base}_$attempt.$ext")
            }
            if (!candidate.exists()) return candidate
            attempt++
        }
    }

    private suspend fun executeWithRetry(
        authManager: GoogleAuthManager,
        buildRequest: (String) -> Request,
        maxRetries: Int = 3,
    ): Result<JSONObject> {
        var token = authManager.getAccessToken(driveScopes).getOrElse {
            return Result.failure(it)
        }

        for (attempt in 0..maxRetries) {
            val request = buildRequest(token)
            try {
                client.newCall(request).execute().use { response ->
                    val bodyStr = response.body?.string().orEmpty()

                    if (response.code == 401 && attempt < maxRetries) {
                        token = authManager.refreshToken(driveScopes).getOrElse { throw it }
                        continue
                    }

                    if ((response.code == 429 || response.code >= 500) && attempt < maxRetries) {
                        delay(backoffMs(attempt))
                        continue
                    }

                    if (!response.isSuccessful) {
                        return Result.failure(IllegalStateException("Drive API error: ${response.code} $bodyStr"))
                    }

                    return Result.success(JSONObject(bodyStr))
                }
            } catch (e: Exception) {
                if (attempt >= maxRetries) return Result.failure(e)
                delay(backoffMs(attempt))
            }
        }

        return Result.failure(IllegalStateException("Drive API request failed after retries"))
    }

    private suspend fun executeStreamWithRetry(
        authManager: GoogleAuthManager,
        buildRequest: (String) -> Request,
        maxRetries: Int = 2,
    ): okhttp3.Response {
        var token = authManager.getAccessToken(driveScopes).getOrElse { throw it }

        for (attempt in 0..maxRetries) {
            val request = buildRequest(token)
            val response = try {
                client.newCall(request).execute()
            } catch (e: Exception) {
                if (attempt >= maxRetries) throw e
                delay(backoffMs(attempt))
                continue
            }

            if (response.code == 401 && attempt < maxRetries) {
                response.close()
                token = authManager.refreshToken(driveScopes).getOrElse { throw it }
                continue
            }

            if ((response.code == 429 || response.code >= 500) && attempt < maxRetries) {
                response.close()
                delay(backoffMs(attempt))
                continue
            }

            return response
        }

        throw IllegalStateException("Drive download failed after retries")
    }

    private fun backoffMs(attempt: Int): Long {
        val base = 750L
        val factor = 1 shl attempt.coerceAtMost(6)
        return (base * factor).coerceAtMost(10_000L)
    }
}

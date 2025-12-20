// Platform bridge for AI-Native Video Editor
package com.blurr.voice.flutter

import android.content.Context
import android.util.Log
import com.arthenica.ffmpegkit.FFmpegKit
import com.arthenica.ffmpegkit.ReturnCode
import com.blurr.voice.agents.AgentFactory
import com.blurr.voice.utilities.FreemiumManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.io.File

/**
 * Bridge for communication between Kotlin (Android) and Flutter (Video Editor)
 *
 * Responsibilities:
 * - Pro gating checks
 * - AI-assisted actions via UltraGeneralistAgent
 * - Timeline export via FFmpegKit (simple MVP renderer)
 */
class VideoEditorBridge(
    private val context: Context,
    flutterEngine: FlutterEngine,
) {
    companion object {
        private const val CHANNEL = "com.blurr.video_editor/bridge"
        private const val TAG = "VideoEditorBridge"
    }

    private val methodChannel: MethodChannel = MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        CHANNEL
    )

    private val scope = CoroutineScope(Dispatchers.Main)

    init {
        setupMethodCallHandler()
    }

    private fun setupMethodCallHandler() {
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "checkProStatus" -> handleCheckProStatus(result)
                "executeAgentTask" -> {
                    val prompt = call.argument<String>("prompt")
                    if (prompt.isNullOrBlank()) {
                        result.error("INVALID_ARGS", "prompt is required", null)
                    } else {
                        handleExecuteAgentTask(prompt, result)
                    }
                }

                "generateCaptions" -> {
                    val clipUri = call.argument<String>("clipUri")
                    val language = call.argument<String>("language") ?: "en"
                    if (clipUri.isNullOrBlank()) {
                        result.error("INVALID_ARGS", "clipUri is required", null)
                    } else {
                        handleGenerateCaptions(clipUri, language, result)
                    }
                }

                "suggestTransitions" -> {
                    val projectJson = call.argument<String>("projectJson")
                    if (projectJson.isNullOrBlank()) {
                        result.error("INVALID_ARGS", "projectJson is required", null)
                    } else {
                        handleSuggestTransitions(projectJson, result)
                    }
                }

                "generateClipFromPrompt" -> {
                    val prompt = call.argument<String>("prompt")
                    if (prompt.isNullOrBlank()) {
                        result.error("INVALID_ARGS", "prompt is required", null)
                    } else {
                        handleGenerateClipFromPrompt(prompt, result)
                    }
                }

                "enhanceVideo" -> {
                    val clipUri = call.argument<String>("clipUri")
                    val intent = call.argument<String>("intent")
                    if (clipUri.isNullOrBlank()) {
                        result.error("INVALID_ARGS", "clipUri is required", null)
                    } else {
                        handleEnhanceVideo(clipUri, intent, result)
                    }
                }

                "exportTimeline" -> {
                    val timelineJson = call.argument<String>("timelineJson")
                    val outputFileName = call.argument<String>("outputFileName")
                    if (timelineJson.isNullOrBlank()) {
                        result.error("INVALID_ARGS", "timelineJson is required", null)
                    } else {
                        handleExportTimeline(timelineJson, outputFileName, result)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun handleCheckProStatus(result: MethodChannel.Result) {
        scope.launch {
            try {
                val isPro = withContext(Dispatchers.IO) {
                    FreemiumManager().isUserSubscribed()
                }
                result.success(mapOf("isPro" to isPro))
            } catch (e: Exception) {
                Log.e(TAG, "Pro check failed", e)
                result.success(mapOf("isPro" to false))
            }
        }
    }

    private fun handleExecuteAgentTask(prompt: String, result: MethodChannel.Result) {
        scope.launch {
            try {
                val responseText = withContext(Dispatchers.IO) {
                    val agent = AgentFactory.getAgent(context)
                    agent.processMessage(prompt).text
                }

                result.success(
                    mapOf(
                        "success" to true,
                        "result" to responseText
                    )
                )
            } catch (e: Exception) {
                Log.e(TAG, "Agent task failed", e)
                result.success(
                    mapOf(
                        "success" to false,
                        "error" to (e.message ?: "Unknown error")
                    )
                )
            }
        }
    }

    private fun handleGenerateClipFromPrompt(prompt: String, result: MethodChannel.Result) {
        // This is intentionally a single-shot call to keep UI responsive.
        val agentPrompt = "Use the video_generation tool to generate a short clip (MP4) for: $prompt. Return ONLY the URL or file path.";
        handleExecuteAgentTask(agentPrompt, result)
    }

    private fun handleGenerateCaptions(clipUri: String, language: String, result: MethodChannel.Result) {
        val agentPrompt = "Generate SRT captions in language '$language' for the video at path/URL: $clipUri. Return ONLY SRT.";
        scope.launch {
            try {
                val responseText = withContext(Dispatchers.IO) {
                    val agent = AgentFactory.getAgent(context)
                    agent.processMessage(agentPrompt).text
                }
                result.success(mapOf("success" to true, "srt" to responseText))
            } catch (e: Exception) {
                Log.e(TAG, "Caption generation failed", e)
                result.success(mapOf("success" to false, "error" to (e.message ?: "Unknown error")))
            }
        }
    }

    private fun handleSuggestTransitions(projectJson: String, result: MethodChannel.Result) {
        val agentPrompt = "You are a mobile video editor assistant. Given this project JSON, suggest transitions between adjacent clips on each video track. Return JSON array of transitions with fields: id, fromClipId, toClipId, type(one of none,crossfade,fadeToBlack), durationMs. Project JSON: $projectJson";

        scope.launch {
            try {
                val responseText = withContext(Dispatchers.IO) {
                    val agent = AgentFactory.getAgent(context)
                    agent.processMessage(agentPrompt).text
                }
                result.success(mapOf("success" to true, "transitions" to responseText))
            } catch (e: Exception) {
                Log.e(TAG, "Transition suggestion failed", e)
                result.success(mapOf("success" to false, "error" to (e.message ?: "Unknown error")))
            }
        }
    }

    private fun handleEnhanceVideo(clipUri: String, intent: String?, result: MethodChannel.Result) {
        val agentPrompt = buildString {
            append("Enhance this video in-place or output a new MP4. Video: $clipUri. ")
            if (!intent.isNullOrBlank()) append("User intent: $intent. ")
            append("If you produce a new file, return ONLY the new file path.")
        }

        handleExecuteAgentTask(agentPrompt, result)
    }

    private fun handleExportTimeline(
        timelineJson: String,
        outputFileName: String?,
        result: MethodChannel.Result
    ) {
        scope.launch {
            try {
                val filePath = withContext(Dispatchers.IO) {
                    exportTimelineInternal(timelineJson, outputFileName)
                }

                result.success(mapOf("success" to true, "filePath" to filePath))
            } catch (e: Exception) {
                Log.e(TAG, "Export failed", e)
                result.success(mapOf("success" to false, "error" to (e.message ?: "Unknown error")))
            }
        }
    }

    /**
     * MVP export implementation:
     * - Exports ONLY the first video track (video/images) in timeline order
     * - Applies trimStartMs and durationMs
     * - Produces a single MP4 in app external files dir
     */
    private fun exportTimelineInternal(timelineJson: String, outputFileName: String?): String {
        val project = JSONObject(timelineJson)
        val tracks = project.getJSONArray("tracks")

        // Find the first video track.
        var videoTrack: JSONObject? = null
        for (i in 0 until tracks.length()) {
            val t = tracks.getJSONObject(i)
            if (t.optString("type") == "video") {
                videoTrack = t
                break
            }
        }
        if (videoTrack == null) {
            throw IllegalStateException("No video track found")
        }

        val clips = videoTrack.getJSONArray("clips")
        if (clips.length() == 0) {
            throw IllegalStateException("No clips on the video track")
        }

        val clipsList = (0 until clips.length()).map { clips.getJSONObject(it) }
            .sortedBy { it.optInt("startMs", 0) }

        val workDir = File(context.cacheDir, "video_export_${System.currentTimeMillis()}")
        workDir.mkdirs()

        val segmentFiles = mutableListOf<File>()

        clipsList.forEachIndexed { index, clip ->
            val uri = clip.optString("uri")
            if (uri.startsWith("http://") || uri.startsWith("https://")) {
                throw IllegalArgumentException("Network media not supported for export yet: $uri")
            }

            val type = clip.optString("type")
            val trimStartMs = clip.optInt("trimStartMs", 0)
            val durationMs = clip.optInt("durationMs", 0)

            if (durationMs <= 0) {
                return@forEachIndexed
            }

            val durSec = durationMs / 1000.0
            val trimStartSec = trimStartMs / 1000.0

            val outFile = File(workDir, "segment_$index.mp4")
            val inputPath = escapePath(uri)
            val outputPath = escapePath(outFile.absolutePath)

            val baseVideoFilter = escapeFilter(
                "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2,format=yuv420p"
            )

            val cmd = when (type) {
                "image" -> {
                    "-y -loop 1 -t $durSec -i $inputPath -vf $baseVideoFilter -r 30 -c:v libx264 -preset veryfast -crf 23 -pix_fmt yuv420p $outputPath"
                }
                "video" -> {
                    "-y -ss $trimStartSec -t $durSec -i $inputPath -vf $baseVideoFilter -r 30 -c:v libx264 -preset veryfast -crf 23 -pix_fmt yuv420p -an $outputPath"
                }
                else -> {
                    // Skip non-video media on the main video track.
                    return@forEachIndexed
                }
            }

            val session = FFmpegKit.execute(cmd)
            val rc = session.returnCode
            if (!ReturnCode.isSuccess(rc)) {
                val stackTrace = session.failStackTrace
                throw IllegalStateException("FFmpeg segment render failed (code=${rc?.value}): $stackTrace")
            }

            segmentFiles.add(outFile)
        }

        if (segmentFiles.isEmpty()) {
            throw IllegalStateException("No renderable clips found")
        }

        // concat demuxer file
        val concatFile = File(workDir, "concat.txt")
        concatFile.writeText(segmentFiles.joinToString(separator = "\n") { "file '${it.absolutePath.replace("'", "\\'")}'" })

        val finalName = outputFileName?.takeIf { it.endsWith(".mp4") } ?: "blurr_export_${System.currentTimeMillis()}.mp4"
        val outputFile = File(context.getExternalFilesDir(null), finalName)

        val concatPath = escapePath(concatFile.absolutePath)
        val outPath = escapePath(outputFile.absolutePath)

        // Re-encode on final concat for broad compatibility.
        val concatCmd = "-y -f concat -safe 0 -i $concatPath -c:v libx264 -preset veryfast -crf 23 -pix_fmt yuv420p -movflags +faststart $outPath"
        val concatSession = FFmpegKit.execute(concatCmd)
        val concatRc = concatSession.returnCode
        if (!ReturnCode.isSuccess(concatRc)) {
            val stackTrace = concatSession.failStackTrace
            throw IllegalStateException("FFmpeg concat failed (code=${concatRc?.value}): $stackTrace")
        }

        return outputFile.absolutePath
    }

    private fun escapePath(path: String): String {
        // ffmpeg-kit accepts shell-like quoted args.
        return "\"" + path.replace("\\", "\\\\").replace("\"", "\\\"") + "\""
    }

    private fun escapeFilter(filter: String): String {
        return "\"" + filter.replace("\\", "\\\\").replace("\"", "\\\"") + "\""
    }

    fun dispose() {
        methodChannel.setMethodCallHandler(null)
    }
}

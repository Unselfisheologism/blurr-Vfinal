// Platform bridge for AI-Native Video Editor
package com.blurr.voice.flutter

import android.content.Context
import android.media.MediaMetadataRetriever
import android.util.Log
import com.moizhassan.ffmpeg.Config
import com.moizhassan.ffmpeg.FFmpeg
import com.blurr.voice.agents.AgentFactory
import com.blurr.voice.utilities.FreemiumManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject
import java.io.File

/**
 * Bridge for communication between Kotlin (Android) and Flutter (Video Editor)
 *
 * Responsibilities:
 * - Pro gating checks
 * - AI-assisted actions via UltraGeneralistAgent
 * - Media metadata probing
 * - Timeline export via FFmpeg Kit 16KB
 */
class VideoEditorBridge(
    private val context: Context,
    flutterEngine: FlutterEngine,
) {
    companion object {
        private const val CHANNEL = "com.blurr.video_editor/bridge"
        private const val TAG = "VideoEditorBridge"

        private const val OUTPUT_W = 1280
        private const val OUTPUT_H = 720
        private const val OUTPUT_FPS = 30

        private const val PIP_W = 384
        private const val PIP_H = 216
        private const val PIP_MARGIN = 24
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

                "getMediaDurationMs" -> {
                    val uri = call.argument<String>("uri")
                    if (uri.isNullOrBlank()) {
                        result.error("INVALID_ARGS", "uri is required", null)
                    } else {
                        handleGetMediaDurationMs(uri, result)
                    }
                }

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

    private fun handleGetMediaDurationMs(uri: String, result: MethodChannel.Result) {
        scope.launch {
            try {
                val durationMs = withContext(Dispatchers.IO) {
                    getMediaDurationMsInternal(uri)
                }
                result.success(mapOf("durationMs" to durationMs))
            } catch (e: Exception) {
                Log.w(TAG, "Failed to get media duration", e)
                result.success(mapOf("durationMs" to null))
            }
        }
    }

    private fun getMediaDurationMsInternal(uri: String): Long? {
        // Best-effort: if we can't read it, return null.
        val lower = uri.lowercase()
        if (lower.endsWith(".png") || lower.endsWith(".jpg") || lower.endsWith(".jpeg") || lower.endsWith(".webp")) {
            return null
        }

        val retriever = MediaMetadataRetriever()
        return try {
            retriever.setDataSource(uri)
            val durStr = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
            durStr?.toLongOrNull()
        } catch (_: Exception) {
            null
        } finally {
            try {
                retriever.release()
            } catch (_: Exception) {
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
        val agentPrompt = "Use the video_generation tool to generate a short clip (MP4) for: $prompt. Return ONLY the URL or file path."
        handleExecuteAgentTask(agentPrompt, result)
    }

    private fun handleGenerateCaptions(clipUri: String, language: String, result: MethodChannel.Result) {
        val agentPrompt = "Generate SRT captions in language '$language' for the video at path/URL: $clipUri. Return ONLY SRT."
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
        val agentPrompt = "You are a mobile video editor assistant. Given this project JSON, suggest transitions between adjacent clips on each video track. Return JSON array of transitions with fields: id, fromClipId, toClipId, type(one of none,crossfade,fadeToBlack), durationMs. Project JSON: $projectJson"

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
                val exportResult = withContext(Dispatchers.IO) {
                    exportTimelineInternal(timelineJson, outputFileName)
                }

                val response = mutableMapOf<String, Any?>(
                    "success" to true,
                    "filePath" to exportResult.videoPath,
                )
                exportResult.captionsPath?.let { response["captionsFilePath"] = it }

                result.success(response)
            } catch (e: Exception) {
                Log.e(TAG, "Export failed", e)
                result.success(mapOf("success" to false, "error" to (e.message ?: "Unknown error")))
            }
        }
    }

    private data class ParsedClip(
        val id: String,
        val type: String,
        val uri: String,
        val startMs: Int,
        val durationMs: Int,
        val trimStartMs: Int,
    ) {
        val endMs: Int get() = startMs + durationMs
    }

    private data class ParsedTransition(
        val fromClipId: String,
        val toClipId: String,
        val type: String,
        val durationMs: Int,
    )

    private data class ExportResult(
        val videoPath: String,
        val captionsPath: String? = null,
    )

    /**
     * Export implementation (incremental toward full NLE):
     * - Respects clip startMs (inserts black gaps)
     * - Applies simple fade transitions (fade-out + fade-in)
     * - Supports picture-in-picture overlays from additional video tracks (simple bottom-right stacking)
     * - Mixes audio clips from audio tracks (timeline-aligned via adelay + amix)
     * - Exports captions sidecar (.srt) and can optionally burn-in captions
     */
    private fun exportTimelineInternal(timelineJson: String, outputFileName: String?): ExportResult {
        val project = JSONObject(timelineJson)
        val tracks = project.getJSONArray("tracks")

        val transitions = parseTransitions(project.optJSONArray("transitions"))
        val transitionFrom = transitions.associateBy { it.fromClipId }
        val transitionTo = transitions.associateBy { it.toClipId }

        val videoTracks = collectTracksByType(tracks, "video")
        if (videoTracks.isEmpty()) throw IllegalStateException("No video track found")

        val baseTrack = videoTracks.first()
        val baseClips = parseClips(baseTrack)
        if (baseClips.isEmpty()) throw IllegalStateException("No clips on the main video track")

        val baseClipById = baseClips.associateBy { it.id }

        val workDir = File(context.cacheDir, "video_export_${System.currentTimeMillis()}").apply { mkdirs() }

        val overlayTracks = videoTracks.drop(1)
        val overlayClips = overlayTracks.flatMap { parseClips(it) }

        val audioTracks = collectTracksByType(tracks, "audio")
        val audioClips = audioTracks.flatMap { parseClips(it) }
            .filter { it.type == "audio" }

        val captionsSrt = (project.opt("captionsSrt") as? String)?.takeIf { it.isNotBlank() }
        val burnInCaptions = project.optBoolean("burnInCaptions", false)

        val finalName = outputFileName?.takeIf { it.endsWith(".mp4") }
            ?: "blurr_export_${System.currentTimeMillis()}.mp4"
        val outputFile = File(context.getExternalFilesDir(null), finalName)

        val captionsFilePath = captionsSrt?.let {
            val nameWithoutExt = finalName.removeSuffix(".mp4")
            val srtFile = File(context.getExternalFilesDir(null), "$nameWithoutExt.srt")
            srtFile.writeText(it)
            srtFile.absolutePath
        }

        val needsCompose = overlayClips.isNotEmpty() || audioClips.isNotEmpty() || (burnInCaptions && captionsFilePath != null)

        val baseVideoFile = if (needsCompose) {
            File(workDir, "base.mp4")
        } else {
            outputFile
        }

        // Render base track segments (clips + gaps) then concat.
        val renderedSegments = renderBaseTrackSegments(
            baseClips = baseClips,
            baseClipById = baseClipById,
            transitionFrom = transitionFrom,
            transitionTo = transitionTo,
            workDir = workDir,
        )

        concatSegments(renderedSegments, baseVideoFile)

        if (!needsCompose) {
            // Sidecar captions already written.
            return ExportResult(videoPath = baseVideoFile.absolutePath, captionsPath = captionsFilePath)
        }

        // Render overlay segments (PiP) for additional video tracks.
        val overlaySegments = renderOverlaySegments(overlayClips, workDir)

        // Compose overlays, audio, and optional burned captions.
        composeFinal(
            baseVideoFile = baseVideoFile,
            overlaySegments = overlaySegments,
            audioClips = audioClips,
            outputFile = outputFile,
            captionsFilePath = captionsFilePath,
            burnInCaptions = burnInCaptions,
        )

        return ExportResult(videoPath = outputFile.absolutePath, captionsPath = captionsFilePath)
    }

    private fun parseTransitions(array: JSONArray?): List<ParsedTransition> {
        if (array == null) return emptyList()
        val out = mutableListOf<ParsedTransition>()
        for (i in 0 until array.length()) {
            val t = array.optJSONObject(i) ?: continue
            val from = t.optString("fromClipId")
            val to = t.optString("toClipId")
            val type = t.optString("type", "none")
            val dur = t.optInt("durationMs", 0)
            if (from.isBlank() || to.isBlank()) continue
            if (type == "none" || dur <= 0) continue
            out.add(ParsedTransition(from, to, type, dur))
        }
        return out
    }

    private fun collectTracksByType(tracks: JSONArray, type: String): List<JSONObject> {
        val out = mutableListOf<JSONObject>()
        for (i in 0 until tracks.length()) {
            val t = tracks.optJSONObject(i) ?: continue
            if (t.optString("type") == type) {
                out.add(t)
            }
        }
        return out
    }

    private fun parseClips(track: JSONObject): List<ParsedClip> {
        val clips = track.optJSONArray("clips") ?: return emptyList()
        val out = mutableListOf<ParsedClip>()
        for (i in 0 until clips.length()) {
            val c = clips.optJSONObject(i) ?: continue
            val id = c.optString("id")
            val type = c.optString("type")
            val uri = c.optString("uri")
            val startMs = c.optInt("startMs", 0)
            val durationMs = c.optInt("durationMs", 0)
            val trimStartMs = c.optInt("trimStartMs", 0)

            if (id.isBlank() || uri.isBlank() || durationMs <= 0) continue
            out.add(ParsedClip(id, type, uri, startMs, durationMs, trimStartMs))
        }
        return out.sortedBy { it.startMs }
    }

    private fun renderBaseTrackSegments(
        baseClips: List<ParsedClip>,
        baseClipById: Map<String, ParsedClip>,
        transitionFrom: Map<String, ParsedTransition>,
        transitionTo: Map<String, ParsedTransition>,
        workDir: File,
    ): List<File> {
        val segmentFiles = mutableListOf<File>()

        var cursorMs = 0
        var segIndex = 0

        for (clip in baseClips) {
            if (clip.startMs > cursorMs) {
                val gapMs = clip.startMs - cursorMs
                val gapFile = File(workDir, "segment_${segIndex}_gap.mp4")
                renderBlackSegment(gapMs, gapFile)
                segmentFiles.add(gapFile)
                segIndex++
                cursorMs = clip.startMs
            }

            val fadeInMs = transitionTo[clip.id]?.durationMs ?: 0

            val trFrom = transitionFrom[clip.id]
            val fadeOutMs = if (trFrom != null) {
                if (trFrom.type == "fadeToBlack") {
                    trFrom.durationMs
                } else {
                    val toClip = baseClipById[trFrom.toClipId]
                    if (toClip != null && toClip.startMs == clip.endMs) trFrom.durationMs else 0
                }
            } else {
                0
            }

            val outFile = File(workDir, "segment_${segIndex}_${clip.id}.mp4")
            renderVisualSegment(
                clip = clip,
                outFile = outFile,
                width = OUTPUT_W,
                height = OUTPUT_H,
                fps = OUTPUT_FPS,
                fadeInMs = fadeInMs,
                fadeOutMs = fadeOutMs,
                fadeOutToBlack = (trFrom?.type == "fadeToBlack"),
            )
            segmentFiles.add(outFile)
            segIndex++
            cursorMs = maxOf(cursorMs, clip.endMs)
        }

        return segmentFiles
    }

    private fun renderOverlaySegments(clips: List<ParsedClip>, workDir: File): List<Pair<ParsedClip, File>> {
        val out = mutableListOf<Pair<ParsedClip, File>>()
        var idx = 0
        for (clip in clips) {
            val outFile = File(workDir, "overlay_${idx}_${clip.id}.mp4")
            renderVisualSegment(
                clip = clip,
                outFile = outFile,
                width = PIP_W,
                height = PIP_H,
                fps = OUTPUT_FPS,
                fadeInMs = 0,
                fadeOutMs = 0,
                fadeOutToBlack = false,
            )
            out.add(clip to outFile)
            idx++
        }
        return out
    }

    private fun renderBlackSegment(durationMs: Int, outFile: File) {
        val durSec = durationMs / 1000.0
        val outPath = escapePath(outFile.absolutePath)
        val cmd = "-y -f lavfi -t $durSec -i color=c=black:s=${OUTPUT_W}x${OUTPUT_H}:r=$OUTPUT_FPS -c:v libx264 -preset veryfast -crf 23 -pix_fmt yuv420p $outPath"
        runFfmpeg(cmd)
    }

    private fun renderVisualSegment(
        clip: ParsedClip,
        outFile: File,
        width: Int,
        height: Int,
        fps: Int,
        fadeInMs: Int,
        fadeOutMs: Int,
        fadeOutToBlack: Boolean,
    ) {
        val uri = clip.uri
        if (uri.startsWith("http://") || uri.startsWith("https://")) {
            throw IllegalArgumentException("Network media not supported for export yet: $uri")
        }

        val type = clip.type
        val durSec = clip.durationMs / 1000.0
        val trimStartSec = clip.trimStartMs / 1000.0

        val inputPath = escapePath(uri)
        val outputPath = escapePath(outFile.absolutePath)

        val baseFilter = buildString {
            append("scale=$width:$height:force_original_aspect_ratio=decrease,")
            append("pad=$width:$height:(ow-iw)/2:(oh-ih)/2,")
            append("format=yuv420p")

            val fadeInSec = (fadeInMs / 1000.0).coerceAtMost(durSec.coerceAtLeast(0.0))
            if (fadeInSec > 0.0) {
                append(",fade=t=in:st=0:d=$fadeInSec")
            }

            val fadeOutSec = (fadeOutMs / 1000.0).coerceAtMost(durSec.coerceAtLeast(0.0))
            if (fadeOutSec > 0.0 && durSec > fadeOutSec) {
                val st = (durSec - fadeOutSec).coerceAtLeast(0.0)
                val color = if (fadeOutToBlack) ":color=black" else ""
                append(",fade=t=out:st=$st:d=$fadeOutSec$color")
            }
        }

        val filterArg = escapeFilter(baseFilter)

        val cmd = when (type) {
            "image" -> {
                "-y -loop 1 -t $durSec -i $inputPath -vf $filterArg -r $fps -c:v libx264 -preset veryfast -crf 23 -pix_fmt yuv420p $outputPath"
            }
            "video" -> {
                "-y -ss $trimStartSec -t $durSec -i $inputPath -vf $filterArg -r $fps -c:v libx264 -preset veryfast -crf 23 -pix_fmt yuv420p -an $outputPath"
            }
            // For audio tracks we don't generate visual segments.
            else -> {
                // Render a black segment to keep pipeline stable.
                "-y -f lavfi -t $durSec -i color=c=black:s=${width}x${height}:r=$fps -c:v libx264 -preset veryfast -crf 23 -pix_fmt yuv420p $outputPath"
            }
        }

        runFfmpeg(cmd)
    }

    private fun concatSegments(segmentFiles: List<File>, outputFile: File) {
        if (segmentFiles.isEmpty()) {
            throw IllegalStateException("No segments to concat")
        }

        val concatFile = File(outputFile.parentFile ?: segmentFiles.first().parentFile, "concat_${System.currentTimeMillis()}.txt")
        concatFile.writeText(segmentFiles.joinToString(separator = "\n") { "file '${it.absolutePath.replace("'", "\\'")}'" })

        val concatPath = escapePath(concatFile.absolutePath)
        val outPath = escapePath(outputFile.absolutePath)

        val cmd = "-y -f concat -safe 0 -i $concatPath -c:v libx264 -preset veryfast -crf 23 -pix_fmt yuv420p -movflags +faststart $outPath"
        runFfmpeg(cmd)
    }

    private fun composeFinal(
        baseVideoFile: File,
        overlaySegments: List<Pair<ParsedClip, File>>, // clip + rendered pip segment
        audioClips: List<ParsedClip>,
        outputFile: File,
        captionsFilePath: String?,
        burnInCaptions: Boolean,
    ) {
        val cmd = StringBuilder()
        cmd.append("-y ")

        // Inputs
        cmd.append("-i ").append(escapePath(baseVideoFile.absolutePath)).append(' ')

        overlaySegments.forEach { (_, segFile) ->
            cmd.append("-i ").append(escapePath(segFile.absolutePath)).append(' ')
        }

        // Audio inputs: use trim via -ss/-t at input level.
        audioClips.forEach { clip ->
            val uri = clip.uri
            if (uri.startsWith("http://") || uri.startsWith("https://")) {
                throw IllegalArgumentException("Network media not supported for export yet: $uri")
            }
            val trimStartSec = clip.trimStartMs / 1000.0
            val durSec = clip.durationMs / 1000.0
            cmd.append("-ss ").append(trimStartSec).append(' ')
            cmd.append("-t ").append(durSec).append(' ')
            cmd.append("-i ").append(escapePath(uri)).append(' ')
        }

        // Filter graph
        val filter = StringBuilder()

        // Video chain
        val baseLabel = "v0"
        filter.append("[0:v]setpts=PTS-STARTPTS[$baseLabel];")

        var currentV = baseLabel
        overlaySegments.forEachIndexed { idx, (clip, _) ->
            val inputIndex = 1 + idx
            val ovLabel = "ov$idx"
            val nextV = "v${idx + 1}"

            val startSec = clip.startMs / 1000.0
            val endSec = (clip.startMs + clip.durationMs) / 1000.0

            // Stack overlays upwards if multiple.
            val stackOffset = idx * (PIP_H + 12)
            val x = OUTPUT_W - PIP_W - PIP_MARGIN
            val y = (OUTPUT_H - PIP_H - PIP_MARGIN - stackOffset).coerceAtLeast(PIP_MARGIN)

            filter.append("[$inputIndex:v]setpts=PTS-STARTPTS+$startSec/TB[$ovLabel];")
            filter.append("[$currentV][$ovLabel]overlay=$x:$y:enable='between(t,$startSec,$endSec)'[$nextV];")
            currentV = nextV
        }

        var finalVideoLabel = currentV

        // Optional burn-in captions
        if (burnInCaptions && !captionsFilePath.isNullOrBlank()) {
            val burned = "vburn"
            val subtitleArg = escapeSubtitleFilterArg(captionsFilePath)
            filter.append("[$finalVideoLabel]subtitles=$subtitleArg[$burned];")
            finalVideoLabel = burned
        }

        // Audio chain
        val audioInputStart = 1 + overlaySegments.size
        val audioLabels = mutableListOf<String>()

        audioClips.forEachIndexed { idx, clip ->
            val inputIndex = audioInputStart + idx
            val delayed = "ad$idx"
            val startMs = clip.startMs

            filter.append("[$inputIndex:a]adelay=${startMs}|${startMs}[$delayed];")
            audioLabels.add(delayed)
        }

        val hasAudio = audioLabels.isNotEmpty()
        val audioOut = "aout"
        if (hasAudio) {
            if (audioLabels.size == 1) {
                filter.append("[${audioLabels.first()}]anull[$audioOut];")
            } else {
                audioLabels.forEach { filter.append("[$it]") }
                filter.append("amix=inputs=${audioLabels.size}:duration=longest[$audioOut];")
            }
        }

        cmd.append("-filter_complex ").append(escapeFilter(filter.toString())).append(' ')
        cmd.append("-map [").append(finalVideoLabel).append("] ")
        if (hasAudio) {
            cmd.append("-map [").append(audioOut).append("] ")
        }

        cmd.append("-c:v libx264 -preset veryfast -crf 23 -pix_fmt yuv420p -movflags +faststart ")

        if (hasAudio) {
            cmd.append("-c:a aac -b:a 192k -shortest ")
        }

        cmd.append(escapePath(outputFile.absolutePath))

        runFfmpeg(cmd.toString())
    }

    private fun runFfmpeg(cmd: String) {
        val rc = FFmpeg.execute(cmd)
        if (rc != 0) {
            val output = Config.getLastCommandOutput()
            throw IllegalStateException("FFmpeg failed (code=$rc): $output")
        }
    }

    private fun escapePath(path: String): String {
        return "\"" + path.replace("\\", "\\\\").replace("\"", "\\\"") + "\""
    }

    private fun escapeFilter(filter: String): String {
        return "\"" + filter.replace("\\", "\\\\").replace("\"", "\\\"") + "\""
    }

    private fun escapeSubtitleFilterArg(path: String): String {
        // subtitles filter uses ':' as separators, so escape it.
        val escaped = path
            .replace("\\", "\\\\")
            .replace(":", "\\:")
            .replace("'", "\\'")
        return "'$escaped'"
    }

    fun dispose() {
        methodChannel.setMethodCallHandler(null)
    }
}

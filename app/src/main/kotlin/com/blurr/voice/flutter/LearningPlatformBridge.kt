package com.blurr.voice.flutter

import android.content.Context
import android.util.Log
import com.blurr.voice.core.providers.UniversalLLMService
import com.blurr.voice.core.providers.UniversalTTSService
import com.blurr.voice.tools.GenerateInfographicTool
import com.blurr.voice.utilities.FreemiumManager
import com.chaquo.python.Python
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File

/**
 * Bridge for the AI-Native Learning Platform.
 *
 * Responsibilities:
 * - Extract plain text from uploaded files (PDF/DOCX/TXT/MD)
 * - Generate learning artifacts via UniversalLLMService (summaries, study guides, quizzes, flashcards)
 * - Knowledge-scoped Q&A chat
 * - Audio overview synthesis via UniversalTTSService (Pro)
 */
class LearningPlatformBridge(
    private val context: Context,
    flutterEngine: FlutterEngine
) {
    companion object {
        private const val CHANNEL = "com.blurr.learning_platform/bridge"
        private const val TAG = "LearningPlatformBridge"

        private const val FREE_CHAR_LIMIT = 8000
        private const val PRO_CHAR_LIMIT = 40000
    }

    private val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

    private val llmService by lazy { UniversalLLMService(context) }
    private val ttsService by lazy { UniversalTTSService(context) }
    private val freemiumManager by lazy { FreemiumManager() }

    init {
        setup()
    }

    private fun setup() {
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "checkProAccess" -> {
                    CoroutineScope(Dispatchers.IO).launch {
                        try {
                            val isPro = freemiumManager.isUserSubscribed()
                            withContext(Dispatchers.Main) { result.success(isPro) }
                        } catch (e: Exception) {
                            Log.e(TAG, "Failed to check pro access", e)
                            withContext(Dispatchers.Main) { result.success(false) }
                        }
                    }
                }

                "extractDocumentText" -> {
                    val bytes = call.argument<ByteArray>("bytes")
                    val fileName = call.argument<String>("fileName")
                    if (bytes == null || fileName.isNullOrBlank()) {
                        result.error("INVALID_ARGS", "bytes and fileName are required", null)
                        return@setMethodCallHandler
                    }

                    CoroutineScope(Dispatchers.IO).launch {
                        try {
                            val text = extractText(bytes, fileName)
                            withContext(Dispatchers.Main) { result.success(text) }
                        } catch (e: Exception) {
                            Log.e(TAG, "Failed to extract document text", e)
                            withContext(Dispatchers.Main) {
                                result.error("EXTRACTION_ERROR", e.message, null)
                            }
                        }
                    }
                }

                "generateSummary" -> {
                    val documentText = call.argument<String>("documentText") ?: ""
                    CoroutineScope(Dispatchers.IO).launch {
                        runGeneration(
                            operation = "summary",
                            documentText = documentText,
                            result = result,
                            prompt = buildSummaryPrompt(documentText)
                        )
                    }
                }

                "generateStudyGuide" -> {
                    val documentText = call.argument<String>("documentText") ?: ""
                    CoroutineScope(Dispatchers.IO).launch {
                        runGeneration(
                            operation = "study_guide",
                            documentText = documentText,
                            result = result,
                            prompt = buildStudyGuidePrompt(documentText)
                        )
                    }
                }

                "generateQuiz" -> {
                    val documentText = call.argument<String>("documentText") ?: ""
                    val count = call.argument<Int>("questionCount") ?: 8
                    CoroutineScope(Dispatchers.IO).launch {
                        runGeneration(
                            operation = "quiz",
                            documentText = documentText,
                            result = result,
                            prompt = buildQuizPrompt(documentText, count.coerceIn(3, 20))
                        )
                    }
                }

                "generateFlashcards" -> {
                    val documentText = call.argument<String>("documentText") ?: ""
                    val count = call.argument<Int>("cardCount") ?: 12
                    CoroutineScope(Dispatchers.IO).launch {
                        runGeneration(
                            operation = "flashcards",
                            documentText = documentText,
                            result = result,
                            prompt = buildFlashcardsPrompt(documentText, count.coerceIn(5, 40))
                        )
                    }
                }

                "askQuestion" -> {
                    val documentText = call.argument<String>("documentText") ?: ""
                    val question = call.argument<String>("question") ?: ""
                    val history = call.argument<List<Map<String, Any?>>>("history") ?: emptyList()

                    CoroutineScope(Dispatchers.IO).launch {
                        try {
                            val isPro = freemiumManager.isUserSubscribed()
                            val clippedDoc = clipDocument(documentText, isPro)

                            val messages = mutableListOf<Pair<String, String>>()
                            messages.add("system" to buildChatSystemPrompt())

                            // Keep last ~8 turns to avoid ballooning.
                            history.takeLast(16).forEach { item ->
                                val role = (item["role"] as? String) ?: return@forEach
                                val content = (item["content"] as? String) ?: ""
                                if (content.isNotBlank()) {
                                    messages.add(role to content)
                                }
                            }

                            messages.add(
                                "user" to """DOCUMENT (authoritative source):
$clippedDoc

QUESTION:
$question

Answer using ONLY the document above. If the answer is not in the document, say so."""
                            )

                            val response = llmService.generateChatCompletion(
                                messages = messages,
                                temperature = 0.4,
                                maxTokens = 1200
                            ) ?: ""

                            withContext(Dispatchers.Main) { result.success(response.trim()) }
                        } catch (e: Exception) {
                            Log.e(TAG, "Chat generation failed", e)
                            withContext(Dispatchers.Main) {
                                result.error("CHAT_ERROR", e.message, null)
                            }
                        }
                    }
                }

                "synthesizeAudio" -> {
                    val text = call.argument<String>("text") ?: ""
                    val voice = call.argument<String>("voice")

                    CoroutineScope(Dispatchers.IO).launch {
                        try {
                            val isPro = freemiumManager.isUserSubscribed()
                            if (!isPro) {
                                withContext(Dispatchers.Main) {
                                    result.error("PRO_REQUIRED", "Audio overviews require Pro", null)
                                }
                                return@launch
                            }

                            val bytes = ttsService.synthesize(text, voice)
                            if (bytes == null) {
                                withContext(Dispatchers.Main) {
                                    result.error("TTS_ERROR", "Failed to synthesize audio", null)
                                }
                                return@launch
                            }

                            val file = File(context.cacheDir, "learning_audio_${System.currentTimeMillis()}.mp3")
                            file.writeBytes(bytes)

                            withContext(Dispatchers.Main) { result.success(file.absolutePath) }
                        } catch (e: Exception) {
                            Log.e(TAG, "TTS failed", e)
                            withContext(Dispatchers.Main) { result.error("TTS_ERROR", e.message, null) }
                        }
                    }
                }

                "generateInfographic" -> {
                    val topic = call.argument<String>("topic") ?: ""
                    val style = call.argument<String>("style") ?: "professional"
                    val method = call.argument<String>("method") ?: GenerateInfographicTool.METHOD_D3JS
                    val data = call.argument<String>("data")

                    CoroutineScope(Dispatchers.IO).launch {
                        try {
                            val isPro = freemiumManager.isUserSubscribed()
                            if (!isPro) {
                                withContext(Dispatchers.Main) {
                                    result.error("PRO_REQUIRED", "Infographics require Pro", null)
                                }
                                return@launch
                            }

                            val tool = GenerateInfographicTool(context, confirmationHandler = null)

                            val params = mutableMapOf<String, Any>(
                                "topic" to topic,
                                "style" to style,
                                "method" to method
                            )

                            if (!data.isNullOrBlank()) {
                                params["data"] = data
                            }

                            val toolResult = tool.execute(params, emptyList())
                            if (!toolResult.success) {
                                withContext(Dispatchers.Main) {
                                    result.error("INFOGRAPHIC_ERROR", toolResult.error, null)
                                }
                                return@launch
                            }

                            val filePath = toolResult.getDataAsMap()?.get("file_path")?.toString() ?: ""
                            if (filePath.isBlank()) {
                                withContext(Dispatchers.Main) {
                                    result.error("INFOGRAPHIC_ERROR", "Infographic tool did not return a file path", null)
                                }
                                return@launch
                            }

                            withContext(Dispatchers.Main) { result.success(filePath) }
                        } catch (e: Exception) {
                            Log.e(TAG, "Infographic generation failed", e)
                            withContext(Dispatchers.Main) { result.error("INFOGRAPHIC_ERROR", e.message, null) }
                        }
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    private suspend fun runGeneration(
        operation: String,
        documentText: String,
        result: MethodChannel.Result,
        prompt: String
    ) {
        try {
            val isPro = freemiumManager.isUserSubscribed()
            val clippedDoc = clipDocument(documentText, isPro)

            if (!isPro && clippedDoc.length < documentText.length) {
                withContext(Dispatchers.Main) {
                    result.error("PRO_REQUIRED", "Long documents require Pro", null)
                }
                return
            }

            val response = llmService.generateChatCompletion(
                messages = listOf(
                    "system" to buildLearningSystemPrompt(operation),
                    "user" to prompt.replace("{DOCUMENT}", clippedDoc)
                ),
                temperature = 0.5,
                maxTokens = 2200
            ) ?: ""

            withContext(Dispatchers.Main) { result.success(response.trim()) }
        } catch (e: Exception) {
            Log.e(TAG, "Generation failed: $operation", e)
            withContext(Dispatchers.Main) { result.error("GENERATION_ERROR", e.message, null) }
        }
    }

    private fun clipDocument(text: String, isPro: Boolean): String {
        val limit = if (isPro) PRO_CHAR_LIMIT else FREE_CHAR_LIMIT
        val trimmed = text.trim()
        return if (trimmed.length <= limit) trimmed else trimmed.substring(0, limit)
    }

    private fun buildLearningSystemPrompt(operation: String): String {
        return """You are an AI-native learning assistant inside a mobile app.

Goals:
- Produce high-signal learning artifacts for studying.
- Be concise and structured for phone screens.
- Do not invent facts not present in the document.

Operation: $operation""".trimIndent()
    }

    private fun buildSummaryPrompt(documentText: String): String {
        return """DOCUMENT:
{DOCUMENT}

TASK:
Create a NotebookLM-style summary in Markdown.
- Start with a 1-paragraph overview.
- Then a bullet list of key ideas.
- Then a short outline (3–7 headings).
""".trimIndent()
    }

    private fun buildStudyGuidePrompt(documentText: String): String {
        return """DOCUMENT:
{DOCUMENT}

TASK:
Create a study guide in Markdown with:
- Key terms + definitions
- Concept map (as a simple bullet hierarchy)
- 5 practice questions with short answers
""".trimIndent()
    }

    private fun buildQuizPrompt(documentText: String, questionCount: Int): String {
        return """DOCUMENT:
{DOCUMENT}

TASK:
Generate a multiple-choice quiz as STRICT JSON (no Markdown fences).
Schema:
{
  "questions": [
    {
      "id": "q1",
      "question": "...",
      "choices": ["A", "B", "C", "D"],
      "answerIndex": 0,
      "explanation": "..."
    }
  ]
}
Rules:
- Exactly $questionCount questions
- 4 choices each
- answerIndex is 0..3
- Explanations must reference the document
""".trimIndent()
    }

    private fun buildFlashcardsPrompt(documentText: String, cardCount: Int): String {
        return """DOCUMENT:
{DOCUMENT}

TASK:
Generate study flashcards as STRICT JSON (no Markdown fences).
Schema:
{
  "cards": [
    {
      "id": "c1",
      "front": "Question / term",
      "back": "Answer / definition",
      "difficulty": 1
    }
  ]
}
Rules:
- Exactly $cardCount cards
- difficulty is 1..3
- Keep fronts short, backs clear
""".trimIndent()
    }

    private fun buildChatSystemPrompt(): String {
        return """You are a document-scoped Q&A assistant.

Rules:
- Use ONLY the provided document text.
- If the answer is not present, say: "I don't know based on this document.".
- Keep answers concise and mobile-friendly.
""".trimIndent()
    }

    private fun extractText(bytes: ByteArray, fileName: String): String {
        val ext = fileName.substringAfterLast('.', "").lowercase()
        return when (ext) {
            "txt", "md" -> String(bytes, Charsets.UTF_8)
            "pdf" -> extractPdfText(bytes, ext)
            "docx" -> extractDocxText(bytes, ext)
            else -> String(bytes, Charsets.UTF_8)
        }
    }

    private fun extractPdfText(bytes: ByteArray, ext: String): String {
        val file = File(context.cacheDir, "learning_import_${System.currentTimeMillis()}.$ext")
        file.writeBytes(bytes)

        val py = Python.getInstance()
        val main = py.getModule("__main__")
        main.put("file_path", file.absolutePath)
        main.callAttr(
            "exec",
            """
from pypdf import PdfReader
reader = PdfReader(file_path)
text_parts = []
for page in reader.pages:
    try:
        t = page.extract_text() or ""
    except Exception:
        t = ""
    if t:
        text_parts.append(t)
result_text = "\n\n".join(text_parts)
            """.trimIndent()
        )

        val out = main["result_text"]?.toString() ?: ""
        return out
    }

    private fun extractDocxText(bytes: ByteArray, ext: String): String {
        val file = File(context.cacheDir, "learning_import_${System.currentTimeMillis()}.$ext")
        file.writeBytes(bytes)

        val py = Python.getInstance()
        val main = py.getModule("__main__")
        main.put("file_path", file.absolutePath)
        main.callAttr(
            "exec",
            """
from docx import Document
_doc = Document(file_path)
paras = [p.text for p in _doc.paragraphs if p.text]
result_text = "\n".join(paras)
            """.trimIndent()
        )

        val out = main["result_text"]?.toString() ?: ""
        return out
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
    }
}

package com.blurr.voice.tools

import android.content.Context
import android.util.Log
import com.blurr.voice.agents.UserConfirmationHandler
import com.blurr.voice.agents.UserQuestion
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/**
 * Generate Infographic Tool
 *
 * Creates infographic-style visuals using either:
 * - D3.js (SVG written to app cache)
 * - Nano Banana Pro (AI image generation via [ImageGenerationTool])
 */
class GenerateInfographicTool(
    private val context: Context,
    private val confirmationHandler: UserConfirmationHandler? = null
) : BaseTool() {

    companion object {
        private const val TAG = "GenerateInfographicTool"

        const val METHOD_D3JS = "d3js"
        const val METHOD_NANO_BANANA_PRO = "nano_banana_pro"

        private const val PATH_MARKER = "INFOGRAPHIC_PATH:"
    }

    override val name: String = "generate_infographic"

    override val description: String = """
        Generate an infographic (SVG or image) about a topic.

        Methods:
        - d3js: Generates an SVG and writes it to app cache (fast, precise).
        - nano_banana_pro: Generates a polished image infographic via an image model.

        Parameters:
        - topic (required): subject/title of the infographic
        - style (optional): professional | colorful | minimal | modern | corporate
        - method (optional): d3js | nano_banana_pro
        - data (optional): JSON string used for the D3.js method
    """.trimIndent()

    override val parameters: List<ToolParameter> = listOf(
        ToolParameter(
            name = "topic",
            type = "string",
            description = "The subject or title of the infographic.",
            required = true
        ),
        ToolParameter(
            name = "style",
            type = "string",
            description = "Style preference for the infographic.",
            required = false,
            enum = listOf("professional", "colorful", "minimal", "modern", "corporate"),
            default = "professional"
        ),
        ToolParameter(
            name = "method",
            type = "string",
            description = "Generation method.",
            required = false,
            enum = listOf(METHOD_D3JS, METHOD_NANO_BANANA_PRO)
        ),
        ToolParameter(
            name = "data",
            type = "string",
            description = "Optional JSON string used by the D3.js method.",
            required = false
        )
    )

    private val imageTool by lazy { ImageGenerationTool(context) }
    private val unifiedShellTool by lazy { UnifiedShellTool(context) }

    override suspend fun execute(params: Map<String, Any>, context: List<ToolResult>): ToolResult =
        withContext(Dispatchers.IO) {
            try {
                validateParameters(params).getOrThrow()

                val topic: String = getRequiredParam(params, "topic")
                val style: String = getOptionalParam(params, "style", "professional")
                val data: String? = getOptionalParam(params, "data", null)
                val methodParam: String? = getOptionalParam(params, "method", null)

                val method = methodParam ?: askUserForMethod(topic, data != null)

                Log.d(TAG, "Generating infographic. topic=$topic method=$method")

                when (method) {
                    METHOD_D3JS -> generateWithD3js(topic, data, style)
                    METHOD_NANO_BANANA_PRO -> generateWithNanoBananaPro(topic, style)
                    else -> ToolResult.failure(name, "Invalid method: $method")
                }
            } catch (e: Exception) {
                Log.e(TAG, "Infographic generation failed", e)
                ToolResult.failure(name, e.message ?: "Infographic generation failed")
            }
        }

    private suspend fun askUserForMethod(topic: String, hasData: Boolean): String {
        val handler = confirmationHandler ?: return METHOD_D3JS

        val question = UserQuestion(
            question = "How would you like to generate the infographic about \"$topic\"?",
            options = listOf(
                "D3.js (SVG, fast and precise)",
                "Nano Banana Pro (AI image, polished layout)"
            ),
            context = buildString {
                append("D3.js writes a local SVG to cache and is best for charts/diagrams.\n")
                append("Nano Banana Pro generates a polished image infographic via an image model.")
                if (hasData) append("\n\nTip: You provided JSON data — D3.js is ideal for that.")
            },
            defaultOption = if (hasData) 0 else 1
        )

        val res = handler.askUser(question)
        return if (res.selectedOption == 1) METHOD_NANO_BANANA_PRO else METHOD_D3JS
    }

    private suspend fun generateWithNanoBananaPro(topic: String, style: String): ToolResult {
        val prompt = buildString {
            append("Create a professional infographic about: $topic\n\n")
            append("Style: $style\n\n")
            append("Requirements:\n")
            append("- Clear typography and strong hierarchy\n")
            append("- Visual structure suitable for mobile viewing\n")
            append("- Use icons/diagrams where helpful\n")
            append("- Avoid tiny text\n")
        }

        val result = imageTool.execute(
            params = mapOf(
                "prompt" to prompt,
                "size" to "1024x1024",
                "style" to style,
                "model" to "nano-banana-pro"
            ),
            context = emptyList()
        )

        if (!result.success) {
            return ToolResult.failure(name, result.error ?: "Image generation failed")
        }

        val imagePath = result.getDataAsMap()?.get("image_path")?.toString()
        if (imagePath.isNullOrBlank()) {
            return ToolResult.failure(name, "Image generated but no local path returned")
        }

        return ToolResult.success(
            toolName = name,
            data = mapOf(
                "method" to METHOD_NANO_BANANA_PRO,
                "file_path" to imagePath,
                "topic" to topic,
                "style" to style
            )
        )
    }

    private suspend fun generateWithD3js(topic: String, data: String?, style: String): ToolResult {
        val js = if (data != null) buildD3jsCodeWithData(topic, data, style) else buildD3jsCodeGeneric(topic, style)

        val result = unifiedShellTool.execute(
            params = mapOf(
                "code" to js,
                "language" to "javascript"
            ),
            context = emptyList()
        )

        if (!result.success) {
            return ToolResult.failure(name, result.error ?: "D3.js generation failed")
        }

        val output = result.getDataAsString()
        val filePath = output
            .lineSequence()
            .map { it.trim() }
            .firstOrNull { it.startsWith(PATH_MARKER) }
            ?.removePrefix(PATH_MARKER)
            ?.trim()
            ?: output
                .lineSequence()
                .firstOrNull { it.startsWith("File written:") }
                ?.removePrefix("File written:")
                ?.trim()

        if (filePath.isNullOrBlank()) {
            return ToolResult.failure(name, "D3.js executed but did not return a file path")
        }

        return ToolResult.success(
            toolName = name,
            data = mapOf(
                "method" to METHOD_D3JS,
                "file_path" to filePath,
                "topic" to topic,
                "style" to style
            )
        )
    }

    private fun buildD3jsCodeWithData(topic: String, data: String, style: String): String {
        val safeTopic = topic.replace("\"", "\\\"")
        return """
            // D3.js Infographic: $safeTopic
            const rawData = $data;
            const data = typeof rawData === 'string' ? JSON.parse(rawData) : rawData;

            const width = 800;
            const height = 600;
            const padding = 60;

            let visualization = '';

            if (Array.isArray(data) && data.length > 0) {
              if (typeof data[0] === 'number') {
                const maxValue = Math.max(...data);
                const barWidth = (width - 2 * padding) / data.length - 10;

                const bars = data.map((value, index) => {
                  const x = padding + index * (barWidth + 10);
                  const barHeight = (value / maxValue) * (height - 2 * padding);
                  const y = height - padding - barHeight;
                  return `<rect x="${'$'}{x}" y="${'$'}{y}" width="${'$'}{barWidth}" height="${'$'}{barHeight}" fill="#4285F4"/>`;
                }).join('\n');

                visualization = `<svg width="${'$'}{width}" height="${'$'}{height}" xmlns="http://www.w3.org/2000/svg">
                  <rect width="${'$'}{width}" height="${'$'}{height}" fill="#f5f5f5"/>
                  <text x="${'$'}{width/2}" y="40" font-size="24" font-weight="bold" text-anchor="middle">$safeTopic</text>
                  <line x1="${'$'}{padding}" y1="${'$'}{height-padding}" x2="${'$'}{width-padding}" y2="${'$'}{height-padding}" stroke="#333" stroke-width="2"/>
                  <line x1="${'$'}{padding}" y1="${'$'}{padding}" x2="${'$'}{padding}" y2="${'$'}{height-padding}" stroke="#333" stroke-width="2"/>
                  ${'$'}{bars}
                  <text x="${'$'}{width/2}" y="${'$'}{height-20}" font-size="12" text-anchor="middle" fill="#666">Style: $style</text>
                </svg>`;
              } else {
                const rows = data.map((item, index) => {
                  const y = 90 + index * 28;
                  return `<text x="40" y="${'$'}{y}" font-size="14" fill="#333">${'$'}{JSON.stringify(item)}</text>`;
                }).join('\n');

                visualization = `<svg width="${'$'}{width}" height="${'$'}{Math.max(height, 120 + data.length * 28)}" xmlns="http://www.w3.org/2000/svg">
                  <rect width="${'$'}{width}" height="${'$'}{height}" fill="#f5f5f5"/>
                  <text x="${'$'}{width/2}" y="40" font-size="24" font-weight="bold" text-anchor="middle">$safeTopic</text>
                  ${'$'}{rows}
                </svg>`;
              }
            } else {
              visualization = '<svg width="400" height="200" xmlns="http://www.w3.org/2000/svg"><text x="200" y="100" text-anchor="middle">Unsupported data</text></svg>';
            }

            const filename = ('infographic_$safeTopic.svg').replace(/\s+/g, '_').toLowerCase();
            const absPath = fs.writeFile(filename, visualization);
            console.log('$PATH_MARKER' + absPath);
        """.trimIndent()
    }

    private fun buildD3jsCodeGeneric(topic: String, style: String): String {
        val safeTopic = topic.replace("\"", "\\\"")
        return """
            // D3.js Infographic: $safeTopic
            const width = 800;
            const height = 600;
            const sampleData = [30, 86, 168, 281, 303, 365];

            const maxValue = Math.max(...sampleData);
            const barWidth = 60;
            const spacing = 20;

            const bars = sampleData.map((value, index) => {
              const x = 100 + index * (barWidth + spacing);
              const barHeight = (value / maxValue) * 400;
              const y = 500 - barHeight;
              return `<rect x="${'$'}{x}" y="${'$'}{y}" width="${'$'}{barWidth}" height="${'$'}{barHeight}" fill="#4285F4" stroke="white" stroke-width="2"/>`;
            }).join('\n');

            const svg = `<svg width="${'$'}{width}" height="${'$'}{height}" xmlns="http://www.w3.org/2000/svg">
              <rect width="${'$'}{width}" height="${'$'}{height}" fill="#f5f5f5"/>
              <text x="${'$'}{width/2}" y="60" font-size="32" font-weight="bold" text-anchor="middle" fill="#333">$safeTopic</text>
              <text x="${'$'}{width/2}" y="90" font-size="16" text-anchor="middle" fill="#666">Sample data • Style: $style</text>
              ${'$'}{bars}
            </svg>`;

            const filename = ('infographic_$safeTopic.svg').replace(/\s+/g, '_').toLowerCase();
            const absPath = fs.writeFile(filename, svg);
            console.log('$PATH_MARKER' + absPath);
        """.trimIndent()
    }
}

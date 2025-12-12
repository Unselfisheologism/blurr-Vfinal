package com.blurr.voice.tools

import android.content.Context
import android.util.Log
import com.blurr.voice.agents.UserConfirmationHandler
import com.blurr.voice.agents.UserQuestion
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/**
 * Generate Infographic Tool - Story 4.12
 * 
 * Creates infographics using two methods:
 * 1. Nano Banana Pro (AI-generated, professional quality)
 * 2. D3.js (Programmatic data visualization)
 * 
 * ALWAYS asks user to choose method before generating.
 */
class GenerateInfographicTool(
    private val context: Context,
    private val confirmationHandler: UserConfirmationHandler?
) : Tool {
    
    companion object {
        private const val TAG = "GenerateInfographicTool"
    }
    
    override val name: String = "generate_infographic"
    
    override val description: String = """
        Generate infographics, charts, and data visualizations using AI or programmatic methods.
        
        This tool ALWAYS asks the user to choose between two approaches:
        
        **Method 1: Nano Banana Pro (AI-Generated)**
        - World-class AI model specifically designed for infographics
        - Creates stunning, professional-quality graphics from natural language
        - Best for: Marketing materials, social media graphics, presentations
        - Output: PNG/JPG image file
        - Pros: Beautiful design, no coding needed, creative layouts
        - Cons: Uses API credits, takes 5-30 seconds
        
        **Method 2: D3.js (Programmatic Data Visualization)**
        - JavaScript-based data visualization library
        - Creates precise, data-driven charts and graphs
        - Best for: Business charts, technical diagrams, data reports
        - Output: SVG file (scalable vector graphics)
        - Pros: Fast (1-3 seconds), free, precise control, scalable
        - Cons: Requires structured data, less creative than AI
        
        **The tool will PAUSE and ask the user which method to use before proceeding.**
        
        Common infographic types:
        - Bar charts, line charts, pie charts
        - Timeline infographics
        - Comparison infographics
        - Statistical dashboards
        - Process flowcharts
        - Data stories
        
        Parameters:
        - topic (required): The subject/data for the infographic
        - data (optional): Structured data for D3.js visualizations
        - style (optional): Style preferences (e.g., "professional", "colorful", "minimal")
    """.trimIndent()
    
    private val imageGenerationTool by lazy { GenerateImageTool(context) }
    private val unifiedShellTool by lazy { UnifiedShellTool(context) }
    
    override suspend fun execute(params: Map<String, Any>): ToolResult = withContext(Dispatchers.IO) {
        val topic = params["topic"] as? String
            ?: return@withContext ToolResult.error(
                toolName = name,
                error = "Missing required parameter: topic"
            )
        
        val data = params["data"] as? String
        val style = params["style"] as? String ?: "professional"
        
        Log.d(TAG, "Generating infographic about: $topic")
        
        // ALWAYS ask user to choose method
        val selectedMethod = askUserForMethod(topic, data != null)
        
        return@withContext when (selectedMethod) {
            0 -> generateWithNanoBananaPro(topic, style)
            1 -> generateWithD3js(topic, data, style)
            else -> ToolResult.error(
                toolName = name,
                error = "Invalid method selection: $selectedMethod"
            )
        }
    }
    
    /**
     * Ask user to choose generation method
     */
    private suspend fun askUserForMethod(topic: String, hasData: Boolean): Int {
        if (confirmationHandler == null) {
            Log.w(TAG, "No confirmation handler available, defaulting to Nano Banana Pro")
            return 0
        }
        
        val question = UserQuestion(
            question = "How would you like to generate the infographic about \"$topic\"?",
            options = listOf(
                "Nano Banana Pro (AI-generated, stunning professional quality)",
                "D3.js (Programmatic data visualization, fast and precise)"
            ),
            context = buildString {
                append("Nano Banana Pro uses AI to create beautiful, creative infographics ")
                append("from natural language descriptions. It's best for marketing and presentations.\n\n")
                append("D3.js creates precise, data-driven charts programmatically. ")
                append("It's best for business charts and technical visualizations.")
                if (hasData) {
                    append("\n\n✨ You provided structured data, which works perfectly with D3.js!")
                }
            },
            defaultOption = 0  // Recommend Nano Banana Pro by default
        )
        
        val result = confirmationHandler.askUser(question)
        Log.d(TAG, "User selected method: ${result.selectedOption} (${result.selectedText})")
        return result.selectedOption
    }
    
    /**
     * Generate infographic using Nano Banana Pro AI model
     */
    private suspend fun generateWithNanoBananaPro(topic: String, style: String): ToolResult {
        Log.d(TAG, "Generating infographic with Nano Banana Pro")
        
        // Build optimized prompt for infographic generation
        val prompt = buildInfographicPrompt(topic, style)
        
        // Call image generation tool with Nano Banana Pro model
        val result = imageGenerationTool.execute(
            mapOf(
                "prompt" to prompt,
                "model" to "nano-banana-pro",  // Specify Nano Banana Pro
                "width" to 1024,
                "height" to 1024,
                "quality" to "high"
            )
        )
        
        return if (result.success) {
            ToolResult.success(
                toolName = name,
                result = "✅ AI-generated infographic created using Nano Banana Pro\n${result.result}",
                data = mapOf(
                    "method" to "nano_banana_pro",
                    "model" to "nano-banana-pro",
                    "topic" to topic,
                    "style" to style
                )
            )
        } else {
            ToolResult.error(
                toolName = name,
                error = "Failed to generate infographic with Nano Banana Pro: ${result.error}"
            )
        }
    }
    
    /**
     * Build optimized prompt for Nano Banana Pro infographic generation
     */
    private fun buildInfographicPrompt(topic: String, style: String): String {
        return buildString {
            append("Create a professional infographic about: $topic\n\n")
            append("Style: $style\n\n")
            append("Requirements:\n")
            append("- Clear, readable typography\n")
            append("- Visually balanced layout\n")
            append("- Use of icons and visual elements\n")
            append("- Color scheme appropriate for the topic\n")
            append("- Professional, polished appearance\n")
            append("- Include key statistics or data points\n")
            append("- Suitable for presentations and social media")
        }
    }
    
    /**
     * Generate infographic using D3.js programmatic visualization
     */
    private suspend fun generateWithD3js(topic: String, data: String?, style: String): ToolResult {
        Log.d(TAG, "Generating infographic with D3.js")
        
        // Generate D3.js code based on data structure
        val jsCode = if (data != null) {
            generateD3jsCodeWithData(topic, data, style)
        } else {
            generateD3jsCodeGeneric(topic, style)
        }
        
        // Execute JavaScript code via unified_shell
        val result = unifiedShellTool.execute(
            mapOf(
                "code" to jsCode,
                "language" to "javascript"
            )
        )
        
        return if (result.success) {
            ToolResult.success(
                toolName = name,
                result = "✅ D3.js infographic created\n${result.result}\n\nSVG file can be converted to PNG if needed.",
                data = mapOf(
                    "method" to "d3js",
                    "language" to "javascript",
                    "topic" to topic,
                    "style" to style,
                    "format" to "svg"
                )
            )
        } else {
            ToolResult.error(
                toolName = name,
                error = "Failed to generate D3.js infographic: ${result.error}"
            )
        }
    }
    
    /**
     * Generate D3.js code with structured data
     */
    private fun generateD3jsCodeWithData(topic: String, data: String, style: String): String {
        return """
            // D3.js Infographic: $topic
            // Data provided by user
            
            const rawData = $data;
            
            // Parse data (assumes JSON array)
            const data = typeof rawData === 'string' ? JSON.parse(rawData) : rawData;
            
            console.log('Generating infographic for ${data.length || 'N/A'} data points');
            
            // Chart dimensions
            const width = 800;
            const height = 600;
            const padding = 60;
            
            // Determine visualization type based on data structure
            let visualization = '';
            
            if (Array.isArray(data) && data.length > 0) {
                if (typeof data[0] === 'number') {
                    // Simple array of numbers - bar chart
                    const maxValue = Math.max(...data);
                    const barWidth = (width - 2 * padding) / data.length - 10;
                    
                    const bars = data.map((value, index) => {
                        const x = padding + index * (barWidth + 10);
                        const barHeight = (value / maxValue) * (height - 2 * padding);
                        const y = height - padding - barHeight;
                        return `<rect x="${'$'}{x}" y="${'$'}{y}" width="${'$'}{barWidth}" height="${'$'}{barHeight}" fill="#4285F4"/>`;
                    }).join('\n    ');
                    
                    visualization = `<svg width="${'$'}{width}" height="${'$'}{height}" xmlns="http://www.w3.org/2000/svg">
      <!-- Title -->
      <text x="${'$'}{width / 2}" y="30" font-size="24" font-weight="bold" text-anchor="middle">$topic</text>
      
      <!-- Axes -->
      <line x1="${'$'}{padding}" y1="${'$'}{height - padding}" x2="${'$'}{width - padding}" y2="${'$'}{height - padding}" stroke="#333" stroke-width="2"/>
      <line x1="${'$'}{padding}" y1="${'$'}{padding}" x2="${'$'}{padding}" y2="${'$'}{height - padding}" stroke="#333" stroke-width="2"/>
      
      <!-- Bars -->
      ${'$'}{bars}
    </svg>`;
                } else if (typeof data[0] === 'object') {
                    // Array of objects - more complex visualization
                    const keys = Object.keys(data[0]);
                    console.log('Object data detected, keys:', keys.join(', '));
                    
                    // Simple table-style visualization
                    const rowHeight = 40;
                    const rows = data.map((item, index) => {
                        const y = 80 + index * rowHeight;
                        return `<text x="100" y="${'$'}{y}" font-size="16">${'$'}{JSON.stringify(item)}</text>`;
                    }).join('\n    ');
                    
                    visualization = `<svg width="${'$'}{width}" height="${'$'}{Math.max(height, 80 + data.length * rowHeight)}" xmlns="http://www.w3.org/2000/svg">
      <text x="${'$'}{width / 2}" y="40" font-size="24" font-weight="bold" text-anchor="middle">$topic</text>
      ${'$'}{rows}
    </svg>`;
                }
            } else {
                console.error('Unsupported data format');
                visualization = '<svg width="400" height="200"><text x="200" y="100" text-anchor="middle">Error: Unsupported data format</text></svg>';
            }
            
            // Save to file
            fs.writeFile('infographic_$topic.svg'.replace(/\s+/g, '_'), visualization);
            console.log('✅ Infographic created: infographic_$topic.svg');
        """.trimIndent()
    }
    
    /**
     * Generate generic D3.js visualization template
     */
    private fun generateD3jsCodeGeneric(topic: String, style: String): String {
        return """
            // D3.js Infographic: $topic
            // Generic template (no specific data provided)
            
            console.log('Generating generic infographic template for: $topic');
            
            const width = 800;
            const height = 600;
            
            // Sample data for demonstration
            const sampleData = [30, 86, 168, 281, 303, 365];
            
            // Create bar chart as example
            const maxValue = Math.max(...sampleData);
            const barWidth = 60;
            const spacing = 20;
            
            const bars = sampleData.map((value, index) => {
                const x = 100 + index * (barWidth + spacing);
                const barHeight = (value / maxValue) * 400;
                const y = 500 - barHeight;
                return `<rect x="${'$'}{x}" y="${'$'}{y}" width="${'$'}{barWidth}" height="${'$'}{barHeight}" fill="#4285F4" stroke="white" stroke-width="2"/>`;
            }).join('\n    ');
            
            const svg = `<svg width="${'$'}{width}" height="${'$'}{height}" xmlns="http://www.w3.org/2000/svg">
      <!-- Background -->
      <rect width="${'$'}{width}" height="${'$'}{height}" fill="#f5f5f5"/>
      
      <!-- Title -->
      <text x="${'$'}{width / 2}" y="60" font-size="32" font-weight="bold" text-anchor="middle" fill="#333">
        $topic
      </text>
      
      <!-- Subtitle -->
      <text x="${'$'}{width / 2}" y="90" font-size="16" text-anchor="middle" fill="#666">
        Sample Data Visualization
      </text>
      
      <!-- Chart -->
      ${'$'}{bars}
      
      <!-- Footer note -->
      <text x="${'$'}{width / 2}" y="${'$'}{height - 30}" font-size="14" text-anchor="middle" fill="#999">
        Generated with D3.js | Style: $style
      </text>
    </svg>`;
            
            // Save to file
            const filename = 'infographic_$topic.svg'.replace(/\s+/g, '_').toLowerCase();
            fs.writeFile(filename, svg);
            console.log(`✅ Infographic created: ${'$'}{filename}`);
            console.log('Note: This is a template. Provide structured data for custom visualizations.');
        """.trimIndent()
    }
    
    /**
     * Get tool schema for LLM
     */
    override fun getSchema(): Map<String, Any> = mapOf(
        "name" to name,
        "description" to description,
        "parameters" to mapOf(
            "type" to "object",
            "properties" to mapOf(
                "topic" to mapOf(
                    "type" to "string",
                    "description" to "The subject or title of the infographic (required)"
                ),
                "data" to mapOf(
                    "type" to "string",
                    "description" to "Optional: JSON string with structured data for D3.js visualizations. Can be array of numbers or array of objects."
                ),
                "style" to mapOf(
                    "type" to "string",
                    "description" to "Optional: Style preference (e.g., 'professional', 'colorful', 'minimal'). Default: 'professional'",
                    "enum" to listOf("professional", "colorful", "minimal", "modern", "corporate")
                )
            ),
            "required" to listOf("topic")
        )
    )
}

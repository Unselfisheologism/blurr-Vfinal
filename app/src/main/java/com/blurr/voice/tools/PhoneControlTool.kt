package com.twent.voice.tools

import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import com.twent.voice.ScreenInteractionService
import com.twent.voice.api.Eyes
import com.twent.voice.api.Finger
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

/**
 * Phone Control Tool - Story 4.17
 * 
 * Wraps the existing UI automation capabilities (ScreenInteractionService, Finger, Eyes APIs)
 * to allow the Ultra-Generalist Agent to control the phone.
 * 
 * This tool provides ZERO new functionality - it only exposes the existing,
 * fully-functional UI automation as a tool interface.
 * 
 * Existing Capabilities (from ScreenInteractionService, Finger, Eyes):
 * - Click/tap at coordinates
 * - Long press
 * - Swipe gestures
 * - Scroll
 * - Type text in focused fields
 * - Press hardware buttons (Home, Back, Recents)
 * - Open apps
 * - Read screen content (XML hierarchy)
 * - Take screenshots
 * - Get current app/activity
 */
class PhoneControlTool(
    private val context: Context
) : BaseTool() {
    
    companion object {
        private const val TAG = "PhoneControlTool"
    }
    
    private val finger = Finger(context)
    private val eyes = Eyes(context)
    
    override val name: String = "phone_control"
    
    override val description: String = 
        "Control the phone using UI automation. Can tap, swipe, type, open apps, " +
        "read screen content, press buttons (home/back), and perform any UI interaction. " +
        "This gives you full control over the phone's user interface."
    
    override val parameters: List<ToolParameter> = listOf(
        ToolParameter(
            name = "action",
            type = "string",
            description = "The action to perform",
            required = true,
            enum = listOf(
                "tap",           // Click at coordinates
                "long_press",    // Long press at coordinates
                "swipe",         // Swipe from one point to another
                "scroll_down",   // Scroll down
                "scroll_up",     // Scroll up
                "type",          // Type text in focused field
                "press_back",    // Press back button
                "press_home",    // Press home button
                "press_recents", // Press app switcher
                "press_enter",   // Press enter/done on keyboard
                "open_app",      // Open an application
                "read_screen",   // Get screen content as text
                "screenshot",    // Take a screenshot
                "get_current_app" // Get current foreground app
            )
        ),
        ToolParameter(
            name = "x",
            type = "number",
            description = "X coordinate for tap/long_press actions (required for tap, long_press, swipe)",
            required = false
        ),
        ToolParameter(
            name = "y",
            type = "number",
            description = "Y coordinate for tap/long_press actions (required for tap, long_press, swipe)",
            required = false
        ),
        ToolParameter(
            name = "x2",
            type = "number",
            description = "End X coordinate for swipe action (required for swipe)",
            required = false
        ),
        ToolParameter(
            name = "y2",
            type = "number",
            description = "End Y coordinate for swipe action (required for swipe)",
            required = false
        ),
        ToolParameter(
            name = "duration",
            type = "number",
            description = "Duration in milliseconds for swipe/scroll (default: 300)",
            required = false
        ),
        ToolParameter(
            name = "text",
            type = "string",
            description = "Text to type (required for type action)",
            required = false
        ),
        ToolParameter(
            name = "app_name",
            type = "string",
            description = "Name or package name of app to open (required for open_app action)",
            required = false
        ),
        ToolParameter(
            name = "pixels",
            type = "number",
            description = "Number of pixels to scroll (for scroll_down/scroll_up, default: 500)",
            required = false
        )
    )
    
    override suspend fun execute(
        params: Map<String, Any>,
        context: List<ToolResult>
    ): ToolResult {
        return try {
            // Validate parameters
            validateParameters(params).getOrThrow()
            
            // Check if accessibility service is running
            val service = ScreenInteractionService.instance
            if (service == null) {
                return ToolResult.failure(
                    toolName = name,
                    error = "Accessibility service is not running. Please enable accessibility permissions for Twent."
                )
            }
            
            // Extract action
            val action: String = getRequiredParam(params, "action")
            
            Log.d(TAG, "Executing phone control action: $action")
            
            // Execute action
            val result = when (action) {
                "tap" -> executeTap(params)
                "long_press" -> executeLongPress(params)
                "swipe" -> executeSwipe(params)
                "scroll_down" -> executeScrollDown(params)
                "scroll_up" -> executeScrollUp(params)
                "type" -> executeType(params)
                "press_back" -> executePressBack()
                "press_home" -> executePressHome()
                "press_recents" -> executePressRecents()
                "press_enter" -> executePressEnter()
                "open_app" -> executeOpenApp(params)
                "read_screen" -> executeReadScreen()
                "screenshot" -> executeScreenshot()
                "get_current_app" -> executeGetCurrentApp()
                else -> ToolResult.failure(
                    toolName = name,
                    error = "Unknown action: $action"
                )
            }
            
            result
            
        } catch (e: Exception) {
            Log.e(TAG, "Error executing phone control", e)
            ToolResult.failure(
                toolName = name,
                error = "Phone control error: ${e.message}"
            )
        }
    }
    
    /**
     * Execute tap action at coordinates
     */
    private suspend fun executeTap(params: Map<String, Any>): ToolResult {
        val x = getRequiredParam<Number>(params, "x").toFloat()
        val y = getRequiredParam<Number>(params, "y").toFloat()
        
        return withContext(Dispatchers.Main) {
            try {
                finger.tap(x, y)
                ToolResult.success(
                    toolName = name,
                    result = "Tapped at coordinates ($x, $y)",
                    data = mapOf("x" to x, "y" to y, "action" to "tap")
                )
            } catch (e: Exception) {
                ToolResult.failure(
                    toolName = name,
                    error = "Tap failed: ${e.message}"
                )
            }
        }
    }
    
    /**
     * Execute long press action at coordinates
     */
    private suspend fun executeLongPress(params: Map<String, Any>): ToolResult {
        val x = getRequiredParam<Number>(params, "x").toFloat()
        val y = getRequiredParam<Number>(params, "y").toFloat()
        
        return withContext(Dispatchers.Main) {
            try {
                finger.longPress(x, y)
                ToolResult.success(
                    toolName = name,
                    result = "Long pressed at coordinates ($x, $y)",
                    data = mapOf("x" to x, "y" to y, "action" to "long_press")
                )
            } catch (e: Exception) {
                ToolResult.failure(
                    toolName = name,
                    error = "Long press failed: ${e.message}"
                )
            }
        }
    }
    
    /**
     * Execute swipe gesture
     */
    private suspend fun executeSwipe(params: Map<String, Any>): ToolResult {
        val x1 = getRequiredParam<Number>(params, "x").toFloat()
        val y1 = getRequiredParam<Number>(params, "y").toFloat()
        val x2 = getRequiredParam<Number>(params, "x2").toFloat()
        val y2 = getRequiredParam<Number>(params, "y2").toFloat()
        val duration = getOptionalParam(params, "duration", 300).toLong()
        
        return withContext(Dispatchers.Main) {
            try {
                finger.swipe(x1, y1, x2, y2, duration)
                ToolResult.success(
                    toolName = name,
                    result = "Swiped from ($x1, $y1) to ($x2, $y2) over ${duration}ms",
                    data = mapOf(
                        "x1" to x1, "y1" to y1,
                        "x2" to x2, "y2" to y2,
                        "duration" to duration,
                        "action" to "swipe"
                    )
                )
            } catch (e: Exception) {
                ToolResult.failure(
                    toolName = name,
                    error = "Swipe failed: ${e.message}"
                )
            }
        }
    }
    
    /**
     * Execute scroll down
     */
    private suspend fun executeScrollDown(params: Map<String, Any>): ToolResult {
        val pixels = getOptionalParam(params, "pixels", 500)
        
        return withContext(Dispatchers.Main) {
            try {
                finger.scrollDown(pixels)
                ToolResult.success(
                    toolName = name,
                    result = "Scrolled down $pixels pixels",
                    data = mapOf("pixels" to pixels, "action" to "scroll_down")
                )
            } catch (e: Exception) {
                ToolResult.failure(
                    toolName = name,
                    error = "Scroll down failed: ${e.message}"
                )
            }
        }
    }
    
    /**
     * Execute scroll up
     */
    private suspend fun executeScrollUp(params: Map<String, Any>): ToolResult {
        val pixels = getOptionalParam(params, "pixels", 500)
        
        return withContext(Dispatchers.Main) {
            try {
                finger.scrollUp(pixels)
                ToolResult.success(
                    toolName = name,
                    result = "Scrolled up $pixels pixels",
                    data = mapOf("pixels" to pixels, "action" to "scroll_up")
                )
            } catch (e: Exception) {
                ToolResult.failure(
                    toolName = name,
                    error = "Scroll up failed: ${e.message}"
                )
            }
        }
    }
    
    /**
     * Execute type text
     */
    private suspend fun executeType(params: Map<String, Any>): ToolResult {
        val text = getRequiredParam<String>(params, "text")
        
        return withContext(Dispatchers.Main) {
            try {
                // Check if typing is available (keyboard visible)
                val isTypingAvailable = eyes.getKeyBoardStatus()
                if (!isTypingAvailable) {
                    return@withContext ToolResult.failure(
                        toolName = name,
                        error = "No text field is focused. Tap on a text field first before typing."
                    )
                }
                
                finger.type(text)
                ToolResult.success(
                    toolName = name,
                    result = "Typed text: '$text'",
                    data = mapOf("text" to text, "action" to "type")
                )
            } catch (e: Exception) {
                ToolResult.failure(
                    toolName = name,
                    error = "Type failed: ${e.message}"
                )
            }
        }
    }
    
    /**
     * Execute press back button
     */
    private suspend fun executePressBack(): ToolResult {
        return withContext(Dispatchers.Main) {
            try {
                finger.pressBack()
                ToolResult.success(
                    toolName = name,
                    result = "Pressed back button",
                    data = mapOf("action" to "press_back")
                )
            } catch (e: Exception) {
                ToolResult.failure(
                    toolName = name,
                    error = "Press back failed: ${e.message}"
                )
            }
        }
    }
    
    /**
     * Execute press home button
     */
    private suspend fun executePressHome(): ToolResult {
        return withContext(Dispatchers.Main) {
            try {
                finger.pressHome()
                ToolResult.success(
                    toolName = name,
                    result = "Pressed home button",
                    data = mapOf("action" to "press_home")
                )
            } catch (e: Exception) {
                ToolResult.failure(
                    toolName = name,
                    error = "Press home failed: ${e.message}"
                )
            }
        }
    }
    
    /**
     * Execute press recents button
     */
    private suspend fun executePressRecents(): ToolResult {
        return withContext(Dispatchers.Main) {
            try {
                finger.pressRecents()
                ToolResult.success(
                    toolName = name,
                    result = "Pressed recents button (app switcher)",
                    data = mapOf("action" to "press_recents")
                )
            } catch (e: Exception) {
                ToolResult.failure(
                    toolName = name,
                    error = "Press recents failed: ${e.message}"
                )
            }
        }
    }
    
    /**
     * Execute press enter button
     */
    @RequiresApi(Build.VERSION_CODES.R)
    private suspend fun executePressEnter(): ToolResult {
        return withContext(Dispatchers.Main) {
            try {
                finger.pressEnter()
                ToolResult.success(
                    toolName = name,
                    result = "Pressed enter/done button",
                    data = mapOf("action" to "press_enter")
                )
            } catch (e: Exception) {
                ToolResult.failure(
                    toolName = name,
                    error = "Press enter failed: ${e.message}"
                )
            }
        }
    }
    
    /**
     * Execute open app
     */
    private suspend fun executeOpenApp(params: Map<String, Any>): ToolResult {
        val appName = getRequiredParam<String>(params, "app_name")
        
        return withContext(Dispatchers.Main) {
            try {
                finger.openApp(appName)
                ToolResult.success(
                    toolName = name,
                    result = "Opening app: $appName",
                    data = mapOf("app_name" to appName, "action" to "open_app")
                )
            } catch (e: Exception) {
                ToolResult.failure(
                    toolName = name,
                    error = "Open app failed: ${e.message}"
                )
            }
        }
    }
    
    /**
     * Execute read screen content
     */
    @RequiresApi(Build.VERSION_CODES.O)
    private suspend fun executeReadScreen(): ToolResult {
        return try {
            val screenContent = eyes.openXMLEyes()
            
            ToolResult.success(
                toolName = name,
                result = screenContent,
                data = mapOf("action" to "read_screen", "content_length" to screenContent.length)
            )
        } catch (e: Exception) {
            ToolResult.failure(
                toolName = name,
                error = "Read screen failed: ${e.message}"
            )
        }
    }
    
    /**
     * Execute screenshot
     */
    @RequiresApi(Build.VERSION_CODES.R)
    private suspend fun executeScreenshot(): ToolResult {
        return try {
            val bitmap = eyes.openEyes()
            
            if (bitmap != null) {
                // Note: The screenshot is saved by Eyes API automatically
                ToolResult.success(
                    toolName = name,
                    result = "Screenshot captured successfully. Size: ${bitmap.width}x${bitmap.height}",
                    data = mapOf(
                        "action" to "screenshot",
                        "width" to bitmap.width,
                        "height" to bitmap.height
                    )
                )
            } else {
                ToolResult.failure(
                    toolName = name,
                    error = "Screenshot capture failed"
                )
            }
        } catch (e: Exception) {
            ToolResult.failure(
                toolName = name,
                error = "Screenshot failed: ${e.message}"
            )
        }
    }
    
    /**
     * Execute get current app
     */
    private suspend fun executeGetCurrentApp(): ToolResult {
        return try {
            val currentApp = eyes.getCurrentActivityName()
            
            ToolResult.success(
                toolName = name,
                result = "Current app: $currentApp",
                data = mapOf("action" to "get_current_app", "app_name" to currentApp)
            )
        } catch (e: Exception) {
            ToolResult.failure(
                toolName = name,
                error = "Get current app failed: ${e.message}"
            )
        }
    }
}

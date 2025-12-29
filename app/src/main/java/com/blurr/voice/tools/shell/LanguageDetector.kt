package com.blurr.voice.tools.shell

/**
 * Supported shell languages
 */
enum class ShellLanguage {
    PYTHON,
    JAVASCRIPT,
    UNKNOWN
}

/**
 * Detects programming language from code content
 */
object LanguageDetector {
    
    /**
     * Detect language from code string
     * 
     * @param code The code to analyze
     * @return Detected language
     */
    fun detectLanguage(code: String): ShellLanguage {
        val trimmed = code.trim()
        
        // JavaScript indicators
        val jsPatterns = listOf(
            "const ", "let ", "var ",
            "function ", "=>",
            "console.log",
            "document.", "window.",
            "require(", "import { ",
            ".map(", ".filter(", ".reduce(",
            "d3.", "chart.", "Chart.",
            "JSON.stringify", "JSON.parse",
            "async ", "await ",
            "new Promise"
        )
        
        // Python indicators  
        val pythonPatterns = listOf(
            "import ", "from ",
            "def ", "class ",
            "print(", "input(",
            "if __name__",
            "self.", "super().",
            "pip_install(",
            "range(", "len(",
            "with ", "as ",
            "try:", "except:",
            "lambda ", "yield "
        )
        
        // Count pattern matches
        val jsScore = jsPatterns.count { trimmed.contains(it, ignoreCase = false) }
        val pyScore = pythonPatterns.count { trimmed.contains(it, ignoreCase = false) }
        
        return when {
            jsScore > pyScore -> ShellLanguage.JAVASCRIPT
            pyScore > jsScore -> ShellLanguage.PYTHON
            
            // Fallback to keyword detection
            trimmed.contains("python", ignoreCase = true) -> ShellLanguage.PYTHON
            trimmed.contains("javascript", ignoreCase = true) -> ShellLanguage.JAVASCRIPT
            trimmed.contains("node", ignoreCase = true) -> ShellLanguage.JAVASCRIPT
            
            else -> ShellLanguage.UNKNOWN
        }
    }
    
    /**
     * Explicitly get language from string name
     */
    fun fromString(language: String?): ShellLanguage {
        return when (language?.lowercase()) {
            "python", "py" -> ShellLanguage.PYTHON
            "javascript", "js", "node" -> ShellLanguage.JAVASCRIPT
            else -> ShellLanguage.UNKNOWN
        }
    }
}

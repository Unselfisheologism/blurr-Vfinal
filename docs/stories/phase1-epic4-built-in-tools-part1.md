# Epic 4: Built-in Tools - Part 1 (Web Search & Multimodal)

**Epic ID**: EPIC-4-PART1  
**Priority**: P0  
**Status**: Ready for Development  
**Estimated Duration**: 1.5 weeks  

---

## Epic Overview

Implement built-in tools for web search and multimodal generation. These tools use user-provided API keys and integrate with existing BYOK providers.

---

## Stories

### Story 4.1: Tavily Search Tool
**Story ID**: STORY-4.1  
**Priority**: P0  
**Estimate**: 1 day  
**Dependencies**: Story 3.2 (Tool interface)  

#### Description
Implement Tavily web search tool for deep research capabilities.

#### Acceptance Criteria
- [ ] TavilySearchTool implements Tool interface
- [ ] Supports basic search with query parameter
- [ ] Supports advanced search with depth parameter
- [ ] Returns search results with titles, snippets, URLs
- [ ] Handles API key from user settings
- [ ] Error handling for invalid API key or rate limits
- [ ] Results include relevance scores

#### Technical Details
**Files to Create**:
- `app/src/main/java/com/blurr/voice/tools/search/TavilySearchTool.kt`

```kotlin
class TavilySearchTool(
    private val keyManager: APIKeyManager
) : Tool {
    override val name = "tavily_search"
    override val description = "Search the web for current information using Tavily"
    override val parameters = listOf(
        ToolParameter("query", "string", "Search query", required = true),
        ToolParameter("search_depth", "string", "basic or advanced", required = false)
    )
    
    override suspend fun execute(params: Map<String, Any>, context: List<ToolResult>): ToolResult {
        val apiKey = keyManager.getTavilyKey() ?: return ToolResult.error("Tavily API key not configured")
        val query = params["query"] as? String ?: return ToolResult.error("Query required")
        val depth = params["search_depth"] as? String ?: "basic"
        
        // Call Tavily API
        val response = callTavilyAPI(apiKey, query, depth)
        return ToolResult.success(name, response)
    }
}
```

#### API Integration
```kotlin
POST https://api.tavily.com/search
{
  "api_key": "tvly-...",
  "query": "quantum computing advances 2024",
  "search_depth": "advanced",
  "max_results": 10
}
```

#### Testing
- [ ] Search with valid API key
- [ ] Handle missing API key
- [ ] Handle invalid query
- [ ] Parse search results correctly
- [ ] Handle API rate limits

---

### Story 4.2: Exa Search Tool
**Story ID**: STORY-4.2  
**Priority**: P1  
**Estimate**: 1 day  
**Dependencies**: Story 3.2  

#### Description
Implement Exa search tool for neural web search.

#### Acceptance Criteria
- [ ] ExaSearchTool implements Tool interface
- [ ] Supports semantic search
- [ ] Returns high-quality results with content snippets
- [ ] Handles user API key
- [ ] Error handling for API failures

#### Technical Details
**Files to Create**:
- `app/src/main/java/com/blurr/voice/tools/search/ExaSearchTool.kt`

#### API Integration
```kotlin
POST https://api.exa.ai/search
Authorization: Bearer ${api_key}
{
  "query": "latest AI research",
  "num_results": 10,
  "type": "neural"
}
```

#### Testing
- [ ] Neural search with valid key
- [ ] Handle missing API key
- [ ] Parse Exa-specific result format

---

### Story 4.3: SerpAPI Tool
**Story ID**: STORY-4.3  
**Priority**: P1  
**Estimate**: 1 day  
**Dependencies**: Story 3.2  

#### Description
Implement SerpAPI tool for Google search results.

#### Acceptance Criteria
- [ ] SerpAPITool implements Tool interface
- [ ] Returns Google search results
- [ ] Supports search parameters (country, language)
- [ ] Handles user API key
- [ ] Parses organic results, featured snippets

#### Technical Details
**Files to Create**:
- `app/src/main/java/com/blurr/voice/tools/search/SerpAPITool.kt`

#### API Integration
```kotlin
GET https://serpapi.com/search
?q=search+query
&api_key=${api_key}
&engine=google
```

#### Testing
- [ ] Google search with valid key
- [ ] Parse organic results
- [ ] Extract featured snippets

---

### Story 4.4: Image Generation Tool
**Story ID**: STORY-4.4  
**Priority**: P0  
**Estimate**: 2 days  
**Dependencies**: Story 3.2  

#### Description
Implement image generation tool using Flux/SD3 models via OpenRouter/AIMLAPI.

#### Acceptance Criteria
- [ ] ImageGenerationTool implements Tool interface
- [ ] Supports text-to-image generation
- [ ] Uses existing BYOK provider (OpenRouter/AIMLAPI)
- [ ] Returns image as Base64 or file path
- [ ] Supports model selection (Flux, SD3, DALL-E)
- [ ] Supports size/resolution parameters
- [ ] Downloads and saves image locally

#### Technical Details
**Files to Create**:
- `app/src/main/java/com/blurr/voice/tools/generation/ImageGenerationTool.kt`

```kotlin
class ImageGenerationTool(
    private val keyManager: APIKeyManager
) : Tool {
    override val name = "generate_image"
    override val description = "Generate images from text descriptions"
    override val parameters = listOf(
        ToolParameter("prompt", "string", "Image description", required = true),
        ToolParameter("model", "string", "flux-1.1-pro, stable-diffusion-3, dall-e-3", required = false),
        ToolParameter("size", "string", "1024x1024, 1024x1792, etc.", required = false)
    )
    
    override suspend fun execute(params: Map<String, Any>, context: List<ToolResult>): ToolResult {
        val provider = keyManager.getSelectedProvider()
        val model = params["model"] as? String ?: "flux-1.1-pro"
        
        // Use existing image generation API
        val imageUrl = generateImage(provider, model, params)
        val localPath = downloadImage(imageUrl)
        
        return ToolResult.success(name, mapOf(
            "image_path" to localPath,
            "url" to imageUrl
        ))
    }
}
```

#### Integration
Uses existing OpenRouter/AIMLAPI image generation endpoints

#### Testing
- [ ] Generate image with Flux
- [ ] Generate image with SD3
- [ ] Download and save image
- [ ] Handle generation errors
- [ ] Display image in chat

---

### Story 4.5: Video Generation Tool

**Goal**: Generate videos using available video generation models from the configured provider

**Acceptance Criteria**:
- [ ] Support text-to-video generation
- [ ] Support image-to-video generation
- [ ] Support video style customization
- [ ] Check provider support for video models
- [ ] Handle providers without video support gracefully
- [ ] Return video URL or file path

#### Parameters
- `prompt`: Video description
- `duration`: Video length in seconds
- `style`: Video style (realistic, animated, etc.)
- `aspect_ratio`: Video aspect ratio
- `image_input`: Optional starting image

#### Provider Support
- **OpenRouter**: No video models
- **AIMLAPI**: Runway, Luma, Kling models
- **Others**: Very limited support

---

### Story 4.6: Audio Generation Tool (Text-to-Speech)

**Goal**: Generate audio/speech using TTS models from the configured provider

**Acceptance Criteria**:
- [ ] Support text-to-speech generation
- [ ] Check provider support for TTS/audio models
- [ ] Support voice selection (different voices)
- [ ] Support multiple providers (OpenRouter, AIMLAPI, Groq)
- [ ] Handle speed, pitch controls
- [ ] Return audio file URL or path

#### Parameters
- `text`: Text to convert to speech
- `voice`: Voice selection (e.g., alloy, echo, fable, onyx, nova, shimmer)
- `speed`: Speech speed (0.25 to 4.0)
- `language`: Optional language code

#### Provider Support
- **OpenRouter**: OpenAI TTS models
- **AIMLAPI**: ElevenLabs, OpenAI, Azure TTS models
- **Groq**: Limited TTS support

---

### Story 4.7: Music Generation Tool

**Goal**: Generate music using available music generation models from the configured provider

**Acceptance Criteria**:
- [ ] Support text-to-music generation
- [ ] Check provider support for music models
- [ ] Support genre and style selection
- [ ] Support duration control
- [ ] Handle providers without music models gracefully
- [ ] Return audio file URL or path

#### Parameters
- `prompt`: Music description
- `genre`: Music genre
- `mood`: Mood/emotion
- `duration`: Music length in seconds
- `instrumental`: Whether to include vocals

#### Provider Support
- **AIMLAPI**: Suno, Udio models
- **Others**: Very limited support

---

### Story 4.8: 3D Model Generation Tool

**Goal**: Generate 3D models using available 3D generation APIs

**Acceptance Criteria**:
- [ ] Support text-to-3D generation
- [ ] Support image-to-3D generation
- [ ] Check provider support for 3D models
- [ ] Handle providers without 3D support (most don't have it)
- [ ] Return 3D model file (GLB, OBJ, etc.)

#### Parameters
- `prompt`: 3D model description
- `image_input`: Optional reference image
- `format`: Output format (glb, obj, fbx)
- `quality`: Model quality/detail level

#### Provider Support
- **OpenRouter**: No 3D models
- **AIMLAPI**: May have Meshy or similar 3D APIs
- **Others**: Very limited support

---

### Story 4.9: API Key Management UI
**Story ID**: STORY-4.7  
**Priority**: P0  
**Estimate**: 1 day  
**Dependencies**: None  

#### Description
Add UI for users to configure API keys for search and generation tools.

#### Acceptance Criteria
- [ ] Settings screen section for tool API keys
- [ ] Can add/edit Tavily, Exa, SerpAPI keys
- [ ] Keys stored securely (EncryptedSharedPreferences)
- [ ] Can test API key validity
- [ ] Shows which tools are available based on configured keys

#### Technical Details
**Files to Modify**:
- `app/src/main/java/com/blurr/voice/SettingsActivity.kt`
- `app/src/main/java/com/blurr/voice/data/APIKeyManager.kt`

#### Testing
- [ ] Add API keys in settings
- [ ] Keys persist across app restarts
- [ ] Test key validation
- [ ] Tools appear/disappear based on keys

---

## Epic Acceptance Criteria

✅ **Search Tools**:
- [ ] At least one search tool (Tavily) fully functional
- [ ] Search results displayed clearly in chat
- [ ] Agent can use search for research tasks

✅ **Multimodal Generation**:
- [ ] Image generation works with at least one model
- [ ] Generated images displayed in chat
- [ ] Video/music generation basics working

✅ **API Key Management**:
- [ ] Users can configure tool API keys
- [ ] Keys stored securely
- [ ] Clear error messages for missing keys

---

**Total Estimate**: 11 developer-days (~2 weeks with buffer)

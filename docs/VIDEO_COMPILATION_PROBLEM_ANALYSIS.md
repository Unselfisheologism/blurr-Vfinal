# Video Compilation & Asset Orchestration Problem

**Date**: December 2024  
**Issue**: How does the AI agent compile multiple media assets into a final video?

---

## The Problem

### Example Scenario:
```
User: "Create a music video about smartphone award 2025 winner"

Agent generates:
1. 🖼️ Product images (5 images)
2. 🎵 Background music (30 seconds)
3. 🎙️ Voiceover narration (20 seconds)
4. 📊 Infographic (1 image with stats)
5. 🎬 Video clips (3 short videos)

BUT: How to compile into ONE video file?
```

### The Gap:
- ✅ Can generate individual assets
- ✅ Can save to local storage
- ❌ **Cannot compile/edit/synchronize**
- ❌ **Cannot add assets to video timeline**
- ❌ **Cannot overlay audio tracks**
- ❌ **Cannot add transitions/effects**

### Similar Problems:
- Combining multiple PDFs into one
- Creating video slideshows from images
- Overlaying text on videos
- Merging audio tracks
- Image editing (crop, resize, filter)
- Document merging
- Data processing/transformation

---

## Root Cause

**The AI generates "ingredients" but can't "cook the meal"**

Current capabilities:
- Generate individual assets ✅
- Store files ✅
- Pass file paths between tools ✅

Missing capabilities:
- Video editing/compilation ❌
- Audio mixing ❌
- Image composition ❌
- Timeline management ❌
- Asset synchronization ❌

---

## Proposed Solutions

### Solution 1: Video Editing Tool (FFmpeg Integration) ⭐ RECOMMENDED

**Implement a new tool**: `VideoEditorTool`

**Capabilities**:
- Compile images into video slideshow
- Overlay audio tracks (music + voiceover)
- Add transitions between clips
- Combine multiple video clips
- Add text overlays
- Adjust timing/duration

**Technical Approach**:
```kotlin
class VideoEditorTool : BaseTool() {
    override val name = "video_editor"
    
    override val description = 
        "Compile and edit videos from multiple assets. Can create slideshows from images, " +
        "overlay audio tracks, combine video clips, add transitions, and sync timing."
    
    override val parameters = listOf(
        ToolParameter("project", "object", "Video project definition", required = true),
        ToolParameter("output_format", "string", "mp4, mov, avi", required = false)
    )
    
    // Uses FFmpeg library for Android
    override suspend fun execute(params: Map<String, Any>): ToolResult {
        val project = params["project"] as VideoProject
        
        // 1. Create timeline
        val timeline = buildTimeline(project)
        
        // 2. Compile using FFmpeg
        val outputPath = compileVideo(timeline)
        
        return ToolResult.success(name, outputPath)
    }
}

data class VideoProject(
    val scenes: List<Scene>,
    val audioTracks: List<AudioTrack>,
    val transitions: List<Transition>
)

data class Scene(
    val type: String, // "image", "video", "text"
    val source: String, // file path
    val duration: Double, // seconds
    val startTime: Double
)

data class AudioTrack(
    val source: String, // file path
    val startTime: Double,
    val volume: Double
)
```

**FFmpeg for Android**:
- Library: `mobile-ffmpeg` or `ffmpeg-kit-android`
- Can do everything: video editing, audio mixing, format conversion
- Open source, well-maintained
- Used by professional video apps

**Example Usage**:
```json
{
  "tool": "video_editor",
  "parameters": {
    "project": {
      "scenes": [
        {
          "type": "image",
          "source": "/path/to/phone_image_1.png",
          "duration": 3.0,
          "startTime": 0.0
        },
        {
          "type": "image",
          "source": "/path/to/infographic.png",
          "duration": 4.0,
          "startTime": 3.0
        },
        {
          "type": "video",
          "source": "/path/to/product_video.mp4",
          "duration": 10.0,
          "startTime": 7.0
        }
      ],
      "audioTracks": [
        {
          "source": "/path/to/music.mp3",
          "startTime": 0.0,
          "volume": 0.7
        },
        {
          "source": "/path/to/voiceover.mp3",
          "startTime": 2.0,
          "volume": 1.0
        }
      ]
    }
  }
}
```

**Pros**:
- ✅ Full video editing capabilities
- ✅ Industry-standard (FFmpeg)
- ✅ Works offline
- ✅ No API costs
- ✅ Fast processing
- ✅ Supports all formats

**Cons**:
- ⚠️ FFmpeg library is large (~40MB)
- ⚠️ Complex API to learn
- ⚠️ Processing can be CPU-intensive

---

### Solution 2: Cloud Video Editing API

**Use external API** like:
- Shotstack API
- Bannerbear Video API
- Creatomate API

**Example with Shotstack**:
```kotlin
class VideoEditorTool : BaseTool() {
    suspend fun compileVideo(project: VideoProject): String {
        val shotstackClient = ShotstackClient(apiKey)
        
        val timeline = Timeline(
            tracks = listOf(
                Track(clips = imageClips),
                Track(clips = videoClips),
                Track(clips = audioClips)
            )
        )
        
        val renderResponse = shotstackClient.render(timeline)
        val videoUrl = pollForCompletion(renderResponse.id)
        
        return downloadVideo(videoUrl)
    }
}
```

**Pros**:
- ✅ No local processing
- ✅ Professional quality
- ✅ Easy API
- ✅ No library size issues

**Cons**:
- ❌ Requires API key (another service)
- ❌ Cost per render
- ❌ Requires internet
- ❌ Slower (upload + process + download)

---

### Solution 3: Hybrid Approach - Agent Instructions with MediaStore

**Let Android MediaStore handle basic compilation**:

```kotlin
class VideoCompilerTool : BaseTool() {
    // Uses Android's MediaMuxer and MediaCodec
    
    suspend fun createSlideshow(images: List<String>, music: String): String {
        val mediaMuxer = MediaMuxer(outputPath, OutputFormat.MUXER_OUTPUT_MPEG_4)
        
        // 1. Encode images as video frames
        images.forEach { imagePath ->
            addImageAsVideoFrame(mediaMuxer, imagePath, frameDuration = 3000)
        }
        
        // 2. Add audio track
        addAudioTrack(mediaMuxer, music)
        
        mediaMuxer.stop()
        mediaMuxer.release()
        
        return outputPath
    }
}
```

**Pros**:
- ✅ Uses native Android APIs
- ✅ No external dependencies
- ✅ No additional costs

**Cons**:
- ⚠️ Limited capabilities (basic only)
- ⚠️ Complex code to write
- ⚠️ May not support advanced features

---

### Solution 4: Multi-Tool Orchestration (No New Tool)

**Agent learns to use existing video generation tools creatively**:

```
User: "Create music video about smartphone winner"

Agent thinks:
1. Generate base video with prompt including all elements
2. Use video_generation with detailed prompt:
   "Music video showcasing Nothing Phone 3, award winner 2025,
    with product shots, specs overlay, celebration music,
    professional narration, 30 seconds"
   
Problem: Single generation may not allow fine control
```

**Pros**:
- ✅ No new code needed
- ✅ Uses existing tools

**Cons**:
- ❌ Limited control over composition
- ❌ May not meet exact requirements
- ❌ Unpredictable results

---

## Recommendation: Solution 1 (FFmpeg) + Solution 2 (Cloud API) Hybrid

### Implement BOTH tools:

#### **Tool 1: VideoEditorTool (FFmpeg-based)**
**For**: Basic compilation, slideshows, audio overlay
**Use when**: User wants quick, offline results
**Dependencies**: FFmpeg Android library

#### **Tool 2: VideoStudioTool (Cloud API-based)**
**For**: Advanced editing, professional quality
**Use when**: User wants complex effects, transitions
**Dependencies**: Shotstack or similar API

### Agent Decision Logic:
```
if (simpleCompilation && offlinePreferred):
    use video_editor (FFmpeg)
else if (complexEffects || professionalQuality):
    use video_studio (Cloud API)
```

---

## Broader Solution: Generic "Asset Processor" Tool

**Extend this concept to ALL asset types**:

```kotlin
class AssetProcessorTool : BaseTool() {
    override val name = "asset_processor"
    
    override val description = 
        "Process, combine, and transform media assets. Supports video editing, " +
        "audio mixing, image manipulation, PDF merging, and more."
    
    override val parameters = listOf(
        ToolParameter("operation", "string", "Type of processing", required = true,
            enum = listOf(
                "video_compile",
                "audio_mix", 
                "image_compose",
                "pdf_merge",
                "document_convert"
            )
        ),
        ToolParameter("inputs", "array", "Input files", required = true),
        ToolParameter("config", "object", "Operation-specific config", required = true)
    )
}
```

**Supported Operations**:

1. **video_compile**: Images/videos → Final video
2. **audio_mix**: Multiple audio → Single track
3. **image_compose**: Multiple images → Collage/composite
4. **pdf_merge**: Multiple PDFs → Single PDF
5. **document_convert**: Doc/PDF/Text transformations
6. **image_edit**: Crop, resize, filter, text overlay
7. **subtitle_add**: Video + text → Video with subtitles

---

## Implementation Plan

### Phase 1: FFmpeg Video Editor (Story 4.18)
**Time**: 2-3 days

**Files to create**:
```
VideoEditorTool.kt (~400 lines)
VideoProject.kt (data classes ~100 lines)
FFmpegWrapper.kt (FFmpeg integration ~200 lines)
```

**Dependencies**:
```gradle
implementation 'com.arthenica:ffmpeg-kit-full:5.1'
```

**Capabilities**:
- Create slideshow from images
- Overlay audio (music + voiceover)
- Combine video clips
- Add transitions (fade, wipe)
- Text overlays
- Trim/crop videos

### Phase 2: Audio Mixer (Story 4.19)
**Time**: 1 day

Mix multiple audio tracks with volume control.

### Phase 3: Image Composer (Story 4.20)
**Time**: 1 day

Create collages, composites, overlays.

### Phase 4: Cloud Video Studio (Optional)
**Time**: 2 days

Professional video editing via cloud API.

---

## Example: Complete Workflow

```
User: "Create music video about Nothing Phone 3 winning 2025 award"

Agent execution:

Step 1: Research
tool: web_search
query: "Nothing Phone 3 smartphone award 2025"
result: Winner details, features, reviews

Step 2: Generate Assets
tool: generate_image
prompt: "Nothing Phone 3 product photo, award winner"
→ image1.png

tool: generate_image
prompt: "Infographic: Nothing Phone 3 specs, price, features"
→ infographic.png

tool: generate_music
prompt: "Uplifting electronic music, celebration"
duration: 30
→ music.mp3

tool: generate_audio
text: "Nothing Phone 3, winner of smartphone award 2025"
voice: "onyx"
→ voiceover.mp3

Step 3: Compile Video ⭐ NEW
tool: video_editor
project:
  scenes:
    - { type: "image", source: "image1.png", duration: 3, startTime: 0 }
    - { type: "image", source: "infographic.png", duration: 4, startTime: 3 }
    - { type: "text", content: "Winner 2025", duration: 2, startTime: 7 }
  audioTracks:
    - { source: "music.mp3", startTime: 0, volume: 0.6 }
    - { source: "voiceover.mp3", startTime: 1, volume: 1.0 }
  transitions:
    - { type: "fade", between: [0, 1], duration: 0.5 }

→ final_video.mp4

Result: Complete 30-second music video!
```

---

## Technical Details: FFmpeg Commands

### Create slideshow from images:
```bash
ffmpeg -loop 1 -t 3 -i image1.png \
       -loop 1 -t 4 -i image2.png \
       -filter_complex "[0:v][1:v]concat=n=2:v=1[v]" \
       -map "[v]" output.mp4
```

### Add audio to video:
```bash
ffmpeg -i video.mp4 -i audio.mp3 \
       -c:v copy -map 0:v:0 -map 1:a:0 \
       output.mp4
```

### Mix multiple audio tracks:
```bash
ffmpeg -i music.mp3 -i voiceover.mp3 \
       -filter_complex "[0:a]volume=0.6[a1];[1:a]volume=1.0[a2];[a1][a2]amix=inputs=2[a]" \
       -map "[a]" output.mp3
```

### Combine with Kotlin:
```kotlin
class FFmpegWrapper {
    fun createSlideshow(
        images: List<String>,
        audioTracks: List<AudioTrack>,
        output: String
    ): Boolean {
        val cmd = buildFFmpegCommand(images, audioTracks, output)
        val session = FFmpegKit.execute(cmd)
        return session.returnCode.isValueSuccess
    }
}
```

---

## Conclusion

**The Problem**: AI generates individual assets but can't compile them

**The Solution**: Add video/audio/image processing tools

**Recommended Approach**:
1. ✅ Implement `VideoEditorTool` using FFmpeg (Story 4.18)
2. ✅ Add to Phase 1 (becomes Story 4.18 in Epic 4 Part 2)
3. ✅ Implement basic operations first (slideshow, audio overlay)
4. ✅ Extend to advanced features later

**Priority**: HIGH - This is essential for complete creative workflows

**Next Steps**:
1. Add Story 4.18 to remaining stories
2. Implement VideoEditorTool with FFmpeg
3. Test with smartphone award example
4. Extend to other asset types

---

**Would you like me to**:
1. Add Story 4.18 (Video Editor Tool) to the remaining stories?
2. Implement it right after Phone Control Tool?
3. Or implement it first since it's critical for the music video example?

# Epic 7 — AI-Native Video Editor (CapCut-like) — Implementation Summary

This document summarizes the **Epic 7: AI-Native Video Editor** implementation added to the embedded Flutter module (`flutter_workflow_editor`) and the Kotlin-native Android host (`app`).

The editor is **heavily inspired by TryKimu’s UX concepts** (multi-track timeline + ruler, media bin, preview + playback controls, top actions, AI toolbar, export), but is implemented natively in Flutter and integrates with the existing Twent agent/tooling on Android.

---

## 1) What was delivered

### Core UX (TryKimu-inspired flow)
- **Dedicated VideoEditor screen** with:
  - **Media Bin** (left-side Drawer) → import clips from device and add to timeline.
  - **Central Preview** (video/image preview + scrubbing slider + play/pause).
  - **Bottom multi-track Timeline** with:
    - Ruler/time ticks
    - Playhead
    - Tracks as rows
    - Clips as draggable blocks
    - Trim handles (start/end)
    - Pinch-to-zoom timeline scale
  - **Top actions**: Undo/Redo, Import, Add Track, Delete clip, Export.
  - **AI toolbar**: Generate Clip, Auto Captions, Smart Transitions, Enhance.

### Data model + state management
- New models for:
  - Media assets (bin)
  - Tracks
  - Clips
  - Transitions
  - Project (timeline + selection + playhead)
- ChangeNotifier-based **VideoEditorState** with:
  - Undo/Redo history
  - Track limit gating (free vs pro)
  - Selected clip
  - Playhead
  - Import media
  - Export orchestration

### AI + export integration
- New **MethodChannel** bridge: `com.twent.video_editor/bridge`
  - AI features call the **UltraGeneralistAgent** (via `AgentFactory.getAgent(context)`)
  - Export uses **FFmpegKit** (already present in app dependencies) for an MVP renderer.

### Kotlin host integration
- New host `VideoEditorActivity` (Flutter add-to-app) and manifest entry.
- New `VideoEditorLauncher.kt` to launch Video Editor from anywhere.
- Home screen now has a **Video Editor button** (`video_editor_link`) wired to `VideoEditorLauncher.launch(this)`.

---

## 2) Flutter module changes

### Routing / app integration
**File:** `flutter_workflow_editor/lib/main.dart`
- Registers:
  - `ChangeNotifierProvider(create: (_) => VideoEditorState())`
  - Route `'/video_editor' → VideoEditorScreen`

### Video Editor screen
**File:** `flutter_workflow_editor/lib/video_editor/video_editor_screen.dart`
- Layout:
  - Drawer: `MediaBinDrawer`
  - Body: `VideoPreviewPanel` + `VideoAIToolbar` + `TimelineView`
- Actions:
  - Undo/Redo
  - Import media
  - Add track (bottom sheet)
  - Delete selected clip
  - Export (modal progress + share result)
- Error handling:
  - State errors are displayed via SnackBar

### State management
**File:** `flutter_workflow_editor/lib/video_editor/state/video_editor_state.dart`
Key responsibilities:
- **Project lifecycle**: `initialize()` creates a new blank project (2 default tracks).
- **Pro gating**:
  - `maxTracks = isPro ? 999 : 2`
  - AI actions require Pro
- **Import**: `importMediaFromDevice()` uses `file_picker` (custom extensions) and tries best-effort duration probing (via `video_player` for video).
- **Timeline ops**:
  - Add asset → timeline at playhead
  - Select clip
  - Move clip (drag)
  - Trim start/end
  - Delete clip
- **Undo/Redo** using an internal project history list.
- **Export**: calls `VideoExportService`, stores `lastExportPath` for sharing.

### Timeline widgets
- `flutter_workflow_editor/lib/video_editor/widgets/timeline/timeline_view.dart`
  - Horizontal scroll
  - Pinch zoom (`pixelsPerSecond`)
  - Playhead drag
  - Tap-to-seek
- `timeline_ruler.dart`
  - Draws major/minor ticks and time labels
- `timeline_track_row.dart`
  - Renders track label + clip stack
  - Shows transition markers (visual)
- `timeline_clip_widget.dart`
  - Draggable clips
  - Start/end trim handles

### Preview widget
**File:** `flutter_workflow_editor/lib/video_editor/widgets/preview/video_preview_panel.dart`
- Preview selected clip:
  - Video: `video_player`
  - Image: `Image.file`
- Playback:
  - Play/pause
  - Slider scrub (relative to clip)
  - Seeks into the source using `trimStartMs + relativePlayhead`

### Media bin
**File:** `flutter_workflow_editor/lib/video_editor/widgets/media_bin_drawer.dart`
- Shows imported assets and quick-add to timeline.

### AI wiring
- `flutter_workflow_editor/lib/video_editor/widgets/video_ai_toolbar.dart`
  - Provides AI actions and Pro gating messaging.
- `flutter_workflow_editor/lib/video_editor/services/video_ai_service.dart`
  - Calls into the Kotlin bridge and normalizes returned values.
- `flutter_workflow_editor/lib/video_editor/services/video_editor_bridge.dart`
  - MethodChannel wrapper for:
    - `checkProStatus`
    - `generateCaptions`
    - `suggestTransitions`
    - `generateClipFromPrompt`
    - `enhanceVideo`
    - `exportTimeline`
- `flutter_workflow_editor/lib/video_editor/services/video_export_service.dart`
  - Orchestrates export and returns a result object.

### Models
- `flutter_workflow_editor/lib/video_editor/models/media_asset.dart`
- `flutter_workflow_editor/lib/video_editor/models/video_clip.dart`
- `flutter_workflow_editor/lib/video_editor/models/video_track.dart`
- `flutter_workflow_editor/lib/video_editor/models/video_transition.dart`
- `flutter_workflow_editor/lib/video_editor/models/video_project.dart`

### Dependencies added
**File:** `flutter_workflow_editor/pubspec.yaml`
- Added:
  - `video_player: ^2.8.6`

---

## 3) Android host (Kotlin) changes

### Entry point + launcher
**File:** `app/src/main/java/com/twent/voice/apps/video/VideoEditorLauncher.kt`
- `VideoEditorLauncher.launch(context)` starts `VideoEditorActivity`.

### Host activity
**File:** `app/src/main/kotlin/com/twent/voice/VideoEditorActivity.kt`
- Uses cached engine: `video_editor_engine`
- Sets initial route `/video_editor` and also `pushRoute(ROUTE)` when reusing engine.
- Attaches Flutter via `FlutterFragment.withCachedEngine(...)`.

### Layout
**File:** `app/src/main/res/layout/activity_video_editor.xml`
- Simple `FrameLayout` with id `flutter_container`.

### Manifest registration
**File:** `app/src/main/AndroidManifest.xml`
- Added `VideoEditorActivity` entry with consistent Flutter config flags.

### Home screen launch button
**Files:**
- `app/src/main/res/layout/activity_main_content.xml`
  - Added `TextView` button: `@+id/video_editor_link` labeled “🎬 Video Editor”.
- `app/src/main/java/com/twent/voice/MainActivity.kt`
  - Adds click listener for `video_editor_link` → `launchVideoEditor()`.
  - `launchVideoEditor()` uses `VideoEditorLauncher.launch(this)`.

---

## 4) MethodChannel contract (Flutter ↔ Kotlin)

Channel:
- `com.twent.video_editor/bridge`

Methods implemented on Kotlin side:
- `checkProStatus` → `{ isPro: Boolean }`
- `getMediaDurationMs(uri)` → `{ durationMs: number? }` (native metadata probing for audio/video)
- `executeAgentTask(prompt)` → `{ success: Boolean, result: String?, error: String? }`
- `generateClipFromPrompt(prompt)` → proxied to agent prompt; expects URL/path in `result`.
- `generateCaptions(clipUri, language)` → returns `{ success, srt }`
- `suggestTransitions(projectJson)` → returns `{ success, transitions }` (often JSON string from agent)
- `enhanceVideo(clipUri, intent)` → returns `{ success, result }`
- `exportTimeline(timelineJson, outputFileName)` → returns `{ success, filePath, captionsFilePath? }`

Pro gating implementation:
- Uses `FreemiumManager().isUserSubscribed()`.

---

## 5) Export implementation (current MVP)

**File:** `app/src/main/kotlin/com/twent/voice/flutter/VideoEditorBridge.kt`

Export details:
- Uses `FFmpegKit` to render timeline to MP4.
- Current behavior (incremental NLE export):
  - Respects `startMs` by inserting **black gaps** where needed.
  - Supports clips of `type == "video"` and `type == "image"` on video tracks.
  - Applies `trimStartMs` and `durationMs`.
  - Applies **simple transitions** (fade-out + fade-in) based on `project.transitions`.
  - Supports **picture-in-picture overlays** from additional video tracks (bottom-right stacking).
  - Mixes **audio clips** from audio tracks with timeline alignment (via `adelay` + `amix`).
  - Exports captions as a **sidecar .srt**, with optional **burn-in**.
  - Produces 1280×720, 30fps, H.264 MP4.
  - **Network URLs are not supported** for export yet (local device paths only).

Output location:
- App external files dir: `context.getExternalFilesDir(null)`.

---

## 6) Remaining limitations / next steps

Epic 7 now has a usable end-to-end editor (timeline → preview → AI → export). Remaining work is mostly about **accuracy and polish**:

1. **True NLE composition (preview + export parity)**
   - Export supports basic PiP overlays and audio mixing; the **live preview** is still single-clip oriented.
   - Next step: real-time composition preview (multi-track) and per-clip transforms (position/scale/rotation).

2. **Transitions (true crossfades)**
   - Export applies transitions as fade-out/fade-in. Next step: real **crossfade** (xfade) + transition parameter UI.

3. **Project persistence (multi-project UX)**
   - Current implementation auto-saves and auto-restores the last project.
   - Next step: multi-project list, rename, duplicate, delete, and per-project export presets.

4. **Media import robustness**
   - Native duration probing is implemented via `MediaMetadataRetriever`.
   - Next step: richer metadata (fps, resolution), thumbnail extraction, and SAF/URI support.

5. **Performance**
   - Tracks are virtualized with `ListView.builder` and track rows are wrapped in `RepaintBoundary`.
   - Next step: timeline thumbnails caching, gesture arena refinements, and reducing rebuilds with selectors.

---

## 7) How to launch the Video Editor

### From the app home screen
- Tap the **🎬 Video Editor** button.

### From Kotlin anywhere else
```kotlin
import com.twent.voice.apps.video.VideoEditorLauncher

VideoEditorLauncher.launch(context)
```

---

## 8) File inventory (added/modified)

### Flutter (new)
- `lib/video_editor/video_editor_screen.dart`
- `lib/video_editor/state/video_editor_state.dart`
- `lib/video_editor/models/*`
- `lib/video_editor/services/*`
- `lib/video_editor/widgets/*`

### Flutter (modified)
- `lib/main.dart`
- `pubspec.yaml`

### Android (new)
- `app/src/main/kotlin/com/twent/voice/VideoEditorActivity.kt`
- `app/src/main/kotlin/com/twent/voice/flutter/VideoEditorBridge.kt`
- `app/src/main/java/com/twent/voice/apps/video/VideoEditorLauncher.kt`
- `app/src/main/res/layout/activity_video_editor.xml`

### Android (modified)
- `app/src/main/AndroidManifest.xml`
- `app/src/main/java/com/twent/voice/MainActivity.kt`
- `app/src/main/res/layout/activity_main_content.xml`

---

## 9) Safety / production notes
- The editor is wired behind clear Pro gating checks.
- All native calls return structured maps and error messages.
- Export uses FFmpegKit already included in the Android app.

If any CI checks fail, they are most likely to be:
- Missing imports / unused imports
- Gradle / Kotlin compilation issues
- Flutter analyzer issues

Fixing those should be straightforward within the files listed above.

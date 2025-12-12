# Story Order Update - Audio Generation Added

**Date**: December 2024  
**Change**: Added Story 4.6 (Audio Generation) between Video and Music Generation

---

## New Story Order

### Epic 4 Part 1: Web Search & Multimodal Tools

| Story | Name | Status |
|-------|------|--------|
| 4.1 | Web Search & Deep Research (Perplexity Sonar) | ✅ COMPLETE |
| 4.2 | (Consolidated into 4.1) | ✅ COMPLETE |
| 4.3 | (Consolidated into 4.1) | ✅ COMPLETE |
| 4.4 | Image Generation Tool | ⏳ Next |
| 4.5 | Video Generation Tool | ⏳ Planned |
| **4.6** | **Audio Generation Tool (TTS)** | ⏳ **NEW** |
| 4.7 | Music Generation Tool | ⏳ Planned |
| 4.8 | 3D Model Generation Tool | ⏳ Planned |
| 4.9 | API Key Management UI | ⏳ Planned |

---

## Old vs New Numbering

| Old Story | → | New Story |
|-----------|---|-----------|
| 4.6: Music Generation | → | **4.7: Music Generation** |
| 4.7: API Key Management UI | → | **4.9: API Key Management UI** |
| _(New)_ | → | **4.6: Audio Generation (TTS)** |
| _(New)_ | → | **4.8: 3D Model Generation** |

---

## Rationale

### Why Add Audio Generation (Story 4.6)?

1. **Workflow Completeness**: Audio/TTS is needed before music generation
   - TTS = speech from text (voiceovers, narration)
   - Music = instrumental/vocal music generation
   - Different use cases, different models

2. **Provider Support**: Audio/TTS models widely available
   - OpenRouter: OpenAI TTS models
   - AIMLAPI: ElevenLabs, OpenAI, Azure TTS models
   - Groq: Some TTS support
   - All providers support this better than music/video

3. **User Value**: High-demand feature
   - Voiceovers for videos
   - Audio narration
   - Accessibility features
   - Podcasts, audiobooks

4. **Logical Flow**:
   ```
   Image (4.4) → Video (4.5) → Audio/TTS (4.6) → Music (4.7) → 3D (4.8)
   ```

### Why Add 3D Generation (Story 4.8)?

Completes the full multimodal suite mentioned in WHATIWANT.md:
- Images ✓
- Videos ✓
- Audio ✓
- Music ✓
- 3D models ✓

---

## Implementation Order

### Recommended Sequence:

1. **Story 4.4: Image Generation** (Highest Priority)
   - Most providers support
   - High user value
   - Foundation for image-to-video

2. **Story 4.5: Video Generation**
   - Depends on image generation
   - Medium provider support
   - High user value

3. **Story 4.6: Audio Generation (TTS)**
   - Wide provider support
   - Essential for complete workflows
   - High user value

4. **Story 4.7: Music Generation**
   - Limited provider support
   - Specialized use case
   - Medium user value

5. **Story 4.8: 3D Model Generation**
   - Very limited provider support
   - Advanced feature
   - Lower priority

6. **Story 4.9: API Key Management UI**
   - Essential for configuration
   - Needed for testing all tools

---

## Provider Support Matrix

| Provider | Images | Video | Audio/TTS | Music | 3D |
|----------|--------|-------|-----------|-------|-----|
| **OpenRouter** | ✅ Many | ❌ None | ✅ OpenAI TTS | ⚠️ Limited | ❌ None |
| **AIMLAPI** | ✅ Many | ✅ Some | ✅ Many (ElevenLabs) | ✅ Suno/Udio | ⚠️ Meshy |
| **Groq** | ⚠️ Limited | ❌ None | ⚠️ Limited | ❌ None | ❌ None |
| **Together AI** | ✅ Some | ⚠️ Limited | ⚠️ Some | ❌ None | ❌ None |
| **Fireworks** | ✅ Some | ❌ None | ⚠️ Some | ❌ None | ❌ None |

**Legend**:
- ✅ Good support (multiple models)
- ⚠️ Limited support (few models)
- ❌ No support

**Recommendation**: Use **AIMLAPI** for best multimodal support!

---

## Updated Phase 1 Story Count

### Before:
- Total: 22 stories
- Completed: 8 stories (36%)

### After:
- Total: **24 stories** (+2 new stories)
- Completed: 8 stories (33%)

### Epic 4 Part 1:
- Before: 7 stories
- After: **9 stories** (added Audio + 3D)
- Completed: 3 stories (33%)

---

## Documentation Updates Needed

Files to update with new story numbers:

- [x] `docs/stories/phase1-epic4-built-in-tools-part1.md`
- [ ] `docs/PHASE_1_IMPLEMENTATION_TRACKER.md`
- [ ] `docs/PHASE_1_STORY_4.1_COMPLETE.md`
- [ ] `docs/STORY_4.1_WEB_SEARCH_COMPLETE.md`
- [ ] `docs/STORY_4.1_SUMMARY.md`
- [ ] All other Phase 1 documentation

---

**Status**: Story order updated and documented  
**Next**: Implement media generation tools (4.4 → 4.8)

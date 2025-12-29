---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
inputDocuments:
  - docs/index.md
  - docs/project-overview.md
  - docs/source-tree-analysis.md
  - docs/development-guide.md
  - WHATIWANT.md
documentCounts:
  briefs: 0
  research: 0
  brainstorming: 0
  projectDocs: 5
workflowType: 'prd'
lastStep: 11
project_name: 'Blurr Mobile AI Super-Assistant'
user_name: 'James Abraham'
date: '2025-12-10'
---

# Product Requirements Document - Blurr Mobile AI Super-Assistant

**Author:** James Abraham  
**Date:** 2025-12-10

---

## Executive Summary

Blurr Mobile AI Super-Assistant transforms the open-source Blurr Android app into a comprehensive "Mobile AI Operating System" — a bring-your-own-key (BYOK) platform that enables AI-powered phone automation, multi-modal content generation, workflow automation, and a suite of AI-native productivity applications.

**The Problem:**
Current AI assistants are either (1) locked to specific providers with per-call costs, (2) limited to chat-only interfaces, or (3) siloed into single-purpose apps. Users lack a unified, cost-controlled way to leverage AI across all their mobile productivity needs.

**The Solution:**
A user-owned-key mobile platform where users bring their own AI API keys (OpenRouter, AIMLAPI.com, Groq, etc.) and gain access to:
- An ultra-generalist AI agent that can control the phone, generate media, create documents, conduct research, and execute workflows
- A suite of 6 AI-native apps (Text Editor, Spreadsheets, DAW, Video Editor, Media Generator, Learning Platform)
- A visual workflow builder with scheduling and n8n integration
- Existing Blurr capabilities (home button activation, UI automation) — fully preserved

### What Makes This Special

1. **True User Ownership** — BYOK model means zero per-call costs from the developer
2. **AI OS, Not Just a Chatbot** — Replaces multiple apps with AI-native equivalents
3. **Phone Automation** — AI that can actually control your device (unique in market)
4. **Provider Agnostic** — Works with any OpenRouter/AIMLAPI.com-compatible provider
5. **Mobile-First Workflow Automation** — n8n-style builder in your pocket

## Project Classification

| Classification | Value |
|----------------|-------|
| **Technical Type** | Android Mobile Application (Accessibility-based AI Platform) |
| **Domain** | Consumer AI / Productivity Technology |
| **Complexity** | High — 5-phase development, 6 AI-native apps, MCP client, workflow automation |
| **Project Context** | Brownfield — extending existing open-source Blurr codebase |
| **Key Constraint** | Must not break any existing Blurr functionality (UI automation, home button, etc.) |

---

## Success Criteria

### User Success

| Metric | Target | Measurement |
|--------|--------|-------------|
| **BYOK Setup** | 90%+ complete on first attempt | Onboarding completion rate |
| **Phone Control** | 95%+ task success rate | Command execution analytics |
| **AI Response Quality** | 4.5+ star ratings | In-app feedback |
| **Aha! Moment** | Multi-step automation saves 10+ minutes | User engagement metrics |

### Business Success

| Timeframe | Metric | Target |
|-----------|--------|--------|
| **Month 3** | Daily Active Users | 10,000 DAU |
| **Month 6** | Pro Conversion | 5% of free users |
| **Month 12** | Monthly Recurring Revenue | $50,000 MRR |
| **Month 12** | God Mode Subscribers | 500+ users |
| **Ongoing** | Churn Rate | <5% monthly |

### Technical Success

| Metric | Target | Rationale |
|--------|--------|-----------|
| **Appwrite Migration** | 100% Firebase replacement | Zero developer-funded compute |
| **API Latency** | P95 <3s for AI responses | User experience |
| **Crash-Free Rate** | 99.5%+ | Store rating preservation |
| **Accessibility Service** | Zero regressions | Core value preserved |
| **Provider Compatibility** | 5+ providers | User choice |

---

## Product Scope

### MVP (Phase 0 + Phase 1) — First 4-6 Weeks

**Must Have:**
- Appwrite backend (100% Firebase replacement)
- BYOK settings screen (OpenRouter, AIMLAPI.com, Groq, Fireworks, Together)
- BYOK voice (STT/TTS via OpenAI-compatible APIs)
- Model selector with balance display
- All existing Blurr features preserved
- Ultra-Generalist 1-chat-UI Agent
- MCP client support
- Basic tools: web search, phone control, document generation

### Growth Features (Phase 2 + Phase 3) — Post-MVP

**AI-Native Apps (Phase 2):**
- AI-native text editor
- AI-native spreadsheets
- AI-native DAW (Digital Audio Workstation)
- AI-native video editor
- AI-native multimodal media generator
- AI-native learning platform

**Workflow Automation (Phase 3):**
- Visual workflow builder (n8n-style)
- n8n integration (import/export)
- Scheduled execution
- Trigger system (Gmail, calendar, screen changes)

### Vision (Phase 4+) — Future

- 3-tier monetization (Free / Pro $14.99 / God Mode $29.99)
- Private MCP server hosting
- Team sharing capabilities
- White-label widgets
- Cross-device sync

---

## User Journeys

### Journey 1: Power User — Alex Chen

Alex is a 28-year-old productivity enthusiast frustrated by AI apps that can't actually control his phone. He discovers Blurr's BYOK model, sets up his OpenRouter key in minutes, and is amazed when the AI navigates Gmail, summarizes emails, and creates calendar events on command.

**The breakthrough:** Alex creates scheduled workflows that run automatically. He says: "Every morning at 8am, check my Gmail for emails from my team, summarize them, and notify me." It works. Alex becomes a God Mode subscriber and evangelist.

**Capabilities Revealed:** BYOK onboarding, multi-app navigation, workflow automation, voice commands, scheduling

---

### Journey 2: Creative Professional — Sarah Martinez

Sarah is a 34-year-old content creator juggling 6 different tools for podcasts, videos, and client work. She's skeptical but tries Blurr's AI-native apps — the DAW creates a podcast intro in 10 minutes vs 2 hours.

**The breakthrough:** Sarah consolidates her entire workflow into Blurr, cancels 4 other subscriptions ($47/month saved), and upgrades to Pro immediately.

**Capabilities Revealed:** Ultra-Generalist Agent, AI-native DAW, spreadsheets, learning platform, subscription conversion

---

### Journey 3: Casual User — Mike Thompson

Mike is a 45-year-old small business owner who's "not a tech person." His son helps him set up BYOK with AIMLAPI.com. His aha moment is simple: asking the AI to look up a phone number and call it — it works in 10 seconds.

**The breakthrough:** Mike realizes "this is what Siri should have been." He uses the free tier (10 runs/day is plenty) and tells everyone at his Rotary Club.

**Capabilities Revealed:** Simple onboarding, home button activation, basic phone automation, free tier satisfaction, word-of-mouth

---

### Journey 4: Pro Subscriber — Rachel Kim

Rachel is a 31-year-old ops manager running 8 workflows for her startup. When a workflow fails due to depleted OpenRouter credits, the error is clear and recovery is automatic after she adds credits.

**The breakthrough:** When Blurr suggests "This workflow could be 40% faster if you combine these steps," Rachel trusts it and implements. She renews annually and advocates for team adoption.

**Capabilities Revealed:** Workflow reliability, error handling, optimization suggestions, subscription retention, enterprise potential

---

### Journey Requirements Summary

| Capability Area | Journeys | Priority |
|-----------------|----------|----------|
| **BYOK Onboarding** | Alex, Mike | Phase 0 |
| **Phone Control** | Alex, Mike | Phase 0-1 |
| **Ultra-Generalist Agent** | Alex, Sarah | Phase 1 |
| **Workflow Builder** | Alex, Rachel | Phase 3 |
| **AI-Native Apps** | Sarah | Phase 2 |
| **Error Handling** | Rachel | Phase 1 |
| **Free Tier Experience** | Mike | Phase 4 |
| **Subscription Upgrade** | Sarah, Rachel | Phase 4 |

---

## Innovation & Novel Patterns

### Detected Innovation Areas

1. **BYOK (Bring Your Own Key) Model**
   - Users provide their own API keys (OpenRouter, AIMLAPI.com, Groq)
   - Zero per-call revenue for developer = no conflict of interest
   - Users control their AI spend completely
   - **Novel because:** No major mobile AI app does this

2. **Mobile AI Operating System**
   - Single platform replaces 6+ specialized apps
   - AI is the interface, not an add-on
   - **Novel because:** Existing apps are chatbots; this is a platform

3. **Phone Automation + Generative AI**
   - AI that can actually click, type, swipe, navigate
   - Combines screen understanding with action execution
   - **Novel because:** Siri/Google Assistant can't control third-party apps

4. **Mobile-First Workflow Automation**
   - n8n-style visual builder designed for phone screens
   - Schedule automation without a server
   - **Novel because:** Workflow tools are desktop/server — this is pocket-sized

5. **AI-Native Application Suite**
   - Apps designed with AI at the core (not bolted on)
   - Shared context between all AI-native apps
   - **Novel because:** Most apps add AI to existing UI — you're inverting this

6. **MCP Client on Mobile**
   - Connect to any MCP server from your phone
   - Use Cursor/Windsurf tools remotely
   - **Novel because:** MCP clients are desktop-only today

### Market Context & Competitive Landscape

| Category | Competitors | Your Differentiation |
|----------|-------------|---------------------|
| AI Assistants | ChatGPT, Claude, Gemini | They can't control your phone |
| Phone Automation | MacroDroid, Tasker | No AI intelligence |
| Workflow Tools | n8n, Zapier | Desktop/web only, not mobile-first |
| AI Productivity | Notion AI, Copilot | Bolted-on AI, not AI-native |

### Validation Approach

1. **BYOK Validation:** Onboarding completion rate (target: 90%+)
2. **Automation Validation:** Phone control task success rate (target: 95%+)
3. **Platform Validation:** Multi-app retention (users who try 3+ features)
4. **Workflow Validation:** Workflow creation rate in first 7 days

### Risk Mitigation

| Risk | Mitigation |
|------|------------|
| BYOK too complex for casual users | Guided onboarding, provider recommendations |
| Phone automation breaks across Android versions | Extensive testing Android 12-16, graceful degradation |
| AI-native apps feel half-baked | MVP focus on 2-3 apps, expand based on usage |
| n8n integration technically difficult | Start export-only, add bidirectional sync later |

---

## Android Mobile App Requirements

### Platform Requirements

| Requirement | Specification |
|-------------|---------------|
| **Platform** | Android only (no iOS in this codebase) |
| **Language** | Kotlin 1.9.22 |
| **UI Framework** | Jetpack Compose |
| **Min SDK** | 24 (Android 7.0 Nougat) |
| **Target SDK** | 35 (Android 15) |
| **Architecture** | MVVM with Repository pattern |

### Device Permissions

| Permission | Purpose | Required For |
|------------|---------|--------------|
| `ACCESSIBILITY_SERVICE` | Screen reading, UI automation | Phone control |
| `SYSTEM_ALERT_WINDOW` | Floating assistant overlay | Home button activation |
| `RECORD_AUDIO` | Voice commands, STT | Voice input |
| `FOREGROUND_SERVICE` | Background task execution | Workflows |
| `POST_NOTIFICATIONS` | Alert on workflow completion | Scheduled tasks |
| `INTERNET` | API calls to AI providers | Core functionality |

### Offline Mode Strategy

| Feature | Offline Support | Notes |
|---------|-----------------|-------|
| **UI automation** | ❌ No | Requires AI provider |
| **Workflow execution** | ⚠️ Partial | Cached workflows run |
| **Saved tools/templates** | ✅ Yes | Local storage |
| **API key storage** | ✅ Yes | Encrypted local |
| **Recent conversations** | ✅ Yes | Room database |

### Push Notification Strategy

| Type | Trigger | Priority |
|------|---------|----------|
| Workflow complete | Background task finishes | Default |
| Scheduled task | Cron trigger fires | High |
| Credit balance warning | OpenRouter balance low | High |

### Play Store Compliance

| Concern | Action Required |
|---------|-----------------|
| Accessibility Service Disclosure | ✅ Exists in Blurr — preserve |
| Foreground Service Notice | Add persistent notification |
| User Data Policy | BYOK keys stored locally only |
| In-App Purchases | RevenueCat/Google Play Billing |

### Technical Architecture (Brownfield Constraints)

| Component | Status | Action |
|-----------|--------|--------|
| `ConversationalAgentService.kt` | 66KB | Refactor for BYOK + MCP |
| `ScreenInteractionService.kt` | 50KB | **DO NOT MODIFY** |
| `MainActivity.kt` | 36KB | Add new navigation routes |
| Firebase dependencies | All | Migrate to Appwrite |
| Picovoice dependencies | Wake word | Remove, use BYOK STT |

### Implementation Considerations

1. **Preserve Core Functionality** — Accessibility Service, MediaProjection, home button activation must not change
2. **Migration Strategy** — Replace Firebase incrementally (Auth → Firestore → Analytics)
3. **Testing Requirements** — Android 12-15, major OEM skins (Samsung, Pixel, OnePlus)

---

## Phased Development Roadmap

### Phase 0: Backend & Dependency Cleanup (Week 1)

| Feature | Priority | Effort | Risk |
|---------|----------|--------|------|
| Appwrite migration (Auth) | P0 | 3 days | Medium |
| Appwrite migration (Database) | P0 | 3 days | Medium |
| Remove Firebase dependencies | P0 | 1 day | Low |
| Remove Picovoice dependencies | P0 | 1 day | Low |
| BYOK settings screen | P0 | 2 days | Low |
| BYOK voice (STT/TTS) | P0 | 2 days | Medium |

**Team:** 1 senior Android developer | **Deliverable:** App runs on user-provided keys

---

### Phase 1: Ultra-Generalist Agent (Weeks 2-5)

| Feature | Priority | Effort | Risk |
|---------|----------|--------|------|
| Model selector + balance | P0 | 2 days | Low |
| MCP client integration | P0 | 5 days | High |
| Web search tool | P0 | 2 days | Low |
| Ultra-Generalist 1-chat UI | P0 | 5 days | Medium |
| Google Workspace OAuth | P1 | 3 days | Medium |
| "Save as Reusable Tool" | P1 | 2 days | Low |

**Team:** 1-2 developers | **Deliverable:** Functional AI agent with tools

---

### Phase 2: AI-Native Apps (Weeks 6-12)

| App | Priority | Effort |
|-----|----------|--------|
| AI-native text editor | P1 | 2 weeks |
| AI-native spreadsheets | P1 | 2 weeks |
| AI-native DAW | P2 | 3 weeks |
| AI-native video editor | P2 | 3 weeks |
| AI-native media generator | P2 | 2 weeks |
| AI-native learning platform | P2 | 3 weeks |

**Strategy:** Ship 2-3 apps first based on user demand

---

### Phase 3: Workflow Automation (Weeks 13-20)

| Feature | Priority | Effort |
|---------|----------|--------|
| Visual workflow builder | P1 | 4 weeks |
| n8n integration | P2 | 2 weeks |
| Scheduled execution | P1 | 1 week |
| Trigger system | P2 | 3 weeks |

---

### Phase 4: Monetization (Weeks 21-24)

| Feature | Priority | Effort |
|---------|----------|--------|
| RevenueCat/Play Billing | P0 | 3 days |
| Free tier limits | P0 | 2 days |
| Pro tier unlocks | P0 | 2 days |
| God Mode features | P1 | 1 week |

---

### Risk Mitigation Summary

| Risk | Mitigation |
|------|------------|
| Appwrite migration complexity | Start with Auth, validate, expand |
| MCP integration on mobile | Prototype early, fallback to non-MCP |
| AI-native apps thin | Focus 2-3 apps, depth before breadth |
| Workflow builder UX | Research iOS Shortcuts, prioritize simplicity |

---

## Functional Requirements

### 1. API Key Management (BYOK)

- FR1: Users can add API keys for OpenRouter provider
- FR2: Users can add API keys for AIMLAPI.com provider
- FR3: Users can add API keys for Groq provider
- FR4: Users can add API keys for Fireworks provider
- FR5: Users can add API keys for Together provider
- FR6: Users can view real-time credit/balance for connected providers
- FR7: Users can select which provider and model to use for AI calls
- FR8: Users can securely store API keys locally (encrypted)
- FR9: System alerts users when credit balance is low

### 2. Voice Interaction (BYOK)

- FR10: Users can speak commands via BYOK STT (Whisper API)
- FR11: System can respond via BYOK TTS (OpenAI-compatible)
- FR12: Users can configure voice settings (speed, voice selection)

### 3. Phone Automation (Preserve Existing)

- FR13: Users can trigger AI assistant via long-press home button
- FR14: AI can read screen content via Accessibility Service
- FR15: AI can click on screen elements via Accessibility Service
- FR16: AI can type text into input fields via Accessibility Service
- FR17: AI can swipe/scroll on screen via Accessibility Service
- FR18: AI can navigate between apps based on user commands

### 4. Ultra-Generalist AI Agent

- FR19: Users can chat with AI in single 1-chat-UI interface
- FR20: AI can orchestrate multiple tools to complete complex tasks
- FR21: AI can perform web search / deep research (Tavily/Exa/SerpAPI)
- FR22: AI can generate images (Flux, SD3) via BYOK providers
- FR23: AI can generate videos (Kling) via BYOK providers
- FR24: AI can generate music/audio (Suno, Udio) via BYOK providers
- FR25: AI can generate 3D models (Meshy, Tripo) via BYOK providers
- FR26: AI can generate PowerPoint presentations
- FR27: AI can generate PDF documents
- FR28: AI can generate infographics
- FR29: Users can save successful prompt+tool chains as reusable tools
- FR30: System can connect to MCP servers as a client

### 5. Google Workspace Integration

- FR31: Users can authenticate with Google via OAuth
- FR32: AI can read and compose Gmail messages
- FR33: AI can create and read Google Calendar events
- FR34: AI can read and edit Google Drive files
- FR35: AI can read and edit Google Sheets data

### 6. AI-Native Applications

- FR36: Users can access AI-native text editor
- FR37: Users can access AI-native spreadsheets generator/editor
- FR38: Users can access AI-native DAW for music creation
- FR39: Users can access AI-native video editor
- FR40: Users can access AI-native multimodal media generator
- FR41: Users can access AI-native learning platform

### 7. Workflow Automation

- FR42: Users can create visual workflows using node-based editor
- FR43: Users can schedule workflows to run at specific times
- FR44: Users can trigger workflows based on events (Gmail, calendar)
- FR45: System can execute workflows in background
- FR46: Users can import/export workflows (n8n compatible)
- FR47: Users can connect to external n8n instances

### 8. Subscription & Monetization

- FR48: Free users are limited to 10 agent runs per day
- FR49: Pro users ($14.99/mo) get unlimited runs and full access
- FR50: God Mode users ($29.99/mo) get private MCP hosting
- FR51: System enforces usage limits with graceful degradation
- FR52: Users can manage subscription via in-app purchases

### 9. System & Administrative

- FR53: Users can view conversation history
- FR54: System stores data locally with sync to Appwrite
- FR55: System provides clear error messages with recovery options

---

## Non-Functional Requirements

### Performance

| Requirement | Target | Measurement |
|-------------|--------|-------------|
| NFR-P1: AI response latency | P95 <3 seconds | Time to first response token |
| NFR-P2: App cold start | <3 seconds | Time from tap to interactive |
| NFR-P3: UI frame rate | 60fps minimum | During normal operation |
| NFR-P4: Memory usage | <300MB average | Background service included |
| NFR-P5: Accessibility Service latency | <100ms per action | Click/type/swipe |

### Security

| Requirement | Target | Implementation |
|-------------|--------|----------------|
| NFR-S1: API key encryption | AES-256 at rest | Android Keystore |
| NFR-S2: Network security | TLS 1.3 minimum | All API calls |
| NFR-S3: No key transmission | Never sent to dev servers | Core BYOK promise |
| NFR-S4: Session management | Secure token refresh | Appwrite sessions |

### Privacy (BYOK Model)

| Requirement | Target | Rationale |
|-------------|--------|-----------|
| NFR-PR1: Keys stored locally only | No cloud sync of keys | Core BYOK promise |
| NFR-PR2: Conversation local-first | Appwrite sync optional | User control |
| NFR-PR3: Analytics opt-in only | No tracking without consent | Trust building |

### Reliability

| Requirement | Target | Measurement |
|-------------|--------|-------------|
| NFR-R1: Crash-free rate | 99.5%+ | Analytics tracking |
| NFR-R2: Accessibility Service uptime | 99.9%+ | Service health |
| NFR-R3: Graceful degradation | Continue on provider failure | Fallback UI |
| NFR-R4: Workflow execution | 95%+ success rate | Background tasks |

### Compatibility

| Requirement | Target | Notes |
|-------------|--------|-------|
| NFR-C1: Android version | 7.0 - 15 (API 24-35) | Current SDK config |
| NFR-C2: Device diversity | Top 20 Android devices | Samsung, Pixel, OnePlus |
| NFR-C3: OEM skin support | Accessibility works on major skins | MIUI, OneUI, ColorOS |

### Integration

| Requirement | Target | Notes |
|-------------|--------|-------|
| NFR-I1: Multi-provider | 5+ AI providers | OpenRouter, AIMLAPI, Groq+ |
| NFR-I2: OAuth reliability | 99%+ auth success | Google Workspace |
| NFR-I3: MCP compliance | Full spec support | As MCP client |
| NFR-I4: n8n compatibility | Import/export workflows | JSON format |

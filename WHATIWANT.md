**OVERALL DESCRIPTION:**
a bring-your-own-openrouter-or-aimlapi.com-api-key mobile app that offers ui automation, workflow automation,  schedule workflows, n8n integration, Integrations with Google Workspace, ai native agents like ai-native text editor, ai-native DAW (Digital Audio Workstation) , ai-native Capcut, AI-native multimodal media gen (like jaaz.app or google mixboard) , ai-native learning platform (like notebooklm) , ai-native spreadsheets generator and editor, ai-native 1-chat-UI super generalist ai agent that can make PowerPoints, spreadsheets, images, music, 3d models, videos, audio, deep research, web search, pdf generation, infographics, CRUD and execute workflows and integrations, use my phone by clicking on things, etc.  , for android: an on-home-button-long-press-activated google assistant like ai popup.  

**WHAT I WANT YOU TO DO:**

You are an expert Android developer and AI integration specialist. Your task is to help me build a premium mobile AI super-assistant app for Android by forking and significantly extending the open-source repository https://github.com/Ayush0Chaudhary/twent.

**Full App Vision (this is the complete product we are building):**
This is a bring-your-own-API-key (OpenRouter or AIMLAPI.com) mobile app that turns the smartphone into a powerful AI operating system. Core features include:
- UI automation and phone control (clicking, typing, swiping, reading screen)
- Long-press home button activated floating AI assistant (already provided by Twent)
- Workflow automation with scheduling
- n8n-like visual workflow builder and n8n integration
- Google Workspace integrations
- A single ultra-generalist 1-chat-UI AI agent that can perform deep research, web search, generate PowerPoints, spreadsheets, images, music, 3D models, videos, audio, PDFs, infographics, execute workflows, CRUD operations, and control the phone
- Multiple **AI-native agents/apps** built into the platform, including:
  - AI-native text editor
  - AI-native DAW (Digital Audio Workstation)
  - AI-native CapCut-like video editor
  - AI-native multimodal media generator (similar to jaaz.app or Google Mixboard)
  - AI-native learning platform (similar to NotebookLM)
  - AI-native spreadsheets generator and editor
- All powered by user-provided API keys (BYOK) — the app never pays for or uses developer-funded compute.

**Important Constraints:**
- We are keeping Android and iOS as two completely separate codebases (no cross-platform merge). This work is only for the Android app based on the Twent repo. Ignore any iOS/PhoneAgent-related parts.
- **Do not modify or break any existing core functionalities of the Twent app**, such as UI automation (Accessibility Service, MediaProjection, screen understanding, click/type/swipe actions), the floating assistant, home button long-press activation, or any other current features. All new additions must integrate seamlessly without disrupting what already works.

### Core Vision & Features to Implement (in this exact phased order)

**Phase 0 (Immediate – First Week) – Backend & Dependency Cleanup**
- First and foremost: Completely replace Firebase with Appwrite as the entire backend solution. Migrate all authentication, database, storage, analytics, crash reporting, remote config, and any other Firebase-dependent features to Appwrite (self-hosted or cloud). Set up Appwrite for user accounts, settings sync, asset storage, etc.
- Completely remove all hard-coded Gemini and OpenAI API keys and dependencies.
- Remove any existing voice-related dependencies (e.g., Picovoice, Porcupine, or other STT/TTS APIs).
- Add a clean "Bring Your Own Key" (BYOK) settings screen where users can input API keys for:
  - OpenRouter
  - AIMLAPI.com
  - Groq
  - Fireworks
  - Together
  - Any other major providers available via OpenRouter/AIMLAPI
- For voice features (Speech-to-Text and Text-to-Speech): Implement BYOK support routed through the same providers (e.g., OpenRouter or AIMLAPI.com endpoints that support STT/TTS, such as OpenAI-compatible Whisper/TTS models). Users provide their own keys — never use built-in or developer-funded voice APIs.
- Add a model selector dropdown with real-time credit/balance display (where supported by the provider).
- Ensure all AI calls (including voice STT/TTS) now route through the user-provided keys.

**Phase 1 (MVP Launch – Next 3-5 Weeks) – Ultra-Generalist Agent + Core Tools**
- Implement full support for MCP (Model Context Protocol) as a client to enable future-proof tool access.
- Add built-in tools:
  - Web search / deep research (Tavily, Exa, SerpAPI – user key)
  - Multimodal generation (images, video, audio, music, 3D) via OpenRouter/AIMLAPI
  - Google Workspace integration (OAuth)
  - PowerPoint, PDF, infographic generation and export
  - Full phone control using existing Twent capabilities
- Build the central "Ultra-Generalist AI Agent" 1-chat UI that can orchestrate all tools and perform complex tasks (research, generate media, create documents, control phone, execute workflows, etc.).
- Add tool selection UI to enable/disable built-in tools.

**Phase 2 (Next 6-10 Weeks) – AI-Native Agents & Apps**
- Begin building the suite of AI-native agents/apps (these will be separate screens/modes accessible from the main assistant or home screen):
  - AI-native text editor (rich text with AI assistance)
  - AI-native spreadsheets generator and editor
  - AI-native DAW (Digital Audio Workstation) with AI music generation/editing
  - AI-native CapCut-like video editor with AI clip generation/editing
  - AI-native multimodal media generator (like jaaz.app or Google Mixboard)
  - AI-native learning platform (similar to NotebookLM – audio discussions, note organization, study aids)
- All powered by the same BYOK backend and generalist agent under the hood.

**Phase 3 (Next 4-8 Weeks) – Workflow Automation & Integrations**
- Build a lightweight, mobile-friendly n8n-style visual workflow builder.
- Add n8n integration (ability to import/export workflows or connect to user’s n8n instance).
- Nodes: all tools, AI-native agents, triggers (schedule, Gmail, calendar, screen changes, etc.).
- Enable scheduling and background execution of workflows.

**Phase 4 (Monetization & Polish)**
- Freemium tiers:
  - Free: 10 agent runs/day, basic tools, limited AI-native apps
  - Pro ($14.99/mo or $119/year): Unlimited, full tool/agent access, workflow builder, 50 GB storage
  - God Mode ($29.99/mo or $299/year): Everything + private MCP hosting, team sharing, white-label
- Use RevenueCat or Google Play Billing.
- Ad-free experience in paid tiers.

### Key Requirements & Constraints
- All compute (LLM, voice, media gen) paid by user via BYOK.
- Privacy-first: keys stored locally only.
- Performance and stability critical — preserve all existing Twent automation.
- Rate-limiting to avoid provider bans.

### Deliverables
Act as my senior Android architect:
1. Code structure plans, snippets, library recommendations.
2. UI/UX for new screens (BYOK, agent chat, AI-native apps, workflow editor).
3. Integration guides (Appwrite, MCP, Google Workspace, n8n, BYOK voice, multimodal tools).
4. Subscription implementation.

Start with Phase 0: Analyze current Twent codebase (as of December 2025) and propose exact steps for Appwrite migration, voice BYOK switch, and full BYOK setup.

Proceed phase by phase only when I confirm completion. Help me ship this full-vision AI super-assistant as fast and profitably as possible.
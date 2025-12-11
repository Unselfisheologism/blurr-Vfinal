---
stepsCompleted: [1, 2, 3, 4, 5, 6]
inputDocuments: 
  - docs/prd.md
  - docs/epics.md
  - docs/project_context.md
  - WHATIWANT.md
workflowType: 'ux-design'
lastStep: 6
project_name: 'Blurr AI Assistant - BYOK'
user_name: 'James Abraham'
date: '2025-12-11'
---

# UX Design Specification: Blurr AI Assistant - BYOK

**Author:** James Abraham  
**Date:** 2025-12-11  
**Version:** 1.0  
**Status:** Complete

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Project Understanding](#project-understanding)
3. [User Context & Personas](#user-context--personas)
4. [Design Challenges & Solutions](#design-challenges--solutions)
5. [Information Architecture](#information-architecture)
6. [Core User Flows](#core-user-flows)
7. [UI Components & Patterns](#ui-components--patterns)
8. [Interaction Design](#interaction-design)
9. [Visual Design Direction](#visual-design-direction)
10. [Accessibility & Inclusivity](#accessibility--inclusivity)
11. [Success Metrics](#success-metrics)
12. [Implementation Guidelines](#implementation-guidelines)

---

## 1. Executive Summary

Blurr AI Assistant is a revolutionary mobile AI super-assistant for Android that transforms smartphones into powerful AI operating systems. The key differentiator: **Pure BYOK (Bring Your Own Key)** - users control their API costs, privacy, and provider choice.

**Core Interaction:** Long-press home button → Ultra-Generalist AI Agent Chat

**Key Features:**
- Multi-provider AI (OpenRouter, AIMLAPI, Groq, Fireworks, Together, OpenAI)
- Phone automation (screen reading, clicking, typing, swiping)
- 6 AI-native apps (text editor, spreadsheets, DAW, video editor, media generator, learning platform)
- Visual workflow builder (n8n-style)
- MCP client (Model Context Protocol)
- Google Workspace integration
- Multimodal generation (images, video, audio, music)
- Web search integration

**Monetization:**
- Free: Unlimited AI runs forever (no quotas)
- Pro: $14.99/mo - Premium features (web search, workflows, local models)
- God Mode: $29.99/mo - Enterprise + team features

---

## 2. Project Understanding

### 2.1 Product Vision

Transform Android phones into AI operating systems where ONE intelligent agent can:
- Research and summarize information
- Generate any type of media (images, video, music, documents)
- Control the phone (automation)
- Build and execute workflows
- Access external tools via MCP
- Integrate with productivity suites (Google Workspace)

**Philosophy:** User controls everything - API keys, costs, privacy, provider choice.

### 2.2 Current State (Phase 0 - Complete)

✅ Appwrite backend migration (replacing Firebase)  
✅ BYOK architecture implemented  
✅ Encrypted API key storage (AES256_GCM)  
✅ Multi-provider support (6 providers)  
✅ Voice STT/TTS via user's API keys  
✅ No hard-coded developer API keys  

### 2.3 Target Platform

- **Primary:** Android phones (Android 8.0+)
- **Secondary:** Android tablets (future)
- **Interaction:** Touch, voice, home button long-press
- **Always-on:** Background service for workflows

---

## 3. User Context & Personas

### 3.1 Primary Persona: "The Power User"

**Demographics:**
- Age: 25-45
- Tech-savvy, understands APIs and LLM providers
- Values privacy and cost transparency
- Android enthusiast

**Goals:**
- Control AI costs directly (no hidden subscription markup)
- Access multiple AI providers
- Automate phone tasks
- Create content (documents, media) efficiently
- Build complex workflows

**Pain Points:**
- Tired of paying for AI subscriptions with hidden markup
- Frustrated by vendor lock-in
- Wants privacy - doesn't trust apps with API keys
- Needs phone automation but existing tools are clunky

**Motivations:**
- "I want to see exactly what I'm paying OpenRouter/Groq"
- "My keys should never leave my device"
- "I should be able to switch providers anytime"
- "One app should do everything - no context switching"

### 3.2 User Tech Level

**High technical competence:**
- Understands what API keys are
- Knows how to get keys from providers
- Comfortable with OAuth flows
- Appreciates technical transparency

**Expects:**
- Control over configuration
- Detailed usage statistics
- Cost breakdowns per API call
- Security transparency

---

## 4. Design Challenges & Solutions

### 4.1 Challenge: Onboarding Complexity

**Problem:** Users must configure API keys before app works.

**Solution: "Try Before Config" Approach**

Leverage existing permission onboarding (5 device permissions) then:

1. **User lands on Main Home Screen** - Can explore freely
2. **When trying AI features** - Friendly prompt appears:
   ```
   🔑 API Key Required
   
   To use AI features, configure your API key.
   You control costs!
   
   [Show Me How] [Configure Now]
   ```
3. **[Show Me How]** - Embedded YouTube tutorial (getting OpenRouter key)
4. **[Configure Now]** - Opens BYOK Settings

**Benefits:**
- User understands value BEFORE configuring
- Tutorial reduces friction
- Feels like "unlocking power" not a barrier

### 4.2 Challenge: Information Architecture

**Problem:** Massive scope - Chat + Automation + 6 AI-native apps + Workflow builder + Settings

**Solution: Hub & Spoke Model**

**Primary Interface:** Ultra-Generalist AI Agent Chat (home button long-press)

**Secondary Interface:** App Home Screen (4-tab navigation)

```
Bottom Navigation:
[🏠 Home] [🎯 Apps] [⚡ Auto] [⚙️ More]
```

**Tab 1: Home**
- Quick access to Ultra-Generalist Chat
- Recent activity
- Quick action grid

**Tab 2: Apps**
- 6 AI-native apps in grid:
  - 📝 Text Editor
  - 📊 Spreadsheets
  - 🎵 DAW (Digital Audio Workstation)
  - 🎬 Video Editor
  - 🎨 Media Generator
  - 📚 Learning Platform

**Tab 3: Automate**
- N8N visual workflow builder
- Scheduled automations
- Phone control scripts
- Trigger management

**Tab 4: More**
- 🔑 API Keys (BYOK Settings) - HIGH PRIORITY
- 🧠 Memories (conversation history)
- 📊 Usage Stats (API costs)
- 👤 Account (Appwrite auth)
- 💎 Upgrade to Pro/God Mode
- ⚙️ Settings
- ℹ️ Help & Tutorials

**Benefits:**
- Clear separation of concerns
- Ultra-Generalist Chat always accessible
- Power features organized logically
- Not overwhelming despite massive scope

### 4.3 Challenge: Tool Orchestration UI

**Problem:** When AI uses multiple tools, how do we show progress without overwhelming?

**Solution: Progressive Disclosure with Real-Time Status**

**High-level view (default):**
```
🤖 Blurr: I'll help you with that.

🔄 Task Breakdown:
┌─────────────────────────────────┐
│ ✅ 1. Web search Phase 0 info   │
│ ⏳ 2. Generate video script     │
│ ⏸️ 3. Create video with clips   │
│ ⏸️ 4. Upload to YouTube         │
└─────────────────────────────────┘

📊 Tools Used:
🔍 Tavily (web search)
🤖 GPT-4 (script generation)
🎬 Video Gen API (video creation)
📹 YouTube API (upload)

[Show Details] [Stop Task]
```

**Detailed view (expandable):**
```
[Show Details] expands to:

🔍 Web Search Results:
• Found 8 articles about Phase 0
• Key points extracted
• Cost: $0.002 (Tavily API)

🤖 Script Generation:
• Generated 500-word script
• Tokens used: 1,200
• Cost: $0.012 (OpenRouter GPT-4)

[View Full Breakdown]
```

**Design Principles:**
- **Progressive Disclosure:** Show high-level, details on demand
- **Real-time Updates:** ⏸️ → ⏳ → ✅ status changes
- **Cost Transparency:** Show API costs per tool
- **User Control:** Can stop complex tasks mid-execution

### 4.4 Challenge: Context Preservation

**Problem:** User switches between chat, AI apps, workflows - context must flow seamlessly.

**Solution: Shared Context System**

**Cross-App Context Awareness:**

**Scenario 1: Chat → Text Editor**
```
User in Chat: "Write a blog post about Phase 0"
AI generates draft

Chat shows:
┌─────────────────────────────────┐
│  ✅ Draft created!              │
│  [📝 Open in Text Editor]       │
│  [📋 Copy to Clipboard]        │
└─────────────────────────────────┘

User taps → Text Editor opens with:
• AI-generated draft pre-loaded
• Chat history accessible (sidebar)
• AI continues assisting in editor
```

**Scenario 2: Text Editor → Chat**
```
User writes 500 words in Text Editor
Long-presses home button → Chat opens

Chat proactively says:
"I see you're working on 'Phase 0 Blog Post' 
in the text editor. Want me to:
• Continue writing
• Generate images for the post
• Create a social media summary
• Something else?"
```

**Context Panel (swipe from left edge):**
```
┌─────────────────────────────────┐
│  📚 Context & Memories          │
├─────────────────────────────────┤
│  🕐 Recent Activity:            │
│  • Ultra-Generalist Chat        │
│  • Text Editor (5 min ago)      │
│  • Workflow Builder (30 min)    │
│                                 │
│  🗂️ Open Documents:            │
│  • Phase 0 Blog Post (editing)  │
│  • Sprint Plan (draft)          │
│                                 │
│  ⚙️ Active Workflows:          │
│  • Daily Photo Backup (running) │
│  • Email Summarizer (scheduled) │
│                                 │
│  🧠 Conversation Threads:      │
│  • Phase 0 Tutorial (today)     │
│  • Project Planning (yesterday) │
│                                 │
│  [View All Memories]            │
└─────────────────────────────────┘
```

**Benefits:**
- AI always knows user's current context
- Seamless transitions between modes
- No context loss
- Proactive suggestions based on activity

### 4.5 Challenge: Progressive Disclosure (Free vs Pro)

**Problem:** Show capabilities without feeling pushy about upgrades.

**Solution: Value-Based Feature Gating (No Usage Limits)**

**Free Tier Status (no quotas shown):**
```
┌─────────────────────────────────┐
│  Ultra-Generalist Chat          │
│                                 │
│  ✨ Unlimited AI runs           │
│  💎 Upgrade for superpowers     │
└─────────────────────────────────┘
```

**When user tries Pro feature:**
```
┌─────────────────────────────────┐
│  🔍 Web Search & Deep Research  │
│                                 │
│  💎 Pro Feature                 │
│                                 │
│  Search the web, get real-time  │
│  data, and conduct deep research│
│  with Tavily and Exa.           │
│                                 │
│  Available in Pro ($14.99/mo)   │
│  14-Day Free Trial              │
│                                 │
│  [Start Free Trial]             │
│  [Learn More]                   │
└─────────────────────────────────┘
```

**Pro feature gating:**
```
When free user tries Pro feature:

┌─────────────────────────────────┐
│  📊 Spreadsheet Generator       │
│                                 │
│  💎 Pro Feature                 │
│                                 │
│  Create AI-powered spreadsheets │
│  with formulas, charts, more.   │
│                                 │
│  Available in Pro ($14.99/mo)   │
│                                 │
│  [See Pro Benefits]             │
│  [Maybe Later]                  │
└─────────────────────────────────┘
```

**Upgrade comparison:**
```
Settings → Upgrade

┌─────────────────────────────────────────┐
│  Choose Your Plan                       │
├─────────────────────────────────────────┤
│  ✨ FREE                                │
│  • Unlimited AI runs ♾️                │
│  • Unlimited conversations              │
│  • Full phone automation                │
│  • Context preservation                 │
│  • 10 GB storage                        │
│                                         │
│  Current Plan                           │
├─────────────────────────────────────────┤
│  💎 PRO - $14.99/mo ($149/year)         │
│  Everything in Free, plus:              │
│  • Web search & deep research           │
│  • Visual workflow builder + scheduling │
│  • Local/offline models (MLX, Ollama)   │
│  • Advanced multimodal generation       │
│  • 100+ agent templates                 │
│  • 100 GB storage                       │
│  • Priority support                     │
│                                         │
│  [Start 14-Day Free Trial]              │
├─────────────────────────────────────────┤
│  👑 GOD MODE - $29.99/mo ($299/year)   │
│  Everything in Pro, plus:               │
│  • Team sharing (5 users)              │
│  • Private MCP server hosting           │
│  • White-label agents                   │
│  • Advanced analytics & export          │
│  • Dedicated support (1h SLA)          │
│                                         │
│  [Start 14-Day Free Trial]              │
└─────────────────────────────────────────┘
```

**Upgrade triggers (value-based, non-intrusive):**
- Attempting Pro-only feature (web search, advanced workflows)
- Creating 4th workflow (Free tier: 3 basic workflows)
- Trying to schedule workflows
- Attempting to use local models
- After 7 days of active use (gentle nudge showcasing Pro value)

### 4.6 Challenge: Trust & Control

**Problem:** Users need to FEEL secure and see exactly what's happening with their API keys.

**Solution: Comprehensive Transparency Dashboard**

**1. Enhanced BYOK Settings:**
```
┌─────────────────────────────────────────┐
│  🔑 API Keys (BYOK)                     │
├─────────────────────────────────────────┤
│  ✅ OpenRouter                          │
│  🟢 Connected • Model: GPT-4o          │
│  💰 Balance: $15.43                     │
│  📊 Used today: $0.12 (8 calls)        │
│                                         │
│  [View Usage] [Manage]                  │
├─────────────────────────────────────────┤
│  ✅ AIMLAPI.com                         │
│  🟢 Connected • Model: Claude 3.5      │
│  💰 Balance: $23.87                     │
│  📊 Used today: $0.34 (12 calls)       │
│  🎤 Voice: Enabled (Whisper + TTS)     │
│                                         │
│  [View Usage] [Manage]                  │
├─────────────────────────────────────────┤
│  ⚪ Groq (Not configured)               │
│  [Add API Key]                          │
└─────────────────────────────────────────┘
```

**2. Real-Time Usage Dashboard:**
```
Settings → Usage & Analytics

┌─────────────────────────────────────────┐
│  📊 API Usage Dashboard                 │
├─────────────────────────────────────────┤
│  Today's Spending: $0.46                │
│  This Month: $8.23                      │
│  Avg. per day: $0.37                    │
│                                         │
│  📈 Usage by Provider:                  │
│  ████████░░ OpenRouter    $5.12 (62%)  │
│  █████░░░░░ AIMLAPI       $3.11 (38%)  │
│                                         │
│  🔧 Usage by Feature:                   │
│  ██████░░░░ Chat          $4.23 (51%)  │
│  ████░░░░░░ Image Gen     $2.10 (26%)  │
│  ██░░░░░░░░ Voice         $1.20 (15%)  │
│  █░░░░░░░░░ Workflows     $0.70 (8%)   │
│                                         │
│  [Export Report] [Set Budget Alert]     │
└─────────────────────────────────────────┘
```

**3. Budget Management:**
```
Settings → Budget Alerts

┌─────────────────────────────────┐
│  💰 Budget Management           │
├─────────────────────────────────┤
│  Daily Budget: $1.00   [Edit]   │
│  Alert at 80%: ✅ Enabled       │
│                                 │
│  Monthly Budget: $25.00 [Edit]  │
│  Alert at 80%: ✅ Enabled       │
│                                 │
│  ⚠️ Action when limit reached: │
│  ◉ Notify me                    │
│  ○ Stop AI operations          │
│  ○ Switch to backup provider   │
└─────────────────────────────────┘
```

**4. Security Indicators:**
```
Bottom of BYOK Settings:

┌─────────────────────────────────┐
│  🔒 Your Keys Are Secure        │
│  • Encrypted with AES256_GCM    │
│  • Stored locally on device     │
│  • Never sent to Blurr servers  │
│  • You can delete anytime       │
│                                 │
│  [Learn More About Security]    │
└─────────────────────────────────┘
```

**5. Activity Log:**
```
Settings → Activity Log

┌─────────────────────────────────────────┐
│  📋 AI Activity Log                     │
├─────────────────────────────────────────┤
│  🕐 Today, 2:34 PM                      │
│  Chat: "Create presentation"            │
│  • OpenRouter GPT-4o: $0.03            │
│  • Web search (Tavily): $0.002         │
│  • Image gen (DALL-E): $0.04           │
│  Total: $0.072                          │
│  [View Full Breakdown]                  │
├─────────────────────────────────────────┤
│  🕐 Today, 1:15 PM                      │
│  Workflow: "Daily Backup" executed      │
│  • No AI calls (scheduled task)        │
│  Total: $0.00                           │
├─────────────────────────────────────────┤
│  🕐 Today, 10:22 AM                     │
│  Voice: "What's the weather?"           │
│  • AIMLAPI Whisper STT: $0.006         │
│  • AIMLAPI GPT-4 mini: $0.001          │
│  • AIMLAPI TTS: $0.015                 │
│  Total: $0.022                          │
└─────────────────────────────────────────┘
```

**6. Privacy Dashboard:**
```
Settings → Privacy & Data

┌─────────────────────────────────┐
│  🔒 Privacy Settings            │
├─────────────────────────────────┤
│  Data Storage:                  │
│  ✅ Store conversations locally │
│  ✅ Encrypt chat history        │
│  ⚪ Sync to Appwrite (optional) │
│                                 │
│  API Keys:                      │
│  ✅ Local encrypted storage     │
│  ⚪ Never leave this device     │
│                                 │
│  Analytics:                     │
│  ⚪ Share anonymous usage       │
│  ✅ Keep everything private     │
│                                 │
│  🗑️ Delete All Data            │
│  [Export My Data] [Delete]      │
└─────────────────────────────────┘
```

**Benefits:**
- Complete cost transparency
- Real-time usage visibility
- Budget control
- Security assurance
- Activity audit trail
- Privacy controls

---

## 5. Information Architecture

### 5.1 Site Map

```
Blurr AI Assistant
│
├─ 🏠 HOME BUTTON LONG-PRESS
│  └─ Ultra-Generalist AI Agent Chat (PRIMARY INTERFACE)
│     ├─ Chat History
│     ├─ Voice Input
│     ├─ Text Input
│     ├─ File Attachments
│     ├─ Tool Orchestration Status
│     └─ Settings (⚙️)
│
├─ 📱 APP HOME SCREEN (4-tab navigation)
│  │
│  ├─ [🏠 Home] Tab
│  │  ├─ Quick Access to Ultra-Generalist Chat
│  │  ├─ Recent Activity
│  │  └─ Quick Action Grid
│  │
│  ├─ [🎯 Apps] Tab
│  │  ├─ 📝 Text Editor (AI-native)
│  │  ├─ 📊 Spreadsheets (AI-native)
│  │  ├─ 🎵 DAW (AI-native)
│  │  ├─ 🎬 Video Editor (AI-native)
│  │  ├─ 🎨 Media Generator (AI-native)
│  │  └─ 📚 Learning Platform (AI-native)
│  │
│  ├─ [⚡ Auto] Tab
│  │  ├─ N8N Workflow Builder
│  │  ├─ Scheduled Automations
│  │  ├─ Phone Control Scripts
│  │  └─ Trigger Management
│  │
│  └─ [⚙️ More] Tab
│     ├─ 🔑 API Keys (BYOK Settings) ⭐
│     ├─ 🧠 Memories
│     ├─ 📊 Usage & Analytics
│     ├─ 👤 Account (Appwrite)
│     ├─ 💎 Upgrade (Pro/God Mode)
│     ├─ ⚙️ Settings
│     └─ ℹ️ Help & Tutorials
│
└─ 👆 CONTEXT PANEL (swipe from left)
   ├─ Recent Activity
   ├─ Open Documents
   ├─ Active Workflows
   └─ Conversation Threads
```

### 5.2 Navigation Patterns

**Primary Navigation:** 4-tab bottom navigation
- Always visible when in App Home Screen
- Hidden during Ultra-Generalist Chat (home button long-press)
- Active tab highlighted

**Secondary Navigation:** Swipe gestures
- Swipe left edge → Context Panel
- Swipe down → Refresh content
- Long-press home button → Ultra-Generalist Chat (system-level)

**Tertiary Navigation:** In-app actions
- Floating action buttons in specific contexts
- Toolbar actions (top right)
- Contextual menus (long-press items)

### 5.3 Screen Hierarchy

**Level 1: Primary Access**
- Ultra-Generalist AI Chat (home button long-press)
- App Home Screen (launcher icon)

**Level 2: Core Features**
- AI-Native Apps (6 apps)
- Automation (Workflows)
- BYOK Settings
- Usage Dashboard

**Level 3: Supporting Features**
- Memories
- Account Settings
- Help & Tutorials
- Privacy Controls

**Level 4: Detailed Views**
- Activity Logs
- Budget Alerts
- Workflow Editor
- App-specific settings

---

## 6. Core User Flows

### 6.1 First-Time User Onboarding

```
[Install App from Play Store]
        ↓
[Launch App]
        ↓
[Permission Onboarding - Existing]
├─ Screen 1/5: Accessibility Permission
├─ Screen 2/5: Display Over Apps
├─ Screen 3/5: Media Projection
├─ Screen 4/5: Notification Access
└─ Screen 5/5: Battery Optimization
        ↓
[Permissions Granted]
        ↓
[Welcome to App Home Screen]
├─ See 4-tab navigation
├─ See "Try Ultra-Generalist Chat" CTA
└─ Explore UI freely
        ↓
[User Tries AI Feature]
        ↓
[Prompt: "🔑 API Key Required"]
├─ [Show Me How] → YouTube tutorial
└─ [Configure Now] → BYOK Settings
        ↓
[BYOK Settings Screen]
├─ Select Provider (OpenRouter recommended)
├─ Enter API Key
├─ Select Model
└─ Save
        ↓
[Status: "✓ Ready"]
        ↓
[User Returns to Home/Chat]
        ↓
[AI Features Now Active] ✅
```

**Time to Value:** 5-10 minutes (including getting API key)

### 6.2 Ultra-Generalist AI Chat (Primary Flow)

```
[User Long-Presses Home Button]
        ↓
[Ultra-Generalist Chat Opens]
        ↓
[User Input Options]
├─ 🎤 Voice Input
├─ ⌨️ Text Input
└─ 📎 File Attachment
        ↓
[User: "Create a presentation about Phase 0"]
        ↓
[AI Begins Multi-Tool Orchestration]
├─ 🔍 Web search (Tavily)
├─ 🤖 Generate outline (GPT-4)
├─ 🎨 Generate images (DALL-E)
└─ 📄 Create PowerPoint
        ↓
[Progress Display]
├─ Task breakdown (checklist)
├─ Real-time status updates
├─ Cost transparency
└─ [Stop Task] option
        ↓
[Completion]
├─ "✅ Presentation created!"
├─ [📝 Open in Editor]
├─ [📧 Send via Gmail]
├─ [💾 Save to Drive]
└─ [📋 Copy Link]
        ↓
[User Takes Action or Continues Chat]
```

### 6.3 Context-Aware Workflow

**Scenario: Chat → Text Editor → Chat**

```
[User in Ultra-Generalist Chat]
        ↓
[User: "Write a blog post about AI"]
        ↓
[AI Generates Draft]
        ↓
[Chat UI Shows]
├─ Draft preview (first 200 chars)
├─ [📝 Open in Text Editor]
└─ [📋 Copy to Clipboard]
        ↓
[User Taps "Open in Text Editor"]
        ↓
[Text Editor Opens]
├─ Draft pre-loaded
├─ AI assistant in sidebar
├─ Chat history accessible
└─ Context preserved
        ↓
[User Edits for 5 Minutes]
        ↓
[User Long-Presses Home Button]
        ↓
[Ultra-Generalist Chat Opens]
        ↓
[AI Proactively Says]
"I see you're working on 'AI Blog Post' 
in the text editor. Want me to:
• Continue writing the next section
• Generate images for the post
• Create social media summaries
• Something else?"
        ↓
[User Selects Option or New Request]
        ↓
[AI Executes with Full Context]
```

### 6.4 BYOK Configuration Flow

```
[User Opens Settings]
        ↓
[Taps "🔑 API Keys (BYOK)"]
        ↓
[BYOK Settings Screen]
        ↓
[Current State Display]
├─ Connected providers (with status)
├─ Balance display
├─ Usage today
└─ Unconfigured providers
        ↓
[User Taps "Add API Key" for Provider]
        ↓
[Configuration Form]
├─ Provider selection dropdown
├─ API key input (password field)
├─ Model selection dropdown
└─ Voice capabilities info
        ↓
[User Enters Key]
        ↓
[Auto-Validation]
├─ Test API connection
├─ Fetch available models
└─ Check balance (if supported)
        ↓
[Validation Result]
├─ ✅ Success → "Connected!"
└─ ❌ Error → "Invalid key. Check and retry."
        ↓
[User Saves Configuration]
        ↓
[Status Updates]
├─ Provider now "🟢 Connected"
├─ Balance displayed
└─ Ready to use
        ↓
[Security Reminder Shown]
"🔒 Your key is encrypted and stored 
locally on your device. Never sent to 
Blurr servers."
```

### 6.5 Workflow Creation Flow

```
[User Opens "⚡ Auto" Tab]
        ↓
[Sees Workflow List]
├─ Active workflows
├─ Scheduled workflows
└─ [+ Create Workflow] button
        ↓
[User Taps "Create Workflow"]
        ↓
[N8N-Style Visual Builder Opens]
        ↓
[Canvas with Node Palette]
├─ Trigger nodes (Schedule, Gmail, etc.)
├─ Action nodes (AI, Phone Control, etc.)
├─ Logic nodes (Condition, Loop, etc.)
└─ Output nodes (Save, Send, etc.)
        ↓
[User Drags Nodes to Canvas]
        ↓
[User Connects Nodes]
├─ Drag from output port
└─ Drop on input port
        ↓
[User Configures Each Node]
├─ Set parameters
├─ Test individual node
└─ See preview output
        ↓
[User Saves Workflow]
├─ Name workflow
├─ Set trigger (schedule/manual)
└─ Choose activation
        ↓
[Workflow Activated]
├─ Shows in workflow list
├─ Trigger scheduled (if applicable)
└─ Can be edited/deleted anytime
        ↓
[Workflow Executes]
├─ User gets notification
├─ View execution log
└─ See results
```

### 6.6 Free User Encounters Pro Feature

```
[Free User Tries Web Search Feature]
        ↓
[Modal Appears]
┌─────────────────────────────────┐
│  🔍 Web Search                  │
│                                 │
│  💎 Pro Feature                 │
│                                 │
│  Search the web, get real-time  │
│  data, and conduct deep research│
│  with Tavily and Exa.           │
│                                 │
│  Available in Pro ($14.99/mo)   │
│  14-Day Free Trial              │
│                                 │
│  [Start Free Trial]             │
│  [Learn More]                   │
└─────────────────────────────────┘
        ↓
[User Choice]
├─ [Start Free Trial] → Trial activation flow
└─ [Learn More] → Pro features page
        ↓
[User Still Has]
├─ Unlimited AI agent runs
├─ Full phone automation
├─ All basic features
└─ No usage restrictions
```

### 6.7 Upgrade to Pro Flow

```
[User Taps "Upgrade" Anywhere in App]
        ↓
[Plan Comparison Screen]
├─ Free (current)
├─ Pro ($14.99/mo)
└─ God Mode ($29.99/mo)
        ↓
[User Selects Plan]
        ↓
[Payment Options]
├─ Monthly subscription
├─ Annual subscription (save 33%)
└─ 7-day free trial available
        ↓
[User Selects Payment Method]
├─ Google Play Billing
└─ RevenueCat integration
        ↓
[Payment Processing]
        ↓
[Success Confirmation]
┌─────────────────────────────────┐
│  🎉 Welcome to Pro!             │
│                                 │
│  • Unlimited AI runs unlocked   │
│  • All apps now available       │
│  • 50 workflows enabled         │
│                                 │
│  [Start Using Pro Features]     │
└─────────────────────────────────┘
        ↓
[User Account Updated]
├─ tasksRemaining = unlimited
├─ plan = "pro"
└─ All features unlocked
```

---

## 7. UI Components & Patterns

### 7.1 Ultra-Generalist Chat Interface

**Layout:**
```
┌─────────────────────────────────────────┐
│  ← Blurr AI              [⚙️]           │  Header (44dp)
├─────────────────────────────────────────┤
│                                         │
│  💬 Chat Messages (Scrollable)          │  Main Content
│  ┌─────────────────────────────────┐  │
│  │ User: Create a video...         │  │
│  └─────────────────────────────────┘  │
│                                         │
│  ┌─────────────────────────────────┐  │
│  │ 🤖 Blurr:                       │  │
│  │ 🔄 Task Breakdown:              │  │
│  │ ✅ 1. Web search                │  │
│  │ ⏳ 2. Generate script           │  │
│  │ ⏸️ 3. Create video              │  │
│  │                                 │  │
│  │ [Show Details] [Stop]           │  │
│  └─────────────────────────────────┘  │
│                                         │
├─────────────────────────────────────────┤
│  🎤  [Type message or command...]   📎 │  Input Bar (56dp)
└─────────────────────────────────────────┘
```

**Component Specifications:**

**Message Bubble (User):**
- Background: #6366F1 (Purple-600)
- Text color: #FFFFFF
- Border radius: 16dp
- Padding: 12dp 16dp
- Max width: 80% of screen
- Align: Right
- Font: Roboto, 16sp

**Message Bubble (AI):**
- Background: #1F2937 (Gray-800)
- Text color: #F9FAFB (Gray-50)
- Border radius: 16dp
- Padding: 12dp 16dp
- Max width: 85% of screen
- Align: Left
- Font: Roboto, 16sp

**Tool Status Indicators:**
- ⏸️ Pending: #9CA3AF (Gray-400)
- ⏳ In Progress: #FBBF24 (Amber-400) with pulse animation
- ✅ Complete: #10B981 (Green-500)
- ❌ Error: #EF4444 (Red-500)

**Input Bar:**
- Height: 56dp (collapsed), expands to 120dp (multi-line)
- Background: #374151 (Gray-700)
- Border radius: 28dp
- Voice button: 🎤 (48dp, circular)
- Attach button: 📎 (40dp)
- Send button: ➤ (appears when text entered)

### 7.2 Bottom Navigation

**Specifications:**
- Height: 56dp
- Background: #1F2937 (Gray-800)
- Elevation: 8dp
- Icons: 24dp
- Labels: Roboto Medium, 12sp
- Active color: #6366F1 (Purple-600)
- Inactive color: #9CA3AF (Gray-400)

**Tab States:**
```
[🏠 Home]  [🎯 Apps]  [⚡ Auto]  [⚙️ More]
   ↑ Active (highlighted with indicator dot)
```

**Active Indicator:**
- Small dot (4dp) above icon
- Color: #6366F1
- Animated transition (150ms ease-in-out)

### 7.3 BYOK Settings Card

**Provider Card (Connected):**
```
┌─────────────────────────────────────────┐
│  ✅ OpenRouter                          │
│  🟢 Connected • Model: GPT-4o          │
│  💰 Balance: $15.43                     │
│  📊 Used today: $0.12 (8 calls)        │
│                                         │
│  [View Usage] [Manage]                  │
└─────────────────────────────────────────┘
```

**Card Specifications:**
- Background: #374151 (Gray-700)
- Border radius: 12dp
- Padding: 16dp
- Margin bottom: 12dp
- Elevation: 2dp
- Status indicator: 8dp circle
  - 🟢 Connected: #10B981
  - 🔴 Error: #EF4444
  - ⚪ Not configured: #6B7280

**Provider Card (Not Configured):**
```
┌─────────────────────────────────────────┐
│  ⚪ Groq (Not configured)               │
│  [Add API Key]                          │
└─────────────────────────────────────────┘
```

### 7.4 Task Breakdown Component

**Specifications:**
```
🔄 Task Breakdown:
┌─────────────────────────────────┐
│ ✅ 1. Web search Phase 0 info   │  Completed
│ ⏳ 2. Generate video script     │  In Progress (pulse)
│ ⏸️ 3. Create video with clips   │  Pending
│ ⏸️ 4. Upload to YouTube         │  Pending
└─────────────────────────────────┘
```

- Container: #1F2937, border-radius 8dp, padding 12dp
- Each task: 40dp height
- Status icons: 20dp
- Font: Roboto Medium, 14sp
- Animations:
  - ⏳ Pulse: opacity 0.5 ↔ 1.0, 1s infinite
  - ⏸️ → ⏳: Fade + scale 0.8 → 1.0, 200ms
  - ⏳ → ✅: Scale 1.0 → 1.2 → 1.0, 300ms

### 7.5 Context Panel

**Swipe Gesture Activation:**
- Swipe from left edge (< 20dp from edge)
- Drawer width: 320dp (80% of screen on phones)
- Background: #111827 (Gray-900)
- Overlay: rgba(0,0,0,0.5)
- Animation: 250ms ease-out

**Panel Content:**
```
┌─────────────────────────────────┐
│  📚 Context & Memories          │  Header
├─────────────────────────────────┤
│                                 │
│  🕐 Recent Activity:            │  Section
│  • Ultra-Generalist Chat        │  List items
│  • Text Editor (5 min ago)      │
│                                 │
│  🗂️ Open Documents:            │  Section
│  • Phase 0 Blog Post (editing)  │
│                                 │
│  ⚙️ Active Workflows:          │  Section
│  • Daily Photo Backup (running) │
│                                 │
│  [View All Memories]            │  Button
└─────────────────────────────────┘
```

### 7.6 Modal Dialogs

**Standard Modal (e.g., Daily Limit Reached):**
- Width: 90% of screen (max 400dp)
- Background: #1F2937 (Gray-800)
- Border radius: 16dp
- Padding: 24dp
- Overlay: rgba(0,0,0,0.7)
- Animation: Scale 0.9 → 1.0 + Fade in, 200ms

**Button Styles:**
- Primary: #6366F1, text #FFFFFF, height 48dp
- Secondary: Transparent, border 1dp #6366F1, text #6366F1
- Destructive: #EF4444, text #FFFFFF
- All buttons: border-radius 24dp, min-width 120dp

### 7.7 Loading States

**Shimmer Effect (for list items):**
- Background gradient: linear-gradient(90deg, #374151 0%, #4B5563 50%, #374151 100%)
- Animation: translateX(-100% → 100%), 1.5s infinite
- Use for: Provider cards loading, workflow list, activity log

**Circular Progress:**
- Size: 48dp (large), 24dp (small)
- Color: #6366F1
- Thickness: 4dp
- Use for: API calls, page transitions

**Skeleton Screens:**
- Use for initial page loads
- Match layout of actual content
- Shimmer animation on all placeholder elements

### 7.8 Empty States

**Pattern:**
```
┌─────────────────────────────────┐
│                                 │
│         [Icon 64dp]             │
│                                 │
│     Heading Text                │
│     Supporting text below       │
│                                 │
│     [Primary Action]            │
│                                 │
└─────────────────────────────────┘
```

**Examples:**

**No API Keys:**
- Icon: 🔑
- Heading: "No API Keys Configured"
- Text: "Add your API key to unlock AI features"
- Action: [Configure BYOK]

**No Workflows:**
- Icon: ⚙️
- Heading: "No Workflows Yet"
- Text: "Create automated tasks with visual workflow builder"
- Action: [Create Workflow]

### 7.9 Toast Notifications

**Success:**
- Background: #10B981 (Green-500)
- Icon: ✅
- Duration: 3s
- Position: Bottom + 88dp (above nav bar)
- Example: "API key saved successfully"

**Error:**
- Background: #EF4444 (Red-500)
- Icon: ❌
- Duration: 5s
- Example: "Invalid API key. Please check and retry."

**Info:**
- Background: #3B82F6 (Blue-500)
- Icon: ℹ️
- Duration: 3s
- Example: "Workflow execution started"

**Warning:**
- Background: #F59E0B (Amber-500)
- Icon: ⚠️
- Duration: 4s
- Example: "Approaching daily budget limit"

---

## 8. Interaction Design

### 8.1 Gestures

**Swipe Gestures:**
- **Swipe left edge**: Open Context Panel
- **Swipe down**: Refresh current view
- **Swipe up on message**: Quick reply
- **Long-press message**: Copy/share/delete options

**Touch Targets:**
- Minimum: 48dp × 48dp
- Preferred: 56dp × 56dp for primary actions
- Spacing: 8dp between interactive elements

**Haptic Feedback:**
- Light: UI interactions (button taps)
- Medium: State changes (toggle switches)
- Heavy: Important actions (workflow execution, AI task completion)

### 8.2 Animations

**Page Transitions:**
- Duration: 300ms
- Curve: cubic-bezier(0.4, 0.0, 0.2, 1) (Material standard)
- Type: Shared element transitions where applicable

**Micro-interactions:**
- Button press: Scale 1.0 → 0.95, 100ms
- Toggle: Slide + color change, 200ms
- Expand/collapse: Height animation, 250ms

**Progress Animations:**
- Indeterminate loading: Continuous rotation
- Determinate: Smooth arc growth with easing
- Success: Checkmark draw animation, 400ms

### 8.3 Voice Interaction

**Voice Input Flow:**
1. User taps 🎤 button
2. Button pulses (indicates listening)
3. Speech waveform visualizer appears
4. Text appears in real-time (if STT supports streaming)
5. User finishes speaking or taps button again
6. Transcription finalizes
7. AI processes and responds

**Voice Output:**
- Visual indicator when AI is speaking
- Animated sound wave
- Pause/stop controls
- Speed control (0.75x, 1x, 1.25x, 1.5x)

### 8.4 Error Handling

**Progressive Error Messages:**

**Level 1 - Inline Validation:**
```
[API Key Input]
❌ Invalid format. Must start with 'sk-'
```

**Level 2 - Toast Notification:**
```
❌ Connection failed. Check your internet.
```

**Level 3 - Modal Dialog:**
```
⚠️ API Rate Limit Exceeded

You've made too many requests.
Wait 60 seconds or switch providers.

[Switch Provider] [Wait]
```

**Error Recovery:**
- Always provide clear next steps
- Offer alternative actions
- Never dead-end the user

---

## 9. Visual Design Direction

### 9.1 Color Palette

**Primary Colors:**
- Purple-600: #6366F1 (Primary actions, active states)
- Purple-500: #8B5CF6 (Hover states)
- Purple-700: #5B21B6 (Pressed states)

**Grayscale:**
- Gray-50: #F9FAFB (Primary text)
- Gray-400: #9CA3AF (Secondary text, disabled)
- Gray-700: #374151 (Cards, elevated surfaces)
- Gray-800: #1F2937 (Primary background)
- Gray-900: #111827 (Deeper backgrounds, overlays)

**Semantic Colors:**
- Success: #10B981 (Green-500)
- Error: #EF4444 (Red-500)
- Warning: #F59E0B (Amber-500)
- Info: #3B82F6 (Blue-500)

**Gradients:**
- Hero sections: linear-gradient(135deg, #667eea 0%, #764ba2 100%)
- Shimmer: linear-gradient(90deg, #374151 0%, #4B5563 50%, #374151 100%)

### 9.2 Typography

**Font Family:**
- Primary: Roboto
- Monospace (for code/keys): Roboto Mono

**Type Scale:**
- H1: 32sp, Bold, Letter spacing -0.5
- H2: 24sp, Bold, Letter spacing -0.25
- H3: 20sp, Medium
- Body: 16sp, Regular, Line height 24sp
- Caption: 12sp, Regular, Letter spacing 0.25
- Button: 14sp, Medium, All caps

**Text Colors:**
- Primary: #F9FAFB (Gray-50)
- Secondary: #D1D5DB (Gray-300)
- Disabled: #6B7280 (Gray-500)

### 9.3 Iconography

**Icon Library:** Material Design Icons
**Sizes:**
- Small: 16dp (inline with text)
- Medium: 24dp (standard UI elements)
- Large: 48dp (empty states, headers)

**Style:**
- Outlined style for inactive states
- Filled style for active states
- Consistent 2dp stroke weight

**Custom Icons:**
- AI Agent: Brain with sparkles
- BYOK: Key with lock
- Workflow: Connected nodes
- Phone Control: Phone with touch indicator

### 9.4 Spacing & Layout

**Base Unit:** 8dp

**Spacing Scale:**
- 4dp: Tight spacing (between related items)
- 8dp: Default spacing
- 16dp: Section spacing
- 24dp: Large spacing (between major sections)
- 32dp: Extra large (page margins)

**Elevation:**
- Level 0: 0dp (flat surfaces)
- Level 1: 2dp (cards)
- Level 2: 4dp (buttons, chips)
- Level 3: 8dp (navigation bar)
- Level 4: 16dp (modals, dialogs)

### 9.5 Material Design 3 Alignment

**Principles:**
- Dynamic color: Support Material You theming
- Motion: Use Material motion system
- Components: Use Material 3 components where possible
- Accessibility: WCAG 2.1 AA minimum

**Key Components:**
- Bottom Navigation: Material 3 Navigation Bar
- Cards: Material 3 Cards with filled style
- Buttons: Material 3 Filled/Outlined/Text buttons
- Text Fields: Material 3 Outlined text fields

---

## 10. Accessibility & Inclusivity

### 10.1 Screen Reader Support

**Content Descriptions:**
- All interactive elements have meaningful labels
- Images have alt text
- Icon-only buttons have contentDescription
- Status updates announced dynamically

**Examples:**
- Voice button: "Start voice input"
- Settings icon: "Open settings"
- Provider status: "OpenRouter connected, balance $15.43"

### 10.2 Touch Target Sizes

**Minimum Sizes:**
- All interactive elements: 48dp × 48dp minimum
- Preferred: 56dp × 56dp for frequently used actions
- Spacing: 8dp between adjacent touch targets

**Exceptions:**
- Dense lists: 40dp height acceptable with adequate spacing
- Text links: Full line height (24sp minimum)

### 10.3 Color Contrast

**Ratios (WCAG 2.1 AA):**
- Normal text (16sp+): 4.5:1 minimum
- Large text (24sp+): 3:1 minimum
- UI components: 3:1 minimum

**Validation:**
- Primary text (#F9FAFB) on background (#1F2937): 13.5:1 ✅
- Secondary text (#D1D5DB) on background: 8.1:1 ✅
- Purple (#6366F1) on background: 4.8:1 ✅

### 10.4 Keyboard Navigation

**Support for:**
- Tab navigation through interactive elements
- Enter/Space for activation
- Arrow keys for lists and menus
- Escape to dismiss modals

**Focus Indicators:**
- 2dp outline
- Color: #6366F1 (Purple-600)
- Offset: 2dp from element

### 10.5 Reduced Motion

**Respect prefers-reduced-motion:**
- Disable decorative animations
- Keep essential transitions (page changes)
- Reduce animation duration by 50%
- Remove continuous animations (pulse, shimmer)

### 10.6 Text Scaling

**Support up to 200% text scaling:**
- Use sp units for all text
- Flexible layouts (avoid fixed heights)
- Test at 100%, 130%, 200% scale
- Ensure no text truncation

### 10.7 Alternative Input Methods

**Voice Control:**
- All actions accessible via voice commands
- Clear voice feedback
- Confirmation for destructive actions

**Switch Access:**
- Logical navigation order
- Grouped related actions
- Highlight current focus clearly

---

## 11. Success Metrics

### 11.1 User Activation

**Metric:** Time to First AI Interaction
- **Target:** < 10 minutes from install
- **Measure:** Install → API key configured → First AI response

**Metric:** BYOK Configuration Success Rate
- **Target:** > 80%
- **Measure:** Users who complete API key setup / Total users who attempt

### 11.2 Engagement

**Metric:** Daily Active Users (DAU)
- **Target:** 40% of Monthly Active Users
- **Measure:** Users who trigger AI agent at least once per day

**Metric:** AI Interactions per Day
- **Target:** 15+ for free users, 50+ for Pro users
- **Measure:** Average number of AI requests per active user

**Metric:** Feature Adoption
- **Target:** 
  - Ultra-Generalist Chat: 100% of active users
  - AI-Native Apps: 30% of Pro users
  - Workflows: 20% of Pro users
- **Measure:** % of users who use each feature weekly

### 11.3 Retention

**Metric:** Day 1, 7, 30 Retention
- **Target:** D1: 60%, D7: 40%, D30: 25%
- **Measure:** Users who return on day 1/7/30 after install

**Metric:** Free-to-Pro Conversion
- **Target:** 5% within 30 days
- **Measure:** Free users who upgrade to Pro / Total free users

### 11.4 User Satisfaction

**Metric:** Net Promoter Score (NPS)
- **Target:** > 50
- **Measure:** In-app survey after 7 days of use

**Metric:** API Cost Satisfaction
- **Target:** > 80% report savings vs traditional AI apps
- **Measure:** Survey response to "Are you saving money with BYOK?"

### 11.5 Technical Performance

**Metric:** API Key Storage Security
- **Target:** 0 security incidents
- **Measure:** Monitor for any key exposure or breaches

**Metric:** AI Response Time
- **Target:** < 3 seconds for simple requests
- **Measure:** Time from user input to AI first response

**Metric:** Crash-Free Sessions
- **Target:** > 99.5%
- **Measure:** Sessions without crashes / Total sessions

---

## 12. Implementation Guidelines

### 12.1 Development Phases

**Phase 1: Foundation (Current - Phase 0 Complete)**
✅ BYOK architecture
✅ Encrypted key storage
✅ Multi-provider support
✅ Basic Ultra-Generalist Chat

**Phase 2: Core Features (Next)**
- Ultra-Generalist Chat UI enhancements
- Tool orchestration UI
- Context preservation system
- Usage dashboard

**Phase 3: AI-Native Apps**
- Text Editor (AI-first)
- Spreadsheets
- Media Generator
- Other apps as prioritized

**Phase 4: Automation**
- N8N workflow builder
- Phone control integration
- Scheduling system

**Phase 5: Advanced Features**
- MCP client implementation
- Google Workspace integration
- Advanced analytics
- Team features (God Mode)

### 12.2 Design Handoff Specifications

**Assets to Provide:**
- High-fidelity mockups (Figma/Sketch)
- Interactive prototypes
- Icon set (SVG format)
- Design tokens (colors, spacing, typography)
- Animation specifications
- Component library

**Documentation:**
- Component usage guidelines
- State variations for each component
- Responsive behavior specifications
- Accessibility annotations

### 12.3 Testing Requirements

**Usability Testing:**
- Test BYOK configuration flow with 5+ users
- Test Ultra-Generalist Chat with complex multi-step tasks
- Test navigation between apps and context preservation
- Test free-to-pro upgrade flow

**A/B Testing Opportunities:**
- Onboarding flow variations
- Upgrade prompt timing and messaging
- Tool orchestration UI verbosity
- Context panel discoverability

**Accessibility Testing:**
- Screen reader (TalkBack) testing
- Keyboard navigation testing
- Color contrast validation
- Text scaling testing (up to 200%)

### 12.4 Analytics Implementation

**Track Key Events:**
- `app_install`: First app launch
- `byok_config_started`: User opens BYOK settings
- `byok_config_completed`: User saves API key
- `ai_interaction`: User sends request to AI
- `tool_used`: AI uses specific tool (web search, image gen, etc.)
- `app_opened`: User opens AI-native app
- `workflow_created`: User creates workflow
- `upgrade_initiated`: User starts upgrade flow
- `upgrade_completed`: User completes payment

**User Properties:**
- `plan_type`: free/pro/god_mode
- `configured_providers`: List of providers with keys
- `days_since_install`: Cohort analysis
- `total_ai_interactions`: Engagement level

### 12.5 Quality Assurance Checklist

**Functional Testing:**
- [ ] BYOK configuration for all 6 providers
- [ ] API key encryption/decryption
- [ ] Ultra-Generalist Chat with voice and text input
- [ ] Tool orchestration (multi-step tasks)
- [ ] Context preservation across apps
- [ ] Workflow creation and execution
- [ ] Free tier limits enforcement
- [ ] Upgrade flow (all payment methods)
- [ ] Usage dashboard accuracy
- [ ] Budget alerts triggering correctly

**UI/UX Testing:**
- [ ] All screens match design specifications
- [ ] Animations smooth (60fps)
- [ ] Touch targets meet minimum size
- [ ] Color contrast meets WCAG AA
- [ ] Text scaling works up to 200%
- [ ] Dark theme consistent throughout
- [ ] Empty states properly designed
- [ ] Error messages clear and actionable

**Performance Testing:**
- [ ] App launches in < 2 seconds
- [ ] Chat messages render instantly
- [ ] No lag when switching tabs
- [ ] Smooth scrolling in all lists
- [ ] Memory usage optimized
- [ ] Battery drain acceptable

**Security Testing:**
- [ ] API keys encrypted at rest
- [ ] Keys never logged or transmitted
- [ ] Secure API communication (HTTPS)
- [ ] Appwrite authentication working
- [ ] No sensitive data in analytics

---

## Conclusion

This UX Design Specification provides a comprehensive blueprint for building Blurr AI Assistant - BYOK. The design prioritizes:

1. **User Control**: BYOK architecture puts users in control of costs and privacy
2. **Transparency**: Real-time usage tracking and cost visibility
3. **Power**: Ultra-Generalist AI Agent can accomplish complex multi-step tasks
4. **Context**: Seamless experience across chat, apps, and workflows
5. **Trust**: Security indicators and privacy controls throughout

The design is intentionally built for power users who value control and transparency over simplicity. Every decision reinforces the core value proposition: **You control your AI.**

**Next Steps:**
1. Review and approve this specification
2. Create high-fidelity mockups in Figma
3. Build interactive prototype
4. Conduct usability testing
5. Begin Phase 2 implementation

---

**Document Status:** Complete ✅  
**Last Updated:** 2025-12-11  
**Prepared by:** Sally (UX Designer)  
**Approved by:** _Pending approval_

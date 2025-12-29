---
stepsCompleted: [1, 2, 3, 4]
status: 'complete'
completedAt: '2025-12-10'
inputDocuments:
  - docs/prd.md
  - docs/architecture.md
  - docs/project_context.md
project_name: 'Blurr Mobile AI Super-Assistant'
user_name: 'James Abraham'
date: '2025-12-10'
---

# Blurr Mobile AI Super-Assistant - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for Blurr Mobile AI Super-Assistant, decomposing the requirements from the PRD and Architecture into implementable stories.

---

## Requirements Inventory

### Functional Requirements (55 FRs)

#### 1. API Key Management (BYOK)
- FR1: Users can add API keys for OpenRouter provider
- FR2: Users can add API keys for AIMLAPI.com provider
- FR3: Users can add API keys for Groq provider
- FR4: Users can add API keys for Fireworks provider
- FR5: Users can add API keys for Together provider
- FR6: Users can view real-time credit/balance for connected providers
- FR7: Users can select which provider and model to use for AI calls
- FR8: Users can securely store API keys locally (encrypted)
- FR9: System alerts users when credit balance is low

#### 2. Voice Interaction (BYOK)
- FR10: Users can speak commands via BYOK STT (Whisper API)
- FR11: System can respond via BYOK TTS (OpenAI-compatible)
- FR12: Users can configure voice settings (speed, voice selection)

#### 3. Phone Automation (Preserve Existing)
- FR13: Users can trigger AI assistant via long-press home button
- FR14: AI can read screen content via Accessibility Service
- FR15: AI can click on screen elements via Accessibility Service
- FR16: AI can type text into input fields via Accessibility Service
- FR17: AI can swipe/scroll on screen via Accessibility Service
- FR18: AI can navigate between apps based on user commands

#### 4. Ultra-Generalist AI Agent
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

#### 5. Google Workspace Integration
- FR31: Users can authenticate with Google via OAuth
- FR32: AI can read and compose Gmail messages
- FR33: AI can create and read Google Calendar events
- FR34: AI can read and edit Google Drive files
- FR35: AI can read and edit Google Sheets data

#### 6. AI-Native Applications
- FR36: Users can access AI-native text editor
- FR37: Users can access AI-native spreadsheets generator/editor
- FR38: Users can access AI-native DAW for music creation
- FR39: Users can access AI-native video editor
- FR40: Users can access AI-native multimodal media generator
- FR41: Users can access AI-native learning platform

#### 7. Workflow Automation
- FR42: Users can create visual workflows using node-based editor
- FR43: Users can schedule workflows to run at specific times
- FR44: Users can trigger workflows based on events (Gmail, calendar)
- FR45: System can execute workflows in background
- FR46: Users can import/export workflows (n8n compatible)
- FR47: Users can connect to external n8n instances

#### 8. Subscription & Monetization
- FR48: Free users are limited to 10 agent runs per day
- FR49: Pro users ($14.99/mo) get unlimited runs and full access
- FR50: God Mode users ($29.99/mo) get private MCP hosting
- FR51: System enforces usage limits with graceful degradation
- FR52: Users can manage subscription via in-app purchases

#### 9. System & Administrative
- FR53: Users can view conversation history
- FR54: System stores data locally with sync to Appwrite
- FR55: System provides clear error messages with recovery options

---

### Non-Functional Requirements (20 NFRs)

#### Performance (5 NFRs)
- NFR-P1: AI response latency P95 <3 seconds
- NFR-P2: App cold start <3 seconds
- NFR-P3: UI frame rate 60fps minimum
- NFR-P4: Memory usage <300MB average
- NFR-P5: Accessibility Service latency <100ms per action

#### Security (4 NFRs)
- NFR-S1: API key encryption AES-256 at rest (Android Keystore)
- NFR-S2: Network security TLS 1.3 minimum
- NFR-S3: No key transmission (never sent to dev servers)
- NFR-S4: Session management with secure token refresh

#### Privacy (3 NFRs)
- NFR-PR1: Keys stored locally only (no cloud sync of keys)
- NFR-PR2: Conversation local-first (Appwrite sync optional)
- NFR-PR3: Analytics opt-in only

#### Reliability (4 NFRs)
- NFR-R1: Crash-free rate 99.5%+
- NFR-R2: Accessibility Service uptime 99.9%+
- NFR-R3: Graceful degradation on provider failure
- NFR-R4: Workflow execution 95%+ success rate

#### Compatibility (3 NFRs)
- NFR-C1: Android version 7.0 - 15 (API 24-35)
- NFR-C2: Device diversity (Top 20 Android devices)
- NFR-C3: OEM skin support (MIUI, OneUI, ColorOS)

#### Integration (4 NFRs)
- NFR-I1: Multi-provider support (5+ AI providers)
- NFR-I2: OAuth reliability 99%+ auth success
- NFR-I3: MCP compliance (full spec support as client)
- NFR-I4: n8n compatibility (import/export workflows)

---

### Additional Requirements (From Architecture)

#### Brownfield Constraints
- DO NOT MODIFY: ScreenInteractionService.kt
- DO NOT MODIFY: MainActivity.kt home button logic
- REFACTOR CAREFULLY: ConversationalAgentService.kt for BYOK/MCP

#### Migration Requirements
- Firebase Auth → Appwrite Auth (incremental)
- Firebase Firestore → Appwrite Database
- Picovoice → BYOK STT/TTS

#### New Infrastructure
- Appwrite SDK integration
- MCP client implementation (custom Kotlin)
- WorkManager for background tasks
- EncryptedDataStore for API keys

---

### FR Coverage Map

| FR | Epic | Description |
|----|------|-------------|
| FR1-9 | Epic 1 | BYOK API key management |
| FR10-12 | Epic 2 | BYOK Voice interaction |
| FR13-18 | Epic 0 | Phone Automation (EXISTING) |
| FR19-30 | Epic 3 | Ultra-Generalist AI Agent |
| FR31-35 | Epic 4 | Google Workspace Integration |
| FR36-41 | Epic 5 | AI-Native Applications |
| FR42-47 | Epic 6 | Workflow Automation |
| FR48-52 | Epic 7 | Subscriptions & Monetization |
| FR53-55 | Epic 1 | System & Administrative |

**Coverage:** 55/55 FRs mapped (100%)

---

## Epic List

### Epic 0: Phone Automation (EXISTING - Preserve)
Users can control their phone via AI using accessibility features.

**FRs covered:** FR13, FR14, FR15, FR16, FR17, FR18
**Status:** EXISTING — Integrate with new epics, DO NOT REBUILD

---

### Epic 1: BYOK Foundation
Users can configure their own AI providers and use the app with their own API keys.

**FRs covered:** FR1, FR2, FR3, FR4, FR5, FR6, FR7, FR8, FR9, FR53, FR54, FR55
**Phase:** 0 (First deliverable)

### Story 1.1: Appwrite Auth Migration
As a user,
I want to create an account and login with Appwrite,
So that I can securely access my personal settings.

**Acceptance Criteria:**
**Given** I am a new user
**When** I tap "Create Account" and enter email/password
**Then** an account is created in Appwrite
**And** I am logged in and redirected to home screen
**And** existing Firebase auth is replaced

### Story 1.2: Encrypted API Key Storage
As a user,
I want my API keys stored securely with encryption,
So that my credentials are protected.

**Acceptance Criteria:**
**Given** I save an API key
**When** the key is stored locally
**Then** it is encrypted with AES-256 using Android Keystore
**And** the key is never transmitted to external servers
**And** it is stored in EncryptedSharedPreferences

### Story 1.3: Add OpenRouter API Key
As a user,
I want to add my OpenRouter API key,
So that I can use OpenRouter models.

**Acceptance Criteria:**
**Given** I am on the BYOK settings screen
**When** I enter my OpenRouter API key and tap Save
**Then** the key is validated with a test call
**And** the key is encrypted and stored locally

### Story 1.4: Add Multiple Provider Keys
As a user,
I want to add keys for AIMLAPI, Groq, Fireworks, and Together,
So that I can choose between providers.

**Acceptance Criteria:**
**Given** I am on the BYOK settings screen
**When** I tap a provider and enter my API key
**Then** the key is validated and stored
**And** I can see all my connected providers

### Story 1.5: View Provider Balance
As a user,
I want to see my real-time credit balance for each provider,
So that I know when I need to add credits.

**Acceptance Criteria:**
**Given** I have a valid API key for a provider
**When** I view the BYOK settings
**Then** I see my current balance for each provider
**And** balances refresh every 30 seconds

### Story 1.6: Model Selection
As a user,
I want to select which provider and model to use,
So that I can control my AI costs and performance.

**Acceptance Criteria:**
**Given** I have connected providers
**When** I tap "Select Model"
**Then** I see available models grouped by provider
**And** I can set a default model for conversations

### Story 1.7: Low Balance Alerts
As a user,
I want to be alerted when my balance is low,
So that I can add credits before running out.

**Acceptance Criteria:**
**Given** my provider balance falls below $5
**When** I check or the background poll detects it
**Then** I see a warning notification
**And** I can tap to go to the provider's site

### Story 1.8: Conversation History
As a user,
I want to view my past conversations,
So that I can reference previous AI interactions.

**Acceptance Criteria:**
**Given** I have had conversations with the AI
**When** I go to History
**Then** I see a list of past conversations
**And** I can tap to view full conversation

### Story 1.9: Error Handling & Recovery
As a user,
I want clear error messages with recovery options,
So that I know what went wrong and how to fix it.

**Acceptance Criteria:**
**Given** an error occurs (e.g., invalid key, rate limit)
**When** the error is displayed
**Then** I see a clear message explaining the issue
**And** I see suggested actions to resolve it

---

### Epic 2: BYOK Voice Interaction
Users can speak commands and hear AI responses using their own voice API keys.

**FRs covered:** FR10, FR11, FR12
**Phase:** 0 (Voice-enabled assistant)

### Story 2.1: STT Integration (Whisper)
As a user,
I want to speak to the app using my STT provider,
So that I can interact hands-free.

**Acceptance Criteria:**
**Given** I have populated the STT API key
**When** I tap the microphone button
**Then** my audio is streamed to the Whisper API
**And** the transcribed text appears in the input field

### Story 2.2: TTS Integration
As a user,
I want the AI to speak back to me using my TTS provider,
So that I can hear responses.

**Acceptance Criteria:**
**Given** I have populated the TTS API key
**When** the AI sends a text response
**Then** the text is sent to the TTS API
**And** the audio plays automatically

### Story 2.3: Voice Settings
As a user,
I want to configure voice speed and selection,
So that the experience matches my preference.

**Acceptance Criteria:**
**Given** I am in Voice Settings
**When** I select a voice or adjust speed slider
**Then** the settings are saved locally
**And** subsequent TTS calls use these settings

---

### Epic 3: Ultra-Generalist AI Agent
Users can chat with a powerful AI that can use multiple tools to accomplish complex tasks.

**FRs covered:** FR19, FR20, FR21, FR22, FR23, FR24, FR25, FR26, FR27, FR28, FR29, FR30
**Phase:** 1 (Core agent functionality)

### Story 3.1: Unified Chat UI
As a user,
I want a clean chat interface that supports text and rich media,
So that I can interact with the agent comfortably.

**Acceptance Criteria:**
**Given** I open the chat screen
**When** I send a message
**Then** it appears in a bubble
**And** the AI response streams in real-time
**And** markdown is rendered correctly

### Story 3.2: Tool Orchestration Engine
As a user,
I want the AI to be able to determine when to use tools,
So that it can answer complex questions.

**Acceptance Criteria:**
**Given** I ask a question requiring a tool (e.g. "Search for...")
**When** the AI processes the prompt
**Then** it detects the intent and selects the correct tool
**And** it executes the tool and uses the output in its response

### Story 3.3: Web Search Tool
As a user,
I want the AI to search the web,
So that I get up-to-date information.

**Acceptance Criteria:**
**Given** I ask about current events
**When** the AI invokes the search tool (Tavily/Exa)
**Then** results are retrieved
**And** the AI summarizes the findings with citations

### Story 3.4: Image Generation Tool
As a user,
I want to generate images from text,
So that I can create visual content.

**Acceptance Criteria:**
**Given** I ask "Generate an image of a cat"
**When** the agent calls the image tool (Flux/SD3)
**Then** the image is generated via API
**And** displayed in the chat stream

### Story 3.5: Video & Media Tools
As a user,
I want to generate video and audio,
So that I can create multimedia.

**Acceptance Criteria:**
**Given** I ask for a video or song
**When** the agent calls the video (Kling) or audio (Suno) tool
**Then** media is generated
**And** displayed/played in the chat

### Story 3.6: Tool Registry & Reusable Tools
As a user,
I want to save successful tool chains,
So that I can reuse them later.

**Acceptance Criteria:**
**Given** an AI has successfully executed a complex sequence
**When** I verify the output
**Then** I can "Save as Tool"
**And** name it for future use

### Story 3.7: MCP Client Integration
As a user,
I want the app to connect to MCP servers,
So that I can extend its capabilities.

**Acceptance Criteria:**
**Given** I have a running MCP server URL
**When** I connect in settings
**Then** the server's tools are discovered
**And** the agent can invoke them during chat

### Story 3.8: Document Generation
As a user,
I want the AI to create PPT structure, PDFs, or Infographics,
So that I can be productive.

**Acceptance Criteria:**
**Given** I ask for a presentation outline or PDF report
**When** the agent processes the request
**Then** it generates the file structure
**And** provides a download/open link

---

### Epic 4: Google Workspace Integration
Users can have AI read/write their Gmail, Calendar, Drive, and Sheets.

**FRs covered:** FR31, FR32, FR33, FR34, FR35
**Phase:** 1 (Productivity integrations)

### Story 4.1: Google OAuth Flow
As a user,
I want to link my Google account securely,
So that I can grant access to my workspace data.

**Acceptance Criteria:**
**Given** I am in Settings > Integrations
**When** I tap "Connect Google Workspace"
**Then** the standard Google OAuth consent screen appears
**And** upon approval, my tokens are securely stored locally

### Story 4.2: Gmail Integration
As a user,
I want the AI to read and draft emails,
So that I can manage my inbox faster.

**Acceptance Criteria:**
**Given** I ask "Summarize my last 5 emails"
**When** the agent accesses the Gmail tool
**Then** summaries are displayed in chat
**And** I can ask it to "Draft a reply" which creates a draft

### Story 4.3: Calendar Integration
As a user,
I want the AI to manage my schedule,
So that I don't miss appointments.

**Acceptance Criteria:**
**Given** I ask "What's on my calendar today?"
**When** the agent accesses the Calendar tool
**Then** my events are listed
**And** I can say "Schedule a meeting with X" to create an event

### Story 4.4: Drive Integration
As a user,
I want the AI to find files in my Drive,
So that I can retrieve information quickly.

**Acceptance Criteria:**
**Given** I ask "Find the Q3 report in Drive"
**When** the agent accesses the Drive tool
**Then** it lists matching files
**And** can read the content of text-based files

### Story 4.5: Sheets Helper
As a user,
I want the AI to read and edit spreadsheets,
So that I can analyze data.

**Acceptance Criteria:**
**Given** I ask "Add a row to my Expense sheet"
**When** the agent accesses the Sheets tool
**Then** the data is appended correctly
**And** I can ask it to analyze existing data ranges

---

### Epic 5: AI-Native Applications
Users can access specialized AI-powered apps for content creation.

**FRs covered:** FR36, FR37, FR38, FR39, FR40, FR41
**Phase:** 2 (6 specialized apps)

### Story 5.1: AI Text Editor
As a user,
I want a writing-focused interface with AI assistance,
So that I can write long-form content.

**Acceptance Criteria:**
**Given** I open the Text Editor app
**When** I type or ask AI to "Continue writing"
**Then** the AI generates context-aware text
**And** I can use slash commands for formatting

### Story 5.2: AI Spreadsheets
As a user,
I want a spreadsheet interface that understands natural language,
So that I can build data tables easily.

**Acceptance Criteria:**
**Given** I open the Spreadsheets app
**When** I describe a table structure (e.g. "CRM for sales")
**Then** the columns and initial data are generated
**And** formulas are auto-suggested

### Story 5.3: AI DAW (Music)
As a user,
I want a music creation interface,
So that I can compose songs with AI.

**Acceptance Criteria:**
**Given** I open the DAW app
**When** I specify genre and mood
**Then** multiple tracks (drums, bass, melody) are generated
**And** I can mix them in a timeline view

### Story 5.4: AI Video Editor
As a user,
I want to generate and edit videos in a timeline,
So that I can produce video content.

**Acceptance Criteria:**
**Given** I open the Video Editor
**When** I upload clips or generate them
**Then** I can arrange them on a timeline
**And** ask AI to "Add transitions" or "Color grade"

### Story 5.5: AI Media Generator
As a user,
I want a dedicated space for generating assets,
So that I can create images/audio without chatting.

**Acceptance Criteria:**
**Given** I open the Media Generator
**When** I select "Icon" or "Background" and prompt
**Then** 4+ variations are generated instantly
**And** I can save them to my gallery

### Story 5.6: AI Learning Platform
As a user,
I want to generate structured courses on any topic,
So that I can learn new skills.

**Acceptance Criteria:**
**Given** I ask to "Learn about Quantum Physics"
**When** the system generates a course
**Then** it creates modules, quizzes, and summaries
**And** tracks my progress through the material

---

### Epic 6: Workflow Automation
Users can create, schedule, and trigger automated workflows that run in background.

**FRs covered:** FR42, FR43, FR44, FR45, FR46, FR47
**Phase:** 3 (Automation engine)

### Story 6.1: Workflow Builder UI
As a user,
I want to visually drag and connect nodes,
So that I can build workflows without coding.

**Acceptance Criteria:**
**Given** I open the Workflow Builder
**When** I drag a "Trigger" node and connect it to an "Action" node
**Then** a line connects them
**And** I can configure properties for each node

### Story 6.2: Schedule Trigger
As a user,
I want to run workflows at specific times,
So that I can automate recurring tasks.

**Acceptance Criteria:**
**Given** I add a "Schedule" trigger node
**When** I set it to "Every morning at 9 AM"
**Then** the workflow executes automatically at that time
**And** I get a notification upon completion

### Story 6.3: Event Triggers
As a user,
I want workflows to run when something happens,
So that I can react to events like emails.

**Acceptance Criteria:**
**Given** I add an "Email Received" trigger
**When** a new email matches my criteria
**Then** the workflow starts automatically
**And** passes the email content to the first action

### Story 6.4: Background Execution
As a user,
I want workflows to run reliably in the background,
So that they work even when the app is closed.

**Acceptance Criteria:**
**Given** a scheduled workflow is due
**When** the app is not in the foreground
**Then** WorkManager executes the task
**And** results are logged for later review

### Story 6.5: Import/Export (n8n)
As a user,
I want to share my workflows or use existing n8n JSON,
So that I don't have to start from scratch.

**Acceptance Criteria:**
**Given** I have an n8n workflow JSON file
**When** I tap "Import"
**Then** the visual builder renders the nodes correctly
**And** I can run it locally

---

### Epic 7: Subscription & Monetization
Users can choose subscription tiers and unlock premium features.

**FRs covered:** FR48, FR49, FR50, FR51, FR52
**Phase:** 4 (Business model)

### Story 7.1: Free Tier Limits
As a user,
I want to use the app for free with limits,
So that I can try it before buying.

**Acceptance Criteria:**
**Given** I am on the Free plan
**When** I try to run my 11th agent task of the day
**Then** I see a "Limit Reached" dialog
**And** am prompted to upgrade

### Story 7.2: Pro Subscription
As a user,
I want to upgrade to Pro for unlimited access,
So that I can use the app without restrictions.

**Acceptance Criteria:**
**Given** I tap "Upgrade to Pro"
**When** I complete the Google Play purchase
**Then** my account status updates instantly
**And** limits are removed

### Story 7.3: God Mode Subscription
As a user,
I want God Mode features like private MCP,
So that I get the ultimate experience.

**Acceptance Criteria:**
**Given** I upgrade to God Mode
**When** I authenticate
**Then** I gain access to "Private MCP Hosting" settings
**And** have priority support

### Story 7.4: Usage Tracking
As a user,
I want to see my usage stats,
So that I know how much I'm using the service.

**Acceptance Criteria:**
**Given** I am in Subscription settings
**When** I view my dashboard
**Then** I see "X/10 runs used today" (if Free)
**Or** "Unlimited access active" (if Pro)

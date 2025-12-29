# Story 4.12: Infographic Generation - Implementation Plan

## Overview

Implement infographic generation with **two options**:
1. **AI Image Generation** (Premium): Using Nano Banana Pro model via configured provider
2. **Data Visualization** (Basic): Using D3.js for programmatic chart/infographic creation

The AI agent will **ask the user mid-work** which option they prefer before generating.

---

## Implementation Phases

### Phase 1: AI Question System (PRIORITY 1 - DO NOW)
**Goal**: Allow AI agent to pause work and ask user questions mid-conversation

**Requirements**:
- Agent can pause current task execution
- Present question to user with options
- Wait for user response
- Resume work with user's choice
- Update system prompt to inform agent of this capability

**Use Cases**:
- Choose between Nano Banana Pro vs D3.js for infographics
- Get clarification on requirements
- Ask for additional data or preferences
- Confirm destructive actions

**Implementation**:
- Add `ask_user` function/tool for the agent
- Update system prompt to document this capability
- Add UI component to display agent questions
- Handle user responses and pass back to agent

---

### Phase 2: Shell Enhancement (PRIORITY 2 - NEXT COMMAND)
**Goal**: Support both Python AND JavaScript execution in the shell

**Current State**:
- PythonShellTool uses Chaquopy (Python-only)
- Only Python libraries supported

**Desired State**:
- Support Python execution (via Chaquopy)
- Support JavaScript execution (via separate JS engine)
- Unified interface for agent
- Pre-installed libraries for both languages

**Reference**: LemonAI's shell (see `lemonai-entire-repo.md` and `lemonaishell-infochat.md`)
- **Note**: Do NOT use Docker-dependent features
- **Note**: Keep it simple - just add JS execution capability
- **Note**: Don't over-engineer based on LemonAI reference

**JS Engine Options for Android**:
1. **J2V8** - V8 JavaScript engine for Android
2. **Rhino** - Mozilla's JS engine for JVM
3. **QuickJS** - Lightweight JS engine
4. **JavaScriptCore** (via AndroidJSCore)

**Recommended**: J2V8 or Rhino for Android compatibility

---

### Phase 3: Story 4.12 Implementation (PRIORITY 3 - THIRD COMMAND)

#### Part A: AI Image Generation (Nano Banana Pro)
**Goal**: Use existing image generation API with Nano Banana Pro model

**Requirements**:
- Use already-implemented image generation tool
- Specify Nano Banana Pro model
- Optimized prompts for infographic generation
- Support for data visualization requests in plain English

**Model Details**:
- **Name**: Nano Banana Pro
- **Capability**: Best non-AI-slop image generation
- **Perfect for**: Infographics, data visualizations, charts
- **Available on**: OpenRouter, AIMLAPI.com, Together AI, etc.
- **Approach**: Natural language prompts → high-quality infographics

**Example Flow**:
```
User: "Create an infographic about climate change"
Agent: Asks user → "Nano Banana Pro (AI) or D3.js (Basic)?"
User: "Nano Banana Pro"
Agent: Calls image_generation with Nano Banana Pro model
Result: Beautiful infographic image
```

#### Part B: D3.js Data Visualization (Basic Option)
**Goal**: Programmatic infographic/chart creation using D3.js

**Requirements**:
- Add D3.js to pre-installed JS libraries
- **IMPORTANT**: NOT under Chaquopy (Chaquopy is Python-only)
- Add to JS engine's library system
- Provide comprehensive examples in shell guide
- Support common chart types (bar, line, pie, scatter, etc.)

**D3.js Capabilities**:
- Bar charts, line charts, pie charts
- Scatter plots, heatmaps, treemaps
- Network graphs, hierarchies
- Geographic maps
- Custom SVG visualizations
- Interactive charts

**Example Flow**:
```
User: "Create a bar chart showing Q4 sales"
Agent: Asks user → "Nano Banana Pro (AI) or D3.js (Basic)?"
User: "D3.js"
Agent: Calls shell with D3.js code
Result: SVG/PNG bar chart
```

#### Part C: Default Behavior - Always Ask
**Requirement**: Whenever user requests infographic generation, agent MUST ask which method to use

**Implementation**:
- Update `generate_infographic` tool description
- Instruct agent to ALWAYS use `ask_user` before generating
- Provide clear options:
  - **Option 1**: "Nano Banana Pro (AI-generated, best quality)"
  - **Option 2**: "D3.js (Basic data visualization, programmatic)"

---

## Technical Architecture

### Current Architecture (Before Changes)
```
User → Agent → Tools:
  - image_generation (AI models)
  - python_shell (Python only via Chaquopy)
  - web_search, phone_control, etc.
```

### New Architecture (After Changes)
```
User ↔ Agent (can ask questions mid-work) → Tools:
  - ask_user (NEW - pause and ask questions)
  - image_generation (enhanced with Nano Banana Pro)
  - unified_shell (NEW - Python + JavaScript support)
    ├── Python execution (Chaquopy)
    └── JavaScript execution (J2V8/Rhino)
  - web_search, phone_control, etc.
```

---

## File Changes Required

### Phase 1: AI Question System
1. **New Tool**: `app/src/main/java/com/blurr/voice/tools/AskUserTool.kt`
   - Implements Tool interface
   - Pauses agent execution
   - Displays question UI
   - Returns user response

2. **UI Component**: `app/src/main/res/layout/dialog_agent_question.xml`
   - Question text
   - Multiple choice options (2-4 options)
   - User selection handling

3. **System Prompt**: `app/src/main/assets/prompts/system_prompt.md`
   - Document `ask_user` tool
   - Provide usage examples
   - Explain when to use it

4. **Agent Service**: `app/src/main/java/com/blurr/voice/agents/ConversationalAgent.kt`
   - Handle ask_user tool calls
   - Pause/resume execution
   - UI interaction

---

### Phase 2: Shell Enhancement
1. **Rename**: `PythonShellTool.kt` → `UnifiedShellTool.kt`
   - Support both Python and JavaScript
   - Detect language from code
   - Route to appropriate executor

2. **New Executor**: `JavaScriptExecutor.kt`
   - Use J2V8 or Rhino
   - Execute JS code
   - Return results

3. **Dependencies**: `app/build.gradle.kts`
   - Add JS engine dependency (e.g., J2V8)
   - Keep Chaquopy for Python

4. **Guide**: `app/src/main/assets/prompts/unified_shell_guide.md`
   - Python examples (keep existing)
   - JavaScript examples (add new)
   - D3.js examples (add comprehensive)

---

### Phase 3: Story 4.12
1. **New Tool**: `app/src/main/java/com/blurr/voice/tools/GenerateInfographicTool.kt`
   - ALWAYS calls `ask_user` first
   - Routes to image_generation OR unified_shell
   - Handles both paths

2. **Dependencies**: `app/build.gradle.kts`
   - Add D3.js as JS library (NOT Chaquopy)
   - Add any required JS charting libraries

3. **Examples**: `unified_shell_guide.md`
   - D3.js bar charts
   - D3.js line charts
   - D3.js pie charts
   - Complex infographics
   - SVG export

---

## Comparison: Nano Banana Pro vs D3.js

| Feature | Nano Banana Pro (AI) | D3.js (Basic) |
|---------|----------------------|---------------|
| **Method** | AI image generation | Programmatic visualization |
| **Quality** | Best (non-AI-slop) | Good (clean, precise) |
| **Flexibility** | Natural language prompts | Code-based (precise control) |
| **Speed** | Depends on API (~5-30 sec) | Fast (~1-3 sec) |
| **Cost** | Uses user's API credits | Free (local execution) |
| **Best For** | Creative infographics, marketing | Data charts, technical visualizations |
| **Customization** | Via prompts | Full programmatic control |
| **Output** | PNG/JPG image | SVG/PNG (programmatic) |

---

## User Experience Flow

### Scenario 1: User Requests Infographic
```
User: "Create an infographic about renewable energy"

Agent: 🤔 "I can create this infographic using:
        1. Nano Banana Pro (AI-generated, highest quality)
        2. D3.js (Basic data visualization)
        Which would you prefer?"

User: [Selects "Nano Banana Pro"]

Agent: ✅ [Generates beautiful AI infographic using image_generation]
       "Here's your infographic! [image preview]"
```

### Scenario 2: Data Chart Request
```
User: "Show Q4 sales data as a bar chart"

Agent: 🤔 "I can create this chart using:
        1. Nano Banana Pro (AI-generated, stylized)
        2. D3.js (Basic data visualization, precise)
        Which would you prefer?"

User: [Selects "D3.js"]

Agent: ✅ [Executes D3.js code via unified_shell]
       "Here's your bar chart! [chart image]"
```

---

## LemonAI Reference Notes

**Files to Review**:
- `lemonai-entire-repo.md` - Full LemonAI codebase
- `lemonaishell-infochat.md` - Shell implementation details

**Key Insights to Extract**:
- How LemonAI handles Python + JS execution
- Library management approach
- Error handling patterns
- Security considerations

**What NOT to Copy**:
- ❌ Docker-dependent features
- ❌ Desktop-specific implementations
- ❌ Over-engineered solutions
- ❌ Features that won't work on Android

**What TO Adapt**:
- ✅ Python + JS execution pattern
- ✅ Unified interface approach
- ✅ Library pre-installation strategy
- ✅ Simple, clean architecture

---

## Implementation Order (As Requested)

### 1. NOW: AI Question System ✅
- Implement `ask_user` tool
- Update system prompt
- Add UI components
- Test with simple questions

**Success Criteria**:
- Agent can ask user questions mid-work
- User can respond with choices
- Agent receives response and continues
- Works seamlessly in conversation flow

---

### 2. NEXT COMMAND: Shell Enhancement
- Add JavaScript execution capability
- Keep Python execution (Chaquopy)
- Create unified interface
- Update documentation

**Success Criteria**:
- Can execute Python code (existing)
- Can execute JavaScript code (new)
- Both work through single tool
- No breaking changes to existing Python functionality

---

### 3. THIRD COMMAND: Story 4.12 Implementation
- Add Nano Banana Pro support
- Add D3.js with comprehensive examples
- Create `generate_infographic` tool
- Always ask user for preference

**Success Criteria**:
- User can choose Nano Banana Pro OR D3.js
- Both methods work correctly
- Agent always asks before generating
- High-quality infographics produced

---

## Success Metrics

### Phase 1 (AI Questions)
- ✅ Agent can ask questions
- ✅ User can respond
- ✅ Conversation flow uninterrupted
- ✅ Works across all tools

### Phase 2 (Shell)
- ✅ Python execution works (unchanged)
- ✅ JavaScript execution works (new)
- ✅ D3.js pre-installed
- ✅ Comprehensive examples

### Phase 3 (Story 4.12)
- ✅ Nano Banana Pro generates infographics
- ✅ D3.js generates data visualizations
- ✅ User always gets to choose
- ✅ Both options produce high quality output

---

## Documentation Updates Needed

1. ✅ This plan document (STORY_4.12_INFOGRAPHIC_PLAN.md)
2. System prompt - Add `ask_user` capability
3. Unified shell guide - Python + JS examples
4. Story 4.12 completion doc - Both methods documented
5. User guide - Explain infographic options

---

## Next Actions

**READY TO IMPLEMENT PHASE 1 (AI QUESTION SYSTEM)!**

Awaiting your confirmation to proceed with:
1. Creating `AskUserTool.kt`
2. Adding UI components
3. Updating system prompt
4. Testing the feature

Then we'll move to Phase 2 (Shell Enhancement) and Phase 3 (Story 4.12) on your subsequent commands.

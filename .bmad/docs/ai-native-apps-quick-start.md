---
title: "AI-Native Apps - Quick Start Guide"
project: twent-Vfinal
phase: "AI-Native Apps Implementation"
version: 1.0
date: 2025-12-18
status: Planning
author: BMAD Method
---

# AI-Native Apps Phase - Quick Start Guide

**🎯 Goal**: Implement 6 AI-native apps within Twent, leveraging 75% of existing infrastructure.

**⏱️ Timeline**: 24 weeks (6 months)

**📦 Deliverables**: Text Editor, Spreadsheets, Media Canvas, DAW, Learning Platform, Video Editor

---

## 📚 Documentation Overview

This planning phase has generated 4 comprehensive documents:

### 1. **Product Requirements Document (PRD)** 
📄 `.bmad/docs/ai-native-apps-phase-prd.md`

**What's inside**:
- Executive summary and vision
- App prioritization and rationale
- Functional requirements for all 6 apps
- User journeys and success metrics
- Technical architecture overview
- Implementation roadmap (24 weeks)
- Risk assessment

**Use this for**: Understanding the "what" and "why" of each app.

---

### 2. **Epics Breakdown**
📄 `.bmad/docs/ai-native-apps-epics.md`

**What's inside**:
- 9 epics (1 foundation + 6 apps + integration + polish)
- Detailed stories for each epic
- Acceptance criteria per epic
- Implementation priority table
- Resource requirements
- Success metrics tracking

**Use this for**: Sprint planning and story estimation.

---

### 3. **Reusability Matrix**
📄 `.bmad/docs/ai-native-apps-reusability-matrix.md`

**What's inside**:
- Component reuse mapping (75% overall reuse)
- Tool usage matrix across all apps
- Flutter module scope (Media Canvas only)
- Database schema designs
- Pro gating strategy
- Export/integration patterns

**Use this for**: Technical implementation decisions and architecture reviews.

---

### 4. **Implementation Guide**
📄 `.bmad/docs/ai-native-apps-implementation-guide.md`

**What's inside**:
- Detailed technical specifications per app
- Code examples and patterns
- System prompt templates
- Data models (Kotlin)
- Key components breakdown

**Use this for**: Developer reference during implementation.

---

## 🚀 Getting Started

### Step 1: Review Documents (1-2 hours)
1. Start with **PRD** to understand the vision
2. Review **Epics** to see the breakdown
3. Check **Reusability Matrix** to understand existing components
4. Reference **Implementation Guide** for technical details

### Step 2: Set Up Development Environment
```bash
# Ensure you have:
- Android Studio (latest stable)
- Flutter SDK (for Media Canvas only)
- Python environment (for shell tools)
- Gradle 8.x
- Kotlin 1.9+
```

### Step 3: Begin with Epic 1 (Foundation)
**Duration**: 2 weeks

**Stories**:
1. Create `/apps/` directory structure
2. Build base components (`BaseAppActivity`, `BaseAppViewModel`, `AgentIntegration`)
3. Implement `ProGatingManager`
4. Create `ExportHelper`

**Deliverable**: Shared infrastructure ready for all apps

### Step 4: Implement Apps Sequentially
Follow the priority order:
1. **App #1: Text Editor** (3 weeks) - Priority 1
2. **App #2: Spreadsheets** (3 weeks) - Priority 2
3. **App #3: Media Canvas** (3 weeks) - Priority 3
4. **App #4: DAW** (3 weeks) - Priority 4
5. **App #5: Learning Platform** (3 weeks) - Priority 5
6. **App #6: Video Editor** (3 weeks) - Priority 6

### Step 5: Integration & Polish (6 weeks)
- Cross-app integration (Epic 8)
- Performance optimization (Epic 9)
- Testing and QA
- Launch preparation

---

## 🎯 Implementation Priorities

### Priority 1: Text Editor
**Why first?**
- Highest user demand
- Simplest implementation
- Clear monetization path
- Strong MVP for testing Pro gating

**Key Features**:
- Rich text editing (Markdown)
- AI rewrite, summarize, expand
- Document management
- Export (PDF, Google Docs)

**Tools Needed**: UniversalLLMService, AskUserTool, ComposioTool

---

### Priority 2: Spreadsheets
**Why second?**
- High business value
- Differentiating feature
- Builds on foundation from Text Editor

**Key Features**:
- Natural language generation
- Data manipulation
- AI analysis
- Chart generation

**Tools Needed**: PythonShellTool (critical), ComposioTool

---

### Priority 3: Media Canvas
**Why third?**
- Showcases entire tool ecosystem
- Requires Flutter module extension
- Unique visual experience

**Key Features**:
- Node-based workflow builder
- All media generation tools
- Agent-assisted workflow creation
- Templates

**Tools Needed**: All media tools, Flutter workflow editor

---

### Priority 4-6: DAW, Learning, Video Editor
**Why later?**
- More complex UIs (timelines, document viewers)
- Build on patterns from earlier apps
- Specialized use cases

---

## 📊 Success Metrics (Track These!)

### Development Metrics
- Story completion rate (target: 100% per sprint)
- Code coverage (target: >70%)
- Bug count (target: <5 P1 bugs per epic)
- Performance benchmarks (load time <2s, response time <10s)

### Post-Launch Metrics (per app)
- User adoption: 30% try at least one app
- Pro conversion: 10-15% of app users
- Session duration: 2-3x increase
- User ratings: 4.0+ average
- Retention: D7 >40%, D30 >20%

---

## 🛠️ Key Technologies

### Existing (Reuse)
- ✅ **UniversalLLMService**: BYOK for OpenRouter/AIMLAPI
- ✅ **ProviderKeyManager**: Secure API key storage
- ✅ **ToolRegistry**: 20+ tools available
- ✅ **Jetpack Compose**: UI framework
- ✅ **Room DB**: Local storage
- ✅ **ComposioTool**: Google Workspace, social media integration
- ✅ **PythonShellTool**: Critical for data processing

### New (Build)
- 🆕 **BaseAppActivity**: Common app patterns
- 🆕 **AgentIntegration**: System prompt management per app
- 🆕 **ProGatingManager**: Subscription enforcement
- 🆕 **ExportHelper**: Export utilities
- 🆕 **App-specific UIs**: Rich text editor, table view, timelines, etc.

### Flutter (Media Canvas Only)
- ⚡ **fl_nodes**: Node-based canvas (existing)
- 🆕 **Media node definitions**: Extend for image/video/audio/music/3D nodes

---

## 💡 Best Practices

### 1. Maximize Reuse
- Always check if existing tool/component can be used
- Extend existing classes rather than creating new ones
- Follow established patterns (MVVM, Repository)

### 2. Consistent Pro Gating
- Use `ProGatingManager` for all subscription checks
- Display upgrade prompts with clear value props
- Track usage limits in SharedPreferences or Room DB

### 3. Agent Integration
- Use system prompt extensions (not new agents)
- Keep prompts focused on app-specific tasks
- Include context (selected text, current state) in prompts

### 4. Performance First
- Use background processing for heavy tasks
- Show progress indicators for all AI operations
- Cache media outputs, implement efficient file management

### 5. Test Early, Test Often
- Write unit tests for ViewModels and Repositories
- Integration test agent-tool interactions
- UAT with real users before launch

---

## 🚨 Common Pitfalls to Avoid

### ❌ Don't Overuse Flutter
- **Only Media Canvas needs Flutter** (for node-based UI)
- All other apps should use Kotlin/Compose
- Avoid Flutter for standard Android UIs

### ❌ Don't Duplicate Agent Logic
- Reuse `UniversalLLMService` for all apps
- Only extend system prompts, don't create new agent classes

### ❌ Don't Reinvent Tools
- Check existing 20+ tools before building new ones
- PythonShellTool can handle most data processing needs
- ComposioTool covers most external integrations

### ❌ Don't Ignore Pro Gating
- Implement limits from day 1
- Test free tier limitations thoroughly
- Ensure upgrade prompts are non-intrusive but clear

### ❌ Don't Skip Foundation
- Epic 1 is critical for all subsequent apps
- Rushing foundation = technical debt later
- Invest 2 full weeks in base components

---

## 📞 Decision Points

### When to Start?
**Wait for explicit user command**: "You shall not start coding without my command."

### Which App to Start With?
**Always Priority 1 (Text Editor)** unless explicitly instructed otherwise.

### How to Approach Flutter?
**Only for Media Canvas**. For all other apps, use Kotlin/Compose.

### When to Involve Pro Features?
**From the start**. Implement Pro gating in foundation (Epic 1), apply to each app during development.

---

## 📋 Pre-Implementation Checklist

Before starting Epic 1:

- [ ] All team members have reviewed PRD
- [ ] Epics and stories understood
- [ ] Reusability matrix reviewed (know what to reuse)
- [ ] Development environment set up
- [ ] Existing codebase explored (agent, tools, UI patterns)
- [ ] Flutter module tested (for Media Canvas)
- [ ] Pro subscription test account available
- [ ] BYOK API keys configured for testing

---

## 🎉 What Success Looks Like

### After 6 Months (24 weeks):
- ✅ 6 AI-native apps launched and stable
- ✅ 75% code reuse achieved (minimize duplication)
- ✅ 30%+ user adoption across apps
- ✅ 10-15% Pro conversion rate
- ✅ 4.0+ user rating per app
- ✅ Zero P0 bugs, <5 P1 bugs total
- ✅ Strong foundation for future apps

### Long-Term Vision:
- **Twent becomes AI-native productivity suite**
- **Users spend 3x more time in app**
- **Pro subscriptions drive sustainable revenue**
- **Platform showcases agent + tools architecture**
- **Community creates custom workflows/templates**

---

## 📚 Additional Resources

### Internal Documentation
- `/docs/project_context.md` - Current project context
- `/docs/prd.md` - Original PRD
- `/docs/epics.md` - Existing epics
- `/fl_nodes_docs.md` - Flutter workflow editor docs

### Code References
- `/app/src/main/java/com/twent/voice/tools/` - All existing tools
- `/app/src/main/java/com/twent/voice/ui/agent/AgentChatActivity.kt` - Agent UI pattern
- `/flutter_workflow_editor/` - Flutter module

### External References
- [Jetpack Compose](https://developer.android.com/jetpack/compose)
- [Room Database](https://developer.android.com/training/data-storage/room)
- [fl_nodes Package](https://pub.dev/packages/fl_nodes)
- [Composio Documentation](https://docs.composio.dev)

---

## 🤝 Ready to Begin?

**Current Status**: ✅ Planning Complete - Ready for Implementation

**Next Action**: **AWAIT USER COMMAND TO START IMPLEMENTATION**

Once you give the command, we'll begin with:
1. **Epic 1: Foundation** (2 weeks)
2. **Epic 2: Text Editor** (3 weeks)
3. Continue through all 6 apps...

**Questions?** 
- Need clarification on any document?
- Want to adjust priorities?
- Need more technical detail on a specific app?
- Ready to start coding?

Just let me know! 🚀

---

**Document Status**: ✅ Complete
**Planning Phase**: ✅ Complete
**Implementation Phase**: ⏸️ Awaiting User Command


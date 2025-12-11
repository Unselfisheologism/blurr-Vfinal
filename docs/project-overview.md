# Blurr (Panda) - Project Overview

> **🐼 Panda: Your Personal AI Phone Operator**  
> *"You touch grass. I'll touch your glass."*

## Executive Summary

Blurr is an Android application that serves as an AI-powered phone operator, capable of autonomously understanding natural language commands and operating the phone's UI to achieve them. The app is designed to make modern technology more accessible by acting as a personal assistant that can handle complex, multi-step tasks across different applications.

## Quick Reference

| Property | Value |
|----------|-------|
| **Application ID** | `com.blurr.voice` |
| **Min SDK** | 24 (Android 7.0) |
| **Target SDK** | 35 (Android 15) |
| **Language** | Kotlin 1.9.22 |
| **UI Framework** | Jetpack Compose |
| **Architecture** | Multi-agent system with Accessibility Service |

## Technology Stack

| Category | Technology | Purpose |
|----------|------------|---------|
| **Core** | Kotlin 1.9.22 | Primary language |
| **UI** | Jetpack Compose | Modern declarative UI |
| **Database** | Room | Local data persistence |
| **Networking** | OkHttp 5.0 | HTTP client |
| **Serialization** | Moshi, Gson, Kotlinx Serialization | JSON parsing |
| **Cloud Services** | Firebase Suite | Auth, Crashlytics, Firestore, Functions, Analytics, Remote Config |
| **AI/ML** | Google Generative AI | LLM integration |
| **Voice** | Picovoice Porcupine | Wake word detection |
| **TTS** | Google Cloud TTS | Text-to-speech (High quality voice via GCS Chirp) |
| **Automation** | UI Automator | Screen interaction |
| **Billing** | Google Play Billing | In-app purchases |

## Architecture Overview

Panda is built on a sophisticated multi-agent system:

```
┌─────────────────────────────────────────────────────────────────┐
│                        PANDA ARCHITECTURE                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌────────────────┐    ┌────────────────┐    ┌───────────────┐  │
│  │   TRIGGERS     │───▶│   THE BRAIN    │───▶│   ACTUATOR    │  │
│  │  (Wake Word,   │    │   (LLM/Gemini) │    │ (Accessibility│  │
│  │   UI Events)   │    │                │    │   Service)    │  │
│  └────────────────┘    └────────────────┘    └───────────────┘  │
│         │                     │                     │            │
│         │                     │                     │            │
│         ▼                     ▼                     ▼            │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                     OPERATOR AGENT                          │ │
│  │              (Executor with Notepad Memory)                 │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Core Components

- **Eyes & Hands (Actuator)**: Android Accessibility Service for reading screen hierarchy and performing touch gestures
- **The Brain**: LLM models (Gemini) for high-level reasoning, planning, and analysis
- **Operator Agent**: Executor with notepad memory for task execution

## Key Features

- 🧠 **Intelligent UI Automation**: Context-aware screen understanding with tap, swipe, and type actions
- 📢 **High Quality Voice**: Google Cloud Speech (Chirp) for natural TTS
- 🎯 **Wake Word Activation**: Picovoice Porcupine integration
- 🔐 **Firebase Integration**: Authentication, crash reporting, remote config
- 💾 **Local Persistence**: Room database for memories and settings

## Documentation Links

- [Source Tree Analysis](./source-tree-analysis.md)
- [Architecture Details](./architecture.md) _(To be generated)_
- [Development Guide](./development-guide.md)
- [Component Inventory](./component-inventory.md) _(To be generated)_

## Existing Documentation

| Document | Description |
|----------|-------------|
| [STT Implementation](./STT_IMPLEMENTATION.md) | Speech-to-text implementation details |
| [TTS Debug Mode](./TTS_DEBUG_MODE.md) | Text-to-speech debugging |
| [Trigger System](./TRIGGER_SYSTEM.md) | Wake word and trigger configuration |
| [Porcupine Setup](./PORCUPINE_SETUP.md) | Wake word engine setup |
| [Interactive Dialogue](./INTERACTIVE_DIALOGUE_SYSTEM.md) | Dialogue system implementation |
| [Speech Coordinator](./SPEECH_COORDINATOR_IMPLEMENTATION.md) | Speech coordination details |
| [Direct App Opening](./DIRECT_APP_OPENING.md) | App launching functionality |
| [Accessibility Disclosure](./ACCESSIBILITY_DISCLOSURE_IMPROVEMENTS.md) | Accessibility service disclosures |

## Getting Started

### Prerequisites
- Android Studio (latest version)
- Android device/emulator API 26+
- API keys configured in `local.properties`

### Quick Start
```bash
# Clone repository
git clone https://github.com/ayush0chaudhary/blurr.git
cd blurr

# Open in Android Studio, sync Gradle, run on device

# Enable Accessibility Service when prompted
```

### Environment Configuration
Create `local.properties` with:
```properties
GEMINI_API_KEYS=your_api_keys
GCLOUD_PROXY_URL=your_proxy_url
GCLOUD_PROXY_URL_KEY=your_key
```

---

*Generated by BMad Document Project Workflow on 2025-12-10*

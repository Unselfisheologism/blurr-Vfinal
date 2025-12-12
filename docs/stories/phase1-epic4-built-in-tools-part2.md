# Epic 4: Built-in Tools - Part 2 (Documents & Google Workspace)

**Epic ID**: EPIC-4-PART2  
**Priority**: P0  
**Status**: Ready for Development  
**Estimated Duration**: 1.5 weeks  

---

## Epic Overview

Implement document generation tools (PDF, PowerPoint, infographics) and Google Workspace integration (OAuth, Gmail, Calendar, Drive, Sheets).

---

## Stories

### Story 4.8: PDF Generator Tool
**Story ID**: STORY-4.8  
**Priority**: P0  
**Estimate**: 1 day  
**Dependencies**: Story 3.2  

#### Description
Implement PDF document generation tool using Android's built-in PDF library.

#### Acceptance Criteria
- [ ] PDFGeneratorTool implements Tool interface
- [ ] Can generate PDF from text content
- [ ] Supports basic formatting (headers, paragraphs, lists)
- [ ] Can include images in PDF
- [ ] Saves PDF to Downloads folder
- [ ] Returns file path for sharing

#### Technical Details
**Files to Create**:
- `app/src/main/java/com/blurr/voice/tools/documents/PDFGeneratorTool.kt`

```kotlin
class PDFGeneratorTool : Tool {
    override val name = "create_pdf"
    override val description = "Create a PDF document"
    override val parameters = listOf(
        ToolParameter("title", "string", "Document title", required = true),
        ToolParameter("content", "string", "Document content (markdown)", required = true),
        ToolParameter("images", "array", "Image paths to include", required = false)
    )
    
    override suspend fun execute(params: Map<String, Any>, context: List<ToolResult>): ToolResult {
        val title = params["title"] as String
        val content = params["content"] as String
        val images = params["images"] as? List<String> ?: emptyList()
        
        val pdfDocument = PdfDocument()
        val pageInfo = PdfDocument.PageInfo.Builder(595, 842, 1).create() // A4 size
        val page = pdfDocument.startPage(pageInfo)
        
        // Draw content
        val canvas = page.canvas
        drawTitle(canvas, title)
        drawContent(canvas, content)
        drawImages(canvas, images)
        
        pdfDocument.finishPage(page)
        
        val file = File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS), "${title}.pdf")
        pdfDocument.writeTo(FileOutputStream(file))
        pdfDocument.close()
        
        return ToolResult.success(name, mapOf("file_path" to file.absolutePath))
    }
}
```

#### Testing
- [ ] Generate simple text PDF
- [ ] Generate PDF with images
- [ ] Verify PDF can be opened
- [ ] Test long content pagination

---

### Story 4.9: PowerPoint Generator Tool
**Story ID**: STORY-4.9  
**Priority**: P0  
**Estimate**: 2 days  
**Dependencies**: Story 3.2  

#### Description
Implement PowerPoint presentation generation using Apache POI.

#### Acceptance Criteria
- [ ] PowerPointTool implements Tool interface
- [ ] Can create presentation from structured content
- [ ] Supports title slides, content slides, image slides
- [ ] Applies basic theme/styling
- [ ] Saves PPTX file
- [ ] Returns file path

#### Technical Details
**Files to Create**:
- `app/src/main/java/com/blurr/voice/tools/documents/PowerPointTool.kt`

**Dependencies**:
Add to `build.gradle.kts`:
```kotlin
dependencies {
    implementation("org.apache.poi:poi:5.2.3")
    implementation("org.apache.poi:poi-ooxml:5.2.3")
}
```

```kotlin
class PowerPointTool : Tool {
    override val name = "create_powerpoint"
    override val description = "Create a PowerPoint presentation"
    override val parameters = listOf(
        ToolParameter("title", "string", "Presentation title", required = true),
        ToolParameter("slides", "array", "Array of slide objects {title, content, image}", required = true)
    )
    
    override suspend fun execute(params: Map<String, Any>, context: List<ToolResult>): ToolResult {
        val ppt = XMLSlideShow()
        val title = params["title"] as String
        val slides = params["slides"] as List<Map<String, Any>>
        
        // Create title slide
        createTitleSlide(ppt, title)
        
        // Create content slides
        slides.forEach { slideData ->
            createContentSlide(ppt, slideData)
        }
        
        val file = File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS), "${title}.pptx")
        ppt.write(FileOutputStream(file))
        
        return ToolResult.success(name, mapOf("file_path" to file.absolutePath))
    }
}
```

#### Testing
- [ ] Generate simple presentation
- [ ] Create slides with images
- [ ] Verify PPTX opens correctly
- [ ] Test with different content types

---

### Story 4.10: Infographic Generator Tool
**Story ID**: STORY-4.10  
**Priority**: P1  
**Estimate**: 2 days  
**Dependencies**: Story 3.2  

#### Description
Implement infographic generation using Canvas drawing with templates.

#### Acceptance Criteria
- [ ] InfographicTool implements Tool interface
- [ ] Supports multiple templates (timeline, comparison, stats)
- [ ] Generates PNG/JPG image
- [ ] Accepts data and renders visually
- [ ] Returns image file path

#### Technical Details
**Files to Create**:
- `app/src/main/java/com/blurr/voice/tools/documents/InfographicTool.kt`
- `app/src/main/java/com/blurr/voice/tools/documents/InfographicTemplates.kt`

```kotlin
class InfographicTool : Tool {
    override val name = "create_infographic"
    override val description = "Create an infographic visualization"
    override val parameters = listOf(
        ToolParameter("template", "string", "timeline, comparison, stats", required = true),
        ToolParameter("title", "string", "Infographic title", required = true),
        ToolParameter("data", "object", "Data to visualize", required = true)
    )
    
    override suspend fun execute(params: Map<String, Any>, context: List<ToolResult>): ToolResult {
        val template = params["template"] as String
        val title = params["title"] as String
        val data = params["data"] as Map<String, Any>
        
        val bitmap = Bitmap.createBitmap(1080, 1920, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        
        when (template) {
            "timeline" -> drawTimelineInfographic(canvas, title, data)
            "comparison" -> drawComparisonInfographic(canvas, title, data)
            "stats" -> drawStatsInfographic(canvas, title, data)
        }
        
        val file = File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES), "${title}.png")
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, FileOutputStream(file))
        
        return ToolResult.success(name, mapOf("image_path" to file.absolutePath))
    }
}
```

#### Testing
- [ ] Generate timeline infographic
- [ ] Generate comparison infographic
- [ ] Generate stats infographic
- [ ] Verify image quality

---

### Story 4.13: Google OAuth Integration (Hybrid Approach - Part 1)
**Story ID**: STORY-4.13  
**Priority**: P0  
**Estimate**: 2 days  
**Dependencies**: None  
**Architecture**: Hybrid (Google OAuth FREE + Composio for other tools)

#### Description
Implement Google OAuth 2.0 authentication for FREE Workspace API access using user credentials (not project credentials).

**Cost Strategy**: 
- Google Workspace (Gmail, Calendar, Drive): Users sign in with their Google account
- Uses THEIR quotas (250 units/sec per user, 1M queries/day per user)
- **Cost: $0** regardless of user count ✅
- Covers 80% of integration usage for FREE

**This is Part 1 of the Hybrid Integration Strategy. Part 2 (Story 4.14) adds Composio for 2,000+ other tools.**

#### Acceptance Criteria
- [ ] OAuth login flow using Google Sign-In
- [ ] Requests required scopes (Gmail, Calendar, Drive, Sheets)
- [ ] Stores OAuth tokens securely
- [ ] Handles token refresh automatically
- [ ] User can revoke access in settings

#### Technical Details
**Files to Create**:
- `app/src/main/java/com/blurr/voice/auth/GoogleAuthManager.kt`
- `app/src/main/java/com/blurr/voice/ui/GoogleSignInActivity.kt`

**Dependencies**:
Add to `build.gradle.kts`:
```kotlin
dependencies {
    implementation("com.google.android.gms:play-services-auth:20.7.0")
    implementation("com.google.api-client:google-api-client-android:2.2.0")
}
```

```kotlin
class GoogleAuthManager(private val context: Context) {
    private val scopes = listOf(
        "https://www.googleapis.com/auth/gmail.readonly",
        "https://www.googleapis.com/auth/gmail.compose",
        "https://www.googleapis.com/auth/calendar",
        "https://www.googleapis.com/auth/drive.file",
        "https://www.googleapis.com/auth/spreadsheets"
    )
    
    suspend fun signIn(): Result<GoogleSignInAccount> {
        val signInOptions = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestEmail()
            .requestScopes(Scope(scopes[0]), *scopes.drop(1).map { Scope(it) }.toTypedArray())
            .build()
        
        val client = GoogleSignIn.getClient(context, signInOptions)
        // Launch sign-in intent
        return Result.success(/* account */)
    }
    
    fun getAccessToken(): String? {
        val account = GoogleSignIn.getLastSignedInAccount(context)
        return account?.let { getAccessToken(it) }
    }
    
    fun isSignedIn(): Boolean {
        return GoogleSignIn.getLastSignedInAccount(context) != null
    }
}
```

#### Testing
- [ ] Sign in with Google account
- [ ] Verify all scopes granted
- [ ] Access token retrieval works
- [ ] Token refresh automatic
- [ ] Sign out functionality

---

### Story 4.14: Composio Integration (Hybrid Approach - Part 2)
**Story ID**: STORY-4.14  
**Priority**: P0  
**Estimate**: 1 day  
**Dependencies**: Story 4.13  

#### Description
Integrate Composio SDK for 2,000+ tool integrations (Notion, Asana, Linear, Slack, Jira, GitHub, etc.).

**Cost Strategy**:
- Composio Scale Plan: $499/month (includes 5M calls)
- Expected usage: 2M calls/month (non-Google tools = 20% of usage)
- **Cost: $499/month = $6,000/year** ✅
- Covers Notion, Asana, Linear, and 2,000+ other tools

**Combined Cost (Story 4.13 + 4.14)**:
- Google Workspace: $0/year (OAuth user credentials)
- Composio: $6,000/year
- **Total: $6,000/year** ✅
- vs DIY: $266,000/year (98% savings!)

#### Acceptance Criteria
- [ ] Composio SDK integrated
- [ ] ComposioIntegrationManager created
- [ ] Can connect to Notion, Asana, Linear
- [ ] OAuth handled by Composio
- [ ] Automatic token refresh
- [ ] 2,000+ integrations available

#### Technical Details
**Files to Create**:
- `app/src/main/java/com/blurr/voice/integrations/ComposioIntegrationManager.kt`
- `app/src/main/java/com/blurr/voice/tools/composio/ComposioTool.kt`

**Dependencies**:
Add to `build.gradle.kts`:
```kotlin
dependencies {
    // Composio SDK
    implementation("dev.composio:composio-android:1.0.0") // Check actual version
    // OR use REST API directly
    implementation("com.squareup.retrofit2:retrofit:2.9.0")
    implementation("com.squareup.retrofit2:converter-gson:2.9.0")
}
```

**Sign up**: https://composio.dev (Scale Plan recommended)

```kotlin
class ComposioIntegrationManager(
    private val context: Context,
    private val apiKey: String
) {
    private val composioClient = ComposioClient(apiKey)
    
    suspend fun connectIntegration(
        userId: String,
        integrationName: String // "notion", "asana", "linear"
    ): Result<ConnectedAccount> {
        // Composio handles OAuth flow
        return composioClient.initiateConnection(userId, integrationName)
    }
    
    suspend fun executeAction(
        connectedAccountId: String,
        appName: String,
        actionName: String,
        params: Map<String, Any>
    ): Result<Any> {
        return composioClient.executeAction(
            connectedAccountId,
            appName,
            actionName,
            params
        )
    }
    
    suspend fun listAvailableIntegrations(): List<Integration> {
        return composioClient.listIntegrations()
    }
}

class ComposioTool(
    private val composioManager: ComposioIntegrationManager
) : Tool {
    override val name = "composio_integration"
    override val description = "Access 2,000+ integrations (Notion, Asana, Linear, etc.)"
    
    override suspend fun execute(params: Map<String, Any>): ToolResult {
        val appName = params["app"] as String // "notion", "asana", etc.
        val action = params["action"] as String
        val connectedAccountId = params["connected_account_id"] as String
        
        val result = composioManager.executeAction(
            connectedAccountId,
            appName,
            action,
            params
        )
        
        return if (result.isSuccess) {
            ToolResult.success(name, result.getOrNull().toString())
        } else {
            ToolResult.error(name, result.exceptionOrNull()?.message ?: "Unknown error")
        }
    }
}
```

#### Testing
- [ ] Connect to Notion
- [ ] Connect to Asana
- [ ] Connect to Linear
- [ ] Execute action via Composio
- [ ] List available integrations
- [ ] OAuth flow works

---

### Story 4.15: Gmail Tool (FREE via OAuth)
**Story ID**: STORY-4.15  
**Priority**: P0  
**Estimate**: 1 day  
**Dependencies**: Story 4.13  

#### Description
Implement Gmail tool for reading and composing emails using user's OAuth credentials (FREE).

#### Acceptance Criteria
- [ ] GmailTool implements Tool interface
- [ ] Can read recent emails (subject, from, body)
- [ ] Can search emails by query
- [ ] Can compose and send emails
- [ ] Can add attachments
- [ ] Handles authentication errors

#### Technical Details
**Files to Create**:
- `app/src/main/java/com/blurr/voice/tools/google/GmailTool.kt`

**Dependencies**:
```kotlin
implementation("com.google.apis:google-api-services-gmail:v1-rev20220404-2.0.0")
```

```kotlin
class GmailTool(
    private val authManager: GoogleAuthManager
) : Tool {
    override val name = "gmail"
    override val description = "Read and compose Gmail messages"
    override val parameters = listOf(
        ToolParameter("action", "string", "read, search, compose", required = true),
        ToolParameter("query", "string", "Search query or subject", required = false),
        ToolParameter("to", "string", "Recipient email", required = false),
        ToolParameter("subject", "string", "Email subject", required = false),
        ToolParameter("body", "string", "Email body", required = false)
    )
    
    override suspend fun execute(params: Map<String, Any>, context: List<ToolResult>): ToolResult {
        if (!authManager.isSignedIn()) {
            return ToolResult.error("Not signed in to Google")
        }
        
        val action = params["action"] as String
        
        return when (action) {
            "read" -> readEmails(params)
            "search" -> searchEmails(params)
            "compose" -> composeEmail(params)
            else -> ToolResult.error("Unknown action: $action")
        }
    }
    
    private suspend fun readEmails(params: Map<String, Any>): ToolResult {
        val service = buildGmailService()
        val messages = service.users().messages().list("me").setMaxResults(10).execute()
        
        val emails = messages.messages.map { msg ->
            val full = service.users().messages().get("me", msg.id).execute()
            mapOf(
                "subject" to getHeader(full, "Subject"),
                "from" to getHeader(full, "From"),
                "snippet" to full.snippet
            )
        }
        
        return ToolResult.success(name, mapOf("emails" to emails))
    }
    
    private suspend fun composeEmail(params: Map<String, Any>): ToolResult {
        val to = params["to"] as? String ?: return ToolResult.error("Recipient required")
        val subject = params["subject"] as? String ?: ""
        val body = params["body"] as? String ?: ""
        
        val service = buildGmailService()
        val email = createEmail(to, subject, body)
        service.users().messages().send("me", email).execute()
        
        return ToolResult.success(name, mapOf("status" to "sent"))
    }
}
```

#### Testing
- [ ] Read recent emails
- [ ] Search emails by keyword
- [ ] Compose and send email
- [ ] Handle OAuth errors

---

### Story 4.16: Google Calendar & Drive Tools (FREE via OAuth)
**Story ID**: STORY-4.16  
**Priority**: P1  
**Estimate**: 1 day  
**Dependencies**: Story 4.13  

#### Description
Implement Google Calendar and Drive tools using user's OAuth credentials (FREE).

**Note**: These use the same FREE OAuth approach as Gmail (Story 4.15).

#### Acceptance Criteria
- [ ] GoogleCalendarTool implements Tool interface
- [ ] Can list upcoming events
- [ ] Can create new calendar events
- [ ] Can search events by query
- [ ] Supports event details (time, location, attendees)

#### Technical Details
**Files to Create**:
- `app/src/main/java/com/blurr/voice/tools/google/GoogleCalendarTool.kt`

**Dependencies**:
```kotlin
implementation("com.google.apis:google-api-services-calendar:v3-rev20220715-2.0.0")
```

#### Testing
- [ ] List upcoming events
- [ ] Create calendar event
- [ ] Search events

---

#### Additional Acceptance Criteria (Calendar)
- [ ] Can list upcoming events
- [ ] Can create new calendar events
- [ ] Can search events by query

#### Additional Acceptance Criteria (Drive)
- [ ] Can list files in Drive
- [ ] Can upload files to Drive
- [ ] Can download files from Drive
- [ ] Can search files by name

---

### Story 4.15: Phone Control Tool
**Story ID**: STORY-4.15  
**Priority**: P0  
**Estimate**: 1 day  
**Dependencies**: Story 3.2  

#### Description
Create bridge tool that wraps existing ScreenInteractionService for phone control capabilities.

#### Acceptance Criteria
- [ ] PhoneControlTool implements Tool interface
- [ ] Can perform existing phone actions (tap, swipe, etc.)
- [ ] Wraps ScreenInteractionService methods
- [ ] Returns action results
- [ ] Handles accessibility service status

#### Technical Details
**Files to Create**:
- `app/src/main/java/com/blurr/voice/tools/phone/PhoneControlTool.kt`

```kotlin
class PhoneControlTool(
    private val context: Context
) : Tool {
    override val name = "phone_control"
    override val description = "Control phone interface (tap, swipe, open apps)"
    override val parameters = listOf(
        ToolParameter("action", "string", "tap, swipe, open_app, go_back, go_home", required = true),
        ToolParameter("x", "number", "X coordinate for tap", required = false),
        ToolParameter("y", "number", "Y coordinate for tap", required = false),
        ToolParameter("app_name", "string", "App name to open", required = false)
    )
    
    override suspend fun execute(params: Map<String, Any>, context: List<ToolResult>): ToolResult {
        if (!isAccessibilityEnabled()) {
            return ToolResult.error("Accessibility service not enabled")
        }
        
        val action = params["action"] as String
        
        return when (action) {
            "tap" -> performTap(params)
            "swipe" -> performSwipe(params)
            "open_app" -> openApp(params)
            "go_back" -> performGlobalAction(AccessibilityService.GLOBAL_ACTION_BACK)
            "go_home" -> performGlobalAction(AccessibilityService.GLOBAL_ACTION_HOME)
            else -> ToolResult.error("Unknown action")
        }
    }
}
```

#### Testing
- [ ] Perform tap action
- [ ] Perform swipe action
- [ ] Open app by name
- [ ] Navigate back/home
- [ ] Handle accessibility disabled

---

## Epic Acceptance Criteria

✅ **Document Generation**:
- [ ] PDF generation working (Story 4.10 - Already COMPLETE)
- [ ] PowerPoint generation working (Story 4.11 - Already COMPLETE)
- [ ] Infographic generation working (Story 4.12 - Already COMPLETE)
- [ ] Generated documents open correctly

✅ **Hybrid Integration Strategy** (NEW):
- [ ] Google OAuth works (Story 4.13) - **Cost: $0/year** ✅
- [ ] Composio integrated (Story 4.14) - **Cost: $6,000/year** ✅
- [ ] Gmail, Calendar, Drive via OAuth (Stories 4.15-4.16) - **FREE**
- [ ] 2,000+ integrations available via Composio
- [ ] **Total Cost: $6,000/year vs $266,000/year DIY (98% savings!)** 🎉

✅ **Phone Control**:
- [ ] Phone control tool wraps existing service
- [ ] Can be invoked by agent

---

## Integration Architecture Summary

### Hybrid Approach (Best of Both Worlds)

**Google Workspace (80% of usage) - FREE**:
- Users sign in with their Google account (OAuth)
- Uses THEIR quotas (not yours)
- Gmail, Calendar, Drive - $0 cost
- Stories 4.13, 4.15, 4.16

**Everything Else (20% of usage) - Composio**:
- Notion, Asana, Linear, Slack, Jira, GitHub, and 2,000+ tools
- Composio handles OAuth for all
- $499/month = $6,000/year
- Story 4.14

**Total Annual Cost**: $6,000  
**vs DIY**: $266,000/year  
**Savings**: 98% (or $260,000/year!)

---

**Total Estimate**: 7 developer-days (~1.5 weeks)

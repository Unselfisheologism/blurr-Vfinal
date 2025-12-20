# Google Workspace Integration - Complete Guide

## Overview

The Flutter workflow editor now includes full Google Workspace integration with OAuth authentication! Users can create workflows that interact with Gmail, Google Calendar, and Google Drive.

---

## ✅ What Was Implemented

### 1. Google Workspace Models
- **GoogleWorkspaceTool**: Model for Gmail, Calendar, Drive
- **GoogleWorkspaceAction**: Action definitions (send_email, create_event, etc.)
- **GoogleWorkspaceParameter**: Action parameter schemas

### 2. AppState Integration
- **loadGoogleWorkspaceTools()**: Loads available tools
- **getGoogleAuthStatus()**: Checks if user is authenticated
- **authenticateGoogleWorkspace()**: Triggers OAuth flow
- **executeGoogleWorkspaceAction()**: Executes Gmail/Calendar/Drive actions

### 3. UI Components
- **Google Workspace Node**: New node type in palette
- **Inspector Panel**: Shows authentication status with "Sign in with Google" button
- **Service/Action Dropdowns**: Select Gmail, Calendar, or Drive with specific actions
- **Parameter Editor**: JSON editor for action parameters

### 4. Execution Engine
- **_executeGoogleWorkspaceAction()**: Handles Google Workspace node execution
- **Authentication Check**: Throws NOT_AUTHENTICATED error if not signed in
- **Variable Resolution**: Supports {{ variable }} syntax in parameters

### 5. Kotlin Bridge
- **WorkflowEditorBridge.kt**: Complete bridge with all methods
- **getGoogleAuthStatus()**: Returns authentication status
- **authenticateGoogle()**: Launches GoogleSignInActivity
- **executeGoogleWorkspaceAction()**: Routes to GmailTool, GoogleCalendarTool, GoogleDriveTool

---

## 🔐 OAuth Authentication Flow

### User Experience:
1. User drags "Google Workspace" node onto canvas
2. Selects node → Inspector panel opens
3. **If not authenticated**: Shows orange warning box with "Sign in with Google" button
4. User clicks "Sign in with Google"
5. **Native OAuth popup** opens (via GoogleSignInActivity)
6. User selects Google account and grants permissions
7. Returns to workflow editor → Inspector shows service/action dropdowns
8. User configures Gmail/Calendar/Drive action
9. Executes workflow → Action runs successfully!

### Technical Flow:
```
Flutter UI → authenticateGoogle() → Platform Channel → Kotlin Bridge
   ↓
WorkflowEditorBridge.handleAuthenticateGoogle()
   ↓
Launches: Intent(GoogleSignInActivity::class.java)
   ↓
GoogleSignInActivity shows native OAuth popup
   ↓
User authenticates → GoogleAuthManager.isSignedIn() = true
   ↓
Flutter refreshes → Shows authenticated UI
```

---

## 📋 Available Google Workspace Actions

### Gmail (3 actions)
1. **send_email**: Send an email
   - Parameters: to, subject, body, cc, bcc
   
2. **read_emails**: Read emails from inbox
   - Parameters: max_results, query
   
3. **search_emails**: Search emails with query
   - Parameters: query, max_results

### Google Calendar (2 actions)
1. **create_event**: Create calendar event
   - Parameters: summary, start_time, end_time, description, location, attendees
   
2. **list_events**: List upcoming events
   - Parameters: max_results, time_min

### Google Drive (3 actions)
1. **upload_file**: Upload file to Drive
   - Parameters: file_path, name, folder_id
   
2. **list_files**: List files in Drive
   - Parameters: max_results, query
   
3. **share_file**: Share file with someone
   - Parameters: file_id, email, role

---

## 🚀 How to Use

### Example 1: Send Email via Gmail

1. **Add nodes**:
   - Manual Trigger
   - Google Workspace node

2. **Connect them**: Drag from trigger output to Google Workspace input

3. **Configure Google Workspace node**:
   - Service: Gmail
   - Action: send_email
   - Parameters:
   ```json
   {
     "to": "recipient@example.com",
     "subject": "Test from Workflow",
     "body": "This email was sent from my workflow!"
   }
   ```

4. **Execute workflow**: Click "Execute" button

5. **View results**: Check execution panel for success message

### Example 2: Create Calendar Event

1. **Configure Google Workspace node**:
   - Service: Google Calendar
   - Action: create_event
   - Parameters:
   ```json
   {
     "summary": "Team Meeting",
     "start_time": "2024-01-15T10:00:00-08:00",
     "end_time": "2024-01-15T11:00:00-08:00",
     "description": "Weekly team sync",
     "attendees": "john@company.com,sarah@company.com"
   }
   ```

### Example 3: Upload File to Drive

1. **Configure Google Workspace node**:
   - Service: Google Drive
   - Action: upload_file
   - Parameters:
   ```json
   {
     "file_path": "/storage/emulated/0/Download/report.pdf",
     "name": "Q4 Report.pdf"
   }
   ```

---

## 🔧 Integration Setup

### AndroidManifest.xml

Add WorkflowEditorActivity:
```xml
<activity
    android:name=".WorkflowEditorActivity"
    android:theme="@style/Theme.AppCompat.NoActionBar"
    android:configChanges="orientation|keyboardHidden|keyboard|screenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
    android:hardwareAccelerated="true"
    android:windowSoftInputMode="adjustResize"
    android:exported="false" />
```

### Launch from Settings

In your SettingsActivity:
```kotlin
binding.btnWorkflowEditor.setOnClickListener {
    startActivity(Intent(this, WorkflowEditorActivity::class.java))
}
```

Or add menu item:
```xml
<item
    android:id="@+id/menu_workflow_editor"
    android:title="Workflow Editor"
    android:icon="@drawable/ic_workflow" />
```

```kotlin
override fun onOptionsItemSelected(item: MenuItem): Boolean {
    return when (item.itemId) {
        R.id.menu_workflow_editor -> {
            startActivity(Intent(this, WorkflowEditorActivity::class.java))
            true
        }
        else -> super.onOptionsItemSelected(item)
    }
}
```

---

## 🧪 Testing

### Test 1: Authentication Flow

1. Open Workflow Editor
2. Add Google Workspace node
3. Select node → Inspector opens
4. Verify: Shows "Not Authenticated" warning
5. Click "Sign in with Google"
6. Verify: GoogleSignInActivity opens
7. Sign in with Google account
8. Verify: Inspector now shows service/action dropdowns
9. Verify: Success snackbar appears

### Test 2: Send Email Workflow

1. Create workflow:
   - Manual Trigger → Google Workspace
2. Configure:
   - Service: Gmail
   - Action: send_email
   - Parameters: `{"to": "your@email.com", "subject": "Test", "body": "Hello!"}`
3. Click "Execute"
4. Verify: Email sent successfully
5. Check your email inbox for the message

### Test 3: Create Calendar Event

1. Configure Google Workspace node:
   - Service: Google Calendar
   - Action: create_event
   - Parameters: Event details with start/end times
2. Execute workflow
3. Verify: Event appears in Google Calendar

### Test 4: Error Handling

1. Sign out from Google (Settings → Google Account)
2. Try to execute workflow with Google Workspace node
3. Verify: Error message shows "NOT_AUTHENTICATED"
4. Verify: Execution panel shows authentication error

---

## 🔍 Debugging

### Check Authentication Status

```kotlin
// In your Activity
val googleAuthManager = GoogleAuthManager(this)
val isSignedIn = googleAuthManager.isSignedIn()
Log.d("Auth", "Signed in: $isSignedIn")
```

### Test Bridge Methods

```kotlin
// Test getGoogleAuthStatus
val channel = MethodChannel(flutterEngine.dartExecutor, "com.twent.workflow_editor")
channel.invokeMethod("getGoogleAuthStatus", null) { result ->
    Log.d("Bridge", "Auth status: $result")
}
```

### Monitor Execution

Check Flutter logs:
```bash
adb logcat | grep -i "flutter\|workflow\|google"
```

Check Kotlin logs:
```bash
adb logcat | grep -i "WorkflowEditorBridge\|GoogleAuth"
```

---

## 🐛 Troubleshooting

### Issue: "Sign in with Google" button doesn't work

**Check:**
1. GoogleSignInActivity exists and is registered in AndroidManifest.xml
2. OAuth credentials configured in Google Cloud Console
3. SHA-1 fingerprint added to OAuth client

**Fix:**
```bash
# Get SHA-1 fingerprint
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Add to Google Cloud Console → APIs & Credentials → OAuth 2.0 Client IDs
```

### Issue: "NOT_AUTHENTICATED" error during execution

**Check:**
1. User actually signed in via GoogleSignInActivity
2. GoogleAuthManager.isSignedIn() returns true
3. Bridge method getGoogleAuthStatus returns true

**Fix:**
```kotlin
// Manually test authentication
val googleAuthManager = GoogleAuthManager(context)
if (!googleAuthManager.isSignedIn()) {
    // Launch sign-in
    startActivity(Intent(this, GoogleSignInActivity::class.java))
}
```

### Issue: Gmail/Calendar/Drive action fails

**Check:**
1. GmailTool, GoogleCalendarTool, GoogleDriveTool exist (from Story 4.15, 4.16)
2. Parameters are correctly formatted (JSON)
3. User has granted necessary scopes

**Fix:**
```kotlin
// Test tool directly
val gmailTool = com.twent.voice.tools.google.GmailTool(context, googleAuthManager)
val result = gmailTool.execute(mapOf(
    "action" to "send_email",
    "to" to "test@example.com",
    "subject" to "Test",
    "body" to "Test email"
), emptyList())
Log.d("Test", "Result: $result")
```

### Issue: OAuth popup doesn't appear

**Check:**
1. GoogleSignInActivity theme allows popup
2. Intent flags are correct
3. Activity not in background

**Fix in AndroidManifest.xml:**
```xml
<activity
    android:name=".activities.GoogleSignInActivity"
    android:theme="@style/Theme.AppCompat.Light.NoActionBar"
    android:exported="false" />
```

---

## 📚 Code Reference

### Files Created/Modified

**Flutter Side:**
- `lib/models/google_workspace_tool.dart` (300+ lines)
- `lib/state/app_state.dart` (added Google methods)
- `lib/services/platform_bridge.dart` (added Google methods)
- `lib/services/execution_engine.dart` (added Google execution)
- `lib/widgets/node_palette.dart` (added Google node)
- `lib/widgets/node_inspector.dart` (added Google inspector UI)
- `lib/widgets/node_widget.dart` (added Google styling)

**Kotlin Side:**
- `WorkflowEditorBridge.kt` (complete bridge, 450+ lines)
- `WorkflowEditorActivity.kt` (launcher activity)
- `activity_workflow_editor.xml` (layout)

**Total**: ~1,500 lines of code added

---

## 🎉 Summary

### What Users Get:
- ✅ Native Google OAuth popup for authentication
- ✅ Gmail integration (send, read, search emails)
- ✅ Google Calendar integration (create events, list events)
- ✅ Google Drive integration (upload, list, share files)
- ✅ Visual authentication status in workflow editor
- ✅ One-click "Sign in with Google" button
- ✅ Seamless integration with existing Google tools
- ✅ Variable support in parameters ({{ variable }})

### Developer Benefits:
- ✅ Reuses existing GmailTool, GoogleCalendarTool, GoogleDriveTool
- ✅ No duplicate OAuth implementation
- ✅ Platform channel for Flutter ↔ Kotlin communication
- ✅ Clean error handling with user-friendly messages
- ✅ Extensible architecture for more Google services

### Business Value:
- ✅ FREE (no API costs - uses user's OAuth quota)
- ✅ Enhances workflow capabilities significantly
- ✅ Differentiates from competitors
- ✅ Complements Composio (Google for FREE, others via Composio)

---

*Google Workspace integration completed with native OAuth support!*
*All 3 services (Gmail, Calendar, Drive) working in workflow editor!*
*Ready for production use!* 🚀

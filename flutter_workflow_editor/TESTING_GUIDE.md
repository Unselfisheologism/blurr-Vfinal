# Testing Guide - Gmail Workflow in n8n-style Editor

## End-to-End Test: Send Email via Gmail

### Prerequisites
1. ✅ Android device/emulator with Google Play Services
2. ✅ Google account for testing
3. ✅ App built and installed
4. ✅ GoogleSignInActivity configured in AndroidManifest.xml

---

## Test Steps

### Step 1: Launch Workflow Editor

1. Open Twent Voice app
2. Navigate to Settings/Menu
3. Tap "Workflow Editor" button
4. **Expected**: Flutter workflow editor opens with empty canvas

---

### Step 2: Create Manual Trigger

1. Look at left sidebar (Node Palette)
2. Under "Triggers" category, find "Manual Trigger"
3. Tap "Manual Trigger" to add to canvas
4. **Expected**: Manual Trigger node appears in center of canvas

---

### Step 3: Add Google Workspace Node

1. In Node Palette, look under "Actions" category
2. Find "Google Workspace" node (red color, Google icon)
3. Tap to add to canvas below Manual Trigger
4. **Expected**: Google Workspace node appears below trigger

---

### Step 4: Connect Nodes

1. Tap and drag from Manual Trigger output port (bottom)
2. Drag to Google Workspace input port (top)
3. **Expected**: Blue curved line connects the two nodes

---

### Step 5: Check Authentication Status

1. Tap Google Workspace node to select it
2. Right panel (Inspector) opens
3. **Expected**: Orange warning box shows:
   - ⚠️ "Not Authenticated"
   - "You need to sign in to Google to use Google Workspace tools"
   - Blue button: "Sign in with Google"

---

### Step 6: Authenticate with Google

1. Click "Sign in with Google" button
2. **Expected**: GoogleSignInActivity opens (native Android OAuth)
3. Select your Google account
4. Grant permissions:
   - Gmail: Send, read emails
   - Calendar: Read, write events
   - Drive: Read, write files
5. **Expected**: Returns to workflow editor
6. **Expected**: Green snackbar: "Successfully authenticated with Google!"
7. **Expected**: Inspector now shows dropdown menus instead of warning

---

### Step 7: Configure Gmail Action

1. In Inspector panel, tap "Service" dropdown
2. Select "Gmail" (📧 icon)
3. Tap "Action" dropdown (now visible)
4. Select "Send Email"
5. In "Parameters (JSON)" field, enter:
```json
{
  "to": "youremail@example.com",
  "subject": "Test from Workflow Editor",
  "body": "This email was sent from my n8n-style workflow editor!"
}
```
6. **Expected**: Parameters saved, no errors

---

### Step 8: Execute Workflow

1. Look at top toolbar
2. Click blue "Execute" button
3. **Expected**: Button shows "Running..." with spinner
4. **Expected**: Execution Panel opens at bottom (black terminal-style)
5. **Expected**: Logs appear:
   ```
   ▶ Starting workflow execution: New Workflow
   ▶ Executing node: [trigger_node_id]
   ✓ Node [trigger_node_id] completed
   ▶ Executing node: [gmail_node_id]
   ✓ Node [gmail_node_id] completed
   ✓ Workflow execution completed
   ```
6. **Expected**: Green checkmark appears on Google Workspace node
7. **Expected**: "Execute" button returns to normal

---

### Step 9: Verify Email Sent

1. Open Gmail app or web
2. Check Sent folder
3. **Expected**: Email appears with:
   - To: youremail@example.com
   - Subject: "Test from Workflow Editor"
   - Body: "This email was sent from my n8n-style workflow editor!"
4. Check recipient inbox (if different email)
5. **Expected**: Email received

---

### Step 10: Inspect Results

1. In workflow editor, click Google Workspace node (if not selected)
2. Look at Inspector panel, scroll down
3. **Expected**: "Execution Results" section shows:
```json
{
  "message_id": "18d3f2...",
  "success": true,
  "to": "youremail@example.com"
}
```
4. **Expected**: No "Error" section visible

---

## Additional Tests

### Test 2: Create Calendar Event

1. Add new Google Workspace node
2. Select Service: Google Calendar
3. Select Action: create_event
4. Parameters:
```json
{
  "summary": "Test Meeting",
  "start_time": "2024-01-20T10:00:00-08:00",
  "end_time": "2024-01-20T11:00:00-08:00",
  "description": "Created from workflow"
}
```
5. Execute workflow
6. **Verify**: Event appears in Google Calendar

---

### Test 3: Error Handling (Not Authenticated)

1. Sign out from Google (Settings → Google Account → Sign Out)
2. In workflow editor, try to execute Gmail workflow
3. **Expected**: Execution logs show error:
   ```
   ✕ ERROR in node [gmail_node]: NOT_AUTHENTICATED: Please sign in to Google
   ```
4. **Expected**: Red error icon on Google Workspace node
5. **Expected**: Inspector shows error details

---

### Test 4: Save and Load Workflow

1. Create workflow with Google Workspace node
2. Configure Gmail action
3. Click "Save" button in toolbar
4. Close workflow editor
5. Reopen workflow editor
6. Click "Open" or select workflow from list
7. **Expected**: Workflow loads with all nodes and connections
8. **Expected**: Google Workspace node still configured
9. Execute workflow again
10. **Expected**: Works correctly

---

### Test 5: Multiple Actions in Sequence

1. Create workflow:
   - Manual Trigger
   - Google Workspace (Gmail: send_email)
   - Google Workspace (Calendar: create_event)
   - Google Workspace (Drive: list_files)
2. Connect them in sequence
3. Execute workflow
4. **Expected**: All three actions execute in order
5. **Expected**: Each node shows green checkmark
6. **Expected**: Logs show all three completed

---

## Success Criteria

✅ **All tests passed if:**
- Google OAuth popup opens when clicking "Sign in with Google"
- Authentication succeeds and inspector shows service dropdowns
- Gmail send_email action sends actual email
- Email appears in Gmail with correct content
- Execution panel shows success logs
- Node shows green checkmark after execution
- Inspector shows execution results
- Error handling works when not authenticated

---

## Common Issues & Fixes

### Issue: "Sign in with Google" does nothing

**Check:**
```bash
adb logcat | grep GoogleSignIn
```

**Fix:**
- Verify GoogleSignInActivity in AndroidManifest.xml
- Check OAuth credentials in Google Cloud Console
- Verify SHA-1 fingerprint added

---

### Issue: Email not sent

**Check:**
```kotlin
// Test GmailTool directly
val gmailTool = GmailTool(context, googleAuthManager)
val result = gmailTool.execute(mapOf("action" to "send_email", ...))
Log.d("Test", "Result: $result")
```

**Fix:**
- Verify Google account has Gmail enabled
- Check Gmail API quota (should be 1B units/day)
- Verify parameters are correct JSON

---

### Issue: Workflow doesn't execute

**Check logs:**
```bash
adb logcat | grep -i "flutter\|workflow\|execution"
```

**Fix:**
- Ensure nodes are connected (blue line visible)
- Click nodes to verify they're properly configured
- Check execution panel for error messages

---

## Performance Metrics

**Expected Timings:**
- OAuth popup open: <1 second
- Authentication complete: 2-5 seconds (user dependent)
- Gmail send_email: 1-3 seconds
- Calendar create_event: 1-2 seconds
- Drive list_files: 1-3 seconds

**Memory Usage:**
- Flutter engine: ~50MB
- Workflow execution: +10-20MB
- Peak during OAuth: +5MB

---

## Automated Test Script

```kotlin
// In androidTest/
@Test
fun testGmailWorkflow() {
    // 1. Launch activity
    val intent = Intent(context, WorkflowEditorActivity::class.java)
    activityRule.launchActivity(intent)
    
    // 2. Add nodes
    onView(withText("Manual Trigger")).perform(click())
    onView(withText("Google Workspace")).perform(click())
    
    // 3. Connect nodes (TODO: implement gesture)
    
    // 4. Configure Gmail
    onView(withId(R.id.google_workspace_node)).perform(click())
    onView(withText("Service")).perform(click())
    onView(withText("Gmail")).perform(click())
    onView(withText("Action")).perform(click())
    onView(withText("Send Email")).perform(click())
    
    // 5. Execute
    onView(withId(R.id.execute_button)).perform(click())
    
    // 6. Verify success
    onView(withText("Workflow execution completed"))
        .check(matches(isDisplayed()))
}
```

---

## Completion Checklist

- [ ] Workflow editor opens successfully
- [ ] Manual Trigger node added
- [ ] Google Workspace node added
- [ ] Nodes connected with blue line
- [ ] Authentication warning shown when not signed in
- [ ] "Sign in with Google" button works
- [ ] OAuth popup appears
- [ ] Authentication succeeds
- [ ] Inspector shows service/action dropdowns
- [ ] Gmail action configured
- [ ] Workflow executes successfully
- [ ] Email sent and received
- [ ] Execution logs show success
- [ ] Node shows green checkmark
- [ ] Inspector shows execution results
- [ ] Error handling tested (not authenticated)
- [ ] Workflow saved and loaded successfully

---

*Testing guide for Google Workspace integration in workflow editor*
*Follow this guide to verify end-to-end functionality*
*Report any issues with logs and screenshots* 📋

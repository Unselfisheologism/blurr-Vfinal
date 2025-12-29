# System Tools Workflow Examples

This document provides practical examples of workflows using Blurr's system-level tools.

## Example 1: Auto-Reply to WhatsApp Messages

**Description:** Automatically check WhatsApp notifications and open the app when new messages arrive.

```json
{
  "name": "WhatsApp Auto-Check",
  "nodes": [
    {
      "type": "schedule",
      "name": "Every 5 Minutes",
      "parameters": {
        "interval": "5m"
      }
    },
    {
      "type": "notificationAction",
      "name": "Get WhatsApp Notifications",
      "parameters": {
        "toolId": "notif_get_by_app",
        "parameters": {
          "packageName": "com.whatsapp"
        }
      }
    },
    {
      "type": "ifElse",
      "name": "Has New Messages?",
      "parameters": {
        "condition": "{{ $node.previous.data.notifications.length > 0 }}"
      }
    },
    {
      "type": "phoneControlAction",
      "name": "Open WhatsApp",
      "parameters": {
        "toolId": "ui_open_app",
        "parameters": {
          "packageName": "com.whatsapp"
        }
      }
    },
    {
      "type": "uiAutomationAction",
      "name": "Tap First Chat",
      "parameters": {
        "toolId": "ui_tap",
        "parameters": {
          "text": "Chat"
        }
      }
    }
  ]
}
```

## Example 2: Screenshot Weather App Daily

**Description:** Open weather app, wait, take screenshot, and save it.

```json
{
  "name": "Daily Weather Screenshot",
  "nodes": [
    {
      "type": "schedule",
      "name": "Every Day 8 AM",
      "parameters": {
        "cron": "0 8 * * *"
      }
    },
    {
      "type": "phoneControlAction",
      "name": "Open Weather App",
      "parameters": {
        "toolId": "ui_open_app",
        "parameters": {
          "packageName": "com.google.android.googlequicksearchbox"
        }
      }
    },
    {
      "type": "code",
      "name": "Wait 2 Seconds",
      "parameters": {
        "code": "await new Promise(resolve => setTimeout(resolve, 2000));"
      }
    },
    {
      "type": "phoneControlAction",
      "name": "Take Screenshot",
      "parameters": {
        "toolId": "ui_screenshot"
      }
    },
    {
      "type": "setVariable",
      "name": "Save Screenshot",
      "parameters": {
        "name": "weather_screenshot",
        "value": "{{ $node.previous.data }}"
      }
    }
  ]
}
```

## Example 3: Smart Home Screen Navigation

**Description:** Navigate through settings to enable/disable features.

```json
{
  "name": "Quick Settings Toggle",
  "nodes": [
    {
      "type": "manual",
      "name": "Start"
    },
    {
      "type": "systemToolAction",
      "name": "Open WiFi Settings",
      "parameters": {
        "toolId": "system_open_settings",
        "parameters": {
          "settingsPage": "wifi"
        }
      }
    },
    {
      "type": "code",
      "name": "Wait for Settings",
      "parameters": {
        "code": "await new Promise(resolve => setTimeout(resolve, 1000));"
      }
    },
    {
      "type": "accessibilityAction",
      "name": "Get UI Structure",
      "parameters": {
        "toolId": "ui_get_hierarchy",
        "parameters": {
          "format": "markdown"
        }
      }
    },
    {
      "type": "aiAssist",
      "name": "Analyze Settings",
      "parameters": {
        "prompt": "Analyze this settings screen and find the WiFi toggle: {{ $node.previous.data }}"
      }
    },
    {
      "type": "uiAutomationAction",
      "name": "Toggle WiFi",
      "parameters": {
        "toolId": "ui_tap",
        "parameters": {
          "text": "{{ $node.previous.data.toggleElement }}"
        }
      }
    }
  ]
}
```

## Example 4: Notification Analyzer

**Description:** Collect and analyze all notifications with AI.

```json
{
  "name": "Notification Intelligence",
  "nodes": [
    {
      "type": "schedule",
      "name": "Every Hour",
      "parameters": {
        "interval": "1h"
      }
    },
    {
      "type": "notificationAction",
      "name": "Get All Notifications",
      "parameters": {
        "toolId": "notif_get_all"
      }
    },
    {
      "type": "setVariable",
      "name": "Store Notifications",
      "parameters": {
        "name": "all_notifications",
        "value": "{{ $node.previous.data.notifications }}"
      }
    },
    {
      "type": "aiAssist",
      "name": "Categorize Notifications",
      "parameters": {
        "prompt": "Categorize these notifications by urgency and type: {{ $variables.all_notifications }}"
      }
    },
    {
      "type": "ifElse",
      "name": "Has Urgent?",
      "parameters": {
        "condition": "{{ $node.previous.data.urgent.length > 0 }}"
      }
    },
    {
      "type": "composioAction",
      "name": "Send Slack Alert",
      "parameters": {
        "appName": "slack",
        "action": "send_message",
        "parameters": {
          "channel": "#alerts",
          "text": "Urgent notifications detected: {{ $node['Categorize Notifications'].data.urgent }}"
        }
      }
    }
  ]
}
```

## Example 5: App Usage Monitor

**Description:** Track which apps are being used throughout the day.

```json
{
  "name": "App Usage Tracker",
  "nodes": [
    {
      "type": "schedule",
      "name": "Every 10 Minutes",
      "parameters": {
        "interval": "10m"
      }
    },
    {
      "type": "systemToolAction",
      "name": "Get Current App",
      "parameters": {
        "toolId": "system_get_activity"
      }
    },
    {
      "type": "setVariable",
      "name": "Log Activity",
      "parameters": {
        "name": "app_history",
        "value": "{{ $variables.app_history || [] }}.concat([{ app: $node.previous.data.packageName, timestamp: Date.now() }])"
      }
    },
    {
      "type": "googleWorkspaceAction",
      "name": "Save to Google Sheets",
      "parameters": {
        "service": "sheets",
        "action": "append_row",
        "parameters": {
          "spreadsheetId": "YOUR_SHEET_ID",
          "range": "Sheet1!A:C",
          "values": [[
            "{{ new Date().toISOString() }}",
            "{{ $node['Get Current App'].data.packageName }}",
            "{{ $node['Get Current App'].data.activityName }}"
          ]]
        }
      }
    }
  ]
}
```

## Example 6: Smart Form Filler

**Description:** Automatically fill forms in apps using stored data.

```json
{
  "name": "Auto Form Filler",
  "nodes": [
    {
      "type": "manual",
      "name": "Start with Form Data",
      "parameters": {
        "formData": {
          "name": "John Doe",
          "email": "john@example.com",
          "phone": "+1234567890"
        }
      }
    },
    {
      "type": "phoneControlAction",
      "name": "Open App",
      "parameters": {
        "toolId": "ui_open_app",
        "parameters": {
          "packageName": "com.example.formapp"
        }
      }
    },
    {
      "type": "code",
      "name": "Wait for App",
      "parameters": {
        "code": "await new Promise(resolve => setTimeout(resolve, 2000));"
      }
    },
    {
      "type": "uiAutomationAction",
      "name": "Tap Name Field",
      "parameters": {
        "toolId": "ui_tap",
        "parameters": {
          "resourceId": "name_input"
        }
      }
    },
    {
      "type": "uiAutomationAction",
      "name": "Type Name",
      "parameters": {
        "toolId": "ui_type",
        "parameters": {
          "text": "{{ $node.Start.formData.name }}"
        }
      }
    },
    {
      "type": "uiAutomationAction",
      "name": "Tap Email Field",
      "parameters": {
        "toolId": "ui_tap",
        "parameters": {
          "resourceId": "email_input"
        }
      }
    },
    {
      "type": "uiAutomationAction",
      "name": "Type Email",
      "parameters": {
        "toolId": "ui_type",
        "parameters": {
          "text": "{{ $node.Start.formData.email }}"
        }
      }
    },
    {
      "type": "uiAutomationAction",
      "name": "Submit",
      "parameters": {
        "toolId": "ui_tap",
        "parameters": {
          "text": "Submit"
        }
      }
    }
  ]
}
```

## Example 7: Screen Recording Alternative

**Description:** Take multiple screenshots to create a visual log.

```json
{
  "name": "Visual Activity Logger",
  "nodes": [
    {
      "type": "schedule",
      "name": "Every 30 Seconds",
      "parameters": {
        "interval": "30s"
      }
    },
    {
      "type": "phoneControlAction",
      "name": "Capture Screen",
      "parameters": {
        "toolId": "ui_screenshot"
      }
    },
    {
      "type": "setVariable",
      "name": "Add to Gallery",
      "parameters": {
        "name": "screenshot_gallery",
        "value": "{{ ($variables.screenshot_gallery || []).concat([$node.previous.data]) }}"
      }
    },
    {
      "type": "ifElse",
      "name": "Gallery Full?",
      "parameters": {
        "condition": "{{ $variables.screenshot_gallery.length >= 20 }}"
      }
    },
    {
      "type": "googleWorkspaceAction",
      "name": "Upload to Drive",
      "parameters": {
        "service": "drive",
        "action": "upload_file",
        "parameters": {
          "name": "activity_log_{{ Date.now() }}.zip",
          "mimeType": "application/zip",
          "data": "{{ $variables.screenshot_gallery }}"
        }
      }
    },
    {
      "type": "setVariable",
      "name": "Clear Gallery",
      "parameters": {
        "name": "screenshot_gallery",
        "value": "[]"
      }
    }
  ]
}
```

## Example 8: Accessibility-Powered Testing

**Description:** Automated UI testing workflow using screen hierarchy analysis.

```json
{
  "name": "UI Test Automation",
  "nodes": [
    {
      "type": "manual",
      "name": "Start Test"
    },
    {
      "type": "phoneControlAction",
      "name": "Open Test App",
      "parameters": {
        "toolId": "ui_open_app",
        "parameters": {
          "packageName": "com.example.testapp"
        }
      }
    },
    {
      "type": "loop",
      "name": "Test Each Screen",
      "parameters": {
        "items": ["login", "dashboard", "settings", "profile"]
      }
    },
    {
      "type": "uiAutomationAction",
      "name": "Navigate to Screen",
      "parameters": {
        "toolId": "ui_tap",
        "parameters": {
          "text": "{{ $item }}"
        }
      }
    },
    {
      "type": "code",
      "name": "Wait",
      "parameters": {
        "code": "await new Promise(resolve => setTimeout(resolve, 1000));"
      }
    },
    {
      "type": "accessibilityAction",
      "name": "Capture Hierarchy",
      "parameters": {
        "toolId": "ui_get_hierarchy",
        "parameters": {
          "format": "xml"
        }
      }
    },
    {
      "type": "phoneControlAction",
      "name": "Screenshot",
      "parameters": {
        "toolId": "ui_screenshot"
      }
    },
    {
      "type": "aiAssist",
      "name": "Verify UI Elements",
      "parameters": {
        "prompt": "Check if all required elements are present in this screen: {{ $node['Capture Hierarchy'].data }}"
      }
    },
    {
      "type": "uiAutomationAction",
      "name": "Go Back",
      "parameters": {
        "toolId": "ui_back"
      }
    }
  ]
}
```

## Best Practices

1. **Always add delays** between UI actions using code nodes with setTimeout
2. **Use Get Screen Hierarchy** before tapping elements to verify they exist
3. **Handle errors** with error handler nodes
4. **Test workflows thoroughly** before scheduling them
5. **Use variables** to store state between runs
6. **Combine with AI** for intelligent decision-making
7. **Check permissions** before running system tool workflows

## Tips for Creating Your Own Workflows

- Start simple and add complexity gradually
- Use the execution panel to debug issues
- Check logcat for detailed error messages
- Test on different screen sizes and Android versions
- Use resource IDs when available (more reliable than text)
- Add conditional logic to handle different screen states
- Combine system tools with Composio and Google Workspace for powerful automations

## Common Patterns

### Pattern: Wait and Retry
```json
{
  "type": "code",
  "name": "Wait",
  "parameters": {
    "code": "await new Promise(resolve => setTimeout(resolve, 1000));"
  }
}
```

### Pattern: Check Before Action
```json
{
  "type": "accessibilityAction",
  "name": "Get Hierarchy"
},
{
  "type": "aiAssist",
  "name": "Find Element"
},
{
  "type": "uiAutomationAction",
  "name": "Tap Element"
}
```

### Pattern: Error Recovery
```json
{
  "type": "errorHandler",
  "name": "On Error"
},
{
  "type": "uiAutomationAction",
  "name": "Press Back"
},
{
  "type": "phoneControlAction",
  "name": "Press Home"
}
```

---

**Note:** These examples are templates. Adjust package names, coordinates, and parameters based on your specific use case and device.

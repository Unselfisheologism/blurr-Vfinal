# AI Agent Workflow Control - User Guide

## Overview

Your AI agent (Panda) can now **create and manage workflows** for you! This means you can ask Panda to set up complex, recurring automation that runs automatically, combining all your connected tools (Gmail, Notion, Slack, GitHub, phone automation, and more).

## What You Can Do

### 1. Create Scheduled Workflows

**You say:** "Check my Gmail every morning at 8 AM and create a summary in my Notion OS"

**Panda does:**
- Creates a workflow with Gmail, AI summarization, and Notion
- Schedules it to run daily at 8:00 AM
- Saves it so it runs automatically
- Asks if you want to test it now

**Result:** Every morning, you get an automatic email summary in Notion!

### 2. Set Up Recurring Tasks

**You say:** "Every Monday at 9 AM, fetch my calendar events for the week and send them to Slack"

**Panda does:**
- Creates a workflow with Google Calendar and Slack
- Schedules it for Mondays at 9:00 AM
- Connects the steps automatically

**Result:** Weekly calendar summaries posted to Slack, without any manual work!

### 3. Automate Data Syncing

**You say:** "Every hour, check GitHub for new issues in my repo and add them to my Trello board"

**Panda does:**
- Creates hourly scheduled workflow
- Fetches GitHub issues via Composio
- Filters for new issues only
- Creates Trello cards automatically

**Result:** Your Trello always has the latest GitHub issues!

### 4. Phone Automation

**You say:** "Take a screenshot of my home screen every morning at 7 AM"

**Panda does:**
- Creates workflow with phone control tools
- Schedules screenshot capture
- Saves screenshots to your preferred location

**Result:** Daily screenshot archive of your phone!

### 5. Complex Multi-Step Automation

**You say:** "Research trending AI topics, draft a LinkedIn post about them, and save it for my review - do this every Friday"

**Panda does:**
- Creates weekly workflow (Fridays)
- Uses Perplexity to research AI trends
- Uses LLM to draft LinkedIn post
- Saves draft for you to review and post

**Result:** Weekly content ideas, automatically researched and drafted!

## How It Works

### Step 1: Tell Panda What You Want
Use natural language to describe the automation you want:
- "Every [timeframe], do [action]"
- "Check [source] and send to [destination]"
- "Automate [task] on [schedule]"

### Step 2: Panda Creates the Workflow
Panda will:
- Understand your request
- Choose the right tools (Gmail, Notion, Composio, phone controls, etc.)
- Build a workflow with all the necessary steps
- Set up the schedule (if recurring)
- Save it for future use

### Step 3: Review and Test
Panda will:
- Explain what the workflow does
- List all the steps
- Mention any required permissions or subscriptions
- Offer to run it immediately as a test

### Step 4: Workflow Runs Automatically
Once created:
- The workflow runs on schedule (or when you trigger it)
- No further interaction needed
- Works even when you're not using the app
- Can be modified or deleted anytime

## Common Use Cases

### Productivity & Organization
- "Daily email summaries to my task manager"
- "Weekly calendar digest sent to my team"
- "Auto-archive old notifications"
- "Morning routine: weather, news, calendar"

### Social Media & Content
- "Draft tweets about trending topics every day"
- "Research and summarize industry news weekly"
- "Auto-post scheduled content"
- "Monitor brand mentions and alert me"

### Development & Tech
- "Check GitHub for new issues hourly"
- "Auto-deploy on main branch updates"
- "Monitor server status and alert on errors"
- "Backup important files daily"

### Personal Life
- "Track my fitness app stats daily"
- "Auto-reply to certain messages"
- "Shopping list sync between apps"
- "Bill payment reminders"

## Available Tools in Workflows

### Free Tools (No Subscription)
- **Gmail**: Read, send, search emails
- **Google Calendar**: View, create, update events
- **Google Drive**: Upload, download, search files
- **Phone Automation**: UI control, screenshots, notifications
- **AI Processing**: Summarize, analyze, generate content
- **Code Execution**: Custom JavaScript or Python

### PRO Tools (Subscription Required)
- **Composio Integrations**: 2000+ apps
  - Notion, Slack, GitHub, Trello, Asana
  - Twitter, LinkedIn, Instagram
  - Stripe, PayPal, QuickBooks
  - Spotify, YouTube, Twitch
  - And 1,995+ more!

### Scheduling Options

**Daily**
- "Every morning at 8 AM"
- "Daily at 6 PM"
- "Every day at noon"

**Weekly**
- "Every Monday at 9 AM"
- "Sundays at 6 PM"
- "Weekdays at 2:30 PM"

**Hourly/Custom**
- "Every hour"
- "Every 2 hours"
- "Every 30 minutes"
- "First Monday of every month"

## Example Conversations

### Example 1: Email to Notion
**You:** "Make a workflow that checks my Gmail every morning at 8 AM and adds a summary to my Notion OS"

**Panda:** "I'll create a daily workflow for you that:
1. Runs automatically at 8:00 AM every morning
2. Fetches your unread Gmail messages
3. Uses AI to create a concise summary
4. Adds the summary as a new page in your Notion

This workflow uses:
- Gmail (FREE - you're already signed in ✓)
- Notion via Composio (PRO feature - requires subscription)

✅ Workflow created: 'Daily Gmail Summary to Notion'

Would you like me to run it now as a test?"

### Example 2: GitHub to Slack
**You:** "Every hour, check my GitHub repo for new issues and post them to our team Slack"

**Panda:** "Setting up your GitHub to Slack automation!

Workflow: 'GitHub Issues to Slack'
- Frequency: Every hour
- Steps:
  1. Fetch issues from your GitHub repo
  2. Filter for new issues only
  3. Format issue details
  4. Post to your Slack channel

Requirements:
- Composio (PRO) for GitHub and Slack integrations
- You'll need to connect both apps in Composio

✅ Workflow created and scheduled!

First run will be in about an hour. Check your Slack for updates!"

### Example 3: Phone Automation
**You:** "Take a screenshot every morning before my alarm goes off"

**Panda:** "Creating morning screenshot workflow!

Workflow: 'Daily Morning Screenshot'
- Schedule: 7:00 AM daily
- Action: Capture screenshot of current screen

Note: This requires Accessibility Service permission for screenshots.

✅ Workflow ready!

Tomorrow at 7 AM, I'll capture your first screenshot. You can find it in your gallery."

## Managing Your Workflows

### View All Workflows
**You:** "Show me all my workflows"
**Panda:** Lists all your saved workflows with details

### Modify a Workflow
**You:** "Change my email summary to run at 9 AM instead"
**Panda:** Updates the schedule for your workflow

### Delete a Workflow
**You:** "Delete the GitHub issues workflow"
**Panda:** Removes the workflow and stops it from running

### Run Immediately
**You:** "Run my email summary workflow now"
**Panda:** Executes the workflow immediately for testing

## Tips for Best Results

### 1. Be Specific About Timing
✅ Good: "Every weekday at 9 AM"
❌ Vague: "Every morning"

### 2. Mention Required Apps
✅ Good: "Check Gmail and post to Notion"
❌ Unclear: "Check email and save it"

### 3. Start Simple
✅ Good: "Daily email summary"
❌ Complex: "Multi-step data pipeline with 10 different tools"

### 4. Test First
Always test workflows before relying on them for important tasks

### 5. Check Permissions
Some workflows need:
- Google sign-in (one-time setup)
- Composio PRO subscription
- Accessibility permissions for phone automation
- Notification access for notification workflows

## Troubleshooting

### "I don't have Composio PRO"
- Use free tools: Gmail, Calendar, Drive, Phone automation
- Upgrade to PRO for access to 2000+ app integrations

### "The workflow didn't run"
- Check that permissions are granted
- Verify you're signed into required services
- Make sure scheduling is correct
- Try running manually first

### "Can I see the workflow?"
- Yes! Open the Workflow Editor from the menu
- All AI-created workflows appear there
- You can view, edit, or delete them visually

### "How do I stop a workflow?"
- Say: "Delete [workflow name]"
- Or: "Stop my [workflow description]"
- Or: Open Workflow Editor and delete manually

## Privacy & Security

- **Local Storage**: Workflows are stored on your device
- **Your Control**: You can view, modify, or delete any workflow
- **Permissions**: Workflows only access what you've authorized
- **Data Safety**: No workflow data is sent to external servers without your explicit actions

## Advanced Features

### Conditional Logic
**You:** "If I have more than 10 unread emails, send me an alert"
**Panda:** Creates workflow with If/Else condition

### Data Processing
**You:** "Extract all email addresses from my inbox and save to a spreadsheet"
**Panda:** Creates workflow with data extraction and processing

### Multi-Path Workflows
**You:** "Check multiple sources and combine the results"
**Panda:** Creates workflow with merge nodes

### Error Handling
**You:** "If the API fails, send me a notification"
**Panda:** Adds error handling to workflow

## What's Coming Soon

- **Workflow Templates**: Pre-built workflows for common tasks
- **Execution History**: See logs of all workflow runs
- **Conditional Scheduling**: "Run only if X condition is met"
- **Workflow Sharing**: Export and share workflows with others
- **Visual Debugging**: Step through workflow execution

## Need Help?

**Ask Panda!**
- "How do I create a workflow?"
- "What tools can I use in workflows?"
- "Show me examples of workflows"
- "Help me automate [specific task]"

Panda understands natural language and can guide you through creating any workflow!

---

## Quick Reference

### Creating Workflows
```
"[Action] every [time]"
"Check [source] and [action]"
"Automate [task] on [schedule]"
```

### Managing Workflows
```
"Show my workflows"
"Update [workflow name]"
"Delete [workflow name]"
"Run [workflow name] now"
```

### Scheduling
```
Daily: "every day at 8 AM"
Weekly: "every Monday at 9 AM"
Hourly: "every hour"
Custom: "weekdays at 2:30 PM"
```

---

**Start automating your life with Panda today!** 🐼

Just tell Panda what you want to automate, and let AI handle the rest.

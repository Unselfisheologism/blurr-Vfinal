# Business Model Migration Plan: Old → New

## Executive Summary

Migrating from **restrictive freemium with usage quotas** to **unlimited free core + value-added premium features**.

**Timeline:** Implement immediately (before public launch)

**Impact:** Eliminates double-dipping, maximizes virality, aligns incentives

---

## Changes Required

### 1. Code Changes

#### ❌ REMOVE: Quota Tracking System

**Delete these files:**
```
app/src/main/java/com/twent/voice/data/FreemiumManager.kt
```

**Remove from User schema:**
```kotlin
// DELETE these fields from Appwrite Users collection:
tasksRemaining: Int
tasksResetAt: String
```

**Remove from UI:**
- Daily run counters ("X of 10 runs remaining")
- Quota reset timers
- "Daily limit reached" modals
- All quota-related toasts/notifications

#### ✅ ADD: Feature Flag System

**Create new file:**
```kotlin
// app/src/main/java/com/twent/voice/data/FeatureGate.kt
enum class PlanFeature {
    // Free (always available)
    UNLIMITED_AGENT_RUNS,
    UNLIMITED_CHAT,
    BYOK_SUPPORT,
    PHONE_AUTOMATION,
    BASIC_TOOLS,
    BASIC_WORKFLOWS,  // 3 max
    
    // Pro features
    WEB_SEARCH,
    DEEP_RESEARCH,
    FULL_WORKFLOW_BUILDER,
    WORKFLOW_SCHEDULING,
    ADVANCED_MULTIMODAL,
    LOCAL_MODELS,
    AGENT_TEMPLATES,
    STORAGE_100GB,
    
    // God Mode
    TEAM_SHARING,
    PRIVATE_MCP_HOSTING,
    WHITE_LABEL,
    ADVANCED_ANALYTICS
}

enum class Plan {
    FREE,
    PRO,
    PRO_TRIAL,
    GOD_MODE
}

object FeatureGate {
    fun hasAccess(feature: PlanFeature, userPlan: Plan): Boolean {
        // Implementation as shown in BUSINESS_MODEL_V2.md
    }
}
```

**Update User model:**
```kotlin
data class User(
    val id: String,
    val email: String,
    val plan: Plan,  // Simple enum
    val createdAt: String,
    val subscription: UserSubscription?  // Trial/subscription tracking
)

data class UserSubscription(
    val plan: Plan,
    val trialStartDate: String?,
    val trialEndDate: String?,
    val subscriptionStartDate: String?,
    val subscriptionEndDate: String?,
    val isTrialActive: Boolean = false
)
```

### 2. UI/UX Changes

#### Update Welcome/Onboarding

**Old:**
```
Welcome! You have 10 free AI runs per day.
Upgrade to Pro for unlimited access.
```

**New:**
```
Welcome to Twent AI Assistant
Your Mobile AI Operating System

✨ Unlimited AI agent runs - forever free
🔑 You control your AI (BYOK)
📱 Full phone automation
⚡ No usage limits, no quotas
```

#### Update BYOK Setup Screen

**Add to bottom:**
```
────────────────────────────────
💡 Recommended: AIMLAPI.com

Get started quickly:
• All-in-one (LLM, Vision, Voice)
• $10 free credit for new users
• Fast and reliable

[Get AIMLAPI Key] ↗
────────────────────────────────
(Affiliate disclosure: We may earn commission)
```

#### Update Settings → Upgrade

**Old:**
```
Free: 10 runs/day
Pro: Unlimited
```

**New:**
```
Free: Unlimited core features ✨
Pro: Premium superpowers 💎

Upgrade to get:
🔍 Web search & deep research
⚙️ Visual workflow builder + scheduling
💻 Run models locally/offline
🎨 Advanced multimodal generation

14-Day Free Trial • Cancel Anytime
```

#### Add Feature Gate Modals

**When user tries Pro feature:**
```
┌─────────────────────────────────┐
│  🔍 Web Search                  │
│                                 │
│  💎 Pro Feature                 │
│                                 │
│  Search the web and get         │
│  real-time data with Tavily     │
│  and Exa integration.           │
│                                 │
│  Available in Pro ($14.99/mo)   │
│                                 │
│  [Start 14-Day Free Trial]      │
│  [Learn More]                   │
└─────────────────────────────────┘
```

### 3. Analytics Updates

#### Remove Old Events
```kotlin
// DELETE
analytics.track("daily_limit_reached")
analytics.track("quota_reset")
analytics.track("tasks_remaining_low")
```

#### Add New Events
```kotlin
// ADD
analytics.track("pro_feature_attempted", mapOf(
    "feature" to featureName,
    "user_plan" to currentPlan
))

analytics.track("trial_started", mapOf(
    "plan" to "PRO"
))

analytics.track("trial_converted", mapOf(
    "plan" to "PRO",
    "duration" to daysUsed
))

analytics.track("affiliate_clicked", mapOf(
    "provider" to providerName
))
```

### 4. RevenueCat Setup

#### Configure Products

**In RevenueCat dashboard:**
```
Products:
- pro_monthly_1499 ($14.99/month)
- pro_yearly_14900 ($149/year, 17% discount)
- god_mode_monthly_2999 ($29.99/month)
- god_mode_yearly_29900 ($299/year, 17% discount)

Entitlements:
- "pro" → Grants access to all Pro features
- "god_mode" → Grants access to all God Mode features

Trial: 14 days for all subscriptions
```

#### Initialize in App

```kotlin
// app/src/main/java/com/twent/voice/MyApplication.kt
override fun onCreate() {
    super.onCreate()
    
    // Initialize RevenueCat
    Purchases.debugLogsEnabled = BuildConfig.DEBUG
    Purchases.configure(
        PurchasesConfiguration.Builder(this, REVENUECAT_API_KEY)
            .appUserID(getCurrentUserId())
            .build()
    )
}
```

#### Check Entitlements

```kotlin
fun updateUserPlan() {
    Purchases.sharedInstance.getCustomerInfo { customerInfo, error ->
        val plan = when {
            customerInfo?.entitlements?.get("god_mode")?.isActive == true -> Plan.GOD_MODE
            customerInfo?.entitlements?.get("pro")?.isActive == true -> Plan.PRO
            else -> Plan.FREE
        }
        
        // Update user in Appwrite
        updateUserPlanInDatabase(plan)
    }
}
```

### 5. Affiliate Integration

#### Add Affiliate Links

```kotlin
// app/src/main/java/com/twent/voice/core/providers/AffiliateLinks.kt
object AffiliateLinks {
    const val AIMLAPI = "https://aimlapi.com/?via=twent"
    const val OPENROUTER = "https://openrouter.ai"
    const val GROQ = "https://console.groq.com"
}
```

#### Update BYOK UI

**Add recommendation section:**
```xml
<!-- res/layout/activity_byok_settings.xml -->
<TextView
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:text="💡 Recommended: AIMLAPI.com"
    android:textStyle="bold" />

<TextView
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:text="Get started quickly:\n• All-in-one (LLM, Vision, Voice)\n• $10 free credit for new users\n• Fast and reliable" />

<Button
    android:id="@+id/aimlapi_signup"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:text="Get AIMLAPI Key ↗" />

<TextView
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:text="(Affiliate disclosure: We may earn commission)"
    android:textSize="11sp"
    android:alpha="0.7" />
```

### 6. Database Migration

#### Appwrite Schema Changes

**Users Collection - Before:**
```json
{
  "plan": "free",
  "tasksRemaining": 10,
  "tasksResetAt": "2025-01-11T00:00:00Z",
  "createdAt": "2025-01-01T10:00:00Z"
}
```

**Users Collection - After:**
```json
{
  "plan": "FREE",
  "createdAt": "2025-01-01T10:00:00Z",
  "subscription": {
    "plan": "FREE",
    "trialStartDate": null,
    "trialEndDate": null,
    "subscriptionStartDate": null,
    "subscriptionEndDate": null,
    "isTrialActive": false
  }
}
```

#### Migration Script

```kotlin
suspend fun migrateExistingUsers() {
    val users = appwriteDb.getAllUsers()
    
    users.forEach { user ->
        val newUserData = mapOf(
            "plan" to user.plan.uppercase(),  // "free" → "FREE"
            // Remove tasksRemaining, tasksResetAt
            "subscription" to mapOf(
                "plan" to user.plan.uppercase(),
                "trialStartDate" to null,
                "trialEndDate" to null,
                "subscriptionStartDate" to if (user.plan == "pro") user.subscriptionStartDate else null,
                "subscriptionEndDate" to null,
                "isTrialActive" to false
            )
        )
        
        appwriteDb.updateUser(user.id, newUserData)
    }
    
    Log.i("Migration", "Migrated ${users.size} users to new model")
}
```

#### Notify Existing Users

**In-app notification:**
```
🎉 Great News!

We've removed all usage limits on the Free tier.
You now have UNLIMITED agent runs forever!

Why? Because you already pay for your AI (BYOK).
We should never charge you twice.

Pro now unlocks premium features like:
• Web search & deep research
• Visual workflow automation
• Local/offline models

[Learn More] [Dismiss]
```

---

## Testing Checklist

### Before Migration

- [ ] Backup Appwrite database
- [ ] Test migration script on staging
- [ ] Verify RevenueCat products configured
- [ ] Test affiliate links work
- [ ] Review all UI copy changes

### During Migration

- [ ] Run database migration script
- [ ] Verify all users migrated correctly
- [ ] Deploy new app version
- [ ] Send notification to existing users

### After Migration

- [ ] Monitor error logs for issues
- [ ] Verify no quota-related errors
- [ ] Test Pro feature gates
- [ ] Test trial flow (start, use, convert)
- [ ] Test affiliate link tracking
- [ ] Verify RevenueCat webhook events

### User Acceptance Testing

- [ ] Free user can make unlimited requests
- [ ] Free user sees Pro feature gates
- [ ] Pro trial starts correctly
- [ ] Trial converts to paid correctly
- [ ] Trial expires and reverts to Free
- [ ] Affiliate links open correctly
- [ ] Analytics events fire correctly

---

## Rollout Plan

### Phase 1: Pre-Launch (If not launched yet)
1. Implement all changes
2. Test thoroughly
3. Launch with new model from day 1
4. No migration needed

### Phase 2: Post-Launch (If already have users)
1. **Week 1: Announce Change**
   - Email to all users
   - In-app notification
   - Blog post explaining why
   
2. **Week 2: Deploy Update**
   - Run database migration
   - Deploy new app version
   - Monitor for issues
   
3. **Week 3: Communicate Benefits**
   - Highlight unlimited free tier
   - Show Pro value proposition
   - Offer limited-time Pro discount?

---

## Communication Templates

### Email to Existing Users

**Subject:** Great News: Free Tier Now Unlimited!

```
Hi [Name],

We have exciting news about Twent AI Assistant!

🎉 The Free tier now has UNLIMITED AI agent runs

That's right - no more daily limits, no more quotas.
You can use Twent as much as you want, forever free.

Why the change?

You already pay for your AI compute through BYOK.
Charging you again for usage was double-dipping.
We realized that was wrong.

Now, we only charge for premium features that
deliver genuine value:

Pro ($14.99/mo) unlocks:
• Web search & deep research
• Visual workflow automation  
• Local/offline models
• Advanced multimodal generation
• 100+ templates

Try Pro free for 14 days: [Link]

Questions? Reply to this email.

Thanks for being part of Twent!

[Your Name]
Founder, Twent AI Assistant
```

### Blog Post

**Title:** Why We're Making Twent Free Forever (Unlimited)

```markdown
Today, we're making a major change to Twent's business model.

The Free tier now has **unlimited AI agent runs** - no quotas, no limits, forever.

## Why?

When we launched Twent with BYOK (Bring Your Own Key), we thought limiting free users to 10 runs/day made sense as a freemium model.

We were wrong.

**You already pay for AI compute** through your BYOK API keys.
Charging you again for usage was double-dipping.

It created a misalignment: we profited from restricting your access, even though you were paying the actual AI costs.

That felt wrong. So we're fixing it.

## What's Changing

**Free Tier (Now):**
- ✅ Unlimited AI agent runs
- ✅ Unlimited conversations
- ✅ Full phone automation
- ✅ Context preservation
- ✅ 10 GB storage

**No catches. No hidden limits. Unlimited.**

## How We Make Money

We only charge for features that cost us money or deliver massive value:

**Pro ($14.99/mo):**
- Web search APIs (we pay Tavily/Exa)
- Workflow scheduling (server costs)
- Local models (integration maintenance)
- Advanced features

**God Mode ($29.99/mo):**
- Team features
- Private MCP hosting  
- Enterprise capabilities

These features justify their cost. Basic AI usage doesn't.

## For Existing Users

If you're on Free, you now have unlimited runs.
If you're on Pro, you're grandfathered at current pricing.

No action needed.

## Try Pro Free

Curious about Pro? Try it free for 14 days:
[Start Trial]

## Questions?

Ask in our Discord or email support@twent.app

Thanks for being part of this journey.

[Your Name]
Founder, Twent AI Assistant
```

---

## Success Criteria

Migration is successful when:

1. ✅ All quota code removed
2. ✅ All users migrated to new schema
3. ✅ No quota-related errors in logs
4. ✅ Feature gates working correctly
5. ✅ Trial flow working end-to-end
6. ✅ Affiliate links tracked
7. ✅ RevenueCat integration working
8. ✅ Analytics events firing
9. ✅ User feedback positive
10. ✅ Free-to-Pro conversion tracking

---

## Risks & Mitigation

### Risk 1: Users Don't Upgrade

**Mitigation:**
- Pro features genuinely valuable
- 14-day trial lowers barrier
- Contextual upgrade prompts
- Show value before asking

### Risk 2: Database Migration Issues

**Mitigation:**
- Test thoroughly on staging
- Backup before migration
- Rollback plan ready
- Monitor logs closely

### Risk 3: Revenue Drop

**Mitigation:**
- Better aligned with user value
- Higher conversion from trial
- Affiliate revenue stream
- Viral growth from unlimited free

### Risk 4: Abuse of Free Tier

**Mitigation:**
- Users still pay their own API costs
- Rate limiting at API level (not usage quotas)
- Monitor for abuse patterns
- Ban bad actors if needed

---

## Timeline

**If Pre-Launch:**
- Day 1: Implement all changes
- Day 2-3: Testing
- Day 4: Deploy
- Launch with new model ✅

**If Post-Launch:**
- Week 1: Code changes + testing
- Week 2: Database migration + deployment
- Week 3: User communication
- Week 4: Monitor & iterate

---

## Next Steps

1. Review this migration plan
2. Approve business model change
3. Assign implementation tasks
4. Set migration date
5. Execute plan
6. Monitor results
7. Iterate based on feedback

---

**This migration positions Twent as a user-first, fair, unlimited AI assistant that respects users' existing AI costs while building a sustainable business through genuine value-add features.**
# HubSpot Email Sequence Setup Guide

## Overview

This guide will help you set up the automated email sequence that triggers when someone downloads the DevOps Automation Checklist from your landing page.

## Prerequisites

1. HubSpot account with Marketing Hub (or higher)
2. Custom properties created (see below)
3. Email templates created (see below)

---

## Step 1: Create Custom Properties

Go to **HubSpot → Settings → Properties → Contact Properties** and create these custom properties:

### 1. `devops_checklist_downloaded`
- **Label:** DevOps Checklist Downloaded
- **Type:** Single-line text
- **Default Value:** `false`
- **Description:** Tracks if contact downloaded the checklist

### 2. `email_sequence_started`
- **Label:** Email Sequence Started
- **Type:** Single-line text
- **Default Value:** `false`
- **Description:** Tracks if email sequence has been triggered

### 3. `email_sequence_date`
- **Label:** Email Sequence Start Date
- **Type:** Date picker
- **Description:** Date when email sequence started

### 4. `lead_source`
- **Label:** Lead Source
- **Type:** Single-line text
- **Description:** Where the lead came from

---

## Step 2: Create Email Templates

Go to **HubSpot → Marketing → Email → Templates** and create 5 email templates based on the sequence in `BUSINESS_MATERIALS/MARKETING/EMAIL_SEQUENCE.md`:

### Email 1: Welcome (Day 1)
- **Template Name:** DevOps Suite - Welcome Email
- **Subject:** Welcome! Here's how we help dev teams save 5+ hours/week
- Copy content from `EMAIL_SEQUENCE.md` Email 1

### Email 2: Pain Point Focus (Day 3)
- **Template Name:** DevOps Suite - Pain Point Email
- **Subject:** Tired of spending hours on boilerplate code?
- Copy content from `EMAIL_SEQUENCE.md` Email 2

### Email 3: ROI Focus (Day 6)
- **Template Name:** DevOps Suite - ROI Email
- **Subject:** How much is manual CI/CD costing you?
- Copy content from `EMAIL_SEQUENCE.md` Email 3

### Email 4: Social Proof (Day 10)
- **Template Name:** DevOps Suite - Social Proof Email
- **Subject:** How [Company] saved 6 hours/week per developer
- Copy content from `EMAIL_SEQUENCE.md` Email 4

### Email 5: Final Push (Day 14)
- **Template Name:** DevOps Suite - Final Push Email
- **Subject:** Last chance: Free consultation this week
- Copy content from `EMAIL_SEQUENCE.md` Email 5

**Important:** Make sure to:
- Use personalization tokens: `{{contact.firstname}}`
- Include the Calendly link: `https://calendly.com/kyjahn-smith/consultation`
- Add unsubscribe link (HubSpot adds this automatically)

---

## Step 3: Create the Workflow

Go to **HubSpot → Automation → Workflows** and create a new workflow:

### Workflow Settings
- **Name:** DevOps Productivity Suite - Email Sequence
- **Type:** Contact-based
- **Enrollment Trigger:** Contact-based property

### Enrollment Trigger
1. Click **"Set enrollment trigger"**
2. Add condition:
   - **Property:** `devops_checklist_downloaded`
   - **Operator:** `is equal to`
   - **Value:** `true`
3. Add additional condition (AND):
   - **Property:** `email_sequence_started`
   - **Operator:** `is equal to`
   - **Value:** `false`

This ensures the sequence only starts once per contact.

### Workflow Actions

Add these actions in order:

#### Action 1: Send Email (Day 1 - Immediate)
- **Action Type:** Send email
- **Email:** DevOps Suite - Welcome Email
- **Send immediately** (or delay: 0 hours)

#### Action 2: Wait (2 days)
- **Action Type:** Wait
- **Duration:** 2 days

#### Action 3: Send Email (Day 3)
- **Action Type:** Send email
- **Email:** DevOps Suite - Pain Point Email

#### Action 4: Wait (3 days)
- **Action Type:** Wait
- **Duration:** 3 days

#### Action 5: Send Email (Day 6)
- **Action Type:** Send email
- **Email:** DevOps Suite - ROI Email

#### Action 6: Wait (4 days)
- **Action Type:** Wait
- **Duration:** 4 days

#### Action 7: Send Email (Day 10)
- **Action Type:** Send email
- **Email:** DevOps Suite - Social Proof Email

#### Action 8: Wait (4 days)
- **Action Type:** Wait
- **Duration:** 4 days

#### Action 9: Send Email (Day 14)
- **Action Type:** Send email
- **Email:** DevOps Suite - Final Push Email

#### Action 10: Set Property (Mark as Complete)
- **Action Type:** Set contact property
- **Property:** `email_sequence_started`
- **Value:** `true`

---

## Step 4: Add Suppression Rules

Add suppression rules to prevent sending emails if:

1. **Contact unsubscribed:**
   - **Condition:** `hs_email_optout` is equal to `true`
   - **Action:** Remove from workflow

2. **Contact booked a call:**
   - **Condition:** Custom property `booked_consultation` is equal to `true`
   - **Action:** Remove from workflow

3. **Contact replied:**
   - **Condition:** `num_contacted` is greater than 0
   - **Action:** Remove from workflow (optional - you may want to continue)

---

## Step 5: Test the Workflow

1. **Create a test contact:**
   - Go to Contacts → Create contact
   - Email: `test@example.com`
   - First name: `Test`

2. **Manually enroll:**
   - Go to the workflow
   - Click "Enroll contacts"
   - Select your test contact
   - Verify emails are scheduled correctly

3. **Check email schedule:**
   - Go to the contact's timeline
   - Verify emails are scheduled for the correct dates

---

## Step 6: Activate the Workflow

Once tested:
1. Click **"Activate"** on the workflow
2. The workflow will now automatically enroll contacts when:
   - `devops_checklist_downloaded` = `true`
   - `email_sequence_started` = `false`

---

## How It Works

1. **User submits form** → `/api/lead-capture` endpoint is called
2. **Contact created/updated** → HubSpot API sets properties:
   - `devops_checklist_downloaded` = `true`
   - `email_sequence_started` = `true`
   - `email_sequence_date` = current date
   - `lead_source` = `landing_page`
3. **Workflow triggers** → Contact is enrolled in the email sequence
4. **Emails send automatically** → On Day 1, 3, 6, 10, and 14

---

## Troubleshooting

### Emails not sending?
- Check workflow is activated
- Verify contact properties are set correctly
- Check suppression rules aren't blocking
- Verify email templates are published

### Contact not enrolling?
- Check `devops_checklist_downloaded` property is set to `true`
- Verify `email_sequence_started` is `false` (or workflow won't enroll)
- Check workflow enrollment trigger conditions

### Wrong email timing?
- Verify wait durations are correct (2 days, 3 days, 4 days, 4 days)
- Check timezone settings in HubSpot

### Need to restart sequence?
- Set `email_sequence_started` back to `false`
- Contact will re-enroll in workflow

---

## Optional: Integration with Calendly

To automatically stop the sequence when someone books a call:

1. **Set up Calendly webhook** → HubSpot integration
2. **Create workflow** that triggers on Calendly event
3. **Set property:** `booked_consultation` = `true`
4. **Add suppression** to email sequence workflow

---

## Support

If you need help setting this up:
- HubSpot Documentation: https://knowledge.hubspot.com/workflows
- HubSpot Community: https://community.hubspot.com/


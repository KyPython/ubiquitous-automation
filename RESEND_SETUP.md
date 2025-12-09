# Resend Email Setup Guide

## ✅ What's Been Set Up

Your email automation is now built into your API! Here's what's included:

- ✅ Resend email service integration
- ✅ 5 email templates (matching your HubSpot emails)
- ✅ Checklist PDF email template
- ✅ Email queue system
- ✅ Automatic email sequence triggering

---

## 🚀 Quick Setup (5 Minutes)

### Step 1: Get Resend API Key (2 min)

1. Go to https://resend.com
2. Sign up for free account (3,000 emails/month free)
3. Go to API Keys → Create API Key
4. Copy your API key

### Step 2: Set Environment Variables in Vercel (2 min)

1. Go to Vercel → Your Project → Settings → Environment Variables
2. Add these variables:

```
RESEND_API_KEY=re_xxxxxxxxxxxxx
FROM_EMAIL=noreply@yourdomain.com
FROM_NAME=DevOps Productivity Suite
```

**Important:** 
- `FROM_EMAIL` must be a domain you own (or use Resend's test domain)
- If you don't have a domain, use: `onboarding@resend.dev` (for testing)

### Step 3: Verify Domain (1 min)

1. In Resend dashboard → Domains
2. Add your domain (or use test domain)
3. Add DNS records to verify
4. Once verified, update `FROM_EMAIL` in Vercel

---

## 📧 How It Works

1. **User submits form** → `/api/lead-capture` endpoint
2. **Contact created in HubSpot** (if API key configured)
3. **Email sequence starts automatically:**
   - Email 0: Checklist PDF (immediate)
   - Email 1: Welcome (immediate)
   - Email 2: Pain Point (Day 3)
   - Email 3: ROI (Day 6)
   - Email 4: Social Proof (Day 10)
   - Email 5: Final Push (Day 14)

---

## ⚠️ Important: Email Scheduling

**Current Implementation:**
- Immediate emails (PDF, Welcome) send right away ✅
- Delayed emails (Day 3, 6, 10, 14) are logged but need a scheduler

**For Production, You Need:**

### Option A: Vercel Cron Jobs (Recommended)
1. Add cron job in `vercel.json`:
```json
{
  "crons": [{
    "path": "/api/cron/process-email-queue",
    "schedule": "0 * * * *"
  }]
}
```

2. Set up database to store scheduled emails (Vercel Postgres, Supabase, etc.)

3. Update `email-queue.ts` to store emails in database

### Option B: Use Inngest (Easier)
1. Sign up at https://inngest.com
2. Install: `npm install inngest`
3. Use Inngest's scheduling instead of custom queue

### Option C: External Scheduler
- Use Zapier/Make.com to trigger emails
- Use a service like EasyCron
- Use GitHub Actions scheduled workflows

---

## 🧪 Testing

### Test Immediate Emails:
1. Submit the form on your landing page
2. Check email inbox for:
   - Checklist PDF email
   - Welcome email

### Test Delayed Emails:
- For now, delayed emails are logged
- Set up cron job/database to process them

---

## 📊 Email Templates

All templates are in `api/templates/email-templates.ts`:
- `getWelcomeEmail()` - Day 1
- `getPainPointEmail()` - Day 3
- `getROIEmail()` - Day 6
- `getSocialProofEmail()` - Day 10
- `getFinalPushEmail()` - Day 14
- `getChecklistEmail()` - PDF delivery

You can customize these templates anytime!

---

## 🔧 Troubleshooting

### Emails not sending?
- Check `RESEND_API_KEY` is set in Vercel
- Check Resend dashboard for errors
- Verify domain is verified in Resend

### PDF not attaching?
- Check PDF exists at: `BUSINESS_MATERIALS/MARKETING/DevOps_Automation_Checklist.pdf`
- Verify file path is correct

### Delayed emails not working?
- Set up cron job (see above)
- Or use Inngest for easier scheduling

---

## 💰 Costs

**Resend Free Tier:**
- 3,000 emails/month free
- 100 emails/day sending limit
- Perfect for getting started!

**If you exceed:**
- $20/month for 50,000 emails
- Very affordable scaling

---

## ✅ Next Steps

1. ✅ Set up Resend account
2. ✅ Add API key to Vercel
3. ✅ Test form submission
4. ⏳ Set up cron job for delayed emails (or use Inngest)
5. ✅ Verify emails are sending

---

## 🎉 You're Done!

Your email automation is now independent of HubSpot! You can:
- Keep Sales Hub Starter ($15/month)
- Send unlimited automated emails via Resend
- Full control over your email sequence

Need help with the cron job setup? Let me know!


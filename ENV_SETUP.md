# Environment Variables Setup

## Required for Lead Capture (HubSpot Integration)

To enable the lead capture form to actually submit to HubSpot, you need to set these environment variables in your Vercel project:

### HubSpot API Key

1. **Get your HubSpot API Key**:
   - Go to HubSpot → Settings → Integrations → Private Apps
   - Create a new private app or use an existing one
   - Copy the API key

2. **Set in Vercel**:
   - Go to your Vercel project dashboard
   - Navigate to Settings → Environment Variables
   - Add: `HUBSPOT_API_KEY` = `your-api-key-here`

### Optional: HubSpot Portal ID

If you want to use portal-specific features:
- Add: `HUBSPOT_PORTAL_ID` = `your-portal-id`

## How It Works

1. **Form Submission**: User fills out the form on the landing page
2. **API Call**: Form data is sent to `/api/lead-capture`
3. **HubSpot Integration**: The API endpoint:
   - Creates a new contact in HubSpot (or updates if exists)
   - Returns success response
4. **Email Automation**: HubSpot workflows can be configured to:
   - Send the DevOps Automation Checklist PDF
   - Add tags/segments
   - Trigger follow-up sequences

## Testing

### Local Development

Create a `.env.local` file:
```
HUBSPOT_API_KEY=your-test-api-key
```

### Production

Set environment variables in Vercel dashboard. They will be available to your serverless functions.

## HubSpot Workflow Setup

After contacts are created, set up a HubSpot workflow to:

1. **Trigger**: When contact is created/updated
2. **Condition**: If "devops_checklist_downloaded" property is true
3. **Action**: Send email with checklist PDF attachment

## Troubleshooting

- **Check Vercel logs**: View function logs in Vercel dashboard
- **HubSpot API limits**: Free tier has rate limits (100 requests/10 seconds)
- **Email delivery**: Ensure HubSpot workflows are properly configured


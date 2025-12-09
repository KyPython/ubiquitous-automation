# HubSpot AI Prompts - Create Custom Properties

Copy and paste these prompts into HubSpot's AI assistant to automatically create the required custom properties.

---

## Property 1: DevOps Checklist Downloaded

**Prompt:**
```
Create a new contact property with these settings:
- Internal name: devops_checklist_downloaded
- Label: DevOps Checklist Downloaded
- Type: Single-line text
- Field type: Text
- Description: Tracks if contact downloaded the DevOps Automation Checklist from the landing page
- Default value: false
- Show in forms: Yes
- Required: No
```

---

## Property 2: Email Sequence Started

**Prompt:**
```
Create a new contact property with these settings:
- Internal name: email_sequence_started
- Label: Email Sequence Started
- Type: Single-line text
- Field type: Text
- Description: Tracks if the automated email sequence has been triggered for this contact
- Default value: false
- Show in forms: No (this is an internal tracking property)
- Required: No
```

---

## Property 3: Email Sequence Start Date

**Prompt:**
```
Create a new contact property with these settings:
- Internal name: email_sequence_date
- Label: Email Sequence Start Date
- Type: Date picker
- Field type: Date
- Description: The date when the email sequence was started for this contact
- Show in forms: No (this is an internal tracking property)
- Required: No
```

---

## Property 4: Lead Source

**Prompt:**
```
Create a new contact property with these settings:
- Internal name: lead_source
- Label: Lead Source
- Type: Single-line text
- Field type: Text
- Description: Where the lead came from (e.g., landing_page, referral, etc.)
- Default value: (leave empty)
- Show in forms: Yes
- Required: No
```

---

## Alternative: Batch Creation Prompt

If HubSpot AI supports creating multiple properties at once, use this:

**Prompt:**
```
Create 4 new contact properties for tracking lead capture and email sequences:

1. Property name: devops_checklist_downloaded
   Label: DevOps Checklist Downloaded
   Type: Single-line text
   Description: Tracks if contact downloaded the DevOps Automation Checklist
   Default value: false

2. Property name: email_sequence_started
   Label: Email Sequence Started
   Type: Single-line text
   Description: Tracks if automated email sequence has been triggered
   Default value: false
   Show in forms: No

3. Property name: email_sequence_date
   Label: Email Sequence Start Date
   Type: Date picker
   Description: Date when email sequence started
   Show in forms: No

4. Property name: lead_source
   Label: Lead Source
   Type: Single-line text
   Description: Where the lead came from
```

---

## How to Use These Prompts

1. **Open HubSpot AI Assistant:**
   - Go to HubSpot → Settings → Properties → Contact Properties
   - Look for the AI assistant icon or "Ask AI" button
   - Or use HubSpot's ChatSpot/ChatGPT integration if available

2. **Copy and paste** one prompt at a time

3. **Verify** each property was created correctly:
   - Check the internal name matches exactly
   - Verify the field type is correct
   - Confirm the description is set

4. **Test** by creating a test contact and setting these properties manually

---

## Verification Checklist

After creating all properties, verify:

- [ ] `devops_checklist_downloaded` exists (text field)
- [ ] `email_sequence_started` exists (text field)
- [ ] `email_sequence_date` exists (date field)
- [ ] `lead_source` exists (text field)
- [ ] All properties are visible in contact records
- [ ] Properties can be used in workflows

---

## Troubleshooting

**If HubSpot AI doesn't recognize the prompt:**
- Try breaking it into smaller, simpler prompts
- Use HubSpot's property creation UI instead
- Check HubSpot documentation for the exact property creation format

**If properties aren't created:**
- Verify you have admin permissions
- Check if property names already exist (they must be unique)
- Try creating them manually via Settings → Properties

---

## Next Steps

After creating these properties:
1. Set up the email templates (see `HUBSPOT_EMAIL_SEQUENCE_SETUP.md`)
2. Create the workflow (see `HUBSPOT_EMAIL_SEQUENCE_SETUP.md`)
3. Test with a sample contact


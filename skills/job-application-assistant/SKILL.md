---
name: job-application-assistant
description: Given a job post URL, extracts application questions and drafts answers based on professional profile.
metadata: {"moltbot":{"emoji":"💼"}}
---

# Job Application Assistant

Extract application questions from job postings, draft answers based on professional profile, and track the full pipeline in Notion.

> **⚠️ Before drafting:** Read `/Users/maikel/Library/CloudStorage/GoogleDrive-m.gonzalezbaile@gmail.com/My Drive/Work/Job Hunting/job-criteria.md` for profile references (About Me, CV) and job criteria context.

## Notion Integration

**Job Hunting Pipeline Database:**
- data_source_id: `daef0884-0fdd-4fc3-a6be-fa4300548dc6`
- database_id: `eaedf5e6-3b8e-4454-bbcf-00f5a72abf23`

**Schema:**
| Property | Type | Values |
|----------|------|--------|
| Role | title | Job title |
| Company | rich_text | Company name |
| Status | status | To apply → Applied → Recruiters Contacted → Interviewing → Offer/Rejected/Withdrawn |
| Fit | select | Strong, Good, Weak, Blocker |
| URL | url | Job posting URL |

---

## Workflow

### Step 1: Check Pipeline & Create Entry

When user provides a job URL:

1. **Check if job already exists** — query by URL:
```bash
NOTION_KEY=$(cat ~/.config/notion/api_key)
curl -s -X POST "https://api.notion.com/v1/data_sources/daef0884-0fdd-4fc3-a6be-fa4300548dc6/query" \
  -H "Authorization: Bearer $NOTION_KEY" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d '{"filter": {"property": "URL", "url": {"equals": "<JOB_URL>"}}}'
```

2. **If not found, create entry** with status "To apply":
```bash
curl -s -X POST "https://api.notion.com/v1/pages" \
  -H "Authorization: Bearer $NOTION_KEY" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d '{
    "parent": {"database_id": "eaedf5e6-3b8e-4454-bbcf-00f5a72abf23"},
    "properties": {
      "Role": {"title": [{"text": {"content": "<ROLE_TITLE>"}}]},
      "Company": {"rich_text": [{"text": {"content": "<COMPANY_NAME>"}}]},
      "Status": {"status": {"name": "To apply"}},
      "Fit": {"select": {"name": "<FIT_ASSESSMENT>"}},
      "URL": {"url": "<JOB_URL>"}
    }
  }'
```

3. **Assess Fit** based on job requirements vs profile:
   - **Strong** — Full remote, leadership role, good tech/culture fit
   - **Good** — Mostly aligned, minor gaps
   - **Weak** — Significant misalignment but worth trying
   - **Blocker** — Hard requirement not met (e.g., on-site required, visa issues)

### Step 2: Fetch & Extract Questions

1. **Fetch the job posting** using `web_fetch` or `browser` (if login required)
2. **Identify the application form** — look for "Apply" links or embedded forms
3. **Extract questions** that require thoughtful answers:
   - Motivation: "Why do you want to work here?"
   - Experience: "Describe your experience with X"
   - Projects: "Tell us about a project you're proud of"
   - Culture fit: "How do you handle conflict?"
   - Role-specific: Technical questions, leadership scenarios
4. **Filter out** standard personal info fields (name, email, phone, etc.)

### Step 3: Read Profile & Draft Answers

Load the professional profile:
- **Master Profile:** `/Users/maikel/Library/CloudStorage/GoogleDrive-m.gonzalezbaile@gmail.com/My Drive/Work/Job Hunting/CVs/About Me.md`
- **CV:** `/Users/maikel/Library/CloudStorage/GoogleDrive-m.gonzalezbaile@gmail.com/My Drive/Work/Job Hunting/CVs/Maikel_Gonzalez_CV_AI_CTO.md`

For each question:
- Pull relevant experience/achievements from the profile
- Tailor to the specific role and company
- Match tone to company culture (if discernible)
- Keep answers concise but substantive

### Step 4: Return for Review

Output questions with drafted answers for Maikel to review and submit.

**Output Format:**
```
## Application: [Role] at [Company]

**Notion:** [Created/Already exists] | **Fit:** [Strong/Good/Weak/Blocker]

### Q1: [Question text]
**Answer:** [Drafted answer based on profile]

### Q2: [Question text]
**Answer:** [Drafted answer based on profile]

---

### Notes:
- [Observations about the role/company fit]
- [Required documents or special instructions]
- [Any questions that need Maikel's input]
```

---

## Step 5: Post-Application — Update Status & Recruiter Outreach

**Trigger:** After Maikel confirms the application was submitted.

### 5.1 Update Notion Status to "Applied"
```bash
curl -s -X PATCH "https://api.notion.com/v1/pages/<PAGE_ID>" \
  -H "Authorization: Bearer $NOTION_KEY" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d '{"properties": {"Status": {"status": {"name": "Applied"}}}}'
```

### 5.2 Extract Company LinkedIn Slug
- Find the company's LinkedIn URL from the job posting or company website
- Extract the slug (e.g., `https://linkedin.com/company/alan` → `alan`)
- If not obvious, search LinkedIn for the company name

### 5.3 Generate Personalized Message
Craft a connection request message that:
- References the specific {role} and {company} applied to
- Mentions something specific about the company (from JD research)
- Keeps it concise (LinkedIn limit ~300 chars)
- Uses `{name}` placeholder for recruiter's first name (auto-replaced by script)

**Example:**
```
Hi {name},

I'm very interested in the {role} role at {company}.

I’ve scaled products and teams from 0→1 to growth stages, led 50+ engineers, and I’m currently hands-on with production AI systems. I believe I can bring strong value to the company.

I'd love to connect and stay in touch.
```

### 5.4 Call Recruiter Outreach Script
```bash
cd /Users/maikel/Workspace/job_seeker && make contact-recruiters SLUG="<company-slug>" MESSAGE="<personalized-message>"
```

### 5.5 Update Notion Status to "Recruiters Contacted"
```bash
curl -s -X PATCH "https://api.notion.com/v1/pages/<PAGE_ID>" \
  -H "Authorization: Bearer $NOTION_KEY" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d '{"properties": {"Status": {"status": {"name": "Recruiters Contacted"}}}}'
```

---

## Pipeline Management Commands

### Query Pipeline by Status
```bash
# Get all jobs with status "To apply"
curl -s -X POST "https://api.notion.com/v1/data_sources/daef0884-0fdd-4fc3-a6be-fa4300548dc6/query" \
  -H "Authorization: Bearer $NOTION_KEY" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d '{"filter": {"property": "Status", "status": {"equals": "To apply"}}}'
```

### Update Job Status
```bash
curl -s -X PATCH "https://api.notion.com/v1/pages/<PAGE_ID>" \
  -H "Authorization: Bearer $NOTION_KEY" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d '{"properties": {"Status": {"status": {"name": "<NEW_STATUS>"}}}}'
```

Valid statuses: `To apply`, `Applied`, `Recruiters Contacted`, `Interviewing`, `Offer`, `Rejected`, `Withdrawn`

### Update Fit Assessment
```bash
curl -s -X PATCH "https://api.notion.com/v1/pages/<PAGE_ID>" \
  -H "Authorization: Bearer $NOTION_KEY" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d '{"properties": {"Fit": {"select": {"name": "<FIT>"}}}}'
```

Valid fit values: `Strong`, `Good`, `Weak`, `Blocker`

---

## Limitations

- Some forms require login (use browser tool with Chrome profile)
- ATS systems may need specific handling
- Novel questions not covered by profile → ask Maikel
- Remote requirement is a hard filter — flag any on-site/hybrid roles as Blocker

---
name: job-search-wellfound
description: Search WellFound (AngelList) for matching job opportunities using saved filters.
metadata: {"moltbot":{"emoji":"🚀"}}
---

# WellFound Job Search

Search WellFound using Maikel's logged-in account with pre-configured filters.

> **⚠️ Before searching:** Read `/Users/maikel/Library/CloudStorage/GoogleDrive-m.gonzalezbaile@gmail.com/My Drive/Work/Job Hunting/job-criteria.md` for the latest job criteria, filtering nuances (AI focus, location flexibility, ML filter-outs), and profile references.

## Platform Info

- **URL:** https://wellfound.com/jobs
- **Access:** Logged-in session with saved filters
- **Method:** Browser automation (clawd profile with saved cookies)

---

## Saved Search Filters (Pre-configured)

Maikel's account has a saved search with:

| Filter | Value |
|--------|-------|
| Roles | CTO, Engineering Manager, "Head of Engineering", "VP of Engineering", "Tech Lead", "Chief Technology Officer", "AI Engineer" |
| Location | Remote only |
| Region | Europe |
| Results | ~84 jobs |

**Note:** Job alerts are enabled — Maikel also gets email notifications.

---

## Execution

### Step 1: Open Jobs Page (Logged In)

The clawd browser profile should have WellFound session cookies. Open the jobs page:

```
browser action="start" profile="clawd"
browser action="open" targetUrl="https://wellfound.com/jobs" profile="clawd"
```

Wait 2-3 seconds for JavaScript to load and filters to apply.

### Step 2: Verify Login & Filters

Check the snapshot for:
- Avatar/username in header (confirms logged in)
- "84 results" or similar count (confirms filters applied)
- "Remote only" and "Europe" badges visible

If not logged in, the skill should report this and stop (manual login required).

### Step 3: Parse Job Listings

Each job card contains:
- **Company name** — heading with link to `/company/{slug}`
- **Role title** — link to job `/jobs/{id}-{slug}`
- **Location** — e.g., "Remote only • Everywhere" or "Onsite or remote • London"
- **Salary/Equity** — e.g., "$80k – $130k • 0.0% – 1.0%"
- **Posted date** — e.g., "Posted 3 days ago"
- **Recruiter activity** — "Recruiter recently active" (good sign)
- **Badges** — "Top 1% of responders", "Growing fast", etc.

### Step 4: Extract Data

From each job card, extract:

```json
{
  "role": "CTO for P2P blockchain tutoring platform",
  "company": "APOLO - P2P CRYPTO LEARNING",
  "url": "https://wellfound.com/jobs/3792805-cto-for-p2p-blockchain-tutoring-platform",
  "location": "Remote only • Everywhere",
  "salary": null,
  "equity": "1.0% – 1.0%",
  "posted": "3 days ago",
  "recruiterActive": true,
  "remote": true,
  "source": "wellfound"
}
```

---

## Output & Notion Integration

Jobs passing all filters (title + remote + AI-relevant) are automatically added to Notion.

**Notion Database:** Job Hunting Pipeline
- database_id: `eaedf5e6-3b8e-4454-bbcf-00f5a72abf23`

### Add to Notion

For each qualifying job:

```bash
NOTION_KEY=$(cat ~/.config/notion/api_key)
curl -s -X POST "https://api.notion.com/v1/pages" \
  -H "Authorization: Bearer $NOTION_KEY" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d '{
    "parent": {"database_id": "eaedf5e6-3b8e-4454-bbcf-00f5a72abf23"},
    "properties": {
      "Role": {"title": [{"text": {"content": "<ROLE>"}}]},
      "Company": {"rich_text": [{"text": {"content": "<COMPANY>"}}]},
      "Status": {"status": {"name": "To apply"}},
      "Fit": {"select": {"name": "<FIT>"}},
      "Summary": {"rich_text": [{"text": {"content": "<AI_RELEVANCE_SUMMARY>"}}]},
      "URL": {"url": "<WELLFOUND_URL>"}
    }
  }'
```

**Fit Assessment:**
- **Strong**: CTO/VP/Head role + explicit AI/ML in job description + funded company
- **Good**: EM role at AI company OR leadership role with AI mentioned
- **Weak**: AI mentioned but not core to role

**Summary field:** Brief note on why it's AI-relevant (e.g., "AI-native product, ML infrastructure")

---

## Filtering Rules

The saved search already filters for role + remote + Europe. Apply these additional rules:

**Hard Skip (don't add to Notion):**
- ❌ IC roles (Senior Engineer, Staff Engineer, etc.) — leadership only
- ❌ Data-focused roles (Data Eng Manager, Analytics Lead) — want product/customer-facing
- ❌ Language requirements (Italian, German, French, etc.)
- ❌ Revenue-sharing consulting arrangements (splitting revenue with founder)
- ❌ Blockchain/Crypto focus (not expertise area)
- ❌ **No AI/ML mention in job description** — must be AI-relevant

**AI/ML Relevance Check (REQUIRED):**
After initial title filter, click into job detail and scan description for:
- Keywords: AI, artificial intelligence, ML, machine learning, LLM, large language model, NLP, GPT, deep learning, neural network, generative AI, GenAI, computer vision, data science (in product context)
- Context: Building AI products, AI strategy, ML infrastructure, AI-native company

If NONE of these appear in the job description → **Skip** (not AI-relevant)

**Equity-only roles:**
- Only consider if founders have **proven exits** (check company description)
- AND salary expected within **≤2 months**
- Otherwise → Skip

**Needs deeper review (flag but include):**
- ⚠️ Co-founder roles from exited founders — check if too hands-on (frontend, Flutter, etc.)
- ⚠️ Fractional/Contractor — include if AI-focused or strategic

**Prioritize (Strong fit):**
- ✅ Has salary listed (€100k+)
- ✅ Product-focused, customer-facing scope
- ✅ AI/ML companies or AI-native products
- ✅ "Recruiter recently active" + "Top X% of responders"
- ✅ Posted within last 2 weeks
- ✅ Series A+ or 50+ employees (established)

---

## Pagination

The saved search shows ~84 results. Scroll or paginate to capture more:

1. Parse visible jobs (first ~10-15)
2. Scroll down or click "Load more" if present
3. Continue until all 84 captured or 3 pages

Most relevant jobs appear first (sorted by "Recommended").

---

## Session Management

**If logged out:**
1. Report to orchestrator: "WellFound session expired, manual login required"
2. Open browser for user to log in
3. After login, cookies persist in clawd profile

**Cookie location:** Managed by clawd browser profile (Chromium user data dir)

---

## State Tracking (Stop Condition)

Track seen job IDs to know when to stop scrolling on subsequent runs.

**State file:** `memory/job-search-state.json`

```json
{
  "wellfound": {
    "lastRun": "2026-01-28T09:00:00Z",
    "seenIds": ["3792805", "3767779", "3789123"]
  }
}
```

### Before Search

Load existing state:
```bash
cat memory/job-search-state.json | jq -r '.wellfound.seenIds[]' 2>/dev/null
```

### During Scroll

While parsing job cards:
1. Extract job ID from URL (e.g., `/jobs/3792805-...` → `3792805`)
2. If job ID is in `seenIds` → **skip it** (already processed, don't detail-check again)
3. If job ID is NOT in `seenIds` → process it (title filter, then detail-check if promising)
4. **Stop condition:** Stop scrolling when you've loaded 3 consecutive pages with zero new (unseen) jobs

**Important:** Do NOT stop at the first seen ID. WellFound's sort order isn't strictly chronological — new jobs can appear between old ones. Always skip seen jobs instead of stopping early.

### After Search

Update state with newly found IDs:
```bash
# Merge new IDs into seenIds array, update lastRun timestamp
jq '.wellfound.lastRun = now | .wellfound.seenIds += ["<new_ids>"] | .wellfound.seenIds |= unique' \
  memory/job-search-state.json > tmp && mv tmp memory/job-search-state.json
```

### First Run

If state file doesn't exist or platform key missing, process all visible jobs (first ~50) and create initial state.

---

## Rate Limits

- Wait 2-3 seconds between page interactions
- Don't run more than once per 2 hours (job alerts cover real-time)
- Respect "hiding" — don't resurface jobs Maikel has hidden

---

## Error Handling

- **Not logged in:** Stop and request manual login
- **Filters not applied:** Check for "Saved Search" menu, try clicking saved search
- **Empty results:** Unusual — report and check if filters changed

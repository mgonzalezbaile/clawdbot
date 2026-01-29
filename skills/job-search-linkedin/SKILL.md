---
name: job-search-linkedin
description: Search LinkedIn Jobs for matching opportunities using pre-filtered URL.
metadata: {"moltbot":{"emoji":"💼"}}
---

# LinkedIn Job Search

Search LinkedIn Jobs using Maikel's logged-in account with pre-configured filters.

> **⚠️ Before searching:** Read `/Users/maikel/Library/CloudStorage/GoogleDrive-m.gonzalezbaile@gmail.com/My Drive/Work/Job Hunting/job-criteria.md` for the latest job criteria, filtering nuances (AI focus, location flexibility, ML filter-outs), and profile references.

## Platform Info

- **URL:** https://www.linkedin.com/jobs/search/
- **Access:** Logged-in session via clawd browser profile
- **Method:** Browser automation (clawd profile with saved cookies)

---

## Saved Search URL (Pre-filtered)

```
https://www.linkedin.com/jobs/search/?currentJobId=4353826403&distance=25.0&f_TPR=a1769221049-&f_WT=2&geoId=91000007&keywords=CTO%20OR%20Chief%20Technology%20Officer%20OR%20Head%20of%20Engineering%20OR%20Engineering%20Manager%20OR%20Tech%20Lead%20OR%20VP%20of%20Engineering&origin=JOB_SEARCH_PAGE_JOB_FILTER&sortBy=DD
```

### Filter Breakdown

| Parameter | Value | Meaning |
|-----------|-------|---------|
| `f_WT=2` | 2 | Remote jobs only |
| `geoId=91000007` | EU | European Union region |
| `keywords` | CTO OR Chief Technology Officer OR... | Leadership roles |
| `sortBy=DD` | Date Descending | Newest first |
| `f_TPR` | Timestamp filter | Posted recently |
| `distance=25.0` | 25 | Search radius (km/mi) |

---

## Execution

### Step 1: Open Jobs Page (Logged In)

```
browser action="start" profile="clawd"
browser action="open" targetUrl="<full-url-above>" profile="clawd"
```

Wait 3-4 seconds for JavaScript to load (LinkedIn is heavy).

### Step 2: Verify Login & Filters

Check the snapshot for:
- Profile photo / "Me" icon in navbar (confirms logged in)
- Job count visible (e.g., "1,000+ results" or "248 results")
- "Remote" filter badge active
- Job cards displaying in left panel

If not logged in → LinkedIn shows login wall. Report and stop.

### Step 3: Parse Job Listings

LinkedIn shows jobs in a left sidebar list. Each job card contains:

- **Job title** — link text, e.g., "Chief Technology Officer"
- **Company name** — secondary text with company link
- **Location** — e.g., "Remote" or "Barcelona, Catalonia, Spain (Remote)"
- **Posted time** — e.g., "2 days ago", "1 week ago", "Reposted"
- **Applicants** — e.g., "Over 100 applicants" (high competition warning)
- **Easy Apply badge** — if present, can apply directly
- **Promoted badge** — sponsored listing (often recruiters)
- **Company logo** — helps identify

### Step 4: Extract Data

From each job card, extract:

```json
{
  "role": "Chief Technology Officer",
  "company": "TechStartup Ltd",
  "url": "https://www.linkedin.com/jobs/view/4353826403",
  "location": "Barcelona, Catalonia, Spain (Remote)",
  "posted": "2 days ago",
  "applicants": "47 applicants",
  "easyApply": true,
  "promoted": false,
  "remote": true,
  "source": "linkedin"
}
```

**Job URL format:** `https://www.linkedin.com/jobs/view/{jobId}`

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
      "URL": {"url": "<LINKEDIN_URL>"}
    }
  }'
```

**Fit Assessment:**
- **Strong**: CTO/VP/Head role + explicit AI/ML in job description + funded company
- **Good**: EM role at AI company OR leadership role with AI mentioned
- **Weak**: AI mentioned but not core to role

**Summary field:** Brief note on why it's AI-relevant (e.g., "Voice AI platform, LLM integration")

---

## Filtering Rules

The URL already filters for roles + remote + EU. Apply these additional rules:

**Hard Skip (don't add to Notion):**
- ❌ IC roles (Senior Engineer, Staff Engineer, Principal Engineer) — leadership only
- ❌ Data-focused roles (Data Eng Manager, Analytics Lead) — want product/customer-facing
- ❌ Language requirements (Italian, German, French required, etc.)
- ❌ Blockchain/Crypto focus (not expertise area)
- ❌ "Over 200 applicants" + posted >1 week — low signal-to-noise
- ❌ **No AI/ML mention in job description** — must be AI-relevant

**AI/ML Relevance Check (REQUIRED):**
After initial title filter, click into job detail and scan description for:
- Keywords: AI, artificial intelligence, ML, machine learning, LLM, large language model, NLP, GPT, deep learning, neural network, generative AI, GenAI, computer vision, data science (in product context)
- Context: Building AI products, AI strategy, ML infrastructure, AI-native company

If NONE of these appear in the job description → **Skip** (not AI-relevant)

**Needs deeper review (flag but include):**
- ⚠️ Promoted/Sponsored listings — often recruiter postings, verify company
- ⚠️ Reposted jobs — may indicate difficulty filling (red flag) or updated posting (neutral)
- ⚠️ "Actively recruiting" — could be high volume, check company size

**Prioritize (Strong fit):**
- ✅ Posted within last 7 days
- ✅ <50 applicants (lower competition)
- ✅ Easy Apply available (faster process)
- ✅ AI/ML companies or AI-native products (check company)
- ✅ Series A+ or 50+ employees
- ✅ Clear salary range listed (rare on LinkedIn, but valuable)

---

## Pagination & Scrolling

LinkedIn shows ~25 jobs per scroll. To capture more:

1. Parse visible jobs (first 25)
2. Scroll down in job list panel
3. Wait for new jobs to load (2-3 sec)
4. Repeat until desired count or no new jobs

**Focus:** First 50-75 results (newest, sorted by date) are most relevant.

---

## Clicking Into Job Details

To get full job description:

1. Click job card in left panel
2. Wait for right panel to load job details
3. Extract from detail panel:
   - Full description text
   - Required skills/qualifications
   - Salary range (if shown)
   - Company size / industry
   - "About the company" section

**When to expand:**
- Only for jobs passing initial filter
- Before adding to Notion (to verify fit)

---

## Session Management

**If logged out:**
1. LinkedIn shows login/signup wall
2. Report to orchestrator: "LinkedIn session expired, manual login required"
3. User logs in manually
4. Cookies persist in clawd profile

**LinkedIn-specific:**
- May show CAPTCHA after too many requests
- May throttle if scrolling too fast
- Profile must be Premium or have sufficient "free views"

---

## State Tracking (Stop Condition)

Track seen job IDs to know when to stop scrolling on subsequent runs.

**State file:** `memory/job-search-state.json`

```json
{
  "linkedin": {
    "lastRun": "2026-01-28T09:00:00Z",
    "seenIds": ["4353826403", "4351234567", "4349876543"]
  }
}
```

### Before Search

Load existing state:
```bash
cat memory/job-search-state.json | jq -r '.linkedin.seenIds[]' 2>/dev/null
```

### During Scroll

While parsing job cards:
1. Extract job ID from URL or `currentJobId` (e.g., `/jobs/view/4353826403` → `4353826403`)
2. If job ID is in `seenIds` → **stop scrolling** (hit known territory)
3. Collect all new jobs until hitting a seen one

**Logic:** Jobs are sorted by date (sortBy=DD). Once you hit a previously-seen job, everything below is also old.

### After Search

Update state with newly found IDs:
```bash
# Merge new IDs into seenIds array, update lastRun timestamp
jq '.linkedin.lastRun = now | .linkedin.seenIds += ["<new_ids>"] | .linkedin.seenIds |= unique' \
  memory/job-search-state.json > tmp && mv tmp memory/job-search-state.json
```

### First Run

If state file doesn't exist or platform key missing, process first ~50 jobs and create initial state.

---

## Rate Limits

- Wait 3-4 seconds between page interactions (LinkedIn is aggressive)
- Scroll slowly — sudden scrolling triggers bot detection
- Don't run more than 2x per day (LinkedIn may flag)
- Space out requests (60+ seconds between job detail clicks)

---

## Error Handling

- **Not logged in:** Stop, request manual login
- **CAPTCHA:** Stop, report "CAPTCHA triggered, manual intervention needed"
- **"No results":** Check if filters changed or LinkedIn layout updated
- **Rate limited:** Wait 1 hour before retry
- **Job details won't load:** May be Premium-only or expired posting

---

## LinkedIn vs WellFound Differences

| Aspect | LinkedIn | WellFound |
|--------|----------|-----------|
| Login persistence | Good (long sessions) | Good |
| Bot detection | Aggressive | Minimal |
| Job freshness | Mix of new + reposted | Mostly fresh |
| Easy Apply | Common | Always |
| Salary visibility | Rare | Common |
| Pagination | Infinite scroll | Load more |
| Rate limiting | Strict | Relaxed |

---

## Notes

- LinkedIn Premium provides unlimited job views — currently active on Maikel's account
- "Promoted" jobs are paid placements but can still be relevant
- Cross-reference with company LinkedIn page for headcount/growth signals

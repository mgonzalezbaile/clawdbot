---
name: job-search-linkedin
description: Search LinkedIn Jobs for matching opportunities using pre-filtered URL.
metadata: {"moltbot":{"emoji":"💼"}}
---

# LinkedIn Job Search

Search LinkedIn Jobs using Maikel's logged-in account with pre-configured filters.

> **⚠️ Before searching:** Read `/Users/maikel/Library/CloudStorage/GoogleDrive-m.gonzalezbaile@gmail.com/My Drive/Work/Job Hunting/job-criteria.md` for the latest job criteria and profile references.

---

## Pipeline Overview

```
┌─────────────────────────────────────────────────────────────────┐
│  URL PRE-FILTERS (built into search URL)                        │
│  Remote + EU + Leadership keywords + Last 24h                   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  PHASE 1: LOAD & EXTRACT                                        │
│  Open page → Scroll to load all jobs → Extract raw list         │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  PHASE 2: FILTER PIPELINE                                       │
│                                                                 │
│  Pass 1: Company Dedup                                          │
│  └─ job-companies check → remove companies already in pipeline  │
│                              ↓                                  │
│  Pass 2: Quick Filters (metadata only)                          │
│  └─ Role title, applicants, promoted → remove obvious skips     │
│                              ↓                                  │
│  Pass 3: Deep Review (click into job)                           │
│  └─ Full description, requirements → verify fit                 │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  PHASE 3: ADD TO NOTION                                         │
│  Only jobs that passed all 3 filter passes                      │
└─────────────────────────────────────────────────────────────────┘
```

---

## Platform Info

- **URL:** https://www.linkedin.com/jobs/search/
- **Access:** Logged-in session via clawd browser profile
- **Method:** Browser automation (clawd profile with saved cookies)

---

## Saved Search URL (Pre-filtered)

```
https://www.linkedin.com/jobs/search/?currentJobId=4360979949&distance=25.0&f_TPR=r86400&f_WT=2&geoId=91000007&keywords=CTO%20OR%20Chief%20Technology%20Officer%20OR%20Head%20of%20Engineering%20OR%20Engineering%20Manager%20OR%20Tech%20Lead%20OR%20VP%20of%20Engineering&origin=JOB_SEARCH_PAGE_JOB_FILTER&sortBy=DD&start=75
```

**URL parameters:**
- `f_TPR=r86400` — Last 24 hours only
- `f_WT=2` — Remote
- `geoId=91000007` — Europe
- `keywords=...` — Leadership roles
- `sortBy=DD` — Sort by date (newest first)

---

# PHASE 1: LOAD & EXTRACT

## Step 1.1: Open Jobs Page

```
browser action="start" profile="clawd"
browser action="open" targetUrl="<saved-search-url>" profile="clawd"
```

Wait 3-4 seconds for JavaScript to load.

## Step 1.2: Verify Login & Filters

Check snapshot for:
- Profile photo / "Me" icon in navbar (confirms logged in)
- Job count visible (e.g., "48 results")
- "Remote" filter badge active
- Job cards in left panel

**If not logged in** → Stop, report "LinkedIn session expired, manual login required"

## Step 1.3: Scroll to Load All Jobs

LinkedIn lazy-loads ~7 jobs initially. Scroll to load all:

```javascript
// Scroll the job list container
() => {
  const list = document.querySelector('.scaffold-layout__list > div');
  if (list) {
    list.scrollTop = list.scrollHeight;
    return 'scrolled to ' + list.scrollHeight;
  }
  return 'no list found';
}
```

Repeat: scroll → wait 3s → check count. Stop when count stabilizes.

```javascript
// Count loaded job cards
() => {
  const items = document.querySelectorAll('li.ember-view');
  let count = 0;
  for (const li of items) {
    if (li.querySelector('a[href*="/jobs/view/"]')) count++;
  }
  return count;
}
```

## Step 1.4: Extract All Jobs (Raw List)

From each job card, extract:

```json
{
  "jobId": "4353826403",
  "role": "Chief Technology Officer",
  "company": "TechStartup Ltd",
  "url": "https://www.linkedin.com/jobs/view/4353826403",
  "location": "Barcelona, Catalonia, Spain (Remote)",
  "posted": "2 days ago",
  "applicants": "47 applicants",
  "easyApply": true,
  "promoted": false
}
```

**Output:** Raw list of ALL jobs on page (no filtering yet)

---

# PHASE 2: FILTER PIPELINE

## Pass 1: Company Dedup (FIRST)

**Why first:** No point evaluating a job if we already have the company in pipeline.

```bash
# Collect unique company names from raw list
companies=("TechStartup Ltd" "AnotherCo" "ThirdCompany")

# Check against Notion pipeline
job-companies check "${companies[@]}"
```

**Output:**
```
=== Already in pipeline (1) ===
TechStartup Ltd
=== New (2) ===
AnotherCo
ThirdCompany
```

**Action:** Remove all jobs from "Already in pipeline" companies. Continue with "New" only.

---

## Pass 2: Quick Filters (Metadata)

Apply these filters using job card metadata (no clicking required):

**Hard Skip:**
- ❌ Role is clearly IC (e.g., "Senior Engineer", "Staff Developer")
- ❌ "Over 200 applicants" — too competitive
- ❌ Location excludes Spain (e.g., "Germany only")

**Flag for careful review in Pass 3:**
- ⚠️ Promoted/Sponsored — often recruiter postings
- ⚠️ Reposted — may indicate difficulty filling

**Prioritize (process first in Pass 3):**
- ✅ <50 applicants
- ✅ Easy Apply available
- ✅ Posted today

**Output:** Filtered list of candidates for deep review

---

## Pass 3: Deep Review (Click Into Job)

For each job that passed Pass 1 & 2:

1. **Click job card** in left panel
2. **Wait** for right panel to load (2-3s)
3. **Extract** from detail panel:
   - Full job description
   - Required skills/qualifications
   - Salary range (if shown)
   - Company size / industry
   - "About the company" section

4. **Evaluate fit** against job-criteria.md:
   - Remote policy confirmed?
   - Spain/EU eligible?
   - Leadership scope clear?
   - AI/tech relevance?
   - Company stage (Series A+)?

5. **Assign fit score:**
   - **Strong**: Right role + strong company + AI/ML focus
   - **Good**: Right role + solid company
   - **Weak**: Stretch role or uncertain quality

**Hard skip at this stage:**
- ❌ Description reveals IC role disguised as leadership
- ❌ "Must relocate" or office-only buried in description
- ❌ Tech stack mismatch (e.g., mainframe, SAP-only)
- ❌ Domain exclusions (gambling, adtech, crypto speculation)

**Output:** Final list of qualified jobs with fit scores

---

# PHASE 3: ADD TO NOTION

**Only jobs that passed ALL 3 filter passes reach this stage.**

**Notion Database:** Job Hunting Pipeline
- database_id: `eaedf5e6-3b8e-4454-bbcf-00f5a72abf23`

```bash
NOTION_KEY=$(cat ~/.config/notion/api_key)
curl -s -X POST "https://api.notion.com/v1/pages" \
  -H "Authorization: Bearer $NOTION_KEY" \
  -H "Notion-Version: 2022-06-28" \
  -H "Content-Type: application/json" \
  -d '{
    "parent": {"database_id": "eaedf5e6-3b8e-4454-bbcf-00f5a72abf23"},
    "properties": {
      "Role": {"title": [{"text": {"content": "<ROLE>"}}]},
      "Company": {"rich_text": [{"text": {"content": "<COMPANY>"}}]},
      "Status": {"status": {"name": "To apply"}},
      "Fit": {"select": {"name": "<Strong|Good|Weak>"}},
      "Summary": {"rich_text": [{"text": {"content": "<WHY_ITS_A_FIT>"}}]},
      "URL": {"url": "<LINKEDIN_URL>"}
    }
  }'
```

**Summary field:** Brief note on why it's a fit (company strength, AI relevance, role scope)

---

# ADDITIONAL DETAILS

## Pagination

The URL uses `f_TPR=r86400` (last 24h), so result sets are small. Process ALL jobs:

1. Scroll until no new jobs load
2. Run full filter pipeline
3. If LinkedIn shows "Page 2" link, navigate and repeat

**Stop condition:** Scroll yields no new job cards (count stable after 2-3 attempts)

---

## State Tracking

Track seen job IDs to avoid re-processing within same day.

**State file:** `memory/job-search-state.json`

```json
{
  "linkedin": {
    "lastRun": "2026-02-04T09:00:00Z",
    "seenIds": ["4353826403", "4351234567"]
  }
}
```

- Before search: Load `seenIds`, skip jobs already processed
- After search: Add new job IDs to `seenIds`
- Daily: Optionally clear `seenIds` for fresh run

---

## Rate Limits & Safety

- Wait 3-4 seconds between interactions
- Scroll slowly (sudden scrolling triggers bot detection)
- Max 2 runs per day
- 60+ seconds between job detail clicks
- If CAPTCHA appears → Stop, report, wait 1 hour

---

## Error Handling

| Error | Action |
|-------|--------|
| Not logged in | Stop, request manual login |
| CAPTCHA | Stop, report, wait 1 hour |
| No results | Check if filters changed |
| Rate limited | Wait 1 hour |
| Job won't load | Skip, may be expired |

---

## Notes

- LinkedIn Premium active (unlimited views)
- "Promoted" jobs can still be relevant — verify in Pass 3
- Cross-reference company LinkedIn page for headcount signals

---
name: job-search-wellfound
description: Search WellFound (AngelList) for matching job opportunities using saved filters.
metadata: {"moltbot":{"emoji":"🚀"}}
---

# WellFound Job Search

Search WellFound using Maikel's logged-in account with pre-configured filters.

> **⚠️ Before searching:** Read `/Users/maikel/Library/CloudStorage/GoogleDrive-m.gonzalezbaile@gmail.com/My Drive/Work/Job Hunting/job-criteria.md` for the latest job criteria and profile references.

---

## Pipeline Overview

```
┌─────────────────────────────────────────────────────────────────┐
│  SAVED SEARCH PRE-FILTERS (configured in WellFound account)     │
│  Remote + Europe + Leadership roles                             │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  PHASE 1: LOAD & EXTRACT                                        │
│  Open page → Scroll/paginate → Extract raw list                 │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  PHASE 2: FILTER PIPELINE                                       │
│                                                                 │
│  Pass 1: Company Dedup                                          │
│  └─ job-companies check → remove companies already in pipeline  │
│                              ↓                                  │
│  Pass 2: Quick Filters (metadata only)                          │
│  └─ Role title, salary, equity-only → remove obvious skips      │
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

# PHASE 1: LOAD & EXTRACT

## Step 1.1: Open Jobs Page

```
browser action="start" profile="clawd"
browser action="open" targetUrl="https://wellfound.com/jobs" profile="clawd"
```

Wait 2-3 seconds for JavaScript to load and filters to apply.

## Step 1.2: Verify Login & Filters

Check snapshot for:
- Avatar/username in header (confirms logged in)
- "84 results" or similar count (confirms filters applied)
- "Remote only" and "Europe" badges visible

**If not logged in** → Stop, report "WellFound session expired, manual login required"

## Step 1.3: Scroll to Load All Jobs

WellFound shows ~10-15 jobs initially. Scroll or click "Load more":

1. Parse visible jobs
2. Scroll down or click "Load more"
3. Repeat until all jobs loaded (count stabilizes)

## Step 1.4: Extract All Jobs (Raw List)

From each job card, extract:

```json
{
  "jobId": "3792805",
  "role": "CTO for P2P blockchain tutoring platform",
  "company": "APOLO - P2P CRYPTO LEARNING",
  "url": "https://wellfound.com/jobs/3792805-cto-for-p2p-blockchain-tutoring-platform",
  "location": "Remote only • Everywhere",
  "salary": null,
  "equity": "1.0% – 1.0%",
  "posted": "3 days ago",
  "recruiterActive": true
}
```

**Job ID:** Extract from URL (e.g., `/jobs/3792805-...` → `3792805`)

**Output:** Raw list of ALL jobs on page (no filtering yet)

---

# PHASE 2: FILTER PIPELINE

## Pass 1: Company Dedup (FIRST)

**Why first:** No point evaluating a job if we already have the company in pipeline.

```bash
# Collect unique company names from raw list
companies=("APOLO" "TechCorp" "StartupXYZ")

# Check against Notion pipeline
job-companies check "${companies[@]}"
```

**Output:**
```
=== Already in pipeline (1) ===
TechCorp
=== New (2) ===
APOLO
StartupXYZ
```

**Action:** Remove all jobs from "Already in pipeline" companies. Continue with "New" only.

---

## Pass 2: Quick Filters (Metadata)

Apply these filters using job card metadata (no clicking required):

**Hard Skip:**
- ❌ Role is clearly IC (e.g., "Senior Engineer", "AI Engineer" without leadership)
- ❌ Equity-only with no salary listed (unless founders have proven exits)
- ❌ Revenue-sharing / consulting arrangements

**Flag for careful review in Pass 3:**
- ⚠️ Co-founder roles — check if too hands-on (Flutter, frontend dev)
- ⚠️ Fractional/Contractor — include if strategic scope

**Prioritize (process first in Pass 3):**
- ✅ Salary listed (€100k+)
- ✅ "Recruiter recently active" + "Top X% of responders"
- ✅ Posted within last 2 weeks
- ✅ Series A+ or 50+ employees

**Output:** Filtered list of candidates for deep review

---

## Pass 3: Deep Review (Click Into Job)

For each job that passed Pass 1 & 2:

1. **Click job card** to open detail view
2. **Wait** for full description to load (2-3s)
3. **Extract** from detail panel:
   - Full job description
   - Required skills/qualifications
   - Company stage / funding
   - Team size
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
      "URL": {"url": "<WELLFOUND_URL>"}
    }
  }'
```

**Summary field:** Brief note on why it's a fit (company strength, AI relevance, role scope)

---

# ADDITIONAL DETAILS

## State Tracking

Track seen job IDs to avoid re-processing.

**State file:** `memory/job-search-state.json`

```json
{
  "wellfound": {
    "lastRun": "2026-02-04T09:00:00Z",
    "seenIds": ["3792805", "3767779", "3789123"]
  }
}
```

**Important:** WellFound's sort order isn't strictly chronological — new jobs can appear between old ones. Always skip seen jobs (don't stop at first seen).

- Before search: Load `seenIds`, skip jobs already processed
- After search: Add new job IDs to `seenIds`

---

## Pagination

WellFound shows ~84 results for current filters. Process all:

1. Scroll/click "Load more" until all jobs visible
2. Run full filter pipeline
3. Stop when no new jobs load

---

## Rate Limits & Safety

- Wait 2-3 seconds between interactions
- Max once per 2 hours (job alerts cover real-time)
- WellFound is less aggressive than LinkedIn — lower bot detection risk

---

## Error Handling

| Error | Action |
|-------|--------|
| Not logged in | Stop, request manual login |
| Filters not applied | Click saved search menu |
| Empty results | Report, check if filters changed |

---

## Notes

- "Recruiter recently active" + "Top X% of responders" = high response likelihood
- Equity-only roles: only consider if founders have proven exits AND salary expected within ≤2 months
- Cross-reference company page for funding stage and team size

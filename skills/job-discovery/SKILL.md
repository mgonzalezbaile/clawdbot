---
name: job-discovery
description: Proactive job discovery orchestrator — searches platforms, dedupes, and adds matching jobs to Notion pipeline.
metadata: {"moltbot":{"emoji":"🔍"}}
---

# Job Discovery Orchestrator

Proactively search job platforms for roles matching profile and expectations, deduplicate results, and add new opportunities to the Notion pipeline.

> **⚠️ Before searching:** Read `/Users/maikel/Library/CloudStorage/GoogleDrive-m.gonzalezbaile@gmail.com/My Drive/Work/Job Hunting/job-criteria.md` for the latest job criteria, filtering nuances, and profile references. That file is the source of truth — the inline criteria below are a quick reference only.

## Search Criteria

**Target Roles:**
- CTO
- VP of Engineering
- Head of Engineering
- Director of Engineering
- Head of AI / AI Lead (with leadership scope)
- Fractional/Advisory CTO (if AI-focused)

**Hard Requirements:**
- ✅ Full remote (European timezone compatible)
- ❌ No hybrid
- ❌ No on-site

**Hard Skip:**
- ❌ IC roles (Senior/Staff Engineer) — leadership only
- ❌ Data-focused roles (Data Eng Manager, Analytics Lead) — want product/customer-facing
- ❌ Language requirements (Italian, German, French, etc.)
- ❌ Blockchain/Crypto focus (not expertise area)
- ❌ Revenue-sharing consulting arrangements

**Equity-Only Rules:**
- Only if founders have **proven exits**
- AND salary expected within **≤2 months**
- Otherwise → Skip

**Preferred:**
- European companies/startups/scaleups
- Series A+ (funded), 50+ employees
- Product-focused, customer-facing scope
- AI/ML companies or AI-native products

**Tech/Domain Fit:**
- AI/ML companies or AI-native products
- Developer tools / platforms
- Health-tech, fintech (has experience)
- B2B SaaS

---

## Workflow

### Step 1: Load Existing Pipeline

Query Notion to get all existing job URLs (avoid duplicates):

```bash
NOTION_KEY=$(cat ~/.config/notion/api_key)
curl -s -X POST "https://api.notion.com/v1/data_sources/daef0884-0fdd-4fc3-a6be-fa4300548dc6/query" \
  -H "Authorization: Bearer $NOTION_KEY" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d '{}' | jq -r '.results[].properties.URL.url // empty' | sort -u
```

Store these URLs in memory for deduplication.

### Step 2: Spawn Platform Searches

Spawn sub-agents for each enabled platform:

```
sessions_spawn:
  task: "Search WellFound for CTO/VP Engineering roles. Return JSON array of {role, company, url, location, remote}. Only include FULL REMOTE roles. Use job-search-wellfound skill."
  label: "job-search-wellfound"
  
sessions_spawn:
  task: "Search Welcome to the Jungle for CTO/VP Engineering roles. Return JSON array of {role, company, url, location, remote}. Only include FULL REMOTE roles. Use job-search-welcometothejungle skill."
  label: "job-search-wttj"
```

**Note:** Spawned agents run in parallel and report back when done.

### Step 3: Collect & Deduplicate Results

When sub-agents return:
1. Parse JSON arrays from each platform
2. Filter out URLs already in Notion pipeline
3. Filter out non-remote roles (if any slipped through)
4. Merge into single candidate list

### Step 4: Assess Fit & Add to Notion

For each new job:

1. **Quick fit assessment** based on title and company:
   - Strong: Exact title match + known good company
   - Good: Related title or interesting company
   - Weak: Stretch role or uncertain fit
   - Blocker: On-site/hybrid mentioned, or clear mismatch

2. **Add to Notion:**
```bash
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
      "URL": {"url": "<URL>"}
    }
  }'
```

### Step 5: Report Summary

Send summary to Maikel:
```
🔍 Job Discovery Complete

Found X new opportunities:
• [Role] at [Company] — [Fit]
• [Role] at [Company] — [Fit]
...

Added to Notion pipeline. Review at: https://notion.so/eaedf5e63b8e4454bbcf00f5a72abf23
```

---

## Scheduling (Cron)

Recommended: Run every 2-4 hours during business hours.

Example cron job (every 3 hours, 9am-6pm CET):
```json
{
  "name": "job-discovery",
  "schedule": {"kind": "cron", "expr": "0 9,12,15,18 * * 1-5", "tz": "Europe/Madrid"},
  "payload": {
    "kind": "agentTurn",
    "message": "Run job discovery. Use the job-discovery skill to search all enabled platforms, dedupe against existing pipeline, and add new matches to Notion."
  },
  "sessionTarget": "isolated"
}
```

---

## Platform Skills

| Platform | Skill | Status | Automation |
|----------|-------|--------|------------|
| WellFound | `job-search-wellfound` | ✅ Active | Cron (3x daily) |
| LinkedIn | `job-search-linkedin` | ✅ Active | Manual only (bot detection) |
| Welcome to the Jungle | `job-search-welcometothejungle` | 🚧 TODO | — |
| Otta | `job-search-otta` | 🚧 TODO | — |

---

## Manual Trigger

User can also trigger manually:
> "Search for new jobs" or "Run job discovery"

---

## Rate Limiting & Safety

- Don't run more than once per hour (platform rate limits)
- If a platform fails, continue with others
- Log errors but don't alert unless all platforms fail
- Respect robots.txt and platform ToS where possible

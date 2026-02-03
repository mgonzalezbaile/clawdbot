---
name: ch3-techcrunch
description: Channel 3 funded startups radar — scrape TechCrunch for recently funded European startups, research each via LinkedIn (eng leadership, open roles, remote policy, AI focus), score match quality, and update Notion pipeline. Use for weekly funded startup discovery scans from TechCrunch.
---

# ch3-techcrunch

Scrape TechCrunch for recently funded European startups, research each company, and populate the Notion Funded Startups Radar.

## Pipeline

Same 6-step pipeline as ch3-eu-startups. Read that skill for full details on steps 2-6:
`/Users/maikel/Workspace/Learning/clawdbot/skills/ch3-eu-startups/SKILL.md`

This skill only documents **Step 1 differences** (scraping) and source-specific notes.

### 1. Scrape TechCrunch

Try `web_fetch` first. If blocked, fall back to browser (profile: `clawd`).

**Funding news pages:**
- `https://techcrunch.com/category/venture/` — main venture/funding category
- `https://techcrunch.com/tag/europe/` — Europe-tagged articles

**Scraping approach:**
1. Fetch the venture category page
2. Extract article titles, dates, and summaries
3. Filter for European startup funding rounds (not US, not VC fund closes, not analysis)
4. For relevant articles, fetch individual pages for full details
5. Extract: company name, funding amount, stage, country, description

**Filtering tips:**
- TechCrunch covers heavily US — filter strictly for European companies
- Look for keywords: "raises", "secures", "closes", "funding", "round" + European cities/countries
- Skip: VC fund announcements, acquisitions, product launches, opinion pieces

### Notion Database

Same as ch3-eu-startups:
```
database_id: 2f8ff60b-2f4d-81a2-badb-df0e6b8fdb96
API version: 2022-06-28
```

Set `Source` field to `"TechCrunch"`.

### Scan State

Track in `memory/ch3-scan-state.json` under key `"techcrunch"`.

### Important Notes

- TechCrunch is US-heavy — expect most articles to be irrelevant (US companies)
- Quality over quantity: fewer but larger/more established European rounds
- May have registration walls — if blocked, report and stop
- **Never send outreach without Maikel's approval**

---
name: ch3-eu-startups
description: Channel 3 funded startups radar — scrape EU-Startups.com funding articles, extract newly funded European startups, research each via LinkedIn (eng leadership, open roles, remote policy, AI focus), score match quality, and update Notion pipeline. Use for weekly funded startup discovery scans.
---

# ch3-eu-startups

Scrape EU-Startups.com for recently funded startups, research each company, and populate the Notion Funded Startups Radar.

## Pipeline

### 1. Scrape EU-Startups.com

Fetch the funding/news section for recent articles about startup funding rounds.

- URL: `https://www.eu-startups.com/category/funding/`
- Extract: company name, amount raised, stage, country/city, description, article URL
- Use `web_fetch` for article listing and individual articles
- Focus on European startups only
- Look for articles published since last scan (track in `memory/ch3-scan-state.json`)

### 2. Dedupe Against Notion

Query the Funded Startups Radar database before adding:

```
database_id: 2f8ff60b-2f4d-81a2-badb-df0e6b8fdb96
API version: 2022-06-28 (required — 2025-09-03 has property issues with this DB)
```

Check by company name. Skip if already exists.

### 3. Research Each Company (Browser/LinkedIn)

For each new company, use the browser (profile: `clawd`) to research on LinkedIn:

1. **Find company LinkedIn page** — search LinkedIn for the company
2. **Check eng leadership** — browse People tab, search for CTO / VP Eng / Head of Eng
3. **Check open eng leadership roles** — browse Jobs tab
4. **Check team size and growth** — from company page insights
5. **Assess remote/hybrid policy** — from job listings or About page
6. **Confirm AI relevance** — from company description and product

### 4. Score Match

Apply criteria to determine match quality:

| Criteria | Strong | Investigate | Weak | Skip |
|----------|--------|-------------|------|------|
| No eng leader | ✅ | Unclear | Has one | — |
| Scaling/growing | ✅ | Maybe | Stable | Shrinking |
| AI-related product | ✅ | Adjacent | No | — |
| Salary viability (€120k+) | Series A+ or large Seed (>€5M) | Seed €2-5M | Pre-seed | — |
| Remote/hybrid OK | ✅ | Unknown | On-site only | — |

Assign: Strong (4-5 ✅), Investigate (2-3), Weak (0-1), Skip (blockers like on-site only or tiny raise)

### 5. Update Notion

Create page in Funded Startups Radar with all fields:

```
Properties:
- Company (title)
- Raised (rich_text): e.g. "€6.4M"
- Stage (select): Pre-Seed, Seed, Series A, Series B, Growth
- What (rich_text): Company description
- Match (select): Strong, Investigate, Weak, Skip
- Location (rich_text): City
- Country (select)
- Has Eng Leader (select): Yes, No, Unknown
- Status (select): "New" for automated entries
- CEO Founder (rich_text)
- URL (url): Article or company URL
- Notes (rich_text): Research findings, open roles, remote policy
- Source (rich_text): "EU-Startups"
- Date Found (date): Today's date
```

### 6. Notify Maikel

After completing all research, send a summary to the main session:

```
🔭 Weekly Startup Radar — EU-Startups Scan

Scanned: X articles | New companies: Y | Skipped (dupes): Z

🔥 Strong matches:
- CompanyName (€Xm Series A, Barcelona) — No CTO, AI product, hiring eng lead

🔍 Investigate:
- CompanyName (€Xm Seed, Berlin) — Unknown eng leader, AI-adjacent

Ready for your review in Notion.
```

**Do NOT send outreach without Maikel's explicit approval.** Always show message content before sending.

## Scan State

Track last scan date in `memory/ch3-scan-state.json`:

```json
{
  "lastScan": "2026-01-30",
  "lastArticleUrl": "https://eu-startups.com/...",
  "companiesScanned": 14
}
```

## Important Notes

- Use `Notion-Version: 2022-06-28` for this database (not 2025-09-03)
- LinkedIn research uses browser profile `clawd`
- Rate limit LinkedIn browsing — don't rush through dozens of searches
- If LinkedIn blocks or shows captcha, stop and report
- Batch size: process up to 15 companies per scan to avoid timeouts

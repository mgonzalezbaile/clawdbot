---
name: ch3-sifted
description: Channel 3 funded startups radar — scrape Sifted.eu for recently funded European startups, research each via LinkedIn (eng leadership, open roles, remote policy, AI focus), score match quality, and update Notion pipeline. Use for weekly funded startup discovery scans from Sifted.
---

# ch3-sifted

Scrape Sifted.eu for recently funded startups, research each company, and populate the Notion Funded Startups Radar.

## Pipeline

Same 6-step pipeline as ch3-eu-startups. Read that skill for full details on steps 2-6:
`/Users/maikel/Workspace/Learning/clawdbot/skills/ch3-eu-startups/SKILL.md`

This skill only documents **Step 1 differences** (scraping) and source-specific notes.

### 1. Scrape Sifted.eu

Sifted is **Cloudflare-protected** — use browser (profile: `clawd`) instead of `web_fetch`.

**Funding news page:** `https://sifted.eu/articles?sector=&stage=&type=funding-news`

Alternative if that doesn't work: `https://sifted.eu/sector/funding`

**Scraping approach:**
1. Open the funding news page in browser
2. Take snapshot to read article listings
3. For each article: extract company name, funding amount, stage, country, description
4. Click into individual articles if listing doesn't have enough detail
5. Scroll/paginate to find articles since last scan

**Extract per company:**
- Company name
- Amount raised
- Funding stage (Pre-Seed, Seed, Series A, B, Growth)
- Country / city
- Short description of what they do
- Article URL

### Notion Database

Same as ch3-eu-startups:
```
database_id: 2f8ff60b-2f4d-81a2-badb-df0e6b8fdb96
API version: 2022-06-28
```

Set `Source` field to `"Sifted"`.

### Scan State

Track in `memory/ch3-scan-state.json` under a separate key:

```json
{
  "sifted": {
    "lastScan": "2026-01-30",
    "lastArticleUrl": "...",
    "companiesScanned": 0
  }
}
```

### Match Criteria

Same as ch3-eu-startups:
- No eng leader (CTO, VP/Head of Eng)
- Scaling, needs leadership
- AI-related product
- Salary viability (€120k+ — Series A+ or large Seed)
- Open to remote or hybrid (no fully on-site)

### Important Notes

- Sifted often covers larger rounds (Series A+) — higher salary viability
- Sifted articles are more detailed — may get enough info without LinkedIn for initial filtering
- If Cloudflare blocks the browser too, report and stop
- Batch size: up to 15 companies per scan
- **Never send outreach without Maikel's approval**

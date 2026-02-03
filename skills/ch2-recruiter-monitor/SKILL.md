---
name: ch2-recruiter-monitor
description: Channel 2 recruiter pipeline monitor — daily scan of emails for recruiter replies, proactive follow-up on stale contacts, draft responses, update Notion pipeline, and notify Maikel. Use for automated recruiter outreach management.
---

# ch2-recruiter-monitor

Daily monitor for the recruiter pipeline. Three jobs: check inbound, trigger follow-ups, notify Maikel.

## Notion Database

```
database_id: 2f8ff60b-2f4d-8132-ae81-d305e4965a12
API version: 2022-06-28
```

## Job 1: Check Inbound

### 1a. Scan Gmail for Replies

Query Notion for all contacts with status != "Not Contacted" and != "Not a Fit". Build a search from their email domains and firm names.

```bash
gog gmail messages search 'newer_than:1d from:(techstaq.io OR nederlia.com OR acelr8.com OR orange-quarter.com OR ...)' --max 20 --account m.gonzalezbaile@gmail.com
```

Also check for LinkedIn connection acceptances:
```bash
gog gmail messages search 'newer_than:1d from:linkedin.com "accepted your invitation"' --max 20 --account m.gonzalezbaile@gmail.com
```

### 1b. Process Replies

For each new email:
1. Read full message: `gog gmail get <messageId>`
2. Read thread context if needed
3. Draft a reply (see Drafting Rules below)
4. Create draft in Gmail: `gog gmail drafts create --to <email> --subject "RE: ..." --body-file /tmp/reply.txt --reply-to-message-id <msgId> --account m.gonzalezbaile@gmail.com`
5. Update Notion: status, last contact date, next action, notes

## Job 2: Proactive Follow-ups

Query Notion and check `Last Contact` date against today. Apply these rules:

| Current Status | Days Since Last Contact | Action |
|----------------|------------------------|--------|
| Connection Sent | ≥ 7 days | If email available: draft follow-up email. If not: flag to try different channel. |
| Connected | ≥ 2 days | Draft follow-up message (use template from outreach-strategy.md) |
| Responded | ≥ 5 days (no reply from us) | Flag as URGENT — we're leaving them hanging |
| Messaged | ≥ 7 days | Draft polite follow-up nudge |
| Call Scheduled | Day of/after call | Remind Maikel to update status post-call |

For each follow-up needed:
1. Check if there's already a pending Gmail draft for this contact — skip if so
2. Read outreach strategy for templates: `/Users/maikel/Library/CloudStorage/GoogleDrive-m.gonzalezbaile@gmail.com/My Drive/Work/Job Hunting/Recruiter Search/outreach-strategy.md`
3. Draft the follow-up in Gmail (do NOT send)
4. Update Notion: Next Action with what was drafted

### Follow-up Guidelines

**Connection Sent (7+ days, no acceptance):**
- If we have their email → draft a brief email introducing ourselves, mention we also sent a LinkedIn request
- If no email → update Next Action: "Try alternative channel (email/referral)"

**Connected (2+ days, not yet messaged):**
- Draft the follow-up message from outreach-strategy.md templates
- Personalize based on their firm and focus area

**Messaged (7+ days, no response):**
- Keep it short and low-pressure
- "Hi [Name], just following up on my previous message. No rush — happy to connect whenever timing works on your end."

## Job 3: Notify Maikel

Send summary to main session:

```
📬 Recruiter Pipeline — Daily Update

📥 New replies (X):
- Name (Firm) — What they said. Draft reply in Gmail.

⏰ Follow-ups needed (X):
- Name (Firm) — Status for Y days. Draft created / Action needed.

🚨 Urgent (X):
- Name (Firm) — Responded X days ago, no reply from us yet!

📊 Pipeline snapshot:
- Connected: X | Awaiting response: X | Active conversations: X
```

## Drafting Rules

1. Read Maikel's profile for context: `/Users/maikel/Library/CloudStorage/GoogleDrive-m.gonzalezbaile@gmail.com/My Drive/Work/Job Hunting/CVs/About Me.md`
2. Read outreach strategy for tone: `/Users/maikel/Library/CloudStorage/GoogleDrive-m.gonzalezbaile@gmail.com/My Drive/Work/Job Hunting/Recruiter Search/outreach-strategy.md`
3. **NEVER send emails or LinkedIn messages** — only create Gmail drafts
4. Keep replies professional but warm, not corporate
5. Align with Maikel's preferences: AI-first preferred, remote/hybrid, European, leadership roles
6. Keep doors open even when a specific role isn't ideal
7. If they want to schedule a call, suggest it but let Maikel confirm timing

## Gmail Account

`m.gonzalezbaile@gmail.com`

---
name: orbit-morning-plan
description: Generate prioritized daily plan with reasoning
metadata: |
  {
    "clawdbot": {
      "emoji": "🌅"
    }
  }
user-invocable: true
disable-model-invocation: false
---

# Morning Daily Plan

You are generating Orbit's **Morning Daily Plan**, a structured daily plan that transforms available tasks into a prioritized, actionable sequence for the day.

## When to Execute This Skill

**User Triggers:**
- User says: "morning plan", "plan my day", "what should I do today"
- User requests today's plan or daily planning

**Proactive Triggers:**
- Automatic morning greeting (scheduled via heartbeat)
- Start of user's working day

## Process Steps

Execute the following steps in order to generate the daily plan:

### Step 0: Load Project Context

Read all `.md` files from `/Users/maikel/Workspace/backlog/ongoing-projects/`. These are strategic overviews of each ongoing project — goal, current state, strategy, and what's next.

Orient yourself on the strategic landscape before looking at individual tasks. This context informs your prioritization reasoning: you understand **why** tasks matter, not just what they are.

### Step 1: Retrieve All Ready Tasks

Use `memory_search` to find all tasks with status **Ready** or **Planned**:

```
memory_search({
  query: "status:Ready OR status:Planned task",
  maxResults: 20,
  minScore: 0.3
})
```

### Step 2: Load Full Task Details

For each task found in Step 1, use `memory_get` to load complete task information including:
- Title
- Description
- Eisenhower Matrix quadrant (Q1, Q2, Q3, Q4)
- Due date (if any)
- Area (Work, Health, Learning, etc.)
- Dependencies (blocked by, blocks)
- Resume context (if task was "In Progress" yesterday)

### Step 3: Apply Prioritization Logic

Prioritize tasks using the following decision hierarchy:

**Priority Order:**

1. **Q1 (Urgent & Important) with due date TODAY** - Highest priority
2. **Q1 (Urgent & Important) with due date THIS WEEK** - High priority
3. **Carried over from yesterday** - Tasks that were planned but not completed
4. **Q2 (Not Urgent but Important) supporting active goals** - Strategic work
5. **Q1 tasks without deadlines** - Important but less time-sensitive
6. **Tasks with dependencies blocking other work** - Unblock others
7. **Q2 tasks with approaching deadlines** - Proactive planning
8. **Q3/Q4 tasks only if capacity remains** - Low priority

**Additional Considerations:**
- If a task has a resume context (checkpoint from yesterday), prioritize it higher within its quadrant
- Balance across Areas (don't overload one area)
- Respect energy and time constraints
- Flag conflicts (overlapping deadlines, resource constraints)
- Consider task dependencies (do blocking tasks first)

### Step 4: Generate Ordered Plan with Reasoning

Structure the plan exactly as shown below:

```markdown
## Today's Plan - {current date}

### Priority Sequence

1. **[Task Title]** - Q1, due today
   *Why:* Critical deadline; blocks delivery of [project/goal]. Moved to top position.

2. **[Task Title]** - Q1, carried over from yesterday
   *Why:* Postponed twice this week; addressing now prevents further drift.
   *Resume:* Left off at [checkpoint]. Next: [specific action].

3. **[Task Title]** - Q2, supports [goal name]
   *Why:* Strategic investment in [area]; no urgent tasks conflict with this slot.

4. **[Task Title]** - Q1, due this week
   *Why:* Three days remaining; completing today creates buffer for review.

### Reasoning Summary

[2-3 sentence explanation of overall prioritization logic, key tradeoffs made, and any conflicts detected]

Example:
"Prioritized Q1 deadlines first, then strategically scheduled Q2 work during expected afternoon focus time. Deferred two Q3 tasks to preserve capacity for unexpected issues. One conflict detected: Tasks #2 and #5 both require the staging environment."

### Resume Contexts

[Only include if applicable]

- **[Task Title]**: Left off at [checkpoint]. Next action: [specific step]
- **[Task Title]**: Blocked on [dependency]. Follow up with [person/system]

### Carried Over

[Only include if applicable]

- [Task] - Planned yesterday, not started
- [Task] - Started yesterday, needs completion

### Available but Not Planned

[List 3-5 lower priority tasks that are Ready but not selected for today]

- **[Task Title]** - Q2, no deadline
- **[Task Title]** - Q3, low impact
- **[Task Title]** - Q2, blocked by [dependency]
```

## Step 5: Present Plan for User Validation

After generating the plan, present it to the user and invite feedback:

**Template:**
```
[Insert generated plan above]

---

This plan prioritizes [brief summary]. You can:
- **Approve** - Lock in this sequence
- **Modify** - Adjust order or swap tasks
- **Challenge** - Question my reasoning

What would you like to do?
```

## Step 6: Handle User Feedback

**If user approves:**
- Mark selected tasks as **Planned** (update status)
- Store the final plan in `memory/daily/{date}.md`
- Confirm: "Plan locked in. I'll check in during the day."

**If user modifies:**
- Apply requested changes
- Re-explain reasoning for affected tasks
- Present updated plan for re-approval

**If user challenges:**
- Defend your reasoning using the prioritization logic from Step 3
- Explain tradeoffs explicitly
- Offer alternatives if user's challenge is valid
- Iterate until agreement is reached
- Be assertive but respectful; you may push back if user's override conflicts with strategic priorities

**Example Challenge Response:**
```
I understand you want to prioritize [Task X] first, but that would push [Task Y] (Q1, due today) to later in the day. If [Task X] takes longer than expected, we risk missing the deadline on [Task Y].

Would you prefer to:
1. Keep [Task Y] first and schedule [Task X] for tomorrow
2. Split [Task Y] into a smaller deliverable today
3. Accept the risk and proceed with [Task X] first

What do you think?
```

## Step 7: Post-Approval Actions

Once the user approves the final plan:

1. **Update task statuses:**
   - Set selected tasks to `status: Planned`
   - Leave unselected Ready tasks as `status: Ready`

2. **Store the plan:**
   - Save the full plan to `memory/daily/{YYYY-MM-DD}.md`
   - Include: ordered sequence, reasoning, resume contexts, and timestamp

3. **Confirm to user:**
   ```
   Plan saved. I'll monitor progress and check in during the day.
   ```

## Reasoning Transparency Rules

Follow these transparency guidelines from Section 14 of the Orbit PRD:

**Always Include (Default):**
- Brief *Why* reasoning for each task in the sequence (1 sentence)
- Reasoning Summary paragraph (2-3 sentences)
- Identification of conflicts or tradeoffs

**Only When Asked:**
- Deep reasoning (full decision tree)
- Alternative sequences considered
- Detailed scoring methodology
- Confidence levels for each decision

**User Controls:**
User may say:
- "Why this order?" → Provide detailed prioritization logic
- "Explain the reasoning" → Show full decision-making process
- "Show alternatives" → Present 2-3 alternative sequences with pros/cons
- "Compare X vs Y" → Explain tradeoff between specific tasks

## Important Notes

**Task Context Continuity:**
- If a task has a resume context (checkpoint from previous session), always highlight it in the plan
- Resume contexts help users pick up where they left off without cognitive overhead

**Proactive Behavior:**
- This skill executes automatically in the morning (via heartbeat scheduling)
- Also available on-demand when user requests it
- Morning plans are part of Orbit's Daily Operating Loop (Section 11)

**Assertive Guidance:**
- You are allowed to challenge user's task selections
- Push back when priorities conflict with strategic goals
- Defend your reasoning but adapt when user provides valid counter-arguments
- Your role is disciplined thinking partner, not passive task list generator

**Data Integrity:**
- Never modify task data without user approval
- Always confirm before changing task statuses
- Preserve historical context when updating plans

## Example Morning Plan

```markdown
## Today's Plan - January 25, 2026

### Priority Sequence

1. **Finalize Q4 investor deck** - Q1, due today 5pm
   *Why:* Hard deadline for board meeting. Highest priority; blocks nothing else.

2. **Debug API authentication layer** - Q1, carried over from yesterday
   *Why:* Blocking production deployment since Monday. Already postponed twice.
   *Resume:* Left off checking token expiration logic in `auth/middleware.ts`. Next: Test with staging credentials.

3. **Draft hiring plan for engineering team** - Q2, supports Growth goal
   *Why:* Strategic work; Q1 capacity allows 2-hour block this afternoon. Aligns with quarterly planning cycle.

4. **Review PRs from team** - Q1, due this week
   *Why:* Three PRs waiting >24h; unblocking team creates velocity. Scheduled before standup.

### Reasoning Summary

Prioritized today's hard deadline first, then addressed carried-over blocker that has drifted for two days. Scheduled strategic Q2 work (hiring plan) in the afternoon when focus is typically available. PR review placed early to unblock the team before standup. Deferred two Q3 tasks (update documentation, organize design files) to preserve capacity for unexpected issues.

### Resume Contexts

- **Debug API authentication layer**: Left off checking token expiration logic in `auth/middleware.ts`. Next: Test with staging credentials and verify refresh flow.

### Carried Over

- Debug API authentication layer - Started yesterday, needs completion today

### Available but Not Planned

- **Update API documentation** - Q3, no deadline
- **Organize Figma design files** - Q3, low impact
- **Research new analytics tools** - Q2, blocked by budget approval
- **Refactor legacy codebase** - Q2, no deadline
- **Schedule 1:1s with reports** - Q2, due next week

---

This plan prioritizes today's deadline and unblocks critical production work first, then allocates focused time for strategic hiring planning. You can:
- **Approve** - Lock in this sequence
- **Modify** - Adjust order or swap tasks
- **Challenge** - Question my reasoning

What would you like to do?
```

## Summary

This skill transforms available tasks into a strategic, prioritized daily plan that:
- Focuses on high-value work (Q1 first, then Q2)
- Surfaces conflicts and tradeoffs explicitly
- Provides reasoning transparency
- Enables collaborative refinement through user feedback
- Maintains task continuity with resume contexts
- Supports Orbit's role as a disciplined Chief of Staff

Execute this skill proactively each morning and on-demand when the user requests daily planning.

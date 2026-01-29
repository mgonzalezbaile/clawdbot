---
name: orbit-end-of-day
description: Daily closure - review progress, capture learnings, prepare tomorrow
metadata: |
  {
    "clawdbot": {
      "emoji": "🌙"
    }
  }
user-invocable: true
disable-model-invocation: false
---

# End of Day Audit

## Purpose

The End-of-Day Audit is a critical daily ritual in Orbit's operating loop. It closes the execution cycle by reviewing what was achieved, what was not, and why—ensuring no loose ends accumulate and that tomorrow's plan is fully informed by today's reality.

This skill transforms daily outcomes into strategic learning and maintains the integrity of your task system.

## When to Use

### User Triggers
- User says: "end of day", "daily review", "close the day", "wrap up today"
- User asks: "what did I do today", "how was my progress", "daily summary"
- User initiates: "let's review the day", "daily audit"

### System Triggers
- Automatic proactive prompt in the evening window (default: 6-8 PM)
- Can be manually triggered at any time for early closure

## Core Process

Follow this structured flow to ensure thorough daily closure:

### Step 1: Load Today's Plan

Read the daily plan file from memory:
```
memory/daily/{YYYY-MM-DD}.md
```

This file contains:
- The planned task sequence for today
- Reasoning for task selection and ordering
- Any mid-day adjustments or context changes

**If no plan exists**: Ask the user to briefly recall what they worked on today and proceed with a simplified review.

### Step 2: Task Status Collection

For each planned task, ask the user for its current status. Present tasks one at a time or in small batches (3-5 tasks) to avoid overwhelming the user.

**For each task, ask:**
> "**[Task Title]** — How did this go today?"

### Step 3: Status-Specific Handling

Process each response according to its status:

#### Status: Completed ✅
- **Action**: Mark task as Done in the task system
- **Response**: Brief positive acknowledgment
- **Example**: "Great. Marked as complete."

#### Status: In Progress 🔄
- **Action**: Capture Resume Context (critical for continuity)
- **Ask sequentially**:
  1. **"Where did you leave off?"** — Capture the last concrete state/action
  2. **"What's the immediate next step when you return to this?"** — Capture the reentry point
  3. **"Any open questions or thoughts to remember?"** — Capture mental context

**Store Resume Context** in the task's metadata or a dedicated resume checkpoint file:
```markdown
### Resume Context - {Task Title}
- **Last State**: [where user stopped]
- **Next Action**: [first step when resuming]
- **Mental Context**: [open questions, thoughts, blockers]
- **Captured**: {YYYY-MM-DD HH:mm}
```

**Purpose**: These checkpoints feed directly into tomorrow's Morning Plan, allowing instant rehydration of context without cognitive overhead.

#### Status: Not Started ⏸️
- **Action**: Ask for decision on the task's future
- **Ask**: "This wasn't started today. Should we:"
  - **Reschedule** → "When should this be planned?"
  - **Deprioritize** → "Move to backlog/Discovery?"
  - **Cancel** → "Is this task still relevant?"

Record the decision and apply the appropriate state change.

#### Status: Blocked 🚧
- **Action**: Capture blocker details
- **Ask**:
  1. "What's blocking this task?"
  2. "Can this blocker be resolved, or does the task need to return to Discovery?"

Create or update blocker metadata for the task.

### Step 4: Capture Insights and Learnings

After reviewing all tasks, ask:

> "Before we close — any insights, observations, or learnings from today?"

**Examples of valuable insights**:
- "I underestimated the time needed for X"
- "Y task revealed a dependency on Z"
- "I'm consistently avoiding tasks in [Area]"
- "This approach worked well and should be repeated"

**Store insights** in the daily review file and consider flagging patterns for future accountability discussions.

### Step 5: Pattern Detection (System Accountability)

Analyze task outcomes to identify patterns:

- **Repeated postponements**: "You've rescheduled this task 4 times. Should we re-scope or cancel it?"
- **Neglected areas**: "No Work tasks have been started this week. Is this intentional?"
- **Chronic blockers**: "This task has been blocked for 3 days. Should it return to Discovery?"
- **Overcommitment**: "You planned 8 tasks but only completed 2. Should we adjust tomorrow's plan?"

**Surface these patterns respectfully but directly**. The goal is sustained discipline, not pressure.

### Step 6: Prepare Tomorrow's Focus

Based on today's outcomes, propose initial priorities for tomorrow:

**Ask**:
> "What should be the top focus for tomorrow?"

**System proposes** (based on):
- Carried-over In Progress tasks (with Resume Context)
- High-priority uncompleted tasks
- Approaching deadlines
- Q1/Q2 priorities from Eisenhower Matrix

**Collaborate** with the user to refine the tentative plan. This feeds directly into tomorrow's Morning Plan generation.

### Step 7: Update Project Overviews

Read all `.md` files from `/Users/maikel/Workspace/backlog/ongoing-projects/`. For each project that had progress today (tasks completed, state changes, new insights, strategic shifts), update the corresponding file:

- Update the **Current State** and **What's Next** sections to reflect today's reality
- Keep updates concise and strategic — details live in Notion tasks, these files are the bird's-eye view
- If a new project emerged today that doesn't have a file, create one following the same structure

## Output Format

Generate a structured daily review document and save it to:
```
memory/daily/{YYYY-MM-DD}-review.md
```

**Template**:

```markdown
## End of Day Review - {YYYY-MM-DD}

### Completed ✅
- [Task Title 1]
- [Task Title 2]

### In Progress 🔄
- **[Task Title 3]**
  - Resume: [captured next step]
  - Last State: [where user stopped]
  - Mental Context: [open questions]

### Rescheduled 📅
- **[Task Title 4]** → {new-date}
  - Reason: [why it was rescheduled]

### Not Started ⏸️
- **[Task Title 5]** — [Decision: moved to backlog / cancelled / rescheduled]

### Blocked 🚧
- **[Task Title 6]**
  - Blocker: [description]
  - Next Action: [how to resolve or return to Discovery]

### Insights & Learnings
[User observations, patterns detected by system, notes for improvement]

### Tomorrow's Initial Focus
1. [Priority Task 1] (carryover with resume context)
2. [Priority Task 2] (deadline approaching)
3. [Priority Task 3] (Q1 importance)

---

**Patterns Noted**:
- [Any accountability observations, e.g., "3rd postponement of Marketing tasks this week"]

**System Health**:
- {X} tasks completed today
- {Y} tasks carried forward
- {Z} tasks rescheduled/cancelled
```

## Post-Review Actions

After completing the audit:

1. **Update Task States** in the task management system (Notion/memory):
   - Mark completed tasks as Done
   - Update In Progress tasks with Resume Context metadata
   - Apply rescheduling decisions
   - Set cancelled/archived states

2. **Store the Review File** at `memory/daily/{YYYY-MM-DD}-review.md`

3. **Note Patterns for Accountability**:
   - Track repeated postponements for future discussion
   - Log neglected areas for strategic review
   - Record insights for long-term memory storage

4. **Prepare for Morning Plan**:
   - The review file feeds directly into tomorrow's plan generation
   - Resume Contexts enable instant task rehydration
   - Carried-over tasks inherit priority adjustments

## Connection to Tomorrow

The End-of-Day Audit is the critical bridge between today and tomorrow:

- **Carried Over Tasks**: In Progress tasks flow into tomorrow's plan with full context
- **Adjusted Priorities**: Reality-based updates (delays, blockers, insights) inform scheduling
- **Resume Contexts**: Eliminate "where was I?" friction when starting work
- **Pattern Awareness**: Accountability observations shape strategic decisions

**Morning Plan Generation** uses the review file to:
- Propose realistic task loads based on actual completion rates
- Surface resume contexts prominently for In Progress tasks
- Challenge repeated postponements during planning dialogue
- Adjust priorities based on yesterday's learnings

## Tone and Style

**Structured but conversational**: Present the audit as a collaborative reflection, not an interrogation.

**Firm but supportive**: Surface accountability patterns clearly, but without judgment or pressure.

**Pragmatic**: Focus on actionable outcomes (decisions, context capture, tomorrow's focus) rather than lengthy reflection.

**Respectful of autonomy**: The user makes all final decisions. Your role is to guide, challenge when appropriate, and ensure nothing falls through the cracks.

**Example Exchange**:

> **Orbit**: "Let's close out the day. I see you planned 5 tasks today. Starting with **Finalize Q1 budget** — how did this go?"
>
> **User**: "Got halfway through. Need to finish tomorrow."
>
> **Orbit**: "Understood. Where did you leave off?"
>
> **User**: "Completed revenue projections, still need to do expense breakdown."
>
> **Orbit**: "Got it. What's the immediate next step when you return to this?"
>
> **User**: "Pull last quarter's expense data and categorize it."
>
> **Orbit**: "Perfect. Any open questions or blockers to note?"
>
> **User**: "Need to confirm with finance if we're using the same categories."
>
> **Orbit**: "Noted. I'll highlight that tomorrow. Moving to **Client proposal review** — how did this go?"

## Edge Cases

### No Plan Exists
If the user didn't start the day with a plan (or skipped it):
- Ask: "What did you work on today?"
- Capture tasks retroactively and review them
- Use this as a gentle reminder of the value of morning planning

### User Ends Day Early
If triggered mid-afternoon:
- Acknowledge the early closure
- Ask if remaining planned tasks should be rescheduled or carried to a different day
- Proceed with normal audit flow

### User Didn't Complete Anything
If no tasks were completed:
- Don't guilt or pressure
- Ask: "What got in the way today?" (gather context)
- Identify if tasks were unrealistic, if new priorities emerged, or if there were external blockers
- Use this as input for tomorrow's plan (smaller scope, more realistic load)

### Too Many Tasks to Review
If the daily plan had >10 tasks:
- Batch them by status if possible ("Which of these are complete?")
- Focus detailed Resume Context capture only on the most critical In Progress tasks
- Simplify the audit to avoid user fatigue

## Integration with Other Systems

- **Morning Plan**: The review file is the primary input for tomorrow's plan generation
- **Memory System**: Insights and learnings should be stored in long-term memory via `memory_search` and curated into `MEMORY.md`
- **Weekly Review**: Repeated patterns (postponements, neglected areas) feed into Sunday's system hygiene ritual
- **Task Management**: All state changes must be persisted to the source of truth (Notion, memory, etc.)

## Success Criteria

A successful End-of-Day Audit achieves:
1. ✅ All planned tasks have a known status
2. ✅ In Progress tasks have captured Resume Contexts
3. ✅ All rescheduling/cancellation decisions are made and applied
4. ✅ Insights and learnings are captured
5. ✅ Tomorrow's initial priorities are identified
6. ✅ The review file is saved and ready for morning planning
7. ✅ No loose ends remain from today's execution

---

**Remember**: The End-of-Day Audit is not about perfection. It's about ensuring that every day closes with clarity, that lessons are captured, and that tomorrow starts with full context and realistic priorities.

You are maintaining the operational heartbeat of Orbit's Delivery Mode.

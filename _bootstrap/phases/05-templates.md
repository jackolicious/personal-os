# Phase 5: Profile and Templates
_Depends on: Phase 1 (directories must exist)_

## Preference modules

Read `_bootstrap/interview-answers.md` before creating these files — use the answers to pre-fill each module.

### `profile/preferences/synthesis.md`

```markdown
# Synthesis Preferences
**Last Updated:** [DATE]
**Tuning Count:** 0

## What I care about most
[From interview or tuning — themes, risks, opportunities I consistently engage with]

## Style
- Depth: detailed
- Format: lead with the most important thing, then bullets
- What to always flag: patterns across multiple 1on1s, risks to strategy, market signals

## Feedback log
<!-- Preference tuning appends here with timestamps -->
```

### `profile/preferences/briefing.md`

```markdown
# Daily Briefing Preferences
**Last Updated:** [DATE]

## Open loop display order
Overdue → due this week → high priority → everything else

## Acknowledgment
user_email: [Email from interview-answers.md — Identity > Email]

## Coaching tone
[From interview Q4 — e.g., "direct and blunt — tell me what I'm missing"]

## Length
Concise and scannable — I read this in under 3 minutes

## What to always include
- Anyone not contacted in >14 days (direct reports) or >21 days (stakeholders)
- Any loop open >14 days without a status update
- Cross-cutting themes from recent 1on1s

## Commitment load thresholds
Warn if critical open loops ≥ 3
Warn if high + critical open loops ≥ 8
(Adjust to match your actual load capacity)
```

### `profile/preferences/writing-style.md`

```markdown
# Writing Style
**Last Updated:** [DATE]

## My voice
[From interview Q3 — 2–3 sentences verbatim describing how they communicate]

## Format defaults
- Length: [concise/detailed — inferred from Q3]
- Structure: [bullets/prose/mixed — inferred from Q3]
- Tone: [formal/casual — inferred from Q3]

## Cascade drafts
Match this style exactly when drafting Down, Lateral, and Up versions.
Avoid corporate jargon unless that's explicitly my style.
```

### `profile/preferences/decisions.md`

```markdown
# Decision-Making Principles

How you make decisions, and how `/personal-os-decide` should behave on your behalf. Loaded at
the start of every decision session. Edit this file to make the skill argue the way you do.

## The principles

**1. Two-way door, make the call.** Reversible decisions get speed. Spending one-way-door
rigor on a two-way-door call is the waste to catch. Classify reversibility first, and when the
call is reversible, say "the bar is decide and move" out loud rather than building an analysis
nobody needed.

**2. Push decisions to the edge.** Whoever is closest to the problem should decide.
Aggregating decisions at the top is an org-scaling failure wearing the costume of control.

**3. Empowerment is gated on context and ownership.** Principle 2 has a precondition. The
person at the edge has to hold enough context and has to own the strategy, or the call goes
wrong. Aspire to defer, then check that the owner can carry it.

**4. The decider asks first.** When you are the approver, solicit the domain owner's
recommendation before asserting your own. The owner says what the decision should be, then you
decide.

**5. Name escalations explicitly, and treat them as healthy.** An escalation is not throwing a
peer under the bus. State the divergent recommendations, take it to the single accountable
approver, and have them say why they called it that way, so everyone keeps the context.
Escalating to break a tie is good. Staying stuck is the failure.

**6. DACI, one accountable approver, log the why.** Use the lightest framework people will
actually adopt. Every real decision has a Driver, exactly one Approver, Contributors, and
Informed. The artifact is the decision, roughly three options, who recommends what, one
result, and the reason it was called that way, written down.

**7. Bias to action when no one owns it.** When a thing is unowned and reversible, the default
is to move rather than wait for permission.

## How the skill applies these

- Lead with reversibility. Two-way door, push to decide. One-way door, hold the evidence bar
  before sign-off.
- Insist on exactly one approver. When the source names several sign-offs, surface the gap and
  ask who is accountable.
- Show the driver's recommendation, and for a contested call ask what the domain owner
  recommends before offering a verdict.
- Log disagreements and the final why as first-class content. Do not smooth them over.
- Surface stuck decisions. A record sitting unmoved past its evidence bar is the thing to
  flag, not to wait out.

## Adoption note

Keep the record short enough that a busy owner fills it in. A heavier artifact nobody
completes is worse than a lighter one that gets used. If you find yourself skipping the
record, cut a section from the template rather than skipping the record.
```

### `_system/templates/decision.md`

````markdown
---
status: proposed          # proposed | in-review | decided | deferred | reversed
reversibility:            # two-way | one-way | mixed
driver:                   # who is running this decision
approver:                 # exactly one accountable name
contributors: []
informed: []
scope:                    # standalone | [project-name]
source:                   # where this came from
date_opened: YYYY-MM-DD
date_decided:
review_date:              # when to check whether this call was right
record_synced:            # date this was mirrored into _system/data/decisions.json
---

# [Decision title]

## Decision statement
One line. The specific call being made, phrased so a yes or no is possible.

## Reversibility
two-way | one-way | mixed. If mixed, name which part is irreversible, because that part is
the only part that earns the evidence bar.

## DACI
| Role | Who |
|------|-----|
| Driver | |
| Approver | (exactly one) |
| Contributors | |
| Informed | |

## Context
What forced the decision, and what happens if nobody decides.

## Options
Roughly three, genuinely different.

### Option A: [name]
- What it is:
- Who recommends it, and why:
- Cost:

### Option B: [name]
### Option C: [name]

## Implications
Second and third-order effects, the precedent it sets, what it forecloses, what it depends on.
This is the part a fast yes misses, so spend the effort here on one-way doors.

## Evidence bar
What has to be known or true before sign-off.
- [ ]
- [ ]

## Escalations and disagreements
Who diverged, on what, and how it resolved. Append, never overwrite.

## Decision and why
The call, the approver, and the reason it went that way. Written for someone reading it in six
months with none of today's context.

## Expected outcome
What should be true by `review_date` if this call was right, phrased so you could be wrong.
"Support tickets on onboarding drop below 10 a week" beats "onboarding improves". A retrospective
with nothing falsifiable to check against turns into a rationalization of whatever happened.

## Follow-through
- [ ] Who needs to be told
- [ ] What changes as a result

## Decision log
Append-only. One dated line per state change, position shift, or escalation.
- YYYY-MM-DD: opened
````

### `profile/preferences/1on1.md`

```markdown
# 1on1 Focus Areas
**Last Updated:** [DATE]

## What to surface from 1on1 synthesis
[From interview Q6 — verbatim]

## Default priority
1. Commitments overdue or at risk
2. Morale or sentiment signals
3. Growth and development themes
4. Political or alignment gaps

## Probing questions
Generate one question I haven't asked yet, based on recent themes.
```

### `profile/preferences/knowledge.md`

```markdown
# Knowledge Relevance Filters
**Last Updated:** [DATE]
**Update schedule:** Weekly

## Currently relevant topics
[From interview Q5 — 2–3 topics as bullet list]

## Relevance criteria
Flag a source as relevant if it addresses one of the above topics OR connects to an open question in HEARTBEAT.md.
```

### `profile/preferences/calendar.md` _(created only if calendar integration is configured)_

```markdown
# Calendar Preferences
**Last Updated:** [DATE]

## Large meeting threshold
Flag meetings with ≥ 4 attendees as needing prep review

## Focus block preferences
- Preferred focus block length: 90 minutes
- Preferred time of day: morning (before 11am)
- Days to look ahead: 5

## Calendar source
[google | apple | none]
If "none": week-ahead command surfaces loops only, without calendar data
```

### `_system/templates/1on1-session.md`

```markdown
---
date: {{DATE}}
person: {{NAME}}
session_number: {{N}}
---

# 1on1 — {{NAME}} — {{DATE}}

## Check-in
[How are they doing, energy level, anything personal to note]

## Their agenda
-

## My agenda
-

## Key topics discussed

### [Topic 1]
[Notes]

## Commitments

| Commitment | Owner | Due | Priority |
|-----------|-------|-----|----------|
| | | | |

## Themes observed
[Patterns, sentiment, what's unsaid]

## Follow-up for next session
-
```

### `_system/templates/1on1-summary.md`

```markdown
---
date: {{DATE}}
person: {{NAME}}
processed_at: {{PROCESSED_DATE}}
---

# Summary — {{NAME}} — {{DATE}}

## One-line read
[Sentiment + key theme in one sentence]

## Decisions made
-

## Open loops opened
<!-- Also add to _system/data/open-loops.json with priority -->
-

## Open loops closed
-

## Themes (add to profile.md if new)
-

## Notable signals
[Anything worth flagging — morale, concerns, ideas, political dynamics]
```

### `_system/templates/meeting-summary.md`

```markdown
---
date: {{DATE}}
meeting: {{TITLE}}
attendees:
processed_at: {{PROCESSED_DATE}}
---

# {{TITLE}} — {{DATE}}

## Purpose
[Why this meeting happened]

## Key decisions
-

## Action items
<!-- Also add to Meetings/action-items.md and _system/data/open-loops.json -->
| Action | Owner | Due | Priority |
|--------|-------|-----|----------|
| | | | |

## Context captured
[Background, constraints, things said that aren't in the action items]

## Open loops opened
-

## Follow-up needed
-
```

### `_system/templates/source-annotation.md`

```markdown
---
source_type:
original:
processed_at:
relevance:
key_concepts:
connections:
open_questions:
---

# [TITLE]

## Summary
[3-5 sentences: what this is, why it matters, key argument]

## Key concepts
- **[Concept]:** [one-line definition]

## Relevant quotes / data
> [Direct quote or stat worth keeping]

## Inferences
[What this implies for product strategy, team, market]

## Open questions raised
-

## Connections to existing knowledge
- Related to [[wiki/concepts/...]] because [reason]

---
[FULL CONVERTED CONTENT BELOW]
```

### `_system/templates/cascade-update.md`

```markdown
---
date: {{DATE}}
week_of: {{WEEK}}
audience: {{AUDIENCE}}
---

# Cascade — Week of {{WEEK}} — {{AUDIENCE}}

## The headline
[One sentence: what matters most this week]

## What happened
-

## What's next
-

## What I need from you
[Specific asks, if any]

## What you should know
[Context that helps you do your job better]
```

### `_system/templates/1on1-ready-note.md`

```markdown
# Ready Note — {{NAME}}
_Last rebuilt: {{DATETIME}}_

## Priority Open Loops
<!-- context_person = {{NAME}}, sorted: overdue → critical → high — top 3–5 -->
| Loop | Owner | Due | Days Open |
|------|-------|-----|-----------|
| | | | |

## Last Session Highlights
_{{LAST_SESSION_DATE}} — {{LAST_SESSION_TOPIC}}_
-
-
-

## My Notes
<!-- MANUAL — append new notes above this line; last 15–30 lines preserved on rebuild -->

<!-- END MANUAL -->

## Recent Action Items
<!-- Open action items from last 2 sessions -->
| Action | Owner | Due |
|--------|-------|-----|
| | | |

## Session History (last 5)
| Date | Key Topic | One-liner |
|------|-----------|-----------|
| | | |
```

### `_system/templates/person-folder.md`

```markdown
<!-- Used as CLAUDE.md scaffold by /personal-os-new-1on1 [name] -->

# [NAME]
**Role:** [Title] | **Function:** [Team] | **Slack:** @[handle]
**Last contact:** YYYY-MM-DD | **Sessions:** 0

## Key context
[One paragraph — who they are, their priorities, how they work]

## Themes (updated as sessions accumulate)
-

## Open loops summary
See `open-loops.md` for full list.
Active count: 0

## Session index
| Date | Key topic | Summary link |
|------|-----------|-------------|
| | | |
```

### `_system/templates/career-evidence-digest.md`

```markdown
# Career Evidence — [DATE_RANGE]
_Generated: {{DATE}}_

## Feedback received
<!-- Sorted: starred first, then date descending -->
| Date | From | What they said | Context |
|------|------|----------------|---------|
| | | | |

## Outcomes delivered
| Date | What | Detail |
|------|------|--------|
| | | |

## Growth moments
| Date | What | Detail |
|------|------|--------|
| | | |

---
_To star entries for your portfolio: "star ev-001, ev-002"_
_To generate a brag doc: "brag doc"_
```

### `_system/templates/wiki-page.md`

```markdown
---
concept: "{{CONCEPT}}"
aliases: []
sources: 0
last_updated: {{DATE}}
---

# {{CONCEPT}}

**Summary:** {{ONE_SENTENCE_SUMMARY}}

**Key points:**
-

**Related:** 

**Open questions:**
-

---
<!-- Connections appended below by nightly synthesis and /personal-os-remember -->
```

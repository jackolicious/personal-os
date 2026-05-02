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

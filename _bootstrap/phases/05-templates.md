# Phase 5: Profile and Templates
_Depends on: Phase 1 (directories must exist)_

### `profile/preferences.md`

```markdown
# My Preferences & Working Style

**Last Updated:** [DATE]
**Tuning Schedule:** daily (week 1)
**Tuning Count:** 0

---

## What I care about most
[Updated by tuning — what themes, risks, and opportunities I consistently engage with]

## Synthesis style
- Depth: detailed
- Format: lead with the most important thing, then bullets
- What to always flag: patterns across multiple 1on1s, risks to strategy, market signals

## 1on1 focus areas
[What I want surfaced from 1on1 processing — e.g., team morale, blockers, growth signals]

## Daily briefing preferences
- Open loops: show overdue first, then due this week, then high priority
- Coaching tone: direct, not gentle — tell me what I'm missing
- Length: concise, scannable — I read this in under 3 minutes

## Knowledge relevance filters
[Topics currently most relevant — update weekly]
- Product strategy for new company
- Team onboarding and assessment
- Market and competitive landscape

## Feedback log
<!-- Tuning process appends here with timestamps -->
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

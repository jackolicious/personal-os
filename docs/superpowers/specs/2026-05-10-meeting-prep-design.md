# Meeting Prep Design
_Date: 2026-05-10_

## Problem

The existing Personal OS has 1on1 prep on-demand (`/personal-os-1on1-prep`) and a week-ahead brief that flags meetings needing prep. Neither delivers ready reference notes for every meeting before the day starts. As a new CPO walking into back-to-back meetings with unfamiliar people, prep needs to be automatic — not something you remember to run.

## Goals

- Every calendar meeting has a prep doc ready before the day starts
- Works without any calendar integration (graceful degradation)
- Brevity first: the doc is scannable in under 60 seconds
- Cold-start safe: useful from day one with zero vault history
- On-demand regeneration for late-added meetings

## Out of scope

- Real-time prep updates (meeting added at 9am won't auto-prep until tomorrow)
- Audio/video content ingestion
- Sending prep docs anywhere automatically (Telegram delivery is user-initiated)

## Design principles

- Connection-type agnostic: the workflow defines what's needed, not how to get it
- Graceful degradation: each tier produces something useful
- Auto-resolve policy (clawchief model): prep generation is low-risk and operational — always auto-resolve
- Brevity: sections omitted when empty, no filler, bullets not paragraphs

---

## Architecture

### Trigger

5am, inside `run-nightly.sh`, as a new pass after the daily briefing is generated.

### Data flow

```
5am run
  ├── [existing] Generate daily briefing
  └── [new] Meeting prep pass (claude --model claude-sonnet-4-6 --print)
        ├── Read profile/preferences/calendar.md → calendar source
        ├── If source = none → skip; briefing notes "No calendar connected"
        ├── Else → pull today's events
        ├── For each event:
        │     ├── Classify type (1on1 / cross-functional / team / external / unknown)
        │     ├── Load vault context (open loops, wiki, decisions, ready-notes)
        │     ├── Generate prep doc → Meetings/prep/YYYY-MM-DD-[slug].md
        │     └── Apply base layer + type overlay
        └── Update daily briefing ### Meetings today with prep doc links
```

### Calendar source tiers

| Source | Behavior |
|--------|----------|
| Google Calendar MCP | Full auto — events pulled, all prep generated |
| Apple Calendar / manual paste | User pastes schedule; workflow runs from there |
| None configured | Pass skips; briefing says "No calendar connected — run `/personal-os-meeting-prep` manually" |

Source is read from `profile/preferences/calendar.md`. If the file doesn't exist, treat as `none`.

### On-demand command

`/personal-os-meeting-prep [slug]` regenerates a single prep doc at any time. For late-added meetings or a quick refresh before a call.

---

## Prep doc content

### Output path

`Meetings/prep/YYYY-MM-DD-[meeting-slug].md`

Slug: meeting title lowercased, spaces to hyphens, max 40 chars.

### Base layer (all meeting types)

```markdown
# [Meeting Title]
[Date] · [Time] · [Duration]

## Who
- [Name] — [Role] · [Last contact: X days ago / first time]

## Goals
[1-3 bullets — specific to this meeting, not generic]

## Context
[Open loops with attendees, relevant decisions, relevant wiki — omit if empty]

## Questions to ask
[2-3 specific questions]

## Listen for
[Signals relevant to a new CPO: alignment, blockers, trust cues, priorities]
```

**Brevity rules:**
- Sections with no content are omitted entirely
- Max 3 bullets per section
- Entire doc readable in under 60 seconds
- Cold start: goals, questions, and "listen for" are generated from title + attendee roles alone, framed for a new CPO in listening posture. Footer: "No prior context on [Name] — run `/personal-os-remember` after this meeting."

### Type overlays (added to base)

**1on1 (direct report)**
- Pull from `1on1s/[Name]/ready-note.md` if it exists (skip re-deriving what's already there)
- Add: their open commitments to you, your open commitments to them, one probing question not yet asked

**Cross-functional sync / executive 1:1**
- Stakeholder framing: what they care about, what you need from them
- Pending decisions they own or influence
- Executive is a derivative of cross-functional — same overlay, framed more strategically

**Team / all-hands**
- Key themes from recent 1on1s with people in this meeting (index-first: read `1on1s/_index.md`, load only recent sessions)
- Pulse questions to read the room
- What the team needs to hear from you today

**External**
- Research brief from `Knowledge/annotated/` if any entries match attendee name/company
- Prior commitments if any (open loops where context_person matches)
- Your goals for the relationship

**Unknown**
- Base layer only
- Note: "Could not classify — review attendee list"

### Meeting type classification rules

| Type | Rule |
|------|------|
| `1on1` | Exactly 2 attendees including Jack |
| `cross-functional` | 3+ attendees, all internal (same email domain) |
| `executive` | Any attendee has title containing CEO, CFO, CTO, COO, President, or is flagged in `People/stakeholders.md` as C-suite |
| `team` | Title contains "standup", "all-hands", "team sync", "sprint", or attendee count matches a configured team |
| `external` | At least one attendee from a different email domain |
| `unknown` | None of the above match |

Executive is classified before cross-functional — a 1:1 with the CEO is `executive`, not `1on1`.

---

## Daily briefing changes

Replace current Step 3 (meeting awareness) with a linked list:

```
### Meetings today
- 9:00 · Board sync (60 min) → Meetings/prep/2026-05-10-board-sync.md
- 11:00 · 1:1 with Sarah → Meetings/prep/2026-05-10-1on1-sarah.md
- 14:00 · Design review (30 min) → Meetings/prep/2026-05-10-design-review.md

No calendar connected — run `/personal-os-meeting-prep` to generate prep manually.
[shown only when calendar source = none]
```

The briefing no longer contains meeting content — it just points to prep docs.

---

## Files to create

- `_system/workflows/meeting-prep.md` — workflow (classification, context loading, generation)
- `_system/templates/meeting-prep.md` — prep doc template (base + overlays)
- `.claude/commands/personal-os-meeting-prep.md` — on-demand command

## Files to modify

- `run-nightly.sh` — add meeting-prep pass inside the 5am block, after briefing generation
- `_system/workflows/daily-briefing.md` — replace Step 3 with linked meeting list
- `_bootstrap/phases/06-workflows.md` — add meeting-prep workflow definition
- `_bootstrap/phases/07-commands.md` — add meeting-prep command
- `_bootstrap/phases/08-automation.md` — add meeting-prep pass to 5am shell block

---

## Model

Sonnet — meeting classification and context synthesis require reasoning.

Per-meeting prep runs as a single Sonnet call with all today's meetings in context (not one subprocess per meeting, since meeting count is low and context reuse across meetings is valuable for detecting overlapping attendees and shared threads).

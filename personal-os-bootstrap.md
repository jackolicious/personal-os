# Personal OS Bootstrap Meta Prompt

> Paste everything below the horizontal rule into Claude Code in a fresh local vault directory.
> Complete the PERSONALIZATION CHECKLIST (Phase 10) before first use.
> Prerequisites: `pip install markitdown`, Granola configured to export to `Inbox/transcripts/`
> Mobile sync: Obsidian Sync (set up separately when ready — vault runs fine without it)

---

# Personal OS Bootstrap

I am setting up my Personal OS from scratch. This directory is both my Obsidian
vault and my Claude Code working directory. Work through setup in phases using
plan mode first, then execute each phase sequentially. Confirm completion of each
phase before moving to the next.

---

## Context

I am [YOUR NAME], Head of Product at [COMPANY], starting [DATE].

This system is my Chief of Staff second brain and personal knowledge management coach.
Primary use cases:
- Process meeting transcripts (Granola exports to Inbox/transcripts/)
- Convert PDFs to annotated Markdown via markitdown
- Track open loops per person and per project — reviewed daily
- Generate a daily briefing with coaching recommendations
- Run weekly Cascade updates (down, lateral, up) using elicitation
- Assemble product strategy from 1on1 inputs and market research
- Make nightly inferences and connections across all new content — incrementally
- Tune to my preferences on an adaptive schedule (daily → weekly over 4 weeks)

Design constraints:
- Bootstrappable from any machine (self-contained, no external dependencies at setup)
- Non-destructive: sources are sacred, synthesis is append-only
- Context-efficient: CLAUDE.md files are lean doc-indexes, not instruction manuals
- Incremental: nightly synthesis processes only the delta, never reruns everything

Automation runs nightly via persistent terminal loop on an always-on Mac.

---

## PHASE 1: Directory scaffold

Create these directories (add .gitkeep to empty ones):

```
Inbox/
Inbox/links/
Inbox/pdfs/
Inbox/transcripts/
Inbox/scratch/
1on1s/
Meetings/
Projects/
Projects/product-strategy/
Projects/product-strategy/inputs/
Projects/product-strategy/drafts/
Knowledge/
Knowledge/sources/
Knowledge/wiki/
Knowledge/wiki/concepts/
Knowledge/wiki/market/
People/
Workflows/
Templates/
Data/
profile/
logs/
.claude/
.claude/commands/
```

---

## PHASE 2: Root files

### `.gitignore`

```
.obsidian/
.obsidian-sync/
.trash/
*.DS_Store
Inbox/pdfs/*.pdf
logs/*.log
.env
```

### `GOALS.md`

```markdown
# 30/60/90 Day Objectives

## 30 Days — Learn
- [ ] Complete all direct report 1on1s
- [ ] Map cross-functional stakeholders
- [ ] Understand current product state and roadmap
- [ ] Identify the top 3 problems the product team faces

## 60 Days — Assess
- [ ] Draft initial product strategy themes (from 1on1 synthesis)
- [ ] Run first Cascade update
- [ ] Identify quick wins vs. structural changes needed

## 90 Days — Act
- [ ] Publish v1 product strategy
- [ ] Redesign PDLC for AI-era team
- [ ] Establish team OS and shared workflows

---
Last Updated: [DATE]
```

### `HEARTBEAT.md`

```markdown
# Heartbeat

## Current Focus
[Update weekly — what is the most important thing right now]

## This Week
-

## Open Questions
-

## Blockers
-

## Upcoming 1on1s
[List any 1on1s this week for daily briefing awareness]

## Last Cascade Sent: [DATE]
## Last Nightly Synthesis: [DATE]
## Last Daily Briefing: [DATE]
```

---

## PHASE 3: CLAUDE.md hierarchy

### `CLAUDE.md` (root — MUST stay under 70 lines)

```markdown
# [YOUR NAME] Personal OS

## Identity
**Role:** Head of Product | **Company:** [COMPANY] | **Start:** [DATE]

## System Map
| Directory | Purpose |
|-----------|---------|
| `Inbox/` | Raw inputs — links, PDFs, transcripts, scratch |
| `1on1s/` | Per-person: profile, open loops, session notes |
| `Meetings/` | Summaries + master action item list |
| `Projects/` | Active initiatives |
| `Knowledge/` | Sources (immutable) + wiki (synthesized) |
| `People/` | Team roster + stakeholder map |
| `Workflows/` | Repeatable process playbooks |
| `profile/` | My preferences and working style (for tuning) |
| `Data/` | Structured state: open loops, decisions, synthesis log |

## Always Load
- `GOALS.md` — current objectives
- `HEARTBEAT.md` — current focus and context
- `People/team.md` — roster with handles
- `profile/preferences.md` — my preferences for synthesis and briefings

## Team
<!-- FILL IN: name, title, slack handle, relationship -->
| Name | Role | Slack | Notes |
|------|------|-------|-------|
| | | | Direct report |
| | | | Direct report |

## Slack Channels
<!-- FILL IN -->
| Channel | Purpose |
|---------|---------|
| #product | Product team |
| #leadership | Exec comms |

## Commands
| Say | Does |
|-----|------|
| `/daily-briefing` | Generate daily coaching briefing with open loops + recommendations |
| `/process-inbox` | Process all new Inbox items |
| `/cascade` | Start weekly Cascade workflow |
| `/1on1-prep [name]` | Prep for a 1on1 |
| `/ingest-url [url]` | Fetch, annotate, file a URL |
| `/nightly` | Run synthesis manually |
| `/open-loops [filter?]` | Review open loops |
| `/new-1on1 [name]` | Create 1on1 session |

## Rules
- Check `Data/synthesis-log.json` before processing any file
- Never modify files in `Knowledge/sources/` or `Inbox/transcripts/`
- Open loops: append only — archive, never delete
- Wiki pages: append dated sections, never rewrite core content
- Always load `profile/preferences.md` when generating any briefing or synthesis
```

### `Inbox/CLAUDE.md`

```markdown
# Inbox

Raw inputs only. Nothing here is processed or synthesized yet.

## Structure
| Folder | Contains | Process with |
|--------|---------|--------------|
| `links/` | .txt or .md files with one URL each | `/ingest-url` |
| `pdfs/` | Raw PDFs awaiting conversion | `Workflows/pdf-ingestion.md` |
| `transcripts/` | Granola exports (raw markdown) | `Workflows/meeting-notes.md` |
| `scratch/` | Fleeting notes, unstructured | `/process-inbox` |

## Processing rules
- Never modify originals in `transcripts/` — outputs go to `Meetings/` or `1on1s/`
- PDFs: convert with markitdown → annotate → file to `Knowledge/sources/`
- After processing any file, log it in `Data/synthesis-log.json`
- If unsure where something belongs, file to `scratch/` and flag in `HEARTBEAT.md`
```

### `1on1s/CLAUDE.md`

```markdown
# 1on1s

One subfolder per person. Direct reports and key stakeholders.

## Person folder structure
```
[Person Name]/
  CLAUDE.md       ← person context (load for any query about them)
  profile.md      ← role, background, working style, key themes
  open-loops.md   ← active commitments and follow-ups (append-only)
  sessions/
    YYYY-MM-DD.md          ← raw notes (immutable after session)
    YYYY-MM-DD-summary.md  ← processed summary (structured)
```

## Creating a new person folder
Use `/new-1on1 [name]` — creates from `Templates/person-folder.md`

## Query patterns
- "What's open with Alex?" → reads Alex/open-loops.md + last summary
- "Prep my 1on1 with Alex" → `/1on1-prep Alex`
- "What themes keep coming up with the team?" → reads all [person]/profile.md theme sections
```

### `Meetings/CLAUDE.md`

```markdown
# Meetings

All non-1on1 meetings. Indexed by date and title.

## Structure
```
YYYY-MM-DD-[slug]/
  raw.md      ← original Granola transcript (immutable)
  summary.md  ← processed: decisions, actions, context
action-items.md  ← master list across all meetings (structured)
```

## action-items.md format
```
- [ ] [Action] | Owner: [Name] | Due: [Date] | Priority: [critical|high|medium|low] | Source: [[YYYY-MM-DD-meeting]]
```
Completed items move to `## Completed` section — never deleted.
```

### `Projects/CLAUDE.md`

```markdown
# Projects

## Active Projects
| Project | Status | Next Action | Owner |
|---------|--------|-------------|-------|
| product-strategy | In progress | Draft v0 themes | [NAME] |

## Project folder structure
```
[project-name]/
  CLAUDE.md    ← project context and status
  inputs/      ← excerpts from 1on1s and research feeding this project
  drafts/      ← versioned drafts (v0, v1, etc.)
  [final].md   ← current canonical version
```
```

### `Knowledge/CLAUDE.md`

```markdown
# Knowledge Base

Karpathy-style: sources are immutable, wiki is LLM-synthesized and append-only.

## Layers
| Layer | Path | Rules |
|-------|------|-------|
| Sources | `sources/` | Immutable after annotation. Never modified. |
| Wiki | `wiki/` | Append-only. Dated sections. Never rewrite. |

## Source annotation format
Every file in `sources/` has a metadata block at top:
```
---
source_type: [pdf | url | transcript | note]
original: [filename or URL]
processed_at: [date]
relevance: [product-strategy | market | people | process | other]
key_concepts: [comma-separated]
connections: [wiki pages this relates to]
open_questions: [questions this raises]
---
```

## Wiki page format
```markdown
# [Concept]

## Definition
[Written at first creation — rarely changed]

## Evidence & Connections
### [YYYY-MM-DD]
- Source: [[source-file]]
- Connection: [why this relates]
- Inference: [what this implies]
```

## Synthesis rule
When connecting a new source to the wiki, ALWAYS append a new dated section.
Never rewrite existing sections.
```

### `People/CLAUDE.md`

```markdown
# People

## Files
- `team.md` — direct reports and key relationships
- `stakeholders.md` — cross-functional map

## Stakeholder entry format
### [Name]
- Role: [Title] at [Function]
- Relationship: [collaborator | dependency | sponsor | inform-only]
- Slack: @[handle]
- Last contact: YYYY-MM-DD
- Key context: [one line]
```

### `Workflows/CLAUDE.md`

```markdown
# Workflows

| Workflow | When to use | File |
|----------|------------|------|
| daily-briefing | Each morning | `daily-briefing.md` |
| cascade | Weekly, Friday | `cascade.md` |
| meeting-notes | After any meeting with transcript | `meeting-notes.md` |
| 1on1-prep | Before any 1on1 | `1on1-prep.md` |
| pdf-ingestion | When a PDF lands in Inbox/pdfs/ | `pdf-ingestion.md` |
| nightly-synthesis | Nightly at 2am via loop | `nightly-synthesis.md` |
| preference-tuning | Adaptive schedule (see nightly) | `preference-tuning.md` |
```

### `profile/CLAUDE.md`

```markdown
# Profile

Contains my working preferences and style — loaded every session for synthesis and briefings.

## Files
- `preferences.md` — synthesis preferences, what to surface, briefing format
```

---

## PHASE 4: Data models

### `Data/open-loops.json`

```json
{
  "schema_version": 2,
  "loops": []
}
```

Schema for each loop entry:
```json
{
  "id": "loop-001",
  "title": "string — the commitment or open question",
  "owner": "string — who owns resolution",
  "context_person": "string | null",
  "context_meeting": "string | null",
  "project": "string | null",
  "priority": "critical | high | medium | low",
  "status": "open | in-progress | blocked | archived",
  "opened_date": "YYYY-MM-DD",
  "due_date": "YYYY-MM-DD | null",
  "closed_date": "YYYY-MM-DD | null",
  "notes": "string — append-only updates separated by | date |",
  "source_file": "path to originating note"
}
```

### `Data/decisions.json`

```json
{
  "schema_version": 1,
  "decisions": []
}
```

Schema for each decision entry:
```json
{
  "id": "dec-001",
  "decision": "string — what was decided",
  "date": "YYYY-MM-DD",
  "made_by": "string",
  "context": "string — why",
  "alternatives_considered": "string | null",
  "source_file": "path",
  "review_date": "YYYY-MM-DD | null"
}
```

### `Data/synthesis-log.json`

```json
{
  "schema_version": 2,
  "last_nightly_run": null,
  "preference_tuning": {
    "start_date": null,
    "last_tuning_run": null,
    "tuning_count": 0,
    "current_schedule": "daily",
    "next_tuning_date": null
  },
  "processed_files": {}
}
```

Schema for each `processed_files` entry (key = relative file path):
```json
{
  "hash": "md5 of file contents at processing time",
  "processed_at": "ISO timestamp",
  "processing_type": "annotation | summary | synthesis | connection | profile-synthesis",
  "output_files": ["paths of files created/updated"],
  "wiki_connections_made": ["wiki page paths appended to"],
  "open_loops_created": ["loop IDs created"],
  "annotation_version": 1
}
```

**Preference tuning schedule logic** (nightly synthesis checks this):
- Days 0–7 from start_date: schedule = "daily"
- Days 8–14: schedule = "every-3-days"
- Days 15–21: schedule = "every-5-days"
- Day 22+: schedule = "weekly"

---

## PHASE 5: Profile and templates

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

### `Templates/1on1-session.md`

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

### `Templates/1on1-summary.md`

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
<!-- Also add to Data/open-loops.json with priority -->
-

## Open loops closed
-

## Themes (add to profile.md if new)
-

## Notable signals
[Anything worth flagging — morale, concerns, ideas, political dynamics]
```

### `Templates/meeting-summary.md`

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
<!-- Also add to Meetings/action-items.md and Data/open-loops.json -->
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

### `Templates/source-annotation.md`

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

### `Templates/cascade-update.md`

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

### `Templates/person-folder.md`

```markdown
<!-- Used as CLAUDE.md scaffold by /new-1on1 [name] -->

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

---

## PHASE 6: Workflow playbooks

### `Workflows/daily-briefing.md`

```markdown
# Daily Briefing Workflow

## Purpose
Morning coaching briefing — not just a status report. Surfaces what needs attention,
makes connections, and recommends one clear action for the day.

## Trigger: `/daily-briefing`

## Steps

1. **Load context**
   - Read `HEARTBEAT.md` (current focus, upcoming 1on1s)
   - Read `GOALS.md` (30/60/90 objectives)
   - Read `profile/preferences.md` (briefing preferences and coaching tone)

2. **Open loops triage**
   - Read `Data/open-loops.json`
   - Categorize: overdue → due this week → high priority → everything else
   - Flag any loop open >14 days without a status update
   - For critical/overdue loops: draft a one-line suggested action

3. **Meeting awareness**
   - Check `HEARTBEAT.md` for 1on1s today or tomorrow
   - If a 1on1 is today: surface last session summary + open loops for that person
   - Suggest running `/1on1-prep [name]` if not already done

4. **Relationship health check**
   - Scan `People/team.md` and `People/stakeholders.md` for `Last contact:` fields
   - Flag anyone not contacted in >14 days (direct reports) or >21 days (stakeholders)
   - Format: "Haven't connected with [Name] in X days — open loops: N"

6. **Fresh from last night**
   - Read `Data/synthesis-log.json` → what was processed in the last nightly run
   - Surface: new wiki connections made, new open loops created, any patterns flagged

7. **Coaching insight**
   - Scan recent meeting summaries (last 7 days) for cross-cutting patterns
   - If 2+ people mentioned the same theme: flag it ("Three 1on1s this week touched on X")
   - If a strategy theme is emerging from multiple sources: surface it

8. **Recommendation**
   - One clear action for today that moves the most important needle
   - Based on: goals progress, overdue loops, emerging patterns

## Output format

# Daily Briefing — [DATE]

### Today's focus
[One sentence from current HEARTBEAT priority]

### Meetings today
[1on1s or key meetings with prep status]

### Open loops requiring action
[Overdue / due today / high priority — with suggested action]

### Relationship health
[Anyone overdue for contact — name, days since last touch, open loop count]

### Fresh from last night
[What nightly synthesis found — new connections, flags]

### Pattern emerging
[If applicable — cross-cutting theme from recent 1on1s or sources]

### Today's recommendation
[One specific action]

---
*Want to update any open loops? Run `/open-loops` | Start cascade? `/cascade`*

## Telegram delivery (optional)
After generating the briefing, ask: "Should I send this to Telegram?"
If yes, post the briefing to the configured Telegram chat.
```

### `Workflows/cascade.md`

```markdown
# Cascade Workflow

## Cadence: Weekly (Friday recommended)
## Audiences: Down (direct reports), Lateral (cross-functional), Up (C-suite)
## Use judgment on which audiences to activate each week

## Step 0: Open loop review
Before elicitation, run: load `Data/open-loops.json` filtered by this week.
Surface any overdue or newly closed loops — these feed into the cascade.

## Step 1: Elicitation — ask these questions one at a time, wait for each answer

1. "What was the most important thing that happened in product this week?"
2. "What decisions were made? Who made them?"
3. "What's the biggest thing that's blocked or at risk?"
4. "What do you want your direct reports to know or do differently next week?"
5. "What do you want the C-suite to understand or decide?" (skip if not sending up)
6. "What do you need from cross-functional partners?"
7. "Any signals from 1on1s or meetings this week worth amplifying?"
8. "Is there anything you want to NOT surface this week, and why?"

## Step 2: Draft three versions

**Down** (direct reports) — tactical, what they need to know and do, clear asks
**Lateral** (cross-functional) — context + shared goals + specific asks
**Up** (C-suite) — strategic framing, what needs attention or a decision

## Step 3: Review + send

Present all three drafts. Wait for explicit approval before sending anything.
Ask which audiences to activate this week.

## Step 4: Log
- Save to `Meetings/YYYY-MM-DD-cascade.md`
- Update `HEARTBEAT.md` Last Cascade Sent date
- Archive any open loops that were resolved this week
```

### `Workflows/meeting-notes.md`

```markdown
# Meeting Notes Ingestion Workflow

## When to run
When a new Granola transcript appears in `Inbox/transcripts/`

## Steps

1. **Identify the meeting type**
   - 1on1 with direct report or stakeholder → `1on1s/[Name]/sessions/`
   - Team meeting / all-hands → `Meetings/`
   - Customer call → `Meetings/` AND excerpt key quotes to relevant project inputs

2. **Check synthesis-log.json** — if hash already in log, skip

3. **Create raw copy** (immutable) as `raw.md` in destination folder

4. **Generate summary** using appropriate template
   - Extract decisions, action items, open loops, themes
   - Assign priority to every open loop extracted
   - For 1on1s: update `[Name]/profile.md` themes section if new themes observed

5. **Update open loops**
   - New commitments → append to `Data/open-loops.json` with priority and due date
   - Closed commitments → set status to "archived"

6. **Update action items** → append to `Meetings/action-items.md`

7. **Log in synthesis-log.json**
```

### `Workflows/pdf-ingestion.md`

```markdown
# PDF Ingestion Workflow

## Prerequisite: `pip install markitdown`

## Steps

1. **Check synthesis-log.json** — skip if already processed

2. **Convert**
   ```
   markitdown "Inbox/pdfs/[filename].pdf" > "Inbox/pdfs/[filename].md"
   ```

3. **Annotate** using `Templates/source-annotation.md`
   - Metadata block, summary, key concepts, inferences, open questions
   - Identify connections to existing wiki pages

4. **File** annotated version to `Knowledge/sources/[slug].md`
   - Original PDF stays in `Inbox/pdfs/` (immutable)

5. **Queue for nightly wiki synthesis** — connections made during nightly run

6. **Log in synthesis-log.json**
```

### `Workflows/1on1-prep.md`

```markdown
# 1on1 Prep Workflow

## Trigger: `/1on1-prep [name]`

1. Load `1on1s/[Name]/CLAUDE.md` and `profile.md`
2. Read most recent `sessions/[date]-summary.md`
3. Filter `Data/open-loops.json` where context_person = [Name]
4. Scan for shared meetings in the last 2 weeks

5. Generate prep doc:
   - Their open commitments to me (overdue flagged)
   - My open commitments to them
   - Suggested agenda topics based on themes
   - One probing question I haven't asked yet
   - Relevant context from HEARTBEAT.md

6. Create session file from `Templates/1on1-session.md`
```

### `Workflows/preference-tuning.md`

```markdown
# Preference Tuning Workflow

## Purpose
Update `profile/preferences.md` based on patterns observed in recent work.
Does NOT reprocess old content — reflects on patterns in what was recently processed.

## Adaptive schedule
Determined by `Data/synthesis-log.json` preference_tuning section:
- Days 0–7 from start_date: daily
- Days 8–14: every 3 days
- Days 15–21: every 5 days
- Day 22+: weekly

## Steps

1. Read current `profile/preferences.md`
2. Read synthesis-log for all files processed since last tuning run
3. Identify patterns:
   - Which topics/themes appeared most in processed content?
   - Which open loops were created most frequently? By whom?
   - What types of connections were made in the wiki?
   - Any topics consistently flagged as relevant that aren't in current filters?
4. Draft updates to `profile/preferences.md`:
   - Update "What I care about most" if new themes emerged
   - Update "Knowledge relevance filters" if new topics are dominant
   - Append observation to "Feedback log" with timestamp
5. Present proposed updates — do NOT auto-apply without review
6. After approval, write updates to `profile/preferences.md`
7. Update `Data/synthesis-log.json` preference_tuning:
   - last_tuning_run: today
   - tuning_count: +1
   - next_tuning_date: calculated from schedule
   - current_schedule: recalculate based on days since start_date
```

### `Workflows/nightly-synthesis.md`

```markdown
# Nightly Synthesis Workflow

## Cadence: Nightly at 2am (persistent loop on always-on Mac)
## Design: incremental — only processes NEW or CHANGED files

## Full algorithm

### Step 1: Load state
Read `Data/synthesis-log.json`

### Step 2: Scan for unprocessed files
- `Inbox/transcripts/*.md` — not in log
- `Inbox/pdfs/*.md` — converted but not annotated
- `Inbox/links/*.md` — not in log
- `Knowledge/sources/*.md` — in log but hash changed

### Step 3: Process each file (ONE AT A TIME)
a. Determine type → apply correct workflow
b. Process (annotate / summarize / extract loops with priority)
c. Write output files
d. Update synthesis-log.json IMMEDIATELY after each file
   (if interrupted, picks up where it left off)

### Step 4: Wiki connections
For each source processed tonight:
a. Read its `connections` metadata
b. For each named wiki page:
   - Exists → APPEND new dated section
   - Does not exist → CREATE with this connection as seed
c. Never re-evaluate old connections

### Step 5: Open loop maintenance
- Scan tonight's summaries for new commitments → append to open-loops.json with priority
- Flag loops where due_date < today and status = open or in-progress
- Flag loops where status = open and opened_date > 14 days ago (no update)

### Step 6: Pattern detection (coaching function)
- If 2+ sources or summaries processed this week share a key concept → flag in HEARTBEAT.md
- If 3+ people mentioned a theme in 1on1s this week → flag for next daily briefing
- Log flags in `HEARTBEAT.md` under "Open Questions"

### Step 7: Last contact update
For each 1on1 session processed tonight:
- Update `Last contact:` in `1on1s/[Name]/CLAUDE.md` to today's date
- If person is in `People/stakeholders.md`, update their `Last contact:` field there too

### Step 8: Profile synthesis (triggered by session count)
After 10+ sessions with any single person:
- Re-read all their summaries
- Update `[Name]/profile.md` themes section with synthesized patterns
- Log as processing_type: "profile-synthesis"

After 5+ sources on any single wiki concept:
- Append "Synthesis as of [date]" section to that wiki page
- Do NOT delete prior connection entries

### Step 9: Preference tuning check
- Read preference_tuning from synthesis-log.json
- If today >= next_tuning_date: run `Workflows/preference-tuning.md`
- Update schedule after tuning completes

### Step 10: Update HEARTBEAT.md
- Last Nightly Synthesis: [today]
- Count of items processed
- Any patterns flagged (from Step 6)

### What counts as "changed"
File hash (MD5) differs from what's stored in synthesis-log.json.
```

---

## PHASE 7: Slash commands

### `.claude/commands/daily-briefing.md`

```markdown
Generate the daily coaching briefing.

Load `profile/preferences.md` first — this governs tone, depth, and what to surface.
Then follow `Workflows/daily-briefing.md` exactly.

At the end, ask: "Should I send this to Telegram?"
```

### `.claude/commands/process-inbox.md`

```markdown
Process all new items in the Inbox.

1. Load `Inbox/CLAUDE.md` and `Data/synthesis-log.json`
2. Scan each Inbox subfolder for files not in synthesis-log
3. For each new file, determine type and apply correct workflow from `Workflows/`
4. Process one file at a time, update synthesis-log after each
5. Report: N files processed, N skipped, any errors
```

### `.claude/commands/cascade.md`

```markdown
Run the weekly Cascade workflow.

Load `Workflows/cascade.md` and follow it exactly.
Do not send anything to Slack without explicit approval.
Present all three drafts (Down, Lateral, Up) and ask which to activate.
```

### `.claude/commands/1on1-prep.md`

```markdown
Prepare for a 1on1. Usage: /1on1-prep [name]

$ARGUMENTS contains the person's name.
Follow `Workflows/1on1-prep.md`.
If no name provided, ask: "Who is this 1on1 with?"
```

### `.claude/commands/ingest-url.md`

```markdown
Fetch, annotate, and file a URL. Usage: /ingest-url [url]

$ARGUMENTS contains the URL.

1. Fetch the URL content
2. Save raw to `Inbox/links/[slug].md`
3. Annotate using `Templates/source-annotation.md`
4. Save annotated to `Knowledge/sources/[slug].md`
5. Update `Data/synthesis-log.json`
6. Report: title, key concepts extracted, connections identified
```

### `.claude/commands/nightly.md`

```markdown
Run nightly synthesis manually.

Follow `Workflows/nightly-synthesis.md` exactly.
Process only new/changed files — never reprocess what's already in synthesis-log.
Report: files processed, loops created, wiki pages updated, any patterns flagged.
```

### `.claude/commands/open-loops.md`

```markdown
Review open loops. Usage: /open-loops [optional filter]

$ARGUMENTS may contain a person name or project name.

1. Read `Data/open-loops.json`
2. Filter if argument provided (context_person or project match)
3. Sort: overdue first → due this week → critical priority → high priority → rest
4. Display each: title, owner, priority, due date, days open, source
5. Flag any loop open >14 days without a note update
6. Ask: "Do you want to update or archive any of these?"
7. For each confirmed closure: set status="archived", closed_date=today
```

### `.claude/commands/new-1on1.md`

```markdown
Create a new person folder in 1on1s/. Usage: /new-1on1 [name]

$ARGUMENTS contains the person's name.

1. Create `1on1s/[Name]/` directory
2. Create `1on1s/[Name]/CLAUDE.md` from `Templates/person-folder.md`
3. Create `1on1s/[Name]/profile.md` (sections: Role, Background, Working Style, Themes, Notes)
4. Create `1on1s/[Name]/open-loops.md` with empty header
5. Create `1on1s/[Name]/sessions/` directory
6. Ask: "Tell me about [Name] — role, relationship to you, key context?"
7. Fill in CLAUDE.md from the answer
8. Add to `People/team.md` or `People/stakeholders.md` as appropriate
```

---

## PHASE 8: Nightly loop runner

### `run-nightly.sh`

```bash
#!/bin/bash
# Nightly synthesis loop
# Keep running in a dedicated terminal tab on your always-on Mac
# Prerequisite: set System Settings > Energy > "Prevent automatic sleeping" ON

echo "Nightly synthesis loop started at $(date). Ctrl+C to stop."

while true; do
  hour=$(date +%H)
  if [ "$hour" = "02" ]; then
    echo "$(date): Running nightly synthesis..."
    claude --print "/nightly" 2>&1 | tee -a logs/nightly.log
    sleep 3600  # avoid double-run within same hour
  else
    sleep 300   # check every 5 minutes
  fi
done
```

**Mac sleep setting:** System Settings → Battery → Options → enable "Prevent automatic sleeping on power adapter when display is off"

---

## PHASE 9: Sync and backup

This system does NOT use GitHub for the personal vault. Sensitive 1on1 notes,
decisions, and strategy content stay local.

**Backup:** Obsidian Sync (set up when ready — vault works fully without it)
  - Sign up at obsidian.md/sync
  - Enable in Obsidian Settings → Sync
  - Vault will be available on Obsidian iOS once configured

**Bootstrap template:** A separate public GitHub repo containing only this
meta prompt and the blank scaffold (no personal data) can be maintained
as a reference/restore point.

**For now:** Vault lives locally. No additional action needed in this phase.

---

## PHASE 10: Setup confirmation and personalization

After scaffold is built, confirm each item before first use.

### Required before Day 1

**Granola transcript path:**
- [ ] Open Granola Settings → Obsidian integration
- [ ] Set export folder to: `[vault path]/Inbox/transcripts/`
- [ ] Test: export one transcript and verify it appears in `Inbox/transcripts/`

**markitdown:**
- [ ] `pip install markitdown`
- [ ] Test: `markitdown --version`

**Mac sleep:**
- [ ] System Settings → Battery → Options → "Prevent automatic sleeping on power adapter when display is off" → ON

**Nightly loop:**
- [ ] Open a dedicated terminal tab
- [ ] `bash run-nightly.sh`
- [ ] Confirm it's running (leave tab open)

### Personalization (fill in before first session)

**Root `CLAUDE.md`:**
- [ ] Your name, company, start date
- [ ] Direct report names, titles, Slack handles
- [ ] Slack channel names

**`GOALS.md`:**
- [ ] Update 30/60/90 objectives to your actual situation

**`People/team.md`:**
- [ ] Add full team roster

**`profile/preferences.md`:**
- [ ] Fill in initial preferences (even rough ones — tuning will refine)
- [ ] Set start_date in `Data/synthesis-log.json` preference_tuning section to today

### First week rituals

| When | What |
|------|------|
| Each morning | `/daily-briefing` |
| Before each 1on1 | `/1on1-prep [name]` |
| After each Granola export | `/process-inbox` |
| When dropping a link | `/ingest-url [url]` |
| Friday afternoon | `/cascade` |

### People to create immediately
- [ ] `/new-1on1 [DR1]`
- [ ] `/new-1on1 [DR2]`
- [ ] (add stakeholders as you meet them)

---

## PHASE 11: Validate

After completing all phases, run these checks:

1. `find . -name "CLAUDE.md" | sort` — should show 7+ CLAUDE.md files
2. `cat Data/synthesis-log.json` — should be valid JSON with empty processed_files
3. `cat Data/open-loops.json` — should be valid JSON with empty loops array
4. `ls .claude/commands/` — should show 8 command files
5. `ls Workflows/` — should show 7 workflow files
6. `cat profile/preferences.md` — should exist and have all sections
7. `bash run-nightly.sh` in a separate tab — confirm it starts without error

Report any missing files or errors before marking setup complete.

---

*Generated: 2026-04-29 | Version: 2.0*
*Key changes from v1: daily briefing command, adaptive preference tuning, priority on open loops,
coaching pattern detection in nightly synthesis, no GitHub vault backup, Obsidian Sync as separate step*

# Phase 6: Workflow Playbooks
_Depends on: Phase 1 (_system/workflows/ must exist)_

### `_system/workflows/daily-briefing.md`

```markdown
# Daily Briefing Workflow

## Model: `claude-sonnet-4-6`
Synthesis and coaching reasoning over structured inputs — needs Sonnet.

## Purpose
Morning coaching briefing — not just a status report. Surfaces what needs attention,
makes connections, and recommends one clear action for the day.

## Trigger: `/personal-os-daily-briefing`

## Steps

1. **Load context**
   - Read `HEARTBEAT.md` (current focus, upcoming 1on1s)
   - Read `GOALS.md` (30/60/90 objectives)
   - Read `profile/preferences.md` (briefing preferences and coaching tone)

2. **Open loops triage**
   - Read `_system/data/open-loops.json`
   - Categorize: overdue → due this week → high priority → everything else
   - Flag any loop open >14 days without a status update
   - For critical/overdue loops: draft a one-line suggested action

3. **Meeting awareness**
   - Check `HEARTBEAT.md` for 1on1s today or tomorrow
   - If a 1on1 is today: surface last session summary + open loops for that person
   - Suggest running `/personal-os-1on1-prep [name]` if not already done

4. **Relationship health check**
   - Scan `People/team.md` and `People/stakeholders.md` for `Last contact:` fields
   - Flag anyone not contacted in >14 days (direct reports) or >21 days (stakeholders)
   - Format: "Haven't connected with [Name] in X days — open loops: N"

6. **Fresh from last night**
   - Read `_system/data/synthesis-log.json` → what was processed in the last nightly run
   - Surface: new wiki connections made, new open loops created, any patterns flagged

7. **Coaching insight** (index-first)
   - Read `1on1s/_index.md` → find people with sessions in the last 7 days
   - Read only those people's most recent summary (via sessions/_index.md) — do not scan all 1on1s
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
*Want to update any open loops? Run `/personal-os-open-loops` | Start cascade? `/personal-os-cascade`*

## Telegram delivery (optional)
After generating the briefing, ask: "Should I send this to Telegram?"
If yes, post the briefing to the configured Telegram chat.
```

### `_system/workflows/cascade.md`

```markdown
# Cascade Workflow

## Model: `claude-sonnet-4-6`
High-quality stakeholder drafts require synthesis and communication reasoning.

## Cadence: Weekly (Friday recommended)
## Audiences: Down (direct reports), Lateral (cross-functional), Up (C-suite)
## Use judgment on which audiences to activate each week

## Step 0: Context load (index-first)
1. Read `_system/data/open-loops.json` — filter for this week's overdue/new loops
2. Read `1on1s/_index.md` — identify people with sessions this week (by last session date)
3. Read only those people's most recent summary (via their sessions/_index.md) — do not scan all sessions
Surface overdue/newly closed loops and this week's 1on1 themes — these feed into the cascade.

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

### `_system/workflows/meeting-notes.md`

```markdown
# Meeting Notes Ingestion Workflow

## Model: `claude-haiku-4-5-20251001`
Structured extraction from raw transcripts — high input tokens, no deep reasoning needed.
Run as a separate subprocess per file so context resets between transcripts.

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
   - New commitments → append to `_system/data/open-loops.json` with priority and due date
   - Closed commitments → set status to "archived"

6. **Update action items** → append to `Meetings/action-items.md`

7. **Log in synthesis-log.json**

8. **Archive original** → move file to `Inbox/archive/transcripts/[filename]`
```

### `_system/workflows/pdf-ingestion.md`

```markdown
# PDF Ingestion Workflow

## Model: `claude-haiku-4-5-20251001`
Annotation is structured extraction — high input tokens, no reasoning needed.
Run as a separate subprocess per file.

## Prerequisite: `pip install markitdown`

## Steps

1. **Check synthesis-log.json** — skip if already processed

2. **Convert**
   ```
   markitdown "Inbox/pdfs/[filename].pdf" > "Inbox/pdfs/[filename].md"
   ```

3. **Annotate** using `_system/templates/source-annotation.md`
   - Metadata block, summary, key concepts, inferences, open questions
   - Identify connections to existing wiki pages

4. **File** annotated version to `Knowledge/sources/[slug].md`

5. **Queue for nightly wiki synthesis** — connections made during nightly run

6. **Log in synthesis-log.json**

7. **Archive original** → move PDF and converted .md to `Inbox/archive/pdfs/[filename]`
```

### `_system/workflows/1on1-prep.md`

```markdown
# 1on1 Prep Workflow

## Model: `claude-sonnet-4-6`
Context synthesis and probing question generation require reasoning.

## Trigger: `/personal-os-1on1-prep [name]`

1. Load `1on1s/[Name]/CLAUDE.md` and `profile.md`
2. Read `1on1s/[Name]/sessions/_index.md` → identify the 2 most recent sessions by date
3. Read only those 2 summary files — do not open the full sessions/ directory
4. Filter `_system/data/open-loops.json` where context_person = [Name]
5. Check `Meetings/_index.md` for shared meetings in the last 2 weeks — read only those files

6. Generate prep doc:
   - Their open commitments to me (overdue flagged)
   - My open commitments to them
   - Suggested agenda topics based on themes
   - One probing question I haven't asked yet
   - Relevant context from HEARTBEAT.md

7. Create session file from `_system/templates/1on1-session.md`
```

### `_system/workflows/preference-tuning.md`

```markdown
# Preference Tuning Workflow

## Model: `claude-sonnet-4-6`
Pattern analysis across processed content over time — needs reasoning, not extraction.

## Purpose
Update `profile/preferences.md` based on patterns observed in recent work.
Does NOT reprocess old content — reflects on patterns in what was recently processed.

## Adaptive schedule
Determined by `_system/data/synthesis-log.json` preference_tuning section:
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
7. Update `_system/data/synthesis-log.json` preference_tuning:
   - last_tuning_run: today
   - tuning_count: +1
   - next_tuning_date: calculated from schedule
   - current_schedule: recalculate based on days since start_date
```

### `_system/workflows/nightly-synthesis.md`

```markdown
# Nightly Synthesis Workflow

## Cadence: Nightly at 2am (persistent loop on always-on Mac)
## Design: incremental — only processes NEW or CHANGED files

## Execution model
Two-phase pipeline to keep context clean and model costs proportional:
- **Steps 1–3** (triage + per-file extraction): `claude-haiku-4-5-20251001`, one subprocess per file.
  Each file runs in an isolated `claude --print` call — context resets between files.
- **Steps 4–11** (connections, patterns, coaching, index updates): `claude-sonnet-4-6`, single pass.
  Reads only the compact outputs from Phase 1 — never the raw sources.

## Full algorithm

### Step 1: Load state
Read `_system/data/synthesis-log.json`

### Step 2: Find unprocessed files (index-first, no directory scans)
Read `_system/data/synthesis-log.json` to build the work queue — do NOT scan directories:
- Files referenced in `Inbox/transcripts/_index.md` but absent from synthesis-log → queue for processing
- Files in synthesis-log with a changed hash (compare MD5) → re-queue
- Do not open any file until it is specifically queued for processing
- Output queue as a newline-delimited list for the `run-nightly.sh` loop to consume

### Step 3: Process each file (ONE AT A TIME)
a. Determine type → apply correct workflow
b. Process (annotate / summarize / extract loops with priority)
c. Write output files
d. Update synthesis-log.json IMMEDIATELY after each file
   (if interrupted, picks up where it left off)
e. Move original to `Inbox/archive/[subfolder]/[filename]` — keep originals immutable, just relocated

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

### Step 8: Update directory indexes
After all files are processed, refresh each `_index.md`:
- `1on1s/_index.md` — update last session date, session count, last contact for any person touched tonight
- `1on1s/[Name]/sessions/_index.md` — append row for each new session processed
- `Knowledge/wiki/_index.md` — append row for each new wiki page created; update source count for existing
- `Meetings/_index.md` — append row for each meeting processed
Never rewrite the full index — append or update only the rows that changed.

### Step 9: Profile synthesis (triggered by session count)
After 10+ sessions with any single person:
- Re-read all their summaries
- Update `[Name]/profile.md` themes section with synthesized patterns
- Log as processing_type: "profile-synthesis"

After 5+ sources on any single wiki concept:
- Append "Synthesis as of [date]" section to that wiki page
- Do NOT delete prior connection entries

### Step 10: Preference tuning check
- Read preference_tuning from synthesis-log.json
- If today >= next_tuning_date: run `_system/workflows/preference-tuning.md`
- Update schedule after tuning completes

### Step 11: Update HEARTBEAT.md
- Last Nightly Synthesis: [today]
- Count of items processed
- Any patterns flagged (from Step 6)

### What counts as "changed"
File hash (MD5) differs from what's stored in synthesis-log.json.
```

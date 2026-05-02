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
   - Read `profile/preferences/briefing.md` (briefing preferences and coaching tone)

2. **Open loops triage**
   - Read `_system/data/open-loops.json`
   - Filter to canonical entries only (canonical_id = null, status ≠ merged)
   - Categorize: overdue → due this week → high priority → everything else
   - Flag any loop open >14 days without a status update
   - For critical/overdue loops: draft a one-line suggested action

2.5 **Commitment load check**
   - Count loops where status = open or in-progress and canonical_id = null
   - Count critical loops; count high + critical combined
   - Read `profile/preferences/briefing.md` for thresholds (defaults: critical ≥ 3, high+critical ≥ 8)
   - If either threshold is breached, add this section to the briefing:
     ```
     ### Commitment load
     You have [N] critical and [N] high-priority open loops.
     Consider reprioritizing before adding more. Longest-open candidates:
     - [Loop title] — [priority], open [N] days
     - [Loop title] — [priority], open [N] days
     - [Loop title] — [priority], open [N] days
     ```
   - If neither threshold is breached, omit this section entirely — no noise on healthy days

2.6 **Pillar balance check**
   - Read `PILLARS.md` to get pillar names
   - Count open + in-progress canonical loops per pillar (exclude nulls from percentage)
   - If any single pillar holds >60% of tagged loops, add this section:
     ```
     ### Pillar balance
     [Pillar Name]: [N] loops ([X]% of tagged work)
     Consider: are the other pillars on track, or just un-logged?
     ```
   - If distribution is healthy or fewer than 5 tagged loops exist, omit this section

3. **Meeting awareness**
   - Check `HEARTBEAT.md` for 1on1s today or tomorrow
   - If a 1on1 is today: surface last session summary + open loops for that person
   - Suggest running `/personal-os-1on1-prep [name]` if not already done

3.5 **Recent decisions**
   - Read `_system/data/decisions.json`
   - Filter: decisions where `date` >= 7 days ago OR `review_date` = today or past
   - Surface up to 3 decisions, sorted: review_date due first, then most recent
   - Format each as: "[DATE] [decision] — made by [made_by]"
   - If a decision has `review_date` = today or overdue: flag with "⚑ Review due"
   - If 0 decisions match the filter: omit this section entirely — no noise

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

### Recent decisions
[Decisions from last 7 days + any with overdue review dates — omitted if empty]

### Open loops requiring action
[Overdue / due today / high priority — with suggested action]

### Pillar balance
[Only shown when one pillar holds >60% of tagged loops]

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
4. Read `HEARTBEAT.md` — current focus, this week's priorities, open questions
5. Read `profile/preferences/writing-style.md` — use this to match voice and tone in all three drafts
Surface overdue/newly closed loops and this week's 1on1 themes — these feed into the cascade.

## Step 0.5: Surface priority open loops
Before asking any questions, display:

```
### Priority Open Loops This Week
[List top 3–5 loops sorted: overdue → critical → high]
| Loop | Owner | Days Open |
|------|-------|-----------|
```

This is context for what follows — not a question.

## Step 1: Elicitation — ask these questions ONE AT A TIME, wait for each answer

For each question, generate 3–5 options from the context loaded in Step 0 before asking.
Format each question as:

```
**Q[N]: [Question]**
Options (pick one or more, or type your own):
1. [Option derived from HEARTBEAT.md / open loops / recent 1on1 themes]
2. [Option derived from a closed/updated loop this week]
3. [Option derived from a 1on1 theme or summary from this week]
4. [Option derived from a flagged pattern or synthesis-log signal]
5. None of these — [type your own]
```

Questions:
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

### `_system/workflows/note-ingestion.md`

```markdown
# Note Ingestion Workflow

## Model: `claude-haiku-4-5-20251001`
Structured extraction from generic markdown notes — high input tokens, no deep reasoning needed.
Run as a separate subprocess per file so context resets between notes.

## When to run
When the Inbox router classifies a file as `note`.

## Steps

1. **Check synthesis-log.json** — if hash already in log, skip

2. **Annotate** using `_system/templates/source-annotation.md`:
   - Metadata block (source_type: note, original: filename, processed_at, relevance, key_concepts, connections, open_questions)
   - Summary (3–5 sentences: what this is, why it matters)
   - Key concepts, relevant quotes, inferences
   - Open questions raised
   - Connections to existing wiki pages

3. **File** annotated version to `Knowledge/sources/[slug].md`
   - Slug: lowercase title with spaces replaced by hyphens, max 50 chars

4. **Queue wiki connections** — list connection targets in the annotation's `connections` metadata field for Pass 3

5. **Update synthesis-log.json** — log the file with processing_type: "annotation", output_files: [Knowledge/sources/[slug].md]

6. **Update Inbox/_index.md** — set Type to `note`, Status to `processed`

7. **Archive original** → move file to `Inbox/_archive/[filename]`
```

### `_system/workflows/link-ingestion.md`

```markdown
# Link Ingestion Workflow

## Model: `claude-haiku-4-5-20251001`
URL fetching and annotation — high input tokens, no deep reasoning needed.
Run as a separate subprocess per file. All URLs in a file are fetched sequentially within one subprocess.

## When to run
When the Inbox router classifies a file as `link`.
A file is classified as `link` if it consists primarily of URLs (one or more), with optional surrounding notes.

## Steps

1. **Check synthesis-log.json** — if hash already in log, skip

2. **Extract all URLs** from the file — collect any http:// or https:// URLs

3. **For each URL, sequentially:**
   a. Fetch page content using WebFetch
      - If fetch fails (any error): write a stub annotation with source_type: url,
        original: URL, processed_at: now, and a `fetch_error: "[error message]"` field.
        File the stub to `Knowledge/sources/[slug].md` and continue to the next URL.
        Do not halt the workflow.
   b. Extract title and body text
   c. Annotate using `_system/templates/source-annotation.md`:
      - Metadata block (source_type: url, original: URL, processed_at, relevance, key_concepts, connections, open_questions)
      - Summary, key concepts, relevant quotes, inferences, open questions
      - If the source file contained notes or context alongside this URL, include them in the `inferences` field
   d. File annotated version to `Knowledge/sources/[slug].md`
      - Slug: strip protocol and `www.` from domain, keep only the root
        (e.g., `nytimes.com` → `nytimes`). Take the page `<title>` tag,
        lowercase it, remove any site-name suffix after the last `|` or `—`,
        strip all characters except letters, digits, and spaces, replace spaces
        with hyphens, truncate to 60 chars at a word boundary.
        If the resulting slug already exists as a file, append `-2`, `-3`, etc.
        Example: `nytimes-product-strategy-frameworks`

4. **Queue wiki connections** for each annotated source — list connection targets in each annotation's `connections` field — Pass 3 reads this during the nightly run

5. **Update synthesis-log.json** — log the source file with processing_type: "annotation", output_files: [all Knowledge/sources paths created]

6. **Update Inbox/_index.md** — set Type to `link`, Status to `processed`

7. **Archive original** → move file to `Inbox/_archive/[filename]`
```

### `_system/workflows/1on1-prep.md`

```markdown
# 1on1 Prep Workflow

## Model: `claude-sonnet-4-6`
Context synthesis and probing question generation require reasoning.

## Trigger: `/personal-os-1on1-prep [name]`

1. Check if `1on1s/[Name]/ready-note.md` exists — if it does, read it first. It's pre-built context; skip re-deriving anything already there and use it as the base for the prep doc.
2. Load `1on1s/[Name]/CLAUDE.md`, `profile.md`, and `profile/preferences/1on1.md`
3. Read `1on1s/[Name]/sessions/_index.md` → identify the 2 most recent sessions by date
4. Read only those 2 summary files — do not open the full sessions/ directory (unless ready-note.md was missing)
5. Filter `_system/data/open-loops.json` where context_person = [Name] (skip if already shown in ready-note)
6. Check `Meetings/_index.md` for shared meetings in the last 2 weeks — read only those files

7. Generate prep doc:
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
Update `profile/preferences/` modules based on patterns observed in recent work.
Does NOT reprocess old content — reflects on patterns in what was recently processed.

## Adaptive schedule
Determined by `_system/data/synthesis-log.json` preference_tuning section:
- Days 0–7 from start_date: daily
- Days 8–14: every 3 days
- Days 15–21: every 5 days
- Day 22+: weekly

## Steps

1. Read all preference modules: `profile/preferences/synthesis.md`, `profile/preferences/briefing.md`, `profile/preferences/knowledge.md`
2. Read synthesis-log for all files processed since last tuning run
3. Identify patterns:
   - Which topics/themes appeared most in processed content?
   - Which open loops were created most frequently? By whom?
   - What types of connections were made in the wiki?
   - Any topics consistently flagged as relevant that aren't in current filters?
4. Draft targeted updates — one per module that needs changing:
   - `synthesis.md`: update "What I care about most" if new themes emerged; append to "Feedback log"
   - `knowledge.md`: update "Currently relevant topics" if dominant topics shifted
   - `briefing.md`: update coaching tone or display preferences if feedback warrants
5. Present proposed updates — do NOT auto-apply without review
6. After approval, write updates to the specific module(s) that changed
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

### Step 5.0: Pillar auto-tagging
For each loop created or updated tonight where `pillar` is null:
1. Read `PILLARS.md` — extract each pillar's name and keywords list
2. Match loop title + project against each pillar's keywords (case-insensitive substring match)
3. On single match: set `pillar` to that pillar's name
4. On multiple matches: set `pillar` to the strongest match (most keyword hits)
5. On no match: leave `pillar` as null — do not guess
Loops with `pillar` already set are not re-tagged (preserve manual overrides).

### Step 5: Open loop maintenance
- Scan tonight's summaries for new commitments → append to open-loops.json with priority
- Flag loops where due_date < today and status = open or in-progress
- Flag loops where status = open and opened_date > 14 days ago (no update)

### Step 5.1: Deduplication pass
For each loop created in Step 5 tonight:
1. Compare against all existing open loops where `status` is `open` or `in-progress` and `canonical_id` is null
2. Match if ALL of: semantic title similarity (same action, different wording counts) + (context_person matches or either is null) + (project matches or either is null)
3. Two-phase check: Haiku extraction pass outputs a `match_candidate_id` field (or null) alongside the loop; Sonnet reasoning pass confirms or rejects before merging
4. **On confirmed match:**
   - Append tonight's source_file to matched loop's `source_files` array
   - If tonight's extraction has an earlier due_date, update the canonical's due_date
   - Mark tonight's new entry as `status: "merged"`, set `canonical_id` to the matched loop's ID
5. **On no match:** leave as canonical (canonical_id: null)
All workflows skip any loop where `status: "merged"` — only canonical entries are displayed or operated on.

### Step 5.2: Career evidence extraction
For each 1on1 summary and meeting summary processed tonight:
1. Scan for three signal types — extract only clear, unambiguous signals:
   - `feedback`: explicit praise or positive signal, must have a person attached (e.g., "Alice said great job on X")
   - `outcome`: concrete deliverable or resolution (e.g., "shipped the roadmap doc", "resolved the pricing dispute")
   - `growth`: handled something differently, changed approach, acted on coaching received (e.g., "I used to escalate immediately — this time I held the space")
2. Skip low-confidence or ambiguous extractions
3. For each clear signal, append to `_system/data/career-evidence.json`:
   - `id`: next ev-NNN in sequence
   - `type`: feedback | outcome | growth
   - `date`: date of the session or meeting
   - `title`: one-line portable summary, written as if for a resume bullet
   - `detail`: verbatim quote or close paraphrase from the source
   - `from`: person's name if attributable, null otherwise
   - `context`: meeting title or "1on1 with [Name]"
   - `source_file`: path to the summary file
   - `tags`: 1–3 skill areas or project names inferred from context
   - `starred`: false
4. Log IDs of created entries in synthesis-log.json as `career_evidence_created`

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

### Step 8.5: Rebuild ready notes
For each person touched tonight (new session processed, open loop created/updated, or last contact changed):
1. Read current `1on1s/[Name]/ready-note.md` if it exists
2. Extract the `<!-- MANUAL -->...<!-- END MANUAL -->` block — keep only the **last 15–30 lines** (trim oldest lines from the top if over 30; never drop below 15 if content exists)
3. Rebuild ready-note.md using `_system/templates/1on1-ready-note.md`:
   - Priority open loops: top 3–5 where context_person = Name, sorted overdue → critical → high; skip any loop where status = merged
   - Last session highlights: 2–3 bullets from the most recent summary
   - Session history: last 5 sessions (date + key topic + one-liner from summary)
   - Recent action items: open items from last 2 sessions — resolve through canonical_id before rendering (if a loop has multiple source_files, show once with "(+N sources)" annotation)
4. Re-insert the trimmed manual block verbatim between the `<!-- MANUAL -->` markers
5. If no `ready-note.md` exists yet (new person folder), create it from template with empty manual section

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
- If today is the first of the month and `BACKLOG.md` has open items: append a flag to HEARTBEAT.md Open Questions: "Backlog review due — N items open in BACKLOG.md"

### What counts as "changed"
File hash (MD5) differs from what's stored in synthesis-log.json.
```

### `_system/workflows/career-evidence.md`

````markdown
# Career Evidence Workflow

## Model: `claude-sonnet-4-6`
Synthesis and narrative framing of accumulated evidence require reasoning.

## Trigger: `/personal-os-career-evidence [last 90d | last 6mo | all]`
Default: last 90 days

## Steps

1. **Load evidence**
   - Read `_system/data/career-evidence.json`
   - Parse date range from $ARGUMENTS (default: 90 days back from today)
   - Filter entries where date >= range start
   - Note count of starred entries

2. **Group and rank**
   - Group by type: feedback → outcomes → growth
   - Within each group: starred entries first, then by date descending

3. **Render digest** using `_system/templates/career-evidence-digest.md`:
   - Feedback section: each entry as `[DATE] [FROM]: "[detail]" — [context]`
   - Outcomes section: each entry as `[DATE]: [title] — [detail]`
   - Growth section: each entry as `[DATE]: [title] — [detail]`
   - Mark starred entries with ★

4. **Offer next actions** after the digest:
   ```
   ---
   To star entries for your portfolio: "star ev-001, ev-007"
   To generate a brag doc: "brag doc"
   ```

5. **Handle "star [IDs]"**
   - Update `starred: true` for each listed ID in career-evidence.json
   - Confirm: "Starred: ev-001, ev-007"

6. **Handle "brag doc"**
   - Read `profile/preferences/writing-style.md` — match voice and tone exactly
   - Synthesize: starred entries first, then fill with highest-signal unstarred entries to reach 3–5 paragraphs
   - Write in first person, past tense, concrete and specific — no generic claims
   - Save to `profile/career/YYYY-MM-DD-brag-doc.md` (YYYY-MM-DD = today)
   - Report: "Saved to profile/career/[filename]"
````

### `_system/workflows/week-ahead.md`

```markdown
# Week-Ahead Workflow

## Model: `claude-sonnet-4-6`
## Trigger: `/personal-os-week-ahead`
## Best run: Sunday evening or Monday morning

## Step 1: Load preferences
- Read `profile/preferences/calendar.md` if it exists
  - Extract: large meeting threshold (default 4), focus block length (default 90min), days ahead (default 5)
  - Note calendar source: google | apple | none
- If `profile/preferences/calendar.md` does not exist: assume calendar source = none
- Read `profile/preferences/briefing.md` for coaching tone

## Step 2: Calendar scan (conditional)
If calendar source = google:
  - Use Google Calendar MCP to list events for next [days_ahead] days
  - For each event: title, date, time, attendee count, duration
If calendar source = apple:
  - Use macOS Calendar MCP or ask: "Please paste your calendar for this week"
If calendar source = none:
  - Skip to Step 4 — surface loops only

## Step 3: Flag meetings needing prep
For each meeting with attendee count >= large_meeting_threshold OR duration >= 60 min:
1. Check `1on1s/[Name]/ready-note.md` — exists and last rebuilt within 3 days → "Ready-note exists"
2. Check `Meetings/_index.md` for an existing notes file for this meeting → "Notes exist"
3. Otherwise → "No prep — consider `/personal-os-1on1-prep [name]`"

## Step 4: Surface focus-required loops
- Read `_system/data/open-loops.json`
- Filter: canonical loops (canonical_id = null) where `requires_focus` = true AND status = open or in-progress
- Sort: overdue → due this week → critical → high
- Display: title, pillar, priority, days open, due date

## Step 5: Suggest focus blocks
For each requires_focus loop (top 3 only):
- If calendar available: identify the next open morning slot ≥ [focus_block_length] minutes in the next [days_ahead] days
  - Suggest: "Block [DAY] [TIME] for '[loop title]'"
- If no calendar: suggest "Consider blocking [focus_block_length] min before [due_date] for '[loop title]'"
- If no due date: suggest "Consider scheduling 90 min this week for '[loop title]'"

## Step 6: Generate and save week-ahead brief

Save output to `_system/briefings/week-ahead-YYYY-MM-DD.md` (YYYY-MM-DD = Sunday's date).

# Week Ahead — [DATE RANGE]

### This week's schedule
[Calendar events — date, time, meeting name, prep status]
[Or: "No calendar connected — create `profile/preferences/calendar.md` to enable calendar scanning"]

### Meetings needing prep
[Flagged meetings with attendee count or duration + prep status]
[Omit if all meetings have prep ready]

### Focus work this week
[requires_focus loops with suggested time blocks]
[Omit if no requires_focus loops]

### Week theme
[One sentence: what does this week need to go well for the 30/60/90 goals to stay on track]

---
*Update a loop? `/personal-os-open-loops` | Run 1on1 prep? `/personal-os-1on1-prep [name]`*

## Telegram delivery (optional)
After saving, ask: "Should I send this to Telegram?"
If yes, post the brief to the configured Telegram chat.
```

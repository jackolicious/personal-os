# Meeting Prep Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Auto-generate a scannable prep doc for every calendar meeting before the day starts, integrated into the 5am automation run with graceful degradation when no calendar is connected.

**Architecture:** Meeting prep runs as a new Sonnet pass at 5am, before the daily briefing, so the briefing can link to ready prep docs. Each prep doc is saved to `Meetings/prep/YYYY-MM-DD-[slug].md`. The daily briefing's Meetings Today section becomes a simple linked list. On-demand regeneration is available via `/personal-os-meeting-prep [slug]`.

**Tech Stack:** Claude Code slash commands, `run-nightly.sh` bash automation, Sonnet for context synthesis, Google Calendar MCP (optional — graceful degradation to manual/none)

---

## File map

| File | Action | Purpose |
|------|--------|---------|
| `_system/templates/meeting-prep.md` | Create | Base prep doc structure |
| `_system/workflows/meeting-prep.md` | Create | Classification, context loading, generation logic |
| `.claude/commands/personal-os-meeting-prep.md` | Create | On-demand command |
| `_system/workflows/daily-briefing.md` | Modify Step 3 | Replace meeting awareness with linked list |
| `run-nightly.sh` | Modify 5am block | Add meeting-prep pass before briefing generation |
| `_bootstrap/phases/06-workflows.md` | Modify | Add meeting-prep workflow for future installs |
| `_bootstrap/phases/07-commands.md` | Modify | Add meeting-prep command for future installs |
| `_bootstrap/phases/08-automation.md` | Modify | Add meeting-prep pass to 5am block for future installs |
| `_bootstrap/tests/06-workflows.sh` | Modify | Add assertions for meeting-prep workflow |
| `_bootstrap/tests/07-commands.sh` | Modify | Add assertions for meeting-prep command |

---

## Task 1: Create meeting-prep template

**Files:**
- Create: `_system/templates/meeting-prep.md`

- [ ] **Step 1: Create the template**

```markdown
# {{TITLE}}
{{DATE}} · {{TIME}} · {{DURATION}}

## Who
<!-- One line per attendee: Name — Role · Last contact: X days ago / first time -->
<!-- Omit if no attendees known -->

## Goals
<!-- 1-3 bullets specific to this meeting — not generic -->
<!-- Omit if cannot be inferred -->

## Context
<!-- Open loops with attendees, relevant decisions, relevant wiki -->
<!-- OMIT ENTIRE SECTION IF EMPTY — no filler -->

## Questions to ask
<!-- 2-3 specific questions -->

## Listen for
<!-- Signals for a new CPO: alignment, blockers, trust cues, priorities -->

---
_After: `/personal-os-remember` to file anything worth keeping_
```

Save to `_system/templates/meeting-prep.md`.

- [ ] **Step 2: Verify file exists**

```bash
ls "_system/templates/meeting-prep.md"
```

Expected: file listed.

---

## Task 2: Create meeting-prep workflow

**Files:**
- Create: `_system/workflows/meeting-prep.md`

- [ ] **Step 1: Create the workflow**

```markdown
# Meeting Prep Workflow

## Model: Sonnet
Context synthesis and meeting classification require reasoning.

## Trigger
1. Automatically: 5am in run-nightly.sh, before daily briefing generation
2. On-demand: `/personal-os-meeting-prep [slug]`

---

## Step 1: Load calendar source

Read `profile/preferences/calendar.md` if it exists.
- Extract: calendar_source (google | apple | none)
- If file doesn't exist or calendar_source = none:
  Output exactly: `NO_CALENDAR`
  Stop — the 5am run will note this in the briefing.

## Step 2: Pull today's events

If calendar_source = google:
  Use Google Calendar MCP to list events for today (all-day and timed).
  For each event collect: title, start time, end time, attendees (name + email).

If calendar_source = apple:
  Use macOS Calendar MCP if available.
  If unavailable: output `NO_CALENDAR` and stop.

If running on-demand ($ARGUMENTS provided):
  Treat $ARGUMENTS as the meeting title or slug.
  Ask: "Who are the attendees? (name and role, one per line — or press enter to skip)"
  Proceed with whatever is provided.

Skip all-day events with no attendees (holidays, OOO blocks).

## Step 3: Classify each event

Evaluate rules in this order — first match wins:

1. executive: any attendee title contains CEO, CFO, CTO, COO, President, VP of Engineering,
   VP of Product; OR attendee is flagged as C-suite in People/stakeholders.md
2. 1on1: exactly 2 attendees (including Jack)
3. team: title (case-insensitive) contains "standup", "all-hands", "team sync",
   "sprint review", "sprint retro", "all hands"
4. external: at least one attendee email domain differs from Jack's domain
5. cross-functional: 3+ attendees, all internal (same email domain)
6. unknown: none of the above

## Step 4: Load vault context for each event

Load only what exists — skip gracefully if files are missing.
Do not error on missing files; omit that context type.

For all meeting types:
- Open loops: read _system/data/open-loops.json — filter where context_person matches
  any attendee name (case-insensitive). Skip if file missing.
- Decisions: read _system/data/decisions.json — filter where date >= 30 days ago
  AND any attendee appears in made_by field. Skip if file missing.
- Wiki: read Knowledge/wiki/_index.md — identify pages where concept column
  matches attendee name or meeting title keywords. Skip if file missing.

For 1on1 type additionally:
- Read 1on1s/[Name]/ready-note.md if it exists. If it does, use it as the primary
  context source — skip re-deriving what is already there.

For team type additionally:
- Read 1on1s/_index.md — identify team members with sessions in the last 14 days.
- For each: read their most recent session summary (via sessions/_index.md).
  Do not scan all sessions. Load max 3 people.

## Step 5: Generate prep doc for each event

Use _system/templates/meeting-prep.md as the structure.
Apply base layer for all meetings, then add the type overlay.

### Base layer (all types)

Fill each section from context loaded in Step 4.
Brevity rules — enforce strictly:
- Any section with no content: OMIT IT ENTIRELY (no "none yet", no empty bullets)
- Max 3 bullets per section
- Goals: specific to this meeting — not "align on priorities" unless that is literally true
- Cold start (no vault context on any attendee): generate goals/questions from
  meeting title + roles, framed for a new CPO in listening/learning posture.
  Add footer line: "No prior context on [Name] — run `/personal-os-remember` after."

### Type overlays (append after base)

**1on1 (direct report)**
If ready-note exists: pull directly from it:
- Their open commitments to you (open loops, owner = them)
- Your open commitments to them (open loops, owner = Jack)
- One probing question not yet asked (from ready-note or generate based on themes)
Format as three short sections appended after the base content.

**Cross-functional / executive**
Append:
```
## Their stake
[What they care about — from stakeholders.md or inferred from role]

## What you need
[Specific ask, unblock, or decision required from them — omit if none]
```

**Team / all-hands**
Append:
```
## Pulse from recent 1on1s
[Key themes from last sessions with people in this meeting — max 3 bullets — OMIT IF EMPTY]

## What the team needs to hear
[1-2 bullets based on current HEARTBEAT.md priorities — omit if no context]
```

**External**
Append:
```
## Research
[From Knowledge/annotated/ matching attendee/company — OMIT IF EMPTY]

## Relationship goal
[What you want from this relationship — infer from context or meeting title]
```

**Unknown**
Base layer only. Append:
`_Note: Could not classify — review attendee list._`

## Step 6: Save each prep doc

Path: `Meetings/prep/YYYY-MM-DD-[slug].md`
- YYYY-MM-DD: today's date
- slug: meeting title lowercased, spaces replaced with hyphens, non-alphanumeric
  characters removed, truncated to 40 chars at a word boundary
- Create `Meetings/prep/` directory if it does not exist

If a file already exists at that path: overwrite it (on-demand regeneration).

## Step 7: Output

Print one line per prep doc created:
`PREP: Meetings/prep/[filename]`

The daily briefing workflow reads these paths to build the Meetings Today section.
If NO_CALENDAR was returned in Step 1, print:
`NO_CALENDAR`
```

Save to `_system/workflows/meeting-prep.md`.

- [ ] **Step 2: Verify file exists**

```bash
ls "_system/workflows/meeting-prep.md"
```

Expected: file listed.

---

## Task 3: Create on-demand command

**Files:**
- Create: `.claude/commands/personal-os-meeting-prep.md`

- [ ] **Step 1: Create the command**

```markdown
Generate meeting prep docs.

Usage: /personal-os-meeting-prep [optional: meeting name or slug]

$ARGUMENTS may contain a meeting name or slug to generate prep for a single meeting.
If $ARGUMENTS is empty, generate prep for all of today's meetings.

Follow _system/workflows/meeting-prep.md exactly.

After completing, report each file created:
"Prep ready: Meetings/prep/[filename]"
```

Save to `.claude/commands/personal-os-meeting-prep.md`.

- [ ] **Step 2: Verify file exists**

```bash
ls ".claude/commands/personal-os-meeting-prep.md"
```

Expected: file listed.

---

## Task 4: Update daily briefing Step 3

**Files:**
- Modify: `_system/workflows/daily-briefing.md`

The current Step 3 generates meeting awareness inline. Replace it so it reads prep docs that have already been generated by the 5am meeting-prep pass.

- [ ] **Step 1: Locate the current Step 3 in `_system/workflows/daily-briefing.md`**

Find the section starting with `3. **Meeting awareness**`.

- [ ] **Step 2: Replace Step 3 with the following**

```markdown
3. **Meetings today**
   - Scan `Meetings/prep/` for files matching today's date: `YYYY-MM-DD-*.md`
     where YYYY-MM-DD is today's date
   - For each file found: read the first line (meeting title) and the
     second line (date · time · duration) to extract title and start time
   - Sort by start time ascending
   - Format as:
     ```
     ### Meetings today
     - [TIME] · [Title] → Meetings/prep/[filename]
     ```
   - If no prep files found for today:
     - Check if `profile/preferences/calendar.md` exists and has a calendar source set
     - If yes: "Prep not yet generated — runs at 5am with the briefing"
     - If no: "No calendar connected — run `/personal-os-meeting-prep` to generate prep manually"
```

- [ ] **Step 3: Also update the Output format section**

Find the `### Meetings today` line in the `## Output format` block. Replace it with:

```markdown
### Meetings today
- [TIME] · [Title] → Meetings/prep/[filename]
[One line per meeting, sorted by start time — omit section if no calendar connected and no prep files exist]
```

- [ ] **Step 4: Remove the Telegram delivery note at the bottom of Step 3**

The old Step 3 had a note about running `/personal-os-1on1-prep`. Remove any such suggestion — the prep docs replace it.

- [ ] **Step 5: Verify the change**

```bash
grep -n "Meetings today\|meeting-prep\|Meetings/prep" "_system/workflows/daily-briefing.md"
```

Expected: lines referencing `Meetings/prep/` and `personal-os-meeting-prep`.

---

## Task 5: Update run-nightly.sh

**Files:**
- Modify: `run-nightly.sh`

Add the meeting-prep pass inside the 5am block, before briefing generation. Meeting prep must run first so the briefing can link to ready prep docs.

- [ ] **Step 1: Locate the 5am block in `run-nightly.sh`**

Find:
```bash
if [ "$HOUR" = "05" ] && [ "$BRIEFING_DONE_DATE" != "$TODAY" ]; then
  BRIEF_FILE="$VAULT_DIR/_system/briefings/$TODAY.md"
  if [ ! -f "$BRIEF_FILE" ]; then
    echo "$(date): Generating daily briefing..."
```

- [ ] **Step 2: Insert the meeting-prep pass before briefing generation**

Replace the `if [ ! -f "$BRIEF_FILE" ]; then` block with:

```bash
  if [ ! -f "$BRIEF_FILE" ]; then
    LOG="$VAULT_DIR/_system/logs/nightly.log"

    # Meeting prep pass — runs first so briefing can link to prep docs
    echo "$(date): Generating meeting prep docs..." | tee -a "$LOG"
    mkdir -p "$VAULT_DIR/Meetings/prep"
    claude --model claude-sonnet-4-6 --print \
      "$(cat "$VAULT_DIR/.claude/commands/personal-os-meeting-prep.md")" \
      >> "$LOG" 2>&1
    echo "$(date): Meeting prep complete." | tee -a "$LOG"

    echo "$(date): Generating daily briefing..."
    claude --model claude-sonnet-4-6 --print \
      "$(cat "$VAULT_DIR/.claude/commands/personal-os-daily-briefing.md")" \
      > "$BRIEF_FILE" 2>&1
    echo "$(date): Briefing saved to $BRIEF_FILE"
  fi
```

- [ ] **Step 3: Verify shell syntax**

```bash
bash -n run-nightly.sh
```

Expected: no output (clean parse).

- [ ] **Step 4: Verify the meeting-prep pass is present**

```bash
grep -n "meeting-prep\|Meeting prep" run-nightly.sh
```

Expected: two lines — the echo and the claude call.

---

## Task 6: Write bootstrap tests (TDD — write first, run to confirm they fail)

**Files:**
- Modify: `_bootstrap/tests/06-workflows.sh`
- Modify: `_bootstrap/tests/07-commands.sh`

- [ ] **Step 1: Add assertions to `_bootstrap/tests/06-workflows.sh`**

Find the end of the file (before the final summary block `echo ""` / `echo "=== Summary ==="`). Add:

```bash
# ---------------------------------------------------------------------------
# meeting-prep
# ---------------------------------------------------------------------------
echo "-- meeting-prep --"

check_present "$FILE" "meeting-prep" \
  "meeting-prep: workflow file defined"

check_present "$FILE" "meeting-prep.md" \
  "meeting-prep: references workflow file path"

check_present "$FILE" "calendar_source" \
  "meeting-prep: calendar source handling present"

check_present "$FILE" "NO_CALENDAR" \
  "meeting-prep: NO_CALENDAR graceful degradation defined"

check_present "$FILE" "executive\|cross-functional\|1on1\|external" \
  "meeting-prep: meeting type classification defined"

check_present "$FILE" "Meetings/prep" \
  "meeting-prep: output path defined"

check_present "$FILE" "Brevity\|brevity\|OMIT" \
  "meeting-prep: brevity rules present"
```

- [ ] **Step 2: Add assertions to `_bootstrap/tests/07-commands.sh`**

Find the file's final summary block and insert before it:

```bash
# ---------------------------------------------------------------------------
# personal-os-meeting-prep
# ---------------------------------------------------------------------------
echo "-- personal-os-meeting-prep --"

check_present "$FILE" "personal-os-meeting-prep" \
  "meeting-prep: command defined"

check_present "$FILE" "meeting-prep.md\|meeting-prep workflow" \
  "meeting-prep: command references workflow"

check_present "$FILE" 'ARGUMENTS\|\$ARGUMENTS' \
  "meeting-prep: command handles arguments"
```

- [ ] **Step 3: Run tests — confirm they fail**

```bash
bash _bootstrap/tests/06-workflows.sh | grep "FAIL.*meeting-prep"
bash _bootstrap/tests/07-commands.sh | grep "FAIL.*meeting-prep"
```

Expected: FAIL lines for each new assertion (phases not yet updated).

---

## Task 7: Update bootstrap phase 06 (workflows)

**Files:**
- Modify: `_bootstrap/phases/06-workflows.md`

- [ ] **Step 1: Append meeting-prep workflow definition**

> **Important:** The condensed content block below is for illustration. When updating the bootstrap phase, copy the COMPLETE workflow content from `_system/workflows/meeting-prep.md` (created in Task 2) verbatim inside the code fence. The bootstrap template must produce the full vault file on a fresh install.

At the end of `_bootstrap/phases/06-workflows.md`, add the section header and the full content of `_system/workflows/meeting-prep.md` inside a fenced code block, following the same pattern as every other workflow in that file. The condensed version below shows the required structure:

````markdown
### `_system/workflows/meeting-prep.md`

```markdown
# Meeting Prep Workflow

## Model: Sonnet
Context synthesis and meeting classification require reasoning.

## Trigger
1. Automatically: 5am in run-nightly.sh, before daily briefing generation
2. On-demand: `/personal-os-meeting-prep [slug]`

## Step 1: Load calendar source

Read `profile/preferences/calendar.md` if it exists.
- Extract: calendar_source (google | apple | none)
- If file doesn't exist or calendar_source = none: output `NO_CALENDAR` and stop.

## Step 2: Pull today's events

If calendar_source = google: use Google Calendar MCP to list today's events.
For each event collect: title, start time, end time, attendees (name + email).
If calendar_source = apple: use macOS Calendar MCP if available; otherwise output `NO_CALENDAR` and stop.
If on-demand ($ARGUMENTS provided): treat $ARGUMENTS as meeting title/slug, ask for attendees.
Skip all-day events with no attendees.

## Step 3: Classify each event

Evaluate in order — first match wins:
1. executive: attendee title contains CEO, CFO, CTO, COO, President, or is C-suite in People/stakeholders.md
2. 1on1: exactly 2 attendees including Jack
3. team: title contains "standup", "all-hands", "team sync", "sprint review", "sprint retro"
4. external: at least one attendee email domain differs from Jack's
5. cross-functional: 3+ attendees, all internal
6. unknown: none of the above

## Step 4: Load vault context for each event

Load only what exists — skip gracefully if files are missing.
- Open loops: _system/data/open-loops.json — filter by context_person matching any attendee
- Decisions: _system/data/decisions.json — filter by date >= 30d ago and attendee in made_by
- Wiki: Knowledge/wiki/_index.md — pages matching attendee names or meeting title keywords
- 1on1 only: read 1on1s/[Name]/ready-note.md if it exists
- Team only: read most recent session summary for up to 3 team members in this meeting

## Step 5: Generate prep doc

Use _system/templates/meeting-prep.md as structure.
Apply base layer for all meetings, then type overlay.

Brevity rules — enforce strictly:
- Omit any section with no content (no "none yet" or empty bullets)
- Max 3 bullets per section
- Goals: specific to this meeting, not generic
- Cold start: generate from title + roles, frame for new CPO in listening posture.
  Add: "No prior context on [Name] — run `/personal-os-remember` after."

Type overlays:
- 1on1: add their commitments to you, your commitments to them, one probing question
- cross-functional/executive: add "Their stake" and "What you need" sections
- team: add "Pulse from recent 1on1s" and "What the team needs to hear" sections
- external: add "Research" (from Knowledge/annotated/) and "Relationship goal" sections
- unknown: base layer only, add "Could not classify" note

## Step 6: Save and output

Path: `Meetings/prep/YYYY-MM-DD-[slug].md`
Slug: title lowercased, spaces to hyphens, non-alphanumeric removed, max 40 chars.
Create Meetings/prep/ if it doesn't exist. Overwrite if file exists.

Print one line per doc: `PREP: Meetings/prep/[filename]`
If no calendar: print `NO_CALENDAR`
```
````

- [ ] **Step 2: Run phase 06 tests**

```bash
bash _bootstrap/tests/06-workflows.sh | tail -5
```

Expected: all meeting-prep assertions now PASS; summary shows 0 new failures.

---

## Task 8: Update bootstrap phase 07 (commands)

**Files:**
- Modify: `_bootstrap/phases/07-commands.md`

- [ ] **Step 1: Append meeting-prep command definition**

At the end of `_bootstrap/phases/07-commands.md`, add:

````markdown
### `.claude/commands/personal-os-meeting-prep.md`

```markdown
Generate meeting prep docs.

Usage: /personal-os-meeting-prep [optional: meeting name or slug]

$ARGUMENTS may contain a meeting name or slug to generate prep for a single meeting.
If $ARGUMENTS is empty, generate prep for all of today's meetings.

Follow _system/workflows/meeting-prep.md exactly.

After completing, report each file created:
"Prep ready: Meetings/prep/[filename]"
```
````

- [ ] **Step 2: Run phase 07 tests**

```bash
bash _bootstrap/tests/07-commands.sh | tail -5
```

Expected: meeting-prep assertions now PASS.

---

## Task 9: Update bootstrap phase 08 (automation)

**Files:**
- Modify: `_bootstrap/phases/08-automation.md`

- [ ] **Step 1: Locate the 5am block in the `run-nightly.sh` template inside phase 08**

Find in `_bootstrap/phases/08-automation.md`:
```
  if [ "$HOUR" = "05" ] && [ "$BRIEFING_DONE_DATE" != "$TODAY" ]; then
    BRIEF_FILE="$VAULT_DIR/_system/briefings/$TODAY.md"
    if [ ! -f "$BRIEF_FILE" ]; then
      echo "$(date): Generating daily briefing..."
```

- [ ] **Step 2: Replace that block with the updated version**

```bash
  if [ "$HOUR" = "05" ] && [ "$BRIEFING_DONE_DATE" != "$TODAY" ]; then
    BRIEF_FILE="$VAULT_DIR/_system/briefings/$TODAY.md"
    if [ ! -f "$BRIEF_FILE" ]; then
      LOG="$VAULT_DIR/_system/logs/nightly.log"

      # Meeting prep pass — runs first so briefing can link to prep docs
      echo "$(date): Generating meeting prep docs..." | tee -a "$LOG"
      mkdir -p "$VAULT_DIR/Meetings/prep"
      claude --model claude-sonnet-4-6 --print \
        "$(cat "$VAULT_DIR/.claude/commands/personal-os-meeting-prep.md")" \
        >> "$LOG" 2>&1
      echo "$(date): Meeting prep complete." | tee -a "$LOG"

      echo "$(date): Generating daily briefing..."
      claude --model claude-sonnet-4-6 --print \
        "$(cat "$VAULT_DIR/.claude/commands/personal-os-daily-briefing.md")" \
        > "$BRIEF_FILE" 2>&1
      echo "$(date): Briefing saved to $BRIEF_FILE"
    fi
```

- [ ] **Step 3: Also add meeting-prep template entry to the permissions list in the settings.json block**

No new permissions needed — all required permissions (`Read(*)`, `Write(*)`, `Edit(*)`, `Bash(mkdir *)`) are already in the template.

- [ ] **Step 4: Verify the change**

```bash
grep -n "meeting-prep\|Meeting prep" _bootstrap/phases/08-automation.md
```

Expected: two lines — the echo and the claude call.

---

## Task 10: Run all bootstrap tests and commit

- [ ] **Step 1: Run full test suite**

```bash
bash _bootstrap/tests/run-all.sh
```

Expected: all tests pass. Note the new total assertion count.

- [ ] **Step 2: Commit**

```bash
git add _bootstrap/phases/06-workflows.md \
        _bootstrap/phases/07-commands.md \
        _bootstrap/phases/08-automation.md \
        _bootstrap/tests/06-workflows.sh \
        _bootstrap/tests/07-commands.sh
git commit -m "$(cat <<'EOF'
feat: add proactive meeting prep to Personal OS

Auto-generates scannable prep docs for every calendar meeting before
the day starts. Integrated into the 5am run with graceful degradation
when no calendar is connected. On-demand via /personal-os-meeting-prep.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"
```

- [ ] **Step 3: Verify commit**

```bash
git log --oneline -3
```

Expected: new commit at top.

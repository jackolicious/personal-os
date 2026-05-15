# Nightly Synthesis — Phase 8 Bootstrap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bootstrap the full nightly automation pipeline so the 2am synthesis + 5am briefing loop actually runs.

**Architecture:** Extract runtime files verbatim from the bootstrap phase specs, initialize empty data files, and write `run-nightly.sh`. The phase specs (06-workflows.md, 07-commands.md, 08-automation.md) are the source of truth — runtime files are derived copies. A new runtime validation test script verifies every file exists with the right content before declaring done.

**Tech Stack:** Bash, Claude CLI (`claude --print`), JSON, Markdown workflow files.

---

## Gap inventory (what exists vs. what's needed)

### Currently exists in `_system/workflows/`:
- ghostwriter-init.md, ghostwriter.md, meeting-prep.md

### Missing (nightly synthesis depends on these):
- nightly-synthesis.md, meeting-notes.md, pdf-ingestion.md, note-ingestion.md,
  link-ingestion.md, daily-briefing.md, preference-tuning.md, wiki-lint.md

### Missing from `_system/data/`:
- synthesis-log.json, open-loops.json, decisions.json, career-evidence.json
  (entire `_system/data/` directory doesn't exist yet)

### Missing from `_system/templates/`:
- source-annotation.md, wiki-page.md, 1on1-ready-note.md, 1on1-summary.md,
  meeting-summary.md
  (only meeting-prep.md currently exists)

### Missing from `.claude/commands/`:
- personal-os-daily-briefing.md, personal-os-nightly.md

### Missing from vault root:
- `run-nightly.sh`

### Missing from `.claude/`:
- `settings.json` (automation permissions)

---

## Task 1: Write the runtime validation test script

Write tests first — they define what "done" means.

**Files:**
- Create: `_bootstrap/tests/runtime-phase8.sh`

- [ ] **Step 1: Create the test script**

```bash
#!/usr/bin/env bash
# Validates that all Phase 8 runtime files exist and contain required content.
# Run from vault root: bash _bootstrap/tests/runtime-phase8.sh

set -euo pipefail
PASS=0; FAIL=0
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

check_exists() {
  local path="$ROOT/$1" label="$2"
  if [ -f "$path" ]; then
    echo "PASS: $label"; PASS=$((PASS+1))
  else
    echo "FAIL: $label — missing: $1"; FAIL=$((FAIL+1))
  fi
}

check_contains() {
  local path="$ROOT/$1" pattern="$2" label="$3"
  if grep -q "$pattern" "$path" 2>/dev/null; then
    echo "PASS: $label"; PASS=$((PASS+1))
  else
    echo "FAIL: $label — pattern not found in $1"; FAIL=$((FAIL+1))
  fi
}

check_valid_json() {
  local path="$ROOT/$1" label="$2"
  if python3 -m json.tool "$path" > /dev/null 2>&1; then
    echo "PASS: $label"; PASS=$((PASS+1))
  else
    echo "FAIL: $label — invalid JSON: $1"; FAIL=$((FAIL+1))
  fi
}

check_bash_syntax() {
  local path="$ROOT/$1" label="$2"
  if bash -n "$path" 2>/dev/null; then
    echo "PASS: $label"; PASS=$((PASS+1))
  else
    echo "FAIL: $label — bash syntax error: $1"; FAIL=$((FAIL+1))
  fi
}

check_executable() {
  local path="$ROOT/$1" label="$2"
  if [ -x "$path" ]; then
    echo "PASS: $label"; PASS=$((PASS+1))
  else
    echo "FAIL: $label — not executable: $1"; FAIL=$((FAIL+1))
  fi
}

echo "=== runtime-phase8: data files ==="
check_exists "_system/data/synthesis-log.json"  "synthesis-log.json exists"
check_valid_json "_system/data/synthesis-log.json" "synthesis-log.json valid JSON"
check_contains "_system/data/synthesis-log.json" '"schema_version": 2' "synthesis-log: schema_version 2"
check_contains "_system/data/synthesis-log.json" '"processed_files"' "synthesis-log: processed_files key"
check_contains "_system/data/synthesis-log.json" '"preference_tuning"' "synthesis-log: preference_tuning key"

check_exists "_system/data/open-loops.json" "open-loops.json exists"
check_valid_json "_system/data/open-loops.json" "open-loops.json valid JSON"
check_contains "_system/data/open-loops.json" '"schema_version": 2' "open-loops: schema_version 2"
check_contains "_system/data/open-loops.json" '"loops"' "open-loops: loops array"

check_exists "_system/data/decisions.json" "decisions.json exists"
check_valid_json "_system/data/decisions.json" "decisions.json valid JSON"
check_contains "_system/data/decisions.json" '"decisions"' "decisions: decisions array"

check_exists "_system/data/career-evidence.json" "career-evidence.json exists"
check_valid_json "_system/data/career-evidence.json" "career-evidence.json valid JSON"
check_contains "_system/data/career-evidence.json" '"evidence"' "career-evidence: evidence array"

echo ""
echo "=== runtime-phase8: templates ==="
check_exists "_system/templates/source-annotation.md"  "source-annotation.md exists"
check_contains "_system/templates/source-annotation.md" "source_type" "source-annotation: source_type field"
check_contains "_system/templates/source-annotation.md" "key_concepts" "source-annotation: key_concepts field"
check_contains "_system/templates/source-annotation.md" "connections" "source-annotation: connections field"

check_exists "_system/templates/wiki-page.md" "wiki-page.md exists"
check_contains "_system/templates/wiki-page.md" "concept:" "wiki-page: concept frontmatter"
check_contains "_system/templates/wiki-page.md" "sources:" "wiki-page: sources frontmatter"

check_exists "_system/templates/1on1-ready-note.md" "1on1-ready-note.md exists"
check_contains "_system/templates/1on1-ready-note.md" "MANUAL" "1on1-ready-note: MANUAL block"
check_contains "_system/templates/1on1-ready-note.md" "Priority Open Loops" "1on1-ready-note: Priority Open Loops section"

check_exists "_system/templates/1on1-summary.md" "1on1-summary.md exists"
check_contains "_system/templates/1on1-summary.md" "One-line read" "1on1-summary: One-line read section"
check_contains "_system/templates/1on1-summary.md" "Open loops opened" "1on1-summary: Open loops opened section"

check_exists "_system/templates/meeting-summary.md" "meeting-summary.md exists"
check_contains "_system/templates/meeting-summary.md" "Key decisions" "meeting-summary: Key decisions section"
check_contains "_system/templates/meeting-summary.md" "Action items" "meeting-summary: Action items section"

echo ""
echo "=== runtime-phase8: ingestion workflows ==="
check_exists "_system/workflows/meeting-notes.md" "meeting-notes.md exists"
check_contains "_system/workflows/meeting-notes.md" "Model: Haiku" "meeting-notes: Model is Haiku"
check_contains "_system/workflows/meeting-notes.md" "synthesis-log.json" "meeting-notes: references synthesis-log"
check_contains "_system/workflows/meeting-notes.md" "open-loops.json" "meeting-notes: references open-loops"

check_exists "_system/workflows/pdf-ingestion.md" "pdf-ingestion.md exists"
check_contains "_system/workflows/pdf-ingestion.md" "Model: Haiku" "pdf-ingestion: Model is Haiku"
check_contains "_system/workflows/pdf-ingestion.md" "markitdown" "pdf-ingestion: uses markitdown"

check_exists "_system/workflows/note-ingestion.md" "note-ingestion.md exists"
check_contains "_system/workflows/note-ingestion.md" "Model: Haiku" "note-ingestion: Model is Haiku"
check_contains "_system/workflows/note-ingestion.md" "Knowledge/annotated" "note-ingestion: files to annotated"

check_exists "_system/workflows/link-ingestion.md" "link-ingestion.md exists"
check_contains "_system/workflows/link-ingestion.md" "Model: Haiku" "link-ingestion: Model is Haiku"
check_contains "_system/workflows/link-ingestion.md" "WebFetch" "link-ingestion: uses WebFetch"

echo ""
echo "=== runtime-phase8: nightly synthesis workflow ==="
check_exists "_system/workflows/nightly-synthesis.md" "nightly-synthesis.md exists"
check_contains "_system/workflows/nightly-synthesis.md" "Step 1: Load state" "nightly-synthesis: Step 1"
check_contains "_system/workflows/nightly-synthesis.md" "Step 4: Wiki connections" "nightly-synthesis: Step 4"
check_contains "_system/workflows/nightly-synthesis.md" "Step 11: Update HEARTBEAT" "nightly-synthesis: Step 11"
check_contains "_system/workflows/nightly-synthesis.md" "synthesis-log.json" "nightly-synthesis: references synthesis-log"
check_contains "_system/workflows/nightly-synthesis.md" "Haiku" "nightly-synthesis: Haiku model referenced"
check_contains "_system/workflows/nightly-synthesis.md" "Sonnet" "nightly-synthesis: Sonnet model referenced"

echo ""
echo "=== runtime-phase8: support workflows ==="
check_exists "_system/workflows/preference-tuning.md" "preference-tuning.md exists"
check_contains "_system/workflows/preference-tuning.md" "Model: Sonnet" "preference-tuning: Model is Sonnet"
check_contains "_system/workflows/preference-tuning.md" "next_tuning_date" "preference-tuning: updates next_tuning_date"

check_exists "_system/workflows/wiki-lint.md" "wiki-lint.md exists"
check_contains "_system/workflows/wiki-lint.md" "Model: Sonnet" "wiki-lint: Model is Sonnet"
check_contains "_system/workflows/wiki-lint.md" "Orphan pages" "wiki-lint: checks for orphan pages"
check_contains "_system/workflows/wiki-lint.md" "_lint-report.md" "wiki-lint: writes lint report"

echo ""
echo "=== runtime-phase8: daily briefing ==="
check_exists "_system/workflows/daily-briefing.md" "daily-briefing.md exists"
check_contains "_system/workflows/daily-briefing.md" "Model: Sonnet" "daily-briefing: Model is Sonnet"
check_contains "_system/workflows/daily-briefing.md" "open-loops.json" "daily-briefing: reads open-loops"
check_contains "_system/workflows/daily-briefing.md" "HEARTBEAT.md" "daily-briefing: reads HEARTBEAT"

check_exists ".claude/commands/personal-os-daily-briefing.md" "personal-os-daily-briefing command exists"
check_contains ".claude/commands/personal-os-daily-briefing.md" "daily-briefing.md" "daily-briefing command: references workflow"

check_exists ".claude/commands/personal-os-nightly.md" "personal-os-nightly command exists"
check_contains ".claude/commands/personal-os-nightly.md" "nightly-synthesis.md" "nightly command: references workflow"

echo ""
echo "=== runtime-phase8: run-nightly.sh ==="
check_exists "run-nightly.sh" "run-nightly.sh exists"
check_bash_syntax "run-nightly.sh" "run-nightly.sh passes bash -n"
check_executable "run-nightly.sh" "run-nightly.sh is executable"
check_contains "run-nightly.sh" 'HOUR.*02\|"02"' "run-nightly.sh: 2am trigger for nightly"
check_contains "run-nightly.sh" 'HOUR.*05\|"05"' "run-nightly.sh: 5am trigger for briefing"
check_contains "run-nightly.sh" 'DOW.*7\|"7"' "run-nightly.sh: Sunday week-ahead"
check_contains "run-nightly.sh" 'claude-haiku' "run-nightly.sh: Haiku for passes 1-2"
check_contains "run-nightly.sh" 'claude-sonnet' "run-nightly.sh: Sonnet for pass 3"
check_contains "run-nightly.sh" 'sleep 300' "run-nightly.sh: 5-min poll interval"
check_contains "run-nightly.sh" 'NIGHTLY_DONE_DATE' "run-nightly.sh: run-once guard"

echo ""
echo "=== runtime-phase8: .claude/settings.json ==="
check_exists ".claude/settings.json" ".claude/settings.json exists"
check_valid_json ".claude/settings.json" ".claude/settings.json valid JSON"
check_contains ".claude/settings.json" '"Read(\*)"' "settings.json: Read(*) allowed"
check_contains ".claude/settings.json" '"Write(\*)"' "settings.json: Write(*) allowed"

echo ""
TOTAL=$((PASS + FAIL))
echo "Results: $PASS passed, $FAIL failed ($TOTAL total)"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
```

Save to `_bootstrap/tests/runtime-phase8.sh`.

- [ ] **Step 2: Make it executable**

```bash
chmod +x "_bootstrap/tests/runtime-phase8.sh"
```

- [ ] **Step 3: Run to confirm everything fails (expected)**

```bash
bash "_bootstrap/tests/runtime-phase8.sh" || true
```

Expected: many FAIL lines. That's correct — we haven't created the files yet.

- [ ] **Step 4: Commit the test script**

```bash
git add "_bootstrap/tests/runtime-phase8.sh"
git commit -m "test: add runtime validation for Phase 8 nightly synthesis"
```

---

## Task 2: Initialize data files

**Files:**
- Create: `_system/data/synthesis-log.json`
- Create: `_system/data/open-loops.json`
- Create: `_system/data/decisions.json`
- Create: `_system/data/career-evidence.json`

- [ ] **Step 1: Create the data directory and all four JSON files**

```bash
mkdir -p "_system/data"
```

Create `_system/data/synthesis-log.json`:
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

Create `_system/data/open-loops.json`:
```json
{
  "schema_version": 2,
  "loops": []
}
```

Create `_system/data/decisions.json`:
```json
{
  "schema_version": 1,
  "decisions": []
}
```

Create `_system/data/career-evidence.json`:
```json
{
  "schema_version": 1,
  "evidence": []
}
```

- [ ] **Step 2: Run the runtime validation tests (data section only)**

```bash
bash "_bootstrap/tests/runtime-phase8.sh" 2>&1 | grep -A1 "data files"
```

Expected: 9 PASS, 0 FAIL for the data files section.

- [ ] **Step 3: Commit**

```bash
git add "_system/data/"
git commit -m "feat: initialize data files for nightly synthesis"
```

---

## Task 3: Create missing templates

Source: `_bootstrap/phases/05-templates.md` — extract the markdown blocks verbatim.

**Files:**
- Create: `_system/templates/source-annotation.md`
- Create: `_system/templates/wiki-page.md`
- Create: `_system/templates/1on1-ready-note.md`
- Create: `_system/templates/1on1-summary.md`
- Create: `_system/templates/meeting-summary.md`

- [ ] **Step 1: Create `_system/templates/source-annotation.md`**

Extract the `source-annotation.md` block from `_bootstrap/phases/05-templates.md` exactly as written. Content:

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

- [ ] **Step 2: Create `_system/templates/wiki-page.md`**

Extract from `_bootstrap/phases/05-templates.md`:

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

- [ ] **Step 3: Create `_system/templates/1on1-ready-note.md`**

Extract from `_bootstrap/phases/05-templates.md`:

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

- [ ] **Step 4: Create `_system/templates/1on1-summary.md`**

Extract from `_bootstrap/phases/05-templates.md`:

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

- [ ] **Step 5: Create `_system/templates/meeting-summary.md`**

Extract from `_bootstrap/phases/05-templates.md`:

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

- [ ] **Step 6: Run template tests**

```bash
bash "_bootstrap/tests/runtime-phase8.sh" 2>&1 | grep "templates"
```

Expected: all template assertions PASS.

- [ ] **Step 7: Commit**

```bash
git add "_system/templates/"
git commit -m "feat: add missing templates for ingestion workflows"
```

---

## Task 4: Create ingestion workflow files

Source: `_bootstrap/phases/06-workflows.md` — extract each workflow block verbatim.

**Files:**
- Create: `_system/workflows/meeting-notes.md`
- Create: `_system/workflows/pdf-ingestion.md`
- Create: `_system/workflows/note-ingestion.md`
- Create: `_system/workflows/link-ingestion.md`

- [ ] **Step 1: Create `_system/workflows/meeting-notes.md`**

Extract the `meeting-notes.md` block from `_bootstrap/phases/06-workflows.md`. Content starts at `# Meeting Notes Ingestion Workflow` and ends before `### _system/workflows/pdf-ingestion.md`. Copy verbatim.

- [ ] **Step 2: Create `_system/workflows/pdf-ingestion.md`**

Extract the `pdf-ingestion.md` block from `_bootstrap/phases/06-workflows.md`. Starts at `# PDF Ingestion Workflow`.

- [ ] **Step 3: Create `_system/workflows/note-ingestion.md`**

Extract the `note-ingestion.md` block from `_bootstrap/phases/06-workflows.md`. Starts at `# Note Ingestion Workflow`.

- [ ] **Step 4: Create `_system/workflows/link-ingestion.md`**

Extract the `link-ingestion.md` block from `_bootstrap/phases/06-workflows.md`. Starts at `# Link Ingestion Workflow`.

- [ ] **Step 5: Run ingestion workflow tests**

```bash
bash "_bootstrap/tests/runtime-phase8.sh" 2>&1 | grep "ingestion"
```

Expected: all ingestion assertions PASS.

- [ ] **Step 6: Commit**

```bash
git add "_system/workflows/meeting-notes.md" "_system/workflows/pdf-ingestion.md" \
        "_system/workflows/note-ingestion.md" "_system/workflows/link-ingestion.md"
git commit -m "feat: add Inbox ingestion workflow files"
```

---

## Task 5: Create nightly synthesis workflow

**Files:**
- Create: `_system/workflows/nightly-synthesis.md`

- [ ] **Step 1: Create `_system/workflows/nightly-synthesis.md`**

Extract the `nightly-synthesis.md` block from `_bootstrap/phases/06-workflows.md`. Starts at `# Nightly Synthesis Workflow`. This is the longest workflow — copy every step verbatim (Steps 1 through 11.5).

- [ ] **Step 2: Run nightly synthesis tests**

```bash
bash "_bootstrap/tests/runtime-phase8.sh" 2>&1 | grep "nightly synthesis"
```

Expected: all 7 assertions PASS.

- [ ] **Step 3: Commit**

```bash
git add "_system/workflows/nightly-synthesis.md"
git commit -m "feat: add nightly synthesis workflow (core compounding layer)"
```

---

## Task 6: Create support workflows

**Files:**
- Create: `_system/workflows/preference-tuning.md`
- Create: `_system/workflows/wiki-lint.md`

- [ ] **Step 1: Create `_system/workflows/preference-tuning.md`**

Extract the `preference-tuning.md` block from `_bootstrap/phases/06-workflows.md`. Starts at `# Preference Tuning Workflow`.

- [ ] **Step 2: Create `_system/workflows/wiki-lint.md`**

Extract the `wiki-lint.md` block from `_bootstrap/phases/06-workflows.md`. Starts at `# Wiki Lint Workflow`.

- [ ] **Step 3: Run support workflow tests**

```bash
bash "_bootstrap/tests/runtime-phase8.sh" 2>&1 | grep "support"
```

Expected: all support workflow assertions PASS.

- [ ] **Step 4: Commit**

```bash
git add "_system/workflows/preference-tuning.md" "_system/workflows/wiki-lint.md"
git commit -m "feat: add preference-tuning and wiki-lint support workflows"
```

---

## Task 7: Create daily briefing workflow and commands

**Files:**
- Create: `_system/workflows/daily-briefing.md`
- Create: `.claude/commands/personal-os-daily-briefing.md`
- Create: `.claude/commands/personal-os-nightly.md`

- [ ] **Step 1: Create `_system/workflows/daily-briefing.md`**

Extract the `daily-briefing.md` block from `_bootstrap/phases/06-workflows.md`. Starts at `# Daily Briefing Workflow`, ends before `### _system/workflows/cascade.md`. Copy verbatim.

- [ ] **Step 2: Create `.claude/commands/personal-os-daily-briefing.md`**

Extract from `_bootstrap/phases/07-commands.md`. Content:

```markdown
Generate the daily coaching briefing.

Load `profile/preferences/briefing.md` first — this governs tone, depth, and what to surface.
Then follow `_system/workflows/daily-briefing.md` exactly.

At the end, ask: "Should I send this to Telegram?"
```

- [ ] **Step 3: Create `.claude/commands/personal-os-nightly.md`**

Extract from `_bootstrap/phases/07-commands.md`. Content:

```markdown
Run nightly synthesis manually.

Follow `_system/workflows/nightly-synthesis.md` exactly.
Process only new/changed files — never reprocess what's already in synthesis-log.
Report: files processed, loops created, wiki pages updated, any patterns flagged.
```

- [ ] **Step 4: Run daily briefing tests**

```bash
bash "_bootstrap/tests/runtime-phase8.sh" 2>&1 | grep "briefing\|nightly command"
```

Expected: all assertions PASS.

- [ ] **Step 5: Commit**

```bash
git add "_system/workflows/daily-briefing.md" \
        ".claude/commands/personal-os-daily-briefing.md" \
        ".claude/commands/personal-os-nightly.md"
git commit -m "feat: add daily briefing workflow and slash commands"
```

---

## Task 8: Create run-nightly.sh

**Files:**
- Create: `run-nightly.sh`

- [ ] **Step 1: Create `run-nightly.sh`**

Extract verbatim from `_bootstrap/phases/08-automation.md` Step 1. Full content:

```bash
#!/bin/bash
# Personal OS — persistent automation loop
# Run in a dedicated terminal tab on your always-on Mac.
# Prerequisite: System Settings > Battery > Options > "Prevent automatic sleeping when on power adapter"

set -euo pipefail
VAULT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$VAULT_DIR/_system/logs" "$VAULT_DIR/_system/briefings"

echo "Personal OS loop started at $(date). Ctrl+C to stop."

NIGHTLY_DONE_DATE=""
BRIEFING_DONE_DATE=""
WEEK_AHEAD_DONE_DATE=""

while true; do
  TODAY="$(date +%Y-%m-%d)"
  HOUR="$(date +%H)"
  DOW="$(date +%u)"  # 1=Mon ... 7=Sun

  # Nightly synthesis at 02:00 — three-pass pipeline
  if [ "$HOUR" = "02" ] && [ "$NIGHTLY_DONE_DATE" != "$TODAY" ]; then
    echo "$(date): Running nightly synthesis..."
    LOG="$VAULT_DIR/_system/logs/nightly.log"
    QUEUE="$VAULT_DIR/_system/logs/nightly-queue-$TODAY.txt"

    # Step 0: Build Inbox queue (shell — no LLM needed)
    echo "$(date): Step 0 — scanning Inbox for new files..." | tee -a "$LOG"
    [ -f "$VAULT_DIR/Inbox/_index.md" ] || printf "| File | Type | Status | Added |\n|------|------|--------|-------|\n" > "$VAULT_DIR/Inbox/_index.md"
    [ -f "$VAULT_DIR/Inbox/_unrouted.md" ] || printf "# Inbox — Unrouted Files\n\nFiles the nightly router couldn't classify. Rename or move them to help it next time.\n\n" > "$VAULT_DIR/Inbox/_unrouted.md"
    find "$VAULT_DIR/Inbox" -maxdepth 1 -type f ! -name '_*' | while IFS= read -r FILE; do
      grep -qF "| $FILE |" "$VAULT_DIR/Inbox/_index.md" || \
        printf "| %s | unknown | pending | %s |\n" "$FILE" "$TODAY" >> "$VAULT_DIR/Inbox/_index.md"
    done

    # Pass 1 (Haiku): identify unprocessed files → write queue
    echo "$(date): Pass 1 — building work queue..." | tee -a "$LOG"
    claude --model claude-haiku-4-5 --print \
      "Read _system/data/synthesis-log.json and Inbox/_index.md.
Output one file path per line for each file where Status=pending and not already in synthesis-log. No other text." \
      > "$QUEUE" 2>> "$LOG"

    # Pass 2 (Haiku): process each file in its own subprocess
    echo "$(date): Pass 2 — per-file extraction..." | tee -a "$LOG"
    while IFS= read -r FILE; do
      [ -z "$FILE" ] && continue
      echo "$(date): Processing $FILE" | tee -a "$LOG"
      claude --model claude-haiku-4-5 --print \
        "Classify this file using these rules:
- link: file consists primarily of URLs (http:// or https://), with optional surrounding notes
- transcript: file has speaker labels, timestamps, or meeting header metadata
- pdf: file has a .pdf extension
- note: .md file that is neither a transcript nor a link
- unrouted: anything else (binary files, unknown extensions, ambiguous content)

Then process it using the matching workflow:
- transcript → _system/workflows/meeting-notes.md
- pdf → _system/workflows/pdf-ingestion.md
- note → _system/workflows/note-ingestion.md
- link → _system/workflows/link-ingestion.md
- unrouted → append filename + one-line description to Inbox/_unrouted.md, update Inbox/_index.md status to flagged, log in synthesis-log.json to prevent re-queuing, stop.

If the file is already in synthesis-log (hash match), skip immediately.
After processing: update Inbox/_index.md — set Type to the classified type and Status to processed.

File: $FILE" \
        2>&1 >> "$LOG"
    done < "$QUEUE"

    # Pass 3 (Sonnet): connections, patterns, coaching, index updates
    echo "$(date): Pass 3 — synthesis and pattern detection..." | tee -a "$LOG"
    claude --model claude-sonnet-4-6 --print \
      "Follow _system/workflows/nightly-synthesis.md Steps 4–11 only.
Per-file extraction (Steps 1–3) is already complete for tonight. Stop." \
      2>&1 >> "$LOG"

    NIGHTLY_DONE_DATE="$TODAY"
    sleep 60
  fi

  # Daily briefing at 05:00 — only if nightly has run today (or it's already morning)
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
    BRIEFING_DONE_DATE="$TODAY"
    sleep 60
  fi

  # Week-ahead brief on Sunday at 20:00
  if [ "$DOW" = "7" ] && [ "$HOUR" = "20" ] && [ "$WEEK_AHEAD_DONE_DATE" != "$TODAY" ]; then
    WEEK_FILE="$VAULT_DIR/_system/briefings/week-ahead-$TODAY.md"
    if [ ! -f "$WEEK_FILE" ]; then
      echo "$(date): Generating week-ahead brief..."
      claude --model claude-sonnet-4-6 --print \
        "$(cat "$VAULT_DIR/.claude/commands/personal-os-week-ahead.md")" \
        > "$WEEK_FILE" 2>&1
      echo "$(date): Week-ahead saved to $WEEK_FILE"
    fi
    WEEK_AHEAD_DONE_DATE="$TODAY"
    sleep 60
  fi

  sleep 300  # check every 5 minutes
done
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x "run-nightly.sh"
```

- [ ] **Step 3: Run bash syntax check**

```bash
bash -n "run-nightly.sh" && echo "Syntax OK"
```

Expected: `Syntax OK` with no errors.

- [ ] **Step 4: Run run-nightly.sh tests**

```bash
bash "_bootstrap/tests/runtime-phase8.sh" 2>&1 | grep "run-nightly"
```

Expected: all 9 assertions PASS.

- [ ] **Step 5: Commit**

```bash
git add "run-nightly.sh"
git commit -m "feat: add run-nightly.sh automation loop (2am synthesis + 5am briefing)"
```

---

## Task 9: Configure .claude/settings.json

**Files:**
- Create: `.claude/settings.json`

Note: check if this file already exists before writing it. If it does, merge the `allow` array rather than overwriting.

- [ ] **Step 1: Check if .claude/settings.json already exists**

```bash
cat ".claude/settings.json" 2>/dev/null || echo "FILE_NOT_FOUND"
```

- [ ] **Step 2a: If FILE_NOT_FOUND — create it**

```json
{
  "permissions": {
    "allow": [
      "Read(*)",
      "Write(*)",
      "Edit(*)",
      "Bash(find *)",
      "Bash(ls *)",
      "Bash(mv *)",
      "Bash(mkdir *)",
      "Bash(markitdown *)",
      "Bash(md5 *)",
      "Bash(md5sum *)",
      "Bash(cat *)",
      "Bash(grep *)",
      "Bash(date *)",
      "mcp__plugin_telegram_telegram__reply"
    ]
  }
}
```

- [ ] **Step 2b: If file already exists — merge the allow list**

Read the existing file. Add any missing entries from the list above into the existing `allow` array. Do not remove any existing entries. Write the merged result back.

- [ ] **Step 3: Validate JSON**

```bash
python3 -m json.tool ".claude/settings.json" > /dev/null && echo "Valid JSON"
```

Expected: `Valid JSON`

- [ ] **Step 4: Run settings tests**

```bash
bash "_bootstrap/tests/runtime-phase8.sh" 2>&1 | grep "settings"
```

Expected: all assertions PASS.

- [ ] **Step 5: Commit**

```bash
git add ".claude/settings.json"
git commit -m "feat: configure .claude/settings.json automation permissions"
```

---

## Task 10: Full validation and final commit

- [ ] **Step 1: Run the full runtime test suite**

```bash
bash "_bootstrap/tests/runtime-phase8.sh"
```

Expected: 0 FAIL. All assertions PASS.

- [ ] **Step 2: Run the full bootstrap test suite**

```bash
bash "_bootstrap/tests/run-all.sh"
```

Expected: 0 FAIL across all phases. Any failures must be investigated and fixed before proceeding.

- [ ] **Step 3: Verify directory structure**

```bash
ls "_system/data/" && ls "_system/workflows/" && ls "_system/templates/"
```

Expected output:
- `_system/data/`: career-evidence.json, decisions.json, open-loops.json, synthesis-log.json
- `_system/workflows/`: daily-briefing.md, ghostwriter.md, ghostwriter-init.md, link-ingestion.md, meeting-notes.md, meeting-prep.md, note-ingestion.md, nightly-synthesis.md, pdf-ingestion.md, preference-tuning.md, wiki-lint.md
- `_system/templates/`: 1on1-ready-note.md, 1on1-summary.md, meeting-prep.md, meeting-summary.md, source-annotation.md, wiki-page.md

- [ ] **Step 4: If all tests pass, open a PR**

Use `superpowers:finishing-a-development-branch` to choose between merge and PR. This feature is complete and self-contained — a squash PR is appropriate.

---

## Post-implementation: Starting the loop

After merging, to start the nightly automation:

1. Open a dedicated terminal tab in the vault directory
2. Run: `bash run-nightly.sh`
3. Leave the tab open (do not close it)
4. Ensure Mac sleep is disabled on power adapter: System Settings > Battery > Options > "Prevent automatic sleeping when on power adapter"

The loop checks every 5 minutes. The first nightly synthesis will fire at 2am, first daily briefing at 5am.

To run synthesis manually without waiting for 2am: `/personal-os-nightly`
To run the daily briefing manually: `/personal-os-daily-briefing`

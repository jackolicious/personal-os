# Inbox Processing Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Flatten `Inbox/` into a type-agnostic drop zone with automatic routing, an `_index.md` queue maintained by the nightly job, and vault-dump-compatible import.

**Architecture:** A shell Step 0 runs `find` on `Inbox/` once per nightly run to add new files to `Inbox/_index.md`. Pass 1 reads that index, then each Haiku subprocess reads a file exactly once — classifying it and processing it in the same pass using the appropriate workflow. Unrouted files are flagged in `Inbox/_unrouted.md` and surfaced in the daily briefing.

**Tech Stack:** Bash (shell queue-building), Claude Haiku (per-file classification + extraction), Claude Sonnet (synthesis pass). All changes are to Markdown workflow/template files and one shell script.

---

## File map

| Action | File | What changes |
|--------|------|-------------|
| Modify | `_bootstrap/phases/01-scaffold.md` | Flatten Inbox subfolders → flat drop zone + `_archive/` |
| Modify | `_bootstrap/phases/04-data.md` | Add `Inbox/_index.md` schema + creation step |
| Modify | `_bootstrap/phases/06-workflows.md` | Add note-ingestion + link-ingestion; update nightly-synthesis + daily-briefing |
| Modify | `_bootstrap/phases/08-automation.md` | Add Step 0 to run-nightly.sh; update Pass 1 + Pass 2 prompts |
| Modify | `README.md` | Inbox architecture, drop zone docs, quickstart Day 1, vault import |
| Modify | `setup.sh` | Update transcript tool paths from `Inbox/transcripts/` → `Inbox/` |

---

## Task 1: Flatten Inbox scaffold

**Files:**
- Modify: `_bootstrap/phases/01-scaffold.md`

- [ ] **Step 1: Verify current scaffold**

```bash
grep -n "Inbox" "_bootstrap/phases/01-scaffold.md"
```

Expected output shows `Inbox/links/`, `Inbox/pdfs/`, `Inbox/transcripts/`, `Inbox/scratch/`, `Inbox/archive/` and typed archive subfolders.

- [ ] **Step 2: Replace the Inbox block**

In `_bootstrap/phases/01-scaffold.md`, replace the entire Inbox section of the directory listing:

Old block (lines inside the code fence starting with `Inbox/`):
```
Inbox/
Inbox/links/
Inbox/pdfs/
Inbox/transcripts/
Inbox/scratch/
Inbox/archive/
Inbox/archive/links/
Inbox/archive/pdfs/
Inbox/archive/transcripts/
Inbox/archive/scratch/
```

New block:
```
Inbox/
Inbox/_archive/
```

- [ ] **Step 3: Add system file creation instructions**

After the directory listing code fence, add:

```markdown
After creating directories, create these system files:

**`Inbox/_index.md`**
```markdown
| File | Type | Status | Added |
|------|------|--------|-------|
```

**`Inbox/_unrouted.md`**
```markdown
# Inbox — Unrouted Files

Files the nightly router couldn't classify. Rename or move them to help it next time.

```
```

- [ ] **Step 4: Verify**

```bash
grep -n "Inbox" "_bootstrap/phases/01-scaffold.md"
```

Expected: only `Inbox/` and `Inbox/_archive/` remain. No `transcripts/`, `pdfs/`, `links/`, `scratch/`.

- [ ] **Step 5: Commit**

```bash
git add "_bootstrap/phases/01-scaffold.md"
git commit -m "feat: flatten Inbox scaffold to type-agnostic drop zone"
```

---

## Task 2: Add Inbox/_index.md schema to data models

**Files:**
- Modify: `_bootstrap/phases/04-data.md`

- [ ] **Step 1: Verify current indexes section**

```bash
grep -n "_index.md\|Inbox" "_bootstrap/phases/04-data.md"
```

Expected: no Inbox index in the file yet; existing indexes are for `1on1s/`, `Meetings/`, `Knowledge/wiki/`, `Interviews/`.

- [ ] **Step 2: Add Inbox/_index.md schema**

In `_bootstrap/phases/04-data.md`, find the `### Directory indexes` section. It ends with:

```
Rule: if a workflow needs to know what's in a directory, it reads `_index.md` first.
It only opens individual files when it knows specifically which ones it needs.

Create empty `_index.md` files in: `1on1s/`, `Meetings/`, `Knowledge/wiki/`, `Interviews/`.
```

Replace that closing line with:

```markdown
Rule: if a workflow needs to know what's in a directory, it reads `_index.md` first.
It only opens individual files when it knows specifically which ones it needs.

**`Inbox/_index.md`** — one row per file dropped in Inbox/, append-only:
```markdown
| File | Type | Status | Added |
|------|------|--------|-------|
| Inbox/2026-04-28-standup.md | transcript | processed | 2026-04-28 |
| Inbox/some-doc.pdf | pdf | pending | 2026-04-29 |
| Inbox/old-note.md | unrouted | flagged | 2026-04-29 |
```

Types: `transcript` | `pdf` | `note` | `link` | `unrouted`
Statuses: `pending` → `processed` (or `flagged` for unrouted)

The nightly shell step adds new files as `unknown / pending`. Pass 1 updates both Type and Status after processing.

Create empty `_index.md` files in: `1on1s/`, `Meetings/`, `Knowledge/wiki/`, `Interviews/`.
`Inbox/_index.md` and `Inbox/_unrouted.md` are created in Phase 1 with their initial content.
```

- [ ] **Step 3: Verify**

```bash
grep -n "Inbox/_index" "_bootstrap/phases/04-data.md"
```

Expected: schema block now present.

- [ ] **Step 4: Commit**

```bash
git add "_bootstrap/phases/04-data.md"
git commit -m "feat: add Inbox/_index.md schema to data models"
```

---

## Task 3: Add note-ingestion workflow

**Files:**
- Modify: `_bootstrap/phases/06-workflows.md`

- [ ] **Step 1: Find insertion point**

```bash
grep -n "pdf-ingestion\|link-ingestion\|note-ingestion\|### \`_system/workflows" "_bootstrap/phases/06-workflows.md"
```

Note the line number after the `pdf-ingestion.md` closing fence — insert the new workflow there.

- [ ] **Step 2: Add note-ingestion workflow**

After the closing ` ``` ` of the `pdf-ingestion.md` block, insert:

````markdown
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

5. **Update synthesis-log.json** — log the file with processing_type: "annotation"

6. **Update Inbox/_index.md** — set Type to `note`, Status to `processed`

7. **Archive original** → move file to `Inbox/_archive/[filename]`
```
````

- [ ] **Step 3: Verify**

```bash
grep -n "note-ingestion" "_bootstrap/phases/06-workflows.md"
```

Expected: at least 2 hits (the heading and a reference in nightly-synthesis).

- [ ] **Step 4: Commit**

```bash
git add "_bootstrap/phases/06-workflows.md"
git commit -m "feat: add note-ingestion workflow to bootstrap"
```

---

## Task 4: Add link-ingestion workflow

**Files:**
- Modify: `_bootstrap/phases/06-workflows.md`

- [ ] **Step 1: Add link-ingestion workflow**

After the closing ` ``` ` of the `note-ingestion.md` block just added, insert:

````markdown
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
   b. Extract title and body text
   c. Annotate using `_system/templates/source-annotation.md`:
      - Metadata block (source_type: url, original: URL, processed_at, relevance, key_concepts, connections, open_questions)
      - Summary, key concepts, relevant quotes, inferences, open questions
      - If the source file contained notes or context alongside this URL, include them in the `inferences` field
   d. File annotated version to `Knowledge/sources/[slug].md`
      - Slug: domain + hyphenated title, max 60 chars (e.g., `nytimes-product-strategy-frameworks`)

4. **Queue wiki connections** for each annotated source — list connection targets in each annotation's `connections` field for Pass 3

5. **Update synthesis-log.json** — log the source file with processing_type: "annotation", output_files: all Knowledge/sources paths created

6. **Update Inbox/_index.md** — set Type to `link`, Status to `processed`

7. **Archive original** → move file to `Inbox/_archive/[filename]`
```
````

- [ ] **Step 2: Verify**

```bash
grep -n "link-ingestion" "_bootstrap/phases/06-workflows.md"
```

Expected: heading line present.

- [ ] **Step 3: Commit**

```bash
git add "_bootstrap/phases/06-workflows.md"
git commit -m "feat: add link-ingestion workflow to bootstrap"
```

---

## Task 5: Update nightly-synthesis to use router

**Files:**
- Modify: `_bootstrap/phases/06-workflows.md`

- [ ] **Step 1: Find the current Step 2 in nightly-synthesis**

```bash
grep -n "Inbox/transcripts/_index\|Find unprocessed\|Step 2:" "_bootstrap/phases/06-workflows.md"
```

Note the line number of Step 2.

- [ ] **Step 2: Update Step 2 to read from Inbox/_index.md**

In the `nightly-synthesis.md` workflow, find:

```markdown
### Step 2: Find unprocessed files (index-first, no directory scans)
Read `_system/data/synthesis-log.json` to build the work queue — do NOT scan directories:
- Files referenced in `Inbox/transcripts/_index.md` but absent from synthesis-log → queue for processing
- Files in synthesis-log with a changed hash (compare MD5) → re-queue
- Do not open any file until it is specifically queued for processing
- Output queue as a newline-delimited list for the `run-nightly.sh` loop to consume
```

Replace with:

```markdown
### Step 2: Find unprocessed files (index-first)
The shell Step 0 in `run-nightly.sh` has already scanned `Inbox/` and updated `Inbox/_index.md` before this workflow runs. Read it now:
- Read `Inbox/_index.md` — collect all rows where Status = `pending`
- Read `_system/data/synthesis-log.json` — exclude any pending file whose hash is already in the log
- Output the remaining file paths as a newline-delimited queue for the `run-nightly.sh` loop to consume
- Do not open any file until it is specifically queued for processing
```

- [ ] **Step 3: Update Step 3 to reference the router**

In the same nightly-synthesis workflow, find:

```markdown
### Step 3: Process each file (ONE AT A TIME)
a. Determine type → apply correct workflow
b. Process (annotate / summarize / extract loops with priority)
c. Write output files
d. Update synthesis-log.json IMMEDIATELY after each file
   (if interrupted, picks up where it left off)
e. Move original to `Inbox/archive/[subfolder]/[filename]` — keep originals immutable, just relocated
```

Replace with:

```markdown
### Step 3: Process each file (ONE AT A TIME)
Each file is processed by a dedicated Haiku subprocess via `run-nightly.sh`. That subprocess:
a. Reads the file once
b. Classifies it: transcript | pdf | note | link | unrouted
c. Applies the matching workflow:
   - transcript → `_system/workflows/meeting-notes.md`
   - pdf → `_system/workflows/pdf-ingestion.md`
   - note → `_system/workflows/note-ingestion.md`
   - link → `_system/workflows/link-ingestion.md`
   - unrouted → appends to `Inbox/_unrouted.md`, sets `Inbox/_index.md` status to `flagged`, stops
d. Updates synthesis-log.json IMMEDIATELY after each file (if interrupted, picks up where it left off)
e. Updates `Inbox/_index.md`: sets Type to classified type, Status to `processed`
f. Moves original to `Inbox/_archive/[filename]`
```

- [ ] **Step 4: Verify**

```bash
grep -n "Inbox/transcripts" "_bootstrap/phases/06-workflows.md"
```

Expected: zero results. All references replaced.

- [ ] **Step 5: Commit**

```bash
git add "_bootstrap/phases/06-workflows.md"
git commit -m "feat: update nightly-synthesis to use Inbox router"
```

---

## Task 6: Add unrouted surfacing to daily-briefing

**Files:**
- Modify: `_bootstrap/phases/06-workflows.md`

- [ ] **Step 1: Find Step 1 in daily-briefing workflow**

```bash
grep -n "Load context\|Step 1\|Step 2" "_bootstrap/phases/06-workflows.md" | head -20
```

Find the block ending Step 1 (Load context) in the daily-briefing section.

- [ ] **Step 2: Insert Step 1.5 after Step 1**

In the daily-briefing workflow, after the Step 1 block:

```markdown
1. **Load context**
   - Read `HEARTBEAT.md` (current focus, upcoming 1on1s)
   - Read `GOALS.md` (30/60/90 objectives)
   - Read `profile/preferences/briefing.md` (briefing preferences and coaching tone)
```

Insert immediately after:

```markdown
1.5 **Unrouted inbox items**
   - Check if `Inbox/_unrouted.md` exists and contains any entries (lines after the header)
   - If yes, add this section to the briefing:
     ```
     ### Inbox needs attention
     These files couldn't be classified automatically:
     - [filename] — [one-line description]
     Rename them or move them to a subfolder to help the router next time.
     ```
   - If the file doesn't exist or has no entries: omit this section entirely — no noise on clean days
```

- [ ] **Step 3: Add the section to the output format**

In the same daily-briefing workflow, find the `## Output format` section. It starts with:

```markdown
# Daily Briefing — [DATE]

### Today's focus
```

Insert this section between `# Daily Briefing — [DATE]` and `### Today's focus`:

```markdown
### Inbox needs attention
[Only shown when _unrouted.md has entries — omit if empty]
```

- [ ] **Step 4: Verify**

```bash
grep -n "unrouted\|Inbox needs" "_bootstrap/phases/06-workflows.md"
```

Expected: Step 1.5 block and output format entry present.

- [ ] **Step 5: Commit**

```bash
git add "_bootstrap/phases/06-workflows.md"
git commit -m "feat: surface unrouted inbox items in daily briefing"
```

---

## Task 7: Update run-nightly.sh template

**Files:**
- Modify: `_bootstrap/phases/08-automation.md`

- [ ] **Step 1: Verify current Pass 1 and Pass 2**

```bash
grep -n "Pass 1\|Pass 2\|transcripts/_index\|meeting-notes" "_bootstrap/phases/08-automation.md"
```

Note the lines for Pass 1 prompt and Pass 2 prompt.

- [ ] **Step 2: Add Step 0 before Pass 1**

In `_bootstrap/phases/08-automation.md`, find the line:

```bash
    # Pass 1 (Haiku): identify unprocessed files → write queue
```

Insert before it:

```bash
    # Step 0: Build Inbox queue (shell — no LLM needed)
    echo "$(date): Step 0 — scanning Inbox for new files..." | tee -a "$LOG"
    [ -f "$VAULT_DIR/Inbox/_index.md" ] || printf "| File | Type | Status | Added |\n|------|------|--------|-------|\n" > "$VAULT_DIR/Inbox/_index.md"
    [ -f "$VAULT_DIR/Inbox/_unrouted.md" ] || printf "# Inbox — Unrouted Files\n\n" > "$VAULT_DIR/Inbox/_unrouted.md"
    find "$VAULT_DIR/Inbox" -maxdepth 1 -type f ! -name '_*' | while IFS= read -r FILE; do
      grep -qF "$FILE" "$VAULT_DIR/Inbox/_index.md" || \
        printf "| %s | unknown | pending | %s |\n" "$FILE" "$TODAY" >> "$VAULT_DIR/Inbox/_index.md"
    done

```

- [ ] **Step 3: Update Pass 1 prompt**

Find:

```bash
    claude --model claude-haiku-4-5-20251001 --print \
      "Read _system/data/synthesis-log.json and Inbox/transcripts/_index.md.
Output one file path per line for each file not yet in synthesis-log. No other text." \
      > "$QUEUE" 2>> "$LOG"
```

Replace with:

```bash
    claude --model claude-haiku-4-5-20251001 --print \
      "Read _system/data/synthesis-log.json and Inbox/_index.md.
Output one file path per line for each file where Status=pending and not already in synthesis-log. No other text." \
      > "$QUEUE" 2>> "$LOG"
```

- [ ] **Step 4: Update Pass 2 prompt**

Find:

```bash
      claude --model claude-haiku-4-5-20251001 --print \
        "Follow _system/workflows/meeting-notes.md for this single file only: $FILE
Process it, write all outputs, update synthesis-log, archive the original. Stop." \
        2>&1 >> "$LOG"
```

Replace with:

```bash
      claude --model claude-haiku-4-5-20251001 --print \
        "Classify this file, then process it using the matching workflow:
- transcript → _system/workflows/meeting-notes.md
- pdf → _system/workflows/pdf-ingestion.md
- note → _system/workflows/note-ingestion.md
- link → _system/workflows/link-ingestion.md
- unrouted → append filename + one-line description to Inbox/_unrouted.md, update Inbox/_index.md status to flagged, stop.

If the file is already in synthesis-log (hash match), skip immediately.
After processing: update Inbox/_index.md — set Type to the classified type and Status to processed.

File: $FILE" \
        2>&1 >> "$LOG"
```

- [ ] **Step 5: Verify**

```bash
grep -n "Inbox/transcripts\|meeting-notes.md" "_bootstrap/phases/08-automation.md"
```

Expected: zero results. Old hardcoded references replaced.

```bash
grep -n "Step 0\|_index.md\|router\|classify" "_bootstrap/phases/08-automation.md"
```

Expected: Step 0 block and router prompt present.

- [ ] **Step 6: Commit**

```bash
git add "_bootstrap/phases/08-automation.md"
git commit -m "feat: add Step 0 queue-building and router to run-nightly.sh"
```

---

## Task 8: Update README

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Update the architecture diagram**

In `README.md`, find the `Inbox/` section of the architecture tree:

```
├── Inbox/                 ← Drop zone: transcripts, PDFs, URLs; archive/ holds processed originals
```

Replace with:

```
├── Inbox/                 ← Drop zone: transcripts, PDFs, markdown notes, link files
│   ├── _index.md          ← Nightly-maintained queue: file, type, status, date added
│   ├── _unrouted.md       ← Files the router couldn't classify (surfaced in daily briefing)
│   └── _archive/          ← Processed originals (system-managed)
```

- [ ] **Step 2: Update the transcript tools table**

Find the "Supported transcript tools" section:

```markdown
### Supported transcript tools

| Tool | Setup |
|------|-------|
| [Granola](https://granola.ai) | Configure export folder to `Inbox/transcripts/` |
| [Fireflies.ai](https://fireflies.ai) | Webhook or Zapier → save to `Inbox/transcripts/` |
| [Zoom AI Companion](https://zoom.us) | Zoom MCP or manual export from zoom.us/recording |
| [Otter.ai](https://otter.ai) | Download transcript as .txt → `Inbox/transcripts/` |
| [Fathom](https://fathom.video) | Auto-email summary → script to `Inbox/transcripts/` |

`setup.sh` will prompt you to choose and configure your tool.
```

Replace with:

```markdown
### What Inbox accepts

Drop any of these directly into `Inbox/` — no subfolders needed:

| Type | Examples |
|------|---------|
| Transcripts | Granola exports, Fireflies summaries, Zoom/Otter/Fathom .txt or .md files |
| PDFs | Documents, articles, reports |
| Markdown notes | Reference material, articles you've copied, scratch notes |
| Link files | A `.md` file with one or more URLs — the nightly job fetches and annotates each one |

The nightly router reads each file once, classifies it, and applies the right workflow. Anything it can't classify lands in `Inbox/_unrouted.md` and is surfaced in your morning briefing.

### Transcript tool setup

| Tool | Setup |
|------|-------|
| [Granola](https://granola.ai) | Configure export folder to `Inbox/` |
| [Fireflies.ai](https://fireflies.ai) | Webhook or Zapier → save to `Inbox/` |
| [Zoom AI Companion](https://zoom.us) | Zoom MCP or manual export from zoom.us/recording → `Inbox/` |
| [Otter.ai](https://otter.ai) | Download transcript as .txt → `Inbox/` |
| [Fathom](https://fathom.video) | Auto-email summary → script to `Inbox/` |

`setup.sh` will prompt you to choose and configure your tool.
```

- [ ] **Step 3: Add Day 1 step and vault import to Quickstart**

Find the Quickstart section. After:

```markdown
**Before your first real session:**
- Fill in your name, company, start date
- Add your team roster to `People/team.md`
- Set your 30/60/90 goals in `GOALS.md`
- Define your strategic pillars in `PILLARS.md`
- Create your first 1on1 folders with `/personal-os-new-1on1 [name]`
```

Add:

```markdown
**Day 1 — seed your system:**
Drop any existing notes, transcripts, or PDFs into `Inbox/`. The next nightly run (2am) processes everything automatically — no pre-sorting required.

**Importing an existing vault?**
Drop its contents directly into `Inbox/`. The router classifies and files everything. Check `Inbox/_unrouted.md` the next morning for anything it couldn't place.
```

- [ ] **Step 4: Verify**

```bash
grep -n "Inbox/transcripts\|Inbox/pdfs" README.md
```

Expected: zero results.

```bash
grep -n "_unrouted\|_index\|_archive\|drop zone\|Drop zone" README.md
```

Expected: at least 3 hits.

- [ ] **Step 5: Commit**

```bash
git add README.md
git commit -m "docs: update README for flat Inbox drop zone and vault import"
```

---

## Task 9: Update setup.sh transcript tool paths

**Files:**
- Modify: `setup.sh`

- [ ] **Step 1: Check for old inbox subfolder references**

```bash
grep -n "Inbox/transcripts\|Inbox/pdfs\|Inbox/links\|Inbox/scratch" setup.sh
```

If zero results: this task is complete, skip to commit.

- [ ] **Step 2: Replace all references**

For any line referencing `Inbox/transcripts/`, `Inbox/pdfs/`, `Inbox/links/`, or `Inbox/scratch/`, replace the path with `Inbox/`. Use the exact lines found in Step 1 — do not change anything else on those lines.

- [ ] **Step 3: Verify**

```bash
grep -n "Inbox/transcripts\|Inbox/pdfs\|Inbox/links\|Inbox/scratch" setup.sh
```

Expected: zero results.

- [ ] **Step 4: Commit**

```bash
git add setup.sh
git commit -m "feat: update setup.sh transcript paths to flat Inbox/"
```

---

## Self-review

**Spec coverage check:**

| Spec requirement | Task |
|-----------------|------|
| Flat Inbox drop zone | Task 1 |
| `Inbox/_index.md` schema | Task 2 |
| `_` prefix for system files (`_archive/`, `_unrouted.md`, `_index.md`) | Tasks 1, 2 |
| Type taxonomy (transcript, pdf, note, link, unrouted) | Tasks 3, 4, 5 |
| Shell Step 0 queue-building | Task 7 |
| Pass 1: reads `Inbox/_index.md` | Task 7 |
| Pass 2: router prompt, one read per file | Task 7 |
| note-ingestion workflow | Task 3 |
| link-ingestion workflow (sequential URL fetch) | Task 4 |
| Daily briefing Step 1.5 unrouted surfacing | Task 6 |
| README: drop zone docs, quickstart Day 1, vault import | Task 8 |
| setup.sh paths updated | Task 9 |
| Type + Status both updated in `_index.md` by Pass 2 | Tasks 5, 7 |

All spec requirements covered. ✓

# Inbox Processing Design
_Date: 2026-05-02_

## Problem

The current inbox is split into typed subfolders (`Inbox/transcripts/`, `Inbox/pdfs/`) that the user must pre-sort into before nightly synthesis picks them up. This creates friction for daily capture and makes vault import impossible without manual reorganization. There is also no maintained index of what's in the inbox, so the nightly job can't efficiently find new work.

## Goals

- Drop zone: user drops anything text-based, PDF, or link-containing into `Inbox/` flat — no pre-sorting required
- Vault import: dumping an existing vault's contents into `Inbox/` works out of the box
- Token efficiency: each file is read exactly once — classification and processing happen in the same pass
- Unrouted visibility: files the router can't classify are surfaced in the daily briefing, never silently dropped
- System file conventions: all nightly-managed files in `Inbox/` use the `_` prefix

## Out of scope

- Binary file types (images, audio, video)
- Real-time processing (files are still processed nightly, not on drop)

---

## Design

### Inbox structure

```
Inbox/
├── _index.md       ← nightly-maintained queue (append-only)
├── _unrouted.md    ← files that couldn't be classified
├── _archive/       ← processed originals, flat
└── [anything]      ← user drops content here
```

`_` prefix rule: any file or folder owned and managed by the nightly job uses the `_` prefix. User-dropped content has no prefix.

### `Inbox/_index.md` schema

Append-only. Nightly marks rows processed; never deletes them.

```markdown
| File | Type | Status | Added |
|------|------|--------|-------|
| Inbox/2026-04-28-standup.md | transcript | processed | 2026-04-28 |
| Inbox/some-doc.pdf | pdf | pending | 2026-04-29 |
| Inbox/old-note.md | unrouted | flagged | 2026-04-29 |
```

### Content type taxonomy

| Type | What it is | Workflow |
|------|-----------|----------|
| `transcript` | Meeting/conversation notes with speakers, action items | `_system/workflows/meeting-notes.md` |
| `pdf` | PDF documents | `_system/workflows/pdf-ingestion.md` |
| `note` | Generic markdown — articles, thoughts, reference material | `_system/workflows/note-ingestion.md` |
| `link` | Markdown containing URLs to external content | `_system/workflows/link-ingestion.md` |
| `unrouted` | Can't confidently classify | → `Inbox/_unrouted.md` |

---

## Nightly synthesis changes

### Step 0: Shell queue-building (new)

Added to `run-nightly.sh` before Pass 1:

```bash
# Step 0: Build Inbox queue
find "$VAULT_DIR/Inbox" -maxdepth 1 -type f \
  ! -name '_*' \
  | while IFS= read -r FILE; do
      grep -qF "$FILE" "$VAULT_DIR/Inbox/_index.md" || \
        echo "| $FILE | unknown | pending | $TODAY |" >> "$VAULT_DIR/Inbox/_index.md"
    done
```

`! -name '_*'` excludes system files from the queue. This is the only directory scan in the system, and it runs once at the top of each nightly run.

### Pass 1 prompt changes

Each per-file Haiku subprocess opens with classification before processing:

```
Classify this file, then process it using the matching workflow:
- transcript → _system/workflows/meeting-notes.md
- pdf → _system/workflows/pdf-ingestion.md
- note → _system/workflows/note-ingestion.md
- link → _system/workflows/link-ingestion.md
- unrouted → append filename + one-line description to Inbox/_unrouted.md,
             update Inbox/_index.md status to "flagged", stop.

If the file is already in synthesis-log (hash match), skip immediately.

File: [FILE]
```

One read, one classification decision, one workflow. After processing, the workflow updates both the Type column (from `unknown` to the classified type) and the Status column in `Inbox/_index.md`. Passes 2 and 3 (Sonnet connections + patterns) are unchanged.

---

## New workflow files

### `_system/workflows/note-ingestion.md`

Model: `claude-haiku-4-5-20251001` — structured extraction, no reasoning needed.

1. Check synthesis-log — skip if already processed
2. Annotate using `_system/templates/source-annotation.md` (metadata, summary, key concepts, inferences, open questions, wiki connections)
3. File to `Knowledge/sources/[slug].md`
4. Queue wiki connections for Pass 2
5. Update synthesis-log
6. Move original to `Inbox/_archive/[filename]`
7. Update `Inbox/_index.md` status to `processed`

### `_system/workflows/link-ingestion.md`

Model: `claude-haiku-4-5-20251001`. All URLs in a single file are fetched sequentially within one subprocess.

1. Check synthesis-log — skip if already processed
2. Extract all URLs from the file
3. For each URL: fetch content, extract title + body
4. Annotate each fetched page using `_system/templates/source-annotation.md`
5. File each to `Knowledge/sources/[slug].md` (slug = domain + title)
6. If source file contained notes alongside the URLs, include them in the annotation's inferences field
7. Update synthesis-log
8. Move original to `Inbox/_archive/[filename]`
9. Update `Inbox/_index.md` status to `processed`

---

## Daily briefing changes

New step 1.5 in `_system/workflows/daily-briefing.md`, inserted after Step 1 (Load context):

```
1.5 Unrouted inbox items
- Check if Inbox/_unrouted.md exists and has any entries
- If yes, add this section to the briefing:

  ### Inbox needs attention
  These files couldn't be classified automatically:
  - [filename] — [one-line description]

  Drop them in the right place or rename to help the router.

- If empty or missing: omit entirely
```

---

## README changes

1. **Inbox section**: replace transcript-tool table framing with drop zone framing. Document accepted types (transcripts, PDFs, markdown notes, link files) and what happens to each.

2. **Quickstart**: add explicit Day 1 step after bootstrap — *"Drop any existing notes, transcripts, or PDFs into `Inbox/`. The next nightly run processes everything."*

3. **Vault import paragraph**: *"Have an existing vault? Drop its contents into `Inbox/`. The router classifies and files everything. Check `Inbox/_unrouted.md` the next morning for anything it couldn't place."*

---

## Files to create

- `_system/workflows/note-ingestion.md`
- `_system/workflows/link-ingestion.md`

## Files to modify

- `run-nightly.sh` — add Step 0 shell queue-building
- `_system/workflows/nightly-synthesis.md` — update Pass 1 prompt to include router
- `_system/workflows/daily-briefing.md` — add Step 1.5 unrouted surfacing
- `README.md` — inbox section, quickstart Day 1 step, vault import paragraph
- `_bootstrap/phases/06-workflows.md` — add note-ingestion and link-ingestion workflow definitions
- `_bootstrap/phases/08-automation.md` — add Step 0 to run-nightly.sh template

## Files to remove

- `Inbox/transcripts/` subfolder reference (flatten to `Inbox/`)
- `Inbox/pdfs/` subfolder reference (flatten to `Inbox/`)

# Phase 4: Data Models
_Depends on: Phase 1 (directories must exist)_

### `_system/data/open-loops.json`

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
  "canonical_id": "string | null — null for canonical entries; loop ID of parent for merged duplicates",
  "owner": "string — who owns resolution",
  "context_person": "string | null",
  "context_meeting": "string | null",
  "project": "string | null",
  "pillar": "string | null — matches a pillar name from PILLARS.md; auto-tagged by nightly synthesis",
  "requires_focus": "boolean — true if resolving this loop requires uninterrupted deep work (no external dependency)",
  "priority": "critical | high | medium | low",
  "status": "open | in-progress | blocked | archived | merged",
  "opened_date": "YYYY-MM-DD",
  "due_date": "YYYY-MM-DD | null",
  "closed_date": "YYYY-MM-DD | null",
  "closed_in": "string | null — path of the file that triggered the close",
  "notes": "string — append-only updates separated by | date |",
  "source_files": ["path to originating note"]
}
```

### `_system/data/decisions.json`

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

### `_system/data/career-evidence.json`

```json
{
  "schema_version": 1,
  "evidence": []
}
```

Schema for each evidence entry:
```json
{
  "id": "ev-001",
  "type": "feedback | outcome | growth",
  "date": "YYYY-MM-DD",
  "title": "string — one-line portable summary, resume-ready",
  "detail": "string — what happened, verbatim or paraphrased from source",
  "from": "string | null — person who gave feedback or can attest to the outcome",
  "context": "string — meeting title or 1on1 name it came from",
  "source_file": "path to originating note",
  "tags": ["string — skill area, project, or theme"],
  "starred": false
}
```

Types:
- `feedback` — explicit praise or positive signal, must be attributable to a person
- `outcome` — shipped something, resolved a situation, delivered a concrete result
- `growth` — handled something differently than before, changed approach, acted on coaching received

---

### `_system/data/synthesis-log.json`

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
  "career_evidence_created": ["ev-IDs created from this file"],
  "annotation_version": 1
}
```

**Preference tuning schedule logic** (nightly synthesis checks this):
- Days 0–7 from start_date: schedule = "daily"
- Days 8–14: schedule = "every-3-days"
- Days 15–21: schedule = "every-5-days"
- Day 22+: schedule = "weekly"

---

### Directory indexes (`_index.md`)

Each key directory maintains a `_index.md` that workflows read **instead of scanning the directory**.
Nightly synthesis updates these after processing each file (see Step 7).

**`1on1s/_index.md`** — one row per person:
```markdown
| Name | Last session | Sessions | Open loops | Last contact | Folder |
|------|-------------|----------|------------|--------------|--------|
| Alice | 2026-04-28 | 14 | 3 | 2026-04-28 | 1on1s/Alice/ |
```

**`1on1s/[Name]/sessions/_index.md`** — one row per session:
```markdown
| Date | Key topic | Summary | Processed |
|------|-----------|---------|-----------|
| 2026-04-28 | Q2 roadmap | sessions/2026-04-28-summary.md | yes |
```

**`Knowledge/wiki/_index.md`** — one row per wiki page:
```markdown
| Page | Concepts | Sources | Last updated |
|------|----------|---------|--------------|
| product-strategy.md | roadmap, prioritization | 8 | 2026-04-28 |
```

**`Meetings/_index.md`** — one row per meeting:
```markdown
| Date | Title | Type | Participants | Action items | Processed |
|------|-------|------|--------------|--------------|-----------|
| 2026-04-28 | All-Hands | team | 12 | 2 | yes |
```

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

The nightly shell step adds new files with Type `unknown` and Status `pending`. Pass 1 updates both Type and Status after processing.

Create empty `_index.md` files in: `1on1s/`, `Meetings/`, `Knowledge/wiki/`, `Interviews/`.
`Inbox/_index.md` and `Inbox/_unrouted.md` are created in Phase 1 with their initial content.

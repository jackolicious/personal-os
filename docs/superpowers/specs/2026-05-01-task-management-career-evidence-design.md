# Design: Task Management, Commitments & Career Evidence
**Date:** 2026-05-01
**Status:** Approved

---

## Overview

Three related features that extend the existing Personal OS:

1. **Task deduplication** — open-loops.json becomes a true canonical task store with multi-source provenance; duplicates extracted from different sources merge into one record
2. **Commitment load coaching** — daily briefing surfaces a soft nudge when high/critical loop counts breach thresholds, encouraging reprioritization
3. **Career evidence** — nightly synthesis silently extracts feedback, outcomes, and growth moments into a new store; surfaced on demand via `/personal-os-career-evidence`

---

## 1. Schema Changes — `open-loops.json`

Two fields change, one is added. All other fields unchanged.

### `source_file` → `source_files` (array)
Every note where this task appeared. Previously a single string.

### `canonical_id` (string | null) — new
If this loop is a detected duplicate, points to the authoritative loop ID. Canonical entries have `canonical_id: null`. All workflows resolve through canonical_id before operating.

### `closed_in` (string | null) — new
Path of the file that triggered the close. Audit trail.

**Canonical entry example:**
```json
{
  "id": "loop-042",
  "title": "Send Alice the updated roadmap doc",
  "canonical_id": null,
  "source_files": [
    "Meetings/2026-04-28-all-hands.md",
    "1on1s/Alice/sessions/2026-04-30.md"
  ],
  "closed_in": null,
  "owner": "Jack",
  "context_person": "Alice",
  "context_meeting": "All-Hands",
  "project": "Q2 Roadmap",
  "priority": "high",
  "status": "open",
  "opened_date": "2026-04-28",
  "due_date": "2026-05-02",
  "closed_date": null,
  "notes": ""
}
```

**Merged duplicate entry:**
```json
{
  "id": "loop-051",
  "canonical_id": "loop-042",
  "status": "merged",
  ...
}
```

Workflows skip any loop where `status: "merged"`.

---

## 2. Deduplication Logic

Runs in nightly synthesis after each file's tasks are extracted, before writing to open-loops.json.

**Match criteria (all must pass):**
- Semantic similarity on `title` — same action, different wording counts as a match
- `context_person` matches or is null on one side
- `project` matches or is null on one side
- Target loop `status` is open or in-progress (not archived/merged)

**On match:**
- Append new source_file to canonical loop's source_files array
- If new extraction has earlier due_date, update canonical's due_date
- Create a merged entry pointing to canonical (audit trail)
- Do not create a visible duplicate

**On no match:**
- Create new canonical loop, canonical_id: null

**Two-phase similarity:**
Haiku extraction pass outputs a `match_candidate_id` when it finds a likely existing loop. Sonnet reasoning pass confirms or rejects. Avoids false positives from Haiku's shallower matching.

**Closing propagation:**
When a source file marks a task complete (language: "done," "completed," "sent," "resolved"):
1. Resolve to canonical loop (via canonical_id if needed)
2. Set status: "archived", closed_date: today, closed_in: source_file_path
3. All generated views reflect this on next run

---

## 3. Career Evidence Data Model

New file: `_system/data/career-evidence.json`

```json
{
  "schema_version": 1,
  "evidence": []
}
```

**Entry schema:**
```json
{
  "id": "ev-001",
  "type": "feedback | outcome | growth",
  "date": "YYYY-MM-DD",
  "title": "One-line summary — portable, resume-ready",
  "detail": "What happened, verbatim or paraphrased",
  "from": "string | null",
  "context": "string — meeting or 1on1 it came from",
  "source_file": "path",
  "tags": ["skill area, project, theme"],
  "starred": false
}
```

**Types:**
- `feedback` — explicit praise or positive signal, attributable to a person
- `outcome` — shipped something, resolved a situation, delivered a concrete result
- `growth` — handled something differently, changed approach, acted on coaching received

**Extraction signal (Haiku pass, per 1on1 summary and meeting summary):**
- feedback: direct praise, compliments — must have a person attached
- outcome: concrete deliverable or resolution — must be specific
- growth: "handled this differently," "used to... now I...," coaching that was acted on

Low-confidence signals are skipped. No speculative evidence.

**`starred` field:**
Set via `/personal-os-career-evidence` command. Starred entries surface first in any digest and are included in brag doc generation.

---

## 4. Workflow Changes

### Nightly synthesis — two additions

After Step 5 (open loop maintenance):
- Run dedup pass against tonight's newly extracted loops before writing to open-loops.json
- Run career evidence extraction on each 1on1 summary and meeting summary processed tonight; append to career-evidence.json; log count in synthesis-log.json as `career_evidence_created`

### Daily briefing — one addition

After open loops triage, add coaching nudge if thresholds breached:

```
### Commitment load
You have 6 high-priority open loops and 3 critical.
Consider: what can be reprioritized, delegated, or dropped before adding more?
[Top 3 longest-open high/critical loops as candidates]
```

**Thresholds** (tunable in `profile/preferences/briefing.md`):
- Warn if critical open loops ≥ 3
- Warn if high + critical ≥ 8
- Section omitted entirely on healthy days

### 1on1 ready notes

"Recent Action Items" table resolves through canonical_id before rendering. A task appearing in both a meeting and a 1on1 shows once, with `(+1 source)` annotation.

### `Meetings/action-items.md` — regenerated view

Rebuilt by nightly synthesis after dedup pass. Sections: Overdue → Due this week → High priority. Only canonical loops. Sources column shows human-readable labels (meeting title or person name), not raw paths.

---

## 5. `/personal-os-career-evidence` Command

**Model:** `claude-sonnet-4-6`
**Trigger:** `/personal-os-career-evidence [last 90d | last 6mo | all]`
Default: last 90 days

**Steps:**
1. Read career-evidence.json, filter by date range
2. Group by type: feedback → outcomes → growth
3. Within each group: starred first, then date descending
4. Render digest
5. Offer: star entries or generate brag doc

**Digest format:**
```
## Feedback received
- [DATE] [FROM]: "[detail]" — [context]

## Outcomes delivered
- [DATE]: [title] — [detail]

## Growth moments
- [DATE]: [title] — [detail]
```

**Brag doc** (optional, on request):
- Sonnet synthesizes starred + highest-signal entries into 3–5 paragraphs
- First person, in Jack's voice (reads profile/preferences/writing-style.md)
- Saved to `profile/career/YYYY-MM-DD-brag-doc.md`

---

## Files to Create or Modify

### New files
- `_system/data/career-evidence.json` — new data store
- `_system/workflows/career-evidence.md` — new workflow
- `_system/templates/career-evidence-digest.md` — output template
- `profile/career/` — directory for brag docs

### Modified files
- `_bootstrap/phases/04-data.md` — add career-evidence.json schema; update open-loops.json schema
- `_bootstrap/phases/05-templates.md` — add career-evidence-digest template
- `_bootstrap/phases/06-workflows.md` — update nightly-synthesis, daily-briefing, 1on1-prep; add career-evidence workflow
- `_bootstrap/phases/07-commands.md` — add /personal-os-career-evidence command
- `_bootstrap/phases/08-automation.md` — update synthesis-log.json to include career_evidence_created
- `_bootstrap/phases/01-scaffold.md` — add profile/career/ directory

# Task Management, Commitments & Career Evidence — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Upgrade open-loops.json to a deduplicated canonical task store, add commitment load coaching to the daily briefing, and silently capture career evidence during nightly synthesis with on-demand retrieval.

**Architecture:** All changes are to `_bootstrap/phases/` markdown template files — the specification that gets instantiated into a live Personal OS vault. No runnable code changes. Each task edits one or two phase files and commits.

**Tech Stack:** Markdown template editing. Verification via `grep` and file reads. Git commits after each task.

---

## File Map

| File | Change |
|------|--------|
| `_bootstrap/phases/01-scaffold.md` | Add `profile/career/` directory |
| `_bootstrap/phases/04-data.md` | Update open-loops.json schema; add career-evidence.json; update synthesis-log schema |
| `_bootstrap/phases/05-templates.md` | Add commitment load thresholds to briefing.md; add career-evidence-digest template |
| `_bootstrap/phases/06-workflows.md` | Update nightly-synthesis (dedup + career evidence); update daily-briefing (commitment load nudge); update ready note rebuild; add career-evidence workflow |
| `_bootstrap/phases/07-commands.md` | Add `/personal-os-career-evidence` command |

---

## Task 1: Add `profile/career/` to directory scaffold

**Files:**
- Modify: `_bootstrap/phases/01-scaffold.md`

- [ ] **Step 1: Verify current scaffold ends with `.claude/commands/`**

```bash
grep -n "profile/" "/Users/jackhirsch/Library/CloudStorage/GoogleDrive-jack.hirsch@gmail.com/My Drive/Personal OS/_bootstrap/phases/01-scaffold.md"
```

Expected: shows `profile/` and `profile/preferences/` but no `profile/career/`

- [ ] **Step 2: Add `profile/career/` after `profile/preferences/`**

In `_bootstrap/phases/01-scaffold.md`, find:
```
profile/
profile/preferences/
```
Replace with:
```
profile/
profile/preferences/
profile/career/
```

- [ ] **Step 3: Verify**

```bash
grep "profile/career" "/Users/jackhirsch/Library/CloudStorage/GoogleDrive-jack.hirsch@gmail.com/My Drive/Personal OS/_bootstrap/phases/01-scaffold.md"
```

Expected: `profile/career/`

- [ ] **Step 4: Commit**

```bash
git add "_bootstrap/phases/01-scaffold.md"
git commit -m "feat: add profile/career/ directory to scaffold"
```

---

## Task 2: Update open-loops.json schema

**Files:**
- Modify: `_bootstrap/phases/04-data.md`

- [ ] **Step 1: Verify current schema fields**

```bash
grep -n "source_file\|status\|closed" "/Users/jackhirsch/Library/CloudStorage/GoogleDrive-jack.hirsch@gmail.com/My Drive/Personal OS/_bootstrap/phases/04-data.md"
```

Expected: shows `"source_file": "path to originating note"` and `"status": "open | in-progress | blocked | archived"`

- [ ] **Step 2: Replace the open-loops.json entry schema**

In `_bootstrap/phases/04-data.md`, find this block:
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

Replace with:
```json
{
  "id": "loop-001",
  "title": "string — the commitment or open question",
  "canonical_id": "string | null — null for canonical entries; loop ID of parent for merged duplicates",
  "owner": "string — who owns resolution",
  "context_person": "string | null",
  "context_meeting": "string | null",
  "project": "string | null",
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

- [ ] **Step 3: Verify**

```bash
grep -n "source_files\|canonical_id\|closed_in\|merged" "/Users/jackhirsch/Library/CloudStorage/GoogleDrive-jack.hirsch@gmail.com/My Drive/Personal OS/_bootstrap/phases/04-data.md"
```

Expected: all four strings appear; `source_file` (singular) no longer appears in the schema block.

- [ ] **Step 4: Commit**

```bash
git add "_bootstrap/phases/04-data.md"
git commit -m "feat: extend open-loops schema with multi-source tracking and dedup fields"
```

---

## Task 3: Add career-evidence.json schema and update synthesis-log

**Files:**
- Modify: `_bootstrap/phases/04-data.md`

- [ ] **Step 1: Add career-evidence.json after the decisions.json section**

In `_bootstrap/phases/04-data.md`, find:
```
### `_system/data/synthesis-log.json`
```

Insert before that line:
```markdown
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

```

- [ ] **Step 2: Add `career_evidence_created` to synthesis-log processed_files schema**

In `_bootstrap/phases/04-data.md`, find the processed_files entry schema:
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

Replace with:
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

- [ ] **Step 3: Verify**

```bash
grep -n "career-evidence\|career_evidence\|ev-001" "/Users/jackhirsch/Library/CloudStorage/GoogleDrive-jack.hirsch@gmail.com/My Drive/Personal OS/_bootstrap/phases/04-data.md"
```

Expected: at least 3 matches — the filename, the ID example, and the synthesis-log field.

- [ ] **Step 4: Commit**

```bash
git add "_bootstrap/phases/04-data.md"
git commit -m "feat: add career-evidence.json schema and synthesis-log tracking field"
```

---

## Task 4: Update briefing preferences template and add career-evidence-digest template

**Files:**
- Modify: `_bootstrap/phases/05-templates.md`

- [ ] **Step 1: Add commitment load thresholds to the briefing.md preference template**

In `_bootstrap/phases/05-templates.md`, find the end of the `profile/preferences/briefing.md` template block:
```markdown
## What to always include
- Anyone not contacted in >14 days (direct reports) or >21 days (stakeholders)
- Any loop open >14 days without a status update
- Cross-cutting themes from recent 1on1s
```

Replace with:
```markdown
## What to always include
- Anyone not contacted in >14 days (direct reports) or >21 days (stakeholders)
- Any loop open >14 days without a status update
- Cross-cutting themes from recent 1on1s

## Commitment load thresholds
Warn if critical open loops ≥ 3
Warn if high + critical open loops ≥ 8
(Adjust to match your actual load capacity)
```

- [ ] **Step 2: Add career-evidence-digest template at the end of Phase 5**

Append to `_bootstrap/phases/05-templates.md` (after the last template block, before any end of file):

```markdown
### `_system/templates/career-evidence-digest.md`

```markdown
# Career Evidence — [DATE_RANGE]
_Generated: {{DATE}}_

## Feedback received
<!-- Sorted: starred first, then date descending -->
| Date | From | What they said | Context |
|------|------|----------------|---------|
| | | | |

## Outcomes delivered
| Date | What | Detail |
|------|------|--------|
| | | |

## Growth moments
| Date | What | Detail |
|------|------|--------|
| | | |

---
_To star entries for your portfolio: "star ev-001, ev-002"_
_To generate a brag doc: "brag doc"_
```
```

- [ ] **Step 3: Verify**

```bash
grep -n "Commitment load\|career-evidence-digest\|brag doc" "/Users/jackhirsch/Library/CloudStorage/GoogleDrive-jack.hirsch@gmail.com/My Drive/Personal OS/_bootstrap/phases/05-templates.md"
```

Expected: all three strings present.

- [ ] **Step 4: Commit**

```bash
git add "_bootstrap/phases/05-templates.md"
git commit -m "feat: add commitment load thresholds to briefing prefs; add career-evidence-digest template"
```

---

## Task 5: Add dedup pass and career evidence extraction to nightly synthesis

**Files:**
- Modify: `_bootstrap/phases/06-workflows.md` (nightly-synthesis.md section)

- [ ] **Step 1: Locate Step 5 in the nightly synthesis workflow**

```bash
grep -n "Step 5\|Step 6\|Open loop maintenance" "/Users/jackhirsch/Library/CloudStorage/GoogleDrive-jack.hirsch@gmail.com/My Drive/Personal OS/_bootstrap/phases/06-workflows.md"
```

Expected: shows line numbers for Step 5 and Step 6.

- [ ] **Step 2: Add Steps 5.1 and 5.2 after Step 5**

In `_bootstrap/phases/06-workflows.md`, find:
```markdown
### Step 5: Open loop maintenance
- Scan tonight's summaries for new commitments → append to open-loops.json with priority
- Flag loops where due_date < today and status = open or in-progress
- Flag loops where status = open and opened_date > 14 days ago (no update)

### Step 6: Pattern detection (coaching function)
```

Replace with:
```markdown
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
```

- [ ] **Step 3: Verify**

```bash
grep -n "Step 5.1\|Step 5.2\|Deduplication\|Career evidence extraction" "/Users/jackhirsch/Library/CloudStorage/GoogleDrive-jack.hirsch@gmail.com/My Drive/Personal OS/_bootstrap/phases/06-workflows.md"
```

Expected: all four strings present.

- [ ] **Step 4: Commit**

```bash
git add "_bootstrap/phases/06-workflows.md"
git commit -m "feat: add dedup pass and career evidence extraction to nightly synthesis"
```

---

## Task 6: Update daily briefing — add commitment load coaching nudge

**Files:**
- Modify: `_bootstrap/phases/06-workflows.md` (daily-briefing.md section)

- [ ] **Step 1: Locate Step 2 and Step 3 in daily briefing**

```bash
grep -n "Open loops triage\|Meeting awareness\|Relationship health" "/Users/jackhirsch/Library/CloudStorage/GoogleDrive-jack.hirsch@gmail.com/My Drive/Personal OS/_bootstrap/phases/06-workflows.md"
```

Expected: shows line numbers for Step 2 and Step 3 of daily-briefing.

- [ ] **Step 2: Add Step 2.5 after the open loops triage step**

In `_bootstrap/phases/06-workflows.md`, in the daily-briefing.md section, find:
```markdown
2. **Open loops triage**
   - Read `_system/data/open-loops.json`
   - Categorize: overdue → due this week → high priority → everything else
   - Flag any loop open >14 days without a status update
   - For critical/overdue loops: draft a one-line suggested action

3. **Meeting awareness**
```

Replace with:
```markdown
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

3. **Meeting awareness**
```

- [ ] **Step 3: Verify**

```bash
grep -n "Commitment load\|canonical_id = null\|threshold" "/Users/jackhirsch/Library/CloudStorage/GoogleDrive-jack.hirsch@gmail.com/My Drive/Personal OS/_bootstrap/phases/06-workflows.md"
```

Expected: all three strings present in the workflows file.

- [ ] **Step 4: Commit**

```bash
git add "_bootstrap/phases/06-workflows.md"
git commit -m "feat: add commitment load coaching nudge to daily briefing"
```

---

## Task 7: Update ready note rebuild — canonical_id resolution in action items

**Files:**
- Modify: `_bootstrap/phases/06-workflows.md` (nightly-synthesis.md Step 8.5 section)

- [ ] **Step 1: Locate Step 8.5 in nightly synthesis**

```bash
grep -n "Step 8.5\|Rebuild ready notes\|Recent action items" "/Users/jackhirsch/Library/CloudStorage/GoogleDrive-jack.hirsch@gmail.com/My Drive/Personal OS/_bootstrap/phases/06-workflows.md"
```

Expected: shows Step 8.5 with the ready note rebuild steps.

- [ ] **Step 2: Update the action items instruction in Step 8.5**

In `_bootstrap/phases/06-workflows.md`, in Step 8.5, find:
```markdown
3. Rebuild ready-note.md using `_system/templates/1on1-ready-note.md`:
   - Priority open loops: top 3–5 where context_person = Name, sorted overdue → critical → high
   - Last session highlights: 2–3 bullets from the most recent summary
   - Session history: last 5 sessions (date + key topic + one-liner from summary)
   - Recent action items: open items from last 2 sessions
```

Replace with:
```markdown
3. Rebuild ready-note.md using `_system/templates/1on1-ready-note.md`:
   - Priority open loops: top 3–5 where context_person = Name, sorted overdue → critical → high; skip any loop where status = merged
   - Last session highlights: 2–3 bullets from the most recent summary
   - Session history: last 5 sessions (date + key topic + one-liner from summary)
   - Recent action items: open items from last 2 sessions — resolve through canonical_id before rendering (if a loop has multiple source_files, show once with "(+N sources)" annotation)
```

- [ ] **Step 3: Verify**

```bash
grep -n "resolve through canonical_id\|+N sources" "/Users/jackhirsch/Library/CloudStorage/GoogleDrive-jack.hirsch@gmail.com/My Drive/Personal OS/_bootstrap/phases/06-workflows.md"
```

Expected: both strings present.

- [ ] **Step 4: Commit**

```bash
git add "_bootstrap/phases/06-workflows.md"
git commit -m "feat: resolve canonical_id in ready note action items to prevent duplicates"
```

---

## Task 8: Add career-evidence workflow

**Files:**
- Modify: `_bootstrap/phases/06-workflows.md`

- [ ] **Step 1: Find the end of the last workflow section in Phase 6**

```bash
grep -n "### \`_system/workflows/" "/Users/jackhirsch/Library/CloudStorage/GoogleDrive-jack.hirsch@gmail.com/My Drive/Personal OS/_bootstrap/phases/06-workflows.md"
```

Expected: list of all workflow section headers. The new workflow goes after the last one.

- [ ] **Step 2: Append the career-evidence workflow to Phase 6**

At the end of `_bootstrap/phases/06-workflows.md`, append:

````markdown

### `_system/workflows/career-evidence.md`

```markdown
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
```
````

- [ ] **Step 3: Verify**

```bash
grep -n "career-evidence.md\|brag doc\|starred entries" "/Users/jackhirsch/Library/CloudStorage/GoogleDrive-jack.hirsch@gmail.com/My Drive/Personal OS/_bootstrap/phases/06-workflows.md"
```

Expected: all three strings present.

- [ ] **Step 4: Commit**

```bash
git add "_bootstrap/phases/06-workflows.md"
git commit -m "feat: add career-evidence workflow"
```

---

## Task 9: Add `/personal-os-career-evidence` command

**Files:**
- Modify: `_bootstrap/phases/07-commands.md`

- [ ] **Step 1: Find the end of Phase 7 commands**

```bash
grep -n "### \`.claude/commands/" "/Users/jackhirsch/Library/CloudStorage/GoogleDrive-jack.hirsch@gmail.com/My Drive/Personal OS/_bootstrap/phases/07-commands.md"
```

Expected: list of all command section headers. New command goes after the last one.

- [ ] **Step 2: Append the command to Phase 7**

At the end of `_bootstrap/phases/07-commands.md`, append:

````markdown

### `.claude/commands/personal-os-career-evidence.md`

```markdown
Review captured career evidence and optionally generate a brag doc.
Usage: /personal-os-career-evidence [last 90d | last 6mo | all]

$ARGUMENTS may contain a time range. Default: last 90 days.

Follow `_system/workflows/career-evidence.md` exactly.
```
````

- [ ] **Step 3: Verify**

```bash
grep -n "personal-os-career-evidence\|career-evidence.md" "/Users/jackhirsch/Library/CloudStorage/GoogleDrive-jack.hirsch@gmail.com/My Drive/Personal OS/_bootstrap/phases/07-commands.md"
```

Expected: both strings present.

- [ ] **Step 4: Commit**

```bash
git add "_bootstrap/phases/07-commands.md"
git commit -m "feat: add /personal-os-career-evidence command"
```

---

## Self-Review Checklist

After completing all tasks, verify spec coverage:

- [ ] open-loops schema: `source_files`, `canonical_id`, `closed_in`, `merged` status — Task 2
- [ ] career-evidence.json schema — Task 3
- [ ] synthesis-log `career_evidence_created` field — Task 3
- [ ] profile/career/ directory — Task 1
- [ ] Commitment load thresholds in briefing prefs — Task 4
- [ ] career-evidence-digest template — Task 4
- [ ] Nightly synthesis dedup pass (Step 5.1) — Task 5
- [ ] Nightly synthesis career evidence extraction (Step 5.2) — Task 5
- [ ] Daily briefing commitment load nudge (Step 2.5) — Task 6
- [ ] Ready note canonical_id resolution — Task 7
- [ ] Career evidence workflow — Task 8
- [ ] `/personal-os-career-evidence` command — Task 9

# Karpathy Wiki Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add wiki activity logging, page schema template, monthly lint automation, and `/personal-os-remember` command to Personal OS so the knowledge wiki compounds from both nightly ingest and interactive sessions.

**Architecture:** All changes are to bootstrap phase files in `_bootstrap/phases/` — the source-of-truth templates that get instantiated when a user runs the bootstrap. Four files are touched: scaffold init (01), templates (05), workflows (06), and commands (07). No runtime files are modified directly; the bootstrap generates the vault.

**Tech Stack:** Markdown template editing only. No code. Verification is read-and-confirm.

---

## File Map

| File | What changes |
|------|-------------|
| `_bootstrap/phases/01-scaffold.md` | Add `Knowledge/wiki/log.md` initial file creation |
| `_bootstrap/phases/05-templates.md` | Append `_system/templates/wiki-page.md` template |
| `_bootstrap/phases/06-workflows.md` | (1) Strip model version numbers from all `## Model:` lines; (2) Update Step 4 of nightly-synthesis; (3) Update Step 6; (4) Update Step 9; (5) Add Step 11.5; (6) Add wiki-lint.md workflow; (7) Add wiki-remember.md workflow |
| `_bootstrap/phases/07-commands.md` | Append `.claude/commands/personal-os-remember.md` |

---

## Task 1: Add wiki/log.md scaffold init

**Files:**
- Modify: `_bootstrap/phases/01-scaffold.md`

- [ ] **Step 1: Read the file to find the insertion point**

  Open `_bootstrap/phases/01-scaffold.md`. The file ends with the `Inbox/_unrouted.md` block. Note the exact last line.

- [ ] **Step 2: Append the log.md init block**

  Add the following after the `Inbox/_unrouted.md` block (after the closing triple-backtick):

  ```
  
  **`Knowledge/wiki/log.md`**
  ```markdown
  # Wiki Activity Log
  _Append-only. Written by nightly synthesis and /personal-os-remember._
  _Format: `## [YYYY-MM-DD] [operation] | [description]`_
  _Operations: ingest | created | pattern | synthesis | remember | lint_
  
  ```
  ```

- [ ] **Step 3: Verify**

  Read `_bootstrap/phases/01-scaffold.md`. Confirm the `Knowledge/wiki/log.md` block appears after `Inbox/_unrouted.md` and contains the header, two italicized description lines, and the Operations line.

- [ ] **Step 4: Commit**

  ```bash
  git add "_bootstrap/phases/01-scaffold.md"
  git commit -m "feat: add Knowledge/wiki/log.md init to scaffold"
  ```

---

## Task 2: Add wiki-page.md template

**Files:**
- Modify: `_bootstrap/phases/05-templates.md`

- [ ] **Step 1: Append the template section**

  Add the following at the very end of `_bootstrap/phases/05-templates.md`:

  ````
  
  ### `_system/templates/wiki-page.md`
  
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
  ````

- [ ] **Step 2: Verify**

  Read the last 30 lines of `_bootstrap/phases/05-templates.md`. Confirm the `wiki-page.md` section is present with all five frontmatter fields (`concept`, `aliases`, `sources`, `last_updated`), the four body sections (`Summary`, `Key points`, `Related`, `Open questions`), and the HTML comment at the end.

- [ ] **Step 3: Commit**

  ```bash
  git add "_bootstrap/phases/05-templates.md"
  git commit -m "feat: add wiki-page.md schema template to bootstrap"
  ```

---

## Task 3: Strip model version numbers from 06-workflows.md

Model references in workflow files should use family name only — no version numbers — so the bootstrap doesn't become stale when models are updated.

**Files:**
- Modify: `_bootstrap/phases/06-workflows.md`

- [ ] **Step 1: Replace all Sonnet version references**

  In `_bootstrap/phases/06-workflows.md`, replace every occurrence of:
  ```
  ## Model: `claude-sonnet-4-6`
  ```
  with:
  ```
  ## Model: Sonnet
  ```
  Use replace_all since this string appears multiple times.

- [ ] **Step 2: Replace all Haiku version references**

  In `_bootstrap/phases/06-workflows.md`, replace every occurrence of:
  ```
  ## Model: `claude-haiku-4-5-20251001`
  ```
  with:
  ```
  ## Model: Haiku
  ```
  Use replace_all.

- [ ] **Step 3: Verify**

  Run:
  ```bash
  grep -n "claude-sonnet\|claude-haiku\|4-5-2025\|4-6" "_bootstrap/phases/06-workflows.md"
  ```
  Expected: no output (zero matches).

- [ ] **Step 4: Confirm model references still present**

  Run:
  ```bash
  grep -n "## Model:" "_bootstrap/phases/06-workflows.md"
  ```
  Expected: multiple lines, all reading `## Model: Sonnet` or `## Model: Haiku` — no version strings.

---

## Task 4: Update nightly-synthesis.md Step 4 (wiki connections)

**Files:**
- Modify: `_bootstrap/phases/06-workflows.md` (within the `nightly-synthesis.md` workflow block)

- [ ] **Step 1: Locate the current Step 4 block**

  In `_bootstrap/phases/06-workflows.md`, find the block that reads:
  ```
  ### Step 4: Wiki connections
  For each source processed tonight:
  a. Read its `connections` metadata
  b. For each named wiki page:
     - Exists → APPEND new dated section
     - Does not exist → CREATE with this connection as seed
  c. Never re-evaluate old connections
  ```

- [ ] **Step 2: Replace with the expanded version**

  Replace the entire Step 4 block (from `### Step 4:` through `c. Never re-evaluate old connections`) with:

  ```
  ### Step 4: Wiki connections
  For each source processed tonight:
  a. Read its `connections` metadata
  b. For each named wiki page:
     - **Exists** → read frontmatter, increment `sources:` count, update `last_updated:`, APPEND new dated section
     - **Does not exist** → CREATE from `_system/templates/wiki-page.md`: fill `concept:` from page name, `Summary:` from the source's key_concepts/summary fields, seed with this connection as first dated section
  c. Never re-evaluate old connections
  d. After each page touched, append ONE line to `Knowledge/wiki/log.md`:
     - New page: `## [DATE] created | [page.md] — seeded from [source slug]`
     - Existing page: `## [DATE] ingest | [source slug] → [page.md]`
  ```

- [ ] **Step 3: Verify**

  Read the Step 4 section. Confirm:
  - Point b has two bolded sub-bullets (**Exists** and **Does not exist**)
  - **Does not exist** references `_system/templates/wiki-page.md`
  - New point d exists with log.md append instructions
  - Both `created` and `ingest` log entry formats are present

---

## Task 5: Update nightly-synthesis.md Step 6 (pattern detection)

**Files:**
- Modify: `_bootstrap/phases/06-workflows.md`

- [ ] **Step 1: Locate the current Step 6 block**

  Find the block that reads:
  ```
  ### Step 6: Pattern detection (coaching function)
  - If 2+ sources or summaries processed this week share a key concept → flag in HEARTBEAT.md
  - If 3+ people mentioned a theme in 1on1s this week → flag for next daily briefing
  - Log flags in `HEARTBEAT.md` under "Open Questions"
  ```

- [ ] **Step 2: Replace with the wiki-filing version**

  Replace the entire Step 6 block with:

  ```
  ### Step 6: Pattern detection (coaching function)
  - If 2+ sources or summaries processed this week share a key concept → flag in HEARTBEAT.md
  - If 3+ people mentioned a theme in 1on1s this week → flag for next daily briefing
  - Log flags in `HEARTBEAT.md` under "Open Questions"
  - **Also file to wiki:** For each flagged pattern:
    a. Identify the closest wiki page (read `Knowledge/wiki/_index.md` — match concept column)
    b. If a matching page exists: APPEND dated section with the pattern summary
    c. If no page exists: CREATE from `_system/templates/wiki-page.md` using the pattern as the seed
    d. Append to `Knowledge/wiki/log.md`: `## [DATE] pattern | [page.md] — [one-line pattern description]`
  ```

- [ ] **Step 3: Verify**

  Read the Step 6 section. Confirm:
  - The first three bullets are unchanged
  - A fourth bold bullet `**Also file to wiki:**` exists with sub-points a through d
  - Sub-point d references `Knowledge/wiki/log.md` with `pattern` as the operation type

---

## Task 6: Update nightly-synthesis.md Step 9 and add Step 11.5

**Files:**
- Modify: `_bootstrap/phases/06-workflows.md`

- [ ] **Step 1: Locate the Step 9 synthesis section**

  Find the block within Step 9 that reads:
  ```
  After 5+ sources on any single wiki concept:
  - Append "Synthesis as of [date]" section to that wiki page
  - Do NOT delete prior connection entries
  ```

- [ ] **Step 2: Add the log line to Step 9**

  Replace that block with:
  ```
  After 5+ sources on any single wiki concept:
  - Append "Synthesis as of [date]" section to that wiki page
  - Do NOT delete prior connection entries
  - Append to `Knowledge/wiki/log.md`:
    `## [DATE] synthesis | [page.md] — synthesized from [N] sources`
  ```

- [ ] **Step 3: Locate Step 11 (the last step)**

  Find the block that reads:
  ```
  ### Step 11: Update HEARTBEAT.md
  - Last Nightly Synthesis: [today]
  - Count of items processed
  - Any patterns flagged (from Step 6)
  - If today is the first of the month and `BACKLOG.md` has open items: append a flag to HEARTBEAT.md Open Questions: "Backlog review due — N items open in BACKLOG.md"
  ```

- [ ] **Step 4: Add Step 11.5 immediately after Step 11**

  Add the following block after Step 11 (before the closing triple-backtick of the nightly-synthesis.md workflow):

  ```
  
  ### Step 11.5: Monthly wiki lint (1st of each month only)
  - Check if today's date is the 1st of the month
  - If yes: follow `_system/workflows/wiki-lint.md`
  - Output goes to `Knowledge/wiki/_lint-report.md`
  - Append to HEARTBEAT.md Open Questions: "Wiki lint report ready — Knowledge/wiki/_lint-report.md"
  - (Daily briefing Step 6 "Fresh from last night" will surface this automatically via HEARTBEAT.md)
  ```

- [ ] **Step 5: Verify**

  Read Step 9 — confirm the `synthesis` log line is present.
  Read Step 11.5 — confirm it exists after Step 11, checks for 1st of month, references `wiki-lint.md`, and sets HEARTBEAT.md.

---

## Task 7: Add wiki-lint.md workflow

**Files:**
- Modify: `_bootstrap/phases/06-workflows.md`

- [ ] **Step 1: Find the insertion point**

  In `_bootstrap/phases/06-workflows.md`, find the `wiki-remember.md` workflow if it doesn't yet exist, or the final workflow section. The wiki-lint workflow is added as a new section at the end of the file — after the last existing workflow definition (career-evidence.md or week-ahead.md), before the closing of the file.

- [ ] **Step 2: Append the wiki-lint.md workflow block**

  Append at the end of `_bootstrap/phases/06-workflows.md`:

  ````
  
  ### `_system/workflows/wiki-lint.md`
  
  ```markdown
  # Wiki Lint Workflow
  
  ## Model: Sonnet
  ## Trigger: Nightly synthesis Step 11.5 (1st of each month)
  
  ## Steps
  
  1. Read `Knowledge/wiki/_index.md` — load all page slugs, concept tags, source counts, last-updated dates
  2. Read `Knowledge/wiki/log.md` — understand what changed recently
  3. For each wiki page, scan for outbound `[[wiki-links]]` — build a reverse index of inbound links
  
  4. Check for:
     a. **Orphan pages** — no inbound links from any other wiki page
     b. **Stale pages** — `last_updated` > 60 days AND no sources with `status: pending` in `Inbox/_index.md`
     c. **Concept gaps** — terms appearing 3+ times across `Knowledge/sources/` metadata `key_concepts` fields but with no wiki page
     d. **Unlinked entities** — a person mentioned in 3+ 1on1 summaries (scan `1on1s/*/sessions/_index.md` Key topic column) but no wiki page exists under their name
     e. **Possible contradictions** — two pages referencing the same entity with claims that look inconsistent by date (flag for human review — never auto-resolve)
  
  5. Write `Knowledge/wiki/_lint-report.md`:
  
  ```
  # Wiki Health Report — [DATE]
  
  ### Orphan pages (no inbound links)
  - [page.md] — last updated [date]
  
  ### Stale pages (60+ days, no new sources pending)
  - [page.md] — last updated [date], [N] sources
  
  ### Concept gaps (no page yet)
  - "[term]" — mentioned in [N] sources: [source1.md, source2.md]
  
  ### Unlinked entities
  - "[Name]" — mentioned in [N] 1on1 sessions, no wiki page
  
  ### Possible contradictions (review manually)
  - [page-a.md] vs [page-b.md] — both reference "[entity]" with potentially conflicting claims
  
  ### Summary
  [N] orphans | [N] stale | [N] gaps | [N] contradictions
  ```
  
  6. Append to `Knowledge/wiki/log.md`:
     `## [DATE] lint | [N] orphans, [N] stale, [N] gaps — Knowledge/wiki/_lint-report.md`
  ```
  ````

- [ ] **Step 3: Verify**

  Read the end of `_bootstrap/phases/06-workflows.md`. Confirm:
  - `wiki-lint.md` section is present
  - `## Model: Sonnet` (no version number)
  - Five lettered checks (a through e) are present
  - The lint report template shows all five sections
  - Step 6 appends to `Knowledge/wiki/log.md` with `lint` as the operation

---

## Task 8: Add wiki-remember.md workflow

**Files:**
- Modify: `_bootstrap/phases/06-workflows.md`

- [ ] **Step 1: Append the wiki-remember.md workflow block**

  Append at the very end of `_bootstrap/phases/06-workflows.md` (after the wiki-lint.md block):

  ````
  
  ### `_system/workflows/wiki-remember.md`
  
  ```markdown
  # Wiki Remember Workflow
  
  ## Model: Sonnet
  ## Trigger: `/personal-os-remember`
  
  ## Purpose
  File insights from the current session into the wiki before the conversation ends.
  This is the only step in the compounding knowledge pipeline that requires human judgment.
  The system does not write anything without explicit user confirmation.
  
  ## Steps
  
  1. **Review session context**
     Reflect on what just happened in this conversation. Look for insights worth persisting:
     - Synthesis or patterns discovered (cross-transcript, cross-person, cross-time)
     - Connections between concepts, people, or projects not captured anywhere else
     - Open questions surfaced that belong in a wiki page's "Open questions" section
     - Strategic framing or reasoning that should be traceable later
     
     **Exclude:** action items (those go to open-loops.json), routine task outputs (already in summaries), things already in a session summary file, ephemeral context that won't matter next month.
  
  2. **Propose 1–3 items to file**
     For each item:
     ```
     [N]. File to: Knowledge/wiki/[page.md]  (will create if it doesn't exist)
          Content: [one paragraph — the insight, in plain language, past tense]
          Type: synthesis | pattern | connection | open-question
     ```
     If nothing from this session meets the bar, say: "Nothing from this session meets the bar for wiki filing." Do not manufacture insights.
  
  3. **Wait for user confirmation**
     User may: approve all, approve some, edit content, redirect to a different page, or decline entirely.
     Do NOT write anything until the user explicitly approves.
  
  4. **Write each approved item**
     a. If page exists: append dated section, update `last_updated:` in frontmatter, increment `sources:` count by 1
     b. If page doesn't exist: create from `_system/templates/wiki-page.md`, use the insight as `Summary:` and as the first dated section below the divider
     c. Update `Knowledge/wiki/_index.md`: add row if new page (`| [page.md] | [concepts] | 1 | [DATE] |`), update Last updated column if existing page
     d. Append to `Knowledge/wiki/log.md`:
        `## [DATE] remember | [page.md] — [one-line description of what was filed]`
  
  5. **Confirm**
     Report: "Filed [N] insight(s) to: [page1.md, page2.md]. Logged in wiki/log.md."
  ```
  ````

- [ ] **Step 2: Verify**

  Read the final section of `_bootstrap/phases/06-workflows.md`. Confirm:
  - `wiki-remember.md` section is present after `wiki-lint.md`
  - `## Model: Sonnet` (no version number)
  - Step 2 shows the exact proposal format with the three fields (File to, Content, Type)
  - Step 3 explicitly says "Do NOT write anything until the user explicitly approves"
  - Step 4d appends to `Knowledge/wiki/log.md` with `remember` as the operation
  - Step 5 gives the confirmation format

- [ ] **Step 3: Commit all 06-workflows.md changes**

  ```bash
  git add "_bootstrap/phases/06-workflows.md"
  git commit -m "feat: add wiki log/lint/remember workflows and schema enforcement to nightly synthesis"
  ```

---

## Task 9: Add /personal-os-remember command

**Files:**
- Modify: `_bootstrap/phases/07-commands.md`

- [ ] **Step 1: Append the command block**

  Add the following at the very end of `_bootstrap/phases/07-commands.md`:

  ````
  
  ### `.claude/commands/personal-os-remember.md`
  
  ```markdown
  File insights from this session into the wiki.
  
  Follow `_system/workflows/wiki-remember.md` exactly.
  If nothing from this session meets the bar for wiki filing, say so directly — do not force it.
  ```
  ````

- [ ] **Step 2: Verify**

  Read the end of `_bootstrap/phases/07-commands.md`. Confirm:
  - `personal-os-remember.md` section is present
  - It references `_system/workflows/wiki-remember.md`
  - It includes the "nothing meets the bar" instruction

- [ ] **Step 3: Commit**

  ```bash
  git add "_bootstrap/phases/07-commands.md"
  git commit -m "feat: add /personal-os-remember slash command"
  ```

---

## Task 10: End-to-end verification

- [ ] **Step 1: Verify no version numbers remain in workflow files**

  ```bash
  grep -rn "claude-sonnet-4\|claude-haiku-4\|4-5-2025" "_bootstrap/phases/"
  ```
  Expected: no output.

- [ ] **Step 2: Verify all new content is present**

  ```bash
  grep -n "wiki/log.md\|wiki-page.md\|wiki-lint\|wiki-remember\|personal-os-remember\|Step 11.5" "_bootstrap/phases/01-scaffold.md" "_bootstrap/phases/05-templates.md" "_bootstrap/phases/06-workflows.md" "_bootstrap/phases/07-commands.md"
  ```
  Expected: at least one match per search term across the four files.

- [ ] **Step 3: Verify log.md format line is present in scaffold**

  ```bash
  grep -n "Operations: ingest" "_bootstrap/phases/01-scaffold.md"
  ```
  Expected: one match.

- [ ] **Step 4: Verify wiki-page.md template has all required fields**

  ```bash
  grep -n "concept:\|aliases:\|sources:\|last_updated:\|Summary:\|Key points:\|Related:\|Open questions:" "_bootstrap/phases/05-templates.md"
  ```
  Expected: one match per field.

- [ ] **Step 5: Verify propose-before-write gate in wiki-remember**

  ```bash
  grep -n "Do NOT write" "_bootstrap/phases/06-workflows.md"
  ```
  Expected: one match in the wiki-remember workflow.

- [ ] **Step 6: Final commit if any loose files remain unstaged**

  ```bash
  git status
  ```
  If clean: done. If any files unstaged, stage and commit them.

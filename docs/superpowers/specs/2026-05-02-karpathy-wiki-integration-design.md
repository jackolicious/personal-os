# Design Spec: Karpathy Wiki Integration
_2026-05-02_

## Problem

`Knowledge/wiki/` grows via nightly append but has three gaps:

1. **No memory of its own evolution.** There's no record of which pages were touched, when, or why. `synthesis-log.json` tracks processed files, not wiki mutations.
2. **No structural consistency.** New pages have no enforced schema — no Summary, no Related links, no Open questions. Machine queries and health checks are harder than necessary.
3. **Knowledge leakage from sessions.** Insights synthesized during interactive Claude sessions disappear when the conversation ends. Only nightly ingest compounds into the wiki; live sessions don't.

Inspired by Andrej Karpathy's LLM Wiki pattern (gist.github.com/karpathy/442a6bf555914893e9891c11519de94f).

---

## Solution

Four additions, all automated except one manual command.

### 1. Wiki Activity Log (`Knowledge/wiki/log.md`)

Append-only file written by nightly synthesis and `/personal-os-remember`. Every wiki mutation gets one line:

```
## 2026-05-02 ingest | alice-1on1-q2.md → delegation.md, platform-dependencies.md
## 2026-05-02 created | platform-dependencies.md — seeded from alice-1on1-q2.md
## 2026-06-01 lint | 2 orphans, 1 stale, 3 gaps — Knowledge/wiki/_lint-report.md
## 2026-05-09 remember | delegation.md — Alice's blockers have been platform-related for 3 quarters
```

**Format:** `## [YYYY-MM-DD] [operation] | [description]`
**Operations:** `ingest` | `created` | `pattern` | `synthesis` | `remember` | `lint`

The log makes it possible to answer: "when was this page last updated, and from what?" It also gives Claude context before answering wiki queries.

### 2. Wiki Page Schema (`_system/templates/wiki-page.md`)

New wiki pages are created from a template with consistent frontmatter and structure:

```markdown
---
concept: "delegation"
aliases: []
sources: 3
last_updated: 2026-05-09
---

# Delegation

**Summary:** One sentence synthesizing the concept as it applies to Jack's context.

**Key points:**
- Bullet insights accumulated over time

**Related:** [[platform-dependencies]], [[alice]]

**Open questions:**
- Questions worth investigating in future sessions

---
<!-- Connections appended below by nightly synthesis and /personal-os-remember -->
## 2026-05-02 | From: alice-1on1-q2.md
[connection content]
```

Existing nightly Step 4 creates new pages from this template instead of blank files. The `Summary:`, `Key points:`, and `Related:` fields are filled on creation and updated by synthesis (Step 9).

### 3. Monthly Wiki Lint (automated, 1st of each month)

New Step 11.5 in nightly synthesis runs `_system/workflows/wiki-lint.md` on the 1st of each month. Output goes to `Knowledge/wiki/_lint-report.md` and surfaces in the morning briefing via the "Fresh from last night" section.

**Five checks:**

| Check | What it catches |
|-------|----------------|
| Orphan pages | Pages no other wiki page links to |
| Stale pages | `last_updated` > 60 days with no pending sources |
| Concept gaps | Terms in 3+ source `key_concepts` fields with no wiki page |
| Unlinked entities | People in 3+ 1on1 summaries with no wiki page |
| Possible contradictions | Two pages making conflicting claims about the same entity |

Lint never auto-fixes. It surfaces findings for human review.

### 4. `/personal-os-remember` (one manual command)

The only manual step in the whole pipeline. Run at the end of any session where something insightful happened.

**Flow:**
1. Claude reviews the conversation and identifies 1–3 insights worth persisting
2. For each: proposes the target page and a one-paragraph filing
3. User approves, edits, or declines each — nothing is written without confirmation
4. Approved items are written to wiki pages (new or append), `_index.md` updated, `log.md` appended

If nothing in the session meets the bar, Claude says so. No forced filing.

**What qualifies:** cross-transcript patterns, strategic connections, open questions worth tracking
**What doesn't:** action items (→ open-loops.json), routine outputs, ephemeral context

---

## What changes in nightly synthesis

| Step | Current behavior | New behavior |
|------|-----------------|--------------|
| Step 4 | Appends dated sections to wiki pages | Also: uses template for new pages; logs all mutations to log.md |
| Step 6 | Flags patterns in HEARTBEAT.md only | Also: files patterns to wiki pages; logs to log.md |
| Step 9 | Appends synthesis section | Also: logs to log.md |
| Step 11.5 | (new) | Monthly lint → `_lint-report.md` → HEARTBEAT.md flag |

---

## Files created/modified

| Bootstrap file | What changes |
|---------------|-------------|
| `_bootstrap/phases/01-scaffold.md` | Add `Knowledge/wiki/log.md` init |
| `_bootstrap/phases/05-templates.md` | Add `_system/templates/wiki-page.md` |
| `_bootstrap/phases/06-workflows.md` | Update nightly-synthesis.md (Steps 4, 6, 9, add 11.5); add wiki-lint.md; add wiki-remember.md; strip model version numbers from all workflows |
| `_bootstrap/phases/07-commands.md` | Add `.claude/commands/personal-os-remember.md` |

**Convention:** Model references use family name only (`Sonnet`, `Haiku`) — no version numbers.

---

## End state

```
Transcript → Inbox → nightly synthesis
  Step 4: wiki pages created from template, all mutations logged ✓
  Step 6: patterns auto-filed to wiki ✓
  Step 9: synthesis sections logged ✓
  Step 11.5 (1st of month): lint report → morning briefing ✓

Interactive session
  → /personal-os-remember
  → propose → confirm → file → log ✓
```

One manual command. Everything else is invisible.

---

## Out of scope

- qmd / local search integration (deferred until wiki exceeds ~75 pages)
- Migrating existing wiki pages to new schema (new pages use template; existing pages are not rewritten)
- Contradiction auto-resolution (lint surfaces findings only; human resolves)

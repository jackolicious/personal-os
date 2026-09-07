# Phase 9: Finalization
_Depends on: Phases 1–8 (everything must exist)_

## Sync and backup

This system does NOT use GitHub for the personal vault. Sensitive 1on1 notes,
decisions, and strategy content stay local.

**Backup:** Obsidian Sync (set up when ready — vault works fully without it)
  - Sign up at obsidian.md/sync
  - Enable in Obsidian Settings → Sync
  - Vault will be available on Obsidian iOS once configured

**Bootstrap template:** A separate public GitHub repo containing only this
meta prompt and the blank scaffold (no personal data) can be maintained
as a reference/restore point.

**For now:** Vault lives locally. No additional action needed in this phase.

---

## Setup confirmation and personalization

After scaffold is built, confirm each item before first use.

### Required before Day 1

**Granola transcript path:**
- [ ] Open Granola Settings → Obsidian integration
- [ ] Set export folder to: `[vault path]/Inbox/transcripts/`
- [ ] Test: export one transcript and verify it appears in `Inbox/transcripts/`

**markitdown:**
- [ ] `pip install markitdown`
- [ ] Test: `markitdown --version`

**Mac sleep:**
- [ ] System Settings → Battery → Options → "Prevent automatic sleeping on power adapter when display is off" → ON

**Nightly loop:**
- [ ] Open a dedicated terminal tab
- [ ] `bash run-nightly.sh`
- [ ] Confirm it's running (leave tab open)

### Personalization (fill in before first session)

**Root `CLAUDE.md`:**
- [ ] Your name, company, start date
- [ ] Direct report names, titles, Slack handles
- [ ] Slack channel names

**`GOALS.md`:**
- [ ] Update 30/60/90 objectives to your actual situation

**`PILLARS.md`:**
- [ ] Confirm pillars were pre-filled from interview Q7
- [ ] Add keywords for each pillar (used for auto-tagging loops)

**Gmail access (optional — for acknowledgment loop):**
- [ ] Connect Gmail via any supported mechanism (MCP, Google CLI, or equivalent) — the acknowledgment scan works with any method that can search and label mail
- [ ] Confirm `profile/preferences/briefing.md` has `user_email:` filled in (pre-filled from interview Q0 if answered)
- [ ] Test: run `/personal-os-daily-briefing` and confirm the scan either closes matched loops or reports gracefully when no EXO_DONE emails exist — if Gmail is not connected, it skips silently

**Calendar integration (optional):**
- [ ] If using Google Calendar: confirm Google Calendar MCP is connected in Claude Code
- [ ] If using Apple Calendar: confirm macOS Calendar access is granted to Claude Code
- [ ] Create `profile/preferences/calendar.md` from template and set your source and preferences
- [ ] Test: run `/personal-os-week-ahead` and confirm it surfaces your schedule or degrades gracefully

**`People/team.md`:**
- [ ] Add full team roster

**`profile/preferences/`:**
- [ ] All 5 modules pre-filled by Phase 0 interview — verify each file has real content, not placeholders
- [ ] Set start_date in `_system/data/synthesis-log.json` preference_tuning section to today
- [ ] Confirm `profile/preferences/briefing.md` has `user_email:` filled in (used for acknowledgment loop mailto links)

### First week rituals

| When | What |
|------|------|
| Each morning | `/personal-os-daily-briefing` |
| Before each 1on1 | `/personal-os-1on1-prep [name]` |
| After each Granola export | `/personal-os-process-inbox` |
| When dropping a link | `/personal-os-ingest-url [url]` |
| Friday afternoon | `/personal-os-cascade` |

### People to create immediately
- [ ] `/personal-os-new-1on1 [DR1]`
- [ ] `/personal-os-new-1on1 [DR2]`
- [ ] (add stakeholders as you meet them)

---

## Validate

After completing all phases, run these checks:

1. `find . -name "CLAUDE.md" | sort` — should show 11 CLAUDE.md files
2. `cat _system/data/synthesis-log.json` — should be valid JSON with empty processed_files
3. `cat _system/data/open-loops.json` — should be valid JSON with empty loops array
4. `ls .claude/commands/` — should show 19 command files (including personal-os-brief.md and personal-os-decide.md)
5. `ls _system/workflows/` — should show 19 workflow files (including brief.md and decision-record.md)
6. `ls profile/preferences/` — should show 7 files: synthesis.md, communication.md, briefing.md, writing-style.md, decisions.md, 1on1.md, knowledge.md (plus calendar.md when calendar integration is configured)
7. `bash run-nightly.sh` in a separate tab — confirm it starts without error
8. `cat PILLARS.md` — should show 4–6 pillar sections with keywords

9. `cat profile/preferences/decisions.md` — read the seven decision principles and rewrite any you
   do not hold. They ship as defaults and no interview question fills them in, so they are one
   person's operating style until you edit them.

Report any missing files or errors before marking setup complete.

---

## Clean up bootstrap files

After validation passes, ask the user:

> "Bootstrap complete and validated. Clean up now? This will save the system design rationale to your wiki, then permanently delete `_bootstrap/` and `personal-os-bootstrap.md`. [Y/n]"

**If yes:**

1. Create `Knowledge/wiki/system-design.md` with exactly this content (substitute today's date for `[TODAY]`):

```markdown
---
source_type: design-document
ingested: [TODAY]
---

# Personal OS — System Design

_Design rationale for the Personal OS. For your personal context, see CLAUDE.md._

## Design constraints

- Bootstrappable from any machine (self-contained, no external dependencies at setup)
- Non-destructive: sources are sacred, synthesis is append-only
- Context-efficient: CLAUDE.md files are lean doc-indexes, not instruction manuals
- Incremental: nightly synthesis processes only the delta, never reruns everything
- Index-first: every directory has an `_index.md`; workflows read the index, then targeted files — never full directory scans

## Why three-tier immutability

Raw transcripts and PDFs can run 5,000–15,000 tokens each. If any workflow had to
read raw sources to answer a question, you'd exhaust your context window before
reaching synthesis. The three tiers solve this by keeping each layer at the right
abstraction and token cost:

| Tier | Examples | Token footprint | Rule |
|------|----------|-----------------|------|
| **Sources** | Transcripts, PDFs, raw URLs | 5k–15k each | Immutable after ingestion |
| **Summaries** | 1on1 session summaries, source annotations | 300–800 each | Write-once, regeneratable |
| **Synthesis** | Wiki pages, profiles, briefings, open-loops.json | 100–400 per entry | Append-only, never rewritten |

**Context efficiency**: Workflows load summaries and synthesis only — not sources.
A `/personal-os-1on1-prep` reading 3 summaries uses ~2k tokens, not 45k.

**Reproducibility**: Sources never change, so any summary can be regenerated from
ground truth if synthesis logic improves.

**Incremental trust**: The hash-based `synthesis-log.json` only works if sources are
immutable. Mutable sources would require reprocessing everything on every change.

**Compounding**: Each tier accumulates independently. New sessions create summaries;
summaries feed wiki pages; wiki pages compound into strategic themes. A single change
anywhere lower would invalidate the layers above it.

Automation runs nightly via persistent terminal loop on an always-on Mac.
```

2. Append to `Knowledge/wiki/_index.md`:
   ```
   | system-design.md | immutability, incremental, index-first | 0 | [TODAY] |
   ```

3. Append to `Knowledge/wiki/log.md`:
   ```
   ## [TODAY] ingest | system-design.md — Personal OS design rationale ingested from bootstrap
   ```

4. Run: `rm -rf _bootstrap`

5. Run: `rm -f personal-os-bootstrap.md`

**If no:** Skip cleanup. Run `bash _bootstrap/archive.sh` later to clean up manually.

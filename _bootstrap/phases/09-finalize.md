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

1. `find . -name "CLAUDE.md" | sort` — should show 7+ CLAUDE.md files
2. `cat _system/data/synthesis-log.json` — should be valid JSON with empty processed_files
3. `cat _system/data/open-loops.json` — should be valid JSON with empty loops array
4. `ls .claude/commands/` — should show 11 command files (including personal-os-week-ahead.md)
5. `ls _system/workflows/` — should show 8 workflow files (including week-ahead.md)
6. `ls profile/preferences/` — should show 5 files: synthesis.md, briefing.md, writing-style.md, 1on1.md, knowledge.md
7. `bash run-nightly.sh` in a separate tab — confirm it starts without error
8. `cat PILLARS.md` — should show 4–6 pillar sections with keywords

Report any missing files or errors before marking setup complete.

---

## Archive bootstrap (optional)

Once setup is confirmed, run `bash _bootstrap/archive.sh` to move `_bootstrap/` out of root.
This is optional — keep `_bootstrap/` if you plan to keep editing it as a codebase.

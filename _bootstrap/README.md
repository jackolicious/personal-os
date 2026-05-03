# Personal OS Bootstrap

Split into 9 phase files for maintainability. Each phase has one responsibility and runs as an isolated subagent to keep the main context window clean.

## Prerequisites

- `pip install markitdown`
- One transcript tool configured (Granola / Fireflies / Zoom / Otter)
- Run `bash setup.sh` to scaffold the vault

**To run the bootstrap:** paste everything below the horizontal rule into Claude Code in your vault directory.

## File structure

| File | Purpose |
|------|---------|
| `context.md` | System design rationale — read first |
| `phases/00-interview.md` | Installer interview — ask 6 questions, write answers |
| `phases/01-scaffold.md` | Directory structure |
| `phases/02-root-files.md` | `.gitignore`, `GOALS.md`, `HEARTBEAT.md` |
| `phases/03-claude-md.md` | `CLAUDE.md` hierarchy (10 files) |
| `phases/04-data.md` | JSON data models + index formats |
| `phases/05-templates.md` | 5 preference modules + 6 templates |
| `phases/06-workflows.md` | 7 workflow playbooks |
| `phases/07-commands.md` | 10 slash commands |
| `phases/08-automation.md` | `run-nightly.sh` + vault permissions |
| `phases/09-finalize.md` | Validation + personalization checklist |
| `archive.sh` | Post-bootstrap cleanup (run after setup is complete) |

## After bootstrap

Run `bash _bootstrap/archive.sh` to move this directory to `_system/bootstrap-archive/` and record the completion timestamp.

To re-edit later: `mv _system/bootstrap-archive/<date> _bootstrap`

---

# Bootstrap

You are setting up a Personal OS vault. Read `_bootstrap/context.md` first for system design rationale.

**Run each phase as a subagent to keep the main context window clean.**

For each phase: dispatch a subagent with the prompt below, wait for it to complete, confirm with one line, then proceed.

Subagent prompt template:
> "Read `_bootstrap/phases/[NN-name].md` and execute every instruction in it exactly.
> Write all files and directories specified. Do not skip any step.
> When done, report: files created, any errors."

Phases to dispatch in order:
0. `_bootstrap/phases/00-interview.md` — installer interview (ask questions, write answers)
1. `_bootstrap/phases/01-scaffold.md` — directory structure
2. `_bootstrap/phases/02-root-files.md` — .gitignore, GOALS.md, HEARTBEAT.md
3. `_bootstrap/phases/03-claude-md.md` — CLAUDE.md hierarchy (10 files)
4. `_bootstrap/phases/04-data.md` — JSON data models + index formats
5. `_bootstrap/phases/05-templates.md` — 5 preference modules + 6 templates
6. `_bootstrap/phases/06-workflows.md` — 7 workflow playbooks
7. `_bootstrap/phases/07-commands.md` — 10 slash commands
8. `_bootstrap/phases/08-automation.md` — run-nightly.sh + vault permissions
9. `_bootstrap/phases/09-finalize.md` — validation + personalization checklist

Start Phase 1 immediately. No preview. Confirm each phase with one line before proceeding.

After all phases complete: run `bash _bootstrap/archive.sh` to clean up root.

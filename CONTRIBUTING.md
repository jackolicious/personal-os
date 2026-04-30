# Contributing to Personal OS

Personal OS is a meta prompt — a single file you paste into Claude Code to scaffold a second brain system. Contributions improve the prompt itself: the workflow playbooks, data models, slash commands, and setup sequence.

## What's worth contributing

**High value:**
- Workflow improvements you've run in production and found wanting (be specific about what broke)
- New slash commands that fill real gaps
- Data model changes that make the system more useful (like the `last_contact` field)
- Fixes to setup steps that are confusing or don't work as described
- Adaptations for roles beyond Head of Product

**Low value:**
- Theoretical improvements you haven't tested
- Complexity added for edge cases most people won't hit
- Style preferences

## How to contribute

1. **Fork and branch.** Work on a branch named for what you're changing: `fix/nightly-step-numbering`, `feat/project-health-tracking`.

2. **Test your changes.** Run the affected workflow against a real vault. The bootstrap has a validation phase (Phase 11) — use it.

3. **Be concrete in PRs.** Describe what you changed, why, and what you tested. "Made cascade better" is not enough. "Cascade was regenerating all three audience drafts even when only one changed — added per-audience dirty flag to step 2" is.

4. **One thing per PR.** Don't bundle a data model change with a new workflow with a README edit. Separate concerns.

## What not to break

- The three-tier immutability model (sources sacred, synthesis append-only)
- The incremental processing design (nightly synthesis must never reprocess already-processed files)
- The root CLAUDE.md line limit (≤70 lines — it's loaded on every session)
- The Phase 10 personalization checklist — it must stay accurate for first-time setup

## Issues

Use GitHub Issues to report setup failures, workflow bugs, or to propose new features before building them. Tag clearly: `bug`, `enhancement`, `question`.

## License

By contributing you agree your changes are licensed under MIT.

# Personal OS — CPO Chief of Staff Backlog
_Development backlog for the bootstrap project. Last updated: 2026-05-20_

## Design principles (established 2026-05-10)
- Connection-type agnostic: workflows define what's needed (calendar events, messages, context), not how to get it
- Graceful degradation: each workflow has a fallback mode that works without any integration
- Auto-resolve policy: follow clawchief resolution model — auto-resolve low-risk operational tasks, draft-and-ask for judgment calls, escalate-without-acting when authority is unclear
- Integration setup is the user's responsibility (MCP, API, CLI, etc.)
- Drop-zone model is intentional: no auto-ingestion of communications. The acknowledgment loop closes loops; it does not open them.

## Active sprint

### P. Acknowledgment loop [DONE — 2026-05-20]
EXO_DONE mailto mechanism. Tapping a link on mobile sends a self-email; Step 0 of the daily briefing scans Gmail for matches and closes the loop in open-loops.json. Auto-archives signal emails. Gracefully skips if Gmail is unavailable.

### A. Proactive meeting prep [IN PROGRESS — brainstorming]
Extend 1on1 prep to all calendar meetings. Proactive trigger (before meetings start or in daily briefing). Connection-agnostic calendar scanning with graceful degradation.

### B. Ghostwriter + content pipeline [NEXT]
Write in Jack's voice for Slack posts, cascade drafts, PRDs, external comms. Includes writing style capture and humanizer (remove AI traces). Reference: existing `humanizer` skill in superpowers.

---

## Backlog (roughly prioritized)

### L. Decision Log [DONE, 2026-09-05]
Shipped as decision records. `Decisions/<slug>/decision.md` (standalone) or
`Projects/<project>/decisions/<slug>/` (project-scoped), both indexed in `Decisions/_index.md`.
DACI with exactly one accountable approver, reversibility classified first, roughly three
options with who recommends what, an evidence bar, and an append-only decision log. Driven by
`/personal-os-decide` and `_system/workflows/decision-record.md`, with principles the owner
edits in `profile/preferences/decisions.md`. Guard: `_bootstrap/tests/14-decision-records.sh`.

Still open from the original item: the quarterly retrospective pass that compares the expected
outcome against what happened. The record has the fields for it, nothing reads them yet.

### M. Customer Signal Synthesis
On ingestion of customer call transcripts, extract jobs-to-be-done, pain points, and feature signals and append to `Knowledge/customer-signals.md`. Quarterly rollup surfaces top themes for roadmap prioritization. Makes the three-tier compounding work for customer intel, not just internal 1:1s.

### N. Executive Narrative Draft
Auto-draft the weekly CEO/board update from existing system state: OKR progress, recent decision log entries, open loops. Produces a structured artifact (progress / decisions / blockers / asks) that gets edited rather than written from scratch. Different from ghostwriter — this is structured executive reporting with a fixed schema.

### O. OKR Pulse Briefing
Weekly synthesis that reads OKR state and surfaces a portfolio-level narrative: what's red/amber, one-sentence "why" per key result, and pre-drafted talking points for the exec sync. Output: ~200-word narrative ready to paste into the weekly update. Goes beyond the team-health performance tracker (item G) to cover the full product portfolio.

### C. Email triage
Gmail inbox processing. Classify signals: action-required / FYI / delegate / archive. Auto-resolve low-risk operational replies (clawchief model). Draft-and-ask for judgment calls. Gmail MCP is available.

### D. Slack triage
Slack message processing. Same classification model as email. Slack integration TBD (MCP or API).

### E. CPO lens / PRD pipeline
Prompted reqs → PoC → spec → prototype → product. Modeled on Rachel Wolan's `create-prd`, `cpo-lens`, `process-task-list`, `generate-tasks`.

### F. Competitive positioning
Research and synthesis skill. Track competitor moves, surface insights into wiki.

### G. Performance tracker
Team health and performance signals. Integrates with 1on1 data, open loops, career evidence.

### H. Executive 1:1 prep
Specialized prep for C-suite 1:1s (CEO, CFO, etc.) — different framing than DR 1on1s.

### I. Calendar analyzer
Pattern analysis across calendar data. Meeting load, focus time ratio, relationship coverage.

### J. Snowflake / data metrics integration
Surface product metrics into the daily briefing and wiki. Requires data warehouse access.

### K. Daily index card
Compact daily output: top 3 priorities, key meetings, one focus metric. Telegram-deliverable.

---

## Completed

### P. Acknowledgment loop (2026-05-20)
EXO_DONE mailto mechanism borrowed from POHA. Open loops in daily briefing and `/personal-os-open-loops` include a tappable `[✓ Done?]` mailto link. Tapping sends a self-email; Step 0 of the daily briefing scans Gmail for matches and closes the loop. Auto-archives signal emails. Gracefully skips if Gmail is unavailable. Slugs auto-generated on loop creation.

## Prose rule cleanup in the template's own files

The installer teaches "no em dashes" and its own source carries 394 of them, 40 of those inside
`_bootstrap/phases/03-claude-md.md`, the file that states the rule. The self-refuting line is fixed
and the guard now ships to installed vaults (Phase 8 Step 2b, test 10). The template's own prose is
still unclean.

Worth doing as a mechanical sweep with a ratchet test so the count can only fall. Shell scripts need
care, since an em dash inside a `grep` pattern is load bearing while one inside an `echo` is not.

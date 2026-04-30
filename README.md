# Personal OS

**An AI-powered Chief of Staff for your Obsidian vault.**

Personal OS is a bootstrap meta prompt that turns Claude Code + Obsidian into a second brain designed for leaders who are information-dense and time-poor. Paste one file into a fresh vault, answer a few setup questions, and you have a system that processes your meetings, tracks your open loops, monitors your relationships, and briefs you every morning.

---

## What it does

| Workflow | Trigger | Output |
|----------|---------|--------|
| **Daily briefing** | `/daily-briefing` | Prioritized morning brief: open loops, meetings, relationship health, pattern |
| **1on1 tracking** | `/1on1-prep [name]` | Pre-read: last session summary + open loops + themes for that person |
| **Meeting processing** | `/process-inbox` | Extracts commitments from Granola transcripts → open loops JSON |
| **Cascade** | `/cascade` | Weekly stakeholder updates drafted for down / lateral / up audiences |
| **Nightly synthesis** | Auto at 2am | Incremental: wiki connections, pattern detection, preference tuning |
| **Open loops** | `/open-loops` | Filterable view by person, project, priority, or staleness |
| **Relationship health** | Part of daily briefing | Flags direct reports (>14d) and stakeholders (>21d) with no contact |

---

## Design principles

- **Sources are sacred.** Raw transcripts and PDFs are never modified after ingestion.
- **Synthesis is append-only.** The wiki grows forward; history is never rewritten.
- **Incremental by default.** Nightly synthesis only processes the delta — never reruns everything.
- **Context-efficient.** CLAUDE.md files are lean doc-indexes, not instruction manuals. Root file stays under 70 lines.
- **Bootstrappable.** No external dependencies at setup. Works from any machine with the vault.

---

## Prerequisites

- [Claude Code](https://claude.ai/code) (CLI)
- [Obsidian](https://obsidian.md) (optional for Day 1, required for mobile sync)
- [Granola](https://granola.ai) configured to export transcripts to `Inbox/transcripts/`
- Python + `pip install markitdown` (for PDF ingestion)
- An always-on Mac (for nightly automation via `run-nightly.sh`)

---

## Quickstart

```bash
# 1. Create a local vault directory (NOT inside Google Drive or iCloud)
mkdir ~/my-personal-os && cd ~/my-personal-os

# 2. Open Claude Code here
claude

# 3. Paste the contents of personal-os-bootstrap.md into the prompt
# Follow the phase-by-phase setup — Claude will guide you through it
```

The bootstrap runs in 11 phases and takes ~20 minutes to scaffold. At the end you'll have a fully wired vault and a personalization checklist.

**Before your first real session**, complete the personalization checklist in Phase 10:
- Fill in your name, company, start date
- Add your team roster to `People/team.md`
- Set your 30/60/90 goals in `GOALS.md`
- Create your first 1on1 folders with `/new-1on1 [name]`

---

## Architecture

```
vault/
├── CLAUDE.md              ← Root context (≤70 lines) — always loaded
├── GOALS.md               ← 30/60/90 objectives
├── HEARTBEAT.md           ← Current focus, upcoming meetings, synthesis state
├── Inbox/                 ← Drop zone: transcripts, PDFs, URLs
├── 1on1s/[Name]/          ← Per-person: profile, session notes, open loops
├── Meetings/              ← Non-1on1 meeting notes and action items
├── Projects/              ← Active initiatives with inputs and drafts
├── People/                ← Team roster + stakeholder map (with last_contact)
├── Knowledge/
│   ├── sources/           ← Immutable annotated sources
│   └── wiki/              ← Append-only synthesized knowledge
├── Data/
│   ├── open-loops.json    ← Structured commitments with priority + due dates
│   ├── decisions.json     ← Decision log
│   └── synthesis-log.json ← Incremental processing ledger (hash-based)
├── Workflows/             ← Playbooks for each workflow
├── Templates/             ← Scaffolds for 1on1 sessions, summaries, person folders
├── profile/
│   └── preferences.md     ← Adaptive briefing preferences (auto-tuned weekly)
└── .claude/commands/      ← Slash commands: /daily-briefing, /cascade, etc.
```

### Three-tier immutability

```
Sources (sacred, never modified)
  ↓  annotation only
Summaries (write-once, regeneratable)
  ↓  append-only connections
Synthesis (wiki + logs, grows forward)
```

---

## People tracking

Every stakeholder gets a `Last contact` field that nightly synthesis updates automatically when a session note is processed. The daily briefing flags anyone overdue:

- Direct reports: flag if no contact in >14 days
- Stakeholders: flag if no contact in >21 days

Format: `"Haven't connected with [Name] in X days — open loops: N"`

---

## Mobile

Obsidian Sync for cross-device access. Set up separately — the vault runs fine without it on Day 1. Telegram integration (`/telegram:configure` in Claude Code) enables quick capture and briefing delivery to your phone without opening Obsidian.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

This is a meta prompt, not a deployable application. The most valuable contributions are tested improvements to the workflow playbooks, slash commands, and data model — especially things you've run in production and found wanting.

---

## License

MIT — see [LICENSE](LICENSE).

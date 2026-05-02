# Personal OS

**An AI-powered Chief of Staff for your Obsidian vault.**

Personal OS is a bootstrap meta prompt that turns Claude Code + Obsidian into a second brain built for leaders who are information-dense and time-poor. Run one setup script, paste one file, and you have a system that processes your meetings, tracks every open loop, monitors your relationships, and briefs you every morning. Automatically.

---

## What it does

### Runs automatically

| When | What happens |
|------|-------------|
| 2am nightly | New transcripts processed into summaries, commitments extracted to open loops, wiki connections made, patterns flagged, indexes refreshed |
| 5am daily | Morning brief generated: open loops, today's meetings, recent decisions, relationship health, coaching insight |
| Sunday 8pm | Week-ahead brief generated: 7-day calendar scan, meetings needing prep flagged, focus blocks suggested for deep-work loops |

### On demand

| Command | What it does |
|---------|-------------|
| `/personal-os-1on1-prep [name]` | Pre-read with open loops, last sessions, and a probing question you haven't asked yet |
| `/personal-os-cascade` | Draft weekly updates for direct reports, cross-functional partners, and the C-suite |
| `/personal-os-open-loops [filter]` | Review commitments filtered by person, project, priority, or staleness |
| `/personal-os-career-evidence` | Review captured accomplishments, star entries, generate a brag doc |
| `/personal-os-week-ahead` | Run the week-ahead review any time, not just Sunday |

---

## Design principles

- **Sources are sacred.** Raw transcripts and PDFs are never modified after ingestion.
- **Synthesis is append-only.** The wiki grows forward; history is never rewritten.
- **Index-first.** Every directory has a `_index.md`. Workflows read the index, then only the specific files they need. No full directory scans.
- **Incremental by default.** Nightly synthesis only processes the delta. It never reruns everything.
- **Context-efficient.** Each tier is loaded at the right abstraction level. A daily briefing costs ~3k tokens in context, not 50k.

### Why three-tier immutability

Raw meeting transcripts run 5,000–15,000 tokens each. The three tiers solve context cost while preserving auditability:

| Tier | Examples | Token cost | Rule |
|------|----------|------------|------|
| Sources | Transcripts, PDFs, raw URLs | 5k–15k each | Immutable after ingestion |
| Summaries | Session summaries, source annotations | 300–800 each | Write-once, regeneratable |
| Synthesis | Wiki, profiles, open-loops.json | 100–400 per entry | Append-only, never rewritten |

Workflows load summaries and synthesis, not sources. If synthesis logic improves, any summary can be regenerated from its immutable source.

---

## Prerequisites

- [Claude Code](https://claude.ai/code) (CLI)
- [Obsidian](https://obsidian.md) (optional for Day 1, required for mobile sync)
- Python + `pip install markitdown` (for PDF ingestion)
- An always-on Mac (for nightly automation)
- One AI note-taking tool (see below)

### Supported transcript tools

| Tool | Setup |
|------|-------|
| [Granola](https://granola.ai) | Configure export folder to `Inbox/transcripts/` |
| [Fireflies.ai](https://fireflies.ai) | Webhook or Zapier → save to `Inbox/transcripts/` |
| [Zoom AI Companion](https://zoom.us) | Zoom MCP or manual export from zoom.us/recording |
| [Otter.ai](https://otter.ai) | Download transcript as .txt → `Inbox/transcripts/` |
| [Fathom](https://fathom.video) | Auto-email summary → script to `Inbox/transcripts/` |

`setup.sh` will prompt you to choose and configure your tool.

---

## Quickstart

```bash
# Clone and run setup (macOS)
git clone https://github.com/jackolicious/personal-os.git
cd personal-os
bash setup.sh
```

`setup.sh` checks prerequisites, creates your vault at a path you choose, wires up the launchd jobs for 5am briefing and 2am synthesis, and walks you through transcript tool configuration. It takes about 2 minutes.

Then:

```bash
cd ~/personal-os   # or wherever you chose
claude
# Paste the contents of personal-os-bootstrap.md into the prompt
# Follow phases 1–11 (~20 minutes)
```

**Before your first real session:**
- Fill in your name, company, start date
- Add your team roster to `People/team.md`
- Set your 30/60/90 goals in `GOALS.md`
- Define your strategic pillars in `PILLARS.md`
- Create your first 1on1 folders with `/personal-os-new-1on1 [name]`

---

## Automation

Three jobs run unattended on an always-on Mac:

| Time | Job | What it does |
|------|-----|--------------|
| 2:00 AM | Nightly synthesis | Processes new transcripts/PDFs, updates wiki, flags patterns, refreshes all `_index.md` files |
| 5:00 AM | Daily briefing | Generates `_system/briefings/YYYY-MM-DD.md` from current state |
| Sunday 8:00 PM | Week-ahead | Generates `_system/briefings/week-ahead-YYYY-MM-DD.md` with calendar scan and focus block suggestions |

All three run inside a single `run-nightly.sh` loop. `setup.sh` also installs a launchd plist as a fallback if the terminal session is closed.

**Required Mac setting:** System Settings → Battery → Options → "Prevent automatic sleeping when on power adapter"

---

## People tracking

Every stakeholder has a `Last contact` field updated automatically when a session note is processed. The daily briefing flags anyone overdue:

- Direct reports: more than 14 days without contact
- Stakeholders: more than 21 days without contact

Output: `"Haven't connected with [Name] in X days — open loops: N"`

---

## Architecture

```
vault/
├── CLAUDE.md              ← Root context (70 lines max, always loaded)
├── GOALS.md               ← 30/60/90 objectives
├── HEARTBEAT.md           ← Current focus, upcoming meetings, synthesis state
├── PILLARS.md             ← Ongoing strategic focus areas with keywords
├── BACKLOG.md             ← Ideas and feature requests, reviewed monthly
├── Inbox/                 ← Drop zone: transcripts, PDFs, URLs; archive/ holds processed originals
├── 1on1s/
│   ├── _index.md          ← All people: last session, session count, last contact
│   └── [Name]/
│       ├── sessions/
│       │   └── _index.md  ← Session list: date, topic, summary link
│       └── ...
├── Meetings/
│   └── _index.md          ← Meeting list: date, title, participants, action items
├── Projects/              ← Active initiatives
├── People/                ← Team roster + stakeholder map (with last_contact)
├── Knowledge/
│   ├── sources/           ← Immutable annotated sources
│   └── wiki/
│       └── _index.md      ← Wiki pages: concepts, sources, last updated
├── Interviews/
│   ├── _index.md          ← Active roles: company, stage, status
│   └── [Role]/
│       ├── role-context.md
│       ├── question-bank.md
│       └── notes/
├── _system/               ← System-managed (do not edit directly)
│   ├── data/
│   │   ├── open-loops.json      ← Commitments with priority, pillar, and due dates
│   │   ├── decisions.json       ← Decision log with review dates
│   │   ├── career-evidence.json ← Captured feedback, outcomes, growth moments
│   │   └── synthesis-log.json   ← Incremental processing ledger (hash-based)
│   ├── workflows/          ← Playbooks for each workflow
│   ├── briefings/          ← Auto-generated daily and week-ahead briefings
│   ├── templates/          ← Scaffolds for sessions, summaries, person folders
│   └── logs/               ← Automation logs
├── profile/
│   ├── preferences/        ← Modular preference files, auto-tuned over time
│   └── career/             ← Brag docs saved here
├── run-nightly.sh         ← Persistent loop: 2am synthesis, 5am briefing, Sunday 8pm week-ahead
└── .claude/commands/      ← Slash commands: /personal-os-daily-briefing, /personal-os-cascade, etc.
```

---

## Mobile

Obsidian Sync for cross-device access. Set it up when ready. The vault works fine without it on Day 1. For quick capture and briefing delivery to your phone, configure Telegram (`/telegram:configure` in Claude Code).

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

This is a meta prompt, not a deployable app. The most valuable contributions are workflow and data model improvements you've actually run in production.

---

## License

MIT. See [LICENSE](LICENSE).

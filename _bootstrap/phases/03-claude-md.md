# Phase 3: CLAUDE.md Hierarchy
_Depends on: Phase 1 (directories must exist)_

### `CLAUDE.md` (root — MUST stay under 70 lines)

```markdown
# [YOUR NAME] Personal OS

## Identity
**Role:** Head of Product | **Company:** [COMPANY] | **Start:** [DATE]

## System Map
| Directory | Purpose |
|-----------|---------|
| `Inbox/` | Raw inputs — links, PDFs, transcripts, scratch |
| `1on1s/` | Per-person: profile, open loops, session notes |
| `Meetings/` | Summaries + master action item list |
| `Projects/` | Active initiatives |
| `Knowledge/` | Sources (immutable) + wiki (synthesized) |
| `People/` | Team roster + stakeholder map |
| `Interviews/` | Active roles: per-role context, question bank, interview notes |
| `profile/` | My preferences and working style (for tuning) |
| `_system/` | System-maintained: data, logs, briefings, templates, workflows |

## Always Load
- `GOALS.md` — current objectives
- `HEARTBEAT.md` — current focus and context
- `PILLARS.md` — ongoing strategic focus areas
- `People/team.md` — roster with handles
- `profile/preferences/synthesis.md` — synthesis style and what to flag

## Team
<!-- FILL IN: name, title, slack handle, relationship -->
| Name | Role | Slack | Notes |
|------|------|-------|-------|
| | | | Direct report |
| | | | Direct report |

## Slack Channels
<!-- FILL IN -->
| Channel | Purpose |
|---------|---------|
| #product | Product team |
| #leadership | Exec comms |

## Commands
| Say | Does |
|-----|------|
| `/personal-os-daily-briefing` | Generate daily coaching briefing with open loops + recommendations |
| `/personal-os-process-inbox` | Process all new Inbox items |
| `/personal-os-cascade` | Start weekly Cascade workflow |
| `/personal-os-1on1-prep [name]` | Prep for a 1on1 |
| `/personal-os-ingest-url [url]` | Fetch, annotate, file a URL |
| `/personal-os-nightly` | Run synthesis manually |
| `/personal-os-open-loops [filter?]` | Review open loops |
| `/personal-os-new-1on1 [name]` | Create 1on1 session |
| `/personal-os-new-interview-role [role]` | Open a new interview role folder |
| `/personal-os-interview-prep [role]` | Generate prep brief for next interview |

## Model routing
| Task | Model |
|------|-------|
| Extract / annotate / triage | `claude-haiku-4-5` — one subprocess per file |
| Synthesize / reason / draft | `claude-sonnet-4-6` — reads structured outputs only |

## Rules
- Check `_system/data/synthesis-log.json` before processing any file
- Never modify files in `Knowledge/sources/` or `Inbox/transcripts/`
- Open loops: append only — archive, never delete
- Wiki pages: append dated sections, never rewrite core content
- Load `profile/preferences/synthesis.md` for any briefing or synthesis; workflows load their own specific preference module
- `_system/` is managed by automation — do not edit files there directly
```

### `Inbox/CLAUDE.md`

```markdown
# Inbox

Raw inputs only. Nothing here is processed or synthesized yet.

## Structure
| Folder | Contains | Process with |
|--------|---------|--------------|
| `links/` | .txt or .md files with one URL each | `/personal-os-ingest-url` |
| `pdfs/` | Raw PDFs awaiting conversion | `_system/workflows/pdf-ingestion.md` |
| `transcripts/` | Meeting transcripts (see sources below) | `_system/workflows/meeting-notes.md` |
| `scratch/` | Fleeting notes, unstructured | `/personal-os-process-inbox` |
| `archive/` | Processed originals (read-only) — never reprocessed | — |

## Supported transcript sources
All tools export to `Inbox/transcripts/` as `.md` or `.txt` files.

| Tool | How to get files here |
|------|-----------------------|
| **Granola** | Configure export folder to `Inbox/transcripts/` in Granola settings |
| **Fireflies** | Set up Zapier/webhook to POST summaries → save to `Inbox/transcripts/` |
| **Zoom AI Companion** | Use Zoom MCP (`/zoom-transcript`) or download summary from zoom.us/recording |
| **Otter.ai** | Export transcript as TXT/MD → move to `Inbox/transcripts/` |
| **Fathom** | Enable auto-email summary → forward to a script that saves to `Inbox/transcripts/` |

File naming convention: `YYYY-MM-DD [Meeting Title].md`

## Processing rules
- Never modify originals — outputs go to `Meetings/` or `1on1s/`
- PDFs: convert with markitdown → annotate → file to `Knowledge/sources/`
- After processing any file: log it in `_system/data/synthesis-log.json`, then move the original to `Inbox/archive/[subfolder]/`
- Originals in `archive/` are immutable — they are never modified or reprocessed
- If unsure where something belongs, file to `scratch/` and flag in `HEARTBEAT.md`
- Read `_index.md` first to see what's already been processed before scanning any subfolder
```

### `1on1s/CLAUDE.md`

````markdown
# 1on1s

One subfolder per person. Direct reports and key stakeholders.

## Index
Read `_index.md` before any other operation. It lists all people, last session date,
session count, and last contact — enabling targeted reads without scanning the directory.

## Person folder structure
```
[Person Name]/
  CLAUDE.md       ← person context (load for any query about them)
  profile.md      ← role, background, working style, key themes
  open-loops.md   ← active commitments and follow-ups (append-only)
  sessions/
    _index.md              ← session index: date, key topic, summary link (auto-maintained)
    YYYY-MM-DD.md          ← raw notes (immutable after session)
    YYYY-MM-DD-summary.md  ← processed summary (structured)
```

## Creating a new person folder
Use `/personal-os-new-1on1 [name]` — creates from `_system/templates/person-folder.md`

## Query patterns
- "What's open with Alex?" → read `1on1s/_index.md`, then Alex/open-loops.md + last summary only
- "Prep my 1on1 with Alex" → `/personal-os-1on1-prep Alex`
- "What themes keep coming up with the team?" → read `1on1s/_index.md`, then each person's profile.md
````

### `Meetings/CLAUDE.md`

````markdown
# Meetings

All non-1on1 meetings. Indexed by date and title.

## Structure
```
YYYY-MM-DD-[slug]/
  raw.md      ← original Granola transcript (immutable)
  summary.md  ← processed: decisions, actions, context
action-items.md  ← master list across all meetings (structured)
```

## action-items.md format
```
- [ ] [Action] | Owner: [Name] | Due: [Date] | Priority: [critical|high|medium|low] | Source: [[YYYY-MM-DD-meeting]]
```
Completed items move to `## Completed` section — never deleted.
````

### `Projects/CLAUDE.md`

````markdown
# Projects

## Active Projects
| Project | Status | Next Action | Owner |
|---------|--------|-------------|-------|
| product-strategy | In progress | Draft v0 themes | [NAME] |

## Project folder structure
```
[project-name]/
  CLAUDE.md    ← project context and status
  inputs/      ← excerpts from 1on1s and research feeding this project
  drafts/      ← versioned drafts (v0, v1, etc.)
  [final].md   ← current canonical version
```
````

### `Knowledge/CLAUDE.md`

````markdown
# Knowledge Base

Karpathy-style: sources are immutable, wiki is LLM-synthesized and append-only.

## Layers
| Layer | Path | Rules |
|-------|------|-------|
| Sources | `sources/` | Immutable after annotation. Never modified. |
| Wiki | `wiki/` | Append-only. Dated sections. Never rewrite. |

## Source annotation format
Every file in `sources/` has a metadata block at top:
```
---
source_type: [pdf | url | transcript | note]
original: [filename or URL]
processed_at: [date]
relevance: [product-strategy | market | people | process | other]
key_concepts: [comma-separated]
connections: [wiki pages this relates to]
open_questions: [questions this raises]
---
```

## Wiki page format
```markdown
# [Concept]

## Definition
[Written at first creation — rarely changed]

## Evidence & Connections
### [YYYY-MM-DD]
- Source: [[source-file]]
- Connection: [why this relates]
- Inference: [what this implies]
```

## Synthesis rule
When connecting a new source to the wiki, ALWAYS append a new dated section.
Never rewrite existing sections.
````

### `People/CLAUDE.md`

```markdown
# People

## Files
- `team.md` — direct reports and key relationships
- `stakeholders.md` — cross-functional map

## Stakeholder entry format
### [Name]
- Role: [Title] at [Function]
- Relationship: [collaborator | dependency | sponsor | inform-only]
- Slack: @[handle]
- Last contact: YYYY-MM-DD
- Key context: [one line]
```

### `Interviews/CLAUDE.md`

````markdown
# Interviews

Active roles under consideration. One subfolder per role.

## Index
See `_index.md` for role list: company, stage, status, last activity.

## Role folder structure
```
Interviews/[Role Name]/
├── role-context.md   ← Company background, JD summary, why interested
├── question-bank.md  ← Questions I want to ask (curated across prior interviews)
└── notes/
    └── YYYY-MM-DD-[interviewer].md  ← Per-conversation notes
```

## Commands
- `/personal-os-new-interview-role [role]` — open a new role folder
- `/personal-os-interview-prep [role]` — generate prep brief for next interview

## Question bank format
Questions are tagged by type so prep can pull the most relevant:
- `[culture]` — values, team dynamics, how decisions get made
- `[strategy]` — product direction, competitive position, roadmap
- `[role]` — scope, success metrics, what good looks like
- `[growth]` — learning opportunities, mentorship, trajectory
````

### `_system/workflows/CLAUDE.md`

```markdown
# Workflows

| Workflow | When to use | File |
|----------|------------|------|
| daily-briefing | Each morning | `daily-briefing.md` |
| cascade | Weekly, Friday | `cascade.md` |
| meeting-notes | After any meeting with transcript | `meeting-notes.md` |
| 1on1-prep | Before any 1on1 | `1on1-prep.md` |
| pdf-ingestion | When a PDF lands in Inbox/pdfs/ | `pdf-ingestion.md` |
| nightly-synthesis | Nightly at 2am via loop | `nightly-synthesis.md` |
| preference-tuning | Adaptive schedule (see nightly) | `preference-tuning.md` |
```

### `profile/CLAUDE.md`

```markdown
# Profile

Contains my working preferences and style — modular files loaded per workflow.

## Files
| File | Contents | Loaded by |
|------|----------|-----------|
| `preferences/synthesis.md` | Synthesis depth, format, what to always flag | Root CLAUDE.md (always) |
| `preferences/briefing.md` | Coaching tone, open loop display order, length | `daily-briefing.md` |
| `preferences/writing-style.md` | Voice, tone, format, characteristic phrases | `cascade.md` |
| `preferences/1on1.md` | Focus areas for 1on1 synthesis | `1on1-prep.md` |
| `preferences/knowledge.md` | Relevance filters — update weekly | `nightly-synthesis.md` |

Preference tuning updates individual modules — never the whole set at once.
```

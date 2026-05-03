# Personal OS — System Context

## Context

I am [YOUR NAME], Head of Product at [COMPANY], starting [DATE].

This system is my Chief of Staff second brain and personal knowledge management coach.
Primary use cases:
- Process meeting transcripts (Granola / Fireflies / Zoom MCP / Otter → Inbox/transcripts/)
- Convert PDFs to annotated Markdown via markitdown
- Track open loops per person and per project — reviewed daily
- Generate a daily briefing with coaching recommendations
- Run weekly Cascade updates (down, lateral, up) using elicitation
- Assemble product strategy from 1on1 inputs and market research
- Make nightly inferences and connections across all new content — incrementally
- Tune to my preferences on an adaptive schedule (daily → weekly over 4 weeks)

Design constraints:
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

**Context efficiency**: Workflows load summaries and synthesis — not sources.
A `/personal-os-1on1-prep` that reads 3 summaries uses ~2k tokens, not 45k.

**Reproducibility**: Sources never change, so any summary can be regenerated from
ground truth if synthesis logic improves.

**Incremental trust**: The hash-based synthesis-log.json only works if sources are
immutable. Mutable sources would require reprocessing everything on every change.

**Compounding**: Each tier accumulates independently. New sessions create summaries;
summaries feed wiki pages; wiki pages compound into strategic themes. A single change
anywhere lower would invalidate the layers above it.

Automation runs nightly via persistent terminal loop on an always-on Mac.

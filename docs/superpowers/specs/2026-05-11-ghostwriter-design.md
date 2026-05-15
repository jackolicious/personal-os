# Ghostwriter + Content Pipeline Design
_Date: 2026-05-11_

## Problem

Writing in a consistent, human voice across Slack posts, cascade drafts, PRDs, and external comms takes time and mental energy. AI-generated drafts are fast but recognizable. There is no existing Personal OS feature that writes in Jack's voice or removes AI traces from text.

## Goals

- Generate first drafts from a short prompt, in Jack's voice
- Polish existing text into Jack's voice and remove AI writing patterns
- Support four content types with appropriate tone per type: Slack, cascade, PRD, external comms
- Trigger automatically whenever Jack asks for writing help, no explicit command required
- Style is synthesized from real writing samples, not pre-seeded descriptions

## Out of scope

- Automatic generation of content without a prompt (no nightly trigger)
- Sending or posting content anywhere (output is text only)
- Learning from new writing over time (style guide is updated manually via `/ghostwriter-init`)

## Design principles

- Style comes entirely from the samples. No voice descriptions baked into workflow files.
- The only pre-seeded content is the humanizer pass, which is universal across all writing.
- One command to remember. Proactive invocation handles the rest.
- Ask once when ambiguous, then proceed.

---

## Architecture

### Commands

Two commands:

**`/ghostwriter`** (primary)
Invoked explicitly or proactively whenever Jack asks for writing help. Handles both draft and polish modes.

**`/ghostwriter-init`**
Reads `Knowledge/writing/samples.md` and synthesizes `Knowledge/writing/style-guide.md`. Run once after setup, and re-run whenever samples change.

### Trigger (proactive invocation)

The `personal-os-ghostwriter` skill description is written so Claude invokes it automatically on any writing request: "draft a Slack post", "help me write a cascade", "polish this email", etc. Explicit `/ghostwriter` is optional.

### Command flow

```
Input received
  │
  ├─ Detect mode
  │    Short prompt → draft mode (generate from scratch)
  │    Substantial text → polish mode (rewrite in Jack's voice)
  │    Ambiguous → ask once
  │
  ├─ Detect content type
  │    Keywords: slack / cascade / PRD / external
  │    Draft mode: infer from prompt or ask
  │    Polish mode: infer from text or ask
  │
  ├─ Read Knowledge/writing/style-guide.md
  │
  ├─ Generate or rewrite content
  │    Apply base style from style guide
  │    Apply per-type tone overlay
  │
  └─ Humanizer pass
       Scan for AI writing patterns
       Remove: em dashes, rule of three, inflated symbolism, AI vocabulary, vague attributions
       Add: personality, opinions, specific details, rhythm variation
       Output final draft
```

### Content type tone overlays

Applied on top of base style, not instead of it:

- **Slack**: informal, lower friction, ICYMI/FYI framing ok, shorter
- **External comms**: selling voice, lead with value, tighter, outcome-first
- **Cascade/PRD**: structured, substantive bullets, goal + anti-goal framing where appropriate
- **Generic** (default): base style only, no special overlay

All types: brevity wins, bullets beat paragraphs, correct grammar and spelling.

---

## Style guide synthesis (ghostwriter-init)

1. Read `Knowledge/writing/samples.md`
2. Analyze samples to extract voice, structural patterns, and tone signals
3. Write a compact style guide to `Knowledge/writing/style-guide.md`
4. The guide is human-readable and directly editable

The style guide content is entirely derived from the samples. No template or pre-written descriptions.

---

## File layout

```
Knowledge/
  writing/
    samples.md                    # raw writing samples (user-maintained)
    style-guide.md                # synthesized by ghostwriter-init

_system/
  workflows/
    ghostwriter.md                # main command logic
    ghostwriter-init.md           # style synthesis logic

~/.claude/skills/
  personal-os-ghostwriter/
    SKILL.md                      # trigger + reads ghostwriter.md
  personal-os-ghostwriter-init/
    SKILL.md                      # reads ghostwriter-init.md
```

---

## Testing

- Run `/ghostwriter-init` against samples, verify `style-guide.md` is populated and human-readable
- Draft mode: prompt "write a Slack post about X", verify output matches voice and is not AI-sounding
- Polish mode: paste AI-generated text, verify humanizer pass removes tells
- Content type detection: verify slack/cascade/PRD/external overlays apply correctly
- Ambiguous input: verify single clarifying question fires before output
- Proactive trigger: verify skill invokes automatically on natural writing requests without `/ghostwriter`

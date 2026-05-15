# Ghostwriter + Content Pipeline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a ghostwriter command to Personal OS that generates or polishes writing in Jack's voice, triggers proactively on any writing request, and removes AI writing patterns via a humanizer pass.

**Architecture:** Two slash commands (`.claude/commands/`) backed by two workflow files (`_system/workflows/`). A style guide (`Knowledge/writing/style-guide.md`) is synthesized once from raw samples and read at runtime. Bootstrap phase files and tests are updated so a fresh install includes the feature.

**Tech Stack:** Bash (tests), Markdown (workflow files, command files), Personal OS bootstrap conventions

---

## File Map

**Create (runtime — not committed, gitignored):**
- `Knowledge/writing/samples.md` — raw writing samples
- `_system/workflows/ghostwriter-init.md` — style synthesis logic
- `_system/workflows/ghostwriter.md` — draft/polish/humanize logic
- `.claude/commands/personal-os-ghostwriter-init.md` — init slash command
- `.claude/commands/personal-os-ghostwriter.md` — main slash command

**Modify (committed):**
- `_bootstrap/phases/06-workflows.md` — add ghostwriter-init and ghostwriter workflow definitions
- `_bootstrap/phases/07-commands.md` — add ghostwriter-init and ghostwriter command definitions
- `_bootstrap/tests/06-workflows.sh` — add tests for both workflows
- `_bootstrap/tests/07-commands.sh` — add tests for both commands

---

## Task 1: Save writing samples

**Files:**
- Create: `Knowledge/writing/samples.md`

- [ ] **Step 1: Create Knowledge/writing/ directory if needed**

```bash
mkdir -p "/Users/jackhirsch/Library/CloudStorage/GoogleDrive-jack.hirsch@gmail.com/My Drive/Personal OS/Knowledge/writing"
```

- [ ] **Step 2: Create samples file**

The samples are in this brainstorming session — Jack's message that begins with `# Writing Samples — Jack Hirsch`. Copy that entire message verbatim as the file content. It contains 11 labeled samples (Farewell Email, Farewell Slack, AI Product Leadership Event, Weekly Status Update Philosophy, RTB Integration Review, Team Composition and Agile, GCP Marketplace Constraints, Access Certification Discovery, AI Agent Setup, Developer Experience Feedback, CEC Feedback).

Create `Knowledge/writing/samples.md` with that full content. If executing in a fresh session without that message in context, ask Jack to re-paste the samples before proceeding.

- [ ] **Step 3: Verify file exists and has content**

```bash
wc -l "/Users/jackhirsch/Library/CloudStorage/GoogleDrive-jack.hirsch@gmail.com/My Drive/Personal OS/Knowledge/writing/samples.md"
```

Expected: line count well over 100 (the samples are long).

---

## Task 2: Add ghostwriter-init workflow (TDD)

**Files:**
- Modify: `_bootstrap/tests/06-workflows.sh` — add failing tests
- Modify: `_bootstrap/phases/06-workflows.md` — add workflow definition
- Create: `_system/workflows/ghostwriter-init.md` — runtime file

- [ ] **Step 1: Add failing tests to 06-workflows.sh**

Open `_bootstrap/tests/06-workflows.sh`. Find the `# ---------------------------------------------------------------------------` block for `meeting-prep` (around line 412). Append the following AFTER the meeting-prep section and BEFORE the `# ---------------------------------------------------------------------------` forbidden patterns block:

```bash
# ---------------------------------------------------------------------------
# ghostwriter-init
# ---------------------------------------------------------------------------
echo "-- ghostwriter-init --"

check_present "$FILE" "ghostwriter-init" \
  "ghostwriter-init: workflow file defined"

check_present "$FILE" "ghostwriter-init\.md" \
  "ghostwriter-init: references workflow file path"

check_present "$FILE" "Knowledge/writing/samples\.md" \
  "ghostwriter-init: reads Knowledge/writing/samples.md"

check_present "$FILE" "Knowledge/writing/style-guide\.md" \
  "ghostwriter-init: writes Knowledge/writing/style-guide.md"

check_present "$FILE" "NO_SAMPLES" \
  "ghostwriter-init: NO_SAMPLES graceful degradation defined"

echo ""
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd "/Users/jackhirsch/Library/CloudStorage/GoogleDrive-jack.hirsch@gmail.com/My Drive/Personal OS" && bash _bootstrap/tests/06-workflows.sh 2>&1 | tail -20
```

Expected: multiple FAIL lines for ghostwriter-init, summary shows failures.

- [ ] **Step 3: Add ghostwriter-init workflow to 06-workflows.md**

Open `_bootstrap/phases/06-workflows.md`. Append the following at the very end of the file:

```markdown

### `_system/workflows/ghostwriter-init.md`

```markdown
# Ghostwriter Init Workflow

## Model: Sonnet
Style synthesis requires reasoning.

## Trigger
On-demand: `/personal-os-ghostwriter-init`

---

## Step 1: Load samples

Read `Knowledge/writing/samples.md`.
If the file doesn't exist:
  Output: "NO_SAMPLES — create Knowledge/writing/samples.md with writing examples first."
  Stop.

## Step 2: Analyze samples

Read all samples carefully. For each sample, observe:
- How sentences are structured
- When bullets vs prose is used
- How messages open and close
- Tone: formal vs informal, warmth level, use of humor
- Recurring phrases or constructions
- How opinions are expressed
- Typical message length by content type

Derive observations entirely from the samples. Do not apply generic voice frameworks.

## Step 3: Synthesize style guide

Write a compact style guide to `Knowledge/writing/style-guide.md`.

Requirements:
- Under 500 words
- Derived entirely from the samples — no generic writing advice
- Specific enough to reproduce the voice in new writing
- Human-readable and directly editable
- Organized as: Voice, Structure, Tone, Per-context notes

## Step 4: Confirm

Output: "Style guide written to Knowledge/writing/style-guide.md"
```
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd "/Users/jackhirsch/Library/CloudStorage/GoogleDrive-jack.hirsch@gmail.com/My Drive/Personal OS" && bash _bootstrap/tests/06-workflows.sh 2>&1 | grep -E "ghostwriter-init|Results"
```

Expected: all ghostwriter-init lines show PASS, Results shows 0 failed.

- [ ] **Step 5: Create runtime workflow file**

Create `_system/workflows/ghostwriter-init.md` with the same content as what was added inside the code fence in Step 3 (the inner markdown — the actual workflow, not the outer bootstrap wrapper):

```markdown
# Ghostwriter Init Workflow

## Model: Sonnet
Style synthesis requires reasoning.

## Trigger
On-demand: `/personal-os-ghostwriter-init`

---

## Step 1: Load samples

Read `Knowledge/writing/samples.md`.
If the file doesn't exist:
  Output: "NO_SAMPLES — create Knowledge/writing/samples.md with writing examples first."
  Stop.

## Step 2: Analyze samples

Read all samples carefully. For each sample, observe:
- How sentences are structured
- When bullets vs prose is used
- How messages open and close
- Tone: formal vs informal, warmth level, use of humor
- Recurring phrases or constructions
- How opinions are expressed
- Typical message length by content type

Derive observations entirely from the samples. Do not apply generic voice frameworks.

## Step 3: Synthesize style guide

Write a compact style guide to `Knowledge/writing/style-guide.md`.

Requirements:
- Under 500 words
- Derived entirely from the samples — no generic writing advice
- Specific enough to reproduce the voice in new writing
- Human-readable and directly editable
- Organized as: Voice, Structure, Tone, Per-context notes

## Step 4: Confirm

Output: "Style guide written to Knowledge/writing/style-guide.md"
```

- [ ] **Step 6: Commit bootstrap changes so far**

```bash
cd "/Users/jackhirsch/Library/CloudStorage/GoogleDrive-jack.hirsch@gmail.com/My Drive/Personal OS" && git add _bootstrap/phases/06-workflows.md _bootstrap/tests/06-workflows.sh && git commit -m "feat: add ghostwriter-init workflow to bootstrap"
```

---

## Task 3: Add ghostwriter-init command (TDD)

**Files:**
- Modify: `_bootstrap/tests/07-commands.sh` — add failing tests
- Modify: `_bootstrap/phases/07-commands.md` — add command definition
- Create: `.claude/commands/personal-os-ghostwriter-init.md` — runtime file

- [ ] **Step 1: Add failing tests to 07-commands.sh**

Open `_bootstrap/tests/07-commands.sh`. Find the `echo ""` after the `personal-os-meeting-prep` section (around line 168). Append the following before the `# --- Forbidden references ---` block:

```bash
# ---------------------------------------------------------------------------
# personal-os-ghostwriter-init
# ---------------------------------------------------------------------------
echo "-- personal-os-ghostwriter-init --"

check_present "$FILE" "personal-os-ghostwriter-init" \
  "ghostwriter-init: command defined"

check_present "$FILE" "ghostwriter-init\.md" \
  "ghostwriter-init: command references workflow"

echo ""
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd "/Users/jackhirsch/Library/CloudStorage/GoogleDrive-jack.hirsch@gmail.com/My Drive/Personal OS" && bash _bootstrap/tests/07-commands.sh 2>&1 | tail -10
```

Expected: FAIL lines for ghostwriter-init.

- [ ] **Step 3: Add command definition to 07-commands.md**

Open `_bootstrap/phases/07-commands.md`. Append the following at the very end:

```markdown

### `.claude/commands/personal-os-ghostwriter-init.md`

```markdown
Synthesize Jack's writing style guide from samples.

Run once after setup to generate Knowledge/writing/style-guide.md.
Re-run whenever Knowledge/writing/samples.md changes.

Follow _system/workflows/ghostwriter-init.md exactly.
```
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd "/Users/jackhirsch/Library/CloudStorage/GoogleDrive-jack.hirsch@gmail.com/My Drive/Personal OS" && bash _bootstrap/tests/07-commands.sh 2>&1 | grep -E "ghostwriter-init|Results"
```

Expected: all ghostwriter-init lines PASS.

- [ ] **Step 5: Create runtime command file**

Create `.claude/commands/personal-os-ghostwriter-init.md`:

```markdown
Synthesize Jack's writing style guide from samples.

Run once after setup to generate Knowledge/writing/style-guide.md.
Re-run whenever Knowledge/writing/samples.md changes.

Follow _system/workflows/ghostwriter-init.md exactly.
```

- [ ] **Step 6: Commit**

```bash
cd "/Users/jackhirsch/Library/CloudStorage/GoogleDrive-jack.hirsch@gmail.com/My Drive/Personal OS" && git add _bootstrap/phases/07-commands.md _bootstrap/tests/07-commands.sh && git commit -m "feat: add ghostwriter-init command to bootstrap"
```

---

## Task 4: Add ghostwriter workflow (TDD)

**Files:**
- Modify: `_bootstrap/tests/06-workflows.sh` — add failing tests
- Modify: `_bootstrap/phases/06-workflows.md` — add workflow definition
- Create: `_system/workflows/ghostwriter.md` — runtime file

- [ ] **Step 1: Add failing tests to 06-workflows.sh**

Open `_bootstrap/tests/06-workflows.sh`. Append the following after the ghostwriter-init section and before the forbidden patterns block:

```bash
# ---------------------------------------------------------------------------
# ghostwriter
# ---------------------------------------------------------------------------
echo "-- ghostwriter --"

check_present "$FILE" "ghostwriter\.md" \
  "ghostwriter: workflow file defined"

check_present "$FILE" "style-guide\.md" \
  "ghostwriter: reads style-guide.md"

check_present "$FILE" "DRAFT" \
  "ghostwriter: DRAFT mode defined"

check_present "$FILE" "POLISH" \
  "ghostwriter: POLISH mode defined"

check_present "$FILE" "slack" \
  "ghostwriter: slack content type defined"

check_present "$FILE" "external" \
  "ghostwriter: external content type defined"

check_present "$FILE" "em dash\|Em dash\|em-dash" \
  "ghostwriter: humanizer pass removes em dashes"

check_present "$FILE" "AI vocab\|AI writing\|delve\|utilize" \
  "ghostwriter: humanizer pass removes AI vocabulary"

echo ""
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd "/Users/jackhirsch/Library/CloudStorage/GoogleDrive-jack.hirsch@gmail.com/My Drive/Personal OS" && bash _bootstrap/tests/06-workflows.sh 2>&1 | tail -20
```

Expected: FAIL lines for ghostwriter.

- [ ] **Step 3: Add ghostwriter workflow to 06-workflows.md**

Open `_bootstrap/phases/06-workflows.md`. Append the following at the very end (after the ghostwriter-init section):

````markdown

### `_system/workflows/ghostwriter.md`

```markdown
# Ghostwriter Workflow

## Model: Sonnet

## Trigger
Proactively when Jack asks to write, draft, compose, or polish any content.
Explicitly via `/personal-os-ghostwriter`.

---

## Step 1: Load style guide

Read `Knowledge/writing/style-guide.md`.
If missing: output "Run /personal-os-ghostwriter-init first to generate your style guide." and stop.

## Step 2: Detect mode

Examine the input:
- Short prompt or instruction (under ~50 words, imperative or request form): DRAFT mode
- Substantial authored text (multiple sentences, clearly written content): POLISH mode
- Ambiguous: ask once — "Are you giving me a prompt to draft from, or text to polish?"

## Step 3: Detect content type

Look for signals in the input:
- "slack", "DM", "channel", "thread", "post" → slack
- "cascade", "all-hands", "town hall", "all hands" → cascade
- "PRD", "spec", "product requirements", "requirements doc" → prd
- "email", "external", "customer", "partner", "press release" → external

If no clear type signal:
- DRAFT mode: infer from context, default to generic if still unclear
- POLISH mode: ask once — "What type of content is this: slack, cascade, PRD, or external?"

## Step 4: Generate or rewrite

### DRAFT mode
Generate a first draft using:
- Base voice and structure from style guide
- Per-type overlay:
  - slack: informal, short, ICYMI/FYI framing ok, no formal sign-off needed
  - cascade: structured, serious, goal-oriented, key points in bullets
  - prd: headers and bullets, include goals and anti-goals where useful
  - external: selling voice, lead with value or outcome, tight
  - generic: base style only

### POLISH mode
Rewrite the provided text:
- Preserve core content and intent, not the original phrasing
- Apply base voice from style guide
- Apply same per-type overlay as above

## Step 5: Humanizer pass

Scan the draft and remove AI writing patterns:
- Em dashes: replace with a comma, period, or restructure the sentence
- Rule of three: vary the structure instead of always grouping in threes
- Inflated symbolism: "journey", "tapestry", "landscape" used metaphorically
- AI vocabulary: "delve", "foster", "leverage" (used generically), "utilize", "robust",
  "holistic", "seamlessly", "groundbreaking", "transformative" (used hyperbolically)
- Vague attributions: "studies show", "experts say", "research indicates"
- Excessive conjunctive transitions: "Furthermore,", "Moreover,", "Additionally,"
- Negative parallelisms: "not only X but also Y"
- Uniform sentence rhythm: vary length and structure

Then check for soul. If the draft reads like a press release or Wikipedia article, add:
- A specific opinion or reaction where appropriate
- First-person perspective where natural ("I think...", "Here's what I keep coming back to...")
- Concrete details over vague statements
- Rhythm variation: short punchy sentences mixed with longer analytical ones

## Step 6: Output

Print the final draft as clean text. No preamble. No "Here's your draft:". Just the content.
```
````

- [ ] **Step 4: Run test to verify it passes**

```bash
cd "/Users/jackhirsch/Library/CloudStorage/GoogleDrive-jack.hirsch@gmail.com/My Drive/Personal OS" && bash _bootstrap/tests/06-workflows.sh 2>&1 | grep -E "^(PASS|FAIL).*ghostwriter|Results"
```

Expected: all ghostwriter lines PASS.

- [ ] **Step 5: Create runtime workflow file**

Create `_system/workflows/ghostwriter.md` with the same inner content (copy from inside the code fence in Step 3):

```markdown
# Ghostwriter Workflow

## Model: Sonnet

## Trigger
Proactively when Jack asks to write, draft, compose, or polish any content.
Explicitly via `/personal-os-ghostwriter`.

---

## Step 1: Load style guide

Read `Knowledge/writing/style-guide.md`.
If missing: output "Run /personal-os-ghostwriter-init first to generate your style guide." and stop.

## Step 2: Detect mode

Examine the input:
- Short prompt or instruction (under ~50 words, imperative or request form): DRAFT mode
- Substantial authored text (multiple sentences, clearly written content): POLISH mode
- Ambiguous: ask once — "Are you giving me a prompt to draft from, or text to polish?"

## Step 3: Detect content type

Look for signals in the input:
- "slack", "DM", "channel", "thread", "post" → slack
- "cascade", "all-hands", "town hall", "all hands" → cascade
- "PRD", "spec", "product requirements", "requirements doc" → prd
- "email", "external", "customer", "partner", "press release" → external

If no clear type signal:
- DRAFT mode: infer from context, default to generic if still unclear
- POLISH mode: ask once — "What type of content is this: slack, cascade, PRD, or external?"

## Step 4: Generate or rewrite

### DRAFT mode
Generate a first draft using:
- Base voice and structure from style guide
- Per-type overlay:
  - slack: informal, short, ICYMI/FYI framing ok, no formal sign-off needed
  - cascade: structured, serious, goal-oriented, key points in bullets
  - prd: headers and bullets, include goals and anti-goals where useful
  - external: selling voice, lead with value or outcome, tight
  - generic: base style only

### POLISH mode
Rewrite the provided text:
- Preserve core content and intent, not the original phrasing
- Apply base voice from style guide
- Apply same per-type overlay as above

## Step 5: Humanizer pass

Scan the draft and remove AI writing patterns:
- Em dashes: replace with a comma, period, or restructure the sentence
- Rule of three: vary the structure instead of always grouping in threes
- Inflated symbolism: "journey", "tapestry", "landscape" used metaphorically
- AI vocabulary: "delve", "foster", "leverage" (used generically), "utilize", "robust",
  "holistic", "seamlessly", "groundbreaking", "transformative" (used hyperbolically)
- Vague attributions: "studies show", "experts say", "research indicates"
- Excessive conjunctive transitions: "Furthermore,", "Moreover,", "Additionally,"
- Negative parallelisms: "not only X but also Y"
- Uniform sentence rhythm: vary length and structure

Then check for soul. If the draft reads like a press release or Wikipedia article, add:
- A specific opinion or reaction where appropriate
- First-person perspective where natural ("I think...", "Here's what I keep coming back to...")
- Concrete details over vague statements
- Rhythm variation: short punchy sentences mixed with longer analytical ones

## Step 6: Output

Print the final draft as clean text. No preamble. No "Here's your draft:". Just the content.
```

- [ ] **Step 6: Commit**

```bash
cd "/Users/jackhirsch/Library/CloudStorage/GoogleDrive-jack.hirsch@gmail.com/My Drive/Personal OS" && git add _bootstrap/phases/06-workflows.md _bootstrap/tests/06-workflows.sh && git commit -m "feat: add ghostwriter workflow to bootstrap"
```

---

## Task 5: Add ghostwriter command (TDD)

**Files:**
- Modify: `_bootstrap/tests/07-commands.sh` — add failing tests
- Modify: `_bootstrap/phases/07-commands.md` — add command definition
- Create: `.claude/commands/personal-os-ghostwriter.md` — runtime file

- [ ] **Step 1: Add failing tests to 07-commands.sh**

Open `_bootstrap/tests/07-commands.sh`. Append the following after the ghostwriter-init section and before the `# --- Forbidden references ---` block:

```bash
# ---------------------------------------------------------------------------
# personal-os-ghostwriter
# ---------------------------------------------------------------------------
echo "-- personal-os-ghostwriter --"

check_present "$FILE" "personal-os-ghostwriter" \
  "ghostwriter: command defined"

check_present "$FILE" "ghostwriter\.md" \
  "ghostwriter: command references workflow"

check_present "$FILE" "ARGUMENTS" \
  "ghostwriter: command handles arguments"

check_present "$FILE" "proactively\|draft\|polish\|write" \
  "ghostwriter: command includes proactive trigger description"

echo ""
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd "/Users/jackhirsch/Library/CloudStorage/GoogleDrive-jack.hirsch@gmail.com/My Drive/Personal OS" && bash _bootstrap/tests/07-commands.sh 2>&1 | tail -10
```

Expected: FAIL lines for ghostwriter.

- [ ] **Step 3: Add command definition to 07-commands.md**

Open `_bootstrap/phases/07-commands.md`. Append the following at the very end:

```markdown

### `.claude/commands/personal-os-ghostwriter.md`

```markdown
Write in Jack's voice. Use proactively whenever Jack asks to write, draft, compose, or polish any communication: Slack posts, cascades, PRDs, emails, external comms. Trigger on: "draft a...", "write a...", "help me write...", "polish this...", "rewrite this...", or any writing request.

$ARGUMENTS may contain a prompt to draft from or text to polish.

Follow _system/workflows/ghostwriter.md exactly.
```
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd "/Users/jackhirsch/Library/CloudStorage/GoogleDrive-jack.hirsch@gmail.com/My Drive/Personal OS" && bash _bootstrap/tests/07-commands.sh 2>&1 | grep -E "^(PASS|FAIL).*ghostwriter|Results"
```

Expected: all ghostwriter lines PASS.

- [ ] **Step 5: Create runtime command file**

Create `.claude/commands/personal-os-ghostwriter.md`:

```markdown
Write in Jack's voice. Use proactively whenever Jack asks to write, draft, compose, or polish any communication: Slack posts, cascades, PRDs, emails, external comms. Trigger on: "draft a...", "write a...", "help me write...", "polish this...", "rewrite this...", or any writing request.

$ARGUMENTS may contain a prompt to draft from or text to polish.

Follow _system/workflows/ghostwriter.md exactly.
```

- [ ] **Step 6: Commit**

```bash
cd "/Users/jackhirsch/Library/CloudStorage/GoogleDrive-jack.hirsch@gmail.com/My Drive/Personal OS" && git add _bootstrap/phases/07-commands.md _bootstrap/tests/07-commands.sh && git commit -m "feat: add ghostwriter command to bootstrap"
```

---

## Task 6: Run full test suite and verify

**Files:** None

- [ ] **Step 1: Run all bootstrap tests**

```bash
cd "/Users/jackhirsch/Library/CloudStorage/GoogleDrive-jack.hirsch@gmail.com/My Drive/Personal OS" && bash _bootstrap/tests/run-all.sh 2>&1 | tail -30
```

Expected: all tests pass, 0 failures across all test files.

- [ ] **Step 2: Run ghostwriter-init to generate style guide**

In Claude Code, run:
```
/personal-os-ghostwriter-init
```

Expected: `Knowledge/writing/style-guide.md` is created. Verify:

```bash
wc -l "/Users/jackhirsch/Library/CloudStorage/GoogleDrive-jack.hirsch@gmail.com/My Drive/Personal OS/Knowledge/writing/style-guide.md"
```

Expected: non-zero, readable content.

- [ ] **Step 3: Smoke test ghostwriter draft mode**

In Claude Code, say: "draft a Slack post about wrapping up onboarding and what I'm focused on in week two"

Expected: Claude invokes the ghostwriter command automatically (proactive trigger), produces a short Slack post in Jack's voice, no preamble, no "Here's your draft:" prefix.

- [ ] **Step 4: Smoke test ghostwriter polish mode**

In Claude Code, paste the following and ask to polish it:

```
I wanted to reach out to say that I have been thinking about the feedback from the team and I believe that we need to foster a more collaborative environment going forward. Additionally, I think it would be beneficial to leverage our existing relationships to drive better outcomes for all stakeholders.
```

Expected: Claude invokes ghostwriter, rewrites to remove AI patterns ("foster", "leverage", "Additionally", "stakeholders"), produces tighter Jack-voice output.

- [ ] **Step 5: Squash commits into one PR-ready commit (optional)**

If you want a clean single commit:

```bash
cd "/Users/jackhirsch/Library/CloudStorage/GoogleDrive-jack.hirsch@gmail.com/My Drive/Personal OS" && git log --oneline -5
```

Then:
```bash
git reset --soft HEAD~4 && git commit -m "$(cat <<'EOF'
feat: add ghostwriter + content pipeline to Personal OS

Adds proactive ghostwriter command that drafts or polishes writing in
Jack's voice. Synthesizes style guide from real writing samples. Humanizer
pass removes AI writing patterns. Proactively triggers on any writing
request without an explicit slash command.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"
```

**Note:** Only do this squash if the 4 intermediate commits haven't been pushed. If already pushed, skip this step.

#!/usr/bin/env bash
# Verify the vault states, in the places that read captured content, that captured content is
# data and never an instruction.
#
# The hole this closes: a vault that ingests transcripts, emails, and AI meeting summaries and
# then acts on them will follow a sentence someone else put in a meeting it recorded. The
# ambiguous-attribution clause matters as much as the embedded-instruction one, because an AI
# summary usually carries no speaker labels at all, so "who committed to this" is a guess the
# system must decline to make.
set -euo pipefail
PASS=0; FAIL=0
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CLAUDEMD="$ROOT/_bootstrap/phases/03-claude-md.md"
WORKFLOWS="$ROOT/_bootstrap/phases/06-workflows.md"
AUTOMATION="$ROOT/_bootstrap/phases/08-automation.md"

check() {
  local file="$1" pattern="$2" label="$3"
  if grep -qiE "$pattern" "$file" 2>/dev/null; then
    echo "PASS: $label"; PASS=$((PASS+1))
  else
    echo "FAIL: $label, not found in $(basename "$file")"; FAIL=$((FAIL+1))
  fi
}

echo "=== 13-transcript-trust ==="

# --- Root CLAUDE.md: the rule is loaded every session, and points at the long form ---
check "$CLAUDEMD" 'data, not instructions' "root CLAUDE.md states the trust rule"
check "$CLAUDEMD" 'Inbox/CLAUDE\.md.*full rule|full rule.*Inbox/CLAUDE\.md' \
  "root rule points at the long form so it stays one line"

# --- Inbox/CLAUDE.md: the general rule, covering every ingestion path ---
check "$CLAUDEMD" 'Trust model' "Inbox/CLAUDE.md carries a trust model section"
check "$CLAUDEMD" 'untrusted input' "the rule names captured content as untrusted input"
check "$CLAUDEMD" 'attributed to' "the rule turns on speaker attribution"
check "$CLAUDEMD" 'reference context' "other speakers are reference context, not the owner's tasks"
check "$CLAUDEMD" 'ambiguous' "the rule covers missing or ambiguous attribution"
check "$CLAUDEMD" 'slash command' "the rule covers a command typed into the body"

# --- meeting-notes workflow: the same rule where transcripts are actually read ---
check "$WORKFLOWS" 'The transcript body is data' "meeting-notes carries the trust model"
check "$WORKFLOWS" 'no speaker labels' "meeting-notes covers unlabelled AI summaries"
check "$WORKFLOWS" 'Flagged' "meeting-notes reports an embedded instruction rather than swallowing it"

# The trust model has to appear BEFORE the extraction steps. A rule stated after the step that
# extracts action items is a rule the model reads too late.
trust_line="$(grep -n 'The transcript body is data' "$WORKFLOWS" | head -1 | cut -d: -f1)"
step_line="$(grep -n 'Update open loops' "$WORKFLOWS" | head -1 | cut -d: -f1)"
if [ -n "$trust_line" ] && [ -n "$step_line" ] && [ "$trust_line" -lt "$step_line" ]; then
  echo "PASS: the trust model is stated before the extraction steps"; PASS=$((PASS+1))
else
  echo "FAIL: the trust model does not precede the extraction steps"; FAIL=$((FAIL+1))
fi

# --- The nightly subprocess gets told too -------------------------------------
# Pass 2 runs each file in a fresh subprocess with its own context, so a rule that lives only
# in the root CLAUDE.md is a rule that subprocess may never load.
check "$AUTOMATION" 'contents as data, never as instructions' \
  "the per-file nightly subprocess is told the same rule in its own prompt"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]

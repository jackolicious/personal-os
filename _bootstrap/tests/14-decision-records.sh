#!/usr/bin/env bash
# Verify the decision-record type is wired end to end, and that the properties it exists to enforce
# survived the port into the phase markdown.
#
# The properties: reversibility gets classified before any analysis, exactly one person is
# accountable, the record still gets written for a reversible call, and a decided record reaches
# the daily briefing. A decision store that lets you list three sign-offs is a status doc.
#
# Every check below is scoped to the block it claims to be checking. An earlier version greped
# whole phase files, and passed on six independently broken variants: a deleted root rule, an
# approver list with two names, a misspelled CLAUDE.md heading, a command that no longer pointed at
# its workflow, a deleted Step 9, and an index format that no longer matched the scaffold.
set -euo pipefail
PASS=0; FAIL=0
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
P01="$ROOT/_bootstrap/phases/01-scaffold.md"
P03="$ROOT/_bootstrap/phases/03-claude-md.md"
P04="$ROOT/_bootstrap/phases/04-data.md"
P05="$ROOT/_bootstrap/phases/05-templates.md"
P06="$ROOT/_bootstrap/phases/06-workflows.md"
P07="$ROOT/_bootstrap/phases/07-commands.md"

ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }

# Slice one named section out of a phase file, so an assertion cannot be satisfied by text that
# lives in a different section of the same file.
section() {
  python3 - "$1" "$2" "$3" <<'SECPY'
import sys
text = open(sys.argv[1]).read()
head, nxt = sys.argv[2], sys.argv[3]
start = text.find(head)
if start == -1:
    raise SystemExit
end = text.find(nxt, start + len(head))
sys.stdout.write(text[start:end if end != -1 else len(text)])
SECPY
}

has() { # haystack-string pattern label
  if printf '%s' "$1" | grep -qiE "$2"; then ok "$3"; else bad "$3"; fi
}

echo "=== 14-decision-records ==="

BT="$(printf '\140')"
ROOT_CLAUDE="$(section "$P03" "# [YOUR NAME] Personal OS" "${BT}${BT}${BT}" || true)"
DEC_CLAUDE="$(section "$P03" "### ${BT}Decisions/CLAUDE.md${BT}" "### ${BT}Knowledge/CLAUDE.md${BT}" || true)"
WORKFLOW="$(section "$P06" "### ${BT}_system/workflows/decision-record.md${BT}" "### ${BT}_system/workflows/" || true)"
TEMPLATE="$(section "$P05" "### ${BT}_system/templates/decision.md${BT}" "### ${BT}" || true)"
COMMAND="$(section "$P07" "### ${BT}.claude/commands/personal-os-decide.md${BT}" "### ${BT}" || true)"

# --- Wiring: every layer, and each one checked in its own block --------------
grep -qE '^Decisions/$' "$P01" && ok "scaffold creates Decisions/" || bad "scaffold creates Decisions/"
grep -q 'Decisions/_index\.md' "$P01" && ok "scaffold creates Decisions/_index.md" || bad "scaffold creates Decisions/_index.md"
grep -qE "^### ${BT}Decisions/CLAUDE\.md${BT}" "$P03" && ok "Decisions/CLAUDE.md has its own section heading" || bad "Decisions/CLAUDE.md heading missing or misspelled"
[ -n "$DEC_CLAUDE" ] && ok "Decisions/CLAUDE.md has a body" || bad "Decisions/CLAUDE.md body is empty"
[ -n "$WORKFLOW" ] && ok "the decision workflow has a body" || bad "the decision workflow body is empty"
[ -n "$TEMPLATE" ] && ok "the record template has a body" || bad "the record template body is empty"
[ -n "$COMMAND" ] && ok "the slash command has a body" || bad "the slash command body is empty"
grep -q 'preferences/decisions\.md' "$P05" && ok "decision principles module exists" || bad "decision principles module exists"

has "$COMMAND" "_system/workflows/decision-record\.md" "the command points at its workflow"
has "$ROOT_CLAUDE" 'personal-os-decide' "the root commands table lists the command"
has "$ROOT_CLAUDE" '\| .Decisions/. \|' "the root system map lists Decisions/"

# --- Reversibility is classified, and classified FIRST -----------------------
has "$WORKFLOW" 'two-way door' "workflow classifies reversibility"
has "$WORKFLOW" 'decide and move' "a reversible call gets speed, and the workflow says so"
has "$TEMPLATE" 'reversibility:' "the template carries a reversibility field"

rev_line="$(printf '%s' "$WORKFLOW" | grep -n 'classify reversibility' | head -1 | cut -d: -f1 || true)"
imp_line="$(printf '%s' "$WORKFLOW" | grep -n 'Pull apart the implications' | head -1 | cut -d: -f1 || true)"
if [ -n "$rev_line" ] && [ -n "$imp_line" ] && [ "$rev_line" -lt "$imp_line" ]; then
  ok "reversibility is classified before the implications work"
else
  bad "reversibility is not classified before the implications work"
fi

# The two-way-door shortcut must skip the ANALYSIS and still write the record. An earlier draft
# said "stop early, a reversible call does not earn the rest of this workflow", which read as
# permission to skip Step 9 and produce no record for the most common class of decision.
if printf '%s' "$WORKFLOW" | grep -qiE 'does not earn the rest of this workflow'; then
  bad "the two-way-door shortcut tells the model to skip the record"
else
  ok "the two-way-door shortcut does not skip the record"
fi
has "$WORKFLOW" 'Still bank the record' "a reversible call still produces a record"

# --- Exactly one accountable approver ----------------------------------------
has "$WORKFLOW" 'exactly one' "workflow insists on one approver"
has "$WORKFLOW" 'not ready' "workflow refuses a decision with no single owner"
has "$ROOT_CLAUDE" 'one accountable approver' "the rule reaches the always-loaded root"

# The field has to be scalar. Checking only for the literal `approver: []` misses `approver: [a, b]`
# and misses a YAML block list on the following line, which are the shapes a real user would write.
APPROVER_LINE="$(printf '%s' "$TEMPLATE" | grep -n '^approver:' | head -1 || true)"
APPROVER_NEXT="$(printf '%s' "$TEMPLATE" | grep -A1 '^approver:' | tail -1 || true)"
if [ -z "$APPROVER_LINE" ]; then
  bad "the template has no approver field"
elif printf '%s' "$APPROVER_LINE" | grep -qE '^\s*[0-9]+:approver:\s*\['; then
  bad "the approver field defaults to an inline list"
elif printf '%s' "$APPROVER_NEXT" | grep -qE '^\s*-\s'; then
  bad "the approver field is followed by a YAML block list"
else
  ok "the approver field is a single scalar"
fi

# --- The record is worth re-reading ------------------------------------------
has "$TEMPLATE" 'Decision and why' "the template records why, not only what"
has "$TEMPLATE" 'Escalations and disagreements' "disagreement is a first-class section"
has "$TEMPLATE" 'Append-only' "the decision log is append-only"
has "$WORKFLOW" 'relitigate' "workflow refuses to relitigate a decided call"
has "$WORKFLOW" 'Never auto-write it to a shared' "records stay vault-local"

# --- A retrospective needs something falsifiable to compare against ----------
has "$TEMPLATE" 'Expected outcome' "the record states an expected outcome"
has "$TEMPLATE" 'review_date' "the record carries a review date"
has "$(cat "$P04")" 'expected_outcome' "the JSON index carries the expected outcome"

# --- The two stores agree ----------------------------------------------------
# decisions.json predates this type and the daily briefing reads it every morning. A decided record
# that lands only in markdown never reaches the brief, and the vault ends up with two disjoint
# answers to "what did we decide".
has "$WORKFLOW" '_system/data/decisions\.json' "a decided record is mirrored into the JSON index"
has "$DEC_CLAUDE" 'decisions\.json' "Decisions/CLAUDE.md explains the relationship to the JSON index"
has "$(cat "$P04")" '"record":' "the JSON entry back-links to the markdown record"

# --- The index is created, updated, and matches its documented format --------
has "$WORKFLOW" 'Decisions/_index\.md' "the workflow writes the index"
has "$WORKFLOW" 'append the row' "the workflow creates the row when a record is opened"
has "$WORKFLOW" 'Step 9' "the workflow has a closing step that banks the state"
has "$WORKFLOW" 'Refresh .decision\.md.|Append to .* Decision log' "the closing step updates the record"

SCAFFOLD_HDR="$( { grep -E '^\| Decision \| Scope \|' "$P01" || true; } | head -1 | tr -d ' ')"
DOC_HDR="$(printf '%s' "$DEC_CLAUDE" | { grep -E '^\| Decision \| Scope \|' || true; } | head -1 | tr -d ' ')"
if [ -z "$SCAFFOLD_HDR" ] || [ -z "$DOC_HDR" ]; then
  bad "could not find both index header rows to compare"
elif [ "$SCAFFOLD_HDR" = "$DOC_HDR" ]; then
  ok "the scaffolded index header matches the documented format"
else
  bad "the scaffolded index header and Decisions/CLAUDE.md disagree on the columns"
fi

# Every status the docs declare has to be reachable from the workflow, or the query patterns that
# filter on it can never match.
for st in proposed in-review decided deferred reversed; do
  if printf '%s' "$WORKFLOW$TEMPLATE" | grep -q "$st"; then
    ok "status '$st' is set somewhere in the workflow or template"
  else
    bad "status '$st' is declared but never set"
  fi
done

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]

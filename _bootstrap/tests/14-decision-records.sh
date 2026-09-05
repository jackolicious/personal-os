#!/usr/bin/env bash
# Verify the decision-record type is wired end to end, and that the two rules the type exists
# to enforce survived the port into the phase markdown.
#
# The rules: reversibility gets classified before any analysis, and exactly one person is
# accountable. A decision record that lets you list three sign-offs is a status doc. The point
# of the type is that it refuses.
set -euo pipefail
PASS=0; FAIL=0
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

check() {
  local file="$1" pattern="$2" label="$3"
  if grep -qiE "$pattern" "$ROOT/$file" 2>/dev/null; then
    echo "PASS: $label"; PASS=$((PASS+1))
  else
    echo "FAIL: $label, not found in $file"; FAIL=$((FAIL+1))
  fi
}

echo "=== 14-decision-records ==="

# --- Wiring: every layer the type needs ---
check "_bootstrap/phases/01-scaffold.md"  '^Decisions/$'          "scaffold creates Decisions/"
# The workflow reads _index.md on an argument-less invocation, and Decisions/CLAUDE.md
# documents its format. A scaffold that creates the directory and not the index leaves the
# first "what is open" query reading a file that does not exist.
check "_bootstrap/phases/01-scaffold.md"  'Decisions/_index\.md' "scaffold creates Decisions/_index.md"
check "_bootstrap/phases/01-scaffold.md"  'Reversibility \| Approver' "the index ships with its header row"
check "_bootstrap/phases/03-claude-md.md" '\| `Decisions/` \|'    "root CLAUDE.md system map lists Decisions/"
check "_bootstrap/phases/03-claude-md.md" 'personal-os-decide'    "root CLAUDE.md commands table lists the command"
check "_bootstrap/phases/03-claude-md.md" '# Decisions'           "Decisions/CLAUDE.md exists"
check "_bootstrap/phases/05-templates.md" 'preferences/decisions\.md' "decision principles module exists"
check "_bootstrap/phases/05-templates.md" 'templates/decision\.md'    "decision record template exists"
check "_bootstrap/phases/06-workflows.md" 'decision-record\.md'   "decision workflow exists"
check "_bootstrap/phases/07-commands.md"  'personal-os-decide\.md' "slash command exists"

# --- Rule 1: reversibility is classified first ---
check "_bootstrap/phases/06-workflows.md" 'two-way door'          "workflow classifies reversibility"
check "_bootstrap/phases/06-workflows.md" 'decide and move'       "a reversible call gets speed, and the workflow says so"
check "_bootstrap/phases/05-templates.md" 'reversibility:'        "the template carries a reversibility field"

# The classification has to precede the analysis steps. Stated after them, it is a label on
# work already done, and the two-way-door shortcut it exists to trigger can never fire.
W="$ROOT/_bootstrap/phases/06-workflows.md"
rev_line="$(grep -n 'classify reversibility' "$W" | head -1 | cut -d: -f1 || true)"
imp_line="$(grep -n 'Pull apart the implications' "$W" | head -1 | cut -d: -f1 || true)"
if [ -n "$rev_line" ] && [ -n "$imp_line" ] && [ "$rev_line" -lt "$imp_line" ]; then
  echo "PASS: reversibility is classified before the implications work"; PASS=$((PASS+1))
else
  echo "FAIL: reversibility is not classified before the implications work"; FAIL=$((FAIL+1))
fi

# --- Rule 2: exactly one accountable approver ---
check "_bootstrap/phases/06-workflows.md" 'exactly one'           "workflow insists on one approver"
check "_bootstrap/phases/06-workflows.md" 'not ready'             "workflow refuses a decision with no single owner"
check "_bootstrap/phases/03-claude-md.md" 'one accountable approver' "the rule reaches the always-loaded root"
check "_bootstrap/phases/05-templates.md" 'exactly one accountable name' "the template field is singular"

# The approver field must be a scalar. A list default in the frontmatter invites the diffusion
# of responsibility the whole type exists to prevent.
if grep -qE '^approver: \[\]' "$ROOT/_bootstrap/phases/05-templates.md"; then
  echo "FAIL: the approver field defaults to a list"; FAIL=$((FAIL+1))
else
  echo "PASS: the approver field is a scalar, not a list"; PASS=$((PASS+1))
fi

# --- The record has to be re-readable, which is the point of keeping it ---
check "_bootstrap/phases/05-templates.md" 'Decision and why'      "the template records why, not only what"
check "_bootstrap/phases/05-templates.md" 'Escalations and disagreements' "disagreement is a first-class section"
check "_bootstrap/phases/05-templates.md" 'Append-only'           "the decision log is append-only"
check "_bootstrap/phases/06-workflows.md" 'relitigate'            "workflow refuses to relitigate a decided call"

# --- It stays local ---
# A decision record is working state. Auto-pushing it to a shared space turns a thinking tool
# into a publishing one, and people stop writing the honest version.
check "_bootstrap/phases/06-workflows.md" 'Never auto-write it to a shared' "records stay vault-local"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]

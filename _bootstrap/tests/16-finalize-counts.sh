#!/usr/bin/env bash
# Keep the Phase 9 validation counts honest by deriving them from the phases that create the
# files, rather than trusting the numbers a human typed once.
#
# Why this exists: the counts had drifted badly before anything checked them. Phase 9 told the
# user to expect 11 command files and 9 workflow files while the phases created 17 of each. A
# validation step that reports the wrong number is worse than no validation step, because the
# user who runs it and sees 17 assumes their own setup went wrong.
#
# CONTRIBUTING names the finalize checklist as something that must stay accurate. This is what
# makes that enforceable instead of aspirational.
set -euo pipefail
PASS=0; FAIL=0
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FINALIZE="$ROOT/_bootstrap/phases/09-finalize.md"

# Pull the number Phase 9 states for a given validation line.
stated() { grep -oE "should show [0-9]+ $1" "$FINALIZE" | head -1 | grep -oE '[0-9]+' || true; }

compare() {
  local label="$1" actual="$2" claimed="$3"
  if [ -z "$claimed" ]; then
    echo "FAIL: $label, Phase 9 states no count"; FAIL=$((FAIL+1))
  elif [ "$actual" = "$claimed" ]; then
    echo "PASS: $label ($actual)"; PASS=$((PASS+1))
  else
    echo "FAIL: $label, phases create $actual but Phase 9 says $claimed"; FAIL=$((FAIL+1))
  fi
}

echo "=== 16-finalize-counts ==="

commands=$(grep -c '^### `\.claude/commands/' "$ROOT/_bootstrap/phases/07-commands.md")
workflows=$(grep -c '^### `_system/workflows/' "$ROOT/_bootstrap/phases/06-workflows.md")
claudemds=$(grep -c '^### `[A-Za-z_/]*CLAUDE\.md`' "$ROOT/_bootstrap/phases/03-claude-md.md")
# calendar.md is conditional on calendar integration, so it stays out of the unconditional count.
prefs=$(grep '^### `profile/preferences/' "$ROOT/_bootstrap/phases/05-templates.md" | grep -vc 'created only if')

compare "command count"   "$commands"  "$(stated 'command files')"
compare "workflow count"  "$workflows" "$(stated 'workflow files')"
compare "CLAUDE.md count" "$claudemds" "$(stated 'CLAUDE.md files')"
compare "preference count" "$prefs"    "$(stated 'files:')"

# The named examples have to exist too. A count that matches while the named file is missing
# sends the user hunting for something the bootstrap never created.
for f in personal-os-brief.md personal-os-decide.md; do
  if grep -q "$f" "$FINALIZE" && grep -q "$f" "$ROOT/_bootstrap/phases/07-commands.md"; then
    echo "PASS: $f is named in Phase 9 and created in Phase 7"; PASS=$((PASS+1))
  elif grep -q "$f" "$FINALIZE"; then
    echo "FAIL: Phase 9 names $f but Phase 7 never creates it"; FAIL=$((FAIL+1))
  fi
done

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]

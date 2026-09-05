#!/usr/bin/env bash
# Verify Phase 8 installs a working prose guard, and that the settings.json snippet quotes its
# hook path.
#
# Why the quoting assertion exists. A vault installed from this template usually lives on a path
# containing a space (~/Google Drive/My Drive/..., ~/Library/Mobile Documents/..., ~/OneDrive/...).
# An unquoted $CLAUDE_PROJECT_DIR in a hook command makes the shell split on that space and try to
# execute /Users/you/Google, which fails. A PreToolUse hook that fails to launch does not block the
# tool. The guard then protects nothing while looking correctly configured, which is the worst
# possible failure mode because it is invisible.
#
# This was found in a real vault on 2026-07-30, where the em-dash guard had been silently dead for
# five weeks and a document shipped with 12 em dashes through a hook that appeared to be installed.
set -euo pipefail
PASS=0; FAIL=0
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PHASE="_bootstrap/phases/08-automation.md"

check_present() {
  local file="$ROOT/$1" pattern="$2" label="$3"
  if grep -q "$pattern" "$file" 2>/dev/null; then
    echo "PASS: $label"; PASS=$((PASS+1))
  else
    echo "FAIL: $label, not found in $1"; FAIL=$((FAIL+1))
  fi
}

check_absent() {
  local file="$ROOT/$1" pattern="$2" label="$3"
  if grep -q "$pattern" "$file" 2>/dev/null; then
    echo "FAIL: $label, found in $1 (should be absent)"; FAIL=$((FAIL+1))
  else
    echo "PASS: $label"; PASS=$((PASS+1))
  fi
}

echo "=== 10-prose-hooks ==="

check_present "$PHASE" 'Step 2b' "Phase 8 has a prose guard step"
check_present "$PHASE" 'no-em-dashes\.sh' "Phase 8 creates the hook script"
check_present "$PHASE" 'chmod +x .claude/hooks/no-em-dashes.sh' "Phase 8 makes the hook executable"
check_present "$PHASE" 'PreToolUse' "Phase 8 registers the hook on PreToolUse"
check_present "$PHASE" 'Write|Edit|MultiEdit' "Phase 8 matches the write tools"

# The quoted form must be present, and the bare unquoted form must not appear as a command value.
check_present "$PHASE" '\\"\$CLAUDE_PROJECT_DIR\\"' "settings.json snippet quotes CLAUDE_PROJECT_DIR"
check_absent  "$PHASE" '"command": "\$CLAUDE_PROJECT_DIR/' "no unquoted CLAUDE_PROJECT_DIR command"
check_present "$PHASE" "silently protects nothing" "Phase 8 explains why quoting matters"

# The rule the hook enforces must actually be stated in the vault's writing preferences.
check_present "_bootstrap/phases/03-claude-md.md" 'No em dashes' "Phase 3 states the em dash rule"

# The rule that bans em dashes must not itself contain one.
if grep -n 'No em dashes' "$ROOT/_bootstrap/phases/03-claude-md.md" | grep -q '—'; then
  echo "FAIL: the 'No em dashes' rule contains an em dash"; FAIL=$((FAIL+1))
else
  echo "PASS: the 'No em dashes' rule contains no em dash"; PASS=$((PASS+1))
fi

# Demonstrate the failure mode rather than asserting it, so this test cannot be dismissed.
PROBE="$(mktemp -d "${TMPDIR:-/tmp}/probe dir XXXXXX")"
printf '#!/bin/bash\nexit 7\n' > "$PROBE/h.sh"
chmod +x "$PROBE/h.sh"
export PROBE_DIR="$PROBE"
set +e
sh -c '$PROBE_DIR/h.sh' >/dev/null 2>&1; unq=$?
sh -c '"$PROBE_DIR"/h.sh' >/dev/null 2>&1; q=$?
set -e
rm -rf "$PROBE"
if [ "$unq" -ne 7 ] && [ "$q" -eq 7 ]; then
  echo "PASS: demonstrated unquoted path fails to launch ($unq) and quoted path runs ($q)"; PASS=$((PASS+1))
else
  echo "FAIL: could not demonstrate the quoting failure (unquoted=$unq quoted=$q)"; FAIL=$((FAIL+1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]

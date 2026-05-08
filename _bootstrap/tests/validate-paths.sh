#!/usr/bin/env bash
# Validates that Knowledge/sources/ path references have been fully renamed to
# Knowledge/annotated/ across all bootstrap and documentation files.
# Run from the repo root: bash _bootstrap/tests/validate-paths.sh

set -euo pipefail

PASS=0
FAIL=0
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

check_absent() {
  local pattern="$1"
  local label="$2"
  local hits
  hits=$(grep -r --include="*.md" --include="*.sh" -l "$pattern" "$ROOT" 2>/dev/null | grep -v ".git" | grep -v "_bootstrap/tests/" || true)
  if [ -n "$hits" ]; then
    echo "FAIL: '$label' still present in:"
    echo "$hits" | sed "s|$ROOT/||"
    FAIL=$((FAIL + 1))
  else
    echo "PASS: no '$label' path references found"
    PASS=$((PASS + 1))
  fi
}

check_present() {
  local file="$ROOT/$1"
  local pattern="$2"
  local label="$3"
  if grep -q "$pattern" "$file" 2>/dev/null; then
    echo "PASS: '$label' found in $1"
    PASS=$((PASS + 1))
  else
    echo "FAIL: '$label' missing from $1"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== validate-paths ==="
echo ""

# No remaining path references to the old folder name
check_absent "Knowledge/sources/" "Knowledge/sources/ path ref"

# Key files contain the new path
check_present "_bootstrap/phases/01-scaffold.md"  "Knowledge/annotated/" "scaffold creates annotated/"
check_present "_bootstrap/phases/03-claude-md.md" "Knowledge/annotated/" "CLAUDE.md template uses annotated/"
check_present "_bootstrap/phases/06-workflows.md" "Knowledge/annotated/" "workflows write to annotated/"
check_present "_bootstrap/phases/07-commands.md"  "Knowledge/annotated/" "commands write to annotated/"
check_present "README.md"                          "annotated/"           "README tree shows annotated/"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]

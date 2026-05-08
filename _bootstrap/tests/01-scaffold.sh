#!/usr/bin/env bash
# Tests that _bootstrap/phases/01-scaffold.md defines the correct directory scaffold.
# Run from the repo root: bash _bootstrap/tests/01-scaffold.sh

set -euo pipefail

PASS=0; FAIL=0
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FILE="_bootstrap/phases/01-scaffold.md"

check_present() {
  local file="$ROOT/$1" pattern="$2" label="$3"
  if grep -q "$pattern" "$file" 2>/dev/null; then
    echo "PASS: $label"; PASS=$((PASS+1))
  else
    echo "FAIL: $label — not found in $1"; FAIL=$((FAIL+1))
  fi
}

check_absent() {
  local file="$ROOT/$1" pattern="$2" label="$3"
  if grep -q "$pattern" "$file" 2>/dev/null; then
    echo "FAIL: $label — found in $1 (should be absent)"; FAIL=$((FAIL+1))
  else
    echo "PASS: $label"; PASS=$((PASS+1))
  fi
}

echo "=== 01-scaffold ==="
echo ""

# Expected directories
check_present "$FILE" "Inbox/"                    "lists Inbox/"
check_present "$FILE" "Inbox/_archive/"           "lists Inbox/_archive/"
check_present "$FILE" "1on1s/"                    "lists 1on1s/"
check_present "$FILE" "Meetings/"                 "lists Meetings/"
check_present "$FILE" "Projects/"                 "lists Projects/"
check_present "$FILE" "Knowledge/"                "lists Knowledge/"
check_present "$FILE" "Knowledge/annotated/"      "lists Knowledge/annotated/"
check_present "$FILE" "Knowledge/wiki/"           "lists Knowledge/wiki/"
check_present "$FILE" "Knowledge/wiki/concepts/"  "lists Knowledge/wiki/concepts/"
check_present "$FILE" "Knowledge/wiki/market/"    "lists Knowledge/wiki/market/"
check_present "$FILE" "People/"                   "lists People/"
check_present "$FILE" "Interviews/"               "lists Interviews/"
check_present "$FILE" "profile/"                  "lists profile/"
check_present "$FILE" "profile/preferences/"      "lists profile/preferences/"
check_present "$FILE" "profile/career/"           "lists profile/career/"
check_present "$FILE" "_system/"                  "lists _system/"
check_present "$FILE" "_system/data/"             "lists _system/data/"
check_present "$FILE" "_system/logs/"             "lists _system/logs/"
check_present "$FILE" "_system/briefings/"        "lists _system/briefings/"
check_present "$FILE" "_system/templates/"        "lists _system/templates/"
check_present "$FILE" "_system/workflows/"        "lists _system/workflows/"
check_present "$FILE" "\.claude/"                 "lists .claude/"
check_present "$FILE" "\.claude/commands/"        "lists .claude/commands/"

# Uses annotated/, not the old sources/ name
check_absent  "$FILE" "Knowledge/sources/"        "does not reference Knowledge/sources/"

# Key conventions
check_present "$FILE" "\.gitkeep"                 "references .gitkeep for empty dirs"

# Initialization files
check_present "$FILE" "Inbox/_index\.md"          "initializes Inbox/_index.md"
check_present "$FILE" "Inbox/_unrouted\.md"       "initializes Inbox/_unrouted.md"
check_present "$FILE" "Knowledge/wiki/log\.md"    "initializes Knowledge/wiki/log.md"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]

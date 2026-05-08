#!/usr/bin/env bash
# Tests that _bootstrap/phases/02-root-files.md defines correct root file content.
# Run from the repo root: bash _bootstrap/tests/02-root-files.sh

set -euo pipefail

PASS=0; FAIL=0
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FILE="_bootstrap/phases/02-root-files.md"

check_present() {
  local file="$ROOT/$1" pattern="$2" label="$3"
  if grep -q "$pattern" "$file" 2>/dev/null; then
    echo "PASS: $label"; PASS=$((PASS+1))
  else
    echo "FAIL: $label — not found in $1"; FAIL=$((FAIL+1))
  fi
}

check_count_gte() {
  local file="$ROOT/$1" pattern="$2" min="$3" label="$4"
  local count
  count=$(grep -c "$pattern" "$file" 2>/dev/null || true)
  if [ "$count" -ge "$min" ]; then
    echo "PASS: $label ($count matches)"; PASS=$((PASS+1))
  else
    echo "FAIL: $label — expected >=$min, got $count in $1"; FAIL=$((FAIL+1))
  fi
}

echo "=== 02-root-files ==="
echo ""

# .gitignore entries
check_present "$FILE" "\.obsidian/"          ".gitignore includes .obsidian/"
check_present "$FILE" "\.trash/"             ".gitignore includes .trash/"
check_present "$FILE" "\*\.DS_Store"         ".gitignore includes *.DS_Store"
check_present "$FILE" "_system/logs/"        ".gitignore includes _system/logs/"
check_present "$FILE" "\.env"                ".gitignore includes .env"

# GOALS.md sections
check_present "$FILE" "## 30 Days"           "GOALS.md has ## 30 Days section"
check_present "$FILE" "## 60 Days"           "GOALS.md has ## 60 Days section"
check_present "$FILE" "## 90 Days"           "GOALS.md has ## 90 Days section"
check_present "$FILE" "Last Updated:"        "GOALS.md has Last Updated: field"

# HEARTBEAT.md sections
check_present "$FILE" "## Current Focus"     "HEARTBEAT.md has ## Current Focus section"
check_present "$FILE" "## This Week"         "HEARTBEAT.md has ## This Week section"
check_present "$FILE" "## Open Questions"    "HEARTBEAT.md has ## Open Questions section"
check_present "$FILE" "## Blockers"          "HEARTBEAT.md has ## Blockers section"
check_present "$FILE" "## Upcoming 1on1s"    "HEARTBEAT.md has ## Upcoming 1on1s section"
check_present "$FILE" "Last Cascade Sent"    "HEARTBEAT.md has Last Cascade Sent field"
check_present "$FILE" "Last Nightly Synthesis" "HEARTBEAT.md has Last Nightly Synthesis field"
check_present "$FILE" "Last Daily Briefing"  "HEARTBEAT.md has Last Daily Briefing field"

# BACKLOG.md sections
check_present "$FILE" "## Open"              "BACKLOG.md has ## Open section"
check_present "$FILE" "## Done"              "BACKLOG.md has ## Done section"

# PILLARS.md content
check_present "$FILE" "\*\*Description:\*\*" "PILLARS.md has **Description:** field"
check_present "$FILE" "\*\*Keywords:\*\*"    "PILLARS.md has **Keywords:** field"

# PILLARS.md has at least 4 pillar headings (## lines)
check_count_gte "$FILE" "^## " 4             "PILLARS.md defines at least 4 ## headings"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]

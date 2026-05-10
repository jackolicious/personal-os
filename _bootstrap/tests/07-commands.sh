#!/usr/bin/env bash
# Tests that _bootstrap/phases/07-commands.md defines all slash commands correctly.
# Run from the repo root: bash _bootstrap/tests/07-commands.sh

set -euo pipefail

PASS=0; FAIL=0
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FILE="_bootstrap/phases/07-commands.md"

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

echo "=== 07-commands ==="
echo ""

# --- Command completeness: all 13 commands must be defined ---

check_present "$FILE" "personal-os-daily-briefing"     "defines personal-os-daily-briefing"
check_present "$FILE" "personal-os-process-inbox"      "defines personal-os-process-inbox"
check_present "$FILE" "personal-os-cascade"            "defines personal-os-cascade"
check_present "$FILE" "personal-os-1on1-prep"          "defines personal-os-1on1-prep"
check_present "$FILE" "personal-os-ingest-url"         "defines personal-os-ingest-url"
check_present "$FILE" "personal-os-nightly"            "defines personal-os-nightly"
check_present "$FILE" "personal-os-open-loops"         "defines personal-os-open-loops"
check_present "$FILE" "personal-os-new-1on1"           "defines personal-os-new-1on1"
check_present "$FILE" "personal-os-new-interview-role" "defines personal-os-new-interview-role"
check_present "$FILE" "personal-os-interview-prep"     "defines personal-os-interview-prep"
check_present "$FILE" "personal-os-career-evidence"    "defines personal-os-career-evidence"
check_present "$FILE" "personal-os-week-ahead"         "defines personal-os-week-ahead"
check_present "$FILE" "personal-os-remember"           "defines personal-os-remember"

echo ""

# --- personal-os-daily-briefing content ---

check_present "$FILE" "_system/workflows/daily-briefing\.md"  "daily-briefing references _system/workflows/daily-briefing.md"
check_present "$FILE" "profile/preferences/briefing\.md"      "daily-briefing references profile/preferences/briefing.md"

echo ""

# --- personal-os-cascade content ---

check_present "$FILE" "_system/workflows/cascade\.md"         "cascade references _system/workflows/cascade.md"
check_present "$FILE" "explicit approval\|without explicit approval\|no-send-without-confirmation\|Do not send" \
                                                              "cascade requires approval before sending"

echo ""

# --- personal-os-1on1-prep content ---

check_present "$FILE" "1on1s/"                                "1on1-prep references 1on1s/"
check_present "$FILE" "_system/workflows/1on1-prep\.md"       "1on1-prep references _system/workflows/1on1-prep.md"

echo ""

# --- personal-os-ingest-url content ---

check_present "$FILE" "Knowledge/annotated/"                  "ingest-url saves to Knowledge/annotated/"
check_present "$FILE" "Inbox/archive"                         "ingest-url moves file to Inbox/archive"

echo ""

# --- personal-os-nightly content ---

check_present "$FILE" "_system/workflows/nightly-synthesis\.md" "nightly references _system/workflows/nightly-synthesis.md"

echo ""

# --- personal-os-open-loops content ---

check_present "$FILE" "_system/data/open-loops\.json"         "open-loops reads _system/data/open-loops.json"
check_present "$FILE" "overdue"                               "open-loops sort order mentions overdue"
check_present "$FILE" "critical"                              "open-loops sort order mentions critical"
check_present "$FILE" "high"                                  "open-loops sort order mentions high"

echo ""

# --- personal-os-new-1on1 content ---

check_present "$FILE" "1on1s/\[Name\]/CLAUDE\.md\|CLAUDE\.md"  "new-1on1 creates CLAUDE.md"
check_present "$FILE" "profile\.md"                           "new-1on1 creates profile.md"
check_present "$FILE" "open-loops\.md"                        "new-1on1 creates open-loops.md"
check_present "$FILE" "sessions/"                             "new-1on1 creates sessions/ directory"
check_present "$FILE" "ready-note\.md"                        "new-1on1 creates ready-note.md"
check_present "$FILE" "People/team\.md\|People/stakeholders\.md" "new-1on1 updates People/team.md or People/stakeholders.md"

echo ""

# --- personal-os-new-interview-role content ---

check_present "$FILE" "role-context\.md"                      "new-interview-role creates role-context.md"
check_present "$FILE" "question-bank\.md"                     "new-interview-role creates question-bank.md"
check_present "$FILE" "Interviews/\[role\]/notes\|notes/ directory\|notes/" \
                                                              "new-interview-role creates notes/ directory"
check_present "$FILE" "Interviews/_index\.md"                 "new-interview-role updates Interviews/_index.md"

echo ""

# --- personal-os-interview-prep content ---

check_present "$FILE" "role-context\.md"                      "interview-prep reads role-context.md"
check_present "$FILE" "question-bank\.md"                     "interview-prep reads question-bank.md"
check_present "$FILE" "Interviews/\[role\]/notes"             "interview-prep creates notes file under Interviews/[role]/notes/"

echo ""

# --- personal-os-career-evidence content ---

check_present "$FILE" "_system/workflows/career-evidence\.md" "career-evidence references _system/workflows/career-evidence.md"
check_present "$FILE" "90"                                    "career-evidence mentions 90-day default"

echo ""

# --- personal-os-week-ahead content ---

check_present "$FILE" "_system/workflows/week-ahead\.md"      "week-ahead references _system/workflows/week-ahead.md"

echo ""

# --- personal-os-remember content ---

check_present "$FILE" "_system/workflows/wiki-remember\.md"   "remember references _system/workflows/wiki-remember.md"

echo ""

# ---------------------------------------------------------------------------
# personal-os-meeting-prep
# ---------------------------------------------------------------------------
echo "-- personal-os-meeting-prep --"

check_present "$FILE" "personal-os-meeting-prep" \
  "meeting-prep: command defined"

check_present "$FILE" "meeting-prep.md" \
  "meeting-prep: command references workflow"

check_present "$FILE" "ARGUMENTS" \
  "meeting-prep: command handles arguments"

echo ""

# --- Forbidden references ---

check_absent  "$FILE" "Knowledge/sources/"                    "does not reference Knowledge/sources/"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]

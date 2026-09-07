#!/usr/bin/env bash
# Ensures this repo stays a clean installer — no vault runtime files on disk.
# Also validates that setup.sh and 08-automation.md describe the same mechanism.
# Run from repo root: bash _bootstrap/tests/00-installer-integrity.sh

set -euo pipefail
PASS=0; FAIL=0
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

ok()   { echo "PASS: $1"; PASS=$((PASS+1)); }
fail() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }

check_absent_dir() {
  local path="$ROOT/$1" label="$2"
  if [ -d "$path" ]; then
    fail "$label — directory exists at $1 (installer repo should not contain vault runtime files)"
  else
    ok "$label"
  fi
}

check_absent_file() {
  local path="$ROOT/$1" label="$2"
  if [ -f "$path" ]; then
    fail "$label — file exists at $1 (installer repo should not contain vault runtime files)"
  else
    ok "$label"
  fi
}

check_present_file() {
  local path="$ROOT/$1" label="$2"
  if [ -f "$path" ]; then
    ok "$label"
  else
    fail "$label — missing: $1"
  fi
}

check_contains() {
  local path="$ROOT/$1" pattern="$2" label="$3"
  if grep -q "$pattern" "$path" 2>/dev/null; then
    ok "$label"
  else
    fail "$label — pattern not found in $1"
  fi
}

echo "=== 00-installer-integrity ==="
echo ""

# ---------------------------------------------------------------------------
# No vault runtime dirs in repo root
# ---------------------------------------------------------------------------
echo "-- No runtime vault directories --"

check_absent_dir "_system"          "_system/ not present (runtime content belongs in vault)"
check_absent_dir "1on1s"            "1on1s/ not present"
check_absent_dir "Knowledge"        "Knowledge/ not present"
check_absent_dir "People"           "People/ not present"
check_absent_dir "Meetings"         "Meetings/ not present"
check_absent_dir "Inbox"            "Inbox/ not present"
check_absent_dir "Projects"         "Projects/ not present"
# A decision record holds hires, prices, vendor calls, and org moves. On a public installer repo
# that is the last directory you want a `git add -A` to sweep up.
check_absent_dir "Decisions"        "Decisions/ not present"
check_absent_dir "Archive"          "Archive/ not present"

echo ""
echo "-- No installed .claude/ content --"

# .claude/commands and settings.json are vault runtime artifacts — must not be committed.
# settings.local.json is gitignored dev tooling (local permission shortcuts) — allowed on disk.
check_absent_dir ".claude/commands"            ".claude/commands/ not present (vault slash commands)"
check_absent_file ".claude/settings.json"      ".claude/settings.json not present (vault runtime permissions)"

echo ""
echo "-- No vault personal content files --"

check_absent_file "HEARTBEAT.md"               "HEARTBEAT.md not present (vault runtime file)"
check_absent_file "GOALS.md"                   "GOALS.md not present (vault runtime file)"
check_absent_file "PILLARS.md"                 "PILLARS.md not present (vault runtime file)"

echo ""
# ---------------------------------------------------------------------------
# Installer files present
# ---------------------------------------------------------------------------
echo "-- Required installer files present --"

check_present_file "setup.sh"                  "setup.sh present"
check_present_file "personal-os-bootstrap.md"  "personal-os-bootstrap.md present"
check_present_file ".gitignore"                ".gitignore present"
check_present_file "_bootstrap/phases/08-automation.md" "08-automation.md present"

echo ""
# ---------------------------------------------------------------------------
# setup.sh and 08-automation.md are consistent
# Both must describe the same automation mechanism: launchd → run-nightly.sh
# ---------------------------------------------------------------------------
echo "-- setup.sh / 08-automation.md consistency --"

check_contains "setup.sh" "run-nightly.sh" \
  "setup.sh references run-nightly.sh"
check_contains "setup.sh" "com.personalos.loop" \
  "setup.sh creates com.personalos.loop plist"
check_contains "setup.sh" "KeepAlive" \
  "setup.sh plist uses KeepAlive (persistent service)"
check_contains "setup.sh" "PathState" \
  "setup.sh plist uses PathState (only runs when script exists)"

check_contains "_bootstrap/phases/08-automation.md" "run-nightly.sh" \
  "08-automation.md defines run-nightly.sh"
check_contains "_bootstrap/phases/08-automation.md" "com.personalos.loop" \
  "08-automation.md defines com.personalos.loop plist"
check_contains "_bootstrap/phases/08-automation.md" "KeepAlive" \
  "08-automation.md plist uses KeepAlive"
check_contains "_bootstrap/phases/08-automation.md" "PathState" \
  "08-automation.md plist uses PathState"

# Both should NOT have a separate 5am-only briefing plist
check_contains "setup.sh" "run-nightly" \
  "setup.sh uses run-nightly approach (not standalone briefing plist)"

echo ""
# ---------------------------------------------------------------------------
# .gitignore correctly blocks vault content
# ---------------------------------------------------------------------------
echo "-- .gitignore coverage --"

check_contains ".gitignore" "_system/" \
  ".gitignore excludes _system/"
check_contains ".gitignore" "Knowledge/" \
  ".gitignore excludes Knowledge/"
check_contains ".gitignore" '\.claude/settings\.json\|settings\.json' \
  ".gitignore excludes .claude/settings.json"

echo ""
TOTAL=$((PASS + FAIL))
echo "Results: $PASS passed, $FAIL failed ($TOTAL total)"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1

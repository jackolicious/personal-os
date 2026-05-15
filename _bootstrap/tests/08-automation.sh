#!/usr/bin/env bash
set -euo pipefail
PASS=0; FAIL=0
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PHASE="$ROOT/_bootstrap/phases/08-automation.md"

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

# Helper: check against the phase file itself (single-arg shorthand)
phase_present() {
  local pattern="$1" label="$2"
  if grep -q "$pattern" "$PHASE" 2>/dev/null; then
    echo "PASS: $label"; PASS=$((PASS+1))
  else
    echo "FAIL: $label — not found in 08-automation.md"; FAIL=$((FAIL+1))
  fi
}

echo "=== 08-automation.sh ==="

# --- run-nightly.sh: script defined/generated in phase ---
phase_present "run-nightly.sh" "run-nightly.sh defined in bootstrap phase"
phase_present 'mkdir -p.*_system/logs.*_system/briefings\|mkdir -p.*_system/briefings.*_system/logs' \
  "Creates _system/logs/ and _system/briefings/ directories"

# --- Timing ---
phase_present '"02"' \
  "Nightly synthesis scheduled at hour 02 (2am)"
phase_present '"05"' \
  "Daily briefing scheduled at hour 05 (5am)"
phase_present 'DOW.*7\|"7"' \
  "Week-ahead runs on Sunday (DOW=7)"
phase_present '"20"' \
  "Week-ahead runs at hour 20 (8pm)"

# --- Output paths ---
phase_present '_system/briefings/week-ahead-' \
  "Week-ahead output saved to _system/briefings/week-ahead-"
phase_present '_system/briefings/\$TODAY' \
  "Daily briefing output saved to _system/briefings/"

# --- Date tracking (run-once-per-day guards) ---
phase_present 'NIGHTLY_DONE_DATE\|BRIEFING_DONE_DATE\|WEEK_AHEAD_DONE_DATE' \
  "Date tracking variables present for run-once-per-day guards"
phase_present 'DONE_DATE.*TODAY\|TODAY.*DONE_DATE' \
  "Date tracking variables compared to TODAY"

# --- Sleep interval ---
phase_present 'sleep 300' \
  "Sleep interval of 300 seconds between loop checks"

# --- Three-pass nightly pipeline ---
phase_present 'Pass 1\|Pass 2\|Pass 3\|pass 1\|pass 2\|pass 3\|Step 0' \
  "Three-pass (plus step 0) nightly pipeline specified"
phase_present 'claude-haiku\|haiku' \
  "Pass 1/2 uses Haiku model for triage"
phase_present 'claude-sonnet\|sonnet' \
  "Pass 3 uses Sonnet model for synthesis"
phase_present 'per.file\|per-file\|each file' \
  "Pass 2 per-file extraction specified"
phase_present 'synthesis\|nightly-synthesis' \
  "Pass 3 synthesis step specified"

# --- .claude/settings.json: permissions ---
phase_present '"allow"' \
  "settings.json permissions allow array defined"
phase_present '"Read(\*)"' \
  "Read(*) permission included"
phase_present '"Write(\*)"' \
  "Write(*) permission included"
phase_present '"Edit(\*)"' \
  "Edit(*) permission included"

# --- Bash tool permissions ---
phase_present 'Bash(find' \
  "Bash find permission included"
phase_present 'Bash(ls' \
  "Bash ls permission included"
phase_present 'Bash(mv' \
  "Bash mv permission included"
phase_present 'Bash(mkdir' \
  "Bash mkdir permission included"
phase_present 'Bash(markitdown' \
  "Bash markitdown permission included"
phase_present 'Bash(md5' \
  "Bash md5/md5sum permission included"
phase_present 'Bash(grep' \
  "Bash grep permission included"
phase_present 'Bash(date' \
  "Bash date permission included"

# --- Telegram permission ---
phase_present 'mcp__plugin_telegram_telegram__reply' \
  "Telegram reply permission included"

# --- Setup instructions ---
phase_present 'Prevent automatic sleeping\|power adapter' \
  "Mac sleep setting mentioned"
check_present "_bootstrap/phases/06-workflows.md" 'pip install markitdown' \
  "pip install markitdown mentioned (in pdf-ingestion workflow)"
phase_present 'run-nightly.sh' \
  "run-nightly.sh defined in phase"

# --- launchd plist (Step 3) ---
phase_present 'com.personalos.loop' \
  "launchd label com.personalos.loop defined"
phase_present 'KeepAlive' \
  "launchd plist uses KeepAlive"
phase_present 'PathState' \
  "launchd plist uses PathState guard (starts only when run-nightly.sh exists)"
phase_present 'RunAtLoad' \
  "launchd plist uses RunAtLoad"
phase_present 'WorkingDirectory' \
  "launchd plist sets WorkingDirectory"
phase_present 'loop.log\|loop-error.log' \
  "launchd plist defines log output paths"
phase_present 'launchctl load' \
  "launchctl load command specified"
phase_present 'launchctl list\|launchctl unload\|launchctl kickstart' \
  "launchctl management commands documented"

# --- Consistency: setup.sh must match ---
check_present "setup.sh" 'com.personalos.loop' \
  "setup.sh creates same plist label (com.personalos.loop) as phase spec"
check_present "setup.sh" 'KeepAlive' \
  "setup.sh plist uses KeepAlive (matches phase spec)"
check_present "setup.sh" 'PathState' \
  "setup.sh plist uses PathState (matches phase spec)"
check_present "setup.sh" 'run-nightly.sh' \
  "setup.sh references run-nightly.sh (matches phase spec)"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1

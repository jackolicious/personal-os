#!/usr/bin/env bash
# Verify Phase 8 ships a loop that survives the five ways an unattended nightly run dies:
# a vault mount that is not there yet, a hung LLM call, a machine that idle-sleeps mid-run,
# an edit that the running process never picks up, and a crash that replays completed work.
#
# Each assertion below maps to a real outage in a running vault:
#   mount wait        launchd KeepAlive turned a transient Drive remount into a crash loop
#   with-timeout      a claude --print stalled 8+ minutes on 11 seconds of CPU, loop froze
#   block caffeinate  macOS slept in the 5-second gap between two items of a fan-out
#   mtime re-exec     an edited loop kept running the old body, cached in memory by bash
#   per-day markers   a mid-block failure re-ran every completed pass on the launchd restart
set -euo pipefail
PASS=0; FAIL=0
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PHASE="$ROOT/_bootstrap/phases/08-automation.md"

check_present() {
  local pattern="$1" label="$2"
  if grep -qE "$pattern" "$PHASE" 2>/dev/null; then
    echo "PASS: $label"; PASS=$((PASS+1))
  else
    echo "FAIL: $label, not found in 08-automation.md"; FAIL=$((FAIL+1))
  fi
}

check_absent() {
  local pattern="$1" label="$2"
  if grep -qE "$pattern" "$PHASE" 2>/dev/null; then
    echo "FAIL: $label, found in 08-automation.md (should be absent)"; FAIL=$((FAIL+1))
  else
    echo "PASS: $label"; PASS=$((PASS+1))
  fi
}

# Pull one fenced code block out of the phase markdown, chosen by a pattern its body matches.
extract_block() {
  awk -v pat="$1" '
    /^```/ { if (inb) { if (buf ~ pat) { printf "%s", buf; exit } ; inb=0; buf="" } else { inb=1; buf="" } ; next }
    inb { buf = buf $0 "\n" }
  ' "$PHASE"
}

echo "=== 11-loop-resilience ==="

# --- The helper script exists and is wired in --------------------------------
check_present '_system/scripts/with-timeout\.sh' "phase creates with-timeout.sh"
check_present 'chmod \+x _system/scripts/with-timeout\.sh' "with-timeout.sh is made executable"
check_present 'with_timeout\(\) \{' "run-nightly defines a with_timeout wrapper"
check_present 'PASS_TIMEOUT' "passes carry a wall-clock budget"

# Every claude call in the loop runs under the budget. An unwrapped one reintroduces the hang.
LOOP="$(extract_block 'Personal OS, persistent automation loop')"
if [ -z "$LOOP" ]; then
  echo "FAIL: could not find the run-nightly.sh block"; FAIL=$((FAIL+1))
else
  # `|| true` on each stage: a grep that matches nothing exits 1, and pipefail would abort here.
  unwrapped="$( { printf '%s' "$LOOP" | grep -nE '(^|[^_a-z-])claude --model' || true; } | { grep -vE 'with_timeout' || true; } | wc -l | tr -d ' ')"
  if [ "$unwrapped" = "0" ]; then
    echo "PASS: every claude call in the loop runs under a timeout"; PASS=$((PASS+1))
  else
    echo "FAIL: $unwrapped claude call(s) in the loop are not wrapped in with_timeout"; FAIL=$((FAIL+1))
  fi
fi

# --- Mount wait --------------------------------------------------------------
check_present 'until \[ -r .*run-nightly\.sh' "loop waits for the vault mount before cd"
check_present 'ThrottleInterval' "phase explains the launchd relaunch path"

# --- Idle sleep --------------------------------------------------------------
check_present 'hold_awake_start' "loop holds a block-scoped idle-sleep assertion"
check_present 'hold_awake_stop' "loop releases the assertion when the block ends"
check_present 'caffeinate -i -w' "assertion is scoped to the loop pid and leaves lid sleep alone"

# --- Auto-reload on edit -----------------------------------------------------
check_present 'SCRIPT_MTIME_AT_START' "loop records its own mtime at start"
check_present 'exec bash .*SCRIPT_FILE' "loop re-execs itself when the script changes"

# --- Checkpointing -----------------------------------------------------------
check_present 'run_pass\(\) \{' "loop has a checkpointed pass helper"
check_present '\.pass-.*-done-' "passes checkpoint to a per-day done sentinel"
check_present '\.pass-.*-attempts-' "passes count attempts so a broken pass gives up"
# In-memory date variables lose their state on the launchd re-exec that a failure causes,
# which is what made the old loop replay completed work.
check_absent 'NIGHTLY_DONE_DATE=|BRIEFING_DONE_DATE=|WEEK_AHEAD_DONE_DATE=' \
  "no in-memory done-date variables (markers are files)"

# --- Catch-up mode -----------------------------------------------------------
check_present '\-\-once\|once\|catchup' "loop supports a one-shot catch-up mode"
check_present 'ONCE_MAX' "catch-up mode is bounded"

# --- Partial output ----------------------------------------------------------
# A briefing written straight to its real path leaves a half-file behind on timeout, and the
# next iteration's existence check then treats that stub as today's finished briefing.
check_present 'BRIEF_FILE\.partial' "briefing is written to a partial path and moved on success"

# --- Demonstrate the timeout rather than asserting it ------------------------
PROBE="$(mktemp -d)"
extract_block 'with-timeout: first arg must be an integer' > "$PROBE/with-timeout.sh"
if [ ! -s "$PROBE/with-timeout.sh" ]; then
  echo "FAIL: could not extract with-timeout.sh from the phase"; FAIL=$((FAIL+1))
else
  chmod +x "$PROBE/with-timeout.sh"
  set +e
  bash "$PROBE/with-timeout.sh" 1 sleep 5 >/dev/null 2>&1; timed_out=$?
  bash "$PROBE/with-timeout.sh" 5 true   >/dev/null 2>&1; passed_through=$?
  bash "$PROBE/with-timeout.sh" 5 sh -c 'exit 3' >/dev/null 2>&1; propagated=$?
  set -e
  if [ "$timed_out" -eq 124 ]; then
    echo "PASS: a command over budget is killed and exits 124"; PASS=$((PASS+1))
  else
    echo "FAIL: expected exit 124 on timeout, got $timed_out"; FAIL=$((FAIL+1))
  fi
  if [ "$passed_through" -eq 0 ] && [ "$propagated" -eq 3 ]; then
    echo "PASS: a command under budget keeps its own exit code"; PASS=$((PASS+1))
  else
    echo "FAIL: exit codes not propagated (true=$passed_through, exit3=$propagated)"; FAIL=$((FAIL+1))
  fi
fi
rm -rf "$PROBE"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]

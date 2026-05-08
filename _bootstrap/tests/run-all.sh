#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"

TOTAL_PASS=0
TOTAL_FAIL=0
SUITES=0

run_suite() {
  local script="$1"
  local name
  name="$(basename "$script")"
  echo ""
  echo "--- $name ---"

  local output exit_code
  output=$(bash "$script" 2>&1) || exit_code=$?
  exit_code=${exit_code:-0}

  echo "$output"

  # Extract pass/fail counts from the script's own summary line
  local p f
  p=$(echo "$output" | grep -E '^Results:' | grep -oE '[0-9]+ passed' | grep -oE '[0-9]+' || echo 0)
  f=$(echo "$output" | grep -E '^Results:' | grep -oE '[0-9]+ failed' | grep -oE '[0-9]+' || echo 0)

  TOTAL_PASS=$((TOTAL_PASS + p))
  TOTAL_FAIL=$((TOTAL_FAIL + f))
  SUITES=$((SUITES + 1))
}

# Numbered phase test scripts, sorted (null-delimited to handle spaces in path)
while IFS= read -r -d '' script; do
  run_suite "$script"
done < <(find "$DIR" -maxdepth 1 -name '[0-9][0-9]-*.sh' -print0 | sort -z)

# validate-paths.sh if present
if [ -f "$DIR/validate-paths.sh" ]; then
  run_suite "$DIR/validate-paths.sh"
fi

echo ""
echo "=== TOTAL: $TOTAL_PASS passed, $TOTAL_FAIL failed across $SUITES suites ==="

[ "$TOTAL_FAIL" -eq 0 ] && exit 0 || exit 1

#!/usr/bin/env bash
# Guards the test harness against silently swallowing a crashed suite.
# A suite that aborts before printing its "Results:" line used to contribute 0 passed / 0 failed,
# so run-all.sh reported green while a whole suite had crashed. Points run-all.sh at a fixture
# dir via TESTS_DIR and asserts a crashing fixture makes the aggregate fail, while an all-good
# fixture set passes.
set -uo pipefail
echo "=== 17-run-all-integrity ==="
DIR="$(cd "$(dirname "$0")" && pwd)"
RA="$DIR/run-all.sh"
PASS=0; FAIL=0
ok(){ echo "  ok: $1"; PASS=$((PASS + 1)); }
no(){ echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

cat > "$TMP/01-good.sh" <<'FIX'
echo "some output"
echo "Results: 3 passed, 0 failed"
FIX
# Aborts under set -u before printing any Results line, exits non-zero.
cat > "$TMP/02-crash.sh" <<'FIX'
set -u
echo "starting"
echo "$this_var_is_undefined"
echo "Results: 1 passed, 0 failed"
FIX

OUT="$(TESTS_DIR="$TMP" bash "$RA" 2>&1)"; rc=$?
[ "$rc" -ne 0 ] && ok "crashed suite makes run-all exit non-zero" || no "run-all reported success despite a crashed suite"
echo "$OUT" | grep -q "02-crash.sh produced no 'Results:' line" && ok "crash is named in the output" || no "crash not surfaced"
echo "$OUT" | grep -qE '=== TOTAL: [0-9]+ passed, [1-9][0-9]* failed' && ok "TOTAL reflects the crash as a failure" || no "TOTAL still shows 0 failed"

rm -f "$TMP/02-crash.sh"
OUT2="$(TESTS_DIR="$TMP" bash "$RA" 2>&1)"; rc2=$?
[ "$rc2" -eq 0 ] && ok "all-good fixture set exits 0" || no "clean set wrongly failed (rc=$rc2)"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]

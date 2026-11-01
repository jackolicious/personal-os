#!/usr/bin/env bash
# No test that runs under pipefail may pipe a multi-line producer into `grep -q`.
#
# grep -q exits at its first match. When that match is not the producer's last line, the
# producer's next write takes SIGPIPE, pipefail returns 141, and the check fails on correct
# output. Whether it bites depends on line order, so a check can pass for months and then fail
# once its data reorders (a date that starts sorting after the matched line, for example).
# Use `grep PATTERN >/dev/null`, which reads all input, or capture the output first.
set -uo pipefail
echo "=== 18-no-grep-q-under-pipefail ==="
PASS=0; FAIL=0
DIR="$(cd "$(dirname "$0")" && pwd)"
scan() {  # files... -> offending file:line
  for f in "$@"; do
    grep -q pipefail "$f" 2>/dev/null || continue
    # echo and printf are builtins that write the whole string in one call, under the 64 KB pipe
    # buffer, so they finish before grep exits. Scripts, awk, sed, and grep write in pieces.
    grep -nE '\|[[:space:]]*grep[[:space:]]+-[a-zA-Z]*q' "$f" 2>/dev/null \
      | grep -vE '^[0-9]+:[[:space:]]*#' \
      | grep -vE '^[0-9]+:[^|]*(echo|printf)[^|]*\|[[:space:]]*grep[[:space:]]+-[a-zA-Z]*q' \
      | sed "s#^#${f##*/}:#"
  done
}
# Hermetic: the detector catches the planted shape and passes the safe form.
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
printf 'set -o pipefail\nawk "{print}" f | grep -q a && echo ok\n' > "$T/bad.sh"
printf 'set -o pipefail\nawk "{print}" f | grep a >/dev/null && echo ok\necho "$X" | grep -q a\n' > "$T/good.sh"
if [ -n "$(scan "$T/bad.sh")" ] && [ -z "$(scan "$T/good.sh")" ]; then
  echo "PASS: detector flags | grep -q and passes | grep >/dev/null"; PASS=$((PASS + 1))
else
  echo "FAIL: detector is broken"; FAIL=$((FAIL + 1))
fi
# Live: no test under pipefail uses the shape.
hits="$(scan $(ls "$DIR"/[0-9]*.sh | grep -v "/18-no-grep-q"))"
if [ -z "$hits" ]; then
  echo "PASS: no pipefail test pipes into grep -q"; PASS=$((PASS + 1))
else
  echo "FAIL: these pipefail tests pipe into grep -q, use 'grep PATTERN >/dev/null' or capture first:"
  echo "$hits" | sed 's/^/  /'
  FAIL=$((FAIL + 1))
fi
echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]

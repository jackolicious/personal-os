#!/usr/bin/env bash
# Verify Phase 8 ships a working local notification bus, by extracting both scripts from the
# phase markdown and running them against a temp queue. Assertions on the markdown alone would
# pass on a bus that cannot fire, so this drives the real code with a frozen clock.
#
# The bus exists so a workflow can reach the vault owner later without the system picking a
# messaging integration on their behalf. It holds no state a rerun can corrupt: --id replaces
# an un-fired entry, and an expired entry is dropped rather than fired late.
set -euo pipefail
PASS=0; FAIL=0
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PHASE="$ROOT/_bootstrap/phases/08-automation.md"

ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }

extract_block() {
  awk -v pat="$1" '
    /^```/ { if (inb) { if (buf ~ pat) { printf "%s", buf; exit } ; inb=0; buf="" } else { inb=1; buf="" } ; next }
    inb { buf = buf $0 "\n" }
  ' "$PHASE"
}

echo "=== 12-notification-bus ==="

grep -q 'notify-enqueue\.sh' "$PHASE" && ok "phase creates notify-enqueue.sh" || bad "phase creates notify-enqueue.sh"
grep -q 'notify-drain\.sh'   "$PHASE" && ok "phase creates notify-drain.sh"   || bad "phase creates notify-drain.sh"
grep -q 'notify-drain\.sh' <(extract_block 'Personal OS, persistent automation loop') \
  && ok "the loop drains the queue every iteration" || bad "the loop never calls notify-drain.sh"
grep -q 'terminal-notifier' "$PHASE" && ok "phase names the terminal-notifier dependency" || bad "terminal-notifier dependency undocumented"

# The bus must not need an LLM or a network call. A notification path that depends on either
# stops working in exactly the degraded conditions it exists to report.
BUS="$(extract_block 'notify-drain: lock timeout')$(extract_block 'notify-enqueue: lock timeout')"
if printf '%s' "$BUS" | grep -qE 'claude --|curl |https?://'; then
  bad "the bus reaches for an LLM or the network"
else
  ok "the bus is pure local shell"
fi

# --- Drive the real scripts --------------------------------------------------
T="$(mktemp -d)"
mkdir -p "$T/_system/scripts" "$T/_system/queues" "$T/_system/logs"
extract_block 'notify-enqueue: lock timeout' > "$T/_system/scripts/notify-enqueue.sh"
extract_block 'notify-drain: lock timeout'   > "$T/_system/scripts/notify-drain.sh"
chmod +x "$T/_system/scripts/"*.sh

if [ ! -s "$T/_system/scripts/notify-enqueue.sh" ] || [ ! -s "$T/_system/scripts/notify-drain.sh" ]; then
  bad "could not extract both bus scripts from the phase"
  rm -rf "$T"
  echo ""; echo "Results: $PASS passed, $FAIL failed"; [ "$FAIL" -eq 0 ]; exit
fi

Q="$T/_system/queues/notifications.tsv"
NOW=1800000000
enq() { NOTIFY_QUEUE="$Q" NOTIFY_NOW="$NOW" bash "$T/_system/scripts/notify-enqueue.sh" "$@" >/dev/null; }
drain() { NOTIFY_QUEUE="$Q" NOTIFY_LOG="$T/_system/logs/n.log" NOTIFY_NOW="${1:-$NOW}" NOTIFY_DRYRUN=1 \
          bash "$T/_system/scripts/notify-drain.sh"; }

# 1. A due entry fires, a future one is held.
enq --id due    --title "Due"    --message "now"   --now
enq --id future --title "Future" --message "later" --in 60
out="$(drain)"
printf '%s' "$out" | grep -q 'WOULD-FIRE: due'    && ok "a due entry fires" || bad "a due entry did not fire"
printf '%s' "$out" | grep -q 'WOULD-FIRE: future' && bad "a future entry fired early" || ok "a future entry is held"
grep -q '^future' "$Q" && ok "the held entry stays queued" || bad "the held entry was dropped"
grep -q '^due' "$Q" && bad "a fired entry stayed in the queue" || ok "a fired entry leaves the queue"

# 2. Re-enqueuing the same id replaces the un-fired entry, so a producer that runs twice
#    (a retried pass, a catch-up run) never doubles a ping.
enq --id dupe --title "First"  --message "one" --in 60
enq --id dupe --title "Second" --message "two" --in 60
count="$(grep -c '^dupe' "$Q" || true)"
[ "$count" = "1" ] && ok "--id replaces rather than appends" || bad "--id produced $count rows, expected 1"
grep -q 'Second' "$Q" && ok "the replacement kept the newer payload" || bad "replacement kept the stale payload"

# 3. An entry whose window has passed is dropped, not fired late. Without this, a machine that
#    slept through the night wakes up and dumps a pile of stale meeting pings at once.
enq --id stale --title "Stale" --message "gone" --at "$((NOW + 60))" --expire-in 5
out="$(drain $((NOW + 600)))"
printf '%s' "$out" | grep -q 'WOULD-FIRE: stale' && bad "an expired entry fired late" || ok "an expired entry is dropped"
grep -q '^stale' "$Q" && bad "the expired entry stayed queued" || ok "the expired entry left the queue"

# 4. Field alignment survives empty interior fields. `IFS=$'\t' read` collapses consecutive
#    tabs because tab is IFS-whitespace, which silently shifts every field after an empty one.
enq --id sparse --title "Title here" --message "Message here" --now   # no subtitle, no url, no icon
out="$(drain)"
printf '%s' "$out" | grep -q 'WOULD-FIRE: sparse' && ok "an entry with empty interior fields fires" || bad "empty interior fields broke the row"
grep -q 'FIRED sparse :: Title here :: Message here' "$T/_system/logs/n.log" \
  && ok "title and message stay in their own columns" || bad "field alignment shifted"

# 5. A malformed row is dropped with a log line rather than taking the drain down, so one bad
#    producer cannot wedge every future notification behind it.
printf 'broken\tnot-a-number\tT\t\tM\t\t\t\t\n' >> "$Q"
enq --id after --title "After" --message "still works" --now
out="$(drain)"
printf '%s' "$out" | grep -q 'WOULD-FIRE: after' && ok "a malformed row does not block the queue" || bad "a malformed row wedged the queue"
grep -q 'malformed row dropped' "$T/_system/logs/n.log" && ok "the malformed row is logged" || bad "the malformed row vanished silently"

rm -rf "$T"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]

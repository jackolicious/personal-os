#!/usr/bin/env bash
set -euo pipefail

echo "=== 03-claude-md ==="

PASS=0; FAIL=0
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PHASE="$ROOT/_bootstrap/phases/03-claude-md.md"

check_present() {
  local pattern="$1" label="$2"
  if grep -q "$pattern" "$PHASE" 2>/dev/null; then
    echo "PASS: $label"; PASS=$((PASS+1))
  else
    echo "FAIL: $label — pattern not found: $pattern"; FAIL=$((FAIL+1))
  fi
}

check_absent() {
  local pattern="$1" label="$2"
  if grep -q "$pattern" "$PHASE" 2>/dev/null; then
    echo "FAIL: $label — pattern found but should be absent: $pattern"; FAIL=$((FAIL+1))
  else
    echo "PASS: $label"; PASS=$((PASS+1))
  fi
}

check_count_gte() {
  local pattern="$1" min="$2" label="$3"
  local count
  count=$(grep -c "$pattern" "$PHASE" 2>/dev/null || true)
  if [ "$count" -ge "$min" ]; then
    echo "PASS: $label ($count matches)"; PASS=$((PASS+1))
  else
    echo "FAIL: $label — expected >=$min, got $count"; FAIL=$((FAIL+1))
  fi
}

# ── Root CLAUDE.md ──────────────────────────────────────────────────────────

echo ""
echo "-- Root CLAUDE.md template --"

check_present "## Model routing" "model routing table present"
check_present "## Rules" "rules section present"
check_present "synthesis-log\.json" "rule: check synthesis-log.json before processing"
check_present "Knowledge/annotated/" "rule: never modify Knowledge/annotated/"
check_present "Open loops.*append only\|append only.*open loops\|Open loops: append only" \
  "rule: open loops append only"
check_present "append dated sections" "rule: wiki pages append dated sections"

echo ""
echo "-- Root CLAUDE.md: commands --"
check_present "personal-os-daily-briefing" "command: personal-os-daily-briefing"
check_present "personal-os-cascade" "command: personal-os-cascade"
check_present "personal-os-1on1-prep" "command: personal-os-1on1-prep"
check_present "personal-os-nightly" "command: personal-os-nightly"
check_present "personal-os-week-ahead\|personal-os-open-loops" \
  "command: personal-os-open-loops"
check_present "personal-os-open-loops" "command: personal-os-open-loops (exact)"
check_present "personal-os-remember\|personal-os-new-1on1" \
  "command: personal-os-remember or personal-os-new-1on1"
check_present "personal-os-new-1on1" "command: personal-os-new-1on1"
check_present "personal-os-career-evidence\|personal-os-interview-prep" \
  "command: personal-os-career-evidence or interview prep equivalent"

echo ""
echo "-- Root CLAUDE.md: system map directories --"
check_present "Inbox/" "system map: Inbox/"
check_present "1on1s/" "system map: 1on1s/"
check_present "Meetings/" "system map: Meetings/"
check_present "Knowledge/" "system map: Knowledge/"
check_present "People/" "system map: People/"
check_present "Interviews/" "system map: Interviews/"
check_present "profile/" "system map: profile/"
check_present "_system/" "system map: _system/"

echo ""
echo "-- Root CLAUDE.md: always load --"
check_present "GOALS\.md" "always load: GOALS.md"
check_present "HEARTBEAT\.md" "always load: HEARTBEAT.md"
check_present "PILLARS\.md" "always load: PILLARS.md"
check_present "profile/preferences/synthesis\.md" "always load: profile/preferences/synthesis.md"

# ── Inbox/CLAUDE.md ─────────────────────────────────────────────────────────

echo ""
echo "-- Inbox/CLAUDE.md template --"

check_present "YYYY-MM-DD" "inbox: file naming convention YYYY-MM-DD"
check_present "Never modify originals\|never modify originals" \
  "inbox: rule never modify originals"
check_present "archive\|Inbox/archive" "inbox: rule archive after processing"
check_present "synthesis-log\.json" "inbox: log in synthesis-log.json"
check_present "immutable" "inbox: originals in archive are immutable"

# ── Knowledge/CLAUDE.md ─────────────────────────────────────────────────────

echo ""
echo "-- Knowledge/CLAUDE.md template --"

check_present "annotated/" "knowledge: layers table has annotated/"
check_present "source_type" "knowledge: annotation metadata field source_type"
check_present "original:" "knowledge: annotation metadata field original"
check_present "processed_at" "knowledge: annotation metadata field processed_at"
check_present "relevance:" "knowledge: annotation metadata field relevance"
check_present "key_concepts" "knowledge: annotation metadata field key_concepts"
check_present "connections:" "knowledge: annotation metadata field connections"
check_present "append.*dated sections\|dated sections.*append\|append a new dated section" \
  "knowledge: rule append dated sections"
check_present "Never rewrite\|never rewrite\|Never rewrite existing" \
  "knowledge: rule never rewrite"
check_present "## Definition\|## Summary" "knowledge: wiki page format with Definition or Summary section"

# ── 1on1s/CLAUDE.md ─────────────────────────────────────────────────────────

echo ""
echo "-- 1on1s/CLAUDE.md template --"

check_present "_index\.md" "1on1s: references _index.md"
check_present "person-folder\.md\|person folder" "1on1s: references person-folder.md template"
check_present "personal-os-new-1on1" "1on1s: references /personal-os-new-1on1"

# ── Meetings/CLAUDE.md ──────────────────────────────────────────────────────

echo ""
echo "-- Meetings/CLAUDE.md template --"

check_present "YYYY-MM-DD-\[slug\]\|YYYY-MM-DD-\[" "meetings: folder pattern YYYY-MM-DD-[slug]"
check_present "Owner:" "meetings: action-items.md Owner column"
check_present "Due:" "meetings: action-items.md Due column"
check_present "Priority:" "meetings: action-items.md Priority column"
check_present "Source:" "meetings: action-items.md Source column"
check_present "Completed\|never deleted\|never delete" \
  "meetings: completed items rule"

# ── People/CLAUDE.md ────────────────────────────────────────────────────────

echo ""
echo "-- People/CLAUDE.md template --"

check_present "team\.md" "people: references team.md"
check_present "stakeholders\.md" "people: references stakeholders.md"
check_present "Last contact:" "people: stakeholder entry format has Last contact: field"

# ── Interviews/CLAUDE.md ────────────────────────────────────────────────────

echo ""
echo "-- Interviews/CLAUDE.md template --"

check_present "_index\.md" "interviews: references _index.md"
check_present "role-context\.md" "interviews: references role-context.md"
check_present "question-bank\.md" "interviews: references question-bank.md"
check_present "notes/" "interviews: references notes/"

# ── Forbidden ───────────────────────────────────────────────────────────────

echo ""
echo "-- Forbidden patterns --"

check_absent "Knowledge/sources/" "Knowledge/sources/ must not appear anywhere"

# ── Summary ─────────────────────────────────────────────────────────────────

echo ""
echo "Results: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi

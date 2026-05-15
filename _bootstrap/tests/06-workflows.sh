#!/usr/bin/env bash
# Tests that _bootstrap/phases/06-workflows.md defines all workflow playbooks
# completely and internally consistently.
# Run from the repo root: bash _bootstrap/tests/06-workflows.sh

set -euo pipefail

PASS=0; FAIL=0
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FILE="_bootstrap/phases/06-workflows.md"

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

echo "=== 06-workflows ==="
echo ""

# ---------------------------------------------------------------------------
# daily-briefing
# ---------------------------------------------------------------------------
echo "-- daily-briefing --"

check_present "$FILE" "daily-briefing" \
  "daily-briefing: workflow file defined"

check_present "$FILE" "Model: Sonnet" \
  "daily-briefing: model is Sonnet"

check_present "$FILE" "HEARTBEAT.md" \
  "daily-briefing: loads HEARTBEAT.md"

check_present "$FILE" "GOALS.md" \
  "daily-briefing: loads GOALS.md"

check_present "$FILE" "profile/preferences/briefing.md" \
  "daily-briefing: loads profile/preferences/briefing.md"

check_present "$FILE" "Inbox/_unrouted.md" \
  "daily-briefing: checks Inbox/_unrouted.md"

check_present "$FILE" "_system/data/open-loops.json" \
  "daily-briefing: loads open-loops.json"

check_present "$FILE" "threshold" \
  "daily-briefing: references commitment load thresholds"

check_present "$FILE" "People/team.md" \
  "daily-briefing: checks People/team.md for last contact"

check_present "$FILE" "People/stakeholders.md" \
  "daily-briefing: checks People/stakeholders.md for last contact"

check_present "$FILE" "14 days" \
  "daily-briefing: 14-day threshold for direct reports"

check_present "$FILE" "21 days" \
  "daily-briefing: 21-day threshold for stakeholders"

check_present "$FILE" "_system/data/decisions.json" \
  "daily-briefing: reads decisions.json"

check_present "$FILE" "_system/data/synthesis-log.json" \
  "daily-briefing: reads synthesis-log.json"

check_present "$FILE" "### Today's focus" \
  "daily-briefing: output includes ### Today's focus"

check_present "$FILE" "### Open loops requiring action" \
  "daily-briefing: output includes ### Open loops requiring action"

check_present "$FILE" "_system/briefings/" \
  "daily-briefing: outputs to _system/briefings/"

echo ""

# ---------------------------------------------------------------------------
# cascade
# ---------------------------------------------------------------------------
echo "-- cascade --"

check_present "$FILE" "cascade.md" \
  "cascade: workflow file defined"

check_present "$FILE" "Cadence: Weekly" \
  "cascade: cadence is Weekly"

check_present "$FILE" "Down" \
  "cascade: Down audience variant defined"

check_present "$FILE" "Lateral" \
  "cascade: Lateral audience variant defined"

check_present "$FILE" "Up" \
  "cascade: Up audience variant defined"

check_present "$FILE" "profile/preferences/writing-style.md" \
  "cascade: loads writing-style.md"

check_present "$FILE" "explicit approval" \
  "cascade: requires explicit approval before saving"

check_present "$FILE" "Meetings/YYYY-MM-DD-cascade.md" \
  "cascade: saves to Meetings/YYYY-MM-DD-cascade.md"

check_present "$FILE" "Last Cascade Sent" \
  "cascade: updates HEARTBEAT.md Last Cascade Sent"

echo ""

# ---------------------------------------------------------------------------
# meeting-notes
# ---------------------------------------------------------------------------
echo "-- meeting-notes --"

check_present "$FILE" "meeting-notes.md" \
  "meeting-notes: workflow file defined"

check_present "$FILE" "Identify the meeting type" \
  "meeting-notes: identifies 1on1 vs team meeting"

check_present "$FILE" "synthesis-log.json" \
  "meeting-notes: checks synthesis-log.json hash"

check_present "$FILE" "raw.md" \
  "meeting-notes: creates immutable raw.md"

check_present "$FILE" "open-loops.json" \
  "meeting-notes: updates open-loops.json"

check_present "$FILE" "Inbox/archive/" \
  "meeting-notes: archives to Inbox/archive/"

echo ""

# ---------------------------------------------------------------------------
# pdf-ingestion
# ---------------------------------------------------------------------------
echo "-- pdf-ingestion --"

check_present "$FILE" "pdf-ingestion.md" \
  "pdf-ingestion: workflow file defined"

check_present "$FILE" "markitdown" \
  "pdf-ingestion: prerequisite markitdown listed"

check_present "$FILE" "Knowledge/annotated/" \
  "pdf-ingestion: files to Knowledge/annotated/"

check_present "$FILE" "Inbox/archive/pdfs/" \
  "pdf-ingestion: archives to Inbox/archive/pdfs/"

check_present "$FILE" "synthesis-log.json" \
  "pdf-ingestion: logs to synthesis-log.json"

echo ""

# ---------------------------------------------------------------------------
# note-ingestion
# ---------------------------------------------------------------------------
echo "-- note-ingestion --"

check_present "$FILE" "note-ingestion.md" \
  "note-ingestion: workflow file defined"

check_present "$FILE" "Knowledge/annotated/" \
  "note-ingestion: files to Knowledge/annotated/"

check_present "$FILE" "Inbox/_archive/" \
  "note-ingestion: archives to Inbox/_archive/"

check_present "$FILE" "Inbox/_index.md" \
  "note-ingestion: updates Inbox/_index.md"

check_present "$FILE" "synthesis-log.json" \
  "note-ingestion: logs to synthesis-log.json"

echo ""

# ---------------------------------------------------------------------------
# link-ingestion
# ---------------------------------------------------------------------------
echo "-- link-ingestion --"

check_present "$FILE" "link-ingestion.md" \
  "link-ingestion: workflow file defined"

check_present "$FILE" "http://" \
  "link-ingestion: extracts http:// URLs"

check_present "$FILE" "https://" \
  "link-ingestion: extracts https:// URLs"

check_present "$FILE" "WebFetch" \
  "link-ingestion: uses WebFetch"

check_present "$FILE" "Knowledge/annotated/" \
  "link-ingestion: files to Knowledge/annotated/"

check_present "$FILE" "60 chars" \
  "link-ingestion: slug truncated to 60 chars"

check_present "$FILE" "Inbox/_archive/" \
  "link-ingestion: archives to Inbox/_archive/"

check_present "$FILE" "synthesis-log.json" \
  "link-ingestion: logs to synthesis-log.json"

echo ""

# ---------------------------------------------------------------------------
# 1on1-prep
# ---------------------------------------------------------------------------
echo "-- 1on1-prep --"

check_present "$FILE" "1on1-prep.md" \
  "1on1-prep: workflow file defined"

check_present "$FILE" "ready-note.md" \
  "1on1-prep: checks for existing ready-note.md"

check_present "$FILE" "2 most recent" \
  "1on1-prep: reads only 2 most recent session summaries"

check_present "$FILE" "context_person" \
  "1on1-prep: filters open-loops.json by context_person"

check_present "$FILE" "profile/preferences/1on1.md" \
  "1on1-prep: loads profile/preferences/1on1.md"

check_present "$FILE" "1on1-session.md" \
  "1on1-prep: creates session file from template"

echo ""

# ---------------------------------------------------------------------------
# nightly-synthesis
# ---------------------------------------------------------------------------
echo "-- nightly-synthesis --"

check_present "$FILE" "nightly-synthesis.md" \
  "nightly-synthesis: workflow file defined"

check_present "$FILE" "2am" \
  "nightly-synthesis: cadence is 2am nightly"

check_present "$FILE" "Haiku" \
  "nightly-synthesis: Phase 1 uses Haiku"

check_present "$FILE" "Sonnet" \
  "nightly-synthesis: Phase 2 uses Sonnet"

check_present "$FILE" "Inbox/_index.md" \
  "nightly-synthesis: checks Inbox/_index.md for pending files"

check_present "$FILE" "isolated" \
  "nightly-synthesis: processes each file in isolated subprocess"

check_present "$FILE" "APPEND" \
  "nightly-synthesis: updates wiki pages with dated sections (APPEND)"

check_present "$FILE" "PILLARS.md" \
  "nightly-synthesis: pillar auto-tagging from PILLARS.md"

check_present "$FILE" "Deduplication" \
  "nightly-synthesis: deduplication pass on open loops"

check_present "$FILE" "Career evidence extraction" \
  "nightly-synthesis: career evidence extraction step"

check_present "$FILE" "Last contact:" \
  "nightly-synthesis: updates Last contact: in person files"

# All four _index.md files must be mentioned
check_count_gte "$FILE" "_index.md" 4 \
  "nightly-synthesis: references at least 4 _index.md files"

check_present "$FILE" "<!-- MANUAL -->" \
  "nightly-synthesis: rebuilds ready notes preserving MANUAL blocks"

check_present "$FILE" "Last Nightly Synthesis" \
  "nightly-synthesis: updates HEARTBEAT.md Last Nightly Synthesis"

check_present "$FILE" "1st of the month" \
  "nightly-synthesis: wiki-lint runs on 1st of each month"

echo ""

# ---------------------------------------------------------------------------
# career-evidence
# ---------------------------------------------------------------------------
echo "-- career-evidence --"

check_present "$FILE" "career-evidence.md" \
  "career-evidence: workflow file defined"

check_present "$FILE" "90 days" \
  "career-evidence: default time range is 90 days"

check_present "$FILE" "career-evidence-digest.md" \
  "career-evidence: uses career-evidence-digest.md template"

check_present "$FILE" "profile/career/" \
  "career-evidence: saves brag doc to profile/career/"

echo ""

# ---------------------------------------------------------------------------
# week-ahead
# ---------------------------------------------------------------------------
echo "-- week-ahead --"

check_present "$FILE" "week-ahead.md" \
  "week-ahead: workflow file defined"

check_present "$FILE" "_system/briefings/week-ahead-" \
  "week-ahead: saves to _system/briefings/week-ahead-"

check_present "$FILE" "### This week's schedule" \
  "week-ahead: output includes ### This week's schedule"

check_present "$FILE" "### Meetings needing prep" \
  "week-ahead: output includes ### Meetings needing prep"

check_present "$FILE" "### Focus work this week" \
  "week-ahead: output includes ### Focus work this week"

check_present "$FILE" "requires_focus" \
  "week-ahead: surfaces loops where requires_focus = true"

echo ""

# ---------------------------------------------------------------------------
# wiki-lint
# ---------------------------------------------------------------------------
echo "-- wiki-lint --"

check_present "$FILE" "wiki-lint.md" \
  "wiki-lint: workflow file defined"

check_present "$FILE" "1st of each month" \
  "wiki-lint: trigger is 1st of each month"

check_present "$FILE" "orphan" \
  "wiki-lint: checks for orphan pages"

check_present "$FILE" "stale" \
  "wiki-lint: checks for stale pages"

check_present "$FILE" "Concept gap" \
  "wiki-lint: checks for concept gaps"

check_present "$FILE" "Knowledge/wiki/_lint-report.md" \
  "wiki-lint: writes _lint-report.md"

check_present "$FILE" "Knowledge/wiki/log.md" \
  "wiki-lint: appends to Knowledge/wiki/log.md"

echo ""

# ---------------------------------------------------------------------------
# wiki-query
# ---------------------------------------------------------------------------
echo "-- wiki-query --"

check_present "$FILE" "wiki-query" \
  "wiki-query: workflow file defined"

check_present "$FILE" "personal-os-query" \
  "wiki-query: trigger is /personal-os-query"

check_present "$FILE" "Rank matched pages\|Rank" \
  "wiki-query: ranks pages by relevance"

check_present "$FILE" "one hop only" \
  "wiki-query: wikilink traversal bounded to one hop"

check_present "$FILE" "conditional\|Conditional\|Only run this step" \
  "wiki-query: annotated source fallback is conditional"

check_present "$FILE" "Nothing in the wiki" \
  "wiki-query: no-match case returns explicit message"

check_present "$FILE" "personal-os-remember" \
  "wiki-query: offers to save via /personal-os-remember"

echo ""

# ---------------------------------------------------------------------------
# wiki-remember
# ---------------------------------------------------------------------------
echo "-- wiki-remember --"

check_present "$FILE" "wiki-remember.md" \
  "wiki-remember: workflow file defined"

check_present "$FILE" "personal-os-remember" \
  "wiki-remember: trigger is /personal-os-remember"

check_present "$FILE" "Propose 1" \
  "wiki-remember: proposes 1-3 filing options before writing"

check_present "$FILE" "explicit" \
  "wiki-remember: requires explicit confirmation before writing"

check_present "$FILE" "Knowledge/wiki/_index.md" \
  "wiki-remember: updates Knowledge/wiki/_index.md"

check_present "$FILE" "Knowledge/wiki/log.md" \
  "wiki-remember: appends to Knowledge/wiki/log.md"

echo ""

# ---------------------------------------------------------------------------
# meeting-prep
# ---------------------------------------------------------------------------
echo "-- meeting-prep --"

check_present "$FILE" "meeting-prep" \
  "meeting-prep: workflow file defined"

check_present "$FILE" "meeting-prep.md" \
  "meeting-prep: references workflow file path"

check_present "$FILE" "calendar_source" \
  "meeting-prep: calendar source handling present"

check_present "$FILE" "NO_CALENDAR" \
  "meeting-prep: NO_CALENDAR graceful degradation defined"

check_present "$FILE" "executive" \
  "meeting-prep: meeting type classification defined"

check_present "$FILE" "Meetings/prep" \
  "meeting-prep: output path defined"

check_present "$FILE" "OMIT\|brevity\|Brevity" \
  "meeting-prep: brevity rules present"

echo ""

# ---------------------------------------------------------------------------
# ghostwriter-init
# ---------------------------------------------------------------------------
echo "-- ghostwriter-init --"

check_present "$FILE" "ghostwriter-init" \
  "ghostwriter-init: workflow file defined"

check_present "$FILE" "ghostwriter-init\.md" \
  "ghostwriter-init: references workflow file path"

check_present "$FILE" "Knowledge/writing/samples\.md" \
  "ghostwriter-init: reads Knowledge/writing/samples.md"

check_present "$FILE" "Knowledge/writing/style-guide\.md" \
  "ghostwriter-init: writes Knowledge/writing/style-guide.md"

check_present "$FILE" "NO_SAMPLES" \
  "ghostwriter-init: NO_SAMPLES graceful degradation defined"

echo ""

# ---------------------------------------------------------------------------
# ghostwriter
# ---------------------------------------------------------------------------
echo "-- ghostwriter --"

check_present "$FILE" "ghostwriter\.md" \
  "ghostwriter: workflow file defined"

check_present "$FILE" "style-guide\.md" \
  "ghostwriter: reads style-guide.md"

check_present "$FILE" "DRAFT" \
  "ghostwriter: DRAFT mode defined"

check_present "$FILE" "POLISH" \
  "ghostwriter: POLISH mode defined"

check_present "$FILE" "slack" \
  "ghostwriter: slack content type defined"

check_present "$FILE" "external" \
  "ghostwriter: external content type defined"

check_present "$FILE" "em dash\|Em dash\|em-dash" \
  "ghostwriter: humanizer pass removes em dashes"

check_present "$FILE" "AI vocab\|AI writing\|delve\|utilize" \
  "ghostwriter: humanizer pass removes AI vocabulary"

echo ""

# ---------------------------------------------------------------------------
# Forbidden patterns
# ---------------------------------------------------------------------------
echo "-- forbidden patterns --"

check_absent "$FILE" "Knowledge/sources/" \
  "forbidden: Knowledge/sources/ must not appear anywhere"

echo ""

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
TOTAL=$((PASS + FAIL))
echo "Results: $PASS passed, $FAIL failed ($TOTAL total)"
echo ""

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi

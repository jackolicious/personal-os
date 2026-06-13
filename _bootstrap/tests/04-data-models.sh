#!/usr/bin/env bash
# Tests that _bootstrap/phases/04-data.md fully specifies all required data schemas.
# Run from the repo root: bash _bootstrap/tests/04-data-models.sh

set -euo pipefail

PASS=0; FAIL=0
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FILE="_bootstrap/phases/04-data.md"

check_present() {
  local file="$ROOT/$1" pattern="$2" label="$3"
  if grep -q "$pattern" "$file" 2>/dev/null; then
    echo "PASS: $label"; PASS=$((PASS+1))
  else
    echo "FAIL: $label — not found in $1"; FAIL=$((FAIL+1))
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

echo "=== 04-data-models ==="
echo ""

# ---------------------------------------------------------------------------
# open-loops.json
# ---------------------------------------------------------------------------
echo "-- open-loops.json schema --"

check_present "$FILE" 'open-loops\.json'          "open-loops.json file referenced"
check_present "$FILE" '"schema_version": 2'        "open-loops: schema_version is 2"
check_present "$FILE" '"loops"'                    "open-loops: loops array defined"

check_present "$FILE" '"id"'                       "open-loops: id field defined"
check_present "$FILE" '"title"'                    "open-loops: title field defined"
check_present "$FILE" '"canonical_id"'             "open-loops: canonical_id field defined"
check_present "$FILE" '"owner"'                    "open-loops: owner field defined"
check_present "$FILE" '"context_person"'           "open-loops: context_person field defined"
check_present "$FILE" '"context_meeting"'          "open-loops: context_meeting field defined"
check_present "$FILE" '"project"'                  "open-loops: project field defined"
check_present "$FILE" '"pillar"'                   "open-loops: pillar field defined"
check_present "$FILE" '"requires_focus"'           "open-loops: requires_focus field defined"
check_present "$FILE" '"priority"'                 "open-loops: priority field defined"
check_present "$FILE" '"status"'                   "open-loops: status field defined"
check_present "$FILE" '"opened_date"'              "open-loops: opened_date field defined"
check_present "$FILE" '"due_date"'                 "open-loops: due_date field defined"
check_present "$FILE" '"closed_date"'              "open-loops: closed_date field defined"
check_present "$FILE" '"closed_in"'                "open-loops: closed_in field defined"
check_present "$FILE" '"notes"'                    "open-loops: notes field defined"
check_present "$FILE" '"source_files"'             "open-loops: source_files field defined"

check_present "$FILE" 'critical'                   "open-loops: priority value 'critical' defined"
check_present "$FILE" 'high'                       "open-loops: priority value 'high' defined"
check_present "$FILE" 'medium'                     "open-loops: priority value 'medium' defined"
check_present "$FILE" 'low'                        "open-loops: priority value 'low' defined"

check_present "$FILE" '"open'                      "open-loops: status value 'open' defined"
check_present "$FILE" 'in-progress'                "open-loops: status value 'in-progress' defined"
check_present "$FILE" 'blocked'                    "open-loops: status value 'blocked' defined"
check_present "$FILE" 'archived'                   "open-loops: status value 'archived' defined"
check_present "$FILE" 'merged'                     "open-loops: status value 'merged' defined"

echo ""

# ---------------------------------------------------------------------------
# decisions.json
# ---------------------------------------------------------------------------
echo "-- decisions.json schema --"

check_present "$FILE" 'decisions\.json'            "decisions.json file referenced"
check_present "$FILE" '"decisions"'                "decisions: decisions array defined"
check_present "$FILE" '"dec-001"'                  "decisions: schema_version field defined (via dec-001 example)"
check_present "$FILE" '"decision"'                 "decisions: decision field defined"
check_present "$FILE" '"made_by"'                  "decisions: made_by field defined"
check_present "$FILE" '"context"'                  "decisions: context field defined"
check_present "$FILE" '"alternatives_considered"'  "decisions: alternatives_considered field defined"
check_present "$FILE" '"source_file"'              "decisions: source_file field defined"
check_present "$FILE" '"review_date"'              "decisions: review_date field defined"

echo ""

# ---------------------------------------------------------------------------
# career-evidence.json
# ---------------------------------------------------------------------------
echo "-- career-evidence.json schema --"

check_present "$FILE" 'career-evidence\.json'      "career-evidence.json file referenced"
check_present "$FILE" '"evidence"'                 "career-evidence: evidence array defined"
check_present "$FILE" '"ev-001"'                   "career-evidence: id with ev- prefix shown"
check_present "$FILE" '"type"'                     "career-evidence: type field defined"
check_present "$FILE" '"detail"'                   "career-evidence: detail field defined"
check_present "$FILE" '"from"'                     "career-evidence: from field defined"
check_present "$FILE" '"tags"'                     "career-evidence: tags field defined"
check_present "$FILE" '"starred"'                  "career-evidence: starred field defined"

check_present "$FILE" 'feedback'                   "career-evidence: type value 'feedback' defined"
check_present "$FILE" 'outcome'                    "career-evidence: type value 'outcome' defined"
check_present "$FILE" 'growth'                     "career-evidence: type value 'growth' defined"

check_present "$FILE" '"ev-'                       "career-evidence: ev- ID prefix present in schema"

echo ""

# ---------------------------------------------------------------------------
# synthesis-log.json
# ---------------------------------------------------------------------------
echo "-- synthesis-log.json schema --"

check_present "$FILE" 'synthesis-log\.json'        "synthesis-log.json file referenced"
check_present "$FILE" '"schema_version": 2'        "synthesis-log: schema_version is 2"
check_present "$FILE" '"last_nightly_run"'         "synthesis-log: last_nightly_run field defined"
check_present "$FILE" '"preference_tuning"'        "synthesis-log: preference_tuning object defined"
check_present "$FILE" '"start_date"'               "synthesis-log: preference_tuning.start_date defined"
check_present "$FILE" '"last_tuning_run"'           "synthesis-log: preference_tuning.last_tuning_run defined"
check_present "$FILE" '"tuning_count"'             "synthesis-log: preference_tuning.tuning_count defined"
check_present "$FILE" '"current_schedule"'         "synthesis-log: preference_tuning.current_schedule defined"
check_present "$FILE" '"next_tuning_date"'         "synthesis-log: preference_tuning.next_tuning_date defined"
check_present "$FILE" '"processed_files"'          "synthesis-log: processed_files object defined"

check_present "$FILE" '"hash"'                     "synthesis-log: per-file hash field defined"
check_present "$FILE" '"processed_at"'             "synthesis-log: per-file processed_at field defined"
check_present "$FILE" '"processing_type"'          "synthesis-log: per-file processing_type field defined"
check_present "$FILE" '"output_files"'             "synthesis-log: per-file output_files field defined"
check_present "$FILE" '"wiki_connections_made"'    "synthesis-log: per-file wiki_connections_made field defined"
check_present "$FILE" '"open_loops_created"'       "synthesis-log: per-file open_loops_created field defined"
check_present "$FILE" '"career_evidence_created"'  "synthesis-log: per-file career_evidence_created field defined"
check_present "$FILE" '"annotation_version"'       "synthesis-log: per-file annotation_version field defined"

check_present "$FILE" 'annotation'                 "synthesis-log: processing_type value 'annotation' defined"
check_present "$FILE" 'summary'                    "synthesis-log: processing_type value 'summary' defined"
check_present "$FILE" 'synthesis'                  "synthesis-log: processing_type value 'synthesis' defined"
check_present "$FILE" 'connection'                 "synthesis-log: processing_type value 'connection' defined"

echo ""

# ---------------------------------------------------------------------------
# Index file schemas
# ---------------------------------------------------------------------------
echo "-- Index file schemas --"

check_present "$FILE" '1on1s/_index\.md'           "1on1s/_index.md referenced"
check_present "$FILE" 'Name'                        "1on1s/_index.md: Name column defined"
check_present "$FILE" 'Last session'                "1on1s/_index.md: Last session column defined"
check_present "$FILE" 'Sessions'                    "1on1s/_index.md: Sessions column defined"
check_present "$FILE" 'Open loops'                  "1on1s/_index.md: Open loops column defined"
check_present "$FILE" 'Last contact'                "1on1s/_index.md: Last contact column defined"

check_present "$FILE" 'Knowledge/wiki/_index\.md'  "Knowledge/wiki/_index.md referenced"
check_present "$FILE" 'Page'                        "wiki/_index.md: Page column defined"
check_present "$FILE" 'Concepts'                    "wiki/_index.md: Concepts column defined"
check_present "$FILE" 'Sources'                     "wiki/_index.md: Sources column defined"
check_present "$FILE" 'Last updated'                "wiki/_index.md: Last updated column defined"

check_present "$FILE" 'Meetings/_index\.md'         "Meetings/_index.md referenced"
check_present "$FILE" 'Title'                       "Meetings/_index.md: Title column defined"
check_present "$FILE" 'Type'                        "Meetings/_index.md: Type column defined"
check_present "$FILE" 'Participants'                "Meetings/_index.md: Participants column defined"
check_present "$FILE" 'Action items'                "Meetings/_index.md: Action items column defined"

check_present "$FILE" 'Knowledge/annotated/_index\.md' "Knowledge/annotated/_index.md referenced"
check_present "$FILE" 'Key concepts'                "annotated/_index.md: Key concepts column defined"
check_present "$FILE" 'Filed'                        "annotated/_index.md: Filed column defined"
check_present "$FILE" 'Knowledge/annotated/`, `Interviews/' "annotated/_index.md created with other indexes at scaffold"

check_present "$FILE" 'Inbox/_index\.md'            "Inbox/_index.md referenced"
check_present "$FILE" 'File'                        "Inbox/_index.md: File column defined"
check_present "$FILE" 'Status'                      "Inbox/_index.md: Status column defined"
check_present "$FILE" 'Added'                       "Inbox/_index.md: Added column defined"

check_present "$FILE" 'transcript'                  "Inbox: Type value 'transcript' defined"
check_present "$FILE" 'pdf'                         "Inbox: Type value 'pdf' defined"
check_present "$FILE" 'note'                        "Inbox: Type value 'note' defined"
check_present "$FILE" 'link'                        "Inbox: Type value 'link' defined"
check_present "$FILE" 'unrouted'                    "Inbox: Type value 'unrouted' defined"

check_present "$FILE" 'pending'                     "Inbox: Status value 'pending' defined"
check_present "$FILE" 'processed'                   "Inbox: Status value 'processed' defined"
check_present "$FILE" 'flagged'                     "Inbox: Status value 'flagged' defined"

echo ""

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
TOTAL=$((PASS + FAIL))
echo "Results: $PASS passed, $FAIL failed ($TOTAL total)"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi

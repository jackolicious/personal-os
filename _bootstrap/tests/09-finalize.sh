#!/usr/bin/env bash
set -euo pipefail
PASS=0; FAIL=0
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PHASE="$ROOT/_bootstrap/phases/09-finalize.md"

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

# Helper: check against the phase file itself
phase_present() {
  local pattern="$1" label="$2"
  if grep -q "$pattern" "$PHASE" 2>/dev/null; then
    echo "PASS: $label"; PASS=$((PASS+1))
  else
    echo "FAIL: $label — not found in 09-finalize.md"; FAIL=$((FAIL+1))
  fi
}

echo "=== 09-finalize.sh ==="

# --- Validation checklist ---
phase_present 'CLAUDE.md.*7\+\|7+ CLAUDE\|7.*CLAUDE.md\|CLAUDE.md.*7' \
  "CLAUDE.md count check (>=7) present"
phase_present 'synthesis-log.json' \
  "synthesis-log.json validation present"
phase_present 'open-loops.json' \
  "open-loops.json validation present"
phase_present '11 command\|command.*11\|commands/.*11\|11.*command' \
  "Command files count check (>=11) present"
phase_present '8 workflow\|workflow.*8\|workflows/.*8\|8.*workflow' \
  "Workflow files count check (>=8) present"
phase_present '5 files\|5 file\|show 5\|five files\|preferences/.*5' \
  "Preference files count check (5 files) present"
phase_present 'run-nightly.sh.*executable\|executable.*run-nightly\|bash run-nightly' \
  "run-nightly.sh executable/startup check present"
phase_present 'PILLARS.md' \
  "PILLARS.md content check present"

# --- Cleanup: save design rationale ---
phase_present 'Knowledge/wiki/system-design.md' \
  "Saves context to Knowledge/wiki/system-design.md"
phase_present '_bootstrap/context.md\|design rationale' \
  "_bootstrap/context.md design rationale referenced"

# --- system-design.md frontmatter ---
phase_present 'source_type:' \
  "system-design.md frontmatter includes source_type: field"
phase_present 'ingested:' \
  "system-design.md frontmatter includes ingested: field"

# --- Wiki index and log updates ---
phase_present 'Knowledge/wiki/_index.md' \
  "Updates Knowledge/wiki/_index.md with new entry"
phase_present 'Knowledge/wiki/log.md' \
  "Appends to Knowledge/wiki/log.md"

# --- Hard deletion ---
phase_present 'rm -rf _bootstrap\|rm -rf.*_bootstrap' \
  "Hard-deletes _bootstrap/ directory (rm -rf)"
phase_present 'rm.*personal-os-bootstrap.md\|personal-os-bootstrap.md.*rm' \
  "Deletes personal-os-bootstrap.md"

# --- archive.sh fallback also hard-deletes ---
phase_present 'archive.sh' \
  "archive.sh fallback mentioned"

# --- First-week rituals: all 5 ---
phase_present 'personal-os-daily-briefing\|daily-briefing\|daily briefing' \
  "First-week ritual: daily briefing mentioned"
phase_present 'personal-os-1on1-prep\|1on1-prep\|1on1 prep' \
  "First-week ritual: 1on1-prep mentioned"
phase_present 'personal-os-process-inbox\|process-inbox\|process inbox' \
  "First-week ritual: process-inbox mentioned"
phase_present 'personal-os-ingest-url\|ingest-url\|ingest url' \
  "First-week ritual: ingest-url mentioned"
phase_present 'personal-os-cascade\|cascade' \
  "First-week ritual: cascade mentioned"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1

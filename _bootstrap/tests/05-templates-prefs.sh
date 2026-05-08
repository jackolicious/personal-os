#!/usr/bin/env bash
# Tests that _bootstrap/phases/05-templates.md fully defines all required
# templates and preference modules.
# Run from the repo root: bash _bootstrap/tests/05-templates-prefs.sh

set -euo pipefail

PASS=0; FAIL=0
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FILE="_bootstrap/phases/05-templates.md"

check_present() {
  local file="$ROOT/$1" pattern="$2" label="$3"
  if grep -q "$pattern" "$file" 2>/dev/null; then
    echo "PASS: $label"; PASS=$((PASS+1))
  else
    echo "FAIL: $label — not found in $1"; FAIL=$((FAIL+1))
  fi
}

echo "=== 05-templates-prefs ==="
echo ""

# ---------------------------------------------------------------------------
# Template: 1on1-session.md
# ---------------------------------------------------------------------------
echo "-- 1on1-session.md --"
check_present "$FILE" "1on1-session\.md"             "1on1-session.md template defined"
check_present "$FILE" "^date:"                        "1on1-session.md frontmatter: date:"
check_present "$FILE" "^person:"                      "1on1-session.md frontmatter: person:"
check_present "$FILE" "^session_number:"              "1on1-session.md frontmatter: session_number:"
check_present "$FILE" "## Check-in"                   "1on1-session.md section: ## Check-in"
check_present "$FILE" "## Their agenda"               "1on1-session.md section: ## Their agenda"
check_present "$FILE" "## My agenda"                  "1on1-session.md section: ## My agenda"
check_present "$FILE" "## Key topics discussed"       "1on1-session.md section: ## Key topics discussed"
check_present "$FILE" "## Commitments"                "1on1-session.md section: ## Commitments"
check_present "$FILE" "## Themes observed"            "1on1-session.md section: ## Themes observed"
check_present "$FILE" "## Follow-up for next session" "1on1-session.md section: ## Follow-up for next session"
check_present "$FILE" "Commitment"                    "1on1-session.md commitments table: Commitment column"
check_present "$FILE" "Owner"                         "1on1-session.md commitments table: Owner column"
check_present "$FILE" "Due"                           "1on1-session.md commitments table: Due column"
check_present "$FILE" "Priority"                      "1on1-session.md commitments table: Priority column"
echo ""

# ---------------------------------------------------------------------------
# Template: 1on1-summary.md
# ---------------------------------------------------------------------------
echo "-- 1on1-summary.md --"
check_present "$FILE" "1on1-summary\.md"             "1on1-summary.md template defined"
check_present "$FILE" "^processed_at:"               "1on1-summary.md frontmatter: processed_at:"
check_present "$FILE" "## One-line read"             "1on1-summary.md section: ## One-line read"
check_present "$FILE" "## Decisions made"            "1on1-summary.md section: ## Decisions made"
check_present "$FILE" "## Open loops opened"         "1on1-summary.md section: ## Open loops opened"
check_present "$FILE" "## Open loops closed"         "1on1-summary.md section: ## Open loops closed"
check_present "$FILE" "## Themes"                    "1on1-summary.md section: ## Themes"
check_present "$FILE" "## Notable signals"           "1on1-summary.md section: ## Notable signals"
echo ""

# ---------------------------------------------------------------------------
# Template: meeting-summary.md
# ---------------------------------------------------------------------------
echo "-- meeting-summary.md --"
check_present "$FILE" "meeting-summary\.md"          "meeting-summary.md template defined"
check_present "$FILE" "^meeting:"                    "meeting-summary.md frontmatter: meeting:"
check_present "$FILE" "^attendees:"                  "meeting-summary.md frontmatter: attendees:"
check_present "$FILE" "## Purpose"                   "meeting-summary.md section: ## Purpose"
check_present "$FILE" "## Key decisions"             "meeting-summary.md section: ## Key decisions"
check_present "$FILE" "## Action items"              "meeting-summary.md section: ## Action items"
check_present "$FILE" "## Context captured"          "meeting-summary.md section: ## Context captured"
check_present "$FILE" "## Follow-up needed"          "meeting-summary.md section: ## Follow-up needed"
echo ""

# ---------------------------------------------------------------------------
# Template: source-annotation.md
# ---------------------------------------------------------------------------
echo "-- source-annotation.md --"
check_present "$FILE" "source-annotation\.md"        "source-annotation.md template defined"
check_present "$FILE" "^source_type:"                "source-annotation.md frontmatter: source_type:"
check_present "$FILE" "^original:"                   "source-annotation.md frontmatter: original:"
check_present "$FILE" "^relevance:"                  "source-annotation.md frontmatter: relevance:"
check_present "$FILE" "^key_concepts:"               "source-annotation.md frontmatter: key_concepts:"
check_present "$FILE" "^connections:"                "source-annotation.md frontmatter: connections:"
check_present "$FILE" "^open_questions:"             "source-annotation.md frontmatter: open_questions:"
check_present "$FILE" "## Summary"                   "source-annotation.md section: ## Summary"
check_present "$FILE" "## Key concepts"              "source-annotation.md section: ## Key concepts"
check_present "$FILE" "## Inferences"                "source-annotation.md section: ## Inferences"
check_present "$FILE" "## Open questions raised"     "source-annotation.md section: ## Open questions raised"
check_present "$FILE" "## Connections"               "source-annotation.md section: ## Connections"
echo ""

# ---------------------------------------------------------------------------
# Template: cascade-update.md
# ---------------------------------------------------------------------------
echo "-- cascade-update.md --"
check_present "$FILE" "cascade-update\.md"           "cascade-update.md template defined"
check_present "$FILE" "^week_of:"                    "cascade-update.md frontmatter: week_of:"
check_present "$FILE" "^audience:"                   "cascade-update.md frontmatter: audience:"
check_present "$FILE" "## The headline"              "cascade-update.md section: ## The headline"
check_present "$FILE" "## What happened"             "cascade-update.md section: ## What happened"
check_present "$FILE" "## What's next"               "cascade-update.md section: ## What's next"
check_present "$FILE" "## What I need from you"      "cascade-update.md section: ## What I need from you"
echo ""

# ---------------------------------------------------------------------------
# Template: 1on1-ready-note.md
# ---------------------------------------------------------------------------
echo "-- 1on1-ready-note.md --"
check_present "$FILE" "1on1-ready-note\.md"          "1on1-ready-note.md template defined"
check_present "$FILE" "## Priority Open Loops"       "1on1-ready-note.md section: ## Priority Open Loops"
check_present "$FILE" "## Last Session Highlights"   "1on1-ready-note.md section: ## Last Session Highlights"
check_present "$FILE" "## My Notes"                  "1on1-ready-note.md section: ## My Notes"
check_present "$FILE" "## Recent Action Items"       "1on1-ready-note.md section: ## Recent Action Items"
check_present "$FILE" "## Session History"           "1on1-ready-note.md section: ## Session History"
check_present "$FILE" "<!-- MANUAL"                  "1on1-ready-note.md marker: <!-- MANUAL -->"
check_present "$FILE" "<!-- END MANUAL"              "1on1-ready-note.md marker: <!-- END MANUAL -->"
echo ""

# ---------------------------------------------------------------------------
# Template: person-folder.md
# ---------------------------------------------------------------------------
echo "-- person-folder.md --"
check_present "$FILE" "person-folder\.md"            "person-folder.md template defined"
check_present "$FILE" "\*\*Role:\*\*"                "person-folder.md field: **Role:**"
check_present "$FILE" "\*\*Slack:\*\*"               "person-folder.md field: **Slack:**"
check_present "$FILE" "\*\*Last contact:\*\*"        "person-folder.md field: **Last contact:**"
check_present "$FILE" "\*\*Sessions:\*\*"            "person-folder.md field: **Sessions:**"
check_present "$FILE" "## Key context"               "person-folder.md section: ## Key context"
check_present "$FILE" "## Themes"                    "person-folder.md section: ## Themes"
check_present "$FILE" "## Open loops"                "person-folder.md section: ## Open loops"
echo ""

# ---------------------------------------------------------------------------
# Template: career-evidence-digest.md
# ---------------------------------------------------------------------------
echo "-- career-evidence-digest.md --"
check_present "$FILE" "career-evidence-digest\.md"   "career-evidence-digest.md template defined"
check_present "$FILE" "## Feedback received"         "career-evidence-digest.md section: ## Feedback received"
check_present "$FILE" "## Outcomes delivered"        "career-evidence-digest.md section: ## Outcomes delivered"
check_present "$FILE" "## Growth moments"            "career-evidence-digest.md section: ## Growth moments"
echo ""

# ---------------------------------------------------------------------------
# Template: wiki-page.md
# ---------------------------------------------------------------------------
echo "-- wiki-page.md --"
check_present "$FILE" "wiki-page\.md"                "wiki-page.md template defined"
check_present "$FILE" "^concept:"                    "wiki-page.md frontmatter: concept:"
check_present "$FILE" "^aliases:"                    "wiki-page.md frontmatter: aliases:"
check_present "$FILE" "^sources:"                    "wiki-page.md frontmatter: sources:"
check_present "$FILE" "^last_updated:"               "wiki-page.md frontmatter: last_updated:"
check_present "$FILE" "\*\*Summary:\*\*"             "wiki-page.md section: **Summary:**"
check_present "$FILE" "\*\*Key points:\*\*"          "wiki-page.md section: **Key points:**"
check_present "$FILE" "\*\*Related:\*\*"             "wiki-page.md section: **Related:**"
check_present "$FILE" "\*\*Open questions:\*\*"      "wiki-page.md section: **Open questions:**"
check_present "$FILE" "nightly synthesis"            "wiki-page.md nightly synthesis comment marker present"
echo ""

# ---------------------------------------------------------------------------
# Preference: synthesis.md
# ---------------------------------------------------------------------------
echo "-- preferences/synthesis.md --"
check_present "$FILE" "preferences/synthesis\.md"    "synthesis.md preference defined"
check_present "$FILE" "\*\*Last Updated:\*\*"        "synthesis.md field: Last Updated:"
check_present "$FILE" "\*\*Tuning Count:\*\*"        "synthesis.md field: Tuning Count:"
check_present "$FILE" "## What I care about most"   "synthesis.md section: ## What I care about most"
check_present "$FILE" "## Style"                     "synthesis.md section: ## Style"
check_present "$FILE" "## Feedback log"              "synthesis.md section: ## Feedback log"
check_present "$FILE" "\- Depth:"                    "synthesis.md style subfield: Depth:"
check_present "$FILE" "\- Format:"                   "synthesis.md style subfield: Format:"
check_present "$FILE" "\- What to always flag:"      "synthesis.md style subfield: What to always flag:"
echo ""

# ---------------------------------------------------------------------------
# Preference: briefing.md
# ---------------------------------------------------------------------------
echo "-- preferences/briefing.md --"
check_present "$FILE" "preferences/briefing\.md"     "briefing.md preference defined"
check_present "$FILE" "## Open loop display order"   "briefing.md section: ## Open loop display order"
check_present "$FILE" "## Coaching tone"             "briefing.md section: ## Coaching tone"
check_present "$FILE" "## Length"                    "briefing.md section: ## Length"
check_present "$FILE" "## What to always include"   "briefing.md section: ## What to always include"
check_present "$FILE" "## Commitment load thresholds" "briefing.md section: ## Commitment load thresholds"
check_present "$FILE" "critical"                     "briefing.md threshold: critical"
check_present "$FILE" "high"                         "briefing.md threshold: high"
echo ""

# ---------------------------------------------------------------------------
# Preference: writing-style.md
# ---------------------------------------------------------------------------
echo "-- preferences/writing-style.md --"
check_present "$FILE" "preferences/writing-style\.md" "writing-style.md preference defined"
check_present "$FILE" "## My voice"                  "writing-style.md section: ## My voice"
check_present "$FILE" "## Format defaults"           "writing-style.md section: ## Format defaults"
check_present "$FILE" "## Cascade drafts"            "writing-style.md section: ## Cascade drafts"
echo ""

# ---------------------------------------------------------------------------
# Preference: 1on1.md
# ---------------------------------------------------------------------------
echo "-- preferences/1on1.md --"
check_present "$FILE" "preferences/1on1\.md"         "1on1.md preference defined"
check_present "$FILE" "## What to surface"           "1on1.md section: ## What to surface"
check_present "$FILE" "## Default priority"          "1on1.md section: ## Default priority"
check_present "$FILE" "## Probing questions"         "1on1.md section: ## Probing questions"
echo ""

# ---------------------------------------------------------------------------
# Preference: knowledge.md
# ---------------------------------------------------------------------------
echo "-- preferences/knowledge.md --"
check_present "$FILE" "preferences/knowledge\.md"    "knowledge.md preference defined"
check_present "$FILE" "\*\*Update schedule:\*\*"     "knowledge.md field: Update schedule:"
check_present "$FILE" "## Currently relevant topics" "knowledge.md section: ## Currently relevant topics"
check_present "$FILE" "## Relevance criteria"        "knowledge.md section: ## Relevance criteria"
echo ""

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]

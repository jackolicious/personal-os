#!/usr/bin/env bash
# Verify the brief workflow ships two working detectors, by extracting both from the phase
# markdown and running them against fixtures written here.
#
# Asserting that the scripts are mentioned would pass on a detector that catches nothing, which
# is the failure mode that matters: the original phrase list scored zero on five real
# violations produced in a live session, and nobody noticed because the lint kept exiting 0.
# So every rule below is proved by feeding it a violation and a clean control.
set -euo pipefail
PASS=0; FAIL=0
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
AUTOMATION="$ROOT/_bootstrap/phases/08-automation.md"
WORKFLOWS="$ROOT/_bootstrap/phases/06-workflows.md"

ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }

check() {
  local file="$1" pattern="$2" label="$3"
  if grep -qiE "$pattern" "$file" 2>/dev/null; then ok "$label"; else bad "$label, not found in $(basename "$file")"; fi
}

extract_block() {
  awk -v pat="$2" '
    /^```/ { if (inb) { if (buf ~ pat) { printf "%s", buf; exit } ; inb=0; buf="" } else { inb=1; buf="" } ; next }
    inb { buf = buf $0 "\n" }
  ' "$1"
}

echo "=== 15-brief-audit ==="

# --- Wiring ---
check "$WORKFLOWS"  'workflows/brief\.md'      "brief workflow exists"
check "$WORKFLOWS"  'voice-lint\.py'           "workflow runs the phrase detector"
check "$WORKFLOWS"  'brief-lint\.py'           "workflow runs the structure detector"
check "$AUTOMATION" 'scripts/voice-lint\.py'   "phase creates voice-lint.py"
check "$AUTOMATION" 'scripts/brief-lint\.py'   "phase creates brief-lint.py"
check "$ROOT/_bootstrap/phases/07-commands.md" 'personal-os-brief\.md' "slash command exists"

# --- The rules that make the workflow more than a prose template ---
check "$WORKFLOWS" 'Diagnose before rewriting' "revise mode diagnoses before it rewrites"
check "$WORKFLOWS" 'One ask'                   "the one-ask rule survives"
check "$WORKFLOWS" 'prove the argument wrong'  "the falsifier requirement survives"
check "$WORKFLOWS" 'lands once'                "the claim-inventory rule survives"
check "$WORKFLOWS" 'Never auto-write to a shared' "drafts stay vault-local"
check "$WORKFLOWS" 'Version, do not overwrite' "a revision becomes the next version file"

# The diagnosis has to precede the rewrite in the document too. A workflow that lists the audit
# after the rewrite steps invites a silent rewrite, which is the behaviour it exists to stop.
diag="$(grep -n 'Diagnose before rewriting' "$WORKFLOWS" | head -1 | cut -d: -f1 || true)"
apply="$(grep -n 'Ask once whether to apply' "$WORKFLOWS" | head -1 | cut -d: -f1 || true)"
if [ -n "$diag" ] && [ -n "$apply" ] && [ "$diag" -lt "$apply" ]; then
  ok "the diagnosis step precedes the apply step"
else
  bad "the diagnosis step does not precede the apply step"
fi

# --- Drive the real detectors ---
if ! command -v python3 >/dev/null 2>&1; then
  echo "SKIP: python3 not available, detector behaviour unchecked"
else
  T="$(mktemp -d)"
  extract_block "$AUTOMATION" 'Detect the AI' > "$T/voice-lint.py"
  extract_block "$AUTOMATION" 'Detect document-STRUCTURE' > "$T/brief-lint.py"

  if [ ! -s "$T/voice-lint.py" ] || [ ! -s "$T/brief-lint.py" ]; then
    bad "could not extract both detectors from the phase"
  else
    # One POSITIVE fixture per category, each scoped with --categories so a fixture cannot be
    # satisfied by a different rule firing. Without this the suite passed with 8 of 14 category
    # lists emptied, which is the same defect one level up from the one this file was written to
    # catch: a detector that catches nothing, guarded by a test that never asks it to.
    vlcat() { python3 "$T/voice-lint.py" --file "$2" --categories "$1" 2>/dev/null || true; }

    fixture() { # category, label, content
      printf '%b' "$3" > "$T/fx.md"
      if vlcat "$1" "$T/fx.md" | grep -q "$1"; then
        ok "$1 catches $2"
      else
        bad "$1 missed $2"
      fi
    }

    EM="$(printf '\xe2\x80\x94')"
    fixture em_dash            "an em dash"                  "A sentence ${EM} with a clause break.\n"
    fixture prose_semicolon    "a prose semicolon"           "We shipped it; the number moved.\n"
    fixture sycophancy         "opener flattery"             "Great question. Here is my answer.\n"
    fixture throat_clearing    "a filler preamble"           "It is worth noting that revenue rose.\n"
    fixture binary_contrast    "a leading binary contrast"   "It is not a bug, it is a feature.\n"
    fixture binary_contrast    "a trailing binary contrast"  "A backstop for links, not for broken ones.\n"
    fixture binary_contrast    "a split binary contrast"     "The release was not delayed. It was cancelled.\n"
    fixture negative_listing   "stacked negations"           "The pitch was no fluff, no filler.\n"
    fixture rhetorical_setup   "a self-posed question"       "The migration? Nobody owns it.\n"
    fixture tee_up             "a tee-up"                    "Importantly, the migration lands first.\n"
    fixture structure_narration "argument narration"         "This distinction matters for pricing.\n"
    fixture self_vouching      "self-vouching"               "To be direct, the plan is behind.\n"
    fixture meta_commentary    "document narration"          "Let us dive in and unpack the numbers.\n"
    fixture rule_of_three      "an aphoristic triple"        "The build is fast, cheap, and reliable.\n"
    fixture rule_of_three      "a sentence-initial triple"   "Fast, cheap, and reliable.\n"
    fixture count_announcement "a heading count"             "## Two asks:\n"
    fixture count_announcement "an inline count"             "Two asks: fund it and staff it.\n"
    fixture unquantified_claim "an unquantified claim"       "Our review found little evidence it is costing us.\n"

    # Controls. A detector that fires on clean prose gets turned off by its user, at which point
    # it protects nothing, so the quiet cases carry as many assertions as the loud ones.
    quiet() { # category, label, content
      printf '%b' "$3" > "$T/ct.md"
      if vlcat "$1" "$T/ct.md" | grep -q "$1"; then
        bad "$1 fires on $2"
      else
        ok "$1 stays quiet on $2"
      fi
    }

    quiet rule_of_three    "a proper-noun list"        "The reviewers are Ada, Grace, and Katherine.\n"
    quiet prose_semicolon  "a semicolon inside code"   'Use \`a; b\` in code.\n'
    quiet prose_semicolon  "a semicolon inside a URL"  "See [the doc](https://x.example/a;b) for detail.\n"
    quiet prose_semicolon  "a semicolon in a table"    "| Col | Val |\n|---|---|\n| a | x; y |\n"
    quiet binary_contrast  "a factual correction"      "Send the draft to the design team, not legal.\n"
    quiet em_dash          "a hyphenated range"        "The Q1-Q2 numbers held.\n"

    # Curly quotes. Every apostrophe-bearing pattern is written with a straight quote, and text
    # from a word processor or a model carries U+2019, so without a fold the linter reports
    # textbook AI prose as clean.
    printf 'Here\xe2\x80\x99s the thing, we should ship.\n' > "$T/smart.md"
    if vlcat throat_clearing "$T/smart.md" | grep -q throat_clearing; then
      ok "a curly apostrophe does not hide a violation"
    else
      bad "a curly apostrophe hides a violation"
    fi

    # An unterminated fence used to blank the rest of the file and still exit 0.
    printf 'Clean line.\n\x60\x60\x60\ncode\nGreat question. Here is the thing.\n' > "$T/unbal.md"
    if vlcat sycophancy "$T/unbal.md" | grep -q sycophancy; then
      ok "an unterminated code fence does not hide the rest of the file"
    else
      bad "an unterminated code fence hides everything after it"
    fi

    # A path that cannot be read is an error. Reporting zero findings tells the caller the draft
    # is clean, so a workflow run against a typo would report an audit it never performed.
    set +e
    python3 "$T/voice-lint.py" --file "$T/does-not-exist.md" >/dev/null 2>&1; missing_rc=$?
    python3 "$T/voice-lint.py" --file "$T/fx.md" --categories not_a_category >/dev/null 2>&1; badcat_rc=$?
    set -e
    [ "$missing_rc" -eq 2 ] && ok "an unreadable path exits 2 rather than reporting clean" \
      || bad "an unreadable path exits $missing_rc, which reads as clean"
    [ "$badcat_rc" -eq 2 ] && ok "an unknown category is an error rather than a silent full scan" \
      || bad "an unknown category exits $badcat_rc and scans everything"

    # brief-lint: structure rules, each with a fixture.
    blint() { python3 "$T/brief-lint.py" --file "$1" 2>/dev/null || true; }

    printf 'Author: someone\nStatus: draft\n\n## Executive summary\n\nShip it.\n' > "$T/b1.md"
    blint "$T/b1.md" | grep -q preamble && ok "catches a metadata preamble" || bad "missed a metadata preamble"

    { printf '## Executive summary\n\n'; python3 -c "print('word '*120)"; } > "$T/b2.md"
    blint "$T/b2.md" | grep -q fat_summary && ok "catches an executive summary that stopped summarizing" || bad "missed a fat summary"

    { printf '## Body\n\n'; python3 -c "print('word '*120)"; } > "$T/b3.md"
    blint "$T/b3.md" | grep -q long_para && ok "catches a paragraph past the verbosity cap" || bad "missed a long paragraph"

    printf '## Risk\n\nThe residual risk is commercial.\n' > "$T/b4.md"
    blint "$T/b4.md" | grep -q abstract_label && ok "catches a category label where a plain noun belongs" || bad "missed an abstract label"

    # A summary asserts, the body proves. This rule had no fixture, so emptying it passed.
    printf '## Executive summary\n\nThe vendor said "we have never shipped a migration of this size and we do not intend to start now" last week.\n' > "$T/b6.md"
    blint "$T/b6.md" | grep -q summary_quote && ok "catches a long quotation in the executive summary" || bad "missed a quotation in the summary"

    # A heading followed straight away by text is valid markdown, and dropping that block used to
    # switch every section rule off for the section.
    printf '## Risk\nThe residual risk is commercial.\n' > "$T/b7.md"
    blint "$T/b7.md" | grep -q abstract_label && ok "a heading with no blank line after it is still scored" || bad "a heading with no blank line disabled its section"

    # Quoting at length is the author choosing to quote, which is a different judgment call.
    { printf '## Body\n\n'; for i in $(seq 1 20); do printf '> quoted words go here and here and here\n'; done; } > "$T/b8.md"
    blint "$T/b8.md" | grep -q long_para && bad "fires on a long block quote" || ok "stays quiet on a long block quote"

    printf 'A note from the author: we should ship.\n\n## Executive summary\n\nShip.\n' > "$T/b9.md"
    blint "$T/b9.md" | grep -q preamble && bad "fires on the word author mid-sentence" || ok "stays quiet on the word author mid-sentence"

    set +e
    python3 "$T/brief-lint.py" --file "$T/does-not-exist.md" >/dev/null 2>&1; bl_missing=$?
    set -e
    [ "$bl_missing" -eq 2 ] && ok "brief-lint exits 2 on an unreadable path" || bad "brief-lint exits $bl_missing on an unreadable path"

    # A table or a list is not a paragraph, and flagging one would make the tool useless on any
    # doc that carries data.
    { printf '## Body\n\n'; for i in $(seq 1 40); do printf -- '- a list row with several words in it\n'; done; } > "$T/b5.md"
    blint "$T/b5.md" | grep -q long_para && bad "fires on a long list" || ok "stays quiet on a long list"

    # Exit codes, since the workflow and any hook branch on them.
    printf 'Clean prose with nothing to find.\n' > "$T/clean.md"
    printf 'Great question. It is worth noting that revenue rose.\n' > "$T/dirty.md"
    set +e
    python3 "$T/voice-lint.py" --file "$T/clean.md" >/dev/null 2>&1; clean_rc=$?
    python3 "$T/voice-lint.py" --file "$T/dirty.md" >/dev/null 2>&1; dirty_rc=$?
    count="$(python3 "$T/voice-lint.py" --count --file "$T/dirty.md" 2>/dev/null)"
    set -e
    [ "$clean_rc" -eq 0 ] && [ "$dirty_rc" -eq 1 ] && ok "exit 0 on clean prose, exit 1 on a finding" \
      || bad "exit codes wrong (clean=$clean_rc dirty=$dirty_rc)"
    [ "$count" -ge 2 ] 2>/dev/null && ok "--count returns a number the workflow can report" \
      || bad "--count did not return a usable number (got '$count')"
  fi
  rm -rf "$T"
fi

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]

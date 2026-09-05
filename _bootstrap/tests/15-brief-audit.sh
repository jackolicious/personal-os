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
    # voice-lint: one fixture per rule, plus a control that must stay silent.
    vl() { python3 "$T/voice-lint.py" --file "$1" 2>/dev/null || true; }

    printf 'It is a backstop for links, not for broken ones.\n' > "$T/f1.md"
    vl "$T/f1.md" | grep -q binary_contrast && ok "catches a trailing binary contrast" || bad "missed a trailing binary contrast"

    printf 'The release was not delayed. It was cancelled.\n' > "$T/f2.md"
    vl "$T/f2.md" | grep -q binary_contrast && ok "catches a binary contrast split across sentences" || bad "missed a split binary contrast"

    printf 'Great question. Here is the thing, we should ship.\n' > "$T/f3.md"
    out="$(vl "$T/f3.md")"
    printf '%s' "$out" | grep -q sycophancy      && ok "catches sycophancy"      || bad "missed sycophancy"
    printf '%s' "$out" | grep -q throat_clearing && ok "catches throat clearing" || bad "missed throat clearing"

    printf 'We shipped it in March, and the number moved.\n' > "$T/f4.md"
    printf 'Importantly, the migration lands first.\n' >> "$T/f4.md"
    vl "$T/f4.md" | grep -q tee_up && ok "catches a tee-up" || bad "missed a tee-up"

    printf 'The build is fast, cheap, and reliable.\n' > "$T/f5.md"
    vl "$T/f5.md" | grep -q rule_of_three && ok "catches an aphoristic rule of three" || bad "missed a rule of three"

    # Controls. A detector that fires on clean prose gets turned off by its user, at which point
    # it protects nothing, so the quiet cases are worth as many assertions as the loud ones.
    printf 'Send the draft to the design team, not legal.\n' > "$T/c1.md"
    vl "$T/c1.md" | grep -q binary_contrast && bad "fires on a plain factual correction" || ok "stays quiet on a plain factual correction"

    printf 'The reviewers are Ada, Grace, and Katherine.\n' > "$T/c2.md"
    vl "$T/c2.md" | grep -q rule_of_three && bad "fires on a proper-noun list" || ok "stays quiet on a proper-noun list"

    printf 'Use `a; b` in code.\n\n```\nint x = 1; int y = 2;\n```\n' > "$T/c3.md"
    vl "$T/c3.md" | grep -q prose_semicolon && bad "fires on a semicolon inside code" || ok "stays quiet on semicolons inside code"

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

    # A table or a list is not a paragraph, and flagging one would make the tool useless on any
    # doc that carries data.
    { printf '## Body\n\n'; for i in $(seq 1 40); do printf -- '- a list row with several words in it\n'; done; } > "$T/b5.md"
    blint "$T/b5.md" | grep -q long_para && bad "fires on a long list" || ok "stays quiet on a long list"

    # Exit codes, since the workflow and any hook branch on them.
    printf 'Clean prose with nothing to find.\n' > "$T/clean.md"
    set +e
    python3 "$T/voice-lint.py" --file "$T/clean.md" >/dev/null 2>&1; clean_rc=$?
    python3 "$T/voice-lint.py" --file "$T/f1.md"    >/dev/null 2>&1; dirty_rc=$?
    count="$(python3 "$T/voice-lint.py" --count --file "$T/f3.md" 2>/dev/null)"
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

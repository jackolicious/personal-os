#!/usr/bin/env bash
# Verify the person-profile contract and the forget register survive the port into the phase
# markdown, and that the embedded linter catches each violation it exists to catch.
#
# The contract: everything above `## Evidence log` is the current picture, rewritten in place and
# cited, and the log below it is append-only. Without it, profiles grow by appending. One live
# vault reached 67 Themes bullets on a single person plus 16 dated append blocks, and three stacked
# "Synthesis as of" sections on another, so every read meant re-synthesizing the whole file to find
# out who the person is today. Nothing cited its source, and nothing stopped the nightly from
# re-deriving a claim the owner asked to forget.
#
# Every check is scoped to the block it claims to check, so text elsewhere in a phase file cannot
# satisfy it. The linter is extracted from Phase 8 and driven against fixtures, since a linter that
# is only mentioned passes on a linter that catches nothing.
set -euo pipefail
PASS=0; FAIL=0
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
P01="$ROOT/_bootstrap/phases/01-scaffold.md"
P03="$ROOT/_bootstrap/phases/03-claude-md.md"
P05="$ROOT/_bootstrap/phases/05-templates.md"
P06="$ROOT/_bootstrap/phases/06-workflows.md"
P07="$ROOT/_bootstrap/phases/07-commands.md"
P08="$ROOT/_bootstrap/phases/08-automation.md"
P09="$ROOT/_bootstrap/phases/09-finalize.md"

ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }

section() {
  python3 - "$1" "$2" "$3" <<'SECPY'
import sys
text = open(sys.argv[1]).read()
head, nxt = sys.argv[2], sys.argv[3]
start = text.find(head)
if start == -1:
    raise SystemExit
end = text.find(nxt, start + len(head))
sys.stdout.write(text[start:end if end != -1 else len(text)])
SECPY
}

has() { # haystack-string pattern label
  if printf '%s' "$1" | grep -qiE -- "$2"; then ok "$3"; else bad "$3"; fi
}
lacks() {
  if printf '%s' "$1" | grep -qiE -- "$2"; then bad "$3"; else ok "$3"; fi
}

extract_block() {
  awk -v pat="$2" '
    /^```/ { if (inb) { if (buf ~ pat) { printf "%s", buf; exit } ; inb=0; buf="" } else { inb=1; buf="" } ; next }
    inb { buf = buf $0 "\n" }
  ' "$1"
}

echo "=== 17-people-profiles ==="

BT="$(printf '\140')"
ROOT_CLAUDE="$(section "$P03" "# [YOUR NAME] Personal OS" "${BT}${BT}${BT}" || true)"
ONE_CLAUDE="$(section "$P03" "### ${BT}1on1s/CLAUDE.md${BT}" "### ${BT}Meetings/CLAUDE.md${BT}" || true)"
TEMPLATE="$(section "$P05" "### ${BT}_system/templates/person-profile.md${BT}" "### ${BT}" || true)"
NOTES="$(section "$P06" "### ${BT}_system/workflows/meeting-notes.md${BT}" "### ${BT}_system/workflows/" || true)"
STEP9="$(section "$P06" "### Step 9: Profile synthesis" "### Step 10" || true)"
PREP="$(section "$P06" "### ${BT}_system/workflows/1on1-prep.md${BT}" "### ${BT}_system/workflows/" || true)"
NEW1="$(section "$P07" "### ${BT}.claude/commands/personal-os-new-1on1.md${BT}" "### ${BT}" || true)"
FORGET="$(section "$P07" "### ${BT}.claude/commands/personal-os-forget.md${BT}" "### ${BT}" || true)"

# --- Every layer exists, each in its own block --------------------------------
[ -n "$TEMPLATE" ]  && ok "person-profile template has a body"   || bad "person-profile template missing"
[ -n "$ONE_CLAUDE" ] && ok "1on1s/CLAUDE.md has a body"          || bad "1on1s/CLAUDE.md missing"
[ -n "$FORGET" ]    && ok "forget command has a body"            || bad "forget command missing"
[ -n "$STEP9" ]     && ok "nightly Step 9 has a body"            || bad "nightly Step 9 missing"
grep -q '1on1s/_forget\.md' "$P01" && ok "scaffold creates 1on1s/_forget.md" || bad "scaffold creates 1on1s/_forget.md"
grep -q 'scripts/lint_people_profiles\.py' "$P08" && ok "Phase 8 creates the profile linter" || bad "Phase 8 creates the profile linter"
has "$ROOT_CLAUDE" 'personal-os-forget' "the root commands table lists /personal-os-forget"
has "$ROOT_CLAUDE" '1on1s/CLAUDE\.md' "the root wiki rule points profiles at their own contract"

# --- The template: current picture on top, append-only log last ---------------
has "$TEMPLATE" '^## Evidence log' "template has an Evidence log"
LAST_H2="$(printf '%s' "$TEMPLATE" | grep -E '^## ' | tail -1 || true)"
[ "$LAST_H2" = "## Evidence log" ] && ok "Evidence log is the template's last section" || bad "Evidence log is not last (last: $LAST_H2)"
has "$TEMPLATE" 'what lands, what grates' "template carries what lands / what grates"
has "$TEMPLATE" 'as you name it' "relationship is whatever the owner names it"
has "$TEMPLATE" 'Append-only' "template states the log is append-only"

# --- The contract, written where every reader of 1on1s/ looks ------------------
has "$ONE_CLAUDE" 'Profile contract' "1on1s/CLAUDE.md states the profile contract"
has "$ONE_CLAUDE" 'rewrite it in place' "the current picture is rewritten, not appended"
has "$ONE_CLAUDE" 'At most 10 themes' "the Themes cap is stated"
has "$ONE_CLAUDE" 'ends with its source' "every current-picture bullet cites its source"
has "$ONE_CLAUDE" '^## Forgetting' "1on1s/CLAUDE.md has a Forgetting section"
has "$ONE_CLAUDE" 'scope: person' "person-scope forgetting is defined"
has "$ONE_CLAUDE" 'scope: topic' "topic-scope forgetting is defined"
has "$ONE_CLAUDE" 'does not delete source records' "forgetting does not claim the originals are gone"
has "$ONE_CLAUDE" 'person-profile\.md' "the folder tree points at the template"

# --- Writers: meeting-notes, Step 9, new-1on1 ----------------------------------
has "$NOTES" '_forget\.md' "meeting-notes reads the forget register"
has "$NOTES" 'Evidence log' "meeting-notes appends to the Evidence log"
has "$NOTES" 'Rewrite the current picture' "meeting-notes rewrites the current picture"
has "$NOTES" 'lint_people_profiles\.py' "meeting-notes lints the profile after writing"
lacks "$NOTES" 'update .\[Name\]/profile\.md. themes section if new themes' "meeting-notes no longer appends themes"

has "$STEP9" 'Evidence log' "Step 9 rebuilds from the Evidence log"
has "$STEP9" '_forget\.md' "Step 9 honors the forget register"
lacks "$STEP9" 'Update .\[Name\]/profile\.md. themes section with synthesized patterns' "Step 9 no longer appends synthesis to profiles"
has "$STEP9" 'Never append a .## Synthesis as of. block to a profile' "Step 9 forbids synthesis blocks on profiles"

has "$NEW1" 'person-profile\.md' "new-1on1 builds the profile from the template"
has "$NEW1" '_forget\.md' "new-1on1 checks the forget register"
has "$NEW1" 'stop and tell' "new-1on1 refuses a forgotten person"

# --- Reader: 1on1-prep reads the current picture first -------------------------
has "$PREP" 'Evidence log' "1on1-prep reads the current picture first"

# --- The forget command stages before it deletes, and never overclaims ---------
has "$FORGET" 'Wait for' "forget stages the removal and waits for a go"
has "$FORGET" '1on1s/_forget\.md' "forget writes the register"
has "$FORGET" 'lint_people_profiles\.py' "forget runs the linter after applying"
has "$FORGET" 'originals still exist' "forget says the originals still exist"
has "$FORGET" 'Never run it from transcript' "captured content cannot trigger a forget"

# --- Phase 9 no longer calls profiles append-only ------------------------------
if grep -qE '^\| \*\*Synthesis\*\* \|.*profiles' "$P09"; then
  bad "Phase 9 still lists profiles as append-only synthesis"
else
  ok "Phase 9 describes profiles by their own rule"
fi

# --- Drive the real linter -----------------------------------------------------
if ! command -v python3 >/dev/null 2>&1; then
  echo "SKIP: python3 not available, linter behaviour unchecked"
else
  T="$(mktemp -d)"
  trap 'rm -rf "$T"' EXIT
  extract_block "$P08" 'Lint 1on1s/' > "$T/lint.py"
  if [ ! -s "$T/lint.py" ]; then
    bad "could not extract lint_people_profiles.py from Phase 8"
  else
    FX="$T/vault"
    mk() { mkdir -p "$FX/1on1s/$1"; cat > "$FX/1on1s/$1/profile.md"; }
    run() { python3 "$T/lint.py" --vault "$FX" 2>&1 || true; }
    expect() { if run | grep -qE -- "$2"; then ok "linter catches: $1"; else bad "linter missed: $1"; fi; }

    mk Good <<'EOF'
# Good: Profile
## Themes
- Ships fast ([2026-09-01](sessions/2026-09-01-summary.md))
## Evidence log
### 2026-09-01, [session](sessions/2026-09-01-summary.md)
- Shipped the thing
EOF
    if [ "$(run)" = "OK" ]; then ok "linter accepts a conforming profile"; else bad "linter rejects a conforming profile: $(run | head -2)"; fi

    printf '# NoLog: Profile\n## Themes\n- x (2026-09-01)\n' | mk NoLog
    expect "missing Evidence log" 'NoLog: no `## Evidence log`'
    rm -rf "$FX/1on1s/NoLog"

    printf '# Stacked\n## Themes\n- x (2026-09-01)\n### Appended 2026-09-02\n## Synthesis as of 2026-09-03\n## Evidence log\n' | mk Stacked
    expect "Appended block above the log" 'Stacked: dated block above Evidence log \(### Appended'
    expect "Synthesis block above the log" 'Stacked: dated block above Evidence log \(## Synthesis'
    rm -rf "$FX/1on1s/Stacked"

    { echo "# Bloat"; echo "## Themes"; for i in $(seq 1 11); do echo "- t$i (2026-09-01)"; done; echo "## Evidence log"; } | mk Bloat
    expect "Themes over the cap" 'Bloat: 11 Themes bullets'
    rm -rf "$FX/1on1s/Bloat"

    printf '# Uncited\n## Themes\n- Likes long docs\n## Evidence log\n' | mk Uncited
    expect "uncited Themes bullet" 'Uncited: uncited Themes bullet'
    rm -rf "$FX/1on1s/Uncited"

    printf '# Trailing\n## Evidence log\n## Session history\n' | mk Trailing
    expect "section after the log" 'Trailing: section after Evidence log'
    rm -rf "$FX/1on1s/Trailing"

    mkdir -p "$FX/1on1s/Good/sessions" "$FX/People"
    echo "Discussed the retreat incident" > "$FX/1on1s/Good/sessions/2026-09-01-summary.md"
    printf '# Gone\n## Evidence log\n' | mk Gone
    printf '### Gone\n- Role: x\n' > "$FX/People/team.md"
    cat > "$FX/1on1s/_forget.md" <<'EOF'
## Active
### F-001
- person: Good
- scope: topic
- match: retreat incident
### F-002
- person: Gone
- scope: person
## Lifted
### F-000
- person: Good
- scope: topic
- match: Ships fast
EOF
    expect "forgotten topic re-derived into a summary" "_forget F-001: term 'retreat incident' reappeared"
    expect "forgotten person's profile re-derived" '_forget F-002: profile re-derived for forgotten person Gone'
    expect "forgotten person left in the roster" '_forget F-002: Gone still in team.md'
    if run | grep -q 'F-000'; then bad "linter enforces Lifted entries"; else ok "linter ignores Lifted entries"; fi
    rc=0; python3 "$T/lint.py" --vault "$FX" >/dev/null 2>&1 || rc=$?
    [ "$rc" = "1" ] && ok "linter exits 1 on violations" || bad "linter exit code on violations was $rc"
  fi
fi

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]

#!/usr/bin/env bash
# Verify Phase 8 installs a prose guard that WORKS, and that the settings.json snippet quotes its
# hook path.
#
# Why the quoting assertion exists. A vault installed from this template usually lives on a path
# containing a space (~/Google Drive/My Drive/..., ~/Library/Mobile Documents/..., ~/OneDrive/...).
# An unquoted $CLAUDE_PROJECT_DIR in a hook command makes the shell split on that space and try to
# execute /Users/you/Google, which fails. A PreToolUse hook that fails to launch does not block the
# tool. The guard then protects nothing while looking correctly configured, which is the worst
# possible failure mode because it is invisible.
#
# This was found in a real vault on 2026-07-30, where the em-dash guard had been silently dead for
# five weeks and a document shipped with 12 em dashes through a hook that appeared to be installed.
#
# Every behavioural claim below is proved by EXTRACTING the hook from the phase markdown and running
# it. An earlier version of this file asserted only that the phase contained certain sentences, and
# it passed with the hook body deleted, which reproduced the exact defect the step exists to fix.
set -euo pipefail
PASS=0; FAIL=0
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PHASE="$ROOT/_bootstrap/phases/08-automation.md"

ok()  { echo "PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }

echo "=== 10-prose-hooks ==="

# --- The step exists and installs the pieces ---------------------------------
for pair in "Step 2b:Phase 8 has a prose guard step" \
            "no-em-dashes\.sh:Phase 8 creates the hook script" \
            "chmod +x .claude/hooks/no-em-dashes.sh:Phase 8 makes the hook executable" \
            "PreToolUse:Phase 8 registers the hook on PreToolUse" \
            "Write|Edit|MultiEdit:Phase 8 matches the write tools"; do
  pat="${pair%%:*}"; label="${pair#*:}"
  if grep -q "$pat" "$PHASE"; then ok "$label"; else bad "$label"; fi
done

# The rule the hook enforces must actually be stated in the vault's writing preferences, and the
# rule banning em dashes must not itself contain one.
if grep -q 'No em dashes' "$ROOT/_bootstrap/phases/03-claude-md.md"; then
  ok "Phase 3 states the em dash rule"
else
  bad "Phase 3 states the em dash rule"
fi
if grep -n 'No em dashes' "$ROOT/_bootstrap/phases/03-claude-md.md" | grep -q '—'; then
  bad "the 'No em dashes' rule contains an em dash"
else
  ok "the 'No em dashes' rule contains no em dash"
fi

# --- The settings.json command VALUE is quoted -------------------------------
# Asserting that the quoted token appears somewhere in the file is not enough: the token can sit in
# a prose sentence while the real command value is unquoted, or written ${CLAUDE_PROJECT_DIR}/...,
# which splits on a space the same way. Parse the JSON and assert on the value itself.
if ! command -v python3 >/dev/null 2>&1; then
  echo "SKIP: python3 unavailable, cannot parse the settings snippet"
else
  CMDS="$(python3 - "$PHASE" <<'PY'
import json, re, sys
s = open(sys.argv[1]).read()
out = []
for block in re.findall(r"```json\n(.*?)```", s, re.S):
    try:
        data = json.loads(block)
    except ValueError:
        continue
    for group in data.get("hooks", {}).get("PreToolUse", []):
        for hook in group.get("hooks", []):
            if "command" in hook:
                out.append(hook["command"])
print("\n".join(out))
PY
)"
  if [ -z "$CMDS" ]; then
    bad "no PreToolUse command found in any settings.json snippet"
  else
    unquoted=0
    while IFS= read -r cmd; do
      [ -n "$cmd" ] || continue
      case "$cmd" in
        *'"$CLAUDE_PROJECT_DIR"'*) ;;
        *'$CLAUDE_PROJECT_DIR'*|*'${CLAUDE_PROJECT_DIR}'*) unquoted=$((unquoted+1));;
      esac
    done <<< "$CMDS"
    if [ "$unquoted" -eq 0 ]; then
      ok "every PreToolUse command value quotes CLAUDE_PROJECT_DIR"
    else
      bad "$unquoted PreToolUse command value(s) reference CLAUDE_PROJECT_DIR unquoted"
    fi
  fi

  # Every json snippet that defines hooks must also carry permissions. A hooks-only object written
  # over settings.json drops the permissions block, which breaks the headless nightly claude calls.
  if python3 - "$PHASE" <<'PY'
import json, re, sys
s = open(sys.argv[1]).read()
bad = 0
for block in re.findall(r"```json\n(.*?)```", s, re.S):
    try:
        data = json.loads(block)
    except ValueError:
        continue
    if "hooks" in data and "permissions" not in data:
        bad += 1
sys.exit(1 if bad else 0)
PY
  then ok "the hooks snippet keeps permissions in the same object"
  else bad "a hooks-only settings.json snippet would drop permissions"
  fi
fi

# --- Run the shipped hook ----------------------------------------------------
if ! command -v jq >/dev/null 2>&1; then
  echo "SKIP: jq unavailable, cannot exercise the hook"
else
  PROBE="$(mktemp -d)"
  python3 - "$PHASE" "$PROBE/hook.sh" <<'PY'
import re, sys
s = open(sys.argv[1]).read()
blocks = re.findall(r"```bash\n(.*?)```", s, re.S)
hook = [b for b in blocks if "PreToolUse hook" in b]
open(sys.argv[2], "w").write(hook[0] if hook else "")
PY
  if [ ! -s "$PROBE/hook.sh" ]; then
    bad "could not extract the hook from the phase markdown"
  else
    chmod +x "$PROBE/hook.sh"
    # $1 file path, $2 content, $3 expected exit code, $4 label
    run_hook() {
      local payload rc
      payload=$(python3 -c 'import json,sys; print(json.dumps({"tool_input":{"file_path":sys.argv[1],"content":sys.argv[2]}}))' "$1" "$2")
      set +e
      printf '%s' "$payload" | bash "$PROBE/hook.sh" >/dev/null 2>&1
      rc=$?
      set -e
      if [ "$rc" -eq "$3" ]; then ok "$4"; else bad "$4 (expected exit $3, got $rc)"; fi
    }

    EM="$(printf '\xe2\x80\x94')"
    run_hook "/v/Notes/a.md"    "clean prose"      0 "clean markdown passes"
    run_hook "/v/Notes/a.md"    "a ${EM} b"        2 "an em dash in markdown is blocked"
    run_hook "/v/Notes/a.MD"    "a ${EM} b"        2 "an uppercase .MD extension is still checked"
    run_hook "/v/Notes/a.markdown" "a ${EM} b"     2 "a .markdown extension is still checked"
    run_hook "/v/src/a.py"      "a ${EM} b"        0 "a non-markdown file is skipped"
    run_hook "/v/Inbox/raw.md"  "a ${EM} b"        0 "captured content under Inbox is skipped"
    run_hook "/v/M/x-transcript.md" "a ${EM} b"    0 "a transcript is skipped"
    run_hook "/v/M/2026-01-01/raw.md" "a ${EM} b"  0 "an immutable raw copy is skipped"
    run_hook "/v/profile/preferences/communication.md" "a ${EM} b" 0 "the style guide is skipped"
    run_hook "/v/My Notes/a b.md" "a ${EM} b"      2 "a path containing spaces is checked"

    # A MultiEdit payload carrying a clean `content` alongside a dirty edit must still block.
    # Built with a python heredoc, since the JSON braces do not survive an inline -c in bash.
    python3 - "$PROBE/multi.json" <<'PYEOF'
import json, sys
payload = {"tool_input": {"file_path": "/v/a.md",
                          "content": "clean",
                          "edits": [{"new_string": "a \u2014 b"}]}}
open(sys.argv[1], "w").write(json.dumps(payload))
PYEOF
    set +e
    bash "$PROBE/hook.sh" < "$PROBE/multi.json" >/dev/null 2>&1
    multi_rc=$?
    set -e
    if [ "$multi_rc" -eq 2 ]; then
      ok "a dirty edit is caught even beside clean content"
    else
      bad "a dirty edit beside clean content slipped through (exit $multi_rc)"
    fi

    # Malformed input must not crash the hook, and must not block a legitimate write.
    for junk in '' 'not json' '{}' '{"tool_input":null}'; do
      set +e
      printf '%s' "$junk" | bash "$PROBE/hook.sh" >/dev/null 2>&1
      junk_rc=$?
      set -e
      if [ "$junk_rc" -eq 0 ]; then
        ok "malformed payload handled without blocking (${junk:-empty})"
      else
        bad "malformed payload returned $junk_rc (${junk:-empty})"
      fi
    done

    # The hook must fail CLOSED when jq is missing. Exiting 0 there lets every em dash through
    # while the hook still looks installed.
    BINONLY="$PROBE/bin"; mkdir -p "$BINONLY"
    for c in bash sh grep printf cat tr echo; do
      src="$(command -v "$c" 2>/dev/null || true)"
      [ -n "$src" ] && ln -sf "$src" "$BINONLY/$c"
    done
    set +e
    printf '{"tool_input":{"file_path":"/v/a.md","content":"x"}}' \
      | PATH="$BINONLY" bash "$PROBE/hook.sh" >/dev/null 2>&1
    nojq_rc=$?
    set -e
    if [ "$nojq_rc" -eq 2 ]; then
      ok "the hook fails closed when jq is missing"
    else
      bad "the hook fails open when jq is missing (exit $nojq_rc)"
    fi
  fi
  rm -rf "$PROBE"
fi

# --- Demonstrate the quoting failure rather than asserting it ----------------
PROBE="$(mktemp -d)"
PROBE_DIR="$PROBE/probe space dir"
mkdir -p "$PROBE_DIR"
printf '#!/bin/sh\nexit 7\n' > "$PROBE_DIR/h.sh"
chmod +x "$PROBE_DIR/h.sh"
set +e
CLAUDE_PROJECT_DIR="$PROBE_DIR" sh -c '$CLAUDE_PROJECT_DIR/h.sh' >/dev/null 2>&1; unq=$?
CLAUDE_PROJECT_DIR="$PROBE_DIR" sh -c '"$CLAUDE_PROJECT_DIR"/h.sh' >/dev/null 2>&1; q=$?
set -e
rm -rf "$PROBE"
if [ "$unq" -ne 7 ] && [ "$q" -eq 7 ]; then
  ok "demonstrated unquoted path fails to launch ($unq) and quoted path runs ($q)"
else
  bad "could not demonstrate the quoting failure (unquoted=$unq quoted=$q)"
fi

# The phase must explain the quoting trap, since a future editor who does not know why the quotes
# are there is the person who removes them.
if grep -q "silently protects nothing" "$PHASE"; then
  ok "Phase 8 explains why quoting matters"
else
  bad "Phase 8 explains why quoting matters"
fi

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]

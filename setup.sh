#!/bin/bash
# Personal OS — one-command vault setup
# Usage: bash setup.sh

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo -e "${BOLD}Personal OS Setup${NC}"
echo "================================="
echo ""

# ── Prerequisite checks ──────────────────────────────────────────────────────

ok()   { echo -e "  ${GREEN}[ok]${NC}  $1"; }
warn() { echo -e "  ${YELLOW}[--]${NC}  $1"; }
fail() { echo -e "  ${RED}[!!]${NC}  $1"; }

echo "Checking prerequisites..."
ERRORS=0

if command -v python3 &>/dev/null; then ok "Python 3"; else fail "Python 3 not found — install from python.org"; ERRORS=$((ERRORS+1)); fi
if command -v claude  &>/dev/null; then ok "Claude Code CLI"; else fail "Claude Code not found — install from claude.ai/code"; ERRORS=$((ERRORS+1)); fi
if command -v git     &>/dev/null; then ok "git"; else fail "git not found — run: xcode-select --install"; ERRORS=$((ERRORS+1)); fi

if python3 -c "import markitdown" 2>/dev/null; then
  ok "markitdown"
else
  warn "markitdown not installed — PDF ingestion will not work until you run: pip install markitdown"
fi

echo ""
if [ "$ERRORS" -gt 0 ]; then
  fail "Fix the above before continuing."
  exit 1
fi

# ── Vault location ───────────────────────────────────────────────────────────

DEFAULT_VAULT="$HOME/personal-os"
echo -e "Vault directory [${BLUE}$DEFAULT_VAULT${NC}]: \c"
read -r VAULT_PATH
VAULT_PATH="${VAULT_PATH:-$DEFAULT_VAULT}"
VAULT_PATH="${VAULT_PATH/#\~/$HOME}"

if [ -d "$VAULT_PATH" ] && [ "$(ls -A "$VAULT_PATH" 2>/dev/null)" ]; then
  echo -e "${YELLOW}Warning: $VAULT_PATH already exists and is not empty.${NC}"
  echo -n "Continue anyway? [y/N]: "
  read -r CONFIRM
  [[ "$CONFIRM" =~ ^[Yy]$ ]] || exit 0
fi

mkdir -p "$VAULT_PATH"
mkdir -p "$VAULT_PATH/_system/logs"
ok "Vault directory created at $VAULT_PATH"

# ── Copy bootstrap and config ─────────────────────────────────────────────────

cp "$SCRIPT_DIR/personal-os-bootstrap.md" "$VAULT_PATH/"
cp "$SCRIPT_DIR/.gitignore"               "$VAULT_PATH/"
ok "Bootstrap and config copied"

# ── Git init ─────────────────────────────────────────────────────────────────

cd "$VAULT_PATH"

if [ ! -d ".git" ]; then
  git init -q
  git add .gitignore personal-os-bootstrap.md
  git commit -q -m "init: Personal OS vault"
  ok "Git repository initialized"
else
  warn "Git already initialized — skipping"
fi

# ── Transcript tool ──────────────────────────────────────────────────────────

echo ""
echo "Which AI note-taking tool will you use for meeting transcripts?"
echo "  1) Granola (Mac desktop, auto-exports to a folder)"
echo "  2) Fireflies.ai (configure webhook or manual download)"
echo "  3) Zoom AI Companion (Zoom MCP or manual export)"
echo "  4) Otter.ai (manual download)"
echo "  5) Other / I'll set this up later"
echo -n "Choice [1-5]: "
read -r TRANSCRIPT_TOOL

case "$TRANSCRIPT_TOOL" in
  1)
    echo ""
    echo -e "Granola export path (e.g. ~/Library/Application Support/Granola/transcripts): \c"
    read -r GRANOLA_PATH
    GRANOLA_PATH="${GRANOLA_PATH:-$HOME/Library/Application Support/Granola/transcripts}"
    GRANOLA_PATH="${GRANOLA_PATH/#\~/$HOME}"
    if [ -d "$GRANOLA_PATH" ]; then
      # Create a symlink so Granola exports land directly in Inbox/
      mkdir -p "$VAULT_PATH/Inbox"
      ok "Granola path confirmed: $GRANOLA_PATH"
      echo ""
      echo -e "${YELLOW}Note:${NC} Configure Granola to export to: $VAULT_PATH/Inbox/"
      echo "      Or symlink: ln -s \"$GRANOLA_PATH\" \"$VAULT_PATH/Inbox\""
    else
      warn "Path not found — you can configure this after Granola is installed"
    fi
    ;;
  2)
    ok "Fireflies selected — configure webhook or auto-download to $VAULT_PATH/Inbox/"
    echo "      Fireflies webhook docs: app.fireflies.ai/integrations"
    ;;
  3)
    ok "Zoom AI Companion selected — configure MCP or export manually to $VAULT_PATH/Inbox/"
    echo "      Zoom MCP setup instructions will be in your bootstrap prompt"
    ;;
  4)
    ok "Otter.ai selected — download transcripts to $VAULT_PATH/Inbox/"
    ;;
  *)
    warn "You can configure transcript ingestion later in Inbox/CLAUDE.md"
    ;;
esac

# ── Daily briefing automation ─────────────────────────────────────────────────

echo ""
echo -n "Automate daily briefing at 5:00 AM via launchd? [Y/n]: "
read -r AUTO_BRIEF

if [[ ! "$AUTO_BRIEF" =~ ^[Nn]$ ]]; then
  PLIST_LABEL="com.personalos.morning"
  PLIST_PATH="$HOME/Library/LaunchAgents/${PLIST_LABEL}.plist"
  CLAUDE_BIN="$(command -v claude)"
  BRIEFINGS_DIR="$VAULT_PATH/_system/briefings"
  mkdir -p "$BRIEFINGS_DIR"

  cat > "$PLIST_PATH" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>${PLIST_LABEL}</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>-l</string>
    <string>-c</string>
    <string>cd "$VAULT_PATH" &amp;&amp; "$CLAUDE_BIN" --model claude-sonnet-4-6 --print "\$(cat .claude/commands/personal-os-daily-briefing.md)" &gt; "$BRIEFINGS_DIR/\$(date +%Y-%m-%d).md" 2&gt;&amp;1</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Hour</key>
    <integer>5</integer>
    <key>Minute</key>
    <integer>0</integer>
  </dict>
  <key>StandardOutPath</key>
  <string>$VAULT_PATH/_system/logs/morning.log</string>
  <key>StandardErrorPath</key>
  <string>$VAULT_PATH/_system/logs/morning-error.log</string>
  <key>EnvironmentVariables</key>
  <dict>
    <key>PATH</key>
    <string>/usr/local/bin:/usr/bin:/bin:/opt/homebrew/bin</string>
  </dict>
</dict>
</plist>
PLIST

  launchctl load "$PLIST_PATH" 2>/dev/null && ok "Daily briefing scheduled at 5:00 AM" || warn "launchctl load failed — briefing plist saved at $PLIST_PATH, load manually"
fi

# ── Nightly synthesis ─────────────────────────────────────────────────────────

echo ""
echo "The nightly synthesis runs at 2:00 AM in a persistent terminal session."
echo "After Claude finishes setting up your vault, start it with:"
echo ""
echo -e "  ${BLUE}bash $VAULT_PATH/run-nightly.sh${NC}"
echo ""
echo "Keep this running in a dedicated terminal tab. Mac sleep must be disabled:"
echo "  System Settings > Battery > Options > Prevent automatic sleeping when on power"

# ── Finish ────────────────────────────────────────────────────────────────────

echo ""
echo -e "${GREEN}${BOLD}Setup complete.${NC}"
echo ""
echo "Next steps:"
echo "  1.  cd $VAULT_PATH && claude"
echo "  2.  Paste the contents of personal-os-bootstrap.md into the prompt"
echo "  3.  Follow phases 1-11 (takes ~20 minutes)"
echo "  4.  Complete the Phase 10 personalization checklist before your first real session"
echo ""

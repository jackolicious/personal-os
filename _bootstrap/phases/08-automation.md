# Phase 8: Automation
_Depends on: Phase 1 (directories must exist)_

## Step 1: Create `run-nightly.sh`

```bash
#!/bin/bash
# Personal OS — persistent automation loop
# Launched automatically by launchd (com.personalos.loop) — see Phase 8 Step 3.
# To run manually: bash run-nightly.sh

set -euo pipefail
VAULT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$VAULT_DIR/_system/logs" "$VAULT_DIR/_system/briefings"

echo "Personal OS loop started at $(date). Ctrl+C to stop."

NIGHTLY_DONE_DATE=""
BRIEFING_DONE_DATE=""
WEEK_AHEAD_DONE_DATE=""

while true; do
  TODAY="$(date +%Y-%m-%d)"
  HOUR="$(date +%H)"
  DOW="$(date +%u)"  # 1=Mon ... 7=Sun

  # Nightly synthesis at 02:00 — three-pass pipeline
  if [ "$HOUR" = "02" ] && [ "$NIGHTLY_DONE_DATE" != "$TODAY" ]; then
    echo "$(date): Running nightly synthesis..."
    LOG="$VAULT_DIR/_system/logs/nightly.log"
    QUEUE="$VAULT_DIR/_system/logs/nightly-queue-$TODAY.txt"

    # Step 0: Build Inbox queue (shell — no LLM needed)
    echo "$(date): Step 0 — scanning Inbox for new files..." | tee -a "$LOG"
    [ -f "$VAULT_DIR/Inbox/_index.md" ] || printf "| File | Type | Status | Added |\n|------|------|--------|-------|\n" > "$VAULT_DIR/Inbox/_index.md"
    [ -f "$VAULT_DIR/Inbox/_unrouted.md" ] || printf "# Inbox — Unrouted Files\n\nFiles the nightly router couldn't classify. Rename or move them to help it next time.\n\n" > "$VAULT_DIR/Inbox/_unrouted.md"
    find "$VAULT_DIR/Inbox" -maxdepth 1 -type f ! -name '_*' | while IFS= read -r FILE; do
      grep -qF "| $FILE |" "$VAULT_DIR/Inbox/_index.md" || \
        printf "| %s | unknown | pending | %s |\n" "$FILE" "$TODAY" >> "$VAULT_DIR/Inbox/_index.md"
    done

    # Pass 1 (Haiku): identify unprocessed files → write queue
    echo "$(date): Pass 1 — building work queue..." | tee -a "$LOG"
    claude --model claude-haiku-4-5 --print \
      "Read _system/data/synthesis-log.json and Inbox/_index.md.
Output one file path per line for each file where Status=pending and not already in synthesis-log. No other text." \
      > "$QUEUE" 2>> "$LOG"

    # Pass 2 (Haiku): process each file in its own subprocess
    echo "$(date): Pass 2 — per-file extraction..." | tee -a "$LOG"
    while IFS= read -r FILE; do
      [ -z "$FILE" ] && continue
      echo "$(date): Processing $FILE" | tee -a "$LOG"
      claude --model claude-haiku-4-5 --print \
        "Classify this file using these rules:
- link: file consists primarily of URLs (http:// or https://), with optional surrounding notes
- transcript: file has speaker labels, timestamps, or meeting header metadata
- pdf: file has a .pdf extension
- note: .md file that is neither a transcript nor a link
- unrouted: anything else (binary files, unknown extensions, ambiguous content)

Then process it using the matching workflow:
- transcript → _system/workflows/meeting-notes.md
- pdf → _system/workflows/pdf-ingestion.md
- note → _system/workflows/note-ingestion.md
- link → _system/workflows/link-ingestion.md
- unrouted → append filename + one-line description to Inbox/_unrouted.md, update Inbox/_index.md status to flagged, log in synthesis-log.json to prevent re-queuing, stop.

If the file is already in synthesis-log (hash match), skip immediately.
After processing: update Inbox/_index.md — set Type to the classified type and Status to processed.

File: $FILE" \
        2>&1 >> "$LOG"
    done < "$QUEUE"

    # Pass 3 (Sonnet): connections, patterns, coaching, index updates
    echo "$(date): Pass 3 — synthesis and pattern detection..." | tee -a "$LOG"
    claude --model claude-sonnet-4-6 --print \
      "Follow _system/workflows/nightly-synthesis.md Steps 4–11 only.
Per-file extraction (Steps 1–3) is already complete for tonight. Stop." \
      2>&1 >> "$LOG"

    NIGHTLY_DONE_DATE="$TODAY"
    sleep 60
  fi

  # Daily briefing at 05:00 — only if nightly has run today (or it's already morning)
  if [ "$HOUR" = "05" ] && [ "$BRIEFING_DONE_DATE" != "$TODAY" ]; then
    BRIEF_FILE="$VAULT_DIR/_system/briefings/$TODAY.md"
    if [ ! -f "$BRIEF_FILE" ]; then
      LOG="$VAULT_DIR/_system/logs/nightly.log"

      # Meeting prep pass — runs first so briefing can link to prep docs
      echo "$(date): Generating meeting prep docs..." | tee -a "$LOG"
      mkdir -p "$VAULT_DIR/Meetings/prep"
      claude --model claude-sonnet-4-6 --print \
        "$(cat "$VAULT_DIR/.claude/commands/personal-os-meeting-prep.md")" \
        >> "$LOG" 2>&1
      echo "$(date): Meeting prep complete." | tee -a "$LOG"

      echo "$(date): Generating daily briefing..."
      claude --model claude-sonnet-4-6 --print \
        "$(cat "$VAULT_DIR/.claude/commands/personal-os-daily-briefing.md")" \
        > "$BRIEF_FILE" 2>&1
      echo "$(date): Briefing saved to $BRIEF_FILE"
    fi
    BRIEFING_DONE_DATE="$TODAY"
    sleep 60
  fi

  # Week-ahead brief on Sunday at 20:00
  if [ "$DOW" = "7" ] && [ "$HOUR" = "20" ] && [ "$WEEK_AHEAD_DONE_DATE" != "$TODAY" ]; then
    WEEK_FILE="$VAULT_DIR/_system/briefings/week-ahead-$TODAY.md"
    if [ ! -f "$WEEK_FILE" ]; then
      echo "$(date): Generating week-ahead brief..."
      claude --model claude-sonnet-4-6 --print \
        "$(cat "$VAULT_DIR/.claude/commands/personal-os-week-ahead.md")" \
        > "$WEEK_FILE" 2>&1
      echo "$(date): Week-ahead saved to $WEEK_FILE"
    fi
    WEEK_AHEAD_DONE_DATE="$TODAY"
    sleep 60
  fi

  sleep 300  # check every 5 minutes
done
```

**Mac sleep setting:** System Settings → Battery → Options → enable "Prevent automatic sleeping on power adapter when display is off"

---

## Step 2: Write vault operational permissions

Create `.claude/settings.json` with this content so automated `claude --print` calls
(nightly synthesis, daily briefing) do not prompt for tool approvals:

```json
{
  "permissions": {
    "allow": [
      "Read(*)",
      "Write(*)",
      "Edit(*)",
      "Bash(find *)",
      "Bash(ls *)",
      "Bash(mv *)",
      "Bash(mkdir *)",
      "Bash(markitdown *)",
      "Bash(md5 *)",
      "Bash(md5sum *)",
      "Bash(cat *)",
      "Bash(grep *)",
      "Bash(date *)",
      "mcp__plugin_telegram_telegram__reply"
    ]
  }
}
```

---

## Step 3: Register the automation loop with launchd

This registers `run-nightly.sh` as a persistent macOS service. launchd starts it
automatically at login and restarts it if it exits. The `PathState` guard means
launchd only keeps it alive once `run-nightly.sh` exists — so it is safe to load
this plist before the script is created.

```bash
VAULT_DIR="$(pwd)"
PLIST_LABEL="com.personalos.loop"
PLIST_PATH="$HOME/Library/LaunchAgents/${PLIST_LABEL}.plist"
CLAUDE_BIN="$(command -v claude)"

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
    <string>${VAULT_DIR}/run-nightly.sh</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <dict>
    <key>PathState</key>
    <dict>
      <key>${VAULT_DIR}/run-nightly.sh</key>
      <true/>
    </dict>
  </dict>
  <key>WorkingDirectory</key>
  <string>${VAULT_DIR}</string>
  <key>StandardOutPath</key>
  <string>${VAULT_DIR}/_system/logs/loop.log</string>
  <key>StandardErrorPath</key>
  <string>${VAULT_DIR}/_system/logs/loop-error.log</string>
  <key>EnvironmentVariables</key>
  <dict>
    <key>PATH</key>
    <string>/usr/local/bin:/usr/bin:/bin:/opt/homebrew/bin</string>
  </dict>
</dict>
</plist>
PLIST

launchctl load "$PLIST_PATH"
echo "Automation loop registered. It will start automatically once run-nightly.sh exists."
```

To check status: `launchctl list | grep personalos`
To stop: `launchctl unload "$HOME/Library/LaunchAgents/com.personalos.loop.plist"`
To restart: `launchctl kickstart gui/$(id -u)/com.personalos.loop`

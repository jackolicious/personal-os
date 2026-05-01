# Phase 8: Automation
_Depends on: Phase 1 (directories must exist)_

## Step 1: Create `run-nightly.sh`

```bash
#!/bin/bash
# Personal OS — persistent automation loop
# Run in a dedicated terminal tab on your always-on Mac.
# Prerequisite: System Settings > Battery > Options > "Prevent automatic sleeping when on power adapter"

set -euo pipefail
VAULT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$VAULT_DIR/_system/logs" "$VAULT_DIR/_system/briefings"

echo "Personal OS loop started at $(date). Ctrl+C to stop."

NIGHTLY_DONE_DATE=""
BRIEFING_DONE_DATE=""

while true; do
  TODAY="$(date +%Y-%m-%d)"
  HOUR="$(date +%H)"

  # Nightly synthesis at 02:00 — three-pass pipeline
  if [ "$HOUR" = "02" ] && [ "$NIGHTLY_DONE_DATE" != "$TODAY" ]; then
    echo "$(date): Running nightly synthesis..."
    LOG="$VAULT_DIR/_system/logs/nightly.log"
    QUEUE="$VAULT_DIR/_system/logs/nightly-queue-$TODAY.txt"

    # Pass 1 (Haiku): identify unprocessed files → write queue
    echo "$(date): Pass 1 — building work queue..." | tee -a "$LOG"
    claude --model claude-haiku-4-5-20251001 --print \
      "Read _system/data/synthesis-log.json and Inbox/transcripts/_index.md.
Output one file path per line for each file not yet in synthesis-log. No other text." \
      > "$QUEUE" 2>> "$LOG"

    # Pass 2 (Haiku): process each file in its own subprocess
    echo "$(date): Pass 2 — per-file extraction..." | tee -a "$LOG"
    while IFS= read -r FILE; do
      [ -z "$FILE" ] && continue
      echo "$(date): Processing $FILE" | tee -a "$LOG"
      claude --model claude-haiku-4-5-20251001 --print \
        "Follow _system/workflows/meeting-notes.md for this single file only: $FILE
Process it, write all outputs, update synthesis-log, archive the original. Stop." \
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
      echo "$(date): Generating daily briefing..."
      claude --model claude-sonnet-4-6 --print \
        "$(cat "$VAULT_DIR/.claude/commands/personal-os-daily-briefing.md")" \
        > "$BRIEF_FILE" 2>&1
      echo "$(date): Briefing saved to $BRIEF_FILE"
    fi
    BRIEFING_DONE_DATE="$TODAY"
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

#!/bin/bash
# Run after bootstrap is complete to move bootstrap files out of root.
set -euo pipefail
VAULT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARCHIVE_DIR="$VAULT_DIR/_system/bootstrap-archive"
mkdir -p "$ARCHIVE_DIR"
DEST="$ARCHIVE_DIR/$(date +%Y-%m-%d)"
mv "$VAULT_DIR/_bootstrap" "$DEST"
printf '{"bootstrapped_at":"%s"}\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  > "$VAULT_DIR/_system/data/bootstrap-complete.json"
echo "Bootstrap archived to $DEST"
echo "To re-edit: mv \"$DEST\" \"$VAULT_DIR/_bootstrap\""

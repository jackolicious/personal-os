#!/bin/bash
# Run after bootstrap is complete to delete bootstrap scaffolding.
# Phase 9 handles this interactively; use this script if you skipped that step.
set -euo pipefail
VAULT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
rm -rf "$VAULT_DIR/_bootstrap"
rm -f  "$VAULT_DIR/personal-os-bootstrap.md"
printf '{"bootstrapped_at":"%s"}\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  > "$VAULT_DIR/_system/data/bootstrap-complete.json"
echo "Bootstrap files deleted."

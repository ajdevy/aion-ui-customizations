#!/bin/bash
set -euo pipefail

DB="$HOME/Library/Application Support/AionUi/aionui/aionui-backend.db"

if [ ! -f "$DB" ]; then
  echo "Error: AionUI database not found at $DB"
  echo "Is AionUI installed?"
  exit 1
fi

echo "Setting OpenCode assistants to full-access mode (no permission prompts)..."

sqlite3 "$DB" "
UPDATE assistant_definitions
SET default_permission_mode = 'fixed',
    default_permission_value = 'agent-full-access',
    updated_at = strftime('%s','now')
WHERE agent_id IN (
  SELECT id FROM agent_metadata WHERE backend = 'opencode'
)
AND deleted_at IS NULL;
"

ROWS=$(sqlite3 "$DB" "SELECT changes();")

echo "Done. Updated $ROWS OpenCode assistant(s)."
echo "Note: Changes apply to new conversations only."

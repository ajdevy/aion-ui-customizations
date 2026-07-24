#!/bin/bash
set -euo pipefail

DB="$HOME/Library/Application Support/AionUi/aionui/aionui-backend.db"

if [ ! -f "$DB" ]; then
  echo "Error: AionUI database not found at $DB"
  exit 1
fi

echo "Reverting OpenCode assistants to default permission mode..."

sqlite3 "$DB" "
UPDATE assistant_definitions
SET default_permission_mode = 'auto',
    default_permission_value = NULL,
    updated_at = strftime('%s','now')
WHERE agent_id IN (
  SELECT id FROM agent_metadata WHERE backend = 'opencode'
)
AND deleted_at IS NULL;
"

ROWS=$(sqlite3 "$DB" "SELECT changes();")

echo "Done. Reverted $ROWS OpenCode assistant(s) to auto mode."
echo "Note: Changes apply to new conversations only."

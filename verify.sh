#!/bin/bash
set -euo pipefail

DB="$HOME/Library/Application Support/AionUi/aionui/aionui-backend.db"

if [ ! -f "$DB" ]; then
  echo "Error: AionUI database not found at $DB"
  exit 1
fi

echo "=== OpenCode Assistant Permission State ==="
echo ""

sqlite3 -header -column "$DB" "
SELECT
  ad.name AS 'Assistant',
  ad.default_permission_mode AS 'Mode',
  COALESCE(ad.default_permission_value, '(none)') AS 'Value',
  CASE
    WHEN ad.default_permission_mode = 'fixed' AND ad.default_permission_value = 'agent-full-access' THEN '✅ Full access (no prompts)'
    WHEN ad.default_permission_mode = 'fixed' AND ad.default_permission_value = 'yolo' THEN '✅ Full access (yolo)'
    WHEN ad.default_permission_mode = 'fixed' AND ad.default_permission_value = 'build' THEN '⚠️  Build mode (prompts on)'
    WHEN ad.default_permission_mode = 'fixed' AND ad.default_permission_value = 'plan' THEN '🔒 Plan mode (read-only)'
    ELSE '❓ Auto (agent default)'
  END AS 'Effect'
FROM assistant_definitions ad
WHERE ad.agent_id IN (
  SELECT id FROM agent_metadata WHERE backend = 'opencode'
)
AND ad.deleted_at IS NULL
ORDER BY ad.name;
"

echo ""
echo "=== Agent Defaults ==="
sqlite3 -header -column "$DB" "
SELECT name AS 'Agent', backend AS 'Backend', behavior_policy AS 'Behavior Policy'
FROM agent_metadata
WHERE backend = 'opencode';
"

#!/bin/bash
set -euo pipefail

# AionUI Customizations - Revert all customizations
# Usage: ./revert.sh [aionui|codex|all]

TARGET="${1:-all}"

revert_aionui() {
    echo "=== Reverting AionUI permission bypass ==="
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
}

revert_codex() {
    echo "=== Reverting Codex mark-as-unread patches ==="
    
    ASSETS_DIR="${CODEX_ASSETS_DIR:-/Users/anastasia/workspace_ai/codex-intel/work/install.Gs99wx/app-extract/webview/assets}"
    
    if [ ! -d "$ASSETS_DIR" ]; then
        echo "Error: Codex assets directory not found at $ASSETS_DIR"
        exit 1
    fi
    
    echo "Found assets at: $ASSETS_DIR"
    echo ""
    echo "To revert the mark-as-unread patches, you need to re-extract the app bundle:"
    echo "  1. Re-run codex-intel's install.sh (it will re-extract app.asar fresh)"
    echo "  2. OR manually restore from a backup if you made one before patching"
    echo ""
    echo "The patches modify minified JS files that cannot be cleanly reverted with sed."
    echo "Re-extraction is the cleanest way to restore originals."
}

case "$TARGET" in
    aionui)
        revert_aionui
        ;;
    codex)
        revert_codex
        ;;
    all)
        revert_aionui
        echo ""
        revert_codex
        ;;
    *)
        echo "Usage: $0 [aionui|codex|all]"
        echo "  aionui  - Revert AionUI permission bypass"
        echo "  codex   - Revert Codex mark-as-unread patches (requires re-extraction)"
        echo "  all     - Revert both (default)"
        exit 1
        ;;
esac
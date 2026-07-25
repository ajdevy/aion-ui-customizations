#!/bin/bash
set -euo pipefail

# AionUI Customizations - Apply all customizations
# Usage: ./apply.sh [aionui|codex|all]

TARGET="${1:-all}"

apply_aionui() {
    echo "=== Applying AionUI permission bypass ==="
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
}

apply_codex() {
    echo "=== Applying Codex mark-as-unread patches ==="
    
    # Find the extracted assets directory
    ASSETS_DIR="${CODEX_ASSETS_DIR:-/Users/anastasia/workspace_ai/codex-intel/work/install.Gs99wx/app-extract/webview/assets}"
    
    if [ ! -d "$ASSETS_DIR" ]; then
        echo "Error: Codex assets directory not found at $ASSETS_DIR"
        echo "Set CODEX_ASSETS_DIR or run codex-intel's install.sh first"
        exit 1
    fi
    
    echo "Found assets at: $ASSETS_DIR"
    
    # Run the mark-as-unread patch script
    /Users/anastasia/workspace_ai/aion-ui-customizations/patches/apply-mark-as-unread.sh "$ASSETS_DIR"
}

case "$TARGET" in
    aionui)
        apply_aionui
        ;;
    codex)
        apply_codex
        ;;
    all)
        apply_aionui
        echo ""
        apply_codex
        ;;
    *)
        echo "Usage: $0 [aionui|codex|all]"
        echo "  aionui  - Apply AionUI permission bypass"
        echo "  codex   - Apply Codex mark-as-unread patches"
        echo "  all     - Apply both (default)"
        exit 1
        ;;
esac
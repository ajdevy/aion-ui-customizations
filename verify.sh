#!/bin/bash
set -euo pipefail

# Unified verify script for AionUI and Codex customizations
# Usage: ./verify.sh [aionui|codex|all]

TARGET="${1:-all}"

verify_aionui() {
    echo "=== AionUI OpenCode Assistant Permission State ==="
    echo ""
    
    DB="$HOME/Library/Application Support/AionUi/aionui/aionui-backend.db"

    if [ ! -f "$DB" ]; then
        echo "AionUI database not found at $DB"
        echo "Is AionUI installed?"
        return 0
    fi

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
}

verify_codex() {
    echo "=== Codex Mark-as-Unread Patch Status ==="
    echo ""
    
    ASSETS_DIR="${CODEX_ASSETS_DIR:-/Users/anastasia/workspace_ai/codex-intel/work/install.Gs99wx/app-extract/webview/assets}"

    if [ ! -d "$ASSETS_DIR" ]; then
        echo "Codex assets directory not found at $ASSETS_DIR"
        echo "Set CODEX_ASSETS_DIR or run after codex-intel install.sh"
        return 0
    fi

    echo "Checking assets in: $ASSETS_DIR"
    echo ""

    # Check thread-overflow-menu
    THREAD_OVERFLOW=$(find "$ASSETS_DIR" -name 'thread-overflow-menu-*.js' | head -1)
    if [ -z "$THREAD_OVERFLOW" ]; then
        echo "❌ thread-overflow-menu-*.js not found"
    else
        echo "✓ thread-overflow-menu found: $(basename "$THREAD_OVERFLOW")"
        if grep -q "markThreadAsUnread:tu" "$THREAD_OVERFLOW"; then
            echo "  ✓ markThreadAsUnread/Read destructured"
        else
            echo "  ✗ markThreadAsUnread/Read NOT patched"
        fi
        if grep -q "eT?z.markThreadRead:z.markThreadUnread" "$THREAD_OVERFLOW"; then
            echo "  ✓ Menu item conditional rendering patched"
        else
            echo "  ✗ Menu item conditional rendering NOT patched"
        fi
    fi

    # Check projects-index-page
    PROJECTS_INDEX=$(find "$ASSETS_DIR" -name 'projects-index-page-*.js' | head -1)
    if [ -z "$PROJECTS_INDEX" ]; then
        echo "❌ projects-index-page-*.js not found"
    else
        echo "✓ projects-index-page found: $(basename "$PROJECTS_INDEX")"
        if grep -q "hasUnreadTurn:d" "$PROJECTS_INDEX"; then
            echo "  ✓ hasUnreadTurn prop passed to Vt"
        else
            echo "  ✗ hasUnreadTurn prop NOT patched"
        fi
        if grep -q "Z.c)(7)" "$PROJECTS_INDEX"; then
            echo "  ✓ Cache size increased to 7"
        else
            echo "  ✗ Cache size NOT increased"
        fi
        if grep -q "d=r(Pe,i)" "$PROJECTS_INDEX"; then
            echo "  ✓ hasUnreadTurn selector added"
        else
            echo "  ✗ hasUnreadTurn selector NOT added"
        fi
    fi
}

case "$TARGET" in
    aionui)
        verify_aionui
        ;;
    codex)
        verify_codex
        ;;
    all)
        verify_aionui
        echo ""
        verify_codex
        ;;
    *)
        echo "Usage: $0 [aionui|codex|all]"
        echo "  aionui  - Verify AionUI permission bypass"
        echo "  codex   - Verify Codex mark-as-unread patches"
        echo "  all     - Verify both (default)"
        exit 1
        ;;
esac
#!/bin/bash
set -euo pipefail

# Revert "Mark as unread" patches for Codex/Codex-Intel
# Since the patches modify files in place, the only reliable way to revert
# is to re-extract the app bundle by re-running the installer.

ASSETS_DIR="${1:-/Users/anastasia/workspace_ai/codex-intel/work/install.Gs99wx/app-extract/webview/assets}"

if [ ! -d "$ASSETS_DIR" ]; then
    echo "Assets directory not found: $ASSETS_DIR"
    exit 1
fi

echo "Reverting Mark-as-Unread patches..."
echo ""
echo "Since patches modify the extracted app bundle in place,"
echo "the only reliable way to revert is to re-extract the app bundle."
echo ""
echo "Run codex-intel's install.sh again to re-extract a clean app bundle:"
echo "  cd /Users/anastasia/workspace_ai/codex-intel"
echo "  ./install.sh /path/to/Codex*.app"
echo ""
echo "Or if you have a backup of the original extracted files, restore them."
echo ""
echo "To manually revert, you would need to restore these files:"
find "$ASSETS_DIR" -name 'thread-overflow-menu-*.js' -o -name 'projects-index-page-*.js' | while read f; do
    echo "  $f"
done
echo ""
echo "Note: If you created backups before patching, restore those instead."
# AionUI & Codex Customizations

Customizations for:
- **AionUI** — the AI agent desktop app that uses opencode as its backend
- **Codex Desktop (Intel Mac)** — OpenAI Codex app converted for Intel Macs via codex-intel

## Features

| Customization | Target App | Description |
|---------------|------------|-------------|
| **Permission Bypass** | AionUI | Bypass all OpenCode permission prompts (edit, bash, read, etc.) |
| **Mark as Unread** | Codex/Codex-Intel | Add "Mark as unread"/"Mark as read" to conversation overflow menu with blue dot indicator |

---

## 1. Permission Bypass (AionUI)

Configures AionUI's OpenCode assistants to **bypass all permission prompts** so the agent runs in full-access mode without asking for confirmation.

### Files
- `apply.sh` — Applies the permission bypass to AionUI's backend database
- `revert.sh` — Reverts back to default `auto` permission mode
- `verify.sh` — Checks current permission state for OpenCode assistants

### How it works
AionUI stores assistant configuration in SQLite at:
```
~/Library/Application Support/AionUi/aionui/aionui-backend.db
```

Sets `default_permission_mode = 'fixed'` with `default_permission_value = 'agent-full-access'`.

### Usage
```bash
# Apply (bypass all permission prompts)
./apply.sh

# Verify current state
./verify.sh

# Revert to auto (agent defaults)
./revert.sh
```

---

## 2. Mark as Unread (Codex / Codex-Intel)

Adds "Mark as unread" and "Mark as read" menu items to the conversation overflow menu (three-dot menu) in the sidebar. Shows a blue dot indicator for unread conversations.

### Files
- `patches/apply-mark-as-unread.sh` — Applies the JS patches to extracted app bundle
- `patches/revert-mark-as-unread.sh` — Restores original files (requires backup)

### How it works
Patches the extracted Electron app's webview assets:
1. `thread-overflow-menu-*.js` — Adds the menu items and action handlers
2. `projects-index-page-*.js` — Passes `hasUnreadTurn` state to the menu

The feature uses existing backend infrastructure (`markConversationAsRead`/`markConversationAsUnread` IPC handlers) that was already implemented but not exposed in the UI.

### Usage
```bash
# After running codex-intel's install.sh (which extracts app.asar):
./patches/apply-mark-as-unread.sh /path/to/extracted/app/webview/assets

# Or with default codex-intel path:
./patches/apply-mark-as-unread.sh
```

**Note:** This must be run after extracting the app bundle. For codex-intel, run it after `./install.sh` completes the extraction step.

### How it looks
- Right-click (or click ⋯) on any conversation in the sidebar → "Mark as unread" / "Mark as read"
- Unread conversations show a blue dot indicator in the sidebar
- Works for both regular conversations and project conversations

---

## Reinstalling

If AionUI or Codex is reinstalled, the database/app is rebuilt and customizations need to be re-applied:

```bash
# AionUI
./apply.sh

# Codex (after re-running install.sh)
./patches/apply-mark-as-unread.sh
```

## Requirements
- macOS
- AionUI installed at `/Applications/AionUi.app` (for permission bypass)
- Codex/Codex-Intel installed (for mark-as-unread)
- SQLite3 (pre-installed on macOS)
- bash
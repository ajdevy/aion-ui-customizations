# AionUI Customizations

Customizations for [AionUI](https://aionui.ai) — the AI agent desktop app that uses opencode as its backend.

## What this does

Configures AionUI's OpenCode assistants to **bypass all permission prompts** (edit, bash, read, etc.) so the agent runs in full-access mode without asking for confirmation.

## Files

| File | Purpose |
|------|---------|
| `apply.sh` | Applies the permission bypass to AionUI's backend database |
| `revert.sh` | Reverts back to default `auto` permission mode |
| `verify.sh` | Checks current permission state for OpenCode assistants |

## How it works

AionUI stores assistant configuration in a SQLite database at:

```
~/Library/Application Support/AionUi/aionui/aionui-backend.db
```

The `assistant_definitions` table has two relevant columns:

- `default_permission_mode` — `'auto'` (agent default) or `'fixed'` (override)
- `default_permission_value` — when `fixed`, the permission mode to use:
  - `'agent-full-access'` — no permission prompts, full access
  - `'yolo'` — same as full access (alias)
  - `'build'` — normal mode (asks for permissions)
  - `'plan'` — read-only, no edit tools

Setting `default_permission_mode` to `'fixed'` with value `'agent-full-access'` bypasses all permission prompts.

## Usage

```bash
# Apply (bypass all permission prompts)
./apply.sh

# Verify current state
./verify.sh

# Revert to auto (agent defaults)
./revert.sh
```

**Note:** Changes apply to **new conversations only**. Existing conversations keep their current permission snapshot.

## Requirements

- macOS (AionUI is a macOS Electron app)
- AionUI installed at `/Applications/AionUi.app`
- SQLite3 (pre-installed on macOS)

## Reinstalling

If AionUI is reinstalled, the database is rebuilt and these customizations need to be re-applied. Run `./apply.sh` after reinstall.

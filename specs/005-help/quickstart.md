# Quickstart: /mykit.help Implementation

**Branch**: `005-help` | **Date**: 2025-12-06

## Overview

This guide provides implementation instructions for the `/mykit.help` command.

## Prerequisites

- Understanding of Claude Code slash command pattern
- Access to `.claude/commands/` directory
- Familiarity with `docs/COMMANDS.md` structure

## Implementation Steps

### Step 1: Update Command File Structure

Replace the stub in `.claude/commands/mykit.help.md` with the full implementation.

**File**: `.claude/commands/mykit.help.md`

The command should handle three modes based on `$ARGUMENTS`:
1. **No arguments**: Display categorized command overview
2. **Command name**: Display detailed help for specific command
3. **"workflow"**: Display workflow cheatsheets

### Step 2: Command Overview Mode (P1)

When `$ARGUMENTS` is empty, display all commands grouped by category:

```markdown
# My Kit Commands

## Read-Only Commands
| Command | Description |
|---------|-------------|
| /mykit.status | Show current workflow state |
| /mykit.help | Show command documentation |

## Workflow Commands
[... continue for each category ...]
```

**Source**: Extract from `docs/COMMANDS.md`

### Step 3: Specific Command Help Mode (P2)

When `$ARGUMENTS` contains a command name (e.g., "commit"):

1. Read `.claude/commands/mykit.{name}.md`
2. Check for `**Stub**` marker to determine status
3. Display structured help:

```markdown
# /mykit.commit

Create a commit with conventional format.

**Status**: Stub - Implementation pending

## Usage
/mykit.commit [create]

## Actions
- `create`: Create the commit

## Flags
- `--force`: Bypass validation gates
- `--yes`, `-y`: Skip confirmation prompts

## Examples
/mykit.commit          # Preview commit
/mykit.commit create   # Create the commit
```

### Step 4: Unknown Command Handling (P2)

When `$ARGUMENTS` doesn't match any known command:

```markdown
Unknown command: "{input}"

Available commands:
- /mykit.backlog
- /mykit.commit
[... list all commands ...]

Run `/mykit.help` for full documentation.
```

### Step 5: Workflow Mode (P3)

When `$ARGUMENTS` is "workflow":

```markdown
# My Kit Workflows

## Full Workflow (with Spec Kit)
/mykit.start run → /mykit.backlog select → /speckit.specify → ...

## Lite Workflow (My Kit only)
/mykit.start run → /mykit.backlog select → /mykit.specify create → ...

## Quick Fix
/mykit.start run → /mykit.backlog select → (implement) → ...
```

**Source**: Extract from `docs/COMMANDS.md` Workflow Cheatsheet section

## Testing Checklist

- [ ] `/mykit.help` displays all commands grouped by category
- [ ] `/mykit.help commit` shows detailed help for /mykit.commit
- [ ] `/mykit.help workflow` shows workflow cheatsheets
- [ ] `/mykit.help invalid` shows error with command list
- [ ] Help works from any directory (no repo context required)
- [ ] Output renders correctly in 80-column terminal
- [ ] Stub commands show "Status: Stub" indicator

## Files Modified

| File | Action | Purpose |
|------|--------|---------|
| `.claude/commands/mykit.help.md` | UPDATE | Replace stub with full implementation |

## Notes

- No new files needed - update existing stub only
- Sources data from existing `docs/COMMANDS.md` - no duplication
- Read-only command with no side effects

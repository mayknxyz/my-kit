# Quickstart: Session Purpose Prompt (/mykit.start)

**Branch**: `004-session-purpose` | **Date**: 2025-12-05

## Overview

The `/mykit.start` command initiates a workflow session by prompting the user to select their work type. This guides downstream commands to behave appropriately for the complexity of the task.

## Usage

```
/mykit.start
```

No arguments required. The command always prompts for selection (no remembered defaults).

## Workflow Options

| Option | When to Use |
|--------|-------------|
| **1. Full workflow (Spec Kit)** | Complex features requiring specification, planning, and structured implementation |
| **2. Lite workflow (My Kit)** | Simple changes that need some structure but not full documentation |
| **3. Quick fix** | Rapid fixes or minor changes with no formal planning |

## Example Session

```
User: /mykit.start

Claude: Select your workflow type:

1. Full workflow (Spec Kit) - Complex features
2. Lite workflow (My Kit) - Simple changes
3. Quick fix - No formal planning

Reply with the number (1, 2, or 3) or type the workflow name.

User: 1

Claude: ✓ Session type set to: Full workflow (Spec Kit)

Next step: Use /mykit.backlog to select or create an issue to work on.
```

## Selection Methods

Users can select their workflow by:
- **Number**: Type "1", "2", or "3"
- **Name**: Type "full", "lite", or "quickfix"
- **Full name**: Type "Full workflow", "Lite workflow", etc.

## Session Behavior

- **Always prompts**: No cached or remembered defaults
- **In-memory state**: Resets when Claude Code session ends
- **Directs to backlog**: After selection, guides user to `/mykit.backlog`

## Testing Checklist

- [ ] Command displays all three options with descriptions
- [ ] Selection via number (1, 2, 3) works correctly
- [ ] Selection via name ("full", "lite", "quickfix") works correctly
- [ ] Invalid input triggers re-prompt with valid options
- [ ] Confirmation message shows selected workflow type
- [ ] User is directed to `/mykit.backlog` after selection
- [ ] Each new invocation prompts again (no remembered state)

## Related Commands

| Command | Relationship |
|---------|--------------|
| `/mykit.backlog` | Next step after `/mykit.start` |
| `/mykit.status` | Shows current session type |
| `/mykit.reset` | Clears session state |

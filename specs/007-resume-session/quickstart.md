# Quickstart: Resume Interrupted Session

**Feature**: 007-resume-session
**Date**: 2025-12-06

## Overview

The `/mykit.resume` command displays saved session state to help developers quickly re-orient after an interruption. It reads from `.mykit/state.json` and shows branch, timestamp, workflow stage, and a suggested next command.

## Prerequisites

- Claude Code CLI installed and configured
- Git repository initialized
- My Kit commands available (`.claude/commands/mykit.*.md`)

## Usage

```
/mykit.resume
```

No arguments required. The command executes immediately (read-only).

## Expected Output

### With Valid State

```markdown
# Resume Session

## Last Session
**Branch**: 007-resume-session
**Saved**: 2025-12-06T14:30:00Z (2 hours ago)
**Stage**: Planning
**Type**: Full workflow

## Suggested Next Step
`/speckit.plan` - Continue with implementation planning
```

### With Warnings

```markdown
# Resume Session

## Last Session
**Branch**: 005-old-feature
**Saved**: 2025-11-25T10:00:00Z (11 days ago)
**Stage**: Implementation
**Type**: Full workflow

## Warnings
⚠️ **Stale State**: Last saved 11 days ago. State may be outdated.
⚠️ **Branch Mismatch**: Currently on `main`, state saved on `005-old-feature`.

## Suggested Next Step
`/mykit.status` - Check current project status
```

### Without State

```markdown
# Resume Session

No saved session state found.

To start a new session, run:
- `/mykit.start` - Begin a new workflow session
- `/mykit.status` - View current project status
```

### With Corrupted State

```markdown
# Resume Session

**Error**: Unable to read session state. The file may be corrupted.

To start fresh:
1. Delete `.mykit/state.json`
2. Run `/mykit.start` to begin a new session
```

## Implementation Steps

1. **Check for state file**: Read `.mykit/state.json`
2. **Validate JSON**: Parse and validate against schema
3. **Validate project**: Check projectId matches current project
4. **Check staleness**: Compare timestamp to current time
5. **Check branch**: Compare saved branch to current branch
6. **Detect workflow stage**: Check spec files in `specs/{branch}/`
7. **Generate suggestion**: Based on stage and file status
8. **Format output**: Display structured card format

## Related Commands

| Command | Description |
|---------|-------------|
| `/mykit.start` | Start a new workflow session (writes state) |
| `/mykit.status` | Show current workflow status |
| `/mykit.help` | Get help with My Kit commands |

## Notes

- This command is **read-only** - it never modifies state.json
- State is written by other commands (`/mykit.start`, `/speckit.*`, `/mykit.commit`)
- If no state exists, the user is guided to start a new session

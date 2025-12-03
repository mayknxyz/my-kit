# My Kit Command Conventions

This document defines the conventions for creating and using My Kit commands.

## Command Pattern

```
/mykit.{command} [action] [flags]
```

- **Read-only commands**: Execute immediately, no action required
- **State-changing commands**: Require an action to execute

## Command Actions

### Read-only (no action needed)

| Command | Description |
|---------|-------------|
| `/mykit.status` | Show current workflow state |
| `/mykit.help` | Show documentation |

### State-changing (action required)

| Command | Actions | Description |
|---------|---------|-------------|
| `/mykit.init` | `create` | Initialize My Kit in repo |
| `/mykit.setup` | `run` | Run onboarding wizard |
| `/mykit.start` | `run` | Begin workflow session |
| `/mykit.backlog` | `select` | Select issue and create branch |
| `/mykit.specify` | `create` | Create lightweight spec |
| `/mykit.plan` | `create` | Create implementation plan |
| `/mykit.tasks` | `generate` | Generate task breakdown |
| `/mykit.implement` | `run` | Execute tasks |
| `/mykit.validate` | `run`, `fix` | Run checks / auto-fix |
| `/mykit.commit` | `create` | Create commit |
| `/mykit.pr` | `create`, `update` | Create/update PR |
| `/mykit.release` | `publish` | Create release |
| `/mykit.reset` | `run` | Clear state |
| `/mykit.resume` | `run` | Resume session |
| `/mykit.upgrade` | `run` | Upgrade My Kit |

## Flag Conventions

| Flag | Purpose | Commands |
|------|---------|----------|
| `--force` | Bypass validation | validate, commit, pr |
| `--yes`, `-y` | Skip confirmations | All with prompts |
| `--json` | JSON output | status, validate |
| `--no-issue` | Work without issue | backlog, specify |
| `--label` | Filter by label | backlog |
| `--assignee` | Filter by assignee | backlog |

## File Structure

| Aspect | Convention |
|--------|------------|
| Location | `.claude/commands/` |
| Naming | `mykit.{command}.md` (e.g., `mykit.commit.md`) |
| Header | YAML frontmatter with `description` (required) |

### Command File Template

```markdown
---
description: One-line description of what the command does
---

## Overview

Brief explanation of the command's purpose.

## Usage

`/mykit.{command} [action] [flags]`

## Actions

| Action | Description |
|--------|-------------|
| (none) | Preview what will happen |
| `create` | Execute the operation |

## Flags

| Flag | Description |
|------|-------------|
| `--force` | Bypass validation |

## Prerequisites

- List requirements before command can run

## Examples

/mykit.commit           # Preview
/mykit.commit create    # Execute
```

## Output Format

### Preview Mode (no action)

```
/mykit.commit

Changes to commit:
  - src/file.ts (modified)
  - tests/file.test.ts (added)

Changelog entry:
  feat: add new feature

To execute: /mykit.commit create
```

### Execution Mode (with action)

```
/mykit.commit create

✓ Changes staged
✓ CHANGELOG updated
✓ Commit created: abc1234

Next: /mykit.pr create
```

## State Management

**State File:** `.mykit/state.json`

```json
{
  "version": "1.0.0",
  "current_feature": {
    "issue_number": 42,
    "branch": "42-feature-name",
    "spec_path": "specs/42-feature-name/"
  },
  "workflow_step": "implementation",
  "last_command": "/mykit.commit",
  "last_command_time": "2025-12-03T12:00:00Z"
}
```

**Rules:**
- Commands read state at start
- Commands update state after successful execution
- Use file locking for atomic writes

## Error Handling

| Exit Code | Meaning |
|-----------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Pre-condition failure |
| 3 | Auth/network error |
| 4 | Git operation error |

**Error Message Format:**

```
Error: [CATEGORY] Description of what went wrong

Remediation:
  - Step to fix the issue
  - Alternative approach
```

## Directory Structure

```
specs/{issue}-{slug}/
├── spec.md
├── plan.md
└── tasks.md

.mykit/
├── config.json
├── state.json
├── scripts/
└── cache/

.claude/commands/
└── mykit.*.md
```

## Issue Linking

- Branch format: `{issue-number}-{slug}` (e.g., `42-add-auth`)
- Spec directory: `specs/{issue-number}-{slug}/`
- PR body: Auto-includes `Closes #{issue-number}`
- Exception: `--no-issue` flag for one-off work

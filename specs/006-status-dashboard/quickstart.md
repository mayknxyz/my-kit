# Quickstart: Enhanced Status Dashboard

**Feature**: 006-status-dashboard
**Date**: 2025-12-06

## Overview

This guide explains how to implement the `/mykit.status` enhanced dashboard command.

## Prerequisites

- Claude Code installed and configured
- Git repository initialized
- GitHub CLI (`gh`) installed and authenticated (optional, for issue details)

## Implementation Summary

The `/mykit.status` command is a Claude Code slash command implemented as a markdown file at `.claude/commands/mykit.status.md`. When invoked, Claude Code reads the instructions and executes the steps to gather and display status information.

## Key Implementation Steps

### 1. Gather Feature Context

```bash
# Get current branch
git rev-parse --abbrev-ref HEAD

# Extract issue number from branch (pattern: {number}-{slug})
# Example: 006-status-dashboard → 006

# Get issue details (if gh available)
gh issue view 6 --json number,title,state
```

### 2. Detect Workflow Phase

Check file existence in `specs/{branch-name}/`:

```
specs/006-status-dashboard/
├── spec.md    → Specification phase
├── plan.md    → Planning phase
└── tasks.md   → Implementation phase
```

### 3. Gather File Status

```bash
# Get machine-readable file status
git status --porcelain

# Example output:
# M  src/file.ts        (staged modification)
#  M src/other.ts       (unstaged modification)
# ?? new-file.txt       (untracked)
```

### 4. Determine Next Command

Apply suggestion logic based on:
- Current workflow phase
- Whether uncommitted changes exist

### 5. Format Output

Display structured markdown dashboard:

```markdown
# My Kit Status

## Feature Context
**Branch**: 006-status-dashboard
**Issue**: #6 - feat: /mykit.status - enhanced dashboard (OPEN)

## Workflow Phase
**Current**: Implementation
**Progress**: spec.md ✓ | plan.md ✓ | tasks.md ✓

## File Status
✓ staged   src/commands/status.md
  modified src/utils/git.ts

(2 files changed)

## Next Step
`/mykit.commit create` - Commit your implementation changes
```

## Error Handling

| Scenario | Display |
|----------|---------|
| Not in git repo | "Not in a git repository. Run `git init` to initialize." |
| Not a feature branch | Show branch name with note about using `/mykit.backlog` |
| gh unavailable | Show local git info only with "GitHub info unavailable" note |
| Detached HEAD | Warning message with current commit hash |

## Testing

Test the command in these scenarios:

1. **Feature branch with all artifacts**: Full dashboard display
2. **Feature branch, spec only**: Show specification phase
3. **Main branch**: No feature context message
4. **With staged changes**: Staged files marked with ✓
5. **With 15+ files changed**: Shows first 10 with "+5 more" summary
6. **Without gh authenticated**: Graceful degradation message

## File Location

```
.claude/commands/mykit.status.md
```

## Related Commands

| Command | Relationship |
|---------|-------------|
| `/mykit.start` | Sets session workflow type |
| `/mykit.help` | Shows command documentation |
| `/mykit.commit` | Common next step suggestion |

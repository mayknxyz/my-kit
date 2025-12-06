# Data Model: Enhanced Status Dashboard

**Feature**: 006-status-dashboard
**Date**: 2025-12-06

## Overview

This document defines the data structures gathered and displayed by `/mykit.status`. As a read-only command, these are ephemeral structures computed on each invocation - no persistence required.

---

## Entities

### 1. FeatureContext

Represents the current feature being worked on.

| Field | Type | Source | Description |
|-------|------|--------|-------------|
| branch | string | `git rev-parse --abbrev-ref HEAD` | Current git branch name |
| issueNumber | number \| null | Parsed from branch pattern `^([0-9]+)-` | Linked GitHub issue number |
| issueTitle | string \| null | `gh issue view` | Issue title from GitHub |
| issueState | enum | `gh issue view` | Issue state: OPEN, CLOSED |
| isFeatureBranch | boolean | Derived | True if branch matches `{number}-{slug}` pattern |
| isDetachedHead | boolean | Derived | True if branch equals "HEAD" |

**Validation Rules**:
- `branch` is never null (always returns something from git)
- `issueNumber` is null if branch doesn't match feature branch pattern
- `issueTitle` and `issueState` are null if gh unavailable or issue not found

---

### 2. WorkflowState

Represents the current phase in the spec-driven workflow.

| Field | Type | Source | Description |
|-------|------|--------|-------------|
| phase | enum | File existence check | Current workflow phase |
| specExists | boolean | Check `specs/{branch}/spec.md` | Specification file present |
| planExists | boolean | Check `specs/{branch}/plan.md` | Plan file present |
| tasksExists | boolean | Check `specs/{branch}/tasks.md` | Tasks file present |
| specsDir | string | Derived | Path to specs directory for current branch |

**Phase Enum Values**:
| Value | Condition |
|-------|-----------|
| `not_started` | No spec.md exists |
| `specification` | spec.md exists, no plan.md |
| `planning` | plan.md exists, no tasks.md |
| `implementation` | tasks.md exists |

**Validation Rules**:
- Phase is derived from file existence, never manually set
- specsDir follows pattern `specs/{branch-name}/`

---

### 3. FileStatus

Represents a single changed file in the working directory.

| Field | Type | Source | Description |
|-------|------|--------|-------------|
| path | string | `git status --porcelain` | Relative file path |
| indexStatus | char | First char of porcelain output | Status in staging area |
| workTreeStatus | char | Second char of porcelain output | Status in working tree |
| displayStatus | string | Derived | Human-readable status label |
| isStaged | boolean | Derived | True if change is staged |

**Display Status Mapping**:
| indexStatus | workTreeStatus | displayStatus | isStaged |
|-------------|----------------|---------------|----------|
| M | _ | "modified" | true |
| _ | M | "modified" | false |
| A | _ | "added" | true |
| ? | ? | "untracked" | false |
| D | _ | "deleted" | true |
| _ | D | "deleted" | false |
| R | _ | "renamed" | true |

---

### 4. FileStatusSummary

Aggregated view of all file changes.

| Field | Type | Description |
|-------|------|-------------|
| files | FileStatus[] | List of changed files (max 10 for display) |
| totalCount | number | Total number of changed files |
| stagedCount | number | Number of staged files |
| unstagedCount | number | Number of unstaged files |
| isClean | boolean | True if no changes (totalCount === 0) |
| hasOverflow | boolean | True if totalCount > 10 |

**Validation Rules**:
- `files` array limited to first 10 entries
- `hasOverflow` is true when `totalCount > 10`
- Display shows "+{totalCount - 10} more" when overflow

---

### 5. CommandSuggestion

Recommended next action based on current state.

| Field | Type | Description |
|-------|------|-------------|
| command | string | Suggested slash command (e.g., `/mykit.commit create`) |
| reason | string | Brief explanation of why this is suggested |
| priority | enum | Suggestion priority: primary, secondary |

**Suggestion Logic**:
| Phase | Has Changes | Primary Suggestion |
|-------|-------------|-------------------|
| not_started | any | `/mykit.backlog select` - "Select an issue to work on" |
| specification | no | `/speckit.clarify` or `/speckit.plan` - "Review or plan the specification" |
| specification | yes | `/mykit.commit create` - "Commit your specification changes" |
| planning | no | `/speckit.tasks` - "Generate implementation tasks" |
| planning | yes | `/mykit.commit create` - "Commit your planning changes" |
| implementation | no | `/mykit.pr create` - "Create a pull request" |
| implementation | yes | `/mykit.commit create` - "Commit your implementation changes" |

---

## Relationships

```
┌─────────────────┐
│ FeatureContext  │
│ - branch        │
│ - issueNumber   │──────────────────┐
│ - issueTitle    │                  │
└────────┬────────┘                  │
         │ derives specsDir          │
         ▼                           │
┌─────────────────┐                  │
│ WorkflowState   │                  │
│ - phase         │                  │
│ - specExists    │                  │
│ - planExists    │                  │
│ - tasksExists   │                  │
└────────┬────────┘                  │
         │                           │
         │ combined with             │
         ▼                           ▼
┌─────────────────┐         ┌─────────────────┐
│ FileStatusSum   │         │ CommandSugg.    │
│ - files[]       │────────▶│ - command       │
│ - totalCount    │         │ - reason        │
│ - isClean       │         └─────────────────┘
└─────────────────┘
```

---

## State Transitions

The command is stateless - no transitions to track. Each invocation computes fresh state from:
1. Git repository state
2. GitHub API (if available)
3. File system (specs directory)

---

## Data Sources Summary

| Data | Source Command | Fallback |
|------|---------------|----------|
| Branch name | `git rev-parse --abbrev-ref HEAD` | Error message |
| Issue details | `gh issue view {n} --json number,title,state` | "GitHub unavailable" |
| Workflow files | File existence check via Claude Code Read tool | N/A |
| File status | `git status --porcelain` | "Unable to read status" |

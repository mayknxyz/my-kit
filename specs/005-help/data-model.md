# Data Model: /mykit.help Command

**Branch**: `005-help` | **Date**: 2025-12-06

## Overview

The help command operates on read-only data extracted from existing markdown files. No persistent storage or database entities are needed. This document defines the conceptual entities for documentation purposes.

## Entities

### Command

A `/mykit.*` operation that users can invoke.

| Field | Type | Description | Source |
|-------|------|-------------|--------|
| name | string | Command name without prefix (e.g., "commit") | Filename: `mykit.{name}.md` |
| fullName | string | Full command path (e.g., "/mykit.commit") | Derived from name |
| description | string | One-line summary of command purpose | First paragraph after `# /mykit.{name}` |
| category | enum | Logical grouping | `docs/COMMANDS.md` tables |
| type | enum | "read-only" or "state-changing" | `docs/COMMANDS.md` section |
| actions | string[] | Available action verbs (e.g., ["create", "update"]) | `docs/COMMANDS.md` Actions column |
| flags | Flag[] | Available command flags | `docs/COMMANDS.md` Flags column |
| examples | string[] | Usage examples | `docs/COMMANDS.md` Examples section |
| status | enum | "implemented" or "stub" | Presence of `**Stub**` in command file |

**Validation Rules**:
- `name` must match pattern `[a-z]+`
- `fullName` must match pattern `/mykit.[a-z]+`
- `description` must be non-empty, ≤100 characters for overview display

### Category

A logical grouping of related commands.

| Field | Type | Description |
|-------|------|-------------|
| id | string | Category identifier (e.g., "workflow") |
| label | string | Display name (e.g., "Workflow") |
| order | number | Display order (1-5) |
| commands | Command[] | Commands in this category |

**Categories** (from `docs/COMMANDS.md`):
1. Read-Only (status, help)
2. Workflow (init, setup, start, resume, reset)
3. Issue & Branch (backlog)
4. Lite Workflow (specify, plan, tasks, implement)
5. Quality & Commit (validate, commit, pr, release)
6. Management (upgrade)

### Flag

A command-line flag that modifies command behavior.

| Field | Type | Description |
|-------|------|-------------|
| name | string | Long flag name (e.g., "--force") |
| short | string? | Short alias (e.g., "-y") |
| description | string | What the flag does |
| commands | string[] | Commands that accept this flag |

**Standard Flags** (from `docs/COMMANDS.md`):
- `--force`: Bypass validation gates
- `--yes` / `-y`: Skip confirmation prompts
- `--json`: Machine-readable output
- `--no-issue`: Work without issue linking
- `--label`: Filter issues by label
- `--assignee`: Filter issues by assignee

### Workflow

A sequence of commands for a specific development goal.

| Field | Type | Description |
|-------|------|-------------|
| id | string | Workflow identifier |
| name | string | Display name |
| description | string | When to use this workflow |
| steps | string[] | Ordered command sequence |

**Workflows** (from `docs/COMMANDS.md`):
1. **Full** (with Spec Kit): start → backlog → speckit.specify → speckit.plan → speckit.tasks → speckit.implement → validate → commit → pr
2. **Lite** (My Kit only): start → backlog → specify → plan → tasks → implement → validate → commit → pr
3. **Quick Fix**: start → backlog → (implement) → validate → commit → pr

## Entity Relationships

```text
Category 1───* Command
Command *───* Flag
Workflow 1───* Command (ordered sequence)
```

## State Transitions

Not applicable - all entities are read-only reference data with no state changes.

## Data Sources

| Entity | Primary Source | Fallback |
|--------|---------------|----------|
| Command (list) | `docs/COMMANDS.md` | None |
| Command (detail) | `.claude/commands/mykit.{name}.md` | `docs/COMMANDS.md` |
| Category | `docs/COMMANDS.md` section headers | None |
| Flag | `docs/COMMANDS.md` Flag Reference | None |
| Workflow | `docs/COMMANDS.md` Workflow Cheatsheet | None |

---
name: mykit-ops
description: My Kit standalone utilities — handles code audits, project constitution management, and task-to-issue conversion.
---

# My Kit Operations

Handles 3 standalone utility operations: audit, constitution, and taskstoissues. Auto-activates when the user expresses intent to audit code, manage the project constitution, or convert tasks to GitHub issues.

## Trigger Keywords

- **audit**: "audit", "run audit", "code audit", "quality check", "security check", "check code quality"
- **constitution**: "constitution", "project principles", "governance", "amend constitution", "create constitution"
- **taskstoissues**: "tasks to issues", "create issues from tasks", "convert tasks", "github issues from tasks"

## Step Identification

| Step | Keywords | Description |
|------|----------|-------------|
| `audit` | audit, quality check, security check | Run comprehensive audit (quality, security, perf, a11y, deps) |
| `constitution` | constitution, principles, governance | Create or amend project constitution |
| `taskstoissues` | tasks to issues, convert tasks | Convert tasks.md entries to GitHub issues |

## Routing Logic

### 1. Identify Step

Map user intent to one of the 3 steps: `audit`, `constitution`, or `taskstoissues`.

### 2. Load Reference File

| Step | Reference |
|------|-----------|
| audit | `references/audit.md` |
| constitution | `references/constitution.md` |
| taskstoissues | `references/taskstoissues.md` |

**Load only the one reference file needed per invocation.**

### 3. Execute Reference Instructions

Follow the loaded reference file's instructions exactly. Each reference contains the complete workflow:

- **audit.md**: 5-domain parallel audit (quality, security, performance, accessibility, dependencies) using dedicated agents, aggregated scoring, and actionable recommendations
- **constitution.md**: Preview/create/amend modes for project constitution with interactive principle collection, semantic versioning, and dependency scan
- **taskstoissues.md**: Parse tasks.md, validate GitHub remote, detect duplicates, topological sort by dependencies, create issues with labels and cross-references

## Reference Files

- `references/audit.md` — Comprehensive multi-domain audit workflow
- `references/constitution.md` — Project constitution management
- `references/taskstoissues.md` — Task-to-GitHub-issue conversion

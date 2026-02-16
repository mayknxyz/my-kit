---
name: mykit-workflow
description: My Kit development workflow — handles 4 development workflow steps: specify, plan, tasks, implement.
---

# My Kit Workflow

Handles the 4 development workflow steps. Auto-activates when the user expresses intent to work on specifications, plans, tasks, or implementation.

## Trigger Keywords

- **specify**: "write the spec", "create specification", "specify", "spec"
- **plan**: "write the plan", "create plan", "implementation plan", "plan this"
- **tasks**: "break into tasks", "task breakdown", "generate tasks", "create tasks"
- **implement**: "implement", "start coding", "execute tasks", "build this"

## Step Identification

Map user intent to one of 4 steps:

| Step | Keywords |
|------|----------|
| `specify` | spec, specification, specify |
| `plan` | plan, implementation plan |
| `tasks` | tasks, task breakdown |
| `implement` | implement, build, code |

## Routing Logic

### 1. Identify Step

Map user intent to one of the 4 steps.

### 2. Load Branch Context

All steps start by sourcing shared context:

```bash
source $HOME/.claude/skills/mykit/references/scripts/fetch-branch-info.sh
```

Sets `BRANCH`, `ISSUE_NUMBER`, `SPEC_PATH`, `PLAN_PATH`, `TASKS_PATH`.

### 3. Load Reference File

Based on the step, load the appropriate reference file:

| Step | Reference |
|------|-----------|
| specify | `references/specify.md` |
| plan | `references/plan.md` |
| tasks | `references/tasks.md` |
| implement | `references/implement.md` |

**Load only the one reference file needed per invocation.**

### 4. Execute Reference Instructions

Follow the loaded reference file's instructions exactly. The reference file contains the complete step-by-step workflow for that step.

## Plan Mode Rule

When a spec file exists at `specs/{branch}/spec.md`, always use `/mykit.plan` (this skill) instead of Claude Code's native `EnterPlanMode`. `EnterPlanMode` should only be used for exploration and research when no spec file exists yet.

## Shared Patterns

See `references/routing.md` for shared routing patterns and branch/path conventions used across all workflow steps.

## Reference Files

- `references/routing.md` — Shared routing patterns, branch/path conventions
- `references/` — 5 files (specify, plan, tasks, implement, issue-review)

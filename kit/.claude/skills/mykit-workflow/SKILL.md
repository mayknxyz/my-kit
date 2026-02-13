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

### 2. Handle Existing Artifacts

For artifact-producing steps (specify, plan, tasks):
- If the artifact already exists, prompt via `AskUserQuestion`: overwrite or cancel
- If the artifact does not exist, create it

### 3. Load Reference File

Based on the step, load the appropriate reference file:

| Step | Reference |
|------|-----------|
| specify | `references/minor/specify.md` |
| plan | `references/minor/plan.md` |
| tasks | `references/minor/tasks.md` |
| implement | `references/minor/implement.md` |

**Load only the one reference file needed per invocation.**

### 4. Execute Reference Instructions

Follow the loaded reference file's instructions exactly. The reference file contains the complete step-by-step workflow for that step.

## Shared Patterns

See `references/routing.md` for shared routing patterns and branch/path conventions used across all workflow steps.

## Reference Files

- `references/routing.md` — Shared routing patterns, branch/path conventions
- `references/minor/` — 4 files (specify, plan, tasks, implement)

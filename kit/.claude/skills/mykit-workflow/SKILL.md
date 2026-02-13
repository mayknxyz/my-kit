---
name: mykit-workflow
description: My Kit development workflow — manages specify, plan, tasks, implement, clarify, analyze, and checklist steps across major, minor, and patch modes.
---

# My Kit Workflow

Handles the 7 development workflow steps across 3 modes (major, minor, patch). Auto-activates when the user expresses intent to work on specifications, plans, tasks, implementation, clarification, analysis, or checklists.

## Trigger Keywords

- **specify**: "write the spec", "create specification", "specify", "spec"
- **plan**: "write the plan", "create plan", "implementation plan", "plan this"
- **tasks**: "break into tasks", "task breakdown", "generate tasks", "create tasks"
- **implement**: "implement", "start coding", "execute tasks", "build this"
- **clarify**: "clarify the spec", "find ambiguities", "clarification questions"
- **analyze**: "analyze artifacts", "consistency check", "cross-artifact analysis"
- **checklist**: "quality checklist", "requirements checklist", "generate checklist"

## Step Identification

Map user intent to one of 7 steps:

| Step | Keywords | Modes Available |
|------|----------|----------------|
| `specify` | spec, specification, specify | major, minor, patch |
| `plan` | plan, implementation plan | major, minor, patch |
| `tasks` | tasks, task breakdown | major, minor, patch |
| `implement` | implement, build, code | major, minor, patch |
| `clarify` | clarify, ambiguities | major only |
| `analyze` | analyze, consistency | major only |
| `checklist` | checklist, quality gates | major only |

## Routing Logic

### 1. Read Session State

Read `.mykit/state.json` to determine the current mode:

```json
{
  "session": {
    "type": "major|minor|patch"
  }
}
```

If `session.type` is not set, prompt the user to select a mode using `AskUserQuestion`:
- header: "Workflow Mode"
- question: "Which workflow mode are you using?"
- options: Major, Minor, Patch

### 2. Validate Step Availability

For major-only steps (`clarify`, `analyze`, `checklist`):
- If mode is `minor` or `patch`, display error explaining the step requires Major mode
- Suggest the appropriate next step for their mode

### 3. CRUD Routing (for specify, plan, tasks)

These steps support CRUD operations via flags:

| Flag | Operation |
|------|-----------|
| `-c` / `--create` | Create new artifact |
| `-r` / `--read` | View existing artifact |
| `-u` / `--update` | Regenerate (overwrite) |
| `-d` / `--delete` | Remove artifact |

If no CRUD flag is provided, present an interactive menu using `AskUserQuestion`.

### 4. Load Reference File

Based on (step, mode), load the appropriate reference file:

| Step | Major | Minor | Patch |
|------|-------|-------|-------|
| specify | `references/major/specify.md` | `references/minor/specify.md` | `references/patch/specify.md` |
| plan | `references/major/plan.md` | `references/minor/plan.md` | `references/patch/plan.md` |
| tasks | `references/major/tasks.md` | `references/minor/tasks.md` | `references/patch/tasks.md` |
| implement | `references/major/implement.md` | `references/minor/implement.md` | `references/patch/implement.md` |
| clarify | `references/major/clarify.md` | — | — |
| analyze | `references/major/analyze.md` | — | — |
| checklist | `references/major/checklist.md` | — | — |

**Load only the one reference file needed per invocation.**

### 5. Execute Reference Instructions

Follow the loaded reference file's instructions exactly. The reference file contains the complete step-by-step workflow for that (step, mode) combination.

### 6. Update State

After successful execution, update `.mykit/state.json`:

```json
{
  "workflow_step": "{step}",
  "last_command": "/mykit.{step}",
  "last_command_time": "{ISO 8601 timestamp}"
}
```

## Shared Patterns

See `references/routing.md` for shared CRUD patterns and state management conventions used across all workflow steps.

## Reference Files

- `references/routing.md` — Shared CRUD routing, state management patterns
- `references/major/` — 7 files (specify, plan, tasks, implement, clarify, analyze, checklist)
- `references/minor/` — 4 files (specify, plan, tasks, implement)
- `references/patch/` — 4 files (specify, plan, tasks, implement)

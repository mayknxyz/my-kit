# Shared Routing Patterns

Common patterns used across all mykit-workflow steps.

## Branch Context

All steps start by sourcing `fetch-branch-info.sh` which sets:

- `BRANCH` — current git branch name
- `ISSUE_NUMBER` — extracted from branch pattern `^([0-9]+)-`, or empty
- `SPEC_PATH` — `specs/{branch}/spec.md`
- `PLAN_PATH` — `specs/{branch}/plan.md`
- `TASKS_PATH` — `specs/{branch}/tasks.md`

```bash
source $HOME/.claude/skills/mykit/references/scripts/fetch-branch-info.sh
```

## Prerequisite Chain

Each step requires its predecessor's artifact:

```
specify (requires issue#) → plan (requires spec.md) → tasks (requires plan.md) → implement (requires tasks.md)
```

## Artifact Handling

Steps that produce artifacts (specify, plan, tasks) follow this pattern:

### If Artifact Exists

When the target artifact already exists, prompt via `AskUserQuestion`:

```
header: "{Step Name}"
question: "A {artifact} already exists. What would you like to do?"
options:
  1. Overwrite — Replace the existing {artifact}
  2. Cancel — Keep the existing {artifact}
```

- **Overwrite**: Continue with creation (will replace the file)
- **Cancel**: Display "Operation cancelled." and stop

### If Artifact Does Not Exist

Proceed directly to creation.

## Branch and Path Conventions

- Feature branch pattern: `{issue-number}-{slug}` (e.g., `042-feature-name`)
- Spec directory: `specs/{branch}/`
- Artifacts: `spec.md`, `plan.md`, `tasks.md` within spec directory

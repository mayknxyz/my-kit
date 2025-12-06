# Quickstart: /mykit.tasks

**Date**: 2025-12-07
**Branch**: `011-task-generation`

## Prerequisites

- Git repository initialized
- On a feature branch matching pattern `{issue-number}-{slug}` (e.g., `011-task-generation`)
- No speckit artifacts (`research.md`, `data-model.md`, `contracts/`) in specs directory

## Basic Usage

### Preview Tasks (Default)

```
/mykit.tasks
```

Shows proposed tasks without creating any files. Use this to review before committing.

### Generate Tasks

```
/mykit.tasks create
```

Generates `tasks.md` in `specs/{branch}/` directory.

### Force Overwrite

```
/mykit.tasks create --force
```

Overwrites existing `tasks.md` without confirmation prompt.

## Usage Scenarios

### Scenario 1: With Existing Spec and Plan

**Setup**: You've already run `/mykit.specify create` and `/mykit.plan create`

```
/mykit.tasks create
```

**Result**: Tasks extracted from spec user stories and plan phases.

### Scenario 2: With Spec Only

**Setup**: You've run `/mykit.specify create` but skipped planning

```
/mykit.tasks create
```

**Result**: Tasks extracted from spec user stories and requirements.

### Scenario 3: With Plan Only

**Setup**: You've run `/mykit.plan create` but skipped specification

```
/mykit.tasks create
```

**Result**: Tasks extracted from plan phases.

### Scenario 4: No Documentation (Guided Mode)

**Setup**: No spec or plan exists in the specs directory

```
/mykit.tasks create
```

**Result**: System asks 3 questions, then generates tasks from your answers:

1. "What needs to be built or changed?"
2. "What components or files are affected?"
3. "What defines 'done' for this work?"

## Output Format

Generated `tasks.md` follows this structure:

```markdown
# Tasks: Feature Name

**Branch**: `011-task-generation` | **Created**: 2025-12-07 | **Source**: spec+plan

## Implementation

- [ ] T001 First implementation task
- [ ] T002 Second implementation task
- [ ] T003 Third implementation task
...

## Completion

- [ ] T0XX Run validation: `/mykit.validate`
- [ ] T0XX Create commit: `/mykit.commit create`
- [ ] T0XX Create pull request: `/mykit.pr create`
```

## Task Characteristics

- **Count**: 5-15 implementation tasks (plus 3 completion tasks)
- **Granularity**: Each task represents ~30 minutes to 2 hours of work
- **Format**: Checkbox list with T### numbering for tracking
- **Completion**: Always includes validate, commit, and PR tasks

## Workflow Integration

```
/mykit.specify create  →  /mykit.plan create  →  /mykit.tasks create  →  /mykit.implement
      (optional)              (optional)            (required)            (required)
```

After generating tasks, use `/mykit.implement` to execute them.

## Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| "Not in a git repository" | Not in git repo | Run `git init` or navigate to repo |
| "No feature branch detected" | On main/develop | Run `/mykit.backlog select` to create branch |
| "Use /speckit.tasks for full workflow" | Speckit artifacts exist | Use `/speckit.tasks` instead |
| "Operation cancelled" | User declined overwrite | Use `--force` or keep existing tasks |

## Next Steps

After generating tasks:

1. Review `tasks.md` in your specs directory
2. Run `/mykit.implement` to start working through tasks
3. Mark tasks complete as you progress
4. Use `/mykit.status` to check workflow state

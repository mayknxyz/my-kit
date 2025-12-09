# Quickstart: /mykit.implement

## Prerequisites

1. Be on a feature branch (e.g., `012-task-execution`)
2. Have a `tasks.md` file at `specs/{branch}/tasks.md`
3. Generated via `/mykit.tasks create` or `/speckit.tasks`

## Basic Usage

### View Progress (Read-Only)

```
/mykit.implement
```

Displays progress dashboard without executing any tasks.

### Execute Next Task

```
/mykit.implement run
```

1. Finds first incomplete task
2. Marks it in-progress
3. Autonomously executes the task
4. On success: marks complete, shows next task
5. On failure: keeps in-progress, reports error

### Mark Task Complete (Manual)

```
/mykit.implement complete
```

Use when:
- Task execution succeeded but wasn't auto-completed
- You finished the task manually
- You want to force-complete regardless of outcome

### Skip Current Task

```
/mykit.implement skip
```

Use when:
- You're blocked on the current task
- Task is no longer relevant
- You want to come back to it later

## Workflow Example

```bash
# 1. Generate tasks from spec/plan
/mykit.tasks create

# 2. Start implementing
/mykit.implement run
# → Executes T001, auto-completes, shows T002

/mykit.implement run
# → Executes T002, auto-completes, shows T003

# 3. Hit a blocker on T003
/mykit.implement skip
# → Skips T003, shows T004

# 4. Continue through remaining tasks
/mykit.implement run
# → Executes T004...

# 5. Complete all tasks including completion section
# → "All tasks complete! Run /mykit.pr create to submit"
```

## Task States

| State | Checkbox | Meaning |
|-------|----------|---------|
| Pending | `[ ]` | Not started |
| In-Progress | `[>]` | Currently being worked on |
| Complete | `[x]` | Successfully finished |
| Skipped | `[~]` | Intentionally bypassed |

## Error Handling

| Error | Solution |
|-------|----------|
| "No tasks.md found" | Run `/mykit.tasks create` first |
| "Not on feature branch" | Run `/mykit.backlog select` to pick an issue |
| "No tasks remaining" | All done! Run `/mykit.pr create` |
| "Execution failed" | Fix the issue manually, then `/mykit.implement complete` or `skip` |

## Tips

- **Resume after interruption**: Just run `/mykit.implement run` - it picks up from the in-progress task
- **Check progress anytime**: `/mykit.implement` (no action) shows dashboard
- **Skipped tasks reminder**: Shown when completing final task if any were skipped

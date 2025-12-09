# Data Model: /mykit.implement - Task Execution

**Branch**: `012-task-execution` | **Date**: 2025-12-09

## Entities

### Task

A single work item extracted from tasks.md.

| Field | Type | Description |
|-------|------|-------------|
| id | string | Task identifier (e.g., "T001", "T015") |
| description | string | Full task description text |
| status | enum | pending, in-progress, complete, skipped |
| section | enum | implementation, completion |
| line_number | integer | Line number in tasks.md (for updates) |

**Validation Rules**:
- `id` must match pattern `T[0-9]{3}` (e.g., T001, T042)
- `status` is derived from checkbox marker: `[ ]`=pending, `[>]`=in-progress, `[x]`=complete, `[~]`=skipped
- `section` is determined by heading: tasks under "## Implementation" or "## Completion"

**State Transitions**:
```
pending → in-progress    (via `run` action)
in-progress → complete   (auto on success, or manual via `complete`)
in-progress → skipped    (via `skip` action)
```

### TaskList

Collection of tasks parsed from tasks.md file.

| Field | Type | Description |
|-------|------|-------------|
| feature_name | string | Feature title from tasks.md header |
| branch | string | Git branch name |
| source | string | Content source (spec, plan, guided) |
| created_date | string | Creation date from tasks.md header |
| tasks | Task[] | Array of Task entities |

**Derived Properties**:
- `total_count`: Length of tasks array
- `completed_count`: Count where status = complete
- `pending_count`: Count where status = pending
- `in_progress_count`: Count where status = in-progress (should be 0 or 1)
- `skipped_count`: Count where status = skipped
- `completion_percentage`: (completed_count / total_count) * 100
- `current_task`: First task where status = in-progress, or first pending if none in-progress
- `next_task`: First pending task after current_task

### WorkflowState

Persisted state in `.mykit/state.json`.

| Field | Type | Description |
|-------|------|-------------|
| workflow_step | string | Current workflow phase ("implement") |
| current_task | string | Task ID currently in progress (e.g., "T005") |
| tasks_path | string | Path to tasks.md file |
| last_command | string | Last executed command ("/mykit.implement") |
| last_command_time | string | ISO 8601 timestamp of last command |

**Example**:
```json
{
  "workflow_step": "implement",
  "current_task": "T005",
  "tasks_path": "specs/012-task-execution/tasks.md",
  "last_command": "/mykit.implement",
  "last_command_time": "2025-12-09T10:30:00Z"
}
```

## File Formats

### tasks.md Structure

```markdown
# Tasks: {feature_name}

**Branch**: `{branch}` | **Created**: {date} | **Source**: {source}

## Implementation

- [ ] T001 {task description}
- [>] T002 {current task description}
- [x] T003 {completed task description}
- [~] T004 {skipped task description}

## Completion

- [ ] T0XX Run validation: `/mykit.validate`
- [ ] T0XX Create commit: `/mykit.commit create`
- [ ] T0XX Create pull request: `/mykit.pr create`
```

### Checkbox Markers

| Marker | Status | GitHub Render | Visual |
|--------|--------|---------------|--------|
| `[ ]` | pending | Unchecked | Empty box |
| `[>]` | in-progress | Unchecked | Arrow indicator |
| `[x]` | complete | Checked | Checked box |
| `[~]` | skipped | Unchecked | Strikethrough indicator |

## Parsing Logic

### Extract Tasks from tasks.md

```
1. Read file content
2. Find "## Implementation" and "## Completion" section headers
3. For each line starting with "- [":
   a. Extract checkbox marker ([ ], [>], [x], [~])
   b. Extract task ID (T###)
   c. Extract description (remainder of line)
   d. Map marker to status
   e. Determine section based on position relative to headers
4. Return TaskList with all tasks
```

### Find Current Task

```
1. Search tasks for status = in-progress
2. If found: return that task
3. If not found: return first task with status = pending
4. If no pending: return null (all complete)
```

### Update Task Status

```
1. Find task by ID
2. Get line_number from task
3. Replace checkbox marker on that line:
   - pending → in-progress: `[ ]` → `[>]`
   - in-progress → complete: `[>]` → `[x]`
   - in-progress → skipped: `[>]` → `[~]`
4. Write updated content back to file
```

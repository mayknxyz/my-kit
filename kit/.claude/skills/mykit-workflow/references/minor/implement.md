<!-- Minor mode: standard task execution with progress tracking -->

## Minor Mode Implementation

Execute implementation tasks from tasks.md one by one with autonomous execution, progress tracking, and workflow guidance.

### Step 1: Check Prerequisites

Verify we're in a git repository:

```bash
git rev-parse --git-dir 2>/dev/null
```

**If not in a git repository**, display error and stop:

```
**Error**: Not in a git repository.

Run `git init` to initialize a repository, or navigate to an existing git repository.
```

### Step 2: Parse Arguments

Parse the command arguments to determine:
- `action`: defaults to `run` (command executes directly)
- `hasForceFlag`: true if `--force` is present

Valid actions:
- `run`: Execute next/current task
- `complete`: Manually mark current task complete
- `skip`: Skip current task

**If an invalid action is provided** (not `run`, `complete`, or `skip`), display:

```
**Error**: Invalid action '{action}'.

Valid actions: run, complete, skip
Or run without an action to view the progress dashboard.
```

### Step 3: Get Current Branch and Extract Issue Number

Get the current branch name:

```bash
git rev-parse --abbrev-ref HEAD
```

Extract the issue number from the branch name using pattern `^([0-9]+)-`:
- **If branch matches pattern**: Set `isFeatureBranch = true`
- **If branch does NOT match pattern**: Set `isFeatureBranch = false`

### Step 4: Validate Feature Branch Requirement

**If `isFeatureBranch` is false**:

Display error and stop:
```
**Error**: No feature branch detected.

You must be on a feature branch (e.g., `042-feature-name`) to execute tasks.

To select an issue and create a branch: `/mykit.start`
```

### Step 5: Determine Paths

Set the following paths based on the current branch:
- `tasksPath = specs/{branch}/tasks.md`
- `statePath = .mykit/state.json`

### Step 6: Check for tasks.md

Check if tasks.md exists at `tasksPath`.

**If tasks.md does NOT exist**:

Display error and stop:
```
**Error**: No tasks file found at `{tasksPath}`.

Run `/mykit.tasks -c` to generate a task list from your spec and plan.
```

### Step 7: Parse tasks.md

Read the tasks.md file and extract all tasks with the following structure:

**For each line matching pattern** `^- \[(.)\] (T[0-9]{3}) (.+)$`:
- Extract `marker`: The character inside brackets (`[ ]`, `[>]`, `[x]`, `[~]`)
- Extract `id`: Task ID (e.g., `T001`)
- Extract `description`: The task description text
- Determine `status` from marker:
  - `[ ]` = pending
  - `[>]` = in-progress
  - `[x]` = complete
  - `[~]` = skipped
- Store `lineNumber` for later updates

### Step 8: Route Based on Action

Based on the parsed `action` from Step 2:

- **If `action` is null (no action)**: Go to Dashboard Mode
- **If `action` is "run"**: Go to Run Mode
- **If `action` is "complete"**: Go to Complete Mode
- **If `action` is "skip"**: Go to Skip Mode

---

## Dashboard Mode (No Action)

### Calculate Progress

Calculate progress metrics from the parsed tasks:
- `totalCount`: Total number of tasks
- `completedCount`: Tasks with status = complete
- `pendingCount`: Tasks with status = pending
- `inProgressCount`: Tasks with status = in-progress (should be 0 or 1)
- `skippedCount`: Tasks with status = skipped
- `completionPercentage`: (completedCount / totalCount) * 100, rounded to nearest integer

### Identify Current and Next Task

Find the current task:
1. Search for first task with status = in-progress
2. If none found, use first task with status = pending
3. If none found, `currentTask = null` (all complete)

### Display Progress Dashboard

Display the progress summary:

```
## Task Progress: {featureName}

**Progress**: {completedCount}/{totalCount} ({completionPercentage}%)
**Status**: {completedCount} complete, {pendingCount} pending, {skippedCount} skipped

{progressBar}

### Current Task
{currentTaskDisplay}

### Next Task
{nextTaskDisplay}

---

**Commands**:
- `/mykit.implement` - Execute current task
- `/mykit.implement complete` - Mark current task complete
- `/mykit.implement skip` - Skip current task
```

### Handle All Tasks Complete

**If all tasks are complete** (pendingCount = 0 AND inProgressCount = 0):

Display completion summary:

```
## All Tasks Complete!

**Progress**: {totalCount}/{totalCount} (100%)

Congratulations! You've completed all tasks for this feature.

{skippedTasksReminder}

**Next Steps**:
1. `/mykit.audit` - Run quality checks
2. `/mykit.commit` - Create a commit
3. `/mykit.pr -c` - Create a pull request
```

---

## Run Mode

### Find Next Task to Execute

1. **If any task has status = in-progress**: Use that task (resume)
2. **Else if any task has status = pending**: Use the first pending task
3. **Else** (all complete): Display completion

### Mark Task In-Progress

**If `targetTask` status is pending**:

Update tasks.md file:
- Find the line with `targetTask.id`
- Replace `- [ ]` with `- [>]`
- Write updated content back to file

Display:
```
**Starting Task**: {targetTask.id}
```

### Update state.json

Update with:
```json
{
  "workflow_step": "implement",
  "current_task": "{targetTask.id}",
  "tasks_path": "{tasksPath}",
  "last_command": "/mykit.implement",
  "last_command_time": "{ISO 8601 timestamp}"
}
```

### Execute Task Autonomously

Display the task details and then **autonomously execute the task**:

Based on the task description, determine the execution approach:

1. **If task references a command**: Execute the referenced command
2. **If task references file paths or code changes**: Read the relevant files and write/edit code
3. **If task is a documentation or research task**: Perform the research or create the documentation
4. **If task requires running tests or validation**: Execute the appropriate test commands

**Execute the task fully before proceeding.**

### Auto-Complete on Success

After successful task execution:

Update tasks.md:
- Replace `- [>]` with `- [x]`

Display:
```
**Task Complete**: {targetTask.id}
```

Show next task or completion summary.

### Handle Execution Failure

If task execution encounters an error, keep the task as in-progress and display options.

---

## Complete Mode

Find task with status = in-progress. If none found, display error.

Update tasks.md:
- Replace `- [>]` with `- [x]`

Display confirmation and show next task.

---

## Skip Mode

Find task with status = in-progress. If none found, display error.

Update tasks.md:
- Replace `- [>]` with `- [~]`

Display confirmation and show next task.

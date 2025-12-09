# /mykit.implement

Execute implementation tasks from tasks.md one by one with autonomous execution, progress tracking, and workflow guidance.

## Usage

```
/mykit.implement [run|complete|skip] [--force]
```

- No action: Display progress dashboard (read-only)
- `run`: Execute the next available task
- `complete`: Manually mark the current task as complete
- `skip`: Skip the current task and move to the next
- `--force`: Skip confirmation prompts

## Description

This command enables developers to work through tasks.md systematically. It provides autonomous task execution with Claude Code, automatic progress tracking, and guidance through the implementation, validation, commit, and PR sequence.

## Implementation

When this command is invoked, perform the following steps:

### Step 1: Check Prerequisites

First, verify we're in a git repository:

```bash
git rev-parse --git-dir 2>/dev/null
```

**If not in a git repository**, display the following message and stop:

```
**Error**: Not in a git repository.

Run `git init` to initialize a repository, or navigate to an existing git repository.
```

### Step 2: Parse Arguments

Parse the command arguments to determine:
- `action`: One of `run`, `complete`, `skip`, or `null` (no action = dashboard mode)
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
- **If branch matches pattern** (e.g., `042-feature-name`):
  - Set `isFeatureBranch = true`
- **If branch does NOT match pattern** (e.g., `main`, `develop`):
  - Set `isFeatureBranch = false`

### Step 4: Validate Feature Branch Requirement

**If `isFeatureBranch` is false**:

Display error and stop:
```
**Error**: No feature branch detected.

You must be on a feature branch (e.g., `042-feature-name`) to execute tasks.

To select an issue and create a branch: `/mykit.backlog select`
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

Run `/mykit.tasks create` to generate a task list from your spec and plan.
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

**Determine section** for each task based on position:
- Tasks under `## Implementation` or similar implementation headers = "implementation"
- Tasks under `## Completion` = "completion"

### Step 8: Detect Checkbox Markers

When reading tasks, recognize these checkbox markers:
- `- [ ]` = pending (standard markdown, not started)
- `- [>]` = in-progress (custom, currently being worked on)
- `- [x]` = complete (standard markdown, finished)
- `- [~]` = skipped (custom, intentionally bypassed)

### Step 9: Route Based on Action

Based on the parsed `action` from Step 2:

- **If `action` is null (no action)**: Go to Step 10 (Dashboard Mode)
- **If `action` is "run"**: Go to Step 14 (Run Mode)
- **If `action` is "complete"**: Go to Step 22 (Complete Mode)
- **If `action` is "skip"**: Go to Step 29 (Skip Mode)

---

## Dashboard Mode (No Action) - User Story 3

### Step 10: Calculate Progress

Calculate progress metrics from the parsed tasks:
- `totalCount`: Total number of tasks
- `completedCount`: Tasks with status = complete
- `pendingCount`: Tasks with status = pending
- `inProgressCount`: Tasks with status = in-progress (should be 0 or 1)
- `skippedCount`: Tasks with status = skipped
- `completionPercentage`: (completedCount / totalCount) * 100, rounded to nearest integer

### Step 11: Identify Current and Next Task

Find the current task:
1. Search for first task with status = in-progress
2. If none found, use first task with status = pending
3. If none found, `currentTask = null` (all complete)

Find the next task:
1. If currentTask exists, find first pending task after currentTask
2. If currentTask is null, `nextTask = null`

### Step 12: Display Progress Dashboard

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
- `/mykit.implement run` - Execute current task
- `/mykit.implement complete` - Mark current task complete
- `/mykit.implement skip` - Skip current task
```

Where:
- `progressBar` = Visual progress bar using filled/empty blocks (e.g., `[##########----------]`)
- `currentTaskDisplay` = `**{id}**: {description}` or "No task in progress"
- `nextTaskDisplay` = `**{id}**: {description}` or "No more tasks pending"

### Step 13: Handle All Tasks Complete

**If all tasks are complete** (pendingCount = 0 AND inProgressCount = 0):

Display completion summary:

```
## All Tasks Complete!

**Progress**: {totalCount}/{totalCount} (100%)

Congratulations! You've completed all tasks for this feature.

{skippedTasksReminder}

**Next Step**: Run `/mykit.pr create` to create a pull request.
```

Where `skippedTasksReminder`:
- If skippedCount > 0: "**Note**: {skippedCount} task(s) were skipped. Consider reviewing before creating the PR."
- If skippedCount = 0: (omit this line)

**Stop execution here for Dashboard Mode.**

---

## Run Mode - User Story 1

### Step 14: Detect Run Action

Verify `action` = "run".

### Step 15: Find Next Task to Execute

Find the task to execute:
1. **If any task has status = in-progress**: Use that task (resume)
2. **Else if any task has status = pending**: Use the first pending task
3. **Else** (all complete): Go to Step 13 (display completion)

Store the found task as `targetTask`.

### Step 16: Mark Task In-Progress

**If `targetTask` status is pending** (not already in-progress):

Update tasks.md file:
- Find the line with `targetTask.id`
- Replace `- [ ]` with `- [>]`
- Write updated content back to file

Display:
```
**Starting Task**: {targetTask.id}
```

### Step 17: Update state.json

Read current `.mykit/state.json` (or create empty object if not exists).

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

Write updated state back to file.

### Step 18: Execute Task Autonomously

Display the task details:

```
---
## Executing Task: {targetTask.id}

**Description**: {targetTask.description}

---
```

**NOW AUTONOMOUSLY EXECUTE THE TASK:**

Based on the task description, determine the execution approach:

1. **If task references a command** (contains `/mykit.` or shell command):
   - Execute the referenced command
   - Example: "Run validation: `/mykit.validate`" -> Execute /mykit.validate

2. **If task references file paths or code changes**:
   - Read the relevant files for context
   - Write or edit code as needed
   - Example: "Implement Step 1: Git repository check" -> Write the code

3. **If task is a documentation or research task**:
   - Perform the research or create the documentation
   - Example: "Add Error Handling section" -> Write the documentation

4. **If task requires running tests or validation**:
   - Execute the appropriate test commands
   - Report results

**Execute the task fully before proceeding.**

### Step 19: Auto-Complete on Success

After successful task execution:

Update tasks.md file:
- Find the line with `targetTask.id`
- Replace `- [>]` with `- [x]`
- Write updated content back to file

Update state.json:
- Set `current_task` to the next pending task ID (or null if none)

Display:
```
**Task Complete**: {targetTask.id}
```

### Step 20: Show Next Task or Completion

After completing the task:

**If there are more pending tasks**:

Find the next pending task and display:
```
### Next Task Available

**{nextTask.id}**: {nextTask.description}

Run `/mykit.implement run` to continue.
```

**If entering completion phase** (last implementation task just completed):
```
### Implementation Complete!

All implementation tasks are done. Completion tasks remain:
- Validation
- Commit
- Pull Request

Run `/mykit.implement run` to continue with completion tasks.
```

**If all tasks complete**:

Go to Step 13 (display completion summary).

### Step 21: Handle Execution Failure

If task execution encounters an error:

Keep the task as in-progress (do NOT change checkbox marker).

Display:
```
**Task Execution Failed**: {targetTask.id}

**Error**: {error description}

**Options**:
- Fix the issue manually, then run `/mykit.implement complete`
- Skip this task with `/mykit.implement skip`
- Retry with `/mykit.implement run`
```

**Stop execution here for Run Mode.**

---

## Complete Mode - User Story 2

### Step 22: Detect Complete Action

Verify `action` = "complete".

### Step 23: Validate In-Progress Task Exists

Find task with status = in-progress.

**If no in-progress task found**:

Display error and stop:
```
**Error**: No task currently in progress.

Run `/mykit.implement run` to start the next task, or view progress with `/mykit.implement`.
```

### Step 24: Mark Task Complete

Update tasks.md file:
- Find the line with the in-progress task
- Replace `- [>]` with `- [x]`
- Write updated content back to file

Store the completed task as `completedTask`.

### Step 25: Update state.json After Completion

Update `.mykit/state.json`:
- Set `current_task` to next pending task ID, or null if none
- Update `last_command` and `last_command_time`

### Step 26: Display Completion Confirmation

Display:
```
**Task Complete**: {completedTask.id}

{completedTask.description}
```

### Step 27: Show Next Task or Phase Transition

Find the next pending task.

**If more pending tasks exist**:
```
### Next Task

**{nextTask.id}**: {nextTask.description}

Run `/mykit.implement run` to execute.
```

**If entering completion phase** (all implementation tasks done, completion tasks remain):
```
### Implementation Phase Complete!

All implementation tasks are done. Time to wrap up:

**Remaining Completion Tasks**:
{list of remaining completion tasks}

Run `/mykit.implement run` to continue.
```

### Step 28: Handle Final Completion

**If all tasks (including completion) are complete**:

Display celebration:
```
## Congratulations!

All tasks complete for this feature!

**Summary**:
- Implementation tasks: {implementationCount} complete
- Completion tasks: {completionCount} complete
- Skipped: {skippedCount}

{skippedReminder}

**Ready to ship!** Your pull request should be created. Review and merge when ready.
```

Where `skippedReminder`:
- If skippedCount > 0: "**Reminder**: {skippedCount} task(s) were skipped. Consider reviewing them before merging."
- If skippedCount = 0: (omit)

**Stop execution here for Complete Mode.**

---

## Skip Mode - User Story 4

### Step 29: Detect Skip Action

Verify `action` = "skip".

### Step 30: Validate In-Progress Task Exists

Find task with status = in-progress.

**If no in-progress task found**:

Display error and stop:
```
**Error**: No task currently in progress.

Run `/mykit.implement run` to start the next task, or view progress with `/mykit.implement`.
```

### Step 31: Mark Task Skipped

Update tasks.md file:
- Find the line with the in-progress task
- Replace `- [>]` with `- [~]`
- Write updated content back to file

Store the skipped task as `skippedTask`.

### Step 32: Update state.json After Skip

Update `.mykit/state.json`:
- Set `current_task` to next pending task ID, or null if none
- Update `last_command` and `last_command_time`

### Step 33: Display Skip Confirmation and Next Task

Display:
```
**Task Skipped**: {skippedTask.id}

{skippedTask.description}
```

Find the next pending task.

**If more pending tasks exist**:
```
### Next Task

**{nextTask.id}**: {nextTask.description}

Run `/mykit.implement run` to execute.
```

**If no more pending tasks**:
```
### No More Pending Tasks

All remaining tasks have been completed or skipped.
```

### Step 34: Remind About Skipped Tasks on Completion

**If all non-skipped tasks are complete AND skippedCount > 0**:

Display:
```
**Reminder**: You have {skippedCount} skipped task(s):

{list of skipped tasks with IDs and descriptions}

Consider completing these before creating your PR, or proceed if they're no longer needed.

Run `/mykit.implement` to view the full progress dashboard.
```

**Stop execution here for Skip Mode.**

---

## Error Handling

| Error | Message |
|-------|---------|
| Not a git repository | "Not in a git repository. Run `git init` to initialize." |
| Not on feature branch | "No feature branch detected. Use `/mykit.backlog select` first." |
| No tasks.md found | "No tasks file found at `{path}`. Run `/mykit.tasks create` first." |
| Invalid action | "Invalid action '{action}'. Valid actions: run, complete, skip" |
| No in-progress task (for complete/skip) | "No task currently in progress. Run `/mykit.implement run` to start." |
| Invalid tasks.md format | "Unable to parse tasks.md. Check the file format and try again." |
| File write failed | "Error: Unable to update {file}. Check permissions." |

## Example Outputs

### Dashboard Mode (Progress View)

```
/mykit.implement

## Task Progress: User Authentication

**Progress**: 5/10 (50%)
**Status**: 5 complete, 4 pending, 1 skipped

[##########----------]

### Current Task
**T006**: Add authentication middleware

### Next Task
**T007**: Implement logout functionality

---

**Commands**:
- `/mykit.implement run` - Execute current task
- `/mykit.implement complete` - Mark current task complete
- `/mykit.implement skip` - Skip current task
```

### Run Mode (Task Execution)

```
/mykit.implement run

**Starting Task**: T006

---
## Executing Task: T006

**Description**: Add authentication middleware

---

[Claude Code autonomously implements the middleware...]

**Task Complete**: T006

### Next Task Available

**T007**: Implement logout functionality

Run `/mykit.implement run` to continue.
```

### Complete Mode (Manual Completion)

```
/mykit.implement complete

**Task Complete**: T006

Add authentication middleware

### Next Task

**T007**: Implement logout functionality

Run `/mykit.implement run` to execute.
```

### Skip Mode

```
/mykit.implement skip

**Task Skipped**: T003

Implement password reset flow

### Next Task

**T004**: Add email verification

Run `/mykit.implement run` to execute.
```

### All Tasks Complete

```
/mykit.implement

## All Tasks Complete!

**Progress**: 10/10 (100%)

Congratulations! You've completed all tasks for this feature.

**Note**: 1 task(s) were skipped. Consider reviewing before creating the PR.

**Next Step**: Run `/mykit.pr create` to create a pull request.
```

## Related Commands

| Command | Relationship |
|---------|--------------|
| `/mykit.tasks` | Generate tasks before running this command |
| `/mykit.status` | View overall workflow status |
| `/mykit.validate` | Validation step in completion phase |
| `/mykit.commit` | Commit step in completion phase |
| `/mykit.pr` | Create PR after all tasks complete |
| `/mykit.resume` | Resume interrupted session |

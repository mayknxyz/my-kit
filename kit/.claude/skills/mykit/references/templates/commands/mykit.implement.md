# /mykit.implement

Execute implementation tasks from tasks.md one by one with autonomous execution, progress tracking, and workflow guidance.

## Usage

```
/mykit.implement
```

- Executes the next available task autonomously

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

### Step 2: Get Current Branch and Extract Issue Number

Get the current branch name:

```bash
git rev-parse --abbrev-ref HEAD
```

Extract the issue number from the branch name using pattern `^([0-9]+)-`:
- **If branch matches pattern** (e.g., `042-feature-name`):
  - Set `isFeatureBranch = true`
- **If branch does NOT match pattern** (e.g., `main`, `develop`):
  - Set `isFeatureBranch = false`

### Step 3: Validate Feature Branch Requirement

**If `isFeatureBranch` is false**:

Display error and stop:
```
**Error**: No feature branch detected.

You must be on a feature branch (e.g., `042-feature-name`) to execute tasks.

To select an issue and create a branch: `/mykit.specify`
```

### Step 4: Determine Paths

Set the following paths based on the current branch:
- `tasksPath = specs/{branch}/tasks.md`

### Step 5: Check for tasks.md

Check if tasks.md exists at `tasksPath`.

**If tasks.md does NOT exist**:

Display error and stop:
```
**Error**: No tasks file found at `{tasksPath}`.

Run `/mykit.tasks` to generate a task list from your spec and plan.
```

### Step 6: Parse tasks.md

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

### Step 7: Detect Checkbox Markers

When reading tasks, recognize these checkbox markers:
- `- [ ]` = pending (standard markdown, not started)
- `- [>]` = in-progress (custom, currently being worked on)
- `- [x]` = complete (standard markdown, finished)
- `- [~]` = skipped (custom, intentionally bypassed)

### Step 8: Calculate Progress

Calculate progress metrics from the parsed tasks:
- `totalCount`: Total number of tasks
- `completedCount`: Tasks with status = complete
- `pendingCount`: Tasks with status = pending
- `inProgressCount`: Tasks with status = in-progress (should be 0 or 1)
- `skippedCount`: Tasks with status = skipped
- `completionPercentage`: (completedCount / totalCount) * 100, rounded to nearest integer

### Step 9: Handle All Tasks Complete

**If all tasks are complete** (pendingCount = 0 AND inProgressCount = 0):

Display completion summary:

```
## All Tasks Complete!

**Progress**: {totalCount}/{totalCount} (100%)

Congratulations! You've completed all tasks for this feature.

{skippedTasksReminder}

**Next Step**: Run `/mykit.pr` to create a pull request.
```

Where `skippedTasksReminder`:
- If skippedCount > 0: "**Note**: {skippedCount} task(s) were skipped. Consider reviewing before creating the PR."
- If skippedCount = 0: (omit this line)

**Stop execution here if all tasks complete.**

---

## Execute Mode

### Step 10: Find Next Task to Execute

Find the task to execute:
1. **If any task has status = in-progress**: Use that task (resume)
2. **Else if any task has status = pending**: Use the first pending task
3. **Else** (all complete): Go to Step 9 (display completion)

Store the found task as `targetTask`.

### Step 11: Mark Task In-Progress

**If `targetTask` status is pending** (not already in-progress):

Update tasks.md file:
- Find the line with `targetTask.id`
- Replace `- [ ]` with `- [>]`
- Write updated content back to file

Display:
```
**Starting Task**: {targetTask.id}
```

### Step 12: Execute Task Autonomously

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
   - Example: "Run validation: `/mykit.audit`" -> Execute /mykit.audit

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

### Step 13: Auto-Complete on Success

After successful task execution:

Update tasks.md file:
- Find the line with `targetTask.id`
- Replace `- [>]` with `- [x]`
- Write updated content back to file

Display:
```
**Task Complete**: {targetTask.id}
```

### Step 14: Show Next Task or Completion

After completing the task:

**If there are more pending tasks**:

Find the next pending task and display:
```
### Next Task Available

**{nextTask.id}**: {nextTask.description}

Run `/mykit.implement` to continue.
```

**If entering completion phase** (last implementation task just completed):
```
### Implementation Complete!

All implementation tasks are done. Completion tasks remain:
- Validation
- Commit
- Pull Request

Run `/mykit.implement` to continue with completion tasks.
```

**If all tasks complete**:

Go to Step 9 (display completion summary).

### Step 15: Handle Execution Failure

If task execution encounters an error:

Keep the task as in-progress (do NOT change checkbox marker).

Display:
```
**Task Execution Failed**: {targetTask.id}

**Error**: {error description}

**Options**:
- Fix the issue manually, then run `/mykit.implement`
- Retry with `/mykit.implement`
```

**Stop execution here.**

---

## Error Handling

| Error | Message |
|-------|---------|
| Not a git repository | "Not in a git repository. Run `git init` to initialize." |
| Not on feature branch | "No feature branch detected. Use `/mykit.specify` first." |
| No tasks.md found | "No tasks file found at `{path}`. Run `/mykit.tasks` first." |
| Invalid tasks.md format | "Unable to parse tasks.md. Check the file format and try again." |
| File write failed | "Error: Unable to update {file}. Check permissions." |

## Example Outputs

### Task Execution

```
/mykit.implement

**Starting Task**: T006

---
## Executing Task: T006

**Description**: Add authentication middleware

---

[Claude Code autonomously implements the middleware...]

**Task Complete**: T006

### Next Task Available

**T007**: Implement logout functionality

Run `/mykit.implement` to continue.
```

### All Tasks Complete

```
/mykit.implement

## All Tasks Complete!

**Progress**: 10/10 (100%)

Congratulations! You've completed all tasks for this feature.

**Note**: 1 task(s) were skipped. Consider reviewing before creating the PR.

**Next Step**: Run `/mykit.pr` to create a pull request.
```

## Related Commands

| Command | Relationship |
|---------|------------|
| `/mykit.tasks` | Generate tasks before running this command |
| `/mykit.status` | View overall workflow status |
| `/mykit.audit` | Validation step in completion phase |
| `/mykit.commit` | Commit step in completion phase |
| `/mykit.pr` | Create PR after all tasks complete |

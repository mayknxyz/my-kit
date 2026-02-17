<!-- Task execution with progress tracking -->

## Implementation

Execute implementation tasks from tasks.md one by one with autonomous execution, progress tracking, and workflow guidance.

### Step 1: Check Prerequisite

```bash
source $HOME/.claude/skills/mykit/references/scripts/fetch-branch-info.sh
```

Check if tasks.md exists at `TASKS_PATH`. **If not**, display error and stop:

```
**Error**: No tasks file found at `{TASKS_PATH}`.

Run `/mykit.tasks` first.
```

### Step 2: Load Skills

Read the `## Skills` section from tasks.md. For each listed skill, load it so it is active during implementation.

### Step 3: Parse tasks.md

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

### Step 4: Find Next Task to Execute

1. **If any task has status = in-progress**: Use that task (resume)
2. **Else if any task has status = pending**: Use the first pending task
3. **Else** (all complete/skipped): Update tasks.md **Status** field from `Pending` to `Complete`. Display completion and stop:

   ```
   All tasks complete!

   Next steps: `/mykit.audit.all` (optional) → `/mykit.commit` → `/mykit.pr`
   ```

### Step 5: Mark Task In-Progress

Update tasks.md: replace `- [ ]` with `- [>]` for the target task.

Display:

```
**Starting Task**: {targetTask.id} — {targetTask.description}
```

### Step 6: Execute Task Autonomously

Based on the task description, determine the execution approach:

1. **If task references a command**: Execute the referenced command
2. **If task references file paths or code changes**: Read the relevant files and write/edit code
3. **If task is a documentation or research task**: Perform the research or create the documentation
4. **If task requires running tests or validation**: Execute the appropriate test commands

Read-only operations (reading files, searching code, checking status) do not require user permission — proceed without asking. Only prompt for confirmation on destructive or irreversible actions.

**Execute the task fully before proceeding.**

### Step 7: Update Task Status

**On success**: Update tasks.md — replace `- [>]` with `- [x]`. Display:

```
**Task Complete**: {targetTask.id}
```

**On failure**: Keep task as `[>]` (in-progress). Display the error and stop.

After completing a task, loop back to Step 4 to pick up the next task. Continue until all tasks are complete or a failure occurs.

### Scope Expansion

If the user requests additional work after all tasks are complete (or while implementing), and the work is related to the current branch/feature:

1. **Reopen tasks.md** — Change `**Status**: Complete` back to `**Status**: Pending` (or keep as `Pending` if not yet complete)
2. **Append new tasks** — Add new `- [ ] T0XX` entries after the last task, continuing the numbering sequence
3. **Resume the loop** — Go back to Step 4 to execute the new tasks
4. **Update plan.md** — After all new tasks are done, update the plan and spec files to reflect the expanded scope

This avoids needing to manually edit tasks.md outside the workflow.

---
description: Convert existing tasks into actionable, dependency-ordered GitHub issues for the feature based on available design artifacts.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Usage

```
/mykit.taskstoissues [--force]
```

- Executes directly: Create GitHub issues from tasks
- `--force`: Skip confirmation prompts

## Parse Arguments

Parse the command arguments to determine:
- `hasRunAction`: true if `run` is present
- `hasForceFlag`: true if `--force` is present

## Step 1: Check Prerequisites

Run `$HOME/.claude/skills/mykit/references/scripts/check-prerequisites.sh --json --require-tasks --include-tasks` from repo root and parse the JSON output for `FEATURE_DIR` and `AVAILABLE_DOCS`.

All paths must be absolute. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

Derive paths:
- `TASKS = FEATURE_DIR/tasks.md`
- `SPEC = FEATURE_DIR/spec.md` (if available)

Extract the **feature issue number** from the current branch name using pattern `^([0-9]+)-`. This is the parent feature issue.

If the prerequisite check fails, display the error and stop.

## Step 2: Validate GitHub Remote

Run the GitHub remote validation helper:

```bash
source $HOME/.claude/skills/mykit/references/scripts/utils.sh && validate_github_remote
```

Parse the JSON output. If `valid` is `false`:

```
**Error**: {error message}

The Git remote must be a GitHub URL to create issues.
Current remote: {remote_url}
```

**Stop execution.** UNDER NO CIRCUMSTANCES EVER CREATE ISSUES IN REPOSITORIES THAT DO NOT MATCH THE REMOTE URL.

Extract `OWNER` and `REPO` from the validation result. Set `OWNER_REPO = OWNER/REPO`.

## Step 3: Parse Tasks

Run the enriched task parser:

```bash
source $HOME/.claude/skills/mykit/references/scripts/utils.sh && parse_tasks_file "TASKS_PATH" true
```

Parse the JSON output into a task list. For each task, extract:
- `id`: Task ID (T001, T002, etc.)
- `status`: pending, in-progress, complete, skipped
- `description`: Task description text
- `phase`: Phase name (e.g., "Implementation", "Completion", "Setup")
- `phase_num`: Phase number (if present)
- `parallel`: Whether task is parallelizable
- `story`: User story reference (e.g., "US1")
- `priority`: Priority level (e.g., "P1")
- `dependencies`: Array of task IDs this task depends on

**Malformed task handling**: If `parse_tasks_file` returns tasks with empty `id` or `description`, warn about each malformed entry and exclude it from processing. Continue with valid tasks.

If zero valid tasks are found:

```
**Error**: No valid tasks found in tasks.md.

Check the file format. Tasks should follow: `- [ ] T### Description`
```

## Step 4: Check for Duplicates

Run duplicate detection:

```bash
source $HOME/.claude/skills/mykit/references/scripts/utils.sh && find_existing_task_issues "OWNER_REPO" "T001 T002 T003 ..."
```

Pass all task IDs as a space-separated list. Parse the JSON result — it maps task IDs to existing issue numbers (e.g., `{"T001":123,"T003":456}`).

Mark any task with an existing issue as `skipped` (for this run) and record the existing issue number.

## Step 5: Determine Creation Order

Run topological sort on the enriched task JSON:

```bash
source $HOME/.claude/skills/mykit/references/scripts/utils.sh && toposort_tasks 'ENRICHED_JSON'
```

The output is a space-separated list of task IDs in dependency-respecting order. Use this order for issue creation.

## Step 6: Prepare Issue Content

For each task (in topological order), prepare the issue content:

### Issue Title

Format: `[TASK_ID] DESCRIPTION`

Example: `[T001] Extend parse_tasks_file() to extract dependency references`

### Issue Body

Format the issue body as follows:

```markdown
## Task Details

**Task ID**: {TASK_ID}
**Phase**: {phase name}
**Priority**: {priority or "—"}
**Parallel**: {Yes/No}
**Feature**: #{parent_feature_issue_number}

## Description

{task description}

## Dependencies

{If task has dependencies AND those dependencies have been created as issues:
  - "Blocked by #ISSUE_NUMBER (TASK_ID)" for each dependency
If task has dependencies but issues haven't been created yet:
  - "Depends on TASK_ID" for each dependency
If no dependencies:
  - "None"}

---
*Created by `/mykit.taskstoissues` from `tasks.md`*
```

### Labels

Derive labels from task metadata:
- If `phase` is set: add label `phase:{phase_name_slug}` (lowercase, spaces to hyphens)
- If `priority` is set: add label `priority:{priority}` (e.g., `priority:P1`)
- Always add label `task` to distinguish from manually-created issues

Before assigning labels, check if they exist:

```bash
gh label list --repo OWNER_REPO --json name --jq '.[].name'
```

For any label that doesn't exist, create it:

```bash
gh label create "LABEL_NAME" --repo OWNER_REPO --description "DESCRIPTION" --color "COLOR"
```

Use these colors:
- `phase:*` labels: `0E8A16` (green)
- `priority:P1`: `B60205` (red)
- `priority:P2`: `FBCA04` (yellow)
- `priority:P3`: `0075CA` (blue)
- `task`: `5319E7` (purple)

### Milestone

If user provided a milestone name in the arguments, or if a milestone matching the feature branch name or issue title exists, assign it. Otherwise skip milestone assignment (do not create milestones automatically).

## Step 7: Preview or Execute

### Preview Mode (no `run` action)

Display a table of what would be created:

```markdown
## Preview: Tasks to GitHub Issues

**Repository**: {OWNER_REPO}
**Feature**: #{parent_feature_issue_number}
**Tasks File**: {TASKS path}

| # | Task ID | Title | Labels | Dependencies | Status |
|---|---------|-------|--------|--------------|--------|
| 1 | T001 | [T001] Description... | task, phase:setup | None | Will create |
| 2 | T002 | [T002] Description... | task, phase:setup | T001 | Will create |
| 3 | T003 | [T003] Description... | task, phase:core | T001 | Already exists (#123) |

**Summary**:
- To create: {count}
- Already exist (skip): {count}
- Total tasks: {count}

To create these issues, run: `/mykit.taskstoissues run`
```

**Stop execution here for Preview Mode.**

### Execute Mode (`run` action)

Display:
```
## Creating GitHub Issues

**Repository**: {OWNER_REPO}
**Feature**: #{parent_feature_issue_number}
```

**CRITICAL**: Maintain a mapping of `task_id -> created_issue_number` as issues are created. This mapping is needed to resolve dependency cross-references for later issues.

For each task in topological order:

1. **If task was marked as duplicate (already exists)**: Skip and log:
   ```
   - **{TASK_ID}**: Skipped (already exists as #{existing_issue_number})
   ```

2. **If task is new**: Create the issue:

   Resolve dependency cross-references: For each dependency in the task, look up the `task_id -> issue_number` mapping to replace task IDs with actual issue numbers in the body.

   Create the issue using `gh`:
   ```bash
   gh issue create --repo OWNER_REPO --title "TITLE" --body "BODY" --label "label1,label2"
   ```

   Parse the created issue URL/number from the output.

   Add to the `task_id -> issue_number` mapping.

   Log:
   ```
   - **{TASK_ID}**: Created #{new_issue_number}
   ```

3. **If creation fails**: Log the error and continue with next task:
   ```
   - **{TASK_ID}**: Failed — {error message}
   ```

## Step 8: Execution Summary

After all tasks are processed, display:

```markdown
## Execution Summary

| Status | Count |
|--------|-------|
| Created | {created_count} |
| Skipped (duplicate) | {skipped_count} |
| Failed | {failed_count} |
| **Total** | **{total_count}** |

{If created_count > 0:}
### Created Issues

| Task ID | Issue | Title |
|---------|-------|-------|
| T001 | #{number} | [T001] Description |
| T002 | #{number} | [T002] Description |

{If failed_count > 0:}
### Failed Issues

| Task ID | Error |
|---------|-------|
| T005 | API rate limit exceeded |

{If skipped_count > 0:}
### Skipped (Already Exist)

| Task ID | Existing Issue |
|---------|---------------|
| T003 | #{number} |
```

## Error Handling

| Error | Message |
|-------|---------|
| Prerequisites fail | Display check-prerequisites.sh error and stop |
| Not a GitHub remote | "The Git remote must be a GitHub URL to create issues." |
| No valid tasks | "No valid tasks found in tasks.md. Check the file format." |
| gh CLI not available | "GitHub CLI (gh) is required. Install from https://cli.github.com/" |
| API rate limit | Log failed task, continue with remaining tasks |
| Label creation fails | Warn and create issue without that label |

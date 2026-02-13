# /mykit.resume

Resume a previous workflow session by displaying saved state and suggesting the next command.

## Usage

```
/mykit.resume
```

No arguments required. This is a read-only command that executes immediately.

## Description

This command reads the saved session state from `.mykit/state.json` and displays relevant context to help you quickly resume work after an interruption. It validates the state, checks for potential issues, and suggests the most appropriate next command.

## Implementation

When this command is invoked, execute the following steps in order:

### Helper Functions

**Project ID Generation**:
```bash
# Generate project identifier from git remote URL
# Uses first 8 characters of SHA-256 hash
git remote get-url origin 2>/dev/null | shasum -a 256 | cut -c1-8
```

**Fallback** (no remote):
```bash
# Use absolute path of .git directory if no remote exists
git rev-parse --absolute-git-dir 2>/dev/null | shasum -a 256 | cut -c1-8
```

**Timestamp Parsing**:
Parse ISO-8601 timestamps and calculate relative time:
- If < 1 hour ago → "X minutes ago"
- If < 24 hours ago → "X hours ago"
- If < 7 days ago → "X days ago"
- If >= 7 days ago → "X days ago" (triggers staleness warning)

### Step 1: Check for State File

Check if `.mykit/state.json` exists:

```bash
test -f .mykit/state.json && echo "EXISTS" || echo "MISSING"
```

**If file is MISSING**, display the following and stop:

```markdown
# Resume Session

No saved session state found.

To start a new session, run:
- `/mykit.start` - Begin a new workflow session
- `/mykit.status` - View current project status
```

### Step 2: Read and Parse State File

Read the contents of `.mykit/state.json`:

```bash
cat .mykit/state.json
```

Attempt to parse as JSON.

**If JSON parsing fails**, display the following and stop:

```markdown
# Resume Session

**Error**: Unable to read session state. The file may be corrupted.

To start fresh:
1. Delete `.mykit/state.json`
2. Run `/mykit.start` to begin a new session
```

### Step 3: Validate JSON Schema

The state file should contain:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| version | string | Yes | Schema version (should be "1") |
| projectId | string | Yes | 8-character hash identifying the project |
| branch | string | Yes | Branch name when state was saved |
| lastCommand | string | Yes | Last mykit command executed |
| timestamp | string | Yes | ISO-8601 timestamp |
| workflowStage | enum | Yes | specify, clarify, plan, tasks, implement, complete |
| sessionType | enum | Yes | major, minor, patch |
| notes | string | No | Optional user notes |

**Validation behavior**:
- If `version` is not "1" → Display warning, continue with caution
- If required fields are missing → Display error, suggest starting fresh
- If `workflowStage` is invalid → Default to "specify" with warning
- If `sessionType` is invalid → Default to "major" with warning
- If `timestamp` is invalid → Display "unknown" for time, continue

### Step 4: Generate Current Project Identifier

Generate the current project's identifier to compare with saved state:

```bash
# Try git remote first
PROJECT_ID=$(git remote get-url origin 2>/dev/null | shasum -a 256 | cut -c1-8)

# Fallback to git directory path
if [ -z "$PROJECT_ID" ]; then
  PROJECT_ID=$(git rev-parse --absolute-git-dir 2>/dev/null | shasum -a 256 | cut -c1-8)
fi
```

**If saved `projectId` does not match current**:
- Add warning: "Project Mismatch: State was saved for a different project."
- Continue displaying state with warning

### Step 5: Detect Current Workflow Stage from Files

Check for spec files in `specs/{savedBranch}/` directory to verify current state:

```bash
# Check spec files existence
test -f "specs/{branch}/spec.md" && echo "SPEC_EXISTS"
test -f "specs/{branch}/plan.md" && echo "PLAN_EXISTS"
test -f "specs/{branch}/tasks.md" && echo "TASKS_EXISTS"
```

**Detection logic** (to compare with saved stage):
```
if tasks.md exists:
  if has incomplete tasks (lines matching "- [ ]") → stage = "implement"
  else (all tasks complete) → stage = "complete"
else if plan.md exists → stage = "tasks"
else if spec.md exists → stage = "plan" or "clarify"
else → stage = "specify"
```

Use the saved `workflowStage` for display, but note discrepancies if detected stage differs significantly.

### Step 6: Check for Uncommitted Changes

Check current git status:

```bash
git status --porcelain
```

- If output is empty → `hasUncommittedChanges = false`
- If output has content → `hasUncommittedChanges = true`

This affects the suggested next command.

### Step 7: Generate Next Command Suggestion

Based on workflow stage and uncommitted changes, determine the suggested command:

| Workflow Stage | Has Uncommitted Changes | Suggested Command | Reason |
|---------------|------------------------|-------------------|--------|
| specify | No | `/mykit.specify` | Create or continue specification |
| specify | Yes | `/mykit.commit` | Commit your specification changes |
| clarify | No | `/mykit.clarify` | Continue clarification |
| clarify | Yes | `/mykit.commit` | Commit your clarification changes |
| plan | No | `/mykit.plan` | Continue planning |
| plan | Yes | `/mykit.commit` | Commit your planning changes |
| tasks | No | `/mykit.tasks` | Generate implementation tasks |
| tasks | Yes | `/mykit.commit` | Commit your task changes |
| implement | No | Continue implementation or `/mykit.pr -c` | Continue coding or create PR |
| implement | Yes | `/mykit.commit` | Commit your implementation changes |
| complete | Any | `/mykit.pr -c` | All tasks done, create pull request |

**Special case**: If warnings exist (stale state, branch mismatch, project mismatch):
- Suggest `/mykit.status` first to verify current state

### Step 8: Check Staleness

Calculate time difference between saved `timestamp` and current time:

```bash
# Get saved timestamp in seconds since epoch
# Get current timestamp in seconds since epoch
# Calculate difference in days
```

**If difference > 7 days**:
- Add warning: "Stale State: Last saved X days ago. State may be outdated."

### Step 9: Check Branch Validity

Verify the saved branch still exists:

```bash
git branch --list "{savedBranch}"
```

**If branch does not exist**:
- Add warning: "Missing Branch: Branch `{savedBranch}` no longer exists."

Check current branch vs saved branch:

```bash
git rev-parse --abbrev-ref HEAD
```

**If current branch differs from saved branch**:
- Add warning: "Branch Mismatch: Currently on `{currentBranch}`, state saved on `{savedBranch}`."

### Step 10: Format and Display Output

Display the complete resume session card:

---

**Standard output (with valid state)**:

```markdown
# Resume Session

## Last Session
**Branch**: {branch}
**Saved**: {timestamp} ({relativeTime})
**Stage**: {workflowStage}
**Type**: {sessionType}
**Last Command**: {lastCommand}

{if notes exist}
**Notes**: {notes}
{end if}

## Suggested Next Step
`{suggestedCommand}` - {reason}
```

**Output with warnings**:

```markdown
# Resume Session

## Last Session
**Branch**: {branch}
**Saved**: {timestamp} ({relativeTime})
**Stage**: {workflowStage}
**Type**: {sessionType}
**Last Command**: {lastCommand}

## Warnings
{for each warning}
- {warningIcon} **{warningType}**: {warningMessage}
{end for}

## Suggested Next Step
`{suggestedCommand}` - {reason}
```

---

## Error Handling

| Error | Message |
|-------|---------|
| State file missing | "No saved session state found." + guidance to start fresh |
| Invalid JSON | "Unable to read session state. The file may be corrupted." + recovery steps |
| Schema version mismatch | Warning: "State version mismatch. Some fields may not display correctly." |
| Project ID mismatch | Warning: "State was saved for a different project." |
| Stale timestamp (>7 days) | Warning: "Last saved X days ago. State may be outdated." |
| Branch missing | Warning: "Branch `{branch}` no longer exists." |
| Branch mismatch | Warning: "Currently on `{current}`, state saved on `{saved}`." |

## Example Output

### With Valid State

```markdown
# Resume Session

## Last Session
**Branch**: 007-resume-session
**Saved**: 2025-12-06T14:30:00Z (2 hours ago)
**Stage**: Planning
**Type**: Major workflow
**Last Command**: /mykit.plan

## Suggested Next Step
`/mykit.tasks` - Generate implementation tasks
```

### With Warnings

```markdown
# Resume Session

## Last Session
**Branch**: 005-old-feature
**Saved**: 2025-11-25T10:00:00Z (11 days ago)
**Stage**: Implementation
**Type**: Major workflow
**Last Command**: /mykit.implement

## Warnings
- **Stale State**: Last saved 11 days ago. State may be outdated.
- **Branch Mismatch**: Currently on `main`, state saved on `005-old-feature`.

## Suggested Next Step
`/mykit.status` - Check current project status before proceeding
```

### Without State

```markdown
# Resume Session

No saved session state found.

To start a new session, run:
- `/mykit.start` - Begin a new workflow session
- `/mykit.status` - View current project status
```

### With Corrupted State

```markdown
# Resume Session

**Error**: Unable to read session state. The file may be corrupted.

To start fresh:
1. Delete `.mykit/state.json`
2. Run `/mykit.start` to begin a new session
```

## Related Commands

| Command | Relationship |
|---------|--------------|
| `/mykit.start` | Creates/updates session state |
| `/mykit.status` | Shows current workflow status (complementary view) |
| `/mykit.help` | Get help with My Kit commands |
| `/mykit.commit` | Updates lastCommand and timestamp in state |

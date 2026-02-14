# /mykit.status

Display current workflow status including feature context, workflow phase, file status, and suggested next command.

## Usage

```
/mykit.status
```

No arguments required. This is a read-only command that executes immediately.

## Implementation

When this command is invoked, execute the following steps in order:

### Step 1: Check Git Repository

First, verify we're in a git repository:

```bash
git rev-parse --git-dir 2>/dev/null
```

**If not in a git repository**, display the following message and stop:

```
# My Kit Status

**Error**: Not in a git repository.

Run `git init` to initialize a repository, or navigate to an existing git repository.
```

### Step 2: Load Branch Context

```bash
source $HOME/.claude/skills/mykit/references/scripts/fetch-branch-info.sh
```

Sets `BRANCH`, `ISSUE_NUMBER`, `SPEC_PATH`, `PLAN_PATH`, `TASKS_PATH`.

**Handle edge cases**:

- **If `BRANCH` is "HEAD"** (detached HEAD state):
  - Get the current commit hash: `git rev-parse --short HEAD`
  - Set `isDetachedHead = true`
  - Display warning in Feature Context section

- **Otherwise**:
  - Set `isDetachedHead = false`
  - Set `isFeatureBranch = true` if `ISSUE_NUMBER` is non-empty

### Step 3: Get GitHub Issue Details (if applicable)

If `ISSUE_NUMBER` is non-empty, attempt to fetch issue details:

```bash
gh issue view {issueNumber} --json number,title,state
```

**Handle results**:

- **If gh command succeeds**: Parse JSON and extract `title` and `state`
- **If gh is not installed**: Set `ghAvailable = false`, display "GitHub CLI not available" note
- **If gh is not authenticated**: Set `ghAuthenticated = false`, display "GitHub CLI not authenticated" note
- **If issue not found**: Display "Issue #{issueNumber} not found" note

### Step 4: Detect Workflow Phase

Check for spec files using paths from `fetch-branch-info.sh` (only if on a feature branch):

1. Check if `SPEC_PATH` exists -> set `specExists`
2. Check if `PLAN_PATH` exists -> set `planExists`
3. Check if `TASKS_PATH` exists -> set `tasksExists`

**Determine phase**:

```
if tasksExists -> phase = "Implementation"
else if planExists -> phase = "Planning"
else if specExists -> phase = "Specification"
else -> phase = "Not started"
```

### Step 5: Get File Status

Get the current file status:

```bash
git status --porcelain
```

**Parse the output**:

Each line has format: `XY filename` where:
- First character (X) = index/staging status
- Second character (Y) = working tree status
- Common codes: M=modified, A=added, D=deleted, R=renamed, ?=untracked

**Create file list**:

- Parse each line and categorize:
  - `M ` (first char M, second space) → "staged modified"
  - ` M` (first space, second M) → "modified"
  - `A ` → "staged added"
  - `D ` → "staged deleted"
  - ` D` → "deleted"
  - `??` → "untracked"
  - `R ` → "staged renamed"
  - `MM` → "staged modified, with unstaged changes"
  - `AM` → "staged added, with unstaged changes"

- Count staged and unstaged files
- Limit display to first 10 files
- Track total count for overflow message

### Step 6: Determine Next Command Suggestion

Based on the current state, determine the suggested next command:

**Suggestion Logic**:

| Phase | Has Uncommitted Changes | Suggested Command | Reason |
|-------|------------------------|-------------------|--------|
| Not started | Any | `/mykit.specify <issue#>` | Create a specification |
| Specification | No | `/mykit.plan` | Create implementation plan |
| Specification | Yes | `/mykit.commit` | Commit your specification changes |
| Planning | No | `/mykit.tasks` | Generate implementation tasks |
| Planning | Yes | `/mykit.commit` | Commit your planning changes |
| Implementation | No | `/mykit.implement` or `/mykit.pr` | Continue implementation or create PR |
| Implementation | Yes | `/mykit.commit` | Commit your implementation changes |

**Special cases**:

- If on main branch (not feature branch): Suggest `/mykit.specify <issue#>`
- If in detached HEAD: Suggest `git checkout {branch}` to return to a branch

### Step 7: Display Dashboard

Format and display the complete status dashboard:

---

# My Kit Status

## Feature Context

**If on a feature branch with issue details**:
```
**Branch**: {branch}
**Issue**: #{issueNumber} - {issueTitle} ({issueState})
```

**If on a feature branch but gh unavailable**:
```
**Branch**: {branch}
**Issue**: #{issueNumber} (GitHub info unavailable)
```

**If on a feature branch but issue not found**:
```
**Branch**: {branch}
**Issue**: #{issueNumber} (not found in GitHub)
```

**If NOT on a feature branch** (e.g., main, develop):
```
**Branch**: {branch}

Not on a feature branch. Use `/mykit.specify <issue#>` to start working on an issue.
```

**If in detached HEAD state**:
```
**Warning**: Detached HEAD state at {commitHash}

You are not on a branch. Use `git checkout {branchName}` to return to a branch.
```

## Workflow Phase

**If on a feature branch**:
```
**Current**: {phase}
**Progress**: spec.md {specExists ? "✓" : "○"} | plan.md {planExists ? "✓" : "○"} | tasks.md {tasksExists ? "✓" : "○"}
```

**If NOT on a feature branch**:
```
No active feature workflow.
```

## File Status

**If working directory is clean**:
```
Working directory clean
```

**If there are changes (10 or fewer)**:
```
{statusIcon} {statusLabel}  {filepath}
{statusIcon} {statusLabel}  {filepath}
...

({totalCount} file(s) changed)
```

Where:
- `statusIcon` = "✓" for staged files, " " (space) for unstaged
- `statusLabel` = "modified", "added", "deleted", "renamed", "untracked"

**If there are more than 10 changes**:
```
{first 10 files listed as above}

+{remainingCount} more file(s)

({totalCount} file(s) changed, {stagedCount} staged, {unstagedCount} unstaged)
```

## Next Step

```
`{suggestedCommand}` - {reason}
```

---

## Error Handling

| Error | Message |
|-------|---------|
| Not a git repository | "Not in a git repository. Run `git init` to initialize." |
| Detached HEAD | "Warning: Detached HEAD state at {commit}. Branch info unavailable." |
| gh not installed | "GitHub CLI not available. Issue details unavailable." |
| gh not authenticated | "GitHub CLI not authenticated. Run `gh auth login`." |
| Issue not found | "Issue #{number} not found in GitHub." |
| git status fails | "Unable to read file status." |

## Example Output

```markdown
# My Kit Status

## Feature Context
**Branch**: 006-status-dashboard
**Issue**: #6 - feat: /mykit.status - enhanced dashboard (OPEN)

## Workflow Phase
**Current**: Implementation
**Progress**: spec.md ✓ | plan.md ✓ | tasks.md ✓

## File Status
✓ modified  .claude/commands/mykit.status.md
  modified  CLAUDE.md

(2 file(s) changed, 1 staged, 1 unstaged)

## Next Step
`/mykit.commit` - Commit your implementation changes
```

## Related Commands

| Command | Relationship |
|---------|--------------|
| `/mykit.help` | Shows command documentation |
| `/mykit.commit` | Common next step when changes exist |
| `/mykit.specify <issue#>` | Suggested when not on a feature branch |

# /mykit.end

End the current workflow session and export a summary log to ~/my-log.

## Usage

```
/mykit.end [--force]
```

- Executes directly: Generates summary, writes to log, clears session state
- `--force`: Skip the optional commit prompt after writing the log

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Description

This command closes the current workflow session by:
1. Gathering session data (branch, issue, mode, phase, artifacts, commits, files changed)
2. Formatting a structured log entry
3. Writing/prepending it to `~/my-log/.andrew/mykit-temp-log.md`
4. Optionally committing the log update in `~/my-log`
5. Clearing session state (deleting `.mykit/state.json`)

## Implementation

When this command is invoked, execute the following steps in order:

### Step 1: Parse Arguments

Parse the command input to determine:
- `hasRunAction`: Whether `run` was provided
- `hasForceFlag`: Whether `--force` flag is present

### Step 2: Check Prerequisites

Verify we're in a git repository:

```bash
git rev-parse --git-dir 2>/dev/null
```

**If not in a git repository**, display error and stop:

```
**Error**: Not in a git repository.

Run `git init` to initialize a repository, or navigate to an existing git repository.
```

Verify `~/my-log` exists and is a git repository:

```bash
test -d ~/my-log/.git
```

**If `~/my-log` does not exist or is not a git repo**, display error and stop:

```
**Error**: Log repository not found at `~/my-log`.

To set up:
1. Create the repository: `mkdir ~/my-log && cd ~/my-log && git init`
2. Create the log directory: `mkdir -p ~/my-log/.andrew`
3. Or clone an existing log repo: `git clone <url> ~/my-log`
```

### Step 3: Check for Active Session

Check if `.mykit/state.json` exists:

```bash
test -f .mykit/state.json && echo "EXISTS" || echo "MISSING"
```

**If state file is MISSING**, display warning and use fallback data:

```
**Note**: No active session state found (`.mykit/state.json` missing). Generating summary from git context only.
```

### Step 4: Gather Session Data

Collect all session information:

**From git**:

```bash
# Repository name (basename of the repo root directory)
REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")

# Current branch
BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Extract issue number from branch pattern ^([0-9]+)-
ISSUE_NUMBER=$(echo "$BRANCH" | grep -oP '^\d+' || echo "")
```

**From GitHub** (if issue number exists):

```bash
ISSUE_TITLE=$(gh issue view "$ISSUE_NUMBER" --json title --jq '.title' 2>/dev/null || echo "")
```

**From `.mykit/state.json`** (if it exists):

Read the file and extract:
- `workflowStep`: from `.workflow_step`
- `sessionMode`: determine from context (in-memory `session.type` if available, or infer from artifacts)
- `specPath`: from `.current_feature.spec_path`
- `planPath`: from `.plan_path`
- `tasksPath`: from `.tasks_path`
- `lastCommand`: from `.last_command`

**Commits since divergence from main**:

```bash
git log main..HEAD --oneline 2>/dev/null
```

If no commits found (branch just created or same as main), set to empty list.

**Files changed since divergence from main**:

```bash
git diff main --stat 2>/dev/null
```

Extract total files changed count from the summary line.

**Artifacts that exist** (check each file):

Check existence of:
- `specs/{BRANCH}/spec.md`
- `specs/{BRANCH}/plan.md`
- `specs/{BRANCH}/tasks.md`

Build a list of artifacts that exist.

### Step 5: Format the Log Entry

Format the session log entry as markdown:

```markdown
## {BRANCH} — {ISSUE_TITLE or "No issue title"}

**Date**: {YYYY-MM-DD HH:MM}
**Repo**: {REPO_NAME}
**Issue**: #{ISSUE_NUMBER} — {ISSUE_TITLE}
**Branch**: `{BRANCH}`
**Mode**: {sessionMode or "unknown"}
**Phase reached**: {workflowStep or "unknown"}
**Last command**: {lastCommand or "N/A"}

### Artifacts

{list of artifacts that exist, e.g.:}
- spec.md
- plan.md
- tasks.md

### Commits

{list of commits from git log, e.g.:}
- `abc1234` First commit message
- `def5678` Second commit message

{or "No commits on this branch." if empty}

### Files Changed

{total files changed count} file(s) changed

---
```

### Step 6: Preview or Execute

**If `hasRunAction` is false (Preview Mode)**:

Display the log entry with a preview header:

```
## Preview — Session Summary

{formatted log entry from Step 5}

**Note**: This is a preview. No files have been written.

To write this log and end the session, run: `/mykit.end`
```

Stop execution here.

**If `hasRunAction` is true (Execute Mode)**:

Continue to Step 7.

### Step 7: Write Log Entry

1. Create the directory if it doesn't exist:

```bash
mkdir -p ~/my-log/.andrew
```

2. Set the log file path:

```
LOG_FILE=~/my-log/.andrew/mykit-temp-log.md
```

3. **If the log file already exists**: Read its current content, prepend the new entry, write back.

4. **If the log file does not exist**: Create it with a header and the new entry.

The file should have this structure:

```markdown
# My Kit Session Log

{newest entry}

---

{older entries...}
```

Write the file using the Write tool (prepend new entry after the `# My Kit Session Log` header).

### Step 8: Optional Commit in ~/my-log

**If `hasForceFlag` is true**: Skip this step.

**If `hasForceFlag` is false**: Use `AskUserQuestion` to prompt:

- header: "Commit log"
- question: "Commit the log update in ~/my-log?"
- options:
  1. label: "Yes", description: "Commit the log entry in the ~/my-log repository"
  2. label: "No", description: "Leave the log file uncommitted"

**If user selects "Yes"**:

```bash
cd ~/my-log && git add .andrew/mykit-temp-log.md && git commit -m "log: end session {BRANCH}"
```

Display: `Log committed in ~/my-log.`

**If user selects "No"**:

Display: `Log written but not committed.`

### Step 9: Clear Session State

Delete the state file (same as `/mykit.reset`):

```bash
rm -f .mykit/state.json
```

### Step 10: Display Completion

```
**Session ended.**

**Log written**: ~/my-log/.andrew/mykit-temp-log.md
**State cleared**: `.mykit/state.json` deleted

Run `/mykit.start` to begin a new session.
```

## Error Handling

| Error | Message |
|-------|---------|
| Not a git repository | "Not in a git repository. Run `git init` to initialize." |
| `~/my-log` not found | "Log repository not found at `~/my-log`." with setup instructions |
| No active session | Warning only — proceeds with git-only data |
| `gh` unavailable | Silently skip issue title fetch, use "N/A" |
| Git log fails | Use empty commit list |
| Log write fails | "Failed to write log file. Check permissions on `~/my-log/.andrew/`." |
| Commit in ~/my-log fails | "Failed to commit log update." with warning (session state still cleared) |

## Example Output

### Preview Mode

```
## Preview — Session Summary

## 117-mykit-end-command — Add /mykit.end command — session summary export to ~/my-log

**Date**: 2026-02-09 20:00
**Repo**: my-kit
**Issue**: #117 — Add /mykit.end command — session summary export to ~/my-log
**Branch**: `117-mykit-end-command`
**Mode**: minor
**Phase reached**: implement
**Last command**: /mykit.implement

### Artifacts

- spec.md
- plan.md
- tasks.md

### Commits

- `a1b2c3d` feat(commands): add /mykit.end command

### Files Changed

5 file(s) changed

---

**Note**: This is a preview. No files have been written.

To write this log and end the session, run: `/mykit.end`
```

### Execute Mode

```
**Session ended.**

**Log written**: ~/my-log/.andrew/mykit-temp-log.md
**State cleared**: `.mykit/state.json` deleted

Run `/mykit.start` to begin a new session.
```

## Session Behavior

- **Reads session state**: Gathers all session data before clearing
- **Writes to external repo**: Log output goes to `~/my-log`, not the current project
- **Clears state**: Equivalent to `/mykit.reset` after logging
- **Idempotent**: Running multiple times appends duplicate entries (use preview first)

## Related Commands

| Command | Relationship |
|---------|--------------|
| `/mykit.start` | Creates session state (opposite operation) |
| `/mykit.reset` | Clears state without logging (subset of end) |
| `/mykit.status` | View session state before ending |
| `/mykit.resume` | Resume instead of ending |

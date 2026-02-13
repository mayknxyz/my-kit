# /mykit.log

Export a session summary log to ~/my-log.

## Usage

```
/mykit.log
```

- Executes directly: Gathers git data, shows preview, prompts to write

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Description

This command gathers session data from git and formats a structured log entry:
1. Gathering session data (branch, issue title, artifacts, commits, files changed)
2. Formatting a structured log entry
3. Showing a preview and prompting to write
4. Prepending it to `~/my-log/.andrew/mykit-temp-log.md`

## Implementation

When this command is invoked, execute the following steps in order:

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

### Step 2: Gather Session Data

Collect all session information from git:

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

### Step 3: Format the Log Entry

Format the session log entry as markdown:

```markdown
## {BRANCH} — {ISSUE_TITLE or "No issue title"}

**Date**: {YYYY-MM-DD HH:MM}
**Repo**: {REPO_NAME}
**Issue**: #{ISSUE_NUMBER} — {ISSUE_TITLE}
**Branch**: `{BRANCH}`

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

### Step 4: Show Preview and Prompt

Display the log entry with a preview header:

```
## Preview — Session Summary

{formatted log entry from Step 3}
```

Use `AskUserQuestion` to prompt:
- header: "Write log"
- question: "Write this to log?"
- options:
  1. label: "Yes", description: "Prepend to ~/my-log/.andrew/mykit-temp-log.md"
  2. label: "Cancel", description: "Don't write anything"

**If user selects "Cancel"**: Display "Log not written." and stop.

### Step 5: Write Log Entry

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

### Step 6: Display Completion

```
**Log written**: ~/my-log/.andrew/mykit-temp-log.md
```

## Error Handling

| Error | Message |
|-------|---------|
| Not a git repository | "Not in a git repository. Run `git init` to initialize." |
| `~/my-log` not found | "Log repository not found at `~/my-log`." with setup instructions |
| `gh` unavailable | Silently skip issue title fetch, use "N/A" |
| Git log fails | Use empty commit list |
| Log write fails | "Failed to write log file. Check permissions on `~/my-log/.andrew/`." |

## Example Output

```
## Preview — Session Summary

## 117-mykit-log-command — Add /mykit.log command

**Date**: 2026-02-09 20:00
**Repo**: my-kit
**Issue**: #117 — Add /mykit.log command
**Branch**: `117-mykit-log-command`

### Artifacts

- spec.md
- plan.md
- tasks.md

### Commits

- `a1b2c3d` feat(commands): add /mykit.log command

### Files Changed

5 file(s) changed

---
```

## Related Commands

| Command | Relationship |
|---------|--------------|
| `/mykit.status` | View current workflow state |
| `/mykit.commit` | Create commits before logging |

# /mykit.commit

Create a commit with conventional format and update CHANGELOG.md.

## Usage

```
/mykit.commit [create] [--force]
```

- No action: Display commit preview (changes, proposed message)
- `create`: Create the commit and update CHANGELOG
- `--force`: Skip validation checks (not recommended)

## Description

This command creates commits following conventional commit format (feat, fix, docs, etc.) and automatically updates CHANGELOG.md. It ensures changes exist before committing and provides clear feedback throughout the process.

## Implementation

When this command is invoked, perform the following steps:

### Step 1: Check Prerequisites

First, verify we're in a git repository:

```bash
git rev-parse --git-dir 2>/dev/null
```

**If not in a git repository**, display:

```
**Error**: Not in a git repository.

Run `git init` to initialize a repository, or navigate to an existing git repository.
```

### Step 2: Parse Arguments

Parse command arguments:
- Check for `create` action in arguments
- Check for `--force` flag in arguments

```bash
ACTION=""
FORCE_FLAG=false

for arg in "$@"; do
  case "$arg" in
    create)
      ACTION="create"
      ;;
    --force)
      FORCE_FLAG=true
      ;;
    *)
      echo "Error: Invalid argument '$arg'"
      exit 1
      ;;
  esac
done
```

**If invalid argument provided**, display:

```
**Error**: Invalid argument '{arg}'.

Valid usage:
- `/mykit.commit` - Preview changes
- `/mykit.commit create` - Create commit
- `/mykit.commit create --force` - Create commit, skip validation
```

### Step 3: Source Scripts

Source required scripts:

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/.mykit/scripts/git-ops.sh"
```

**If git-ops.sh cannot be sourced**, display:

```
**Error**: git-ops.sh script not found at .mykit/scripts/git-ops.sh

This is a My Kit installation issue. Try re-running installation or `/mykit.upgrade`.
```

### Step 4: Check for Uncommitted Changes

Check if there are changes to commit:

```bash
source .mykit/scripts/git-ops.sh

if ! has_uncommitted_changes; then
  echo "**Info**: No uncommitted changes found."
  echo ""
  echo "Working directory is clean. Nothing to commit."
  exit 0
fi
```

### Step 5: Route Based on Action

- **If ACTION is empty**: Go to Step 6 (Preview Mode)
- **If ACTION is "create"**: Go to Step 8 (Create Mode)

---

## Preview Mode (No Action)

### Step 6: Display Changes Preview

Show what will be committed:

```
## Commit Preview

The following changes will be committed:

### Changed Files
```

Then run:

```bash
git status --short
```

Show diff stats:

```
### Diff Summary
```

```bash
git diff --stat
```

### Step 7: Generate Suggested Commit Message

Analyze changes to suggest commit type:

```bash
source .mykit/scripts/git-ops.sh
SUGGESTED_TYPE=$(generate_commit_message)
```

Display:

```
### Suggested Commit Format

Based on the changed files, suggested commit type: **{SUGGESTED_TYPE}**

Common commit types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

---

**Next Steps**:
- Review changes above
- Run `/mykit.commit create` to create commit
- You'll be prompted for commit type and description
```

Stop after preview.

---

## Create Mode

### Step 8: Display Create Mode Header

```
## Creating Commit

```

### Step 9: Show Current Changes

Display brief summary:

```bash
echo "Changed files:"
git status --short
echo ""
```

### Step 10: Prompt for Commit Details

Use Claude Code's capabilities to gather commit information through conversation:

```
I'll help you create a conventional commit. Let me ask you a few questions:

**1. What type of change is this?**

Common types:
- `feat` - New feature or functionality
- `fix` - Bug fix
- `docs` - Documentation only
- `refactor` - Code refactoring (no functional changes)
- `test` - Adding or updating tests
- `chore` - Maintenance, dependencies, config
- `perf` - Performance improvements
- `style` - Code style/formatting changes

Please provide the commit type:
```

After receiving the type, validate it's one of the recognized types. If not, suggest the closest match or ask again.

```
**2. Briefly describe the change (one line):**

This will be the commit message. Be concise but descriptive.
Example: "add user authentication with JWT"

Please provide the description:
```

After receiving the description, validate it's not empty and is reasonably concise (< 72 characters recommended).

```
**3. Optional: Specify a scope (or press Enter to skip):**

Scope identifies what part of the codebase changed.
Examples: api, ui, auth, database

Scope (optional):
```

### Step 11: Display Commit Summary

Show what will be committed:

```
### Commit Summary

**Type**: {type}
**Scope**: {scope or "none"}
**Message**: {type}{(scope)}: {description}

**CHANGELOG Impact**:
- Section: {changelog_section}
- Entry: {description}

```

### Step 12: Confirm Commit

If `--force` flag is NOT set, ask for confirmation:

```
**Confirm commit?** (yes/no):
```

If user says no or anything other than "yes", abort:

```
Commit cancelled.
```

If `--force` flag IS set, skip confirmation.

### Step 13: Update CHANGELOG.md

Call the update_changelog function:

```bash
source .mykit/scripts/git-ops.sh

if update_changelog "$COMMIT_TYPE" "$COMMIT_DESCRIPTION"; then
  echo "✓ Updated CHANGELOG.md"
else
  echo "⚠️  Warning: Could not update CHANGELOG.md"
fi
```

### Step 14: Stage CHANGELOG if Modified

If CHANGELOG.md was modified, stage it:

```bash
if git diff --name-only | grep -q "CHANGELOG.md"; then
  git add CHANGELOG.md
  echo "✓ Staged CHANGELOG.md"
fi
```

### Step 15: Create the Commit

Create commit with conventional format:

```bash
source .mykit/scripts/git-ops.sh

COMMIT_SHA=$(create_commit "$COMMIT_TYPE" "$COMMIT_DESCRIPTION" "$COMMIT_SCOPE")

if [[ $? -eq 0 ]]; then
  echo "✓ Created commit: $COMMIT_SHA"
else
  echo "❌ Failed to create commit"
  exit 1
fi
```

### Step 16: Update State

Update `.mykit/state.json` with commit information:

```bash
STATE_FILE=".mykit/state.json"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

if [[ -f "$STATE_FILE" ]]; then
  STATE_JSON=$(cat "$STATE_FILE")
else
  STATE_JSON="{}"
fi

# Build commit message
if [[ -n "$COMMIT_SCOPE" ]]; then
  COMMIT_MSG="${COMMIT_TYPE}(${COMMIT_SCOPE}): ${COMMIT_DESCRIPTION}"
else
  COMMIT_MSG="${COMMIT_TYPE}: ${COMMIT_DESCRIPTION}"
fi

UPDATED_STATE=$(echo "$STATE_JSON" | jq \
  --arg sha "$COMMIT_SHA" \
  --arg message "$COMMIT_MSG" \
  --arg timestamp "$TIMESTAMP" \
  '.last_commit = {
    sha: $sha,
    message: $message,
    timestamp: $timestamp
  }')

echo "$UPDATED_STATE" > "$STATE_FILE"
```

### Step 17: Display Success Message

```
---

✅ **Commit created successfully**

**Commit**: {sha}
**Message**: {message}

**Next Steps**:
- Continue development: Make more changes
- Create another commit: `/mykit.commit create`
- Create pull request: `/mykit.pr create` (when ready)
- Push changes: `git push`
```

---

## Force Flag Behavior

When `--force` flag is used:

### Step 18: Display Force Warning (if --force used)

If force flag is set, display warning before creating commit:

```
⚠️  **Warning**: Using --force flag

You are bypassing validation checks. This is not recommended unless you have a specific reason.

Proceeding with commit creation...

```

Then continue with Steps 13-17 normally.

---

## Error Handling

### No Changes to Commit

If `git status --porcelain` returns empty:

```
**Info**: No uncommitted changes found.

Working directory is clean. Nothing to commit.

Make some changes first, then run `/mykit.commit create`.
```

Exit with code 0 (not an error, just informational).

### Invalid Commit Type

If user provides unrecognized commit type:

```
**Error**: Invalid commit type '{type}'.

Valid types: feat, fix, docs, refactor, test, chore, perf, style

Please try again with a valid type.
```

Ask for commit type again.

### Empty Description

If user provides empty or whitespace-only description:

```
**Error**: Commit description cannot be empty.

Please provide a brief description of your changes.
```

Ask for description again.

### Git Commit Failure

If `git commit` command fails:

```
**Error**: Failed to create commit.

Git error: {error message}

Common causes:
- Git hooks blocked the commit
- File conflicts
- Permission issues

Fix the issue and try again.
```

### CHANGELOG Update Failure

If CHANGELOG update fails:

```
**Warning**: Could not update CHANGELOG.md

The commit was created but CHANGELOG.md was not updated.

You can manually update CHANGELOG.md later.
```

Don't fail the commit, just warn.

### State Update Failure

If state.json update fails:

```
**Warning**: Could not update state.json

The commit was created but state was not saved.

Error: {error message}
```

Don't fail the commit, just warn.

---

## Notes

- CHANGELOG.md is automatically created if it doesn't exist
- Force flag skips validation but still shows warnings
- Commit follows conventional commits specification
- State tracking enables other commands to see latest commit
- Scope is optional but recommended for larger projects

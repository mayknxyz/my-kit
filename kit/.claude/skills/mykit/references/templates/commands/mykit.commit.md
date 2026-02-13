# /mykit.commit

Create a commit with conventional format and update CHANGELOG.md.

## Usage

```
/mykit.commit
```

- Default: Create the commit and update CHANGELOG

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

### Step 2: Source Scripts

Source required scripts:

```bash
source $HOME/.claude/skills/mykit/references/scripts/git-ops.sh
```

**If git-ops.sh cannot be sourced**, display:

```
**Error**: git-ops.sh script not found at $HOME/.claude/skills/mykit/references/scripts/git-ops.sh

This is a My Kit installation issue. Try `/mykit.sync` to reinstall.
```

### Step 3: Check for Uncommitted Changes

Check if there are changes to commit:

```bash
source $HOME/.claude/skills/mykit/references/scripts/git-ops.sh

if ! has_uncommitted_changes; then
  echo "**Info**: No uncommitted changes found."
  echo ""
  echo "Working directory is clean. Nothing to commit."
  exit 0
fi
```

### Step 4: Display Create Mode Header

```
## Creating Commit

```

### Step 5: Show Current Changes

Display brief summary:

```bash
echo "Changed files:"
git status --short
echo ""
```

### Step 6: Prompt for Commit Details

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

### Step 7: Display Commit Summary

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

### Step 8: Confirm Commit

Use `AskUserQuestion` to confirm:
- header: "Confirm"
- question: "Create this commit?"
- options:
  1. label: "Yes", description: "Create the commit"
  2. label: "Cancel", description: "Abort"

If user selects "Cancel", display "Commit cancelled." and stop.

### Step 9: Update CHANGELOG.md

Call the update_changelog function:

```bash
source $HOME/.claude/skills/mykit/references/scripts/git-ops.sh

if update_changelog "$COMMIT_TYPE" "$COMMIT_DESCRIPTION"; then
  echo "Updated CHANGELOG.md"
else
  echo "Warning: Could not update CHANGELOG.md"
fi
```

### Step 10: Stage CHANGELOG if Modified

If CHANGELOG.md was modified, stage it:

```bash
if git diff --name-only | grep -q "CHANGELOG.md"; then
  git add CHANGELOG.md
  echo "Staged CHANGELOG.md"
fi
```

### Step 11: Create the Commit

Create commit with conventional format:

```bash
source $HOME/.claude/skills/mykit/references/scripts/git-ops.sh

COMMIT_SHA=$(create_commit "$COMMIT_TYPE" "$COMMIT_DESCRIPTION" "$COMMIT_SCOPE")

if [[ $? -eq 0 ]]; then
  echo "Created commit: $COMMIT_SHA"
else
  echo "Failed to create commit"
  exit 1
fi
```

### Step 12: Display Success Message

```
---

**Commit created successfully**

**Commit**: {sha}
**Message**: {message}

**Next Steps**:
- Continue development: Make more changes
- Create another commit: `/mykit.commit`
- Create pull request: `/mykit.pr` (when ready)
- Push changes: `git push`
```

---

## Error Handling

### No Changes to Commit

If `git status --porcelain` returns empty:

```
**Info**: No uncommitted changes found.

Working directory is clean. Nothing to commit.

Make some changes first, then run `/mykit.commit`.
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

---

## Notes

- CHANGELOG.md is automatically created if it doesn't exist
- Commit follows conventional commits specification
- Scope is optional but recommended for larger projects

# /mykit.commit

Create a commit with conventional format and update CHANGELOG.md.

## Usage

```
/mykit.commit
```

- Executes directly: Creates the commit and updates CHANGELOG

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

After receiving the scope (or empty), ask about breaking changes:

```
**4. Is this a breaking change?**

A breaking change introduces incompatible API or behavior changes.
This affects version bumping (triggers a major version bump at release time).
```

Use `AskUserQuestion` tool with:
- header: "Breaking Change"
- question: "Is this a breaking change?"
- options:
  1. label: "No", description: "No breaking changes (default)"
  2. label: "Yes", description: "This introduces incompatible changes"

Store the answer as `IS_BREAKING` (true/false).

If `IS_BREAKING` is true, ask for a breaking change description:

```
**Describe what breaks:**

Example: "removed the /api/v1/users endpoint, use /api/v2/users instead"
```

Store the answer as `BREAKING_DESCRIPTION`.

### Step 6b: Detect Issue Number from Branch

Attempt to extract the issue number from the current branch for automatic linkage:

```bash
source $HOME/.claude/skills/mykit/references/scripts/git-ops.sh

ISSUE_NUMBER=""
if is_feature_branch; then
  ISSUE_NUMBER=$(extract_issue_number)
fi
```

If `ISSUE_NUMBER` is non-empty, a `Refs #{ISSUE_NUMBER}` footer will be appended to the commit message (see Step 9).

### Step 7: Display Commit Summary

Show what will be committed:

```
### Commit Summary

**Type**: {type}
**Scope**: {scope or "none"}
**Breaking**: {IS_BREAKING ? "Yes — " + BREAKING_DESCRIPTION : "No"}
**Issue**: {ISSUE_NUMBER ? "Refs #" + ISSUE_NUMBER : "none (not on feature branch)"}
**Message**: {type}{(scope)}: {description}

**CHANGELOG Impact**:
- Section: {changelog_section}
- Entry: {description}
{if IS_BREAKING: "- Breaking Section: " + BREAKING_DESCRIPTION}

```

### Step 8: Confirm Commit

Use `AskUserQuestion` to confirm:
- header: "Confirm"
- question: "Create this commit?"
- options:
  1. label: "Yes", description: "Create the commit"
  2. label: "Cancel", description: "Abort"

If user selects "Cancel", display "Commit cancelled." and stop.

### Step 9: Ask Version Bump Type

Use `AskUserQuestion` to determine the version bump:
- header: "Version"
- question: "What type of version bump?"
- options:
  1. label: "Minor", description: "New backward-compatible feature (0.X.0)"
  2. label: "Patch", description: "Bug fix or small change (0.0.X)"
  3. label: "Major", description: "Breaking change (X.0.0)"

Store the answer as `BUMP_TYPE` (major/minor/patch).

### Step 10: Calculate Version

Calculate the next version from the latest git tag and the selected bump type:

```bash
source $HOME/.claude/skills/mykit/references/scripts/git-ops.sh

# Get latest tag
LATEST_TAG=$(git describe --tags --abbrev=0 --match 'v[0-9]*.[0-9]*.[0-9]*' 2>/dev/null || echo "v0.0.0")
[[ "$LATEST_TAG" =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]
V_MAJOR="${BASH_REMATCH[1]}"
V_MINOR="${BASH_REMATCH[2]}"
V_PATCH="${BASH_REMATCH[3]}"

case "$BUMP_TYPE" in
  major)
    V_MAJOR=$((V_MAJOR + 1)); V_MINOR=0; V_PATCH=0
    ;;
  minor)
    V_MINOR=$((V_MINOR + 1)); V_PATCH=0
    ;;
  patch)
    V_PATCH=$((V_PATCH + 1))
    ;;
esac

DEV_VERSION="v${V_MAJOR}.${V_MINOR}.${V_PATCH}"
CHANGELOG_VERSION="${DEV_VERSION#v}"
```

**If CHANGELOG already has a version header matching this version** (from a previous commit in this branch), reuse that version instead of bumping again.

### Step 11: Update CHANGELOG.md (Version-Aware)

Call the update_changelog function with the version:

```bash
source $HOME/.claude/skills/mykit/references/scripts/git-ops.sh

if update_changelog "$COMMIT_TYPE" "$COMMIT_DESCRIPTION" "$CHANGELOG_VERSION"; then
  echo "Updated CHANGELOG.md (${CHANGELOG_VERSION})"
else
  echo "Warning: Could not update CHANGELOG.md"
fi

# If breaking change, also add a Breaking section entry
if [[ "$IS_BREAKING" == "true" ]]; then
  if update_changelog "breaking" "$BREAKING_DESCRIPTION" "$CHANGELOG_VERSION"; then
    echo "Updated CHANGELOG.md (Breaking)"
  else
    echo "Warning: Could not update CHANGELOG.md Breaking section"
  fi
fi
```

### Step 11b: Update package.json Version

If a `package.json` exists in the project root, update its `version` field to match the new version:

```bash
REPO_ROOT="$(git rev-parse --show-toplevel)"
PKG_FILE="${REPO_ROOT}/package.json"

if [[ -f "$PKG_FILE" ]]; then
  # Update the "version" field in package.json
  sed -i "s/\"version\": *\"[^\"]*\"/\"version\": \"${CHANGELOG_VERSION}\"/" "$PKG_FILE"
  echo "Updated package.json version to ${CHANGELOG_VERSION}"
fi
```

This keeps `package.json` version in sync with the CHANGELOG version on every commit.

### Step 12: Stage All Changes

Auto-stage all changes (including CHANGELOG.md and package.json updates):

```bash
source $HOME/.claude/skills/mykit/references/scripts/git-ops.sh

stage_all_changes
echo "Staged all changes"
```

### Step 13: Build and Create the Commit

Build the commit subject line:

```bash
if [[ -n "$COMMIT_SCOPE" ]]; then
  COMMIT_SUBJECT="${COMMIT_TYPE}(${COMMIT_SCOPE}): ${COMMIT_DESCRIPTION}"
else
  COMMIT_SUBJECT="${COMMIT_TYPE}: ${COMMIT_DESCRIPTION}"
fi
```

Build the commit body with footers (if any):

```bash
COMMIT_BODY=""

if [[ "$IS_BREAKING" == "true" ]]; then
  COMMIT_BODY="${COMMIT_BODY}BREAKING CHANGE: ${BREAKING_DESCRIPTION}"$'\n'
fi

if [[ -n "$ISSUE_NUMBER" ]]; then
  COMMIT_BODY="${COMMIT_BODY}Refs #${ISSUE_NUMBER}"$'\n'
fi
```

Create the commit using `create_commit()`:

```bash
source $HOME/.claude/skills/mykit/references/scripts/git-ops.sh

COMMIT_SHA=$(create_commit "$COMMIT_TYPE" "$COMMIT_DESCRIPTION" "$COMMIT_SCOPE" "$COMMIT_BODY")

if [[ $? -eq 0 ]]; then
  echo "Created commit: $COMMIT_SHA"
else
  echo "Failed to create commit"
  exit 1
fi
```

### Step 14: Display Success Message

```
---

**Commit created successfully**

**Commit**: {sha}
**Message**: {message}
**Version**: {CHANGELOG_VERSION}

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
- Version bump type is asked at commit time and calculated from latest git tag
- Scope is optional but recommended for larger projects
- `package.json` version is updated automatically when CHANGELOG is updated

# /mykit.commit

Create a commit with conventional format and update CHANGELOG.md.

## Usage

```
/mykit.commit [--force]
```

- Executes directly: Creates the commit and updates CHANGELOG
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
- Check for `--force` flag in arguments

```bash
FORCE_FLAG=false

for arg in "$@"; do
  case "$arg" in
    --force)
      FORCE_FLAG=true
      ;;
  esac
done
```

### Step 3: Source Scripts

Source required scripts:

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/$HOME/.claude/skills/mykit/references/scripts/git-ops.sh"
```

**If git-ops.sh cannot be sourced**, display:

```
**Error**: git-ops.sh script not found at $HOME/.claude/skills/mykit/references/scripts/git-ops.sh

This is a My Kit installation issue. Try re-running installation or `/mykit.upgrade`.
```

### Step 4: Check for Uncommitted Changes

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

### Step 5: Display Create Mode Header

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

### Step 10b: Detect Issue Number from Branch

Attempt to extract the issue number from the current branch for automatic linkage:

```bash
source $HOME/.claude/skills/mykit/references/scripts/git-ops.sh

ISSUE_NUMBER=""
if is_feature_branch; then
  ISSUE_NUMBER=$(extract_issue_number)
fi
```

If `ISSUE_NUMBER` is non-empty, a `Refs #{ISSUE_NUMBER}` footer will be appended to the commit message (see Step 15).

### Step 11: Display Commit Summary

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

### Step 13: Update CHANGELOG.md (Version-Aware)

Determine the version for the CHANGELOG entry. The mode (Major/Minor/Patch) determines the version bump:

1. Read `session.type` from conversation context (`"major"`, `"minor"`, or `"patch"`)
2. If `session.type` is not set in conversation context, read `session_type` from `.mykit/state.json`
3. Check if `.mykit/state.json` already has a `dev_version` for this development cycle:
   - **If `dev_version` exists**: Use it (don't bump again — same development cycle)
   - **If `dev_version` is missing/null**: Calculate next version based on mode:
     - Get latest git tag (e.g., `v0.26.0`)
     - Apply bump based on mode: Major → next major (`v1.0.0`), Minor → next minor (`v0.27.0`), Patch → next patch (`v0.26.1`)
     - Store as `dev_version` in state.json (Step 16)
4. If no mode is available (no `session.type` and no `session_type` in state), fall back to `calculate_next_version()` which scans commit messages

```bash
source $HOME/.claude/skills/mykit/references/scripts/git-ops.sh

# Determine dev_version
STATE_FILE=".mykit/state.json"
DEV_VERSION=""
SESSION_TYPE="${session_type:-}"  # from conversation context

# Try state.json if not in context
if [[ -z "$SESSION_TYPE" && -f "$STATE_FILE" ]]; then
  SESSION_TYPE=$(jq -r '.session_type // empty' "$STATE_FILE" 2>/dev/null || echo "")
fi

# Check for existing dev_version
if [[ -f "$STATE_FILE" ]]; then
  DEV_VERSION=$(jq -r '.dev_version // empty' "$STATE_FILE" 2>/dev/null || echo "")
fi

# Calculate if needed
if [[ -z "$DEV_VERSION" ]]; then
  # Get latest tag
  LATEST_TAG=$(git describe --tags --abbrev=0 --match 'v[0-9]*.[0-9]*.[0-9]*' 2>/dev/null || echo "v0.0.0")
  [[ "$LATEST_TAG" =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]
  V_MAJOR="${BASH_REMATCH[1]}"
  V_MINOR="${BASH_REMATCH[2]}"
  V_PATCH="${BASH_REMATCH[3]}"

  case "$SESSION_TYPE" in
    major)
      V_MAJOR=$((V_MAJOR + 1)); V_MINOR=0; V_PATCH=0
      ;;
    minor)
      V_MINOR=$((V_MINOR + 1)); V_PATCH=0
      ;;
    patch)
      V_PATCH=$((V_PATCH + 1))
      ;;
    *)
      # Fallback: use calculate_next_version() from git-ops.sh
      DEV_VERSION=$(calculate_next_version)
      ;;
  esac

  if [[ -z "$DEV_VERSION" ]]; then
    DEV_VERSION="v${V_MAJOR}.${V_MINOR}.${V_PATCH}"
  fi
fi

# Strip 'v' prefix for CHANGELOG version header (e.g., "v0.27.0" → "0.27.0")
CHANGELOG_VERSION="${DEV_VERSION#v}"
```

Call the update_changelog function with the version:

```bash
if update_changelog "$COMMIT_TYPE" "$COMMIT_DESCRIPTION" "$CHANGELOG_VERSION"; then
  echo "✓ Updated CHANGELOG.md (${CHANGELOG_VERSION})"
else
  echo "⚠️  Warning: Could not update CHANGELOG.md"
fi

# If breaking change, also add a Breaking section entry
if [[ "$IS_BREAKING" == "true" ]]; then
  if update_changelog "breaking" "$BREAKING_DESCRIPTION" "$CHANGELOG_VERSION"; then
    echo "✓ Updated CHANGELOG.md (Breaking)"
  else
    echo "⚠️  Warning: Could not update CHANGELOG.md Breaking section"
  fi
fi
```

### Step 14: Stage All Changes

Auto-stage all changes (including CHANGELOG.md updates from Step 13):

```bash
source $HOME/.claude/skills/mykit/references/scripts/git-ops.sh

stage_all_changes
echo "✓ Staged all changes"
```

### Step 15: Build and Create the Commit

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
  echo "✓ Created commit: $COMMIT_SHA"
else
  echo "❌ Failed to create commit"
  exit 1
fi
```

### Step 16: Update State

Update `.mykit/state.json` with commit information, `session_type`, and `dev_version`:

```bash
STATE_FILE=".mykit/state.json"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

if [[ -f "$STATE_FILE" ]]; then
  STATE_JSON=$(cat "$STATE_FILE")
else
  STATE_JSON="{}"
fi

# Build commit message for state record
COMMIT_MSG="$COMMIT_SUBJECT"

# Determine breaking flag
BREAKING_FLAG="false"
if [[ "$IS_BREAKING" == "true" ]]; then
  BREAKING_FLAG="true"
fi

# Determine session_type to persist (from conversation context or existing state)
PERSIST_SESSION_TYPE="${SESSION_TYPE:-}"

UPDATED_STATE=$(echo "$STATE_JSON" | jq \
  --arg sha "$COMMIT_SHA" \
  --arg message "$COMMIT_MSG" \
  --arg timestamp "$TIMESTAMP" \
  --argjson breaking "$BREAKING_FLAG" \
  --arg last_cmd "/mykit.commit" \
  --arg last_time "$TIMESTAMP" \
  --arg dev_version "$DEV_VERSION" \
  --arg session_type "$PERSIST_SESSION_TYPE" \
  '.last_commit = {
    sha: $sha,
    message: $message,
    timestamp: $timestamp,
    breaking: $breaking
  } | .last_command = $last_cmd | .last_command_time = $last_time
  | .dev_version = $dev_version
  | if $session_type != "" then .session_type = $session_type else . end')

# Atomic write via temp file
echo "$UPDATED_STATE" > "${STATE_FILE}.tmp"
mv "${STATE_FILE}.tmp" "$STATE_FILE"
```

### Step 17: Display Success Message

```
---

✅ **Commit created successfully**

**Commit**: {sha}
**Message**: {message}

**Next Steps**:
- Continue development: Make more changes
- Create another commit: `/mykit.commit`
- Create pull request: `/mykit.pr -c` (when ready)
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

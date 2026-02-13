# /mykit.pr

Manage pull requests with check dashboard and rich descriptions.

## Usage

```
/mykit.pr [-c|-r|-u|-d] [--force]
```

- No flags: Interactive CRUD menu
- `-c` / `--create`: Create a new pull request
- `-r` / `--read`: View the current PR
- `-u` / `--update`: Update PR title and body
- `-d` / `--delete`: Close the PR
- `--force`: Skip confirmation prompts

## Description

This command manages pull requests with an informational check dashboard and rich descriptions generated from specs, plans, and commits. It automatically links the PR to its GitHub issue.

## CRUD Routing

Parse the user input for CRUD flags (`-c`/`--create`, `-r`/`--read`, `-u`/`--update`, `-d`/`--delete`).

**If a CRUD flag is found**: Route directly to the corresponding operation below.

**If no CRUD flag is found**: Present the interactive menu:

Use `AskUserQuestion`:
- header: "PR"
- question: "What would you like to do?"
- options:
  1. label: "Create", description: "Create a new pull request"
  2. label: "View", description: "View the current PR for this branch"
  3. label: "Update", description: "Update PR title and body"
  4. label: "Close", description: "Close the PR"

Route to the selected operation.

## Operations

### Read (`-r`)

1. Get current branch and extract issue number
2. Run `gh pr view` to display the current PR
3. If no PR exists, display: "No PR found for this branch. Run `/mykit.pr -c` to create one."

### Update (`-u`)

1. Get current branch and find existing PR
2. If no PR exists, display error and stop
3. Regenerate PR title and body from current specs/commits
4. Run `gh pr edit` to update the PR

### Delete (`-d`)

1. Get current branch and find existing PR
2. If no PR exists, display error and stop
3. Confirm closure (unless `--force`)
4. Run `gh pr close` to close the PR

### Create (`-c`)

When the Create operation is selected, perform the following steps:

## Implementation

When this command is invoked, perform the following steps:

### Step 1: Check Prerequisites

Verify we're in a git repository:

```bash
git rev-parse --git-dir 2>/dev/null
```

**If not in a git repository**, display:

```
**Error**: Not in a git repository.

Run `git init` to initialize a repository, or navigate to an existing git repository.
```

### Step 2: Check Feature Branch

Get current branch and verify it's a feature branch:

```bash
source $HOME/.claude/skills/mykit/references/scripts/git-ops.sh

CURRENT_BRANCH=$(get_current_branch)

if ! is_feature_branch; then
  echo "**Error**: Not on a feature branch."
  echo ""
  echo "Current branch: $CURRENT_BRANCH"
  echo ""
  echo "Feature branches must follow the pattern: {number}-{slug}"
  echo "Example: 042-add-dark-mode"
  echo ""
  echo "To start working on an issue:"
  echo "- Run `/mykit.start` to select an issue and create a branch"
  exit 1
fi
```

### Step 3: Extract Issue Number

Extract issue number from branch name:

```bash
ISSUE_NUMBER=$(extract_issue_number)
echo "Issue: #$ISSUE_NUMBER"
echo "Branch: $CURRENT_BRANCH"
echo ""
```

### Step 4: Parse Arguments

Parse command arguments:

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

**If invalid argument**, display:

```
**Error**: Invalid argument '{arg}'.

Valid usage:
- `/mykit.pr` - Preview PR
- `/mykit.pr -c` - Create PR
- `/mykit.pr -c --force` - Create PR, bypass validation
```

### Step 5: Source Required Scripts

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/$HOME/.claude/skills/mykit/references/scripts/git-ops.sh"
source "$SCRIPT_DIR/$HOME/.claude/skills/mykit/references/scripts/utils.sh"
```

### Step 5a: Read Configuration

Read PR-related configuration values with safe defaults:

```bash
BASE_BRANCH=$(get_config_field_or_default ".defaults.branch" "main")
TITLE_TEMPLATE=$(get_config_field_or_default ".pr.titleTemplate" "{version}: {title} (#{issue})")
AUTO_ASSIGN=$(get_config_field_or_default ".pr.autoAssign" "true")
DRAFT_MODE=$(get_config_field_or_default ".pr.draftMode" "false")
```

### Step 5b: Read Session Type

Read `session.type` from conversation context, falling back to `session_type` in `.mykit/state.json`:

```bash
SESSION_TYPE="${session_type:-}"  # from conversation context

if [[ -z "$SESSION_TYPE" && -f ".mykit/state.json" ]]; then
  SESSION_TYPE=$(jq -r '.session_type // empty' ".mykit/state.json" 2>/dev/null || echo "")
fi
```

### Step 6: Determine Paths

```bash
BRANCH_SLUG="${CURRENT_BRANCH#*-}"  # Remove issue number prefix
SPEC_PATH="specs/$CURRENT_BRANCH/spec.md"
PLAN_PATH="specs/$CURRENT_BRANCH/plan.md"
TASKS_PATH="specs/$CURRENT_BRANCH/tasks.md"
```

### Step 7: Gather Check Dashboard Data

Read check status from state.json and task completion status (informational only — never blocks):

```bash
# Task completion status
TASKS_COMPLETE=false
if [[ -f "$TASKS_PATH" ]]; then
  if check_tasks_complete "$TASKS_PATH"; then
    TASKS_COMPLETE=true
  fi
fi

# Read check statuses from state.json
QUALITY_STATUS=$(get_state_field ".checks.quality.status" 2>/dev/null || echo "not_run")
QUALITY_LAST_RUN=$(get_state_field ".checks.quality.last_run" 2>/dev/null || echo "")
SECURITY_STATUS=$(get_state_field ".checks.security.status" 2>/dev/null || echo "not_run")
SECURITY_LAST_RUN=$(get_state_field ".checks.security.last_run" 2>/dev/null || echo "")

# Check commits exist
COMMIT_COUNT=$(get_commit_count "$BASE_BRANCH")
```

### Step 8: Route Based on Action

- **If ACTION is empty**: Go to Step 9 (Preview Mode)
- **If ACTION is "create"**: Go to Step 11 (Create Mode)

---

## Preview Mode (No Action)

### Step 9: Display PR Preview

Show what the PR will contain:

```
## Pull Request Preview

**Issue**: #{ISSUE_NUMBER}
**Branch**: {CURRENT_BRANCH}
**Base**: {BASE_BRANCH}
```

Display the check dashboard (informational only — never blocks PR creation):

```bash
echo "### Checks"
echo ""

# Map status to emoji
status_emoji() {
  case "$1" in
    passed)  echo "✅" ;;
    failed)  echo "❌" ;;
    *)       echo "⬜" ;;
  esac
}

# Display each registered check
echo "$(status_emoji "$QUALITY_STATUS") quality    — $QUALITY_STATUS${QUALITY_LAST_RUN:+ ($QUALITY_LAST_RUN)}"
echo "$(status_emoji "$SECURITY_STATUS") security   — $SECURITY_STATUS${SECURITY_LAST_RUN:+ ($SECURITY_LAST_RUN)}"
echo "⬜ perf       — not run"
echo "⬜ a11y       — not run"
echo "⬜ deps       — not run"
echo ""

# Tasks status
if [[ -f "$TASKS_PATH" ]]; then
  if [[ "$TASKS_COMPLETE" == true ]]; then
    echo "✅ All tasks complete"
  else
    echo "⚠️  Tasks incomplete"
  fi
else
  echo "⬜ No tasks.md (ad-hoc branch)"
fi
echo ""

# Commits status
if [[ "$COMMIT_COUNT" -gt 0 ]]; then
  echo "✅ $COMMIT_COUNT commit(s) on branch"
else
  echo "⚠️  No commits on branch"
fi
```

Display PR settings that will be applied at create time:

```
### PR Settings

- **Assignee**: {self if AUTO_ASSIGN is "true", otherwise none}
- **Draft**: {yes if DRAFT_MODE is "true", otherwise no}
- **Labels**: (selected at create time)
```

### Step 10: Generate and Display PR Description

Generate PR description:

```bash
# Start with summary
PR_DESCRIPTION="## Summary\n\n"

# Try to extract from spec
if [[ -f "$SPEC_PATH" ]]; then
  # Extract summary section from spec
  SPEC_SUMMARY=$(sed -n '/^## Summary/,/^##/p' "$SPEC_PATH" | grep -v '^##' | sed '/^$/d' || echo "")
  if [[ -n "$SPEC_SUMMARY" ]]; then
    PR_DESCRIPTION+="$SPEC_SUMMARY\n\n"
  fi
fi

# If no spec summary, use commits
if [[ -z "$SPEC_SUMMARY" ]]; then
  PR_DESCRIPTION+="This PR implements changes for issue #$ISSUE_NUMBER.\n\n"
fi

# Add changes section
PR_DESCRIPTION+="## Changes\n\n"
PR_DESCRIPTION+="$(get_branch_commits "$BASE_BRANCH" 'pretty')\n\n"

# Add test plan if from plan.md
if [[ -f "$PLAN_PATH" ]]; then
  TEST_PLAN=$(sed -n '/^## Test/,/^##/p' "$PLAN_PATH" | grep -v '^##' || echo "")
  if [[ -n "$TEST_PLAN" ]]; then
    PR_DESCRIPTION+="## Test Plan\n\n$TEST_PLAN\n\n"
  fi
fi

# Add issue link
PR_DESCRIPTION+="Closes #$ISSUE_NUMBER"
```

Display preview:

```
### PR Description

{PR_DESCRIPTION}

---

**Status**: {Ready|Not Ready}

```

```
**Next Steps**:
- Review the PR description and check dashboard above
- Run `/mykit.pr -c` to create the pull request
- The PR will be created on GitHub and linked to issue #{ISSUE_NUMBER}
```

Stop after preview.

---

## Create Mode

### Step 11: Display Create Mode Header

```
## Creating Pull Request

Issue: #{ISSUE_NUMBER}
Branch: {CURRENT_BRANCH}

```

### Step 12: Display Check Dashboard

Display the informational check dashboard before proceeding (never blocks):

```bash
echo "### Checks"
echo ""

status_emoji() {
  case "$1" in
    passed)  echo "✅" ;;
    failed)  echo "❌" ;;
    *)       echo "⬜" ;;
  esac
}

echo "$(status_emoji "$QUALITY_STATUS") quality    — $QUALITY_STATUS${QUALITY_LAST_RUN:+ ($QUALITY_LAST_RUN)}"
echo "$(status_emoji "$SECURITY_STATUS") security   — $SECURITY_STATUS${SECURITY_LAST_RUN:+ ($SECURITY_LAST_RUN)}"
echo "⬜ perf       — not run"
echo "⬜ a11y       — not run"
echo "⬜ deps       — not run"
echo ""
```

### Step 13: Verify Commits Exist

Commits are required to create a PR (this is a hard requirement, not a check):

```bash
if [[ "$COMMIT_COUNT" -eq 0 ]]; then
  echo "❌ **No commits on branch**"
  echo ""
  echo "Create commits with: \`/mykit.commit\`"
  exit 1
fi
```

### Step 14: Generate PR Description

Use same logic as Step 10 to generate PR_DESCRIPTION.

### Step 15: Check gh CLI

Verify gh CLI is available:

```bash
if ! command -v gh; then
  echo "**Error**: GitHub CLI (gh) not found"
  echo ""
  echo "The gh CLI is required to create pull requests."
  echo ""
  echo "Install gh CLI:"
  echo "  - macOS: brew install gh"
  echo "  - Linux: https://github.com/cli/cli#installation"
  echo ""
  echo "After installation, run: gh auth login"
  exit 1
fi
```

### Step 16: Check gh Authentication

```bash
if ! gh auth status &>/dev/null; then
  echo "**Error**: Not authenticated with GitHub"
  echo ""
  echo "Run: gh auth login"
  exit 1
fi
```

### Step 17: Push Branch to Remote

Ensure branch is pushed:

```bash
echo "Pushing branch to remote..."

if git push -u origin "$CURRENT_BRANCH" 2>&1; then
  echo "✓ Branch pushed"
else
  echo "❌ Failed to push branch"
  echo ""
  echo "Push the branch manually: git push -u origin $CURRENT_BRANCH"
  exit 1
fi

echo ""
```

### Step 17a: Resolve PR Title from Template

Resolve the PR title from the configured template:

```bash
PR_TITLE="$TITLE_TEMPLATE"

# {version} - latest git tag
VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "unreleased")
PR_TITLE="${PR_TITLE//\{version\}/$VERSION}"

# {issue} - issue number from branch
PR_TITLE="${PR_TITLE//\{issue\}/$ISSUE_NUMBER}"

# {title} - issue title from GitHub, or spec title, or last commit subject
ISSUE_TITLE=""
if [[ -n "$ISSUE_NUMBER" ]]; then
  ISSUE_TITLE=$(gh issue view "$ISSUE_NUMBER" --json title --jq '.title' 2>/dev/null || echo "")
fi
if [[ -z "$ISSUE_TITLE" ]] && [[ -f "$SPEC_PATH" ]]; then
  ISSUE_TITLE=$(grep -m1 '^# ' "$SPEC_PATH" | sed 's/^# //' | sed 's/^Feature Specification: //' || echo "")
fi
if [[ -z "$ISSUE_TITLE" ]]; then
  ISSUE_TITLE=$(git log -1 --pretty=%s)
fi
PR_TITLE="${PR_TITLE//\{title\}/$ISSUE_TITLE}"
```

### Step 17b: Fetch Repo Labels and Select

Fetch available labels from the repository:

```bash
REPO_LABELS=$(gh label list --json name --jq '.[].name' --limit 30 2>/dev/null || echo "")
```

Define session-type-to-label mapping for auto-selection:

| Session Type | Match patterns (case-insensitive) |
|---|---|
| `major` | `enhancement`, `feature`, `breaking`, `breaking change` |
| `minor` | `enhancement`, `feature` |
| `patch` | `bug`, `fix`, `maintenance`, `patch` |

**If `REPO_LABELS` is empty**: Set `SELECTED_LABELS` to empty (no labels available in repo). Skip to Step 18.

**If `FORCE_FLAG` is true**: Auto-select labels by matching `REPO_LABELS` against the session type patterns (case-insensitive). Store matches as `SELECTED_LABELS`. No user prompt.

**If `FORCE_FLAG` is false**: Present available repo labels using `AskUserQuestion`:

- header: "Labels"
- question: "Which labels should this PR have?"
- multiSelect: true
- options: up to 4 labels at a time, with session-type matches listed first. If more than 4 labels, add a "More..." option to show the next batch.
- User can select "Other" to skip labels entirely.

Store selected labels as `SELECTED_LABELS`.

### Step 18: Create Pull Request

Create PR using gh CLI:

```bash
echo "Creating pull request..."

# Build gh pr create command dynamically
PR_CMD=(gh pr create \
  --title "$PR_TITLE" \
  --body "$PR_DESCRIPTION" \
  --base "$BASE_BRANCH" \
  --head "$CURRENT_BRANCH")

# Self-assign from config
if [[ "$AUTO_ASSIGN" == "true" ]]; then
  PR_CMD+=(--assignee @me)
fi

# Draft mode from config
if [[ "$DRAFT_MODE" == "true" ]]; then
  PR_CMD+=(--draft)
fi

# Labels from selection (Step 17b)
for label in "${SELECTED_LABELS[@]}"; do
  PR_CMD+=(--label "$label")
done

PR_URL=$("${PR_CMD[@]}" 2>&1)

if [[ $? -eq 0 ]]; then
  # Extract PR number from URL
  PR_NUMBER=$(echo "$PR_URL" | grep -oP '/pull/\K[0-9]+' || echo "")

  echo "✓ Pull request created"
  echo ""
  echo "**PR**: $PR_URL"

else
  echo "❌ Failed to create pull request"
  echo ""
  echo "Error: $PR_URL"
  exit 1
fi
```

### Step 19: Update State

Update state.json with PR information:

```bash
STATE_FILE=".mykit/state.json"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

if [[ -f "$STATE_FILE" ]]; then
  STATE_JSON=$(cat "$STATE_FILE")
else
  STATE_JSON="{}"
fi

UPDATED_STATE=$(echo "$STATE_JSON" | jq \
  --arg url "$PR_URL" \
  --arg number "$PR_NUMBER" \
  --arg timestamp "$TIMESTAMP" \
  '.pr = {
    url: $url,
    number: $number,
    created_at: $timestamp
  } | .workflow_step = "pr_created"')

echo "$UPDATED_STATE" > "$STATE_FILE"
```

### Step 20: Display Success Message

```
---

✅ **Pull request created successfully**

**PR**: {PR_URL}
**Issue**: #{ISSUE_NUMBER}
**Assigned**: {self if AUTO_ASSIGN is "true", otherwise none}
**Draft**: {yes if DRAFT_MODE is "true", otherwise no}
**Labels**: {comma-separated SELECTED_LABELS, or "none"}

**Next Steps**:
- Review the PR on GitHub
- Request reviews from team members
- Address any CI/CD feedback
- Merge when approved

You can view the PR with: gh pr view {PR_NUMBER}
```

---

## Error Handling

### Not on Feature Branch

```
**Error**: Not on a feature branch.

Current branch: {branch}

Feature branches must follow pattern: {number}-{slug}
Example: 042-add-dark-mode

To create a feature branch: `/mykit.start`
```

### No Issue Number

```
**Error**: Could not extract issue number from branch name.

Branch: {branch}

Expected format: {number}-{slug}
Example: 042-add-dark-mode
```

### gh CLI Not Found

```
**Error**: GitHub CLI (gh) not found.

Install gh CLI:
  - macOS: brew install gh
  - Linux: https://github.com/cli/cli#installation

After installation: gh auth login
```

### Not Authenticated

```
**Error**: Not authenticated with GitHub.

Run: gh auth login
```

### PR Already Exists

If PR already exists for the branch:

```
**Info**: Pull request already exists for this branch.

Existing PR: {URL}

To update the PR:
- Push new commits: git push
- Update PR description: gh pr edit {number}
```

### Push Failure

```
**Error**: Failed to push branch to remote.

Git error: {error}

Push manually: git push -u origin {branch}
```

### PR Creation Failure

```
**Error**: Failed to create pull request.

GitHub error: {error}

Common causes:
- Branch already has a PR
- Authentication issues
- Network problems

Try again or create PR manually on GitHub.
```

---

## Notes

- Check dashboard is informational — checks never block PR creation
- Only hard requirement: at least one commit on the branch
- PR description generated from spec, plan, and commits
- Automatic issue linking with "Closes #N"
- State tracking for workflow progression
- Supports ad-hoc branches without tasks.md

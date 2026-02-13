# /mykit.pr

Manage pull requests with check dashboard and rich descriptions.

## Usage

```
/mykit.pr
```

- No arguments: Interactive menu (Create / View / Update / Close)

## Description

This command manages pull requests with an informational check dashboard and rich descriptions generated from specs, plans, and commits. It automatically links the PR to its GitHub issue.

## Routing

Use `AskUserQuestion` to present the interactive menu:
- header: "PR"
- question: "What would you like to do?"
- options:
  1. label: "Create", description: "Create a new pull request"
  2. label: "View", description: "View the current PR for this branch"
  3. label: "Update", description: "Update PR title and body"
  4. label: "Close", description: "Close the PR"

Route to the selected operation.

## Operations

### View

1. Get current branch and extract issue number
2. Run `gh pr view` to display the current PR
3. If no PR exists, display: "No PR found for this branch. Run `/mykit.pr` and select Create."

### Update

1. Get current branch and find existing PR
2. If no PR exists, display error and stop
3. Regenerate PR title and body from current specs/commits
4. Run `gh pr edit` to update the PR

### Close

1. Get current branch and find existing PR
2. If no PR exists, display error and stop
3. Use `AskUserQuestion` to confirm closure
4. Run `gh pr close` to close the PR

### Create

When the Create operation is selected, perform the following steps:

## Create Implementation

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
  echo "- Run \`/mykit.specify\` to select an issue and create a branch"
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

### Step 4: Source Required Scripts

```bash
source $HOME/.claude/skills/mykit/references/scripts/git-ops.sh
source $HOME/.claude/skills/mykit/references/scripts/utils.sh
```

### Step 4a: Read Workflow Preferences

Read PR-related preferences from the project's `CLAUDE.md` `## Workflow` section. If `CLAUDE.md` doesn't exist or the section is missing, use these defaults:

```bash
BASE_BRANCH="main"
TITLE_TEMPLATE="{version}: {title} (#{issue})"
AUTO_ASSIGN="true"
DRAFT_MODE="false"
```

To read from CLAUDE.md: parse the `## Workflow` section for key-value pairs like `Default branch: main`, `PR title format: ...`, `Auto-assign PRs: yes/no`, `Draft PRs: yes/no`. Map `yes` → `"true"`, `no` → `"false"`.

### Step 5: Determine Paths

```bash
SPEC_PATH="specs/$CURRENT_BRANCH/spec.md"
PLAN_PATH="specs/$CURRENT_BRANCH/plan.md"
TASKS_PATH="specs/$CURRENT_BRANCH/tasks.md"
```

### Step 6: Gather Check Dashboard Data

Read task completion status and commit count (informational only — never blocks):

```bash
# Task completion status
TASKS_COMPLETE=false
if [[ -f "$TASKS_PATH" ]]; then
  if check_tasks_complete "$TASKS_PATH"; then
    TASKS_COMPLETE=true
  fi
fi

# Check commits exist
COMMIT_COUNT=$(get_commit_count "$BASE_BRANCH")
```

### Step 7: Display Check Dashboard

Display the informational check dashboard before proceeding (never blocks):

```bash
echo "### Checks"
echo ""

# Tasks status
if [[ -f "$TASKS_PATH" ]]; then
  if [[ "$TASKS_COMPLETE" == true ]]; then
    echo "All tasks complete"
  else
    echo "Tasks incomplete"
  fi
else
  echo "No tasks.md (ad-hoc branch)"
fi
echo ""

# Commits status
if [[ "$COMMIT_COUNT" -gt 0 ]]; then
  echo "$COMMIT_COUNT commit(s) on branch"
else
  echo "No commits on branch"
fi
```

### Step 8: Verify Commits Exist

Commits are required to create a PR (this is a hard requirement, not a check):

```bash
if [[ "$COMMIT_COUNT" -eq 0 ]]; then
  echo "**No commits on branch**"
  echo ""
  echo "Create commits with: \`/mykit.commit\`"
  exit 1
fi
```

### Step 9: Generate PR Description

```bash
# Start with summary
PR_DESCRIPTION="## Summary\n\n"

# Try to extract from spec
if [[ -f "$SPEC_PATH" ]]; then
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

### Step 10: Check gh CLI

Verify gh CLI is available and authenticated:

```bash
if ! command -v gh; then
  echo "**Error**: GitHub CLI (gh) not found"
  echo ""
  echo "Install gh CLI:"
  echo "  - macOS: brew install gh"
  echo "  - Linux: https://github.com/cli/cli#installation"
  echo ""
  echo "After installation, run: gh auth login"
  exit 1
fi

if ! gh auth status &>/dev/null; then
  echo "**Error**: Not authenticated with GitHub"
  echo ""
  echo "Run: gh auth login"
  exit 1
fi
```

### Step 11: Push Branch to Remote

Ensure branch is pushed:

```bash
echo "Pushing branch to remote..."

if git push -u origin "$CURRENT_BRANCH" 2>&1; then
  echo "Branch pushed"
else
  echo "Failed to push branch"
  echo ""
  echo "Push the branch manually: git push -u origin $CURRENT_BRANCH"
  exit 1
fi
```

### Step 11a: Resolve PR Title from Template

Resolve the PR title from the configured template:

```bash
PR_TITLE="$TITLE_TEMPLATE"

# {version} - infer from CHANGELOG or latest git tag
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

### Step 11b: Fetch Repo Labels and Select

Fetch available labels from the repository:

```bash
REPO_LABELS=$(gh label list --json name --jq '.[].name' --limit 30 2>/dev/null || echo "")
```

**If `REPO_LABELS` is empty**: Set `SELECTED_LABELS` to empty. Skip label selection.

**If labels are available**: Present using `AskUserQuestion`:

- header: "Labels"
- question: "Which labels should this PR have?"
- multiSelect: true
- options: up to 4 labels, inferred-best-match labels listed first
- User can select "Other" to skip labels entirely.

Store selected labels as `SELECTED_LABELS`.

### Step 12: Confirm PR Creation

Use `AskUserQuestion` to confirm:
- header: "Create PR"
- question: "Create this pull request?"
- options:
  1. label: "Yes", description: "Create the PR on GitHub"
  2. label: "Cancel", description: "Abort"

If user selects "Cancel", display "PR creation cancelled." and stop.

### Step 13: Create Pull Request

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

# Labels from selection
for label in "${SELECTED_LABELS[@]}"; do
  PR_CMD+=(--label "$label")
done

PR_URL=$("${PR_CMD[@]}" 2>&1)

if [[ $? -eq 0 ]]; then
  PR_NUMBER=$(echo "$PR_URL" | grep -oP '/pull/\K[0-9]+' || echo "")
  echo "Pull request created"
  echo ""
  echo "**PR**: $PR_URL"
else
  echo "Failed to create pull request"
  echo ""
  echo "Error: $PR_URL"
  exit 1
fi
```

### Step 14: Display Success Message

```
---

**Pull request created successfully**

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

To create a feature branch: `/mykit.specify`
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

---

## Notes

- Check dashboard is informational — checks never block PR creation
- Only hard requirement: at least one commit on the branch
- PR description generated from spec, plan, and commits
- Automatic issue linking with "Closes #N"
- Supports ad-hoc branches without tasks.md

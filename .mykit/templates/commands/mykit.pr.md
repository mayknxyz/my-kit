# /mykit.pr

Create pull requests with comprehensive validation gates and rich descriptions.

## Usage

```
/mykit.pr [create] [--force]
```

- No action: Display PR preview (description, validation status)
- `create`: Create the pull request
- `--force`: Bypass validation gates (with warnings)

## Description

This command creates pull requests after validating that all tasks are complete, validation has passed, and commits exist. It generates rich PR descriptions from specs, plans, and commits, and automatically links the PR to its GitHub issue.

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
source .mykit/scripts/git-ops.sh

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
  echo "- Run `/mykit.backlog` to select an issue and create a branch"
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
- `/mykit.pr create` - Create PR
- `/mykit.pr create --force` - Create PR, bypass validation
```

### Step 5: Source Required Scripts

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/.mykit/scripts/git-ops.sh"
source "$SCRIPT_DIR/.mykit/scripts/utils.sh"
```

### Step 6: Determine Paths

```bash
BRANCH_SLUG="${CURRENT_BRANCH#*-}"  # Remove issue number prefix
SPEC_PATH="specs/$CURRENT_BRANCH/spec.md"
PLAN_PATH="specs/$CURRENT_BRANCH/plan.md"
TASKS_PATH="specs/$CURRENT_BRANCH/tasks.md"
```

### Step 7: Check Validation Gates (unless --force)

Run validation checks to determine PR readiness:

```bash
VALIDATION_ERRORS=()
VALIDATION_WARNINGS=()

# Gate 1: Check tasks completion
if [[ -f "$TASKS_PATH" ]]; then
  if ! check_tasks_complete "$TASKS_PATH"; then
    VALIDATION_ERRORS+=("Tasks incomplete")
  fi
fi

# Gate 2: Check validation status
VALIDATION_STATUS=$(get_state_field ".validation.status" 2>/dev/null || echo "not_run")
if [[ "$VALIDATION_STATUS" != "passed" ]]; then
  if [[ "$VALIDATION_STATUS" == "not_run" ]]; then
    VALIDATION_ERRORS+=("Validation not run")
  elif [[ "$VALIDATION_STATUS" == "failed" ]]; then
    VALIDATION_ERRORS+=("Validation failed")
  fi
fi

# Gate 3: Check commits exist
COMMIT_COUNT=$(get_commit_count "main")
if [[ "$COMMIT_COUNT" -eq 0 ]]; then
  VALIDATION_ERRORS+=("No commits on branch")
fi
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
**Base**: main

### Validation Status
```

Display validation gate results:

```bash
echo "**Validation Gates**:"
echo ""

# Gate 1: Tasks
if [[ -f "$TASKS_PATH" ]]; then
  if check_tasks_complete "$TASKS_PATH"; then
    echo "✓ All tasks complete"
  else
    echo "❌ Tasks incomplete:"
    find_incomplete_tasks "$TASKS_PATH"
  fi
else
  echo "⚠️  No tasks.md found (ad-hoc branch)"
fi
echo ""

# Gate 2: Validation
if [[ "$VALIDATION_STATUS" == "passed" ]]; then
  echo "✓ Code validation passed"
elif [[ "$VALIDATION_STATUS" == "not_run" ]]; then
  echo "❌ Validation not run"
  echo "   Run: `/mykit.validate run`"
elif [[ "$VALIDATION_STATUS" == "failed" ]]; then
  echo "❌ Validation failed"
  echo "   Run: `/mykit.validate run` and fix issues"
fi
echo ""

# Gate 3: Commits
if [[ "$COMMIT_COUNT" -gt 0 ]]; then
  echo "✓ $COMMIT_COUNT commit(s) on branch"
else
  echo "❌ No commits on branch"
  echo "   Create commits with: `/mykit.commit create`"
fi
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
PR_DESCRIPTION+="$(get_branch_commits 'main' 'pretty')\n\n"

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

If validation errors exist:

```
**Validation Errors**: {count} error(s) must be fixed

**Next Steps**:
- Fix validation errors listed above
- Run `/mykit.pr create` when ready
- Or use `--force` to bypass (not recommended)
```

If no validation errors:

```
**Next Steps**:
- Review the PR description above
- Run `/mykit.pr create` to create the pull request
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

### Step 12: Run Validation Gates (unless --force)

If `--force` is false, check validation gates:

```bash
if [[ "$FORCE_FLAG" == false ]]; then
  if [[ ${#VALIDATION_ERRORS[@]} -gt 0 ]]; then
    echo "❌ **Validation failed**"
    echo ""
    echo "The following issues must be resolved:"
    echo ""

    for error in "${VALIDATION_ERRORS[@]}"; do
      case "$error" in
        "Tasks incomplete")
          echo "❌ **Tasks incomplete**"
          echo ""
          echo "Incomplete tasks:"
          find_incomplete_tasks "$TASKS_PATH"
          echo ""
          echo "Complete tasks with: `/mykit.implement run`"
          echo ""
          ;;
        "Validation not run")
          echo "❌ **Validation not run**"
          echo ""
          echo "Run validation with: `/mykit.validate run`"
          echo ""
          ;;
        "Validation failed")
          echo "❌ **Validation failed**"
          echo ""
          echo "Fix validation errors and run: `/mykit.validate run`"
          echo ""
          ;;
        "No commits on branch")
          echo "❌ **No commits on branch**"
          echo ""
          echo "Create commits with: `/mykit.commit create`"
          echo ""
          ;;
      esac
    done

    echo "---"
    echo ""
    echo "Fix the issues above, or use \`--force\` to bypass validation (not recommended)."
    exit 1
  fi
fi
```

### Step 13: Display Force Warning (if --force)

If force flag is set:

```
⚠️  **Warning**: Using --force flag

You are bypassing validation gates:
```

List bypassed gates:

```bash
for error in "${VALIDATION_ERRORS[@]}"; do
  echo "  - $error"
done

echo ""
echo "This is not recommended. Proceeding with PR creation..."
echo ""
```

### Step 14: Generate PR Description

Use same logic as Step 10 to generate PR_DESCRIPTION.

### Step 15: Check gh CLI

Verify gh CLI is available:

```bash
if ! command -v gh &>/dev/null; then
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

### Step 18: Create Pull Request

Create PR using gh CLI:

```bash
echo "Creating pull request..."

# Create PR with generated description
PR_URL=$(gh pr create \
  --title "$(git log -1 --pretty=%s)" \
  --body "$PR_DESCRIPTION" \
  --base main \
  --head "$CURRENT_BRANCH" 2>&1)

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

To create a feature branch: `/mykit.backlog`
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

- Validation gates ensure quality before PR creation
- Force flag allows bypassing gates with warnings
- PR description generated from spec, plan, and commits
- Automatic issue linking with "Closes #N"
- State tracking for workflow progression
- Supports ad-hoc branches without tasks.md

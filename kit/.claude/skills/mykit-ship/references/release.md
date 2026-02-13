# /mykit.release

Manage releases with automatic versioning, PR merging, and cleanup.

## Usage

```
/mykit.release [-c|-r] [--force]
```

- No flags: Interactive menu (Create or View)
- `-c` / `--create`: Execute the full release flow
- `-r` / `--read`: View release preview (version, commits, what would happen)
- `--force`: Skip confirmation prompt

**Note**: Update (`-u`) and Delete (`-d`) are not supported for releases.

## CRUD Routing

Parse the user input for CRUD flags (`-c`/`--create`, `-r`/`--read`, `-u`/`--update`, `-d`/`--delete`).

**If `-u` or `-d` is provided**: Display error: "Update and Delete are not supported for releases. Available operations: Create (`-c`), View (`-r`)."

**If `-c` or `-r` is found**: Route directly to the corresponding operation.

**If no CRUD flag is found**: Present the interactive menu:

Use `AskUserQuestion`:
- header: "Release"
- question: "What would you like to do?"
- options:
  1. label: "Create", description: "Execute the full release flow"
  2. label: "View", description: "Preview the release (version, commits, changes)"

Route to the selected operation.

### Read (`-r`)

Display the release preview: calculated version, commits that would be included, and what would happen. Do not execute any release actions.

### Create (`-c`)

## Description

This command automates the full release lifecycle: calculate the next semantic version from conventional commits, squash-merge the PR with admin override, create a GitHub release with auto-generated notes, clean up the feature branch, and close the linked issue.

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
source $HOME/.claude/skills/mykit/references/scripts/utils.sh
source $HOME/.claude/skills/mykit/references/scripts/git-ops.sh

CURRENT_BRANCH=$(get_current_branch)

if ! is_feature_branch; then
  echo "**Error**: Not on a feature branch."
  echo ""
  echo "Current branch: $CURRENT_BRANCH"
  echo ""
  echo "You must be on a feature branch to create a release."
  echo "Feature branches follow the pattern: {number}-{slug}"
  exit 1
fi

ISSUE_NUMBER=$(extract_issue_number)
```

### Step 3: Parse Arguments

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
- `/mykit.release` - Preview release
- `/mykit.release create` - Execute release
- `/mykit.release create --force` - Execute release, skip confirmation
```

### Step 4: Check for Open PR

Verify an open PR exists for the current branch:

```bash
source $HOME/.claude/skills/mykit/references/scripts/git-ops.sh

PR_JSON=$(get_pr_for_branch)

if [[ $? -ne 0 ]]; then
  echo "**Error**: No open pull request found for branch '$CURRENT_BRANCH'."
  echo ""
  echo "Create a PR first: \`/mykit.pr -c\`"
  exit 1
fi

PR_NUMBER=$(echo "$PR_JSON" | jq -r '.number')
PR_TITLE=$(echo "$PR_JSON" | jq -r '.title')
PR_HEAD_SHA=$(echo "$PR_JSON" | jq -r '.headRefOid')
```

### Step 5: Calculate Next Version

```bash
source $HOME/.claude/skills/mykit/references/scripts/git-ops.sh

# Calculate version from latest git tag and CHANGELOG
NEXT_VERSION=$(calculate_next_version)
CURRENT_VERSION=$(git describe --tags --abbrev=0 --match 'v[0-9]*.[0-9]*.[0-9]*' 2>/dev/null || echo "v0.0.0")
```

### Step 6: Get Included Commits

```bash
# Read default branch from CLAUDE.md's ## Workflow section, or fall back to "main"
BASE_BRANCH="main"
if [[ -f "CLAUDE.md" ]]; then
  CLAUDE_BRANCH=$(grep -oP 'Default branch: \K\S+' CLAUDE.md 2>/dev/null || true)
  if [[ -n "$CLAUDE_BRANCH" ]]; then
    BASE_BRANCH="$CLAUDE_BRANCH"
  fi
fi
COMMITS=$(get_branch_commits "$BASE_BRANCH" "pretty")
COMMIT_COUNT=$(get_commit_count "$BASE_BRANCH")
```

### Step 7: Route Based on Action

- **If ACTION is empty**: Go to Step 8 (Preview Mode)
- **If ACTION is "create"**: Go to Step 9 (Create Mode)

---

## Preview Mode (No Action)

### Step 8: Display Release Preview

Display what the release would look like without performing any actions:

```
## Release Preview

**Current Version**: {CURRENT_VERSION}
**Next Version**: {NEXT_VERSION}
**PR**: #{PR_NUMBER} — {PR_TITLE}
**Branch**: {CURRENT_BRANCH}
**Commits**: {COMMIT_COUNT}

### Included Commits

{COMMITS}

### Release Steps

If you run `/mykit.release create`, the following will happen:

1. Squash merge PR #{PR_NUMBER} with message: `{NEXT_VERSION}: {PR_TITLE} (#{PR_NUMBER})`
2. Create git tag `{NEXT_VERSION}`
3. Create GitHub release `{NEXT_VERSION}` with auto-generated notes
4. Delete branch `{CURRENT_BRANCH}` (local and remote)
5. Close issue #{ISSUE_NUMBER} with release comment

---

**Note**: This is a preview. No changes have been made.

To execute: `/mykit.release create`
```

Stop after preview.

---

## Create Mode

### Step 9: Confirm Release

**If `--force` flag is NOT set**, ask for confirmation:

Use `AskUserQuestion` tool:
- header: "Confirm Release"
- question: "Release {NEXT_VERSION} from PR #{PR_NUMBER}? This will squash-merge, tag, create a GitHub release, and delete the branch."
- options:
  1. label: "Yes, release", description: "Proceed with release {NEXT_VERSION}"
  2. label: "Cancel", description: "Abort — no changes will be made"

If user selects "Cancel", display:
```
Release cancelled. No changes were made.
```
And stop.

### Step 10: Squash Merge PR

```bash
echo "Merging PR #{PR_NUMBER}..."

MERGE_SUBJECT="${NEXT_VERSION}: ${PR_TITLE} (#${PR_NUMBER})"

MERGE_OUTPUT=$(gh pr merge "$PR_NUMBER" \
  --squash \
  --admin \
  --match-head-commit "$PR_HEAD_SHA" \
  --subject "$MERGE_SUBJECT" 2>&1)

if [[ $? -ne 0 ]]; then
  echo "**Error**: Failed to merge PR."
  echo ""
  echo "$MERGE_OUTPUT"
  echo ""

  if echo "$MERGE_OUTPUT" | grep -qi "admin\|permission\|forbidden\|unauthorized"; then
    echo "This likely means you lack admin permissions on this repository."
    echo "Admin permissions are required for \`--admin\` merge override."
  fi

  echo ""
  echo "No tag or release was created. No cleanup was performed."
  exit 1
fi

echo "PR #{PR_NUMBER} merged."
```

### Step 11: Switch to Main and Pull

```bash
echo "Switching to ${BASE_BRANCH}..."

git checkout "$BASE_BRANCH" 2>/dev/null
git pull origin "$BASE_BRANCH" 2>/dev/null

echo "On ${BASE_BRANCH}, up to date."
```

### Step 12: Create Tag and Push

```bash
echo "Creating tag ${NEXT_VERSION}..."

if ! git tag "$NEXT_VERSION"; then
  echo "**Warning**: Failed to create local tag ${NEXT_VERSION}."
  echo ""
  echo "The PR was already merged. To recover manually:"
  echo "  git tag ${NEXT_VERSION}"
  echo "  git push origin ${NEXT_VERSION}"
  echo "  gh release create ${NEXT_VERSION} --generate-notes --title '${NEXT_VERSION}'"
  exit 1
fi

if ! git push origin "$NEXT_VERSION" 2>/dev/null; then
  echo "**Warning**: Failed to push tag ${NEXT_VERSION}."
  echo ""
  echo "The PR was already merged. To recover manually:"
  echo "  git push origin ${NEXT_VERSION}"
  echo "  gh release create ${NEXT_VERSION} --generate-notes --title '${NEXT_VERSION}'"
  exit 1
fi

echo "Tag ${NEXT_VERSION} pushed."
```

### Step 13: Create GitHub Release

```bash
echo "Creating GitHub release..."

RELEASE_OUTPUT=$(gh release create "$NEXT_VERSION" \
  --generate-notes \
  --title "$NEXT_VERSION" 2>&1)

if [[ $? -ne 0 ]]; then
  echo "**Warning**: Failed to create GitHub release."
  echo ""
  echo "$RELEASE_OUTPUT"
  echo ""
  echo "The PR was merged and tag ${NEXT_VERSION} was pushed."
  echo "To create the release manually:"
  echo "  gh release create ${NEXT_VERSION} --generate-notes --title '${NEXT_VERSION}'"
  echo ""
  echo "Continuing with cleanup..."
fi

echo "GitHub release ${NEXT_VERSION} created."
```

### Step 14: Delete Feature Branch

```bash
echo "Cleaning up branch ${CURRENT_BRANCH}..."

# Delete remote branch (may already be deleted by gh pr merge --delete-branch)
git push origin --delete "$CURRENT_BRANCH" 2>/dev/null || true

# Delete local branch
git branch -d "$CURRENT_BRANCH" 2>/dev/null || git branch -D "$CURRENT_BRANCH" 2>/dev/null || true

echo "Branch ${CURRENT_BRANCH} deleted."
```

### Step 15: Close Linked Issue

```bash
if [[ -n "$ISSUE_NUMBER" ]]; then
  echo "Closing issue #${ISSUE_NUMBER}..."

  gh issue close "$ISSUE_NUMBER" \
    --comment "Released in ${NEXT_VERSION}" 2>/dev/null || {
    echo "**Warning**: Could not close issue #${ISSUE_NUMBER}."
    echo "Close it manually: gh issue close ${ISSUE_NUMBER} --comment 'Released in ${NEXT_VERSION}'"
  }

  echo "Issue #${ISSUE_NUMBER} closed."
fi
```

### Step 16: Display Success

```
---

**Release {NEXT_VERSION} published!**

**Version**: {NEXT_VERSION}
**PR**: #{PR_NUMBER} — {PR_TITLE}
**Release**: {GitHub release URL}
**Issue**: #{ISSUE_NUMBER} closed

**What happened**:
1. PR #{PR_NUMBER} squash-merged to {BASE_BRANCH}
2. Tag {NEXT_VERSION} created and pushed
3. GitHub release {NEXT_VERSION} published with auto-generated notes
4. Branch {CURRENT_BRANCH} deleted (local and remote)
5. Issue #{ISSUE_NUMBER} closed with release comment

```

---

## Error Handling

### Not on Feature Branch

```
**Error**: Not on a feature branch.

Current branch: {branch}

Feature branches must follow pattern: {number}-{slug}
Example: 042-add-dark-mode
```

### No Open PR

```
**Error**: No open pull request found for branch '{branch}'.

Create a PR first: `/mykit.pr -c`
```

### Merge Permission Failure

```
**Error**: Failed to merge PR.

{gh error output}

This likely means you lack admin permissions on this repository.
Admin permissions are required for `--admin` merge override.

No tag or release was created. No cleanup was performed.
```

### Post-Merge Failure (Tag/Release)

```
**Warning**: {step} failed.

The PR was already merged. To recover manually:
  {manual recovery commands}
```

### gh CLI Not Found

```
**Error**: GitHub CLI (gh) not found.

Install gh CLI:
  - macOS: brew install gh
  - Linux: https://github.com/cli/cli#installation

After installation: gh auth login
```

---

## Notes

- Preview mode (no action) is always safe — no side effects
- The merge is the point of no return; post-merge failures provide manual recovery steps
- `--force` skips the confirmation prompt but not prerequisite checks
- Branch deletion is best-effort (uses `|| true`) since `gh pr merge` may already delete it
- Issue closing is best-effort — warns but doesn't fail the release
- The squash merge commit message format is: `v{version}: {PR title} (#{PR number})`

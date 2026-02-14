# /mykit.pr

Create a pull request with a rich description generated from specs, plans, and commits.

## Usage

```
/mykit.pr
```

## Description

This command creates a pull request, auto-generating the title, description, and labels from the workflow artifacts (spec, plan, tasks, commits). Requires at least one commit on the branch.

## Implementation

When this command is invoked, perform the following steps:

### Step 1: Check Prerequisite

```bash
source $HOME/.claude/skills/mykit/references/scripts/fetch-branch-info.sh
source $HOME/.claude/skills/mykit/references/scripts/git-ops.sh
```

Check if at least one commit exists on the branch:

```bash
BASE_BRANCH="main"
COMMIT_COUNT=$(get_commit_count "$BASE_BRANCH")
```

**If no commits**, display error and stop:

```
**Error**: No commits on branch.

Run `/mykit.commit` first.
```

Check if a PR already exists for this branch:

```bash
EXISTING_PR=$(gh pr view "$CURRENT_BRANCH" --json url --jq '.url' 2>/dev/null || echo "")
```

**If PR already exists**, display and stop:

```
**Info**: Pull request already exists for this branch.

PR: {EXISTING_PR}
```

### Step 2: Read Workflow Preferences

Read PR preferences from the project's `CLAUDE.md` `## Workflow` section. Defaults:

```
BASE_BRANCH="main"
TITLE_TEMPLATE="{version}: {title} (#{issue})"
AUTO_ASSIGN="true"
DRAFT_MODE="false"
```

### Step 3: Generate PR Title

Resolve the title template:

- `{version}` — from CHANGELOG version or latest git tag
- `{issue}` — issue number from branch
- `{title}` — issue title from GitHub, or spec feature name, or last commit subject

### Step 4: Generate PR Description

Build the description from available artifacts:

```markdown
## Summary

{Extract from spec Overview section, or summarize from commits}

## Changes

{List commits on branch: git log main..HEAD --oneline}

## Test Plan

{Extract from plan if available, otherwise "Manual testing"}

Closes #{ISSUE_NUMBER}
```

### Step 5: Auto-Detect Labels

Fetch available repo labels:

```bash
REPO_LABELS=$(gh label list --json name --jq '.[].name' --limit 30 2>/dev/null || echo "")
```

If labels exist, auto-match based on:
- Commit type: `feat` → "enhancement", `fix` → "bug", `docs` → "documentation"
- Spec/plan content keywords matching label names

If no labels available, skip.

### Step 6: Push and Create PR

Push branch to remote:

```bash
git push -u origin "$CURRENT_BRANCH"
```

Create the PR:

```bash
PR_CMD=(gh pr create \
  --title "$PR_TITLE" \
  --body "$PR_DESCRIPTION" \
  --base "$BASE_BRANCH" \
  --head "$CURRENT_BRANCH")

# Auto-assign from config
if [[ "$AUTO_ASSIGN" == "true" ]]; then
  PR_CMD+=(--assignee @me)
fi

# Draft mode from config
if [[ "$DRAFT_MODE" == "true" ]]; then
  PR_CMD+=(--draft)
fi

# Labels from auto-detection
for label in "${SELECTED_LABELS[@]}"; do
  PR_CMD+=(--label "$label")
done

PR_URL=$("${PR_CMD[@]}" 2>&1)
```

### Step 7: Display Success

```
**Pull request created successfully**

**PR**: {PR_URL}
**Issue**: #{ISSUE_NUMBER}

**Next steps**: Review on GitHub, request reviews, merge when approved.
```

---

## Error Handling

| Error | Message |
|-------|---------|
| No commits | "No commits on branch. Run `/mykit.commit` first." |
| PR already exists | "Pull request already exists. {URL}" |
| gh CLI not found | "GitHub CLI (gh) not found. Install: https://github.com/cli/cli#installation" |
| Not authenticated | "Not authenticated with GitHub. Run: `gh auth login`" |
| Push failure | "Failed to push branch. Push manually: `git push -u origin {branch}`" |
| PR creation failure | "Failed to create PR. {error}" |

## Notes

- PR description auto-generated from spec, plan, and commits
- Labels auto-detected from commit type and content
- Automatic issue linking with "Closes #N"
- Workflow preferences (base branch, title format, auto-assign, draft) read from CLAUDE.md

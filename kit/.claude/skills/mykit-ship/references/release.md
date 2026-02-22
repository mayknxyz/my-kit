# /mykit.release

Create a release with automatic versioning, PR merging, and cleanup.

## Usage

```
/mykit.release
```

## Description

This command automates the full release lifecycle: calculate version, squash-merge the PR, create a GitHub release, clean up the branch, and close the linked issue.

## Implementation

When this command is invoked, perform the following steps:

### Step 1: Check Prerequisite

```bash
source $HOME/.claude/skills/mykit/references/scripts/fetch-branch-info.sh
source $HOME/.claude/skills/mykit/references/scripts/git-ops.sh

PR_JSON=$(get_pr_for_branch)
# Ensure body is included for test plan check
# get_pr_for_branch must return: number, title, headRefOid, body
```

**If no open PR**, display error and stop:

```
**Error**: No open pull request found for branch '{CURRENT_BRANCH}'.

Run `/mykit.pr` first.
```

Extract PR details:

```bash
PR_NUMBER=$(echo "$PR_JSON" | jq -r '.number')
PR_TITLE=$(echo "$PR_JSON" | jq -r '.title')
PR_HEAD_SHA=$(echo "$PR_JSON" | jq -r '.headRefOid')
```

### Step 2: Check Test Plan Completion

Fetch the PR body and extract test plan checkboxes:

```bash
PR_BODY=$(echo "$PR_JSON" | jq -r '.body')
```

Parse all checkbox lines matching `- [ ]` (unchecked) and `- [x]` (checked). A test plan exists if any checkbox lines are found.

**If no checkboxes found**: Skip this step — no test plan to verify.

**If all checkboxes are checked**: Display `Test plan: all items complete.` and continue.

**If unchecked items exist**, display them:

```
### Test Plan — {checked}/{total} complete

Unchecked:
- [ ] {unchecked item 1}
- [ ] {unchecked item 2}
```

Then apply the **test plan mode** (passed from the invoking command):

#### Mode: `abort` (default — `/mykit.release`)

Display error and stop:

```
**Error**: Test plan incomplete ({checked}/{total}).

Complete the test plan first, or use:
- `/mykit.release.complete` — mark all items as checked and release
- `/mykit.release.bypass` — remove unchecked items and release
```

#### Mode: `complete` (`/mykit.release.complete`)

Update the PR body, replacing all `- [ ]` with `- [x]`:

```bash
gh pr edit "$PR_NUMBER" --body "$UPDATED_BODY"
```

Display: `Test plan: marked {unchecked_count} items as complete.`

#### Mode: `bypass` (`/mykit.release.bypass`)

Update the PR body, removing all unchecked `- [ ]` lines:

```bash
gh pr edit "$PR_NUMBER" --body "$UPDATED_BODY"
```

Display: `Test plan: removed {unchecked_count} unchecked items.`

### Step 3: Read Version and Display Summary

Read base branch from CLAUDE.md `## Workflow` section (default: `main`).

Read the version from CHANGELOG.md or package.json on the branch. The commit step already bumped the version, so **do not recalculate** — use the version that was set during `/mykit.commit`.

```bash
CURRENT_VERSION=$(git describe --tags --abbrev=0 --match 'v[0-9]*.[0-9]*.[0-9]*' 2>/dev/null || echo "v0.0.0")
# NEXT_VERSION comes from CHANGELOG.md or package.json on the branch
COMMITS=$(get_branch_commits "$BASE_BRANCH" "pretty")
COMMIT_COUNT=$(get_commit_count "$BASE_BRANCH")
```

Display release summary:

```
## Releasing {NEXT_VERSION}

**Current**: {CURRENT_VERSION} → **Next**: {NEXT_VERSION}
**PR**: #{PR_NUMBER} — {PR_TITLE}
**Branch**: {CURRENT_BRANCH}
**Commits**: {COMMIT_COUNT}
```

### Step 4: Squash Merge PR

Use `--delete-branch` to clean up the remote branch automatically.

```bash
gh pr merge "$PR_NUMBER" \
  --squash \
  --admin \
  --delete-branch \
  --match-head-commit "$PR_HEAD_SHA"
```

**If merge fails**, display error with manual recovery steps and stop. No tag or release will be created.

### Step 5: Sync Main and Verify Version

```bash
git checkout "$BASE_BRANCH"
git pull origin "$BASE_BRANCH"
```

Check if CHANGELOG.md (and package.json if present) already have the correct `NEXT_VERSION` from the squash merge. **If they do, skip to Step 6** — no version bump commit needed.

Only if the version is missing or incorrect after merge:

1. Update package.json version to `NEXT_VERSION`
2. Update CHANGELOG.md with the version header and release date
3. Commit: `{NEXT_VERSION}: {PR_TITLE} (#{ISSUE_NUMBER}) (#{PR_NUMBER})`
4. Push to base branch

### Step 6: Tag and Release

Create and push tag:

```bash
git tag "$NEXT_VERSION"
git push origin "$BASE_BRANCH" --tags
```

Create GitHub release using the CHANGELOG entry for this version as release notes:

```bash
gh release create "$NEXT_VERSION" \
  --notes "$RELEASE_NOTES" \
  --title "$NEXT_VERSION"
```

`$RELEASE_NOTES` should contain the CHANGELOG.md content for `NEXT_VERSION` (the section between the version header and the next version header or end of file). Do not use `--generate-notes` — it produces commit-log-style output instead of user-facing changelogs.

**If tag or release fails**, display warning with manual recovery commands but continue cleanup.

### Step 7: Cleanup

Delete local feature branch (remote already deleted by `--delete-branch` in Step 4). Note: `CURRENT_BRANCH` must be captured in Step 1 before any `git checkout` changes the active branch.

```bash
git branch -d "$CURRENT_BRANCH" 2>/dev/null || git branch -D "$CURRENT_BRANCH" 2>/dev/null || true
```

Close linked issue:

```bash
gh issue close "$ISSUE_NUMBER" \
  --comment "Released in ${NEXT_VERSION}" 2>/dev/null || true
```

Both are best-effort — warn on failure but don't stop.

### Step 8: Display Success

```
**Release {NEXT_VERSION} published!**

**Version**: {NEXT_VERSION}
**PR**: #{PR_NUMBER} — {PR_TITLE}
**Release**: {GitHub release URL}
**Issue**: #{ISSUE_NUMBER} closed
**Branch**: {CURRENT_BRANCH} deleted
```

---

## Error Handling

| Error | Message |
|-------|---------|
| No open PR | "No open PR found. Run `/mykit.pr` first." |
| Test plan incomplete (abort mode) | "Test plan incomplete. Use `/mykit.release.complete` or `/mykit.release.bypass`." |
| Merge failure | "Failed to merge PR. {error}. No tag or release created." |
| Tag/release failure | Warning only — PR already merged, show manual recovery |
| Branch deletion failure | Warning only — best-effort |
| Issue close failure | Warning only — best-effort |
| gh CLI not found | "GitHub CLI (gh) not found." |

## Notes

- The merge is the point of no return; post-merge failures provide manual recovery steps
- Remote branch deletion is handled by `--delete-branch` on `gh pr merge`; local branch cleanup is best-effort
- Issue closing is best-effort — warns but doesn't fail the release
- **Version ownership**: The commit step owns version bumping. The release step reads the version set by commit — it does NOT recalculate or re-bump. If CHANGELOG/package.json are already correct after merge, skip the version bump commit
- Squash merge commit subject is auto-generated by `gh pr merge` from the PR title

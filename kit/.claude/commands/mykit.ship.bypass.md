# /mykit.ship.bypass

Ship the current work through the full release workflow — review, issue, branch, PR, merge, tag, release. No stops.

## Step 1: Prerequisites

Verify the environment is ready:

```bash
git rev-parse --is-inside-work-tree 2>/dev/null
gh auth status 2>/dev/null
git remote get-url origin 2>/dev/null
```

**If not a git repo**, display error and stop: `Not inside a git repository.`

**If not authenticated**, display error and stop: `Not authenticated with GitHub CLI. Run gh auth login first.`

**If no remote**, display error and stop: `No origin remote configured. Add a GitHub remote first.`

## Step 2: Review changes

Before anything else, build full context of what's being shipped:

1. Run `git status` and `git diff` to see all modified, added, and deleted files
2. Read each changed file to understand the scope and purpose of the changes
3. Summarize what changed and why — this context drives every subsequent step (commit message, changelog, issue body, PR description)

Display a brief summary:

```
### Changes to ship

{concise bullet list of what changed and why}

**Files**: {count} changed
```

## Step 3: Select version type

Use AskUserQuestion to present a version type selection:

- **Question:** "What type of version bump?"
- **Options:**
  - `patch` — Bug fixes, small tweaks (e.g. 1.12.0 → 1.12.1)
  - `minor` — New features, enhancements (e.g. 1.12.1 → 1.13.0)
  - `major` — Breaking changes (e.g. 1.13.0 → 2.0.0)

Wait for the user's selection before proceeding. If the user interrupts or corrects the selection, use their latest response.

## Step 4: Determine the next version

- Read `CHANGELOG.md` to find the current version number
- Bump according to the selected type (major/minor/patch)

## Step 5: Create GitHub issue

- Title should summarize the changes from the review in Step 1
- Body should list the changes using context gathered in Step 1
- Add appropriate label from the canonical list (`$HOME/.claude/skills/mykit/references/labels.md`) — never create new labels
- Self-assign (`--assignee` with your GitHub username)

## Step 6: Create branch and commit

- Create a new branch named `{issue#}-{short-description}` (e.g. `44-add-git-gh-configs`)
- Stage only the relevant changed files (do NOT include unrelated changes)
- Update `CHANGELOG.md` with the new version, today's date, and changes under appropriate headings (Added/Changed/Fixed/Removed)
- Add the changelog link at the bottom of the file following the existing pattern
- Commit with message: `v{version}: short description (#issue)`

## Step 7: Push and create PR

- Push branch with `-u` flag
- Create PR with:
  - Title: `v{version}: short description (#issue)`
  - Body with `Closes #issue`, summary bullets, and test plan
  - Self-assign (`--assignee` with your GitHub username)
  - Add label from the canonical list (`$HOME/.claude/skills/mykit/references/labels.md`)

## Step 8: Squash merge

```bash
PR_HEAD_SHA=$(gh pr view <number> --json headRefOid --jq '.headRefOid')
MERGE_SUBJECT="v{version}: short description (#issue) (#{pr_number})"

gh pr merge <number> --squash --admin --match-head-commit "$PR_HEAD_SHA" --subject "$MERGE_SUBJECT"
```

**If merge fails**, display error with manual recovery steps and stop. No tag or release will be created.

## Step 9: Checkout main and pull

```bash
git checkout main
git pull --ff-only origin main
```

## Step 10: Tag and release

```bash
git tag v{version}
git push origin v{version}
gh release create v{version} --generate-notes --title "v{version}"
```

**If tag or release fails**, display warning with manual recovery commands but continue cleanup.

## Step 11: Cleanup

Delete feature branch (local and remote):

```bash
git push origin --delete "$CURRENT_BRANCH" 2>/dev/null || true
git branch -d "$CURRENT_BRANCH" 2>/dev/null || git branch -D "$CURRENT_BRANCH" 2>/dev/null || true
```

Close linked issue:

```bash
gh issue close "$ISSUE_NUMBER" --comment "Released in v{version}" 2>/dev/null || true
```

Both are best-effort — warn on failure but don't stop.

## Error Handling

| Error | Message |
|-------|---------|
| Not a git repo | `Not inside a git repository.` |
| `gh` not authenticated | `Not authenticated with GitHub CLI. Run gh auth login first.` |
| No remote | `No origin remote configured. Add a GitHub remote first.` |
| Issue creation fails | Display `gh` error output |
| Push failure | `Failed to push branch.` |
| PR creation fails | Display `gh` error output |
| Merge failure | `Failed to merge PR. {error}. No tag or release created.` |
| Tag/release failure | Warning only — PR already merged, show manual recovery |

## Rules

- Never include unrelated changes in the commit
- Never include files with secrets (`.env`, `hosts.yml`, credentials)
- Follow the existing CHANGELOG.md format exactly
- Prefix commit, PR title, and release title with `v{version}:`
- Always wait for each step to succeed before proceeding to the next

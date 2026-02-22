# /mykit.ship.approve

Ship the current work up to PR creation — review, issue, branch, PR — then stop for manual review.

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

## Step 5: Find or create GitHub issue

- First, check for an existing related issue: `gh issue list --state open`
- If a matching issue exists, use it — do not create a duplicate
- If no matching issue exists, create one:
  - Title should summarize the changes from the review in Step 1
  - Body should list the changes using context gathered in Step 1
  - Add appropriate label from the canonical list (`$HOME/.claude/skills/mykit/references/labels.md`) — never create new labels
  - Self-assign (`--assignee` with your GitHub username)

## Step 6: Create branch and commit

- Create a new branch named `{issue#}-{short-description}` (e.g. `44-add-git-gh-configs`)
- Stage only the relevant changed files (do NOT include unrelated changes)
- Update `CHANGELOG.md` with the new version, today's date, and changes under appropriate headings (Added/Changed/Fixed/Removed)
- If the existing CHANGELOG uses comparison links at the bottom, add one for the new version following the existing pattern
- Commit with message: `v{version}: short description (#issue)`

## Step 7: Push and create PR

- Push branch with `-u` flag
- Create PR with:
  - Title: `v{version}: short description (#issue)`
  - Body with `Closes #issue`, summary bullets, and test plan
  - Self-assign (`--assignee` with your GitHub username)
  - Add label from the canonical list (`$HOME/.claude/skills/mykit/references/labels.md`)

## Step 8: Display PR for review

```
**PR created — ready for review**

**PR**: {PR_URL}
**Issue**: #{ISSUE_NUMBER}
**Version**: v{version}

**Next step**: Review the PR on GitHub, then run `/mykit.release` to merge, tag, and release.
```

Stop here. Do **not** merge, tag, or release.

## Error Handling

| Error | Message |
|-------|---------|
| Not a git repo | `Not inside a git repository.` |
| `gh` not authenticated | `Not authenticated with GitHub CLI. Run gh auth login first.` |
| No remote | `No origin remote configured. Add a GitHub remote first.` |
| Issue creation fails | Display `gh` error output |
| Push failure | `Failed to push branch.` |
| PR creation fails | Display `gh` error output |

## Rules

- Never include unrelated changes in the commit
- Never include files with secrets (`.env`, `hosts.yml`, credentials)
- Follow the existing CHANGELOG.md format exactly
- Prefix commit, PR title, and release title with `v{version}:`
- Always wait for each step to succeed before proceeding to the next
- **Do not merge, tag, or release** — this command stops at PR creation

---
description: Ship changes — issue, branch, changelog, PR, merge, tag, release
---

# /ship

Ship the current work through the full release workflow.

## Step 1: Select version type

Before doing anything else, use AskUserQuestion to present a version type selection:

- **Question:** "What type of version bump?"
- **Options:**
  - `patch` — Bug fixes, small tweaks (e.g. 1.12.0 → 1.12.1)
  - `minor` — New features, enhancements (e.g. 1.12.1 → 1.13.0)
  - `major` — Breaking changes (e.g. 1.13.0 → 2.0.0)

Wait for the user's selection before proceeding. If the user interrupts or corrects the selection, use their latest response.

## Step 2: Determine the next version

- Read `CHANGELOG.md` to find the current version number
- Bump according to the selected type (major/minor/patch)

## Step 3: Create GitHub issue

- Title should summarize the changes on the current branch
- Body should list the changes (inspect working tree via `git status` and `git diff`)
- Add appropriate label (`enhancement`, `bug`, or `documentation`)
- Self-assign (`--assignee` with your GitHub username)

## Step 4: Create branch and commit

- Create a new branch named `{issue#}-{short-description}` (e.g. `44-add-git-gh-configs`)
- Stage only the relevant changed files (do NOT include unrelated changes)
- Update `CHANGELOG.md` with the new version, today's date, and changes under appropriate headings (Added/Changed/Fixed/Removed)
- Add the changelog link at the bottom of the file following the existing pattern
- Commit with message: `v{version}: short description (#issue)`

## Step 5: Push and create PR

- Push branch with `-u` flag
- Create PR with:
  - Title: `v{version}: short description (#issue)`
  - Body with `Closes #issue`, summary bullets, and test plan
  - Self-assign (`--assignee` with your GitHub username)
  - Add label (`enhancement`, `bug`, or `documentation`)

## Step 6: Squash merge

- `gh pr merge <number> --squash --admin --delete-branch`

## Step 7: Checkout main and pull

- Confirm you're on `main` and up to date after merge

## Step 8: Tag and release

- `git tag v{version}`
- `git push origin v{version}`
- `gh release create v{version} --title "v{version}: short description"` with release notes pulled from the CHANGELOG entry

## Rules

- Never include unrelated changes in the commit
- Never include files with secrets (`.env`, `hosts.yml`, credentials)
- Follow the existing CHANGELOG.md format exactly
- Prefix commit, PR title, and release title with `v{version}:`
- Always wait for each step to succeed before proceeding to the next

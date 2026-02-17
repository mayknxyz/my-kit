---
name: mykit-ship
description: My Kit ship pipeline — handles commit creation, pull request management, and release publishing with conventional commits, CHANGELOG updates, and GitHub integration.
---

# My Kit Ship Pipeline

Handles the 3 shipping steps: commit, pr, and release. Auto-activates when the user expresses intent to commit changes, create pull requests, or publish releases.

## Trigger Keywords

- **commit**: "commit", "create commit", "commit changes", "save changes", "conventional commit"
- **pr**: "pull request", "create PR", "open PR", "update PR", "merge request"
- **release**: "release", "publish release", "create release", "tag release", "ship it"

## Step Identification

| Step | Keywords | Description |
|------|----------|-------------|
| `commit` | commit, save, conventional commit | Create commit with CHANGELOG updates |
| `pr` | pull request, PR, merge request | Create or update pull request |
| `release` | release, publish, tag, ship | Create release with versioning |

## Related Commands

| Command | Description |
|---------|-------------|
| `/mykit.ship.approve` | Full ship pipeline (review → PR), stops for manual review |
| `/mykit.ship.bypass` | Full ship pipeline (review → release), no stops |
| `/mykit.release` | Release only — aborts if test plan incomplete |
| `/mykit.release.complete` | Release — marks unchecked test plan items as complete |
| `/mykit.release.bypass` | Release — removes unchecked test plan items |

## Test Plan Mode

The release step accepts a **test plan mode** passed from the invoking command:

| Mode | Command | Behavior on incomplete test plan |
|------|---------|----------------------------------|
| `abort` | `/mykit.release` | Stop and suggest `.complete` or `.bypass` |
| `complete` | `/mykit.release.complete` | Mark all `- [ ]` → `- [x]`, proceed |
| `bypass` | `/mykit.release.bypass` | Remove unchecked lines, proceed |

## Routing Logic

### 1. Identify Step

Map user intent to one of the 3 steps: `commit`, `pr`, or `release`.

### 2. Load Branch Context

Before executing any step, source shared context:

```bash
source $HOME/.claude/skills/mykit/references/scripts/fetch-branch-info.sh
```

Sets `BRANCH`, `ISSUE_NUMBER`, `SPEC_PATH`, `PLAN_PATH`, `TASKS_PATH`.

### 3. Load Reference File

| Step | Reference |
|------|-----------|
| commit | `references/commit.md` |
| pr | `references/pr.md` |
| release | `references/release.md` |

**Load only the one reference file needed per invocation.**

### 4. Execute Reference Instructions

Follow the loaded reference file's instructions exactly. Each reference contains the complete workflow:

- **commit.md**: Auto-generated conventional commit, CHANGELOG updates, version bump, pre-stage safety check
- **pr.md**: Auto-generated PR title/description/labels from artifacts, push and create
- **release.md**: Version calculation, squash merge, tag, GitHub release, branch cleanup

## Reference Files

- `references/commit.md` — Full commit workflow with CHANGELOG management
- `references/pr.md` — Pull request creation/update with validation gates
- `references/release.md` — Release publishing with versioning

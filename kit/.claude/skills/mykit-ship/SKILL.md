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

## Routing Logic

### 1. Identify Step

Map user intent to one of the 3 steps: `commit`, `pr`, or `release`.

### 2. Read Shared Git Context

Before executing any step, gather shared context:

```bash
# Current branch
git rev-parse --abbrev-ref HEAD

# Issue number from branch pattern ^([0-9]+)-
# Uncommitted changes
git status --porcelain

# Recent commits on branch
git log --oneline -10
```

### 3. Load Reference File

| Step | Reference |
|------|-----------|
| commit | `references/commit.md` |
| pr | `references/pr.md` |
| release | `references/release.md` |

**Load only the one reference file needed per invocation.**

### 4. Execute Reference Instructions

Follow the loaded reference file's instructions exactly. Each reference contains the complete workflow:

- **commit.md**: Interactive commit type selection, message composition, auto-staging, CHANGELOG updates, breaking change detection, issue linkage, version bump selection
- **pr.md**: Validation gates (tasks complete, code quality, commits exist), PR description generation from artifacts, issue linking, create/update modes
- **release.md**: Version determination, tag creation, GitHub release publishing, post-release cleanup

## Reference Files

- `references/commit.md` — Full commit workflow with CHANGELOG management
- `references/pr.md` — Pull request creation/update with validation gates
- `references/release.md` — Release publishing with versioning

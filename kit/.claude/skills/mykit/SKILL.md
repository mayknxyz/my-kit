---
name: mykit
description: My Kit infrastructure — scripts, templates, and version files. Shared utilities used by mykit-workflow, mykit-ship, and mykit-ops skills.
disable-model-invocation: true
---

# My Kit Infrastructure

This skill contains shared infrastructure files used by other My Kit skills and commands. It is **not** auto-triggered by Claude — it exists solely as a reference container.

## Contents

### Scripts (`references/scripts/`)

9 bash utilities for workflow automation:

| Script | Purpose |
|--------|---------|
| `fetch-branch-info.sh` | Resolve branch context (BRANCH, ISSUE_NUMBER, paths) — sourced by all commands |
| `check-prerequisites.sh` | Validate git repo, branch, and feature context |
| `create-new-feature.sh` | Create feature branch from issue number |
| `git-ops.sh` | Git operations (commit, changelog, branch) |
| `security.sh` | Security scanning utilities |
| `setup-plan.sh` | Plan directory setup |
| `update-agent-context.sh` | Update agent context files |
| `utils.sh` | Shared utilities (task parsing, git helpers) |
| `validation.sh` | Code quality validation (shellcheck, markdownlint) |

### Templates (`references/templates/`)

Template files organized by category:

- `minor/` — Lightweight templates (spec, plan, tasks)
- `commands/` — Command template files for distribution
- `frameworks/` — Framework-specific CLAUDE.md templates (vanilla, astro, sveltekit)

## Path Convention

Scripts in this skill use `$HOME/.claude/` prefix for infrastructure paths (after stow deployment).

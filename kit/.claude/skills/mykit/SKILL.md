---
name: mykit
description: My Kit infrastructure — scripts, templates, upstream mirror, and version files. Shared utilities used by mykit-workflow, mykit-ship, and mykit-ops skills.
disable-model-invocation: true
---

# My Kit Infrastructure

This skill contains shared infrastructure files used by other My Kit skills and commands. It is **not** auto-triggered by Claude — it exists solely as a reference container.

## Contents

### Scripts (`references/scripts/`)

14 bash utilities for workflow automation:

| Script | Purpose |
|--------|---------|
| `check-prerequisites.sh` | Validate git repo, branch, and feature context |
| `check-upstream-drift.sh` | Detect drift between local and spec-kit upstream |
| `create-new-feature.sh` | Create feature branch from issue number |
| `github-api.sh` | GitHub API helpers |
| `git-ops.sh` | Git operations (commit, changelog, branch) |
| `security.sh` | Security scanning utilities |
| `setup-plan.sh` | Plan directory setup |
| `setup-wizard.sh` | Interactive onboarding wizard |
| `sync-upstream.sh` | Sync spec-kit upstream mirror |
| `update-agent-context.sh` | Update agent context files |
| `upgrade.sh` | Self-upgrade via git pull + stow |
| `utils.sh` | Shared utilities (state, config, parsing) |
| `validation.sh` | Code quality validation (shellcheck, markdownlint) |
| `version.sh` | Version checking and comparison |

### Templates (`references/templates/`)

22 template files organized by category:

- `major/` — Full workflow templates (spec, plan, tasks, checklist, agent-file)
- `minor/` — Lightweight templates (spec, plan, tasks)
- `patch/` — Patch templates (spec, plan, tasks)
- `commands/` — Command template files for distribution
- `frameworks/` — Framework-specific templates (vanilla, astro, sveltekit)

### Upstream Mirror (`references/upstream/`)

Spec-kit upstream mirror for tracking upstream changes:

- `commands/` — Upstream speckit command files
- `scripts/` — Upstream utility scripts
- `templates/` — Upstream templates
- `VERSION` — Upstream spec-kit version

### Memory (`references/memory/`)

- `constitution.md` — Project constitution template

### Version Files

- `VERSION` — Current My Kit version (v2.0.0)
- `SPEC_KIT_VERSION` — Tracked spec-kit upstream version

## Path Convention

Scripts in this skill use `$HOME/.claude/` prefix for infrastructure paths (after stow deployment). Per-project paths (`.mykit/state.json`, `.mykit/config.json`, `.mykit/memory/`) remain relative to the project root.

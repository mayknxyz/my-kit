# My Kit

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub issues](https://img.shields.io/github/issues/mayknxyz/my-kit)](https://github.com/mayknxyz/my-kit/issues)
[![GitHub stars](https://img.shields.io/github/stars/mayknxyz/my-kit)](https://github.com/mayknxyz/my-kit/stargazers)

A developer workflow toolkit for [Claude Code](https://claude.ai/code) and [GitHub](https://github.com) that complements [Spec Kit](https://github.com/github/spec-kit). My Kit provides slash commands that automate GitHub operations and workflow orchestration, while Spec Kit handles detailed feature specification.

## What is My Kit?

My Kit provides `/mykit.*` slash commands for Claude Code that automate common development tasks:

- **Issue Management** - Select issues, create branches, track progress
- **Workflow Orchestration** - Guide you through planning → implementation → PR
- **Quality Gates** - Validation checks before commits and PRs
- **Release Automation** - Semantic versioning, changelogs, GitHub releases

## How It Works with Spec Kit

| Tool | Purpose |
|------|---------|
| **Spec Kit** | Detailed feature specification (spec → plan → tasks) |
| **My Kit** | GitHub workflow + lightweight alternative for simple changes |

**Choose your workflow:**

```
[1] Full Workflow (Spec Kit)    - Complex features requiring detailed specs
[2] Lite Workflow (My Kit)      - Simple changes with lightweight docs
[3] Quick Fix                   - Minor changes, no formal planning
```

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/mayknxyz/my-kit/main/install.sh | bash
```

**Requirements:** Git, [GitHub CLI](https://cli.github.com/) (`gh`)

## Quick Start

```bash
# 1. Initialize in your project
/mykit.init

# 2. First-time setup (configure preferences)
/mykit.setup

# 3. Start a workflow session
/mykit.start --run

# 4. Select an issue from backlog
/mykit.backlog --run
```

## Commands

### Workflow

| Command | Description |
|---------|-------------|
| `/mykit.init` | Initialize My Kit in repository |
| `/mykit.setup` | Configure preferences (first-time) |
| `/mykit.start` | Begin workflow session |
| `/mykit.status` | Show current progress |
| `/mykit.resume` | Resume interrupted session |
| `/mykit.reset` | Clear state, start fresh |

### Issue & Branch

| Command | Description |
|---------|-------------|
| `/mykit.backlog` | List issues, select one, create branch |
| `/mykit.help` | Show command documentation |

### Lite Workflow (Spec Kit Alternative)

| Command | Description |
|---------|-------------|
| `/mykit.specify` | Create lightweight spec (AI-guided) |
| `/mykit.plan` | Create implementation plan (AI-guided) |
| `/mykit.tasks` | Generate task breakdown |
| `/mykit.implement` | Execute tasks one by one |

### Quality & Commit

| Command | Description |
|---------|-------------|
| `/mykit.validate` | Run quality checks (lint, format, tests) |
| `/mykit.commit` | Create commit with auto-generated CHANGELOG |
| `/mykit.pr` | Create pull request |
| `/mykit.release` | Create GitHub release with semantic versioning |

### Management

| Command | Description |
|---------|-------------|
| `/mykit.upgrade` | Upgrade My Kit to latest version |

## Workflow Examples

### Full Workflow (with Spec Kit)

```
/mykit.start [1] → /mykit.backlog → /speckit.specify → /speckit.plan →
/speckit.tasks → /speckit.implement → /mykit.validate → /mykit.commit → /mykit.pr
```

### Lite Workflow (My Kit only)

```
/mykit.start [2] → /mykit.backlog → /mykit.specify → /mykit.plan →
/mykit.tasks → /mykit.implement → /mykit.validate → /mykit.commit → /mykit.pr
```

### Quick Fix

```
/mykit.start [3] → /mykit.backlog → (implement) → /mykit.validate →
/mykit.commit → /mykit.pr
```

## Key Features

### Explicit Execution

Commands preview by default. Add `--run` to execute:

```bash
/mykit.commit           # Shows what will be committed
/mykit.commit --run     # Actually commits
```

### Validation Gates

Critical steps require validation:
- `/mykit.pr` requires `/mykit.validate` to pass
- `/mykit.commit` requires uncommitted changes
- `/mykit.specify` requires an issue selected

### Issue Linking

All work is linked to GitHub Issues:
- Branch: `42-feature-name` (issue number prefix)
- Specs: `specs/42-feature-name/`
- PR: Auto-includes `Closes #42`

## Configuration

Settings stored in `.mykit/config.json`:

```json
{
  "github": {
    "default_base_branch": "main",
    "auto_assign_pr": true
  },
  "validation": {
    "auto_fix": true
  }
}
```

## Project Structure

```
.mykit/
├── config.json     # User preferences
├── state.json      # Workflow state
├── scripts/        # Shell utilities
└── cache/          # GitHub API cache

.claude/
└── commands/       # Slash command files
    └── mykit.*.md

specs/
└── {issue}-{slug}/ # Feature specifications
    ├── spec.md
    ├── plan.md
    └── tasks.md
```

## Documentation

- [Blueprint](docs/001_BLUEPRINT.md) - Architecture, requirements, and development plan

## License

MIT

## Related

- [Spec Kit](https://github.com/github/spec-kit) - Feature specification toolkit
- [Claude Code](https://claude.ai/code) - AI-powered development environment

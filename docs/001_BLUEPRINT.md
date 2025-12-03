# My Kit Evolution Plan

This document captures planned changes to My Kit. It serves as a living discussion document before implementation begins.

---

## Current State

My Kit currently provides:
- `/mykit.init` - Initialize repository
- `/mykit.backlog` - Select issue, create branch
- `/mykit.status` - Show workflow state
- `/mykit.validate` - Run quality checks
- `/mykit.commit` - Create commit with CHANGELOG
- `/mykit.pr` - Create pull request
- `/mykit.release` - Create release
- `/mykit.quickfix` - Lightweight workflow for minor fixes

**Current workflow** assumes Spec Kit for feature development:
```
/mykit.init → /mykit.backlog → /speckit.specify → /speckit.plan → /speckit.tasks → /speckit.implement → /mykit.validate → /mykit.commit → /mykit.pr
```

**Problem**: Spec Kit is overkill for minor changes. Users need a lighter alternative.

---

## Existing Features Inventory (v0.3.0)

### Commands (14 mykit.* + 8 speckit.*)

| Command | Description | Keep? |
|---------|-------------|-------|
| `/mykit.init` | Initialize repo, create state/config | Yes - redesign |
| `/mykit.backlog` | List issues, create branch | Yes - enhance |
| `/mykit.status` | Show workflow state | Yes - enhance to dashboard |
| `/mykit.quickfix` | Fast workflow for minor fixes | No - merge into /mykit.start |
| `/mykit.validate` | Shellcheck, markdownlint, formatting | Yes - keep |
| `/mykit.commit` | Update CHANGELOG, create commit | Yes - add validation gates |
| `/mykit.pr` | Create PR with rich description | Yes - add validation gates |
| `/mykit.pr.update` | Update existing PR | Yes - keep |
| `/mykit.issues` | Sync specs to GitHub issues | Yes - keep |
| `/mykit.docs` | Generate framework docs | Move to plugin |
| `/mykit.performance` | Run benchmarks | Move to plugin |
| `/mykit.security` | Security scanning | Move to plugin |
| `/mykit.review` | AI code review (14 subagents) | Move to plugin |
| `/mykit.release` | Semantic versioning, release notes | Yes - keep |

### Scripts (10 files in `.mykit/scripts/`)

| Script | Key Functions | Keep? |
|--------|---------------|-------|
| `utils.sh` | error(), state mgmt, JSON helpers, logging | Yes - essential |
| `github-api.sh` | Issues, PRs, releases, caching layer | Yes - essential |
| `git-ops.sh` | Branch, commit, tag operations | Yes - essential |
| `pr-generator.sh` | PR description from commits/specs | Yes - enhance |
| `release-manager.sh` | Semver calc, release notes | Yes - keep |
| `validation.sh` | Linting, formatting, reports | Yes - keep |
| `framework-detector.sh` | Detect astro/svelte/vanilla | Move to plugin system |
| `report-generator.sh` | Timestamped report paths | Yes - keep |
| `subagent-invoker.sh` | Prepare context for reviews | Move to plugin |
| `doc-generator.sh` | Render templates with variables | Move to plugin |

### Useful Implementations to Keep

**Error Handling** (utils.sh):
```bash
error(exit_code, message, remediation)  # Specific exit codes
warning(message)                         # Non-fatal issues
success(message)                         # Green output
info(message)                            # Blue output
```

**State Management** (utils.sh):
```bash
read_state()                    # Read with file locking
write_state(json)               # Atomic write
lock_state() / unlock_state()   # Concurrent safety
update_state_field(path, value) # Partial updates
get_state_field(path)           # jq queries
```

**Caching System** (github-api.sh):
```bash
cache_response(key, data, ttl)  # TTL-based caching
get_cached_response(key)        # Check expiration
invalidate_cache(key)           # Single key
invalidate_cache_pattern(pat)   # Pattern-based
```

**Conventional Commits** (git-ops.sh):
```bash
extract_conventional_commits()   # Parse type(scope): msg
calculate_next_version()         # Semver from commits
generate_release_notes()         # Categorized by type
```

### Configuration Structure

**state.json** (workflow tracking):
```json
{
  "version": "1.0.0",
  "current_feature": {
    "issue_number": 123,
    "issue_title": "Feature X",
    "branch": "123-feature-x",
    "spec_path": "specs/123-feature-x/spec.md"
  },
  "workflow_step": "implementation",
  "last_command": "/mykit.commit",
  "last_command_time": "2025-12-03T..."
}
```

**config.json** (settings):
```json
{
  "github": {
    "default_base_branch": "main",
    "auto_assign_pr": true,
    "draft_pr_by_default": false
  },
  "validation": { "auto_fix": true },
  "release": {
    "version_bump_strategy": "auto",
    "delete_branch_after_release": true,
    "close_issue_after_release": true
  }
}
```

### Directory Structure

```
.mykit/
├── state.json         # Workflow state
├── config.json        # Settings
├── state.lock         # File lock
├── history.jsonl      # Command log (JSON Lines)
├── cache/             # GitHub API cache (TTL-based)
├── reports/           # Validation/review reports
├── releases/          # Release metadata
├── backups/           # Installation backups
├── scripts/           # Shell utilities
├── plugins/           # NEW: Plugin directory
├── hooks/             # NEW: Hook scripts
└── templates/
    ├── commands/      # Command sources
    ├── scripts/       # Script sources
    ├── lite/          # NEW: Lite workflow templates
    └── docs/          # Framework documentation
```

### Patterns to Keep

1. **Exit codes**: 1 (general), 2 (pre-condition), 3 (auth/network), 4 (git)
2. **File locking**: Atomic state operations with 5s timeout
3. **JSON Lines**: Streaming-friendly history log with 10k rotation
4. **Template distribution**: Source in templates/, copied on install
5. **Caching TTL**: 5min (issues), 30min (user), 1hr (releases)
6. **Conventional commits**: Standard format for versioning

### Things to Improve in Redevelopment

| Issue | Current | Proposed |
|-------|---------|----------|
| No dry-run | Commands execute immediately | R6: Explicit --run flag |
| No validation gates | Can PR without tests | R7: Validation gates |
| No recovery | Lost state on interrupt | R8: /mykit.resume |
| Framework bundled | Selected at install | R10: Plugin system |
| Subagents bundled | 42 templates | Plugin-based reviews |
| No explicit execution | Auto-execute | --run flag required |

---

## Architecture: Hybrid Scripts + Skills

### Design Principle

Use the right tool for each task:
- **Scripts**: Deterministic operations (fast, reliable, offline-capable)
- **Skills**: AI-powered tasks (context-aware, reasoning required)

### Component Assignment

| Component | Implementation | Reason |
|-----------|----------------|--------|
| **Git operations** | Script | Deterministic, fast |
| **GitHub API** | Script | Caching, rate limiting |
| **State management** | Script | Atomic, file-locked |
| **Validation (lint)** | Script | Tool-based, fast |
| **Code review** | Skill | AI analysis needed |
| **Specification** | Skill | Understanding context |
| **Planning** | Skill | Reasoning required |
| **Task generation** | Skill | Context-aware breakdown |
| **PR description** | Hybrid | Template + AI polish |
| **Release notes** | Hybrid | Commit parsing + AI polish |

### Command Breakdown

| Command | Script Part | Skill Part |
|---------|-------------|------------|
| `/mykit.init` | Create dirs, state, config | - |
| `/mykit.backlog` | List issues, create branch | - |
| `/mykit.start` | Show options, set state | - |
| `/mykit.status` | Read state, format output | - |
| `/mykit.specify` | Create folder, save file | Generate spec from questions |
| `/mykit.plan` | Create folder, save file | Generate plan from context |
| `/mykit.tasks` | Read spec/plan, save file | Generate tasks from context |
| `/mykit.implement` | Track progress, update state | - |
| `/mykit.validate` | Run linters, generate report | - |
| `/mykit.commit` | Stage, commit, update CHANGELOG | - |
| `/mykit.pr` | Create PR via API | Generate description (optional) |
| `/mykit.release` | Tag, create release, cleanup | Polish release notes (optional) |
| `/mykit.upgrade` | Download, backup, replace | - |
| `/mykit.plugin` | Install, remove, update | - |
| `/mykit.help` | Display help text | - |
| `/mykit.resume` | Read state, suggest next | - |
| `/mykit.reset` | Clear state | - |

### File Structure

```
.mykit/
├── scripts/           # Bash scripts (deterministic)
│   ├── utils.sh       # Error handling, state, logging
│   ├── github-api.sh  # API + caching
│   ├── git-ops.sh     # Branch, commit, tag
│   ├── validation.sh  # Linting, formatting
│   └── plugin-manager.sh  # Plugin operations
│
└── skills/            # Claude Code skills (AI-powered)
    ├── specify.md     # Generate specifications
    ├── plan.md        # Generate implementation plans
    ├── tasks.md       # Generate task breakdowns
    └── describe.md    # Generate PR/release descriptions

.claude/
├── commands/          # Slash commands (orchestration)
│   └── mykit.*.md     # Each command orchestrates scripts + skills
│
└── skills/            # Installed skills (from .mykit/skills/)
    └── mykit-*.md     # Prefixed to avoid conflicts
```

### Execution Flow Example

**`/mykit.specify --run`**:
```
1. [Script] Validate: issue selected (R1)
2. [Script] Create folder: specs/{issue}-{slug}/
3. [Skill]  Guided questions → generate spec content
4. [Script] Save: specs/{issue}-{slug}/spec.md
5. [Script] Update state: spec_path, workflow_step
6. [Script] Log command to history
```

**`/mykit.pr --run`**:
```
1. [Script] Validate: tasks complete, validation passed (R7)
2. [Script] Gather: commits, diff, spec summary
3. [Skill]  Generate: PR description (optional, or use template)
4. [Script] Create PR via GitHub API
5. [Script] Update state: pr_url, pr_number
6. [Script] Log command to history
```

### Benefits

1. **Speed**: Scripts for fast operations (no API latency)
2. **Reliability**: Deterministic results for git/GitHub ops
3. **Intelligence**: AI for tasks requiring understanding
4. **Offline**: Core workflow works without internet (except GitHub)
5. **Testable**: Scripts can be unit tested
6. **Extensible**: Skills can be enhanced/replaced via plugins

---

## Requirements

Guiding principles for My Kit development:

### R1: GitHub Issue Required

**All work must be linked to a GitHub Issue.**

- Before `/mykit.specify` or `/speckit.specify`, user must:
  - Select an existing issue from backlog, OR
  - Create a new issue
- No specification work proceeds without an issue number
- Enforced in `/mykit.backlog` (always runs before specify commands)

**Rationale**: GitHub Issues provide:
- Documentation trail for all changes
- Reference for PRs, commits, and releases
- Traceability from idea → implementation → deployment

### R2: Branch Naming Convention

**All feature branches must include issue number.**

Format: `{issue-number}-{slug}`
- Example: `042-add-dark-mode`
- Example: `007-fix-login-bug`

**Rationale**: Links commits/branches to issues automatically.

### R3: Spec Folder Matches Issue

**Spec folder must use issue number prefix.**

Format: `specs/{issue-number}-{slug}/`
- Example: `specs/042-add-dark-mode/`

**Rationale**: One-to-one mapping between issues and specs.

### R4: No Orphan Work

**Quick fixes also require issues.**

Even `/mykit.start [3] Quick fix` must:
1. Select or create an issue first
2. Create branch with issue number
3. Reference issue in commit/PR

**Rationale**: Every change is documented, no matter how small.

### R5: PR Links to Issue

**All PRs must reference their issue.**

- PR description includes `Closes #<issue-number>`
- Automatically closes issue when PR merges

**Rationale**: Completes the documentation loop.

### R6: Explicit Execution

**All mykit commands require explicit flags to execute.**

Commands show a preview/dry-run by default. To execute, user must include a flag:

| Command | Preview (default) | Execute |
|---------|-------------------|---------|
| `/mykit.start` | Shows options | `/mykit.start --run` |
| `/mykit.backlog` | Lists issues | `/mykit.backlog --select 42` |
| `/mykit.specify` | Shows template | `/mykit.specify --run` |
| `/mykit.commit` | Shows diff/message | `/mykit.commit --run` |
| `/mykit.pr` | Shows PR preview | `/mykit.pr --run` |
| `/mykit.upgrade` | Shows available updates | `/mykit.upgrade --run` |

**Flags**:
- `--run` - Execute the command
- `--dry-run` - Preview only (default behavior, flag optional)
- `--yes` or `-y` - Skip confirmation prompts

**Rationale**:
- Prevents accidental execution
- Allows reviewing what will happen before committing
- Safer for destructive or irreversible operations

### R7: Validation Gates

**Critical steps require validation to pass before proceeding.**

| Before | Validation Required |
|--------|---------------------|
| `/mykit.commit` | Uncommitted changes exist |
| `/mykit.pr` | All tasks marked complete, `/mykit.validate` passed |
| `/mykit.release` | PR merged, no blocking issues |
| `/mykit.specify` | Issue selected (R1 enforced) |

**Behavior**:
- Command fails with clear error if validation fails
- Error message explains what's missing and how to fix
- `--force` flag to bypass (with warning)

**Rationale**: Prevents incomplete or broken work from progressing.

### R8: State Recovery

**Sessions can be interrupted and resumed.**

Commands for state management:
```
/mykit.resume            # Resume last session
/mykit.reset             # Clear state, start fresh
/mykit.reset --keep-branch  # Reset state but keep branch
```

**State persistence**:
- State saved to `.mykit/state.json` after each command
- Includes: current issue, branch, workflow step, task progress
- Survives Claude Code session restarts

**Rationale**: Real work gets interrupted. Users need seamless recovery.

### R9: Pre/Post Hooks

**Allow custom scripts at lifecycle points.**

Configuration in `.mykit/config.json`:
```json
{
  "hooks": {
    "pre-commit": ".mykit/hooks/lint.sh",
    "post-commit": ".mykit/hooks/notify.sh",
    "pre-pr": ".mykit/hooks/check-coverage.sh",
    "post-pr": ".mykit/hooks/notify-slack.sh"
  }
}
```

**Available hook points**:
- `pre-specify`, `post-specify`
- `pre-plan`, `post-plan`
- `pre-commit`, `post-commit`
- `pre-pr`, `post-pr`
- `pre-release`, `post-release`

**Behavior**:
- Hooks run automatically when command executes
- Pre-hooks can abort execution (non-zero exit)
- Post-hooks run after successful execution
- Hooks receive context via environment variables

**Rationale**: Extensibility for team-specific workflows.

### R10: Onboarding Wizard

**First-time setup via interactive wizard.**

**New Command**: `/mykit.setup`

```
/mykit.setup

Welcome to My Kit! Let's configure your workflow.

[1/5] GitHub authentication... ✓ Logged in as @mayknxyz
[2/5] Default branch? [main]
[3/5] Auto-assign PRs to you? [Y/n]
[4/5] Draft PRs by default? [y/N]
[5/5] Install any plugins?
      [ ] speckit - Full specification workflow
      [ ] astro-docs - Astro documentation
      [ ] security - Security scanning

Setup complete! Run /mykit.start to begin.
```

**Behavior**:
- Runs automatically on first `/mykit.init` if no config exists
- Can be re-run anytime: `/mykit.setup --run`
- Creates `.mykit/config.json` with user preferences
- Optionally installs selected plugins

**Rationale**: Smoother onboarding, fewer configuration errors.

### R11: Command Chaining

**Run multiple commands in sequence.**

**Syntax**:
```
/mykit.chain validate,commit,pr --run
```

**Predefined chains** in `.mykit/config.json`:
```json
{
  "chains": {
    "ship": ["validate", "commit", "pr"],
    "finish": ["validate", "commit", "pr", "release"],
    "check": ["validate", "status"]
  }
}
```

**Usage**:
```
/mykit.ship --run      # Runs: validate → commit → pr
/mykit.finish --run    # Runs: validate → commit → pr → release
```

**Behavior**:
- Stops on first failure
- Shows progress for each step
- Respects validation gates (R7)
- Each command still requires issue context (R1)

**Rationale**: Common workflows in one command, fewer manual steps.

### R12: Plugin System

**Framework-specific features installed via plugins, not bundled.**

Instead of asking "which framework?" during installation:
1. Install My Kit (base, framework-agnostic)
2. Add plugins as needed: `/mykit.plugin install astro-docs`

**New Command**: `/mykit.plugin`

```
/mykit.plugin install <name>    # Install a plugin
/mykit.plugin remove <name>     # Remove a plugin
/mykit.plugin list              # List installed plugins
/mykit.plugin search <query>    # Search available plugins
/mykit.plugin update [name]     # Update plugin(s)
```

**Example plugins**:
| Plugin | Description |
|--------|-------------|
| `speckit` | Full Spec Kit workflow (specify, plan, tasks, implement) |
| `astro-docs` | Astro documentation generation |
| `svelte-docs` | SvelteKit documentation generation |
| `react-docs` | React/Next.js documentation generation |
| `python-docs` | Python/FastAPI documentation generation |
| `go-docs` | Go documentation generation |
| `rust-docs` | Rust documentation generation |
| `changelog` | Enhanced changelog generation |
| `semver` | Semantic versioning automation |
| `slack-notify` | Slack notifications for PR/release |
| `jira-sync` | Sync issues with Jira |

**Spec Kit as plugin**:
```
/mykit.plugin install speckit    # Install Spec Kit
/mykit.plugin update speckit     # Update Spec Kit
/mykit.plugin remove speckit     # Remove Spec Kit
```

Once installed, Spec Kit commands become available:
- `/speckit.specify`, `/speckit.plan`, `/speckit.tasks`, `/speckit.implement`

**Plugin structure**:
```
.mykit/plugins/<plugin-name>/
├── plugin.json          # Metadata (name, version, description)
├── commands/            # Additional slash commands
│   └── mykit.astro-docs.md
├── templates/           # Custom templates
│   └── docs/
├── hooks/               # Hook scripts
│   └── post-release.sh
└── README.md            # Plugin documentation
```

**Plugin registry**:
- Official plugins hosted on GitHub: `github.com/mayknxyz/mykit-plugins`
- Community plugins via URL or local path
- Version pinning supported

**Config tracking** in `.mykit/config.json`:
```json
{
  "plugins": {
    "astro-docs": {
      "version": "1.0.0",
      "source": "official",
      "installed_at": "2025-12-03T..."
    },
    "slack-notify": {
      "version": "0.5.0",
      "source": "https://github.com/user/mykit-slack",
      "installed_at": "2025-12-03T..."
    }
  }
}
```

**Benefits**:
- Lean base installation
- Install only what you need
- Community can create plugins
- Independent plugin versioning
- No framework lock-in during install

**Rationale**: Modular > monolithic. Users choose their stack.

---

## Proposed Changes

### 1. Session Purpose Prompt

**New Command**: `/mykit.start`

At session start, ask what type of work:

```
What would you like to work on?

[1] Full workflow (Spec Kit) - Complex features, full specification
[2] Lite workflow (My Kit) - Simple changes, lightweight docs
[3] Quick fix - No planning, just code

Select [1-3]:
```

- Sets `session.type`: `"speckit" | "mykit" | "quickfix"`
- Replaces deprecated `/mykit.quickfix` command

**State tracking**:
```json
{
  "session": {
    "type": "speckit | mykit | quickfix",
    "started_at": "timestamp"
  }
}
```

---

### 2. My Kit Lite Commands (Spec Kit Counterparts)

| Spec Kit (Full) | My Kit (Lite) | Purpose | Required |
|-----------------|---------------|---------|----------|
| `/speckit.specify` | `/mykit.specify` | Create lightweight spec.md | Optional |
| `/speckit.plan` | `/mykit.plan` | Create plan.md | Optional |
| `/speckit.tasks` | `/mykit.tasks` | Generate tasks.md | **Required** |
| `/speckit.implement` | `/mykit.implement` | Execute tasks | **Required** |

**Flexible flow**: Skip steps as needed
```
Full:    /mykit.specify → /mykit.plan → /mykit.tasks → /mykit.implement
Minimal: /mykit.tasks → /mykit.implement
```

#### `/mykit.specify` - Lightweight Specification (Optional)

**Guided conversation**:
1. "What is this feature/change about?" → Summary
2. "What problem does it solve?" → Problem statement
3. "What should be true when done?" → Acceptance criteria

**Creates**: `specs/{###-feature}/spec.md`

#### `/mykit.plan` - Lightweight Planning (Optional)

**Guided conversation**:
1. "What's the implementation approach?" → Strategy
2. "What are the key components to change?" → Scope
3. "Any risks or considerations?" → Notes

**Creates**: `specs/{###-feature}/plan.md`

#### `/mykit.tasks` - Task Generation (Required)

- If spec.md/plan.md exist: reads them to generate tasks
- If not: asks guided questions to understand the work
- Generates ordered task list
- Adds standard completion tasks (validate, commit, PR)

**Creates**: `specs/{###-feature}/tasks.md`

#### `/mykit.implement` - Task Execution (Required)

- Reads tasks.md
- Shows current task
- Marks tasks complete as work progresses
- Suggests next task

---

### 3. Status Dashboard

**Enhanced Command**: `/mykit.status`

Rich status display showing current state at a glance:

```
/mykit.status

═══════════════════════════════════════════
  My Kit Status
═══════════════════════════════════════════
  Issue:    #42 - Add dark mode
  Branch:   042-add-dark-mode
  Mode:     Lite workflow
  Step:     Implementation (3/5 tasks done)
═══════════════════════════════════════════
  Spec:     ✓ specs/042-add-dark-mode/spec.md
  Plan:     ✓ specs/042-add-dark-mode/plan.md
  Tasks:    ⧖ specs/042-add-dark-mode/tasks.md (3/5)
  Validate: ○ Not run yet
═══════════════════════════════════════════
  Next:     /mykit.implement --run
═══════════════════════════════════════════
```

**Flags**:
- `/mykit.status` - Full dashboard
- `/mykit.status --brief` - One-line summary
- `/mykit.status --json` - JSON output for scripts

---

### 4. Help Command

**New Command**: `/mykit.help`

Built-in documentation:

```
/mykit.help              # List all commands with descriptions
/mykit.help start        # Detailed help for specific command
/mykit.help --flags      # Show all available flags
/mykit.help --examples   # Show usage examples
```

**Output example**:
```
/mykit.help start

/mykit.start - Begin a new workflow session

USAGE:
  /mykit.start [--run]

OPTIONS:
  --run     Execute the command (default: preview only)
  --yes     Skip confirmation prompts

WORKFLOW OPTIONS:
  [1] Full workflow (Spec Kit) - Complex features
  [2] Lite workflow (My Kit) - Simple changes
  [3] Quick fix - No planning

EXAMPLES:
  /mykit.start           # Preview options
  /mykit.start --run     # Start session interactively
```

---

### 5. State Recovery Commands

**New Commands**: `/mykit.resume`, `/mykit.reset`

```
/mykit.resume            # Resume last session from saved state
/mykit.reset             # Clear all state, start fresh
/mykit.reset --keep-branch   # Reset state but keep current branch
/mykit.reset --keep-specs    # Reset state but keep spec files
```

**Resume behavior**:
- Reads `.mykit/state.json`
- Shows what was in progress
- Suggests next command

---

### 6. Issue Templates Integration

**Enhanced**: `/mykit.backlog --create`

When creating new issues:
- Detects repository's `.github/ISSUE_TEMPLATE/` templates
- Offers template selection if multiple exist
- Auto-fills based on workflow type

```
/mykit.backlog --create

Available templates:
  [1] bug_report.md - Report a bug
  [2] feature_request.md - Suggest a feature
  [3] blank - Empty issue

Select template [1-3]:
```

**Auto-fill mapping**:
- Quick fix → bug_report template
- Lite workflow → feature_request template (small)
- Full workflow → feature_request template (detailed)

---

### 7. Lite Templates

**Location**: `.mykit/templates/lite/`

#### spec.md
```markdown
# Feature: {TITLE}

**Branch**: `{BRANCH}` | **Issue**: #{NUMBER} | **Mode**: My Kit Lite

## Summary
{description}

## Problem
{problem statement}

## Acceptance Criteria
- [ ] {criterion 1}
- [ ] {criterion 2}
```

#### plan.md
```markdown
# Plan: {TITLE}

## Approach
{strategy}

## Scope
{components to change}

## Notes
{risks and considerations}
```

#### tasks.md
```markdown
# Tasks: {TITLE}

## Implementation
- [ ] T001 {task}
- [ ] T002 {task}

## Completion
- [ ] T00N /mykit.validate --fix
- [ ] T00N+1 /mykit.commit
- [ ] T00N+2 /mykit.pr
```

---

## Workflow Diagrams

### [1] Full Workflow (Spec Kit)
```
/mykit.start [1]
    ↓
/mykit.backlog (select issue, create branch)
    ↓
/speckit.specify → /speckit.plan → /speckit.tasks → /speckit.implement
    ↓
/mykit.validate → /mykit.commit → /mykit.pr → /mykit.release
```

### [2] Lite Workflow (My Kit)
```
/mykit.start [2]
    ↓
/mykit.backlog (select issue, create branch)
    ↓
/mykit.specify (optional) → /mykit.plan (optional) → /mykit.tasks → /mykit.implement
    ↓
/mykit.validate → /mykit.commit → /mykit.pr → /mykit.release
```

### [3] Quick Fix
```
/mykit.start [3]
    ↓
/mykit.backlog (select issue, create branch)
    ↓
(implement directly - no spec/plan/tasks)
    ↓
/mykit.validate → /mykit.commit → /mykit.pr
```

---

## Files to Create

### Installation & Management
| File | Description |
|------|-------------|
| `install.sh` | Curl-based installer (repo root) |
| `.claude/commands/mykit.upgrade.md` | Self-upgrade command |
| `.claude/commands/mykit.plugin.md` | Plugin management command |
| `.claude/commands/mykit.setup.md` | Onboarding wizard (R10) |
| `.claude/commands/mykit.chain.md` | Command chaining (R11) |
| `.mykit/templates/commands/mykit.upgrade.md` | Template for distribution |
| `.mykit/templates/commands/mykit.plugin.md` | Template for distribution |
| `.mykit/templates/commands/mykit.setup.md` | Template for distribution |
| `.mykit/templates/commands/mykit.chain.md` | Template for distribution |

### Plugin Infrastructure
| File | Description |
|------|-------------|
| `.mykit/plugins/.gitkeep` | Plugins directory placeholder |
| `.mykit/scripts/plugin-manager.sh` | Plugin install/remove/update logic |

### Session & Workflow Commands
| File | Description |
|------|-------------|
| `.claude/commands/mykit.start.md` | Session purpose prompt |
| `.claude/commands/mykit.specify.md` | Lightweight spec creation |
| `.claude/commands/mykit.plan.md` | Lightweight planning |
| `.claude/commands/mykit.tasks.md` | Task generation |
| `.claude/commands/mykit.implement.md` | Task execution |
| `.claude/commands/mykit.help.md` | Built-in help/documentation |
| `.claude/commands/mykit.resume.md` | Resume interrupted session |
| `.claude/commands/mykit.reset.md` | Clear state, start fresh |
| `.mykit/templates/commands/mykit.start.md` | Template for distribution |
| `.mykit/templates/commands/mykit.specify.md` | Template for distribution |
| `.mykit/templates/commands/mykit.plan.md` | Template for distribution |
| `.mykit/templates/commands/mykit.tasks.md` | Template for distribution |
| `.mykit/templates/commands/mykit.implement.md` | Template for distribution |
| `.mykit/templates/commands/mykit.help.md` | Template for distribution |
| `.mykit/templates/commands/mykit.resume.md` | Template for distribution |
| `.mykit/templates/commands/mykit.reset.md` | Template for distribution |

### Hooks Directory
| File | Description |
|------|-------------|
| `.mykit/hooks/README.md` | Hook documentation and examples |
| `.mykit/hooks/pre-commit.sample` | Sample pre-commit hook |
| `.mykit/hooks/post-pr.sample` | Sample post-PR hook |

### Skills (AI-Powered)
| File | Description |
|------|-------------|
| `.mykit/skills/specify.md` | Generate specifications from guided questions |
| `.mykit/skills/plan.md` | Generate implementation plans from context |
| `.mykit/skills/tasks.md` | Generate task breakdowns from spec/plan |
| `.mykit/skills/describe.md` | Generate PR/release descriptions |
| `.claude/skills/mykit-specify.md` | Installed skill (copied from .mykit/) |
| `.claude/skills/mykit-plan.md` | Installed skill |
| `.claude/skills/mykit-tasks.md` | Installed skill |
| `.claude/skills/mykit-describe.md` | Installed skill |

### Lite Templates
| File | Description |
|------|-------------|
| `.mykit/templates/lite/spec.md` | Spec template |
| `.mykit/templates/lite/plan.md` | Plan template |
| `.mykit/templates/lite/tasks.md` | Tasks template |

---

## Files to Modify

| File | Changes |
|------|---------|
| `.claude/commands/mykit.init.md` | Suggest /mykit.start as entry point |
| `.claude/commands/mykit.backlog.md` | Add --create flag, issue template integration |
| `.claude/commands/mykit.status.md` | Enhanced dashboard, --brief and --json flags |
| `.claude/commands/mykit.commit.md` | Add validation gates (R7), --force flag |
| `.claude/commands/mykit.pr.md` | Add validation gates (R7), --force flag |
| `.claude/commands/mykit.validate.md` | Integrate with validation gates |
| `.mykit/scripts/utils.sh` | Add session state helpers, hook runner |
| `.mykit/config.json` | Add hooks configuration section |
| `CLAUDE.md` | Document new workflow, commands, and requirements |

## Files to Delete/Deprecate

| File | Reason |
|------|--------|
| `script_install.sh` | Replaced by `install.sh` (curl-based) |
| `script_update.sh` | Replaced by `/mykit.upgrade` command |
| `.claude/commands/mykit.quickfix.md` | Replaced by `/mykit.start` option [3] Quick fix |
| `.mykit/templates/commands/mykit.quickfix.md` | Replaced by `/mykit.start` option [3] Quick fix |

---

## Installation Architecture

### Current State

My Kit installation (`script_install.sh`) optionally installs Spec Kit:
```bash
INSTALL_SPECKIT=true bash script_install.sh
```

**Problems**:
- Coupling makes it hard to upgrade Spec Kit independently
- Requires cloning repo first (multiple steps)
- Not user-friendly for public distribution

---

### Proposed: Curl + Command-Based Management

**Install** (first time):
```bash
curl -fsSL https://raw.githubusercontent.com/mayknxyz/my-kit/main/install.sh | bash
```

**Upgrade** (existing users):
```
/mykit.upgrade
```

**Spec Kit** (optional plugin):
```
/mykit.plugin install speckit
/mykit.plugin update speckit
```

---

### Install Script (`install.sh`)

Single curl command installs My Kit:
```bash
curl -fsSL https://raw.githubusercontent.com/mayknxyz/my-kit/main/install.sh | bash
```

**What it does**:
1. Detect current directory (must be a git repo)
2. Download latest My Kit release from GitHub
3. Copy files to project:
   - `.claude/commands/mykit.*.md`
   - `.mykit/scripts/*.sh`
   - `.mykit/templates/`
4. Create default config (`.mykit/config.json`)
5. Display success message and next steps

**Script location**: `install.sh` at repo root (publicly accessible via raw.githubusercontent.com)

---

### Upgrade Command (`/mykit.upgrade`)

Upgrade from within Claude Code:
```
/mykit.upgrade              # Upgrade to latest version
/mykit.upgrade --version 1.2.0   # Upgrade to specific version
/mykit.upgrade --list       # Show available versions
```

**What it does**:
1. Check current version vs latest on GitHub
2. If up to date, report "Already on latest version"
3. If update available:
   - Show changelog summary (what's new)
   - Download latest release (or specified version)
   - Backup current files to `.mykit/backups/`
   - Replace command and script files
   - Preserve user config (`.mykit/config.json`)
4. Report success with version info

**Version pinning** allows:
- Upgrading to specific versions
- Rolling back if latest breaks something
- Listing available versions before upgrading

**Files to create**:
- `.claude/commands/mykit.upgrade.md`
- `.mykit/templates/commands/mykit.upgrade.md`

---

## Implementation Priority

Recommended implementation order:

| Phase | Items | Reason |
|-------|-------|--------|
| **1** | `install.sh`, `/mykit.upgrade` | Foundation - enables public distribution |
| **2** | `/mykit.setup` (onboarding wizard) | First-time user experience (R10) |
| **3** | `/mykit.start`, `/mykit.help`, deprecate `/mykit.quickfix` | Entry point + discoverability |
| **4** | `/mykit.status` (enhanced dashboard) | Visibility into workflow state |
| **5** | `/mykit.resume`, `/mykit.reset` | State recovery (R8) |
| **6** | Validation gates in `/mykit.commit`, `/mykit.pr` | Quality enforcement (R7) |
| **7** | `/mykit.specify`, `/mykit.plan`, `/mykit.tasks` | Lite workflow commands |
| **8** | `/mykit.implement` | Task execution |
| **9** | `/mykit.chain` (command chaining) | Workflow automation (R11) |
| **10** | `/mykit.backlog --create` with issue templates | Issue creation enhancement |
| **11** | Pre/Post hooks infrastructure | Extensibility (R9) |
| **12** | `/mykit.plugin` infrastructure | Plugin system (R12) |
| **13** | Official plugins (`speckit`, `astro-docs`, `svelte-docs`, etc.) | All integrations as plugins |

**Rationale**:
1. Installation first (distribution)
2. Onboarding (first-time experience)
3. Core UX (entry, help, status)
4. Reliability (recovery, validation)
5. Features (lite workflow, chaining, hooks)
6. Extensibility (plugins - including Spec Kit)

---

## Open Questions

1. ~~**Should `/mykit.quickfix` be deprecated?**~~ **DECIDED: Yes** - merged into `/mykit.start` option [3]

2. **Branch naming for ad-hoc work without issue?** Currently uses issue number prefix (e.g., `042-feature-name`). For ad-hoc, use `adhoc-{slug}`?

3. **Should My Kit Lite commands be optional?** Some users may only want Spec Kit workflow.

4. **How to handle switching modes mid-session?** If user starts with ad-hoc but decides they need more structure.

5. **Should `/mykit.specify` pre-fill from GitHub issue body?** Could extract summary/acceptance criteria from issue description.

6. **Spec Kit source location?** Where should `/mykit.speckit install` pull from? Options:
   - GitHub repo (official): `https://github.com/github/spec-kit`
   - Local path (for development): `/path/to/spec-kit`
   - Configurable in `.mykit/config.json`

---

## Discussion Notes

*(Add notes from ongoing discussions here)*

---

## Version History

| Date | Change |
|------|--------|
| 2025-12-03 | Initial plan created |
| 2025-12-03 | Added installation architecture: curl one-liner + /mykit.upgrade |
| 2025-12-03 | Separated Spec Kit as optional add-on via /mykit.speckit |
| 2025-12-03 | Deprecated script_install.sh and script_update.sh |
| 2025-12-03 | Deprecated /mykit.quickfix, merged into /mykit.start option [3] |
| 2025-12-03 | Made /mykit.specify and /mykit.plan optional steps |
| 2025-12-03 | Added version pinning to /mykit.upgrade (--version, --list) |
| 2025-12-03 | Added implementation priority (5 phases) |
| 2025-12-03 | Added Requirements section (R1-R5): GitHub Issue mandatory for all work |
| 2025-12-03 | Added R6: Explicit execution - commands require --run flag to execute |
| 2025-12-03 | Added R7: Validation gates before critical steps |
| 2025-12-03 | Added R8: State recovery (/mykit.resume, /mykit.reset) |
| 2025-12-03 | Added R9: Pre/Post hooks for extensibility |
| 2025-12-03 | Added /mykit.status dashboard enhancement |
| 2025-12-03 | Added /mykit.help command |
| 2025-12-03 | Added issue templates integration for /mykit.backlog --create |
| 2025-12-03 | Added R10: Plugin system - framework support via /mykit.plugin |
| 2025-12-03 | Removed /mykit.speckit - Spec Kit now installed as plugin |
| 2025-12-03 | Added Existing Features Inventory from v0.3.0 codebase review |
| 2025-12-03 | Added Architecture: Hybrid Scripts + Skills approach |
| 2025-12-03 | Added R10: Onboarding wizard (/mykit.setup) |
| 2025-12-03 | Added R11: Command chaining (/mykit.chain, /mykit.ship, etc.) |
| 2025-12-03 | Updated implementation priority to 13 phases |

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Code quality validation command (`/mykit.validate`) with shellcheck and markdownlint integration
- Conventional commit command (`/mykit.commit`) with automatic CHANGELOG.md updates
- Pull request command (`/mykit.pr`) with comprehensive validation gates and rich descriptions
- Validation infrastructure (`validation.sh`) for code quality checks
- Git operations infrastructure (`git-ops.sh`) for commit and CHANGELOG management
- Task completion validation in `utils.sh` for workflow gate checking

### Features
- **Validation Gates (Blueprint Phase 6 - R7)**:
  - Gate 1: All tasks must be complete before PR creation
  - Gate 2: Code validation must pass before PR creation
  - Gate 3: At least one commit must exist on branch
  - Force flag (`--force`) to bypass gates with warnings
- **Code Quality Validation**:
  - shellcheck integration for shell script linting
  - markdownlint integration for markdown file validation
  - Graceful degradation when tools are missing
  - Results stored in state.json for other commands
- **Conventional Commits**:
  - Interactive prompts for commit type, description, and scope
  - Automatic CHANGELOG.md updates with proper sectioning
  - Support for feat, fix, docs, refactor, test, chore, perf, style
  - Preview mode showing changes and suggested commit type
- **Pull Request Creation**:
  - Rich PR descriptions generated from spec.md, plan.md, and commits
  - Automatic issue linking with "Closes #N"
  - GitHub CLI integration for PR creation
  - Comprehensive error messages with remediation steps
- **Infrastructure**:
  - validation.sh: Tool detection, script/markdown validation, result formatting
  - git-ops.sh: Uncommitted changes checking, commit creation, branch operations
  - utils.sh enhancements: Task checking, state management, jq helpers

### Files
- `.claude/commands/mykit.validate.md` - Validation command implementation
- `.claude/commands/mykit.commit.md` - Commit command implementation
- `.claude/commands/mykit.pr.md` - Pull request command implementation
- `.mykit/scripts/validation.sh` - Validation infrastructure (370 lines)
- `.mykit/scripts/git-ops.sh` - Git operations infrastructure (483 lines)
- `.mykit/scripts/utils.sh` - Enhanced utilities (338 lines)
- `.mykit/templates/commands/*.md` - Templates for distribution
- `specs/013-validation-gates/` - Feature specification and design documents

## [0.12.0] - 2025-12-09

### Added
- Task execution command (`/mykit.implement`) for working through tasks.md systematically
- Dashboard mode (no action) showing progress percentage, current task, and next task
- Run mode (`run` action) for autonomous task execution with auto-complete on success
- Complete mode (`complete` action) for manual task completion
- Skip mode (`skip` action) for bypassing blocked tasks with `[~]` marker

### Features
- Extended checkbox markers: `[ ]` pending, `[>]` in-progress, `[x]` complete, `[~]` skipped
- Autonomous task execution based on task type (commands, code changes, documentation)
- Dual state persistence in tasks.md (visual) and state.json (workflow context)
- Resume logic for interrupted sessions (picks up in-progress task)
- Phase transition messaging (implementation → completion tasks)
- Skipped tasks reminder when all other tasks complete
- Progress bar visualization with completion percentage
- Comprehensive error handling for all edge cases

### Files
- `.claude/commands/mykit.implement.md` - Slash command implementation (675 lines)
- `.mykit/templates/commands/mykit.implement.md` - Template for distribution
- `specs/012-task-execution/` - Feature specification and design documents

## [0.11.0] - 2025-12-07

### Added
- Task generation command (`/mykit.tasks`) for creating task breakdowns from specs/plans
- Preview mode showing proposed tasks without creating files
- Execute mode (`create` action) to write tasks file to `specs/{branch}/tasks.md`
- Guided conversation fallback with 3 questions when no spec/plan exists
- Force flag (`--force`) to overwrite existing tasks without confirmation

### Features
- Artifact detection (spec.md, plan.md) with priority-based task extraction
- User story extraction from spec with priority ordering (P1, P2, P3)
- Implementation phases extraction from plan
- Automatic completion tasks appending (validate, commit, PR)
- Task count bounds: 5-15 implementation tasks at 30min-2hr granularity
- Speckit conflict detection redirecting to `/speckit.tasks` when appropriate
- State updates to `.mykit/state.json` with `tasks_path` and `workflow_step: "tasks"`
- AskUserQuestion integration for guided conversation and overwrite confirmation

### Files
- `.claude/commands/mykit.tasks.md` - Slash command implementation (409 lines)
- `.mykit/templates/commands/mykit.tasks.md` - Template for distribution
- `specs/011-task-generation/` - Feature specification and design documents

## [0.10.0] - 2025-12-07

### Added
- Lightweight plan command (`/mykit.plan`) for creating implementation plans from specifications
- Preview mode showing proposed plan content without creating files
- Execute mode (`create` action) to write plan file to `specs/{branch}/plan.md`
- Guided conversation for technical decisions (0-5 questions based on spec analysis)
- Force flag (`--force`) to overwrite existing plans without confirmation

### Features
- Three mandatory plan sections: Technical Context, Design Decisions, Implementation Phases
- Spec analysis to identify technology choices, integrations, and ambiguities
- AskUserQuestion integration for technical decision prompts with options
- Mutual exclusivity check with `/speckit.plan` workflow (prevents mixing workflows)
- State updates to `.mykit/state.json` with `plan_path` and `workflow_step: "planning"`
- Clear error messages for missing prerequisites (no git repo, no feature branch, no spec file)

### Files
- `.claude/commands/mykit.plan.md` - Slash command implementation
- `docs/COMMANDS.md` - Updated command documentation with detailed usage
- `specs/010-lightweight-plan/` - Feature specification and design documents

## [0.9.0] - 2025-12-07

### Added
- Lightweight spec command (`/mykit.specify`) for creating feature specifications
- Preview mode showing proposed spec content without creating files
- Execute mode (`create` action) to write spec file to `specs/{branch}/spec.md`
- GitHub issue extraction for issues with 50+ character body content
- Guided conversation fallback with 3 questions: summary, problem, acceptance criteria
- No-issue flag (`--no-issue`) for ad-hoc specs without linked GitHub issues
- Force flag (`--force`) to overwrite existing specs without confirmation

### Features
- Automatic section extraction from issue body (Summary, Problem, Acceptance Criteria)
- Pattern matching for common markdown heading variations (Description, Why, Checklist, etc.)
- State updates to `.mykit/state.json` with `spec_path` and `workflow_step`
- AskUserQuestion integration for guided conversation and overwrite confirmation
- Non-blocking GitHub API failure handling (warns and proceeds with conversation)

### Files
- `.claude/commands/mykit.specify.md` - Slash command implementation
- `docs/COMMANDS.md` - Updated command documentation with detailed usage
- `specs/009-lightweight-spec/` - Feature specification and design documents

## [0.8.0] - 2025-12-06

### Added
- Reset command (`/mykit.reset`) for clearing workflow state and starting fresh
- Preview mode showing state file contents and what will be cleared/preserved
- Execute mode (`run` action) to delete `.mykit/state.json`
- Semantic flags (`--keep-branch`, `--keep-specs`) for explicit preservation confirmation
- Force flag (`--force`) to skip preview and execute immediately

### Features
- State file existence detection with graceful "no state to reset" handling
- State file content display (branch, lastCommand, workflowStage, timestamp)
- Preservation confirmation for spec files, current branch, and config file
- Combined flags support for power users
- Error handling for permission denied and file system failures

### Files
- `.claude/commands/mykit.reset.md` - Slash command implementation
- `specs/008-reset-state/` - Feature specification and design documents

## [0.7.0] - 2025-12-06

### Added
- Resume session command (`/mykit.resume`) for restoring workflow context after interruptions
- Session state display showing branch, timestamp, workflow stage, and session type
- Next command suggestion based on workflow stage and uncommitted changes
- State validation with warnings for stale state, branch mismatch, and project mismatch

### Features
- Project ID generation using SHA-256 hash of git remote URL (with fallback to git directory path)
- 7-day staleness threshold for state freshness detection
- Branch existence validation via `git branch --list`
- Graceful handling of missing or corrupted state files
- Read-only command that executes immediately (no action parameter required)

### Files
- `.claude/commands/mykit.resume.md` - Slash command implementation
- `specs/007-resume-session/` - Feature specification and design documents

## [0.6.0] - 2025-12-06

### Added
- Enhanced status dashboard (`/mykit.status`) displaying feature context, workflow phase, file status, and next step suggestion
- Feature context section showing current branch and linked GitHub issue details
- Workflow phase detection based on spec.md/plan.md/tasks.md existence
- File status visibility with staged/unstaged distinction and 10-file display limit
- Next command suggestion based on current workflow state and uncommitted changes

### Features
- Git branch detection with detached HEAD state handling
- Issue number extraction from branch pattern `{number}-{slug}`
- GitHub CLI integration for issue title and state lookup with graceful degradation
- Status code mapping (M, A, D, R, ??) to human-readable labels
- Suggestion logic state machine for context-aware command recommendations

### Files
- `.claude/commands/mykit.status.md` - Slash command implementation
- `docs/COMMANDS.md` - Updated command documentation

## [0.5.0] - 2025-12-06

### Added
- Help command (`/mykit.help`) for command documentation and workflow guidance
- Command overview mode showing all 17 commands grouped by category
- Specific command help mode (`/mykit.help <command>`) with usage, actions, flags, examples
- Workflow cheatsheets mode (`/mykit.help workflow`) for Full, Lite, and Quick Fix workflows
- Unknown command error handling with list of available commands
- Stub detection showing implementation status for each command

### Features
- Three help modes based on argument: empty (overview), command name (detail), "workflow" (cheatsheets)
- Categorized command tables: Read-Only, Workflow, Issue & Branch, Lite Workflow, Quality & Commit, Management
- Flag reference with short aliases
- Workflow decision guide for choosing the right workflow

### Files
- `.claude/commands/mykit.help.md` - Slash command implementation

## [0.4.0] - 2025-12-05

### Added
- Session purpose prompt (`/mykit.start`) for workflow type selection
- Three workflow options: Full workflow (Spec Kit), Lite workflow (My Kit), Quick fix
- Chat-based selection via number (1, 2, 3) or name (full, lite, quickfix)
- In-memory session state (`session.type`) for downstream command behavior
- Automatic direction to `/mykit.backlog` after selection

### Features
- `AskUserQuestion` tool integration for interactive selection
- Invalid input handling with re-prompt guidance
- Session-scoped state (resets when Claude Code session ends)
- Always-prompt behavior (no remembered defaults)

### Files
- `.claude/commands/mykit.start.md` - Slash command implementation

## [0.3.0] - 2025-12-05

### Added
- Interactive setup wizard (`/mykit.setup`) for onboarding configuration
- Preview mode showing current or default configuration values
- Five-step wizard flow: GitHub auth, default branch, PR preferences, validation settings, release settings
- Atomic config file writes with temp file pattern for interruption safety
- Config pre-population when re-running wizard with existing configuration
- Partial config detection with completion guidance

### Features
- GitHub CLI authentication detection with warning for unauthenticated users
- Default branch auto-detection from remote HEAD with fallback to main/master
- Boolean prompts (Y/n, y/N) with sensible defaults
- Version prefix validation (warns on non-standard values)
- Signal trap handler for clean interrupt handling (INT/TERM)
- Help flag (`--help`) with usage documentation

### Files
- `.mykit/scripts/setup-wizard.sh` - Core wizard logic
- `.mykit/config.json` - Generated configuration output

## [0.2.0] - 2025-12-05

### Added
- Self-upgrade command (`/mykit.upgrade`) for in-place updates
- Version utilities (`version.sh`) for version checking and comparison
- Upgrade utilities (`upgrade.sh`) for backup, restore, and installation
- Preview mode showing current version, latest version, and changelog
- Version listing with release dates and current/latest markers
- Version pinning to upgrade or downgrade to specific versions
- Downgrade warnings when targeting older versions

### Features
- Automatic backup before upgrade to `.mykit/backup/.last-backup/`
- Automatic rollback on upgrade failure
- Lock file prevents concurrent upgrade operations
- Cross-platform SHA-256 checksum support (sha256sum/shasum/openssl)
- Modified file detection via manifest comparison
- Configuration preservation (`.mykit/config.json` never overwritten)

### Infrastructure
- Exit codes per CLI interface contract (0-4)
- Dependency validation (curl, git, gh CLI)
- Network error handling with troubleshooting guidance

## [0.1.0] - 2025-12-04

### Added
- Curl-based installer (`install.sh`) for one-line installation
- Stub command files for all `/mykit.*` slash commands
- Shell utility scripts (utils, github-api, git-ops, validation)
- Lite workflow templates (spec, plan, tasks)
- Project constitution defining core principles
- Feature specification workflow (`specs/001-curl-installer/`)

### Infrastructure
- Atomic installation with rollback on failure
- Signal trapping for clean interruption handling
- Prerequisite validation (git, gh CLI, git repository)
- Platform-specific installation guidance

[Unreleased]: https://github.com/mayknxyz/my-kit/compare/v0.12.0...HEAD
[0.12.0]: https://github.com/mayknxyz/my-kit/compare/v0.11.0...v0.12.0
[0.11.0]: https://github.com/mayknxyz/my-kit/compare/v0.10.0...v0.11.0
[0.10.0]: https://github.com/mayknxyz/my-kit/compare/v0.9.0...v0.10.0
[0.9.0]: https://github.com/mayknxyz/my-kit/compare/v0.8.0...v0.9.0
[0.8.0]: https://github.com/mayknxyz/my-kit/compare/v0.7.0...v0.8.0
[0.7.0]: https://github.com/mayknxyz/my-kit/compare/v0.6.0...v0.7.0
[0.6.0]: https://github.com/mayknxyz/my-kit/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/mayknxyz/my-kit/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/mayknxyz/my-kit/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/mayknxyz/my-kit/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/mayknxyz/my-kit/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/mayknxyz/my-kit/releases/tag/v0.1.0

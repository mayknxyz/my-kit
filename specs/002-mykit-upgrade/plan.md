# Implementation Plan: Self-Upgrade Command

**Branch**: `002-mykit-upgrade` | **Date**: 2025-12-04 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/002-mykit-upgrade/spec.md`

## Summary

Implement `/mykit.upgrade` command that enables users to upgrade My Kit from within Claude Code. The command follows the action-based pattern (preview by default, `--run` to execute), supports version listing and pinning, creates backups before upgrade, and preserves user configuration. Implementation uses Bash 4.0+ with curl for downloads, consistent with the existing `install.sh` architecture.

## Technical Context

**Language/Version**: Bash 4.0+ (POSIX-compatible shell script)
**Primary Dependencies**: curl, git, gh CLI (validated at runtime)
**Storage**: File system only (`.claude/commands/`, `.mykit/scripts/`, `.mykit/config.json`)
**Testing**: Manual testing via Claude Code (preview mode, execution mode, error handling)
**Target Platform**: Linux, macOS, Windows (via Git Bash/WSL)
**Project Type**: Single project (CLI toolkit)
**Performance Goals**: Version check < 5 seconds, full upgrade < 30 seconds
**Constraints**: No external dependencies beyond curl/git/gh, offline-capable for backups
**Scale/Scope**: Single-user CLI tool, local installation only

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Evidence |
|-----------|--------|----------|
| I. Spec-First Development | PASS | spec.md created and clarified before this plan |
| II. Issue-Linked Traceability | PASS | Branch `002-mykit-upgrade` links to GitHub Issue #2 |
| III. Explicit Execution | PASS | Command previews by default, `--run` required to execute |
| IV. Validation Gates | PASS | FR-012 validates dependencies before upgrade |
| V. Simplicity | PASS | Reuses existing install.sh patterns, no new abstractions |

**Gate Result**: PASS - No violations. Proceeding to Phase 0.

## Project Structure

### Documentation (this feature)

```text
specs/002-mykit-upgrade/
├── spec.md              # Feature specification (complete)
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (N/A - CLI command)
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (repository root)

```text
.claude/commands/
└── mykit.upgrade.md     # Slash command definition

.mykit/
├── scripts/
│   ├── utils.sh         # Existing utilities (reuse)
│   ├── upgrade.sh       # NEW: Core upgrade logic
│   └── version.sh       # NEW: Version checking utilities
├── config.json          # User configuration (preserved during upgrade)
└── backup/              # NEW: Backup directory (single backup retained)
    └── .last-backup/    # Most recent backup before upgrade
```

**Structure Decision**: Single project structure. New scripts added to `.mykit/scripts/` following existing patterns. Slash command file in `.claude/commands/`.

## Complexity Tracking

> No violations to justify. Implementation follows existing patterns.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| N/A | N/A | N/A |

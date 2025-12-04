# Implementation Plan: Curl-Based Installer

**Branch**: `001-curl-installer` | **Date**: 2025-12-04 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-curl-installer/spec.md`

## Summary

Create a single-file bash installer (`install.sh`) that enables users to install My Kit via curl. The installer validates prerequisites (git, gh CLI, git repository), downloads command and script files from GitHub, creates default configuration, and provides atomic installation with rollback on failure.

## Technical Context

**Language/Version**: Bash 4.0+ (POSIX-compatible shell script)
**Primary Dependencies**: curl, git, gh CLI (validated at runtime)
**Storage**: File system only (`.claude/commands/`, `.mykit/scripts/`, `.mykit/config.json`)
**Testing**: Manual testing via curl execution; shellcheck for static analysis
**Target Platform**: POSIX-compliant systems (Linux, macOS, WSL)
**Project Type**: Single file script (no build required)
**Performance Goals**: Complete installation in under 30 seconds on typical connection
**Constraints**: Must work when piped from curl; no interactive prompts; atomic rollback
**Scale/Scope**: Single installer script (~200-400 lines)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Spec-First Development | ✅ PASS | Specification complete with clarifications |
| II. Issue-Linked Traceability | ✅ PASS | Linked to GitHub Issue #1; branch `001-curl-installer` |
| III. Explicit Execution | N/A | Installer runs immediately (expected behavior for curl pipe) |
| IV. Validation Gates | ✅ PASS | Installer validates prerequisites before file operations |
| V. Simplicity | ✅ PASS | Single bash file, no external dependencies beyond curl/git/gh |

**Gate Result**: PASS - No violations requiring justification.

## Project Structure

### Documentation (this feature)

```text
specs/001-curl-installer/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output (file manifest)
├── quickstart.md        # Phase 1 output (usage guide)
└── tasks.md             # Phase 2 output (/speckit.tasks)
```

### Source Code (repository root)

```text
install.sh               # Main installer script (curl target)

.claude/commands/        # Downloaded by installer
└── mykit.*.md           # Slash command files

.mykit/
├── config.json          # Created by installer (if not exists)
├── scripts/             # Downloaded by installer
│   └── *.sh             # Shell utilities
└── templates/           # Downloaded by installer
    └── ...              # Template files
```

**Structure Decision**: Single file at repository root (`install.sh`) with no additional source directories. The installer downloads existing files from the repository; it does not create new source structure.

## Complexity Tracking

> No violations to justify - implementation follows Simplicity principle.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| (none) | - | - |

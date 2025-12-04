# Implementation Plan: /mykit.setup - Onboarding Wizard

**Branch**: `003-setup-wizard` | **Date**: 2025-12-05 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/003-setup-wizard/spec.md`

## Summary

Implement an interactive setup wizard that guides users through configuring My Kit preferences. The wizard runs automatically on first `/mykit.init` when no config exists, or manually via `/mykit.setup run`. It collects GitHub auth status, default branch, PR preferences (auto-assign, draft mode), validation settings (auto-fix), and release settings (version prefix), then writes a valid `.mykit/config.json`.

## Technical Context

**Language/Version**: Bash 4.0+ (POSIX-compatible shell script)
**Primary Dependencies**: curl, git, gh CLI (validated at runtime)
**Storage**: File system only (`.mykit/config.json`)
**Testing**: Manual testing via Claude Code command execution
**Target Platform**: Linux, macOS (any system with Bash 4.0+)
**Project Type**: Single project (CLI toolkit)
**Performance Goals**: Wizard completes in under 2 minutes (user interaction time)
**Constraints**: No external dependencies beyond curl, git, gh; must work offline for non-GitHub settings
**Scale/Scope**: Single-user CLI tool, one config file per repository

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Evidence |
|-----------|--------|----------|
| I. Spec-First Development | PASS | spec.md created and clarified before planning |
| II. Issue-Linked Traceability | PASS | Branch `003-setup-wizard` matches Issue #3 |
| III. Explicit Execution | PASS | `/mykit.setup` previews, `/mykit.setup run` executes |
| IV. Validation Gates | PASS | FR-001 validates gh auth before GitHub settings |
| V. Simplicity | PASS | Minimal config options, no over-engineering |

**Gate Result**: PASS - No violations requiring justification.

## Project Structure

### Documentation (this feature)

```text
specs/003-setup-wizard/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (N/A - no API)
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (repository root)

```text
.claude/commands/
└── mykit.setup.md       # Slash command definition (update existing stub)

.mykit/
├── scripts/
│   └── setup-wizard.sh  # Core wizard logic (new)
└── config.json          # Generated config file (output)
```

**Structure Decision**: Single project structure. The wizard is a Bash script invoked by the existing Claude Code slash command pattern. No new directories needed beyond adding `setup-wizard.sh` to `.mykit/scripts/`.

## Complexity Tracking

> No violations to justify - all gates passed.

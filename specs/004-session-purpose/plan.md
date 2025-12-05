# Implementation Plan: Session Purpose Prompt (/mykit.start)

**Branch**: `004-session-purpose` | **Date**: 2025-12-05 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/004-session-purpose/spec.md`

## Summary

Implement the `/mykit.start` command that prompts users to select their workflow type at the beginning of each session. The command presents three options (Full workflow, Lite workflow, Quick fix), accepts chat-based selection, stores the choice in-memory as `session.type`, and directs users to `/mykit.backlog`.

## Technical Context

**Language/Version**: Markdown + Claude Code slash command pattern (no external runtime)
**Primary Dependencies**: Claude Code `AskUserQuestion` tool for chat-based selection
**Storage**: In-memory session state (Claude Code conversation context)
**Testing**: Manual testing via Claude Code CLI
**Target Platform**: Claude Code CLI (cross-platform)
**Project Type**: Single project (slash command)
**Performance Goals**: N/A (interactive CLI command)
**Constraints**: Must complete workflow selection in <30 seconds
**Scale/Scope**: Single-user CLI tool

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Spec-First Development | ✅ PASS | Specification created before implementation |
| II. Issue-Linked Traceability | ✅ PASS | Linked to GitHub Issue #4, branch follows `{issue-number}-{slug}` pattern |
| III. Explicit Execution | ✅ PASS | Command is read-only (displays prompt), state change requires user selection |
| IV. Validation Gates | ✅ PASS | No gates required for this command (session initialization) |
| V. Simplicity | ✅ PASS | Single markdown file, no external dependencies, in-memory state |

**Gate Result**: PASS - Proceeding to Phase 0

## Project Structure

### Documentation (this feature)

```text
specs/004-session-purpose/
├── spec.md              # Feature specification
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (N/A for this feature)
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (repository root)

```text
.claude/commands/
└── mykit.start.md       # Slash command implementation (exists, needs update)
```

**Structure Decision**: This is a slash command-only feature. Implementation lives entirely in `.claude/commands/mykit.start.md`. No additional source files, scripts, or storage are needed. Session state is maintained in Claude Code's conversation context.

## Complexity Tracking

No violations. Implementation follows simplest possible approach:
- Single markdown file update
- No external dependencies
- No file storage
- No scripts required

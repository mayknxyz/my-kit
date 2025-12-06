# Implementation Plan: /mykit.reset - Clear State

**Branch**: `008-reset-state` | **Date**: 2025-12-06 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/008-reset-state/spec.md`

## Summary

Implement the `/mykit.reset` command to clear My Kit workflow state, enabling developers to start fresh. The command deletes `.mykit/state.json` and clears in-memory session state. Follows My Kit's action pattern: preview by default, explicit `run` action to execute. Supports `--keep-branch` and `--keep-specs` flags for selective preservation, and `--force` for immediate execution.

## Technical Context

**Language/Version**: Markdown + Claude Code slash command pattern (no external runtime)
**Primary Dependencies**: Claude Code file system access, git CLI (for branch info only)
**Storage**: `.mykit/state.json` (file deletion), in-memory conversation context
**Testing**: Manual testing via Claude Code slash command invocation
**Target Platform**: Claude Code CLI environment
**Project Type**: Single project - slash command definition
**Performance Goals**: Reset completes in under 5 seconds (SC-001)
**Constraints**: Atomic operation - no partial state left (SC-002)
**Scale/Scope**: Single-user CLI tool, operates on local repository

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Evidence |
|-----------|--------|----------|
| I. Spec-First Development | ✅ PASS | Spec created via `/speckit.specify`, clarified via `/speckit.clarify` |
| II. Issue-Linked Traceability | ✅ PASS | Linked to GitHub Issue #8, branch `008-reset-state` |
| III. Explicit Execution | ✅ PASS | Preview by default, `run` action required for state change |
| IV. Validation Gates | ✅ PASS | No gates apply (reset is a cleanup operation, not progression) |
| V. Simplicity | ✅ PASS | Single file deletion, no abstractions, follows existing command patterns |

**Command Convention Compliance**:
- Pattern: `/mykit.reset [run] [--keep-branch] [--keep-specs] [--force]`
- Read-only (preview): `/mykit.reset` - shows what would be cleared
- State-changing: `/mykit.reset run` - executes the reset
- Standard flags: `--force` (bypass preview), future: `--json` (machine output)

**Gate Result**: ✅ ALL GATES PASS - Proceed to Phase 0

## Project Structure

### Documentation (this feature)

```text
specs/008-reset-state/
├── spec.md              # Feature specification
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (via /speckit.tasks)
```

### Source Code (repository root)

```text
.claude/commands/
└── mykit.reset.md       # Slash command definition (UPDATE existing stub)

.mykit/
├── state.json           # Target file for deletion (if exists)
└── config.json          # NOT touched by reset (preserved)
```

**Structure Decision**: Update existing `.claude/commands/mykit.reset.md` stub file. No new directories or files required beyond the spec artifacts. The command is self-contained in a single Markdown file following the established pattern used by `mykit.status.md`, `mykit.resume.md`, and other existing commands.

## Complexity Tracking

> No violations - design follows all constitution principles with minimal complexity.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |

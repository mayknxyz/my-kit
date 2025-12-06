# Implementation Plan: Lightweight Spec Command

**Branch**: `009-lightweight-spec` | **Date**: 2025-12-07 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/009-lightweight-spec/spec.md`

## Summary

Implement `/mykit.specify` as a Claude Code slash command that creates lightweight specifications through an AI-guided workflow. The command extracts content from linked GitHub issues when available (50+ character body), or guides users through a 3-question conversational flow. Supports preview mode (no action) and execution mode (`create` action) per the explicit execution principle.

## Technical Context

**Language/Version**: Markdown (Claude Code slash command) + Bash 4.0+ (helper scripts)
**Primary Dependencies**: Claude Code conversation context, `gh` CLI (GitHub), `git` CLI
**Storage**: File system (`.mykit/state.json`, `specs/{branch}/spec.md`)
**Testing**: Manual testing via command invocation, acceptance scenario validation
**Target Platform**: Any platform running Claude Code with access to shell
**Project Type**: Single project (CLI tool)
**Performance Goals**: Command execution under 5 seconds (excluding user input)
**Constraints**: Non-blocking on GitHub API failure, must preserve session state for recovery
**Scale/Scope**: Single-user CLI workflow tool

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Evidence |
|-----------|--------|----------|
| I. Spec-First Development | **PASS** | This command creates specs; follows the pattern |
| II. Issue-Linked Traceability | **PASS** | Requires issue selection unless `--no-issue` flag; creates spec in `specs/{branch}/` |
| III. Explicit Execution | **PASS** | Preview mode (no action) vs execution mode (`create` action) implemented |
| IV. Validation Gates | **PASS** | FR-005 requires issue selection; FR-010 handles existing files |
| V. Simplicity | **PASS** | 3-question conversation, reuses existing patterns from `/mykit.start` |

**Gate Result**: All principles satisfied. No violations requiring justification.

## Project Structure

### Documentation (this feature)

```text
specs/009-lightweight-spec/
├── spec.md              # Feature specification (done)
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
└── mykit.specify.md     # Slash command implementation (update existing stub)

.mykit/
├── state.json           # Workflow state (existing, will be updated)
└── templates/
    └── lite/
        └── spec.md      # Lite spec template (existing)
```

**Structure Decision**: Updates existing files only. The slash command pattern established by `/mykit.start` and `/mykit.status` will be followed. No new directories or structural changes required.

## Complexity Tracking

> No violations to justify. Implementation follows existing patterns.

| Aspect | Decision | Rationale |
|--------|----------|-----------|
| No new scripts | Slash command only | Follows AI skill pattern; shell scripts reserved for deterministic ops |
| Reuses AskUserQuestion | Standard Claude Code tool | Consistent with `/mykit.start` implementation |
| State via .mykit/state.json | Existing mechanism | No new storage infrastructure needed |

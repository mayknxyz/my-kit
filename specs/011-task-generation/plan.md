# Implementation Plan: /mykit.tasks - Task Generation

**Branch**: `011-task-generation` | **Date**: 2025-12-07 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/011-task-generation/spec.md`

## Summary

Implement the `/mykit.tasks` slash command that generates task breakdowns from existing spec/plan documents or via guided conversation. The command follows the established My Kit pattern: preview by default, execute with `create` action, and integrates with `.mykit/state.json` for workflow tracking.

## Technical Context

**Language/Version**: Markdown (Claude Code slash command pattern)
**Primary Dependencies**: Claude Code conversation context, `git` CLI, file system access
**Storage**: File system (`specs/{branch}/tasks.md`, `.mykit/state.json`)
**Testing**: Manual testing via Claude Code session (acceptance scenario verification)
**Target Platform**: Claude Code CLI (cross-platform)
**Project Type**: Single command file + optional helper scripts
**Performance Goals**: Task generation under 30 seconds (existing artifacts), under 3 minutes (guided conversation)
**Constraints**: Works offline (no GitHub API required), must integrate with `/mykit.implement`
**Scale/Scope**: Single slash command, generates 5-15 tasks per feature

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Evidence |
|-----------|--------|----------|
| I. Spec-First Development | ✅ PASS | Feature has spec.md completed and clarified |
| II. Issue-Linked Traceability | ✅ PASS | Branch `011-task-generation` linked to GitHub Issue #11 |
| III. Explicit Execution | ✅ PASS | Command uses preview by default, `create` action for execution |
| IV. Validation Gates | ✅ PASS | FR-007 validates feature branch, FR-008 detects speckit conflicts |
| V. Simplicity | ✅ PASS | Single command file, reuses existing patterns from /mykit.specify and /mykit.plan |

**Gate Result**: PASS - No violations requiring justification.

## Project Structure

### Documentation (this feature)

```text
specs/011-task-generation/
├── spec.md              # Feature specification (complete)
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # N/A - no API contracts needed
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (repository root)

```text
.claude/commands/
└── mykit.tasks.md       # Primary implementation (slash command)

.mykit/templates/commands/
└── mykit.tasks.md       # Template for distribution
```

**Structure Decision**: Single command file pattern, matching existing `/mykit.specify.md` and `/mykit.plan.md` structure. No helper scripts required as this is a pure AI skill.

## Design Decisions

### DD-001: Command Implementation Pattern

**Choice**: Follow the exact pattern established by `/mykit.specify` and `/mykit.plan` commands
**Rationale**: Consistency across My Kit commands improves user experience and maintainability. The existing commands provide a proven template for argument parsing, prerequisite checks, preview/execute modes, and state updates.

### DD-002: Task Generation Algorithm

**Choice**: AI-driven analysis with structured output format
**Rationale**: Claude Code's conversation context enables intelligent task extraction from documentation. The AI can understand context, prioritize P1 user stories, and generate appropriately-sized tasks (30min-2hr granularity).

### DD-003: Guided Conversation Structure

**Choice**: 3 focused questions when no artifacts exist
**Rationale**: Per spec clarification, this balances context gathering without overwhelming users who chose to skip formal specification.

### DD-004: Integration with /mykit.implement

**Choice**: Generate tasks.md with checkbox format (`- [ ] T001 ...`) and task numbering
**Rationale**: This format enables `/mykit.implement` to track progress and mark tasks complete. Task IDs (T001, T002) provide reference points for discussion and status updates.

## Implementation Phases

### Phase 1: Core Command Structure

Implement the base command file with:
- Argument parsing (`create`, `--force`)
- Git repository and feature branch validation
- Spec/plan detection logic
- Preview vs execute mode handling

**Key Files**:
- `.claude/commands/mykit.tasks.md`

### Phase 2: Task Generation from Artifacts

Implement task extraction when spec/plan exists:
- Read and analyze spec.md content
- Read and analyze plan.md content (if exists)
- Extract user stories, requirements, and phases
- Generate ordered task list with T### numbering
- Append standard completion tasks

**Key Logic**:
- Prioritize P1 user stories
- Align with plan phases if plan.md exists
- Target 5-15 implementation tasks
- Each task ~30min-2hr of work

### Phase 3: Guided Conversation Mode

Implement fallback when no artifacts exist:
- Detect missing spec/plan files
- Ask 3 guided questions using AskUserQuestion tool
- Generate tasks from answers

**Questions**:
1. What needs to be built or changed?
2. What components or files are affected?
3. What defines "done" for this work?

### Phase 4: State Management and Output

Implement file writing and state updates:
- Write tasks.md to `specs/{branch}/`
- Update `.mykit/state.json` with task metadata
- Handle existing file overwrite confirmation
- Display completion message with next steps

### Phase 5: Template Distribution

Create template for distribution:
- Copy command to `.mykit/templates/commands/`
- Ensure installer copies to target repos

## Success Criteria Reference

| Criterion | How Addressed |
|-----------|---------------|
| SC-001: Under 30 seconds (artifacts) | AI-driven extraction without external API calls |
| SC-002: Under 3 minutes (guided) | Only 3 questions, direct generation |
| SC-003: 100% completion tasks | Always appended regardless of source |
| SC-004: /mykit.implement integration | Checkbox format with T### numbering |
| SC-005: Preview clarity | Clear PREVIEW header and next steps |
| SC-006: No manual reformatting | Consistent template-based output |

# Implementation Plan: /mykit.implement - Task Execution

**Branch**: `012-task-execution` | **Date**: 2025-12-09 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/012-task-execution/spec.md`

## Summary

Implement the `/mykit.implement` command that enables developers to execute tasks from tasks.md one by one. The command provides autonomous task execution with Claude Code, automatic progress tracking, and workflow guidance through the implementation → validation → commit → PR sequence.

## Technical Context

**Language/Version**: Markdown (Claude Code slash command pattern) - no external runtime
**Primary Dependencies**: Claude Code conversation context, git CLI, file system access
**Storage**: File system (`specs/{branch}/tasks.md`, `.mykit/state.json`)
**Testing**: Manual acceptance testing (Claude Code commands)
**Target Platform**: Claude Code CLI (cross-platform)
**Project Type**: Single project - slash command file
**Performance Goals**: N/A (interactive command)
**Constraints**: Must integrate with existing mykit command patterns
**Scale/Scope**: Single command file with 4 user actions (run, complete, skip, status)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Evidence |
|-----------|--------|----------|
| I. Spec-First Development | PASS | Spec created via `/speckit.specify`, clarified via `/speckit.clarify` |
| II. Issue-Linked Traceability | PASS | Branch `012-task-execution` linked to GitHub Issue #12 |
| III. Explicit Execution | PASS | Preview mode (no action), execution requires `run`/`complete`/`skip` actions |
| IV. Validation Gates | PASS | Feature branch validation (FR-009), tasks.md existence check |
| V. Simplicity | PASS | Single command file, follows existing mykit.tasks.md pattern |

**Gate Result**: All principles satisfied. Proceeding to Phase 0.

## Project Structure

### Documentation (this feature)

```text
specs/012-task-execution/
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
└── mykit.implement.md   # Command implementation (update existing stub)

.mykit/
├── state.json           # Workflow state (existing, to be updated)
└── templates/commands/
    └── mykit.implement.md  # Template distribution
```

**Structure Decision**: Update existing `.claude/commands/mykit.implement.md` stub file. No new directories needed. Follows established mykit command pattern.

## Complexity Tracking

> No violations. Implementation follows existing patterns.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |

## Design Decisions

### DD-001: Task State Representation in tasks.md

**Choice**: Use markdown checkbox syntax with extensions
- `- [ ]` = pending
- `- [>]` = in-progress (new marker)
- `- [x]` = complete
- `- [~]` = skipped

**Rationale**: Extends standard markdown checkboxes, visually distinct, compatible with existing tasks.md format from `/mykit.tasks`.

**Alternative Rejected**: Separate state.json tracking only - would lose visual progress in tasks.md file.

### DD-002: Autonomous Execution Model

**Choice**: Claude Code reads task description and autonomously executes (write code, run commands)

**Rationale**: Per clarification session - developers want hands-off execution with auto-complete on success.

**Alternative Rejected**: Manual execution (display task, wait for user) - adds friction, doesn't leverage Claude Code capabilities.

### DD-003: State Persistence

**Choice**: Dual tracking - tasks.md for visual progress, state.json for current task context

**State.json additions**:
```json
{
  "current_task": "T005",
  "task_status": "in-progress",
  "tasks_path": "specs/012-task-execution/tasks.md"
}
```

**Rationale**: tasks.md provides human-readable progress; state.json enables session resumption.

### DD-004: Command Actions

**Choice**: Four actions aligned with task lifecycle
- No action: Display progress dashboard (read-only)
- `run`: Execute next/current task
- `complete`: Manually mark current task complete
- `skip`: Skip current task and move to next

**Rationale**: Covers all user stories from spec; follows mykit convention (no-action = preview/status).

## Implementation Phases

### Phase 1: Core Infrastructure (Setup)

Create command skeleton with prerequisite checks:
- Git repository validation
- Feature branch detection
- Argument parsing (run, complete, skip, --force)
- Path determination (tasks.md, state.json)

### Phase 2: Progress Dashboard (US3 - Read-Only)

Implement no-action mode:
- Parse tasks.md for task states
- Calculate completion percentage
- Display progress summary with current/next task
- Handle missing tasks.md error

### Phase 3: Task Execution (US1 - MVP)

Implement `run` action:
- Read tasks.md and find first incomplete task
- Mark task as in-progress (update tasks.md with `[>]`)
- Update state.json with current task context
- Autonomously execute task (Claude Code writes code/runs commands)
- On success: auto-complete and proceed to next task
- On failure: keep in-progress, report failure, await user action

### Phase 4: Task Completion (US2)

Implement `complete` action:
- Validate task is in-progress
- Update tasks.md: `[>]` → `[x]`
- Update state.json
- Display next task or completion message
- Handle completion tasks (validation, commit, PR)

### Phase 5: Task Skip (US4)

Implement `skip` action:
- Validate task is in-progress
- Update tasks.md: `[>]` → `[~]`
- Update state.json
- Move to next task
- Track skipped tasks for completion reminder

### Phase 6: Polish & Distribution

- Error handling table
- Example outputs
- Related commands section
- Copy to templates for distribution

# Tasks: Session Purpose Prompt (/mykit.start)

**Input**: Design documents from `/specs/004-session-purpose/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, quickstart.md

**Tests**: Manual testing only (per plan.md). No automated test tasks included.

**Organization**: Tasks organized by user story to enable incremental validation.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Single file**: `.claude/commands/mykit.start.md` (slash command implementation)
- No additional source files, scripts, or storage needed

---

## Phase 1: Setup

**Purpose**: Prepare the command file structure

- [x] T001 Read existing stub at .claude/commands/mykit.start.md to understand current structure
- [x] T002 Review similar commands (e.g., .claude/commands/mykit.setup.md) for pattern reference

---

## Phase 2: Foundational (Core Command Structure)

**Purpose**: Implement the base command structure that all user stories share

**⚠️ CRITICAL**: This phase creates the shared prompt structure for all workflow options

- [x] T003 Write command header with usage section in .claude/commands/mykit.start.md
- [x] T004 Write workflow options display section with all three options in .claude/commands/mykit.start.md
- [x] T005 Write selection handling logic section for chat-based input in .claude/commands/mykit.start.md
- [x] T006 Write invalid input handling with re-prompt guidance in .claude/commands/mykit.start.md
- [x] T007 Write direction to /mykit.backlog section in .claude/commands/mykit.start.md

**Checkpoint**: Command structure ready - user story verification can now begin

---

## Phase 3: User Story 1 - Select Full Workflow (Priority: P1) 🎯 MVP

**Goal**: Developer can select "Full workflow (Spec Kit)" and have session.type set to "full"

**Independent Test**: Invoke `/mykit.start`, select option 1, verify confirmation shows "full" and directs to `/mykit.backlog`

### Implementation for User Story 1

- [x] T008 [US1] Add Full workflow option (1) with description "Complex features" in .claude/commands/mykit.start.md
- [x] T009 [US1] Add session.type="full" state instruction for option 1 in .claude/commands/mykit.start.md
- [x] T010 [US1] Add confirmation message for Full workflow selection in .claude/commands/mykit.start.md

**Checkpoint**: User Story 1 (Full workflow) should be fully testable - MVP complete

---

## Phase 4: User Story 2 - Select Lite Workflow (Priority: P2)

**Goal**: Developer can select "Lite workflow (My Kit)" and have session.type set to "lite"

**Independent Test**: Invoke `/mykit.start`, select option 2, verify confirmation shows "lite" and directs to `/mykit.backlog`

### Implementation for User Story 2

- [x] T011 [US2] Add Lite workflow option (2) with description "Simple changes" in .claude/commands/mykit.start.md
- [x] T012 [US2] Add session.type="lite" state instruction for option 2 in .claude/commands/mykit.start.md
- [x] T013 [US2] Add confirmation message for Lite workflow selection in .claude/commands/mykit.start.md

**Checkpoint**: User Stories 1 AND 2 should both be independently testable

---

## Phase 5: User Story 3 - Select Quick Fix (Priority: P3)

**Goal**: Developer can select "Quick fix" and have session.type set to "quickfix"

**Independent Test**: Invoke `/mykit.start`, select option 3, verify confirmation shows "quickfix" and directs to `/mykit.backlog`

### Implementation for User Story 3

- [x] T014 [US3] Add Quick fix option (3) with description "No formal planning" in .claude/commands/mykit.start.md
- [x] T015 [US3] Add session.type="quickfix" state instruction for option 3 in .claude/commands/mykit.start.md
- [x] T016 [US3] Add confirmation message for Quick fix selection in .claude/commands/mykit.start.md

**Checkpoint**: All three workflow options should be fully functional

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final validation and documentation

- [x] T017 Run quickstart.md testing checklist to verify all scenarios
- [x] T018 Verify edge case: invalid input triggers re-prompt
- [x] T019 Verify edge case: each invocation prompts fresh (no remembered state)
- [x] T020 Update command status from "Stub" to implemented in .claude/commands/mykit.start.md

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion
- **User Stories (Phase 3-5)**: Depend on Foundational phase completion
- **Polish (Phase 6)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - Independent of US1
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - Independent of US1/US2

### Task Dependencies

All tasks modify the same file (`.claude/commands/mykit.start.md`), so they should be executed sequentially. No parallel execution within phases.

### Parallel Opportunities

- **None within feature**: Single file implementation
- **Cross-feature**: This feature can be developed in parallel with other features on different branches

---

## Parallel Example: Not Applicable

All tasks modify `.claude/commands/mykit.start.md` - execute sequentially.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (read existing files)
2. Complete Phase 2: Foundational (command structure)
3. Complete Phase 3: User Story 1 (Full workflow option)
4. **STOP and VALIDATE**: Test Full workflow selection independently
5. Feature delivers value with just the primary use case

### Incremental Delivery

1. Complete Setup + Foundational → Command structure ready
2. Add User Story 1 (Full) → Test → MVP complete
3. Add User Story 2 (Lite) → Test → Enhanced
4. Add User Story 3 (Quick fix) → Test → Complete
5. Each story adds a workflow option without breaking previous options

---

## Summary

| Metric | Value |
|--------|-------|
| Total Tasks | 20 |
| Setup Tasks | 2 |
| Foundational Tasks | 5 |
| User Story 1 Tasks | 3 |
| User Story 2 Tasks | 3 |
| User Story 3 Tasks | 3 |
| Polish Tasks | 4 |
| Parallel Opportunities | 0 (single file) |
| MVP Scope | Phases 1-3 (10 tasks) |

---

## Notes

- All tasks modify `.claude/commands/mykit.start.md` - no parallel execution
- Session state is in-memory (Claude Code conversation context) - no file storage
- Manual testing via Claude Code CLI - no automated tests
- Each checkpoint allows independent validation
- Commit after each phase for clean history

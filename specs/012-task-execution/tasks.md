# Tasks: /mykit.implement - Task Execution

**Input**: Design documents from `/specs/012-task-execution/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: User story reference (US1, US2, US3, US4)

---

## Phase 1: Setup

**Purpose**: Initialize the command file structure

- [x] T001 Create command file skeleton at `.claude/commands/mykit.implement.md` with Usage and Description sections

---

## Phase 2: Foundational (Core Command Infrastructure)

**Purpose**: Implement shared prerequisites and validation logic used by all user stories

**CRITICAL**: No user story work can begin until this phase is complete

- [x] T002 Implement Step 1: Git repository prerequisite check in `.claude/commands/mykit.implement.md`
- [x] T003 Implement Step 2: Argument parsing for `run`, `complete`, `skip` actions and `--force` flag in `.claude/commands/mykit.implement.md`
- [x] T004 Implement Step 3: Branch name extraction and feature branch validation (pattern `^([0-9]+)-`) in `.claude/commands/mykit.implement.md`
- [x] T005 Implement Step 4: Path determination (`specs/{branch}/tasks.md`, `.mykit/state.json`) in `.claude/commands/mykit.implement.md`
- [x] T006 Implement Step 5: tasks.md existence check with error message suggesting `/mykit.tasks create` in `.claude/commands/mykit.implement.md`
- [x] T007 Implement Step 6: Task parsing logic - extract tasks with ID, description, status, section from tasks.md in `.claude/commands/mykit.implement.md`
- [x] T008 Implement Step 7: Checkbox marker detection (`[ ]`=pending, `[>]`=in-progress, `[x]`=complete, `[~]`=skipped) in `.claude/commands/mykit.implement.md`

**Checkpoint**: Foundation ready - user story implementation can now proceed

---

## Phase 3: User Story 3 - View Task Progress Dashboard (Priority: P3 - but implemented first as read-only foundation)

**Goal**: Display progress without modifying files - provides read-only foundation for other actions

**Independent Test**: Run `/mykit.implement` (no action) on a feature branch with tasks.md; verify progress summary displays without file modifications

### Implementation for User Story 3

- [x] T009 [US3] Implement no-action detection (when no `run`/`complete`/`skip` argument) in `.claude/commands/mykit.implement.md`
- [x] T010 [US3] Implement progress calculation (total, completed, pending, skipped, percentage) in `.claude/commands/mykit.implement.md`
- [x] T011 [US3] Implement current task detection (first in-progress, or first pending if none in-progress) in `.claude/commands/mykit.implement.md`
- [x] T012 [US3] Implement progress dashboard display format (percentage, current task, next task) in `.claude/commands/mykit.implement.md`
- [x] T013 [US3] Handle edge case: all tasks complete - show completion summary and suggest `/mykit.pr create` in `.claude/commands/mykit.implement.md`

**Checkpoint**: User Story 3 complete - progress dashboard works independently

---

## Phase 4: User Story 1 - Execute Next Available Task (Priority: P1) MVP

**Goal**: Execute tasks autonomously with auto-complete on success

**Independent Test**: Run `/mykit.implement run` on a feature branch with tasks.md containing uncompleted tasks; verify task is marked in-progress, executed, and auto-completed on success

### Implementation for User Story 1

- [x] T014 [US1] Implement `run` action detection in `.claude/commands/mykit.implement.md`
- [x] T015 [US1] Implement find-next-task logic: first in-progress task, or first pending if none in-progress in `.claude/commands/mykit.implement.md`
- [x] T016 [US1] Implement task status update: `[ ]` → `[>]` (mark as in-progress) with file write in `.claude/commands/mykit.implement.md`
- [x] T017 [US1] Implement state.json update with current_task, workflow_step, tasks_path, last_command, last_command_time in `.claude/commands/mykit.implement.md`
- [x] T018 [US1] Implement autonomous task execution instructions (display task, instruct Claude to execute it) in `.claude/commands/mykit.implement.md`
- [x] T019 [US1] Implement auto-complete on success: `[>]` → `[x]` and proceed to next task in `.claude/commands/mykit.implement.md`
- [x] T020 [US1] Implement failure handling: keep in-progress, report failure, display available actions (complete, skip, run to retry) in `.claude/commands/mykit.implement.md`
- [x] T021 [US1] Implement resume logic: if task already in-progress, continue execution rather than starting new in `.claude/commands/mykit.implement.md`

**Checkpoint**: User Story 1 complete - task execution works independently (MVP)

---

## Phase 5: User Story 2 - Mark Task Complete (Priority: P2)

**Goal**: Manually mark current task complete and see next task

**Independent Test**: Run `/mykit.implement complete` after a task is in progress; verify task is marked [x] in tasks.md and next task is displayed

### Implementation for User Story 2

- [x] T022 [US2] Implement `complete` action detection in `.claude/commands/mykit.implement.md`
- [x] T023 [US2] Implement validation: check if a task is currently in-progress, error if not in `.claude/commands/mykit.implement.md`
- [x] T024 [US2] Implement task status update: `[>]` → `[x]` with file write in `.claude/commands/mykit.implement.md`
- [x] T025 [US2] Implement state.json update after completion in `.claude/commands/mykit.implement.md`
- [x] T026 [US2] Implement next task display after completion in `.claude/commands/mykit.implement.md`
- [x] T027 [US2] Implement completion phase transition message (when last implementation task done, highlight completion tasks remain) in `.claude/commands/mykit.implement.md`
- [x] T028 [US2] Implement final completion celebration (when all tasks including completion tasks done) in `.claude/commands/mykit.implement.md`

**Checkpoint**: User Story 2 complete - manual completion works independently

---

## Phase 6: User Story 4 - Skip Current Task (Priority: P3)

**Goal**: Skip blocked tasks and move to next

**Independent Test**: Run `/mykit.implement skip` when a task is in progress; verify task is marked [~] and next task is identified

### Implementation for User Story 4

- [x] T029 [US4] Implement `skip` action detection in `.claude/commands/mykit.implement.md`
- [x] T030 [US4] Implement validation: check if a task is currently in-progress, error if not in `.claude/commands/mykit.implement.md`
- [x] T031 [US4] Implement task status update: `[>]` → `[~]` with file write in `.claude/commands/mykit.implement.md`
- [x] T032 [US4] Implement state.json update after skip in `.claude/commands/mykit.implement.md`
- [x] T033 [US4] Implement next task identification and display after skip in `.claude/commands/mykit.implement.md`
- [x] T034 [US4] Implement skipped tasks reminder when all other tasks complete in `.claude/commands/mykit.implement.md`

**Checkpoint**: User Story 4 complete - task skipping works independently

---

## Phase 7: Polish & Distribution

**Purpose**: Error handling, documentation, and template distribution

- [x] T035 Add Error Handling section with error table (not in git repo, not on feature branch, no tasks.md, invalid format, no in-progress task) in `.claude/commands/mykit.implement.md`
- [x] T036 Add Example Outputs section showing dashboard, run, complete, skip examples in `.claude/commands/mykit.implement.md`
- [x] T037 Add Related Commands section linking to `/mykit.tasks`, `/mykit.status`, `/mykit.validate`, `/mykit.commit`, `/mykit.pr` in `.claude/commands/mykit.implement.md`
- [x] T038 Copy completed command to `.mykit/templates/commands/mykit.implement.md` for distribution
- [x] T039 Run manual acceptance testing for all user story scenarios

---

## Phase 8: Completion

- [ ] T040 Run validation: `/mykit.validate`
- [ ] T041 Create commit: `/mykit.commit create`
- [ ] T042 Create pull request: `/mykit.pr create`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 - BLOCKS all user stories
- **User Story 3 (Phase 3)**: Depends on Phase 2 - read-only foundation
- **User Story 1 (Phase 4)**: Depends on Phase 3 (uses progress/task detection logic) - MVP
- **User Story 2 (Phase 5)**: Depends on Phase 4 (uses run infrastructure)
- **User Story 4 (Phase 6)**: Depends on Phase 4 (uses run infrastructure)
- **Polish (Phase 7)**: Depends on Phases 3-6
- **Completion (Phase 8)**: Depends on Phase 7

### User Story Dependencies

- **User Story 3 (P3)**: After Foundational - provides read-only foundation, no story dependencies
- **User Story 1 (P1)**: After US3 - MVP, core functionality
- **User Story 2 (P2)**: After US1 - uses task update infrastructure
- **User Story 4 (P3)**: After US1 - uses task update infrastructure (can run parallel to US2)

### Parallel Opportunities

Within **Phase 2** (Foundational):
- T002, T003, T004 can run in parallel (different validation concerns)
- T005, T006 can run in parallel (path/detection logic)
- T007, T008 can run in parallel (parsing logic)

Within **User Story 1** (Phase 4):
- T014, T015 can run in parallel (action detection vs task finding)

Between **User Stories**:
- US2 (Phase 5) and US4 (Phase 6) can potentially run in parallel after US1

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001)
2. Complete Phase 2: Foundational (T002-T008)
3. Complete Phase 3: User Story 3 (T009-T013) - read-only dashboard
4. Complete Phase 4: User Story 1 (T014-T021) - task execution
5. **STOP and VALIDATE**: Test with `/mykit.implement run`
6. Deploy/demo if ready - core functionality works

### Incremental Delivery

1. Setup + Foundational → Command structure ready
2. Add User Story 3 → Test progress dashboard → Read-only mode works
3. Add User Story 1 → Test task execution → MVP!
4. Add User Story 2 → Test manual completion → Enhanced control
5. Add User Story 4 → Test skip functionality → Full flexibility
6. Polish + Distribution → Production ready

---

## Summary

| Metric | Value |
|--------|-------|
| Total Tasks | 42 |
| Phase 1 (Setup) | 1 task |
| Phase 2 (Foundational) | 7 tasks |
| Phase 3 (US3 - Dashboard) | 5 tasks |
| Phase 4 (US1 - Execution) | 8 tasks |
| Phase 5 (US2 - Complete) | 7 tasks |
| Phase 6 (US4 - Skip) | 6 tasks |
| Phase 7 (Polish) | 5 tasks |
| Phase 8 (Completion) | 3 tasks |
| Parallel Opportunities | 8 identified |
| MVP Scope | Phases 1-4 (21 tasks) |

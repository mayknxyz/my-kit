# Tasks: /mykit.tasks - Task Generation

**Input**: Design documents from `/specs/011-task-generation/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: User story reference (US1, US2, US3, US4)

---

## Phase 1: Setup

**Purpose**: Initialize the command file structure

- [x] T001 Create command file skeleton at `.claude/commands/mykit.tasks.md` with Usage and Description sections

---

## Phase 2: Foundational (Core Command Infrastructure)

**Purpose**: Implement shared prerequisites and validation logic used by all user stories

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T002 Implement Step 1: Git repository prerequisite check in `.claude/commands/mykit.tasks.md`
- [x] T003 Implement Step 2: Argument parsing for `create` and `--force` flags in `.claude/commands/mykit.tasks.md`
- [x] T004 Implement Step 3: Branch name extraction and issue number parsing in `.claude/commands/mykit.tasks.md`
- [x] T005 Implement Step 4: Feature branch validation (require pattern `^([0-9]+)-`) in `.claude/commands/mykit.tasks.md`
- [x] T006 Implement Step 5: Path determination (`specs/{branch}/tasks.md`) in `.claude/commands/mykit.tasks.md`
- [x] T007 Implement Step 6: Speckit conflict detection (check for research.md, data-model.md, contracts/) in `.claude/commands/mykit.tasks.md`

**Checkpoint**: Foundation ready - user story implementation can now proceed ✅

---

## Phase 3: User Story 1 - Generate Tasks from Existing Spec/Plan (Priority: P1) 🎯 MVP

**Goal**: Implement task generation when spec.md and/or plan.md exist

**Independent Test**: Run `/mykit.tasks create` on a feature branch with existing spec.md and/or plan.md; verify tasks.md is generated with structured content

### Implementation for User Story 1

- [x] T008 [US1] Implement Step 7: Check for existing tasks.md and handle overwrite confirmation in `.claude/commands/mykit.tasks.md`
- [x] T009 [US1] Implement Step 8: Spec file detection and content reading in `.claude/commands/mykit.tasks.md`
- [x] T010 [US1] Implement Step 9: Plan file detection and content reading in `.claude/commands/mykit.tasks.md`
- [x] T011 [US1] Implement Step 10: User story extraction from spec (parse `### User Story N - {title} (Priority: {P#})`) in `.claude/commands/mykit.tasks.md`
- [x] T012 [US1] Implement Step 11: Implementation phases extraction from plan in `.claude/commands/mykit.tasks.md`
- [x] T013 [US1] Implement Step 12: Task generation algorithm (5-15 tasks, 30min-2hr granularity) in `.claude/commands/mykit.tasks.md`
- [x] T014 [US1] Implement Step 13: Completion tasks appending (validate, commit, PR) in `.claude/commands/mykit.tasks.md`
- [x] T015 [US1] Implement Step 14: Tasks.md file writing with lite template format in `.claude/commands/mykit.tasks.md`

**Checkpoint**: User Story 1 complete - task generation from artifacts works independently ✅

---

## Phase 4: User Story 2 - Generate Tasks via Guided Questions (Priority: P2)

**Goal**: Implement fallback guided conversation when no spec/plan exists

**Independent Test**: Run `/mykit.tasks create` on a feature branch with no spec.md or plan.md; verify 3-question conversation triggers and generates tasks

### Implementation for User Story 2

- [x] T016 [US2] Implement Step 8a: Empty/missing artifact detection triggering guided mode in `.claude/commands/mykit.tasks.md`
- [x] T017 [US2] Implement guided Q1: "What needs to be built or changed?" using AskUserQuestion in `.claude/commands/mykit.tasks.md`
- [x] T018 [US2] Implement guided Q2: "What components or files are affected?" using AskUserQuestion in `.claude/commands/mykit.tasks.md`
- [x] T019 [US2] Implement guided Q3: "What defines 'done' for this work?" using AskUserQuestion in `.claude/commands/mykit.tasks.md`
- [x] T020 [US2] Implement task generation from guided answers (connect to existing generation algorithm) in `.claude/commands/mykit.tasks.md`

**Checkpoint**: User Story 2 complete - guided conversation works independently ✅

---

## Phase 5: User Story 3 - Preview Tasks Before Creating (Priority: P3)

**Goal**: Implement preview mode (no action) showing proposed tasks without file creation

**Independent Test**: Run `/mykit.tasks` (without `create`) on a feature branch; verify preview is displayed without writing files

### Implementation for User Story 3

- [x] T021 [US3] Implement preview mode detection (no `create` action present) in `.claude/commands/mykit.tasks.md`
- [x] T022 [US3] Implement preview output format with "PREVIEW" header and next steps message in `.claude/commands/mykit.tasks.md`
- [x] T023 [US3] Ensure preview mode skips file writing and state updates in `.claude/commands/mykit.tasks.md`

**Checkpoint**: User Story 3 complete - preview mode works independently ✅

---

## Phase 6: User Story 4 - State Management and Output (Priority: P3)

**Goal**: Ensure completion tasks always appear and state is properly updated

**Independent Test**: Verify any generated tasks.md includes completion section; verify `.mykit/state.json` is updated after `create`

### Implementation for User Story 4

- [x] T024 [US4] Implement state.json update (workflow_step, tasks_path, last_command, last_command_time) in `.claude/commands/mykit.tasks.md`
- [x] T025 [US4] Implement completion message display with next steps (`/mykit.implement`) in `.claude/commands/mykit.tasks.md`
- [x] T026 [US4] Add error handling table (Error Handling section) in `.claude/commands/mykit.tasks.md`

**Checkpoint**: User Story 4 complete - state management works independently ✅

---

## Phase 7: Polish & Distribution

**Purpose**: Template distribution and documentation

- [x] T027 Copy completed command to `.mykit/templates/commands/mykit.tasks.md` for distribution
- [x] T028 Add Related Commands section linking to `/mykit.specify`, `/mykit.plan`, `/mykit.implement`, `/mykit.status`
- [ ] T029 Run manual acceptance testing for all user story scenarios

---

## Phase 8: Completion

- [ ] T030 Run validation: `/mykit.validate`
- [ ] T031 Create commit: `/mykit.commit create`
- [ ] T032 Create pull request: `/mykit.pr create`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 - BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Phase 2 - MVP implementation
- **User Story 2 (Phase 4)**: Depends on Phase 2 - Can run parallel to US1 (different code paths)
- **User Story 3 (Phase 5)**: Depends on Phase 3 (needs generation logic to preview)
- **User Story 4 (Phase 6)**: Depends on Phase 3 (needs file writing to add state)
- **Polish (Phase 7)**: Depends on Phases 3-6
- **Completion (Phase 8)**: Depends on Phase 7

### User Story Dependencies

- **User Story 1 (P1)**: After Foundational - core functionality, no story dependencies
- **User Story 2 (P2)**: After Foundational - alternative input path, independent of US1
- **User Story 3 (P3)**: After US1 - needs generation output to preview
- **User Story 4 (P3)**: After US1 - needs file writing to update state

### Parallel Opportunities

Within **Phase 2** (Foundational):
- T002, T003, T004 can run in parallel (different validation concerns)
- T005, T006, T007 can run in parallel (path/detection logic)

Within **User Story 1** (Phase 3):
- T009 and T010 can run in parallel (spec vs plan detection)

Between **User Stories**:
- US1 and US2 can potentially run in parallel (different code paths) after Phase 2

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001)
2. Complete Phase 2: Foundational (T002-T007)
3. Complete Phase 3: User Story 1 (T008-T015)
4. **STOP and VALIDATE**: Test with spec.md/plan.md present
5. Deploy/demo if ready - core functionality works

### Incremental Delivery

1. Setup + Foundational → Command structure ready
2. Add User Story 1 → Test with existing artifacts → MVP!
3. Add User Story 2 → Test guided conversation → Enhanced capability
4. Add User Story 3 → Test preview mode → Safer UX
5. Add User Story 4 → Test state updates → Full integration
6. Polish + Distribution → Production ready

---

## Summary

| Metric | Value |
|--------|-------|
| Total Tasks | 32 |
| Phase 1 (Setup) | 1 task |
| Phase 2 (Foundational) | 6 tasks |
| Phase 3 (US1 - MVP) | 8 tasks |
| Phase 4 (US2 - Guided) | 5 tasks |
| Phase 5 (US3 - Preview) | 3 tasks |
| Phase 6 (US4 - State) | 3 tasks |
| Phase 7 (Polish) | 3 tasks |
| Phase 8 (Completion) | 3 tasks |
| Parallel Opportunities | 6 identified |
| MVP Scope | Phases 1-3 (15 tasks) |

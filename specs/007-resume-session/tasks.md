# Tasks: Resume Interrupted Session

**Input**: Design documents from `/specs/007-resume-session/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, quickstart.md

**Tests**: Not explicitly requested in specification. Manual testing via Claude Code conversation.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Slash command**: `.claude/commands/mykit.resume.md`
- **State file**: `.mykit/state.json` (read-only)
- **Spec files**: `specs/{branch}/` directory

---

## Phase 1: Setup

**Purpose**: Understand existing patterns and prepare for implementation

- [X] T001 Review existing `/mykit.status` implementation in `.claude/commands/mykit.status.md` for pattern reference
- [X] T002 [P] Review existing `/mykit.start` implementation in `.claude/commands/mykit.start.md` for session state context
- [X] T003 [P] Review existing stub in `.claude/commands/mykit.resume.md` to understand current placeholder

---

## Phase 2: Foundational (Command Structure)

**Purpose**: Establish the core command structure that all user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T004 Create command header section with usage documentation in `.claude/commands/mykit.resume.md`
- [X] T005 Define implementation outline with step numbering in `.claude/commands/mykit.resume.md`
- [X] T006 Add helper functions section for project ID generation (SHA-256 hash logic) in `.claude/commands/mykit.resume.md`
- [X] T007 Add helper functions section for timestamp parsing and relative time display in `.claude/commands/mykit.resume.md`

**Checkpoint**: Command structure ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Resume with Saved State (Priority: P1) 🎯 MVP

**Goal**: Display saved session state in structured card format with suggested next command

**Independent Test**: Create a test `.mykit/state.json` file with valid data, run `/mykit.resume`, verify output shows branch, timestamp, stage, and appropriate suggestion

### Implementation for User Story 1

- [X] T008 [US1] Implement Step 1: Check for state file existence in `.claude/commands/mykit.resume.md`
- [X] T009 [US1] Implement Step 2: Read and parse `.mykit/state.json` as JSON in `.claude/commands/mykit.resume.md`
- [X] T010 [US1] Implement Step 3: Validate JSON schema (version, projectId, branch, timestamp, workflowStage, sessionType) in `.claude/commands/mykit.resume.md`
- [X] T011 [US1] Implement Step 4: Generate current project identifier using git remote URL hash in `.claude/commands/mykit.resume.md`
- [X] T012 [US1] Implement Step 5: Detect current workflow stage from spec files (`specs/{branch}/`) in `.claude/commands/mykit.resume.md`
- [X] T013 [US1] Implement Step 6: Check for uncommitted changes via `git status --porcelain` in `.claude/commands/mykit.resume.md`
- [X] T014 [US1] Implement Step 7: Generate next command suggestion based on workflow stage and file status in `.claude/commands/mykit.resume.md`
- [X] T015 [US1] Implement Step 8: Format and display structured card output (Last Session section) in `.claude/commands/mykit.resume.md`
- [X] T016 [US1] Implement Step 9: Display Suggested Next Step section in `.claude/commands/mykit.resume.md`

**Checkpoint**: User Story 1 complete - valid state displays correctly with suggestions

---

## Phase 4: User Story 2 - Resume with No Saved State (Priority: P2)

**Goal**: Gracefully handle missing state file with helpful guidance

**Independent Test**: Delete `.mykit/state.json`, run `/mykit.resume`, verify friendly message and `/mykit.start` suggestion appear

### Implementation for User Story 2

- [X] T017 [US2] Add conditional handling for missing state file in Step 1 of `.claude/commands/mykit.resume.md`
- [X] T018 [US2] Create "No saved session state found" output template in `.claude/commands/mykit.resume.md`
- [X] T019 [US2] Add suggestions for `/mykit.start` and `/mykit.status` as next steps in `.claude/commands/mykit.resume.md`

**Checkpoint**: User Story 2 complete - missing state handled gracefully

---

## Phase 5: User Story 3 - Resume with Stale State (Priority: P3)

**Goal**: Validate state freshness and resource existence with appropriate warnings

**Independent Test**: Create state.json with old timestamp or non-existent branch, run `/mykit.resume`, verify warnings appear

### Implementation for User Story 3

- [X] T020 [US3] Implement staleness check: compare timestamp to current time (7-day threshold) in `.claude/commands/mykit.resume.md`
- [X] T021 [US3] Implement branch validation: check if saved branch still exists via `git branch --list` in `.claude/commands/mykit.resume.md`
- [X] T022 [US3] Implement branch mismatch detection: compare current branch to saved branch in `.claude/commands/mykit.resume.md`
- [X] T023 [US3] Implement project ID validation: compare stored projectId to current project ID in `.claude/commands/mykit.resume.md`
- [X] T024 [US3] Create Warnings section in output template for all validation issues in `.claude/commands/mykit.resume.md`
- [X] T025 [US3] Handle corrupted/invalid JSON with error message and recovery instructions in `.claude/commands/mykit.resume.md`

**Checkpoint**: User Story 3 complete - all validation warnings implemented

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final cleanup and documentation

- [X] T026 Add Error Handling section documenting all error cases in `.claude/commands/mykit.resume.md`
- [X] T027 Add Example Output section with all scenarios (valid, warnings, no state, corrupted) in `.claude/commands/mykit.resume.md`
- [X] T028 Add Related Commands section linking to `/mykit.start`, `/mykit.status`, `/mykit.help` in `.claude/commands/mykit.resume.md`
- [X] T029 Run quickstart.md validation - manually test all scenarios documented in `specs/007-resume-session/quickstart.md`
- [X] T030 Update spec status from "Draft" to "Complete" in `specs/007-resume-session/spec.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup understanding - BLOCKS all user stories
- **User Stories (Phase 3-5)**: All depend on Foundational phase completion
  - User stories should proceed sequentially in priority order (P1 → P2 → P3)
  - Each builds on the previous (US2 adds to US1 flow, US3 adds validation)
- **Polish (Phase 6)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - Core functionality
- **User Story 2 (P2)**: Builds on US1 by adding missing state handling branch
- **User Story 3 (P3)**: Builds on US1 by adding validation and warning logic

### Within Each User Story

- Tasks are sequential within each story (earlier steps inform later steps)
- All tasks modify the same file (`.claude/commands/mykit.resume.md`)
- No parallel tasks within stories due to single file constraint

### Parallel Opportunities

- **Phase 1**: T002 and T003 can run in parallel (different reference files)
- **Cross-phase**: Limited parallelism due to single-file implementation
- **Multi-developer**: One developer can handle all tasks (single file focus)

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (review existing patterns)
2. Complete Phase 2: Foundational (command structure)
3. Complete Phase 3: User Story 1 (core resume functionality)
4. **STOP and VALIDATE**: Test with valid state.json
5. Can ship MVP with just US1 complete

### Incremental Delivery

1. Complete Setup + Foundational → Structure ready
2. Add User Story 1 → Test with valid state → MVP complete
3. Add User Story 2 → Test with missing state → Better UX
4. Add User Story 3 → Test with stale/invalid state → Full feature
5. Polish → Documentation and validation

### Single Developer Strategy

Recommended approach (single file, linear flow):

1. Complete all Setup tasks (understand patterns)
2. Build Foundational structure
3. Implement US1 completely (core path)
4. Test US1 manually
5. Add US2 handling (empty state path)
6. Add US3 validation (warning paths)
7. Polish and document

---

## Summary

| Phase | Tasks | Description |
|-------|-------|-------------|
| Setup | 3 | Review existing patterns |
| Foundational | 4 | Command structure |
| US1 (P1) | 9 | Core resume functionality |
| US2 (P2) | 3 | Missing state handling |
| US3 (P3) | 6 | Validation and warnings |
| Polish | 5 | Documentation and cleanup |
| **Total** | **30** | |

### Tasks per User Story

- **US1**: 9 tasks (MVP)
- **US2**: 3 tasks
- **US3**: 6 tasks

### MVP Scope

Complete Phases 1-3 (16 tasks) for functional MVP that handles the happy path of resuming a valid saved session.

---

## Notes

- All implementation tasks modify `.claude/commands/mykit.resume.md`
- This is a Claude Code slash command (Markdown with implementation instructions)
- No external code files or tests required
- Manual testing via Claude Code conversation
- State file `.mykit/state.json` is read-only (written by other commands)

# Tasks: Enhanced Status Dashboard

**Input**: Design documents from `/specs/006-status-dashboard/`
**Prerequisites**: plan.md (✓), spec.md (✓), research.md (✓), data-model.md (✓), quickstart.md (✓)

**Tests**: Not requested - skipping test tasks per specification.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Slash command file**: `.claude/commands/mykit.status.md`
- This is a single-file feature - all implementation goes into the slash command markdown file

---

## Phase 1: Setup

**Purpose**: Read existing command file and prepare implementation structure

- [X] T001 Read existing stub file at .claude/commands/mykit.status.md to understand current state
- [X] T002 Review existing command patterns in .claude/commands/mykit.help.md and .claude/commands/mykit.start.md for consistency

---

## Phase 2: Foundational (Command Structure)

**Purpose**: Establish the core command structure that all user stories build upon

**⚠️ CRITICAL**: Command structure must be in place before adding feature sections

- [X] T003 Create command header and usage section in .claude/commands/mykit.status.md
- [X] T004 Define implementation execution flow structure in .claude/commands/mykit.status.md
- [X] T005 Add error handling framework (git not available, non-repo scenarios) in .claude/commands/mykit.status.md
- [X] T006 Define output dashboard layout sections in .claude/commands/mykit.status.md

**Checkpoint**: Command skeleton ready - user story sections can now be added

---

## Phase 3: User Story 1 - Quick Context Overview (Priority: P1) 🎯 MVP

**Goal**: Display current branch, linked GitHub issue, and workflow phase

**Independent Test**: Run `/mykit.status` on a feature branch and verify branch name, issue info, and workflow phase are displayed correctly

### Implementation for User Story 1

- [X] T007 [US1] Implement git branch detection using `git rev-parse --abbrev-ref HEAD` in .claude/commands/mykit.status.md
- [X] T008 [US1] Implement issue number extraction from branch pattern `^([0-9]+)-` in .claude/commands/mykit.status.md
- [X] T009 [US1] Implement GitHub issue lookup using `gh issue view` with JSON output in .claude/commands/mykit.status.md
- [X] T010 [US1] Implement graceful degradation when gh unavailable (show local info only) in .claude/commands/mykit.status.md
- [X] T011 [US1] Implement workflow phase detection by checking spec.md/plan.md/tasks.md existence in .claude/commands/mykit.status.md
- [X] T012 [US1] Implement "Feature Context" dashboard section output in .claude/commands/mykit.status.md
- [X] T013 [US1] Implement "Workflow Phase" dashboard section with progress indicators in .claude/commands/mykit.status.md
- [X] T014 [US1] Handle edge case: detached HEAD state warning in .claude/commands/mykit.status.md
- [X] T015 [US1] Handle edge case: main branch (no feature context) message in .claude/commands/mykit.status.md

**Checkpoint**: User Story 1 complete - context overview is fully functional and testable

---

## Phase 4: User Story 2 - File Status Visibility (Priority: P2)

**Goal**: Display uncommitted file changes with staged/unstaged distinction

**Independent Test**: Make file changes, run `/mykit.status`, verify changed files are listed with correct status indicators

### Implementation for User Story 2

- [X] T016 [US2] Implement git status parsing using `git status --porcelain` in .claude/commands/mykit.status.md
- [X] T017 [US2] Implement status code mapping (M, A, D, R, ??) to display labels in .claude/commands/mykit.status.md
- [X] T018 [US2] Implement staged vs unstaged differentiation with visual markers in .claude/commands/mykit.status.md
- [X] T019 [US2] Implement 10-file display limit with "+N more" summary in .claude/commands/mykit.status.md
- [X] T020 [US2] Implement "File Status" dashboard section output in .claude/commands/mykit.status.md
- [X] T021 [US2] Handle edge case: clean working directory indicator in .claude/commands/mykit.status.md

**Checkpoint**: User Story 2 complete - file status visibility is fully functional

---

## Phase 5: User Story 3 - Next Command Suggestion (Priority: P3)

**Goal**: Suggest next logical command based on workflow state and file status

**Independent Test**: Be at different workflow stages, run `/mykit.status`, verify appropriate commands are suggested

### Implementation for User Story 3

- [X] T022 [US3] Implement suggestion logic state machine based on phase and changes in .claude/commands/mykit.status.md
- [X] T023 [US3] Add suggestions for "not started" phase: `/mykit.backlog select` in .claude/commands/mykit.status.md
- [X] T024 [US3] Add suggestions for "specification" phase: `/speckit.clarify` or `/speckit.plan` in .claude/commands/mykit.status.md
- [X] T025 [US3] Add suggestions for "planning" phase: `/speckit.tasks` in .claude/commands/mykit.status.md
- [X] T026 [US3] Add suggestions for "implementation" phase: `/mykit.pr create` or continue implementing in .claude/commands/mykit.status.md
- [X] T027 [US3] Add commit suggestion when uncommitted changes exist in .claude/commands/mykit.status.md
- [X] T028 [US3] Implement "Next Step" dashboard section with command and reason in .claude/commands/mykit.status.md

**Checkpoint**: User Story 3 complete - all dashboard features are functional

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Finalize command and ensure quality

- [X] T029 [P] Review output formatting consistency with other mykit commands in .claude/commands/mykit.status.md
- [X] T030 [P] Verify all edge cases from spec are handled in .claude/commands/mykit.status.md
- [X] T031 Test command execution in various scenarios per quickstart.md
- [X] T032 Update docs/COMMANDS.md with enhanced status command documentation

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup - establishes command structure
- **User Story 1 (Phase 3)**: Depends on Foundational - context overview
- **User Story 2 (Phase 4)**: Depends on Foundational - file status (can parallel with US1)
- **User Story 3 (Phase 5)**: Depends on US1 and US2 - needs context and file status for suggestions
- **Polish (Phase 6)**: Depends on all user stories complete

### User Story Dependencies

- **User Story 1 (P1)**: Independent after Foundational - core context display
- **User Story 2 (P2)**: Independent after Foundational - can be developed alongside US1
- **User Story 3 (P3)**: Depends on US1 + US2 - suggestion logic requires both context and file status data

### Within Each User Story

All tasks within a user story should be completed in order (sequential implementation in single file).

### Parallel Opportunities

- **Phase 1**: T001 and T002 can run in parallel (reading existing files)
- **Phase 2**: Sequential (building on each other in same file)
- **Phase 3 & 4**: US1 and US2 can be developed in parallel by different developers (but since single file, likely sequential)
- **Phase 6**: T029 and T030 can run in parallel (independent verification tasks)

---

## Parallel Example: Foundational Phase

```bash
# Phase 1 tasks can run in parallel (reading existing files):
Task: "Read existing stub file at .claude/commands/mykit.status.md"
Task: "Review existing command patterns in .claude/commands/mykit.help.md"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (command structure)
3. Complete Phase 3: User Story 1 (context overview)
4. **STOP and VALIDATE**: Test `/mykit.status` shows branch, issue, workflow phase
5. Ship MVP if needed

### Incremental Delivery

1. Setup + Foundational → Command skeleton ready
2. Add User Story 1 → Test context display → (MVP!)
3. Add User Story 2 → Test file status display
4. Add User Story 3 → Test command suggestions
5. Polish → Final validation

### Single Developer Strategy

Since this is a single markdown file:

1. Complete all phases sequentially
2. Test after each user story checkpoint
3. Commit after each phase completion

---

## Notes

- All tasks modify the same file: `.claude/commands/mykit.status.md`
- [P] marks are limited since single-file implementation
- Each user story builds on previous sections but can be tested independently
- Commit after each phase for clean git history
- Edge cases are distributed across relevant user stories

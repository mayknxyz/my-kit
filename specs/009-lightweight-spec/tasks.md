# Tasks: Lightweight Spec Command

**Input**: Design documents from `/specs/009-lightweight-spec/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md

**Tests**: Not requested in specification - manual testing via command invocation.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4)
- Include exact file paths in descriptions

## Path Conventions

- **Slash command**: `.claude/commands/mykit.specify.md`
- **Templates**: `.mykit/templates/lite/spec.md`
- **State**: `.mykit/state.json`
- **Specs**: `specs/{branch-name}/spec.md`

---

## Phase 1: Setup

**Purpose**: Verify prerequisites and prepare for implementation

- [x] T001 Review existing stub at .claude/commands/mykit.specify.md
- [x] T002 [P] Review existing pattern in .claude/commands/mykit.start.md for AskUserQuestion usage
- [x] T003 [P] Review existing pattern in .claude/commands/mykit.status.md for git/gh CLI usage
- [x] T004 [P] Verify lite spec template exists at .mykit/templates/lite/spec.md

---

## Phase 2: Foundational (Command Structure)

**Purpose**: Core command skeleton that ALL user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T005 Define command structure with Usage, Description, and Implementation sections in .claude/commands/mykit.specify.md
- [x] T006 Implement argument parsing for `create` action and `--no-issue`, `--force` flags in .claude/commands/mykit.specify.md
- [x] T007 Add Step 1: Check prerequisites (git repo, branch extraction) in .claude/commands/mykit.specify.md
- [x] T008 Add error handling patterns consistent with existing commands in .claude/commands/mykit.specify.md

**Checkpoint**: Command structure ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Create Spec from GitHub Issue (Priority: P1) 🎯 MVP

**Goal**: Extract spec content from linked GitHub issue body when >= 50 chars

**Independent Test**: Select an issue with structured body, run `/mykit.specify create`, verify spec is created with extracted content

### Implementation for User Story 1

- [x] T009 [US1] Add Step: Extract issue number from branch name in .claude/commands/mykit.specify.md
- [x] T010 [US1] Add Step: Fetch issue body using `gh issue view {number} --json body,title` in .claude/commands/mykit.specify.md
- [x] T011 [US1] Add Step: Check if body length >= 50 characters in .claude/commands/mykit.specify.md
- [x] T012 [US1] Add Step: Extract sections (Summary/Description, Problem/Why, Acceptance Criteria) from issue body using heading pattern matching in .claude/commands/mykit.specify.md
- [x] T013 [US1] Add Step: Map extracted sections to lite spec template structure in .claude/commands/mykit.specify.md
- [x] T014 [US1] Add Step: Create spec file at specs/{branch}/spec.md using extracted content in .claude/commands/mykit.specify.md
- [x] T015 [US1] Add Step: Update .mykit/state.json with spec_path and workflow_step in .claude/commands/mykit.specify.md
- [x] T016 [US1] Add Step: Display confirmation message with spec file path in .claude/commands/mykit.specify.md

**Checkpoint**: User Story 1 is complete - can create specs from well-documented issues

---

## Phase 4: User Story 2 - Create Spec via Guided Conversation (Priority: P2)

**Goal**: Fallback to 3-question conversation when issue body < 50 chars or extraction fails

**Independent Test**: Select an issue with empty body, run `/mykit.specify create`, verify guided questions are asked

### Implementation for User Story 2

- [x] T017 [US2] Add Step: Detect when to trigger guided conversation (body < 50 chars or extraction failure) in .claude/commands/mykit.specify.md
- [x] T018 [US2] Add Step: Question 1 - Ask "What is this feature/change about?" using AskUserQuestion tool in .claude/commands/mykit.specify.md
- [x] T019 [US2] Add Step: Question 2 - Ask "What problem does it solve?" using AskUserQuestion tool in .claude/commands/mykit.specify.md
- [x] T020 [US2] Add Step: Question 3 - Ask "What should be true when done?" using AskUserQuestion tool in .claude/commands/mykit.specify.md
- [x] T021 [US2] Add Step: Map Q1→Summary, Q2→Problem, Q3→Acceptance Criteria in .claude/commands/mykit.specify.md
- [x] T022 [US2] Integrate with spec creation flow (T014-T016) in .claude/commands/mykit.specify.md

**Checkpoint**: User Story 2 is complete - can create specs via guided conversation

---

## Phase 5: User Story 3 - Preview Spec Before Creation (Priority: P3)

**Goal**: Show preview without writing files when no action provided

**Independent Test**: Run `/mykit.specify` (no action), verify spec content is displayed but no files created

### Implementation for User Story 3

- [x] T023 [US3] Add Step: Check if `create` action is present in .claude/commands/mykit.specify.md
- [x] T024 [US3] Add Step: If no action, display preview header "PREVIEW - Proposed Spec" in .claude/commands/mykit.specify.md
- [x] T025 [US3] Add Step: Show spec content formatted per template without file write in .claude/commands/mykit.specify.md
- [x] T026 [US3] Add Step: Instruct user "Run `/mykit.specify create` to save this spec" in .claude/commands/mykit.specify.md

**Checkpoint**: User Story 3 is complete - preview mode works

---

## Phase 6: User Story 4 - Create Spec Without Issue (Priority: P3)

**Goal**: Support `--no-issue` flag for ad-hoc work

**Independent Test**: Run `/mykit.specify create --no-issue`, verify guided conversation proceeds and spec is created with generated path

### Implementation for User Story 4

- [x] T027 [US4] Add Step: Check for `--no-issue` flag in .claude/commands/mykit.specify.md
- [x] T028 [US4] Add Step: If --no-issue, skip issue validation and extraction in .claude/commands/mykit.specify.md
- [x] T029 [US4] Add Step: Generate ad-hoc spec path using slug from Q1 answer (e.g., specs/adhoc-{slug}/spec.md) in .claude/commands/mykit.specify.md
- [x] T030 [US4] Add Step: Proceed with guided conversation flow (T018-T022) in .claude/commands/mykit.specify.md

**Checkpoint**: User Story 4 is complete - ad-hoc specs work

---

## Phase 7: Edge Cases & Polish

**Purpose**: Handle edge cases and cross-cutting concerns

- [x] T031 Add handling for GitHub API unavailable (warn and proceed with guided conversation) in .claude/commands/mykit.specify.md
- [x] T032 Add handling for existing spec file (prompt: Overwrite/Merge/Cancel) in .claude/commands/mykit.specify.md
- [x] T033 Add `--force` flag handling to skip overwrite confirmation in .claude/commands/mykit.specify.md
- [x] T034 Add validation that issue is selected before proceeding (error if not, unless --no-issue) in .claude/commands/mykit.specify.md
- [x] T035 Add Related Commands section with links to /mykit.start, /mykit.backlog, /mykit.plan in .claude/commands/mykit.specify.md
- [x] T036 Update docs/COMMANDS.md with /mykit.specify command reference

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-6)**: All depend on Foundational phase completion
  - US1 (extraction) and US2 (conversation) can proceed in parallel
  - US3 (preview) depends on US1 or US2 being complete
  - US4 (no-issue) reuses US2 conversation flow
- **Polish (Phase 7)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational - No dependencies on other stories
- **User Story 3 (P3)**: Depends on either US1 or US2 (needs content generation logic)
- **User Story 4 (P3)**: Depends on US2 (reuses guided conversation)

### Within Each User Story

- Command structure must be in place (Phase 2)
- Steps should be added in logical order (validation → extraction → file write → confirmation)

### Parallel Opportunities

- Setup tasks T002, T003, T004 can run in parallel
- US1 and US2 can be developed in parallel after Foundational phase
- Edge case tasks T031, T032, T033, T034 can run in parallel

---

## Parallel Example: Setup Phase

```bash
# Launch these tasks together:
Task: "Review existing pattern in .claude/commands/mykit.start.md for AskUserQuestion usage"
Task: "Review existing pattern in .claude/commands/mykit.status.md for git/gh CLI usage"
Task: "Verify lite spec template exists at .mykit/templates/lite/spec.md"
```

## Parallel Example: After Foundational

```bash
# Can develop User Story 1 and User Story 2 in parallel:
# Developer A: US1 (GitHub extraction)
# Developer B: US2 (Guided conversation)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1 (extraction from issue)
4. **STOP and VALIDATE**: Test with a well-documented GitHub issue
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Command structure ready
2. Add User Story 1 → Test extraction → Demo (MVP!)
3. Add User Story 2 → Test conversation → Demo (fallback works)
4. Add User Story 3 → Test preview → Demo (preview mode works)
5. Add User Story 4 → Test --no-issue → Demo (ad-hoc works)
6. Complete Polish → Full feature ready

---

## Summary

| Phase | Task Count | Description |
|-------|------------|-------------|
| Setup | 4 | Review prerequisites and patterns |
| Foundational | 4 | Command structure skeleton |
| US1 (P1) | 8 | GitHub issue extraction |
| US2 (P2) | 6 | Guided conversation |
| US3 (P3) | 4 | Preview mode |
| US4 (P3) | 4 | No-issue flag |
| Polish | 6 | Edge cases and docs |
| **Total** | **36** | |

## Notes

- All tasks target a single file: .claude/commands/mykit.specify.md (except T036)
- The [P] marker indicates tasks that could be parallelized in a team setting
- Each user story checkpoint allows for independent validation
- Commit after each phase or logical task group

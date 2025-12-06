# Tasks: /mykit.plan - Lightweight Plan (AI Skill)

**Input**: Design documents from `/specs/010-lightweight-plan/`
**Prerequisites**: plan.md (complete), spec.md (complete), research.md, data-model.md, quickstart.md

**Tests**: Not requested - no test tasks included.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Single project**: Slash command in `.claude/commands/`
- **State file**: `.mykit/state.json`
- **Spec location**: `specs/{branch}/`

---

## Phase 1: Setup

**Purpose**: Prepare the command file structure

- [x] T001 Read existing `.claude/commands/mykit.plan.md` stub to understand current state
- [x] T002 Review `.claude/commands/mykit.specify.md` as reference implementation pattern

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core command structure that ALL user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T003 Create command header with usage documentation in `.claude/commands/mykit.plan.md`
- [x] T004 Implement Step 1: Check Prerequisites (git repo validation) in `.claude/commands/mykit.plan.md`
- [x] T005 Implement Step 2: Parse Arguments (create, --force) in `.claude/commands/mykit.plan.md`
- [x] T006 Implement Step 3: Get Current Branch and Extract Issue Number in `.claude/commands/mykit.plan.md`
- [x] T007 Implement Step 4: Determine Spec Path and Plan Path in `.claude/commands/mykit.plan.md`

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Create Implementation Plan (Priority: P1) 🎯 MVP

**Goal**: Generate a complete plan.md file with Technical Context, Design Decisions, and Implementation Phases from an existing spec.

**Independent Test**: Run `/mykit.plan create` on a feature branch with an existing spec.md and verify plan.md is created with all three required sections.

### Implementation for User Story 1

- [x] T008 [US1] Implement Step 5: Check for existing spec file in `.claude/commands/mykit.plan.md`
- [x] T009 [US1] Implement Step 6: Check for speckit conflict (research.md, data-model.md, contracts/) in `.claude/commands/mykit.plan.md`
- [x] T010 [US1] Implement Step 7: Read and parse spec file content in `.claude/commands/mykit.plan.md`
- [x] T011 [US1] Implement Step 8: Generate Technical Context section from spec in `.claude/commands/mykit.plan.md`
- [x] T012 [US1] Implement Step 9: Generate Design Decisions section from spec in `.claude/commands/mykit.plan.md`
- [x] T013 [US1] Implement Step 10: Generate Implementation Phases section from spec in `.claude/commands/mykit.plan.md`
- [x] T014 [US1] Implement Step 11: Format complete plan.md content in `.claude/commands/mykit.plan.md`
- [x] T015 [US1] Implement Step 12: Write plan to `specs/{branch}/plan.md` in `.claude/commands/mykit.plan.md`
- [x] T016 [US1] Implement Step 13: Update `.mykit/state.json` with workflow_step and plan_path in `.claude/commands/mykit.plan.md`
- [x] T017 [US1] Implement success message with file path and next step suggestion in `.claude/commands/mykit.plan.md`

**Checkpoint**: User Story 1 complete - `/mykit.plan create` generates a valid plan from spec

---

## Phase 4: User Story 2 - Preview Implementation Plan (Priority: P1)

**Goal**: Display plan preview without creating files when no action is specified.

**Independent Test**: Run `/mykit.plan` (no action) and verify plan content is displayed but no files are written.

### Implementation for User Story 2

- [x] T018 [US2] Add preview mode detection (no `create` action) in `.claude/commands/mykit.plan.md`
- [x] T019 [US2] Implement preview display with "PREVIEW" header in `.claude/commands/mykit.plan.md`
- [x] T020 [US2] Add "No files created" note and suggestion to run with `create` in `.claude/commands/mykit.plan.md`
- [x] T021 [US2] Ensure preview uses same generation logic as execute mode in `.claude/commands/mykit.plan.md`

**Checkpoint**: User Story 2 complete - preview mode works independently

---

## Phase 5: User Story 3 - Guided Conversation (Priority: P2)

**Goal**: Ask 0-5 clarifying technical questions when spec contains ambiguity.

**Independent Test**: Run `/mykit.plan create` on a spec with multiple valid technical approaches and verify AI asks relevant questions.

### Implementation for User Story 3

- [x] T022 [US3] Implement spec analysis to identify technical ambiguities in `.claude/commands/mykit.plan.md`
- [x] T023 [US3] Define question categories (stack, integration, persistence, testing) in `.claude/commands/mykit.plan.md`
- [x] T024 [US3] Implement AskUserQuestion tool usage for technical decisions in `.claude/commands/mykit.plan.md`
- [x] T025 [US3] Add question format with options table and recommendation in `.claude/commands/mykit.plan.md`
- [x] T026 [US3] Implement answer recording for plan generation in `.claude/commands/mykit.plan.md`
- [x] T027 [US3] Add 3-5 question limit enforcement in `.claude/commands/mykit.plan.md`

**Checkpoint**: User Story 3 complete - guided conversation enhances plan generation

---

## Phase 6: User Story 4 - Handle Missing Prerequisites (Priority: P2)

**Goal**: Display clear error messages when prerequisites are not met.

**Independent Test**: Run `/mykit.plan create` without a spec file and verify error message with suggested command.

### Implementation for User Story 4

- [x] T028 [US4] Implement error for "Not in git repository" in `.claude/commands/mykit.plan.md`
- [x] T029 [US4] Implement error for "Not on feature branch" in `.claude/commands/mykit.plan.md`
- [x] T030 [US4] Implement error for "No specification found" with `/mykit.specify create` suggestion in `.claude/commands/mykit.plan.md`
- [x] T031 [US4] Implement error for speckit conflict with `/speckit.tasks` suggestion in `.claude/commands/mykit.plan.md`
- [x] T032 [US4] Add error handling table to documentation section in `.claude/commands/mykit.plan.md`

**Checkpoint**: User Story 4 complete - all error cases handled with actionable messages

---

## Phase 7: User Story 5 - Force Overwrite (Priority: P3)

**Goal**: Support `--force` flag to overwrite existing plans without confirmation.

**Independent Test**: Run `/mykit.plan create --force` on a branch with existing plan.md and verify it is overwritten.

### Implementation for User Story 5

- [x] T033 [US5] Implement check for existing plan.md file in `.claude/commands/mykit.plan.md`
- [x] T034 [US5] Implement confirmation prompt using AskUserQuestion when plan exists in `.claude/commands/mykit.plan.md`
- [x] T035 [US5] Implement `--force` flag to skip confirmation in `.claude/commands/mykit.plan.md`
- [x] T036 [US5] Add cancel handling and message in `.claude/commands/mykit.plan.md`

**Checkpoint**: User Story 5 complete - force overwrite works as expected

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Final cleanup and documentation

- [x] T037 [P] Add Example Outputs section to documentation in `.claude/commands/mykit.plan.md`
- [x] T038 [P] Add Related Commands table in `.claude/commands/mykit.plan.md`
- [x] T039 Update docs/COMMANDS.md with `/mykit.plan` detailed documentation
- [x] T040 Verify command follows Google Shell Style Guide for any bash snippets
- [x] T041 Run manual validation against quickstart.md scenarios

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup - BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational - MVP delivery
- **User Story 2 (Phase 4)**: Depends on Foundational - Can parallel with US1
- **User Story 3 (Phase 5)**: Depends on Foundational - Can parallel with US1/US2
- **User Story 4 (Phase 6)**: Depends on Foundational - Can parallel with US1/US2/US3
- **User Story 5 (Phase 7)**: Depends on Foundational - Can parallel with others
- **Polish (Phase 8)**: Depends on all user stories complete

### User Story Dependencies

| Story | Priority | Can Start After | Dependencies on Other Stories |
|-------|----------|-----------------|-------------------------------|
| US1 - Create Plan | P1 | Foundational | None (MVP) |
| US2 - Preview Plan | P1 | Foundational | Shares generation logic with US1 |
| US3 - Guided Conversation | P2 | Foundational | Enhances US1/US2 generation |
| US4 - Error Handling | P2 | Foundational | None |
| US5 - Force Overwrite | P3 | Foundational | None |

### Within Each User Story

- Earlier tasks in sequence before later tasks
- All tasks in a story target same file (`.claude/commands/mykit.plan.md`)
- Commit after each logical group of changes

### Parallel Opportunities

Since all tasks modify the same file (`.claude/commands/mykit.plan.md`), parallel execution within a story is limited. However:

- **Phase 1**: T001 and T002 can run in parallel (read-only)
- **Phase 8**: T037 and T038 can run in parallel (different sections)
- **Cross-story**: Stories could theoretically be developed in parallel by different developers if using feature flags or sections

---

## Parallel Example: Setup Phase

```bash
# Launch both reference reads together:
Task: "Read existing mykit.plan.md stub"
Task: "Review mykit.specify.md as reference pattern"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (review existing code)
2. Complete Phase 2: Foundational (command structure)
3. Complete Phase 3: User Story 1 (create plan)
4. **STOP and VALIDATE**: Test `/mykit.plan create` works end-to-end
5. Can deploy/demo MVP at this point

### Incremental Delivery

1. Setup + Foundational → Command skeleton ready
2. Add User Story 1 → Core functionality working → **MVP!**
3. Add User Story 2 → Preview mode working
4. Add User Story 3 → Guided conversation working
5. Add User Story 4 → Error handling complete
6. Add User Story 5 → Force overwrite working
7. Polish → Documentation complete

### Recommended Order

Since US1 and US2 share generation logic, implement them together:
1. Foundational → US1 + US2 → US4 → US3 → US5 → Polish

---

## Notes

- All implementation tasks modify `.claude/commands/mykit.plan.md`
- Follow the step-by-step markdown pattern from `/mykit.specify`
- Each step should have clear conditional logic ("If X, then Y")
- Include error messages with actionable next steps
- Test each user story independently before moving to next
- Commit after each task or logical group

---

## Summary

| Metric | Count |
|--------|-------|
| Total Tasks | 41 |
| Setup Tasks | 2 |
| Foundational Tasks | 5 |
| User Story 1 Tasks | 10 |
| User Story 2 Tasks | 4 |
| User Story 3 Tasks | 6 |
| User Story 4 Tasks | 5 |
| User Story 5 Tasks | 4 |
| Polish Tasks | 5 |
| Parallel Opportunities | 4 (T001/T002, T037/T038) |

**MVP Scope**: Phases 1-3 (17 tasks) - delivers core plan generation functionality

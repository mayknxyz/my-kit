# Tasks: /mykit.help Command

**Input**: Design documents from `/specs/005-help/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, quickstart.md

**Tests**: Not requested - manual verification via Claude Code session per plan.md

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Single file**: `.claude/commands/mykit.help.md` (update existing stub)
- **Data source**: `docs/COMMANDS.md` (read-only reference)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare the command file structure

- [X] T001 Read existing stub at .claude/commands/mykit.help.md to understand current state
- [X] T002 Read docs/COMMANDS.md to understand command data structure and categories

**Checkpoint**: Existing files understood, ready for implementation

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Define command structure and argument parsing logic

**Note**: This is a simple markdown command - foundational work is minimal

- [X] T003 Define command header and argument parsing structure in .claude/commands/mykit.help.md

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Quick Command Reference (Priority: P1)

**Goal**: Display categorized list of all commands when `/mykit.help` is run without arguments

**Independent Test**: Run `/mykit.help` and verify all commands displayed grouped by category

### Implementation for User Story 1

- [X] T004 [US1] Add Read-Only Commands section with table (status, help) in .claude/commands/mykit.help.md
- [X] T005 [US1] Add Workflow Commands section with table (init, setup, start, resume, reset) in .claude/commands/mykit.help.md
- [X] T006 [US1] Add Issue & Branch Commands section with table (backlog) in .claude/commands/mykit.help.md
- [X] T007 [US1] Add Lite Workflow Commands section with table (specify, plan, tasks, implement) in .claude/commands/mykit.help.md
- [X] T008 [US1] Add Quality & Commit Commands section with table (validate, commit, pr, release) in .claude/commands/mykit.help.md
- [X] T009 [US1] Add Management Commands section with table (upgrade) in .claude/commands/mykit.help.md
- [X] T010 [US1] Add conditional logic to display command overview when $ARGUMENTS is empty in .claude/commands/mykit.help.md

**Checkpoint**: `/mykit.help` displays all commands grouped by category - MVP complete

---

## Phase 4: User Story 2 - Detailed Command Help (Priority: P2)

**Goal**: Display detailed help for a specific command when `/mykit.help <command>` is run

**Independent Test**: Run `/mykit.help commit` and verify description, usage, actions, flags, examples displayed

### Implementation for User Story 2

- [X] T011 [US2] Add command validation logic to check if requested command exists in .claude/commands/mykit.help.md
- [X] T012 [US2] Add detailed help template showing description, usage syntax, actions, flags, examples in .claude/commands/mykit.help.md
- [X] T013 [US2] Add stub detection logic to check for **Stub** marker and display status in .claude/commands/mykit.help.md
- [X] T014 [US2] Add error handling for unknown commands with list of available commands in .claude/commands/mykit.help.md
- [X] T015 [US2] Add conditional logic to display specific command help when $ARGUMENTS matches a command name in .claude/commands/mykit.help.md

**Checkpoint**: `/mykit.help <command>` displays detailed help for any valid command

---

## Phase 5: User Story 3 - Workflow Guidance (Priority: P3)

**Goal**: Display workflow cheatsheets when `/mykit.help workflow` is run

**Independent Test**: Run `/mykit.help workflow` and verify Full, Lite, and Quick Fix workflows displayed

### Implementation for User Story 3

- [X] T016 [US3] Add Full Workflow cheatsheet (with Spec Kit) in .claude/commands/mykit.help.md
- [X] T017 [US3] Add Lite Workflow cheatsheet (My Kit only) in .claude/commands/mykit.help.md
- [X] T018 [US3] Add Quick Fix workflow cheatsheet in .claude/commands/mykit.help.md
- [X] T019 [US3] Add conditional logic to display workflow cheatsheets when $ARGUMENTS equals "workflow" in .claude/commands/mykit.help.md

**Checkpoint**: `/mykit.help workflow` displays all three workflow sequences

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final cleanup and validation

- [X] T020 Remove **Stub** status marker from .claude/commands/mykit.help.md
- [X] T021 Verify output renders correctly in 80-column terminal width
- [ ] T022 Manual test: run `/mykit.help` from outside a My Kit repository to verify context-independence (FR-011)
- [ ] T023 Manual test: run `/mykit.help invalidcommand` to verify error handling (FR-006)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion
- **User Stories (Phase 3-5)**: All depend on Foundational phase completion
  - User stories can proceed sequentially in priority order (P1 → P2 → P3)
  - Each story builds on previous work in same file
- **Polish (Phase 6)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after US1 complete - Uses same conditional structure
- **User Story 3 (P3)**: Can start after US2 complete - Uses same conditional structure

### Within Each User Story

- Command sections before conditional logic
- Core implementation before error handling
- Story complete before moving to next priority

### Parallel Opportunities

- T004-T009 within US1 can be written in parallel (different sections, same file structure)
- T016-T018 within US3 can be written in parallel (different workflow sections)

---

## Parallel Example: User Story 1

```bash
# All command category sections can be written in parallel:
Task: "Add Read-Only Commands section"
Task: "Add Workflow Commands section"
Task: "Add Issue & Branch Commands section"
Task: "Add Lite Workflow Commands section"
Task: "Add Quality & Commit Commands section"
Task: "Add Management Commands section"

# Then add conditional logic after all sections defined
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1 (command overview)
4. **STOP and VALIDATE**: Run `/mykit.help` to verify categorized command list
5. This delivers core value - users can discover all commands

### Incremental Delivery

1. Complete Setup + Foundational → Structure ready
2. Add User Story 1 → Test → `/mykit.help` shows all commands (MVP!)
3. Add User Story 2 → Test → `/mykit.help commit` shows detailed help
4. Add User Story 3 → Test → `/mykit.help workflow` shows cheatsheets
5. Each story adds value without breaking previous stories

---

## Notes

- Single file implementation: all tasks modify `.claude/commands/mykit.help.md`
- No external dependencies or runtime required
- Sources data from existing `docs/COMMANDS.md` - no duplication
- Read-only command with no side effects
- Verify 80-column terminal rendering at each checkpoint

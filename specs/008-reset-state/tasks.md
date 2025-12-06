# Tasks: /mykit.reset - Clear State

**Input**: Design documents from `/specs/008-reset-state/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: Not requested - no test tasks included.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4)
- Include exact file paths in descriptions

## Path Conventions

- **Slash command**: `.claude/commands/mykit.reset.md`
- **State file**: `.mykit/state.json`
- **Spec directory**: `specs/008-reset-state/`

---

## Phase 1: Setup

**Purpose**: Reference existing command patterns and prepare for implementation

- [x] T001 Read existing `.claude/commands/mykit.status.md` as reference for output formatting patterns
- [x] T002 [P] Read existing `.claude/commands/mykit.resume.md` as reference for state file handling patterns

---

## Phase 2: Foundational (Core Command Structure)

**Purpose**: Core command structure that ALL user stories depend on

**⚠️ CRITICAL**: All user story functionality builds on this foundation

- [x] T003 Replace stub in `.claude/commands/mykit.reset.md` with command header (Usage, Description sections)
- [x] T004 Add argument parsing section documenting `run`, `--keep-branch`, `--keep-specs`, `--force` flags in `.claude/commands/mykit.reset.md`
- [x] T005 Add Implementation section header with step-by-step structure in `.claude/commands/mykit.reset.md`

**Checkpoint**: Command file has complete structure - ready for user story implementations

---

## Phase 3: User Story 1 - Complete Reset (Priority: P1) 🎯 MVP

**Goal**: Enable developers to clear all workflow state and start fresh

**Independent Test**: Run `/mykit.reset run` with an existing state file, verify it's deleted and confirmation shown

### Implementation for User Story 1

- [x] T006 [US1] Implement Step 1: Check for state file existence in `.claude/commands/mykit.reset.md`
- [x] T007 [US1] Implement Step 2: Handle "no state file" case with informative message in `.claude/commands/mykit.reset.md`
- [x] T008 [US1] Implement Step 3: Preview mode logic (when no `run` action provided) in `.claude/commands/mykit.reset.md`
- [x] T009 [US1] Implement Step 4: Read and display state file contents summary in preview in `.claude/commands/mykit.reset.md`
- [x] T010 [US1] Implement Step 5: Execute mode - delete state file with `rm` command in `.claude/commands/mykit.reset.md`
- [x] T011 [US1] Implement Step 6: Display confirmation message showing what was cleared in `.claude/commands/mykit.reset.md`
- [x] T012 [US1] Add Error Handling section for permission errors and file system failures in `.claude/commands/mykit.reset.md`

**Checkpoint**: `/mykit.reset` (preview) and `/mykit.reset run` (execute) both work independently

---

## Phase 4: User Story 2 - --keep-branch Flag (Priority: P2)

**Goal**: Provide explicit branch preservation semantics in reset output

**Independent Test**: Run `/mykit.reset run --keep-branch`, verify state cleared and output confirms branch preserved

### Implementation for User Story 2

- [x] T013 [US2] Add --keep-branch flag handling to argument parsing in `.claude/commands/mykit.reset.md`
- [x] T014 [US2] Update preview output to show branch preservation when flag is present in `.claude/commands/mykit.reset.md`
- [x] T015 [US2] Update confirmation output to emphasize branch preserved when flag is present in `.claude/commands/mykit.reset.md`

**Checkpoint**: `--keep-branch` flag works and output reflects branch preservation explicitly

---

## Phase 5: User Story 3 - --keep-specs Flag (Priority: P3)

**Goal**: Provide explicit spec preservation declaration in reset output

**Independent Test**: Run `/mykit.reset run --keep-specs`, verify state cleared and output confirms specs preserved

### Implementation for User Story 3

- [x] T016 [US3] Add --keep-specs flag handling to argument parsing in `.claude/commands/mykit.reset.md`
- [x] T017 [US3] Update preview output to show spec preservation when flag is present in `.claude/commands/mykit.reset.md`
- [x] T018 [US3] Update confirmation output to emphasize specs preserved when flag is present in `.claude/commands/mykit.reset.md`

**Checkpoint**: `--keep-specs` flag works and output reflects spec preservation explicitly

---

## Phase 6: User Story 4 - Combined Flags (Priority: P3)

**Goal**: Enable combining --keep-branch and --keep-specs flags

**Independent Test**: Run `/mykit.reset run --keep-branch --keep-specs`, verify both preservation messages appear

### Implementation for User Story 4

- [x] T019 [US4] Ensure flag parsing supports both flags simultaneously in `.claude/commands/mykit.reset.md`
- [x] T020 [US4] Update output formatting to show both preservation messages cleanly in `.claude/commands/mykit.reset.md`

**Checkpoint**: Combined flags work correctly with clear output

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Edge cases, --force flag, documentation

- [x] T021 Add --force flag handling to bypass preview mode in `.claude/commands/mykit.reset.md`
- [x] T022 Add Example Output section with all command variations in `.claude/commands/mykit.reset.md`
- [x] T023 Add Related Commands table linking to `/mykit.start`, `/mykit.resume`, `/mykit.status` in `.claude/commands/mykit.reset.md`
- [x] T024 Update `docs/COMMANDS.md` to document `/mykit.reset` command (if file exists)
- [x] T025 Run quickstart.md validation scenarios to verify implementation matches design

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - read reference commands
- **Foundational (Phase 2)**: Depends on Setup - creates command structure
- **User Story 1 (Phase 3)**: Depends on Foundational - implements core reset
- **User Story 2 (Phase 4)**: Depends on Phase 3 - adds --keep-branch
- **User Story 3 (Phase 5)**: Depends on Phase 3 - adds --keep-specs
- **User Story 4 (Phase 6)**: Depends on Phases 4 & 5 - combines flags
- **Polish (Phase 7)**: Depends on all user stories

### User Story Dependencies

- **User Story 1 (P1)**: Foundation for all other stories - MUST complete first
- **User Story 2 (P2)**: Can start after US1 - extends preview/confirm output
- **User Story 3 (P3)**: Can start after US1 - extends preview/confirm output
- **User Story 4 (P3)**: Depends on US2 AND US3 being complete

### Parallel Opportunities

Within Phase 1:
- T001 and T002 can run in parallel (reading different files)

Within User Story 1:
- T006-T007 (existence check) must complete before T008-T012

User Stories 2 and 3:
- US2 (Phase 4) and US3 (Phase 5) can run in parallel after US1 completes

---

## Parallel Example: Setup Phase

```bash
# Read both reference commands simultaneously:
Task: "Read .claude/commands/mykit.status.md for output patterns"
Task: "Read .claude/commands/mykit.resume.md for state handling patterns"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (read reference commands)
2. Complete Phase 2: Foundational (command structure)
3. Complete Phase 3: User Story 1 (core reset functionality)
4. **STOP and VALIDATE**: Test `/mykit.reset` and `/mykit.reset run`
5. MVP is functional - can be used immediately

### Incremental Delivery

1. Complete Setup + Foundational → Command structure ready
2. Add User Story 1 → Core reset works → **MVP Complete**
3. Add User Story 2 → `--keep-branch` flag works
4. Add User Story 3 → `--keep-specs` flag works
5. Add User Story 4 → Combined flags work
6. Polish → `--force` flag, documentation, examples

---

## Task Summary

| Phase | Story | Tasks | Description |
|-------|-------|-------|-------------|
| 1 | Setup | 2 | Reference existing patterns |
| 2 | Foundational | 3 | Command structure |
| 3 | US1 (P1) | 7 | Core reset functionality |
| 4 | US2 (P2) | 3 | --keep-branch flag |
| 5 | US3 (P3) | 3 | --keep-specs flag |
| 6 | US4 (P3) | 2 | Combined flags |
| 7 | Polish | 5 | Force flag, docs, examples |
| **Total** | | **25** | |

---

## Notes

- All tasks modify a single file: `.claude/commands/mykit.reset.md`
- This is a Claude Code slash command, not traditional code - tasks are documentation sections
- Each phase adds to the same file, building up the complete command definition
- No external dependencies or test framework required
- Validation is manual via Claude Code command invocation

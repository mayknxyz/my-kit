# Tasks: Curl-Based Installer

**Input**: Design documents from `/specs/001-curl-installer/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/cli-interface.md

**Tests**: Not requested - validation via manual testing and shellcheck static analysis.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Single file project**: `install.sh` at repository root
- **Target directories**: `.claude/commands/`, `.mykit/scripts/`, `.mykit/templates/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create the installer file with core structure and constants

- [x] T001 Create `install.sh` with shebang, strict mode (`set -euo pipefail`), and script header
- [x] T002 Define constants: REPO_URL, file manifest arrays (COMMAND_FILES, SCRIPT_FILES, TEMPLATE_FILES) in `install.sh`
- [x] T003 Define exit code constants (EXIT_SUCCESS=0, EXIT_ERROR=1, EXIT_PREREQ=2, EXIT_NETWORK=3, EXIT_FILESYSTEM=4) in `install.sh`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core functions that ALL user stories depend on - signal handling, cleanup, atomic installation framework

**CRITICAL**: No user story work can begin until this phase is complete

- [x] T004 Implement `cleanup()` function for temp directory removal in `install.sh`
- [x] T005 Implement signal trap setup (EXIT, INT, TERM) calling cleanup in `install.sh`
- [x] T006 Implement `create_temp_dir()` function using mktemp in `install.sh`
- [x] T007 Implement `download_file()` function using curl -fsSL in `install.sh`
- [x] T008 Implement `backup_existing()` function to backup current My Kit files before overwrite in `install.sh`
- [x] T009 Implement `restore_backup()` function for rollback on failure in `install.sh`
- [x] T010 Implement `atomic_move()` function to move files from temp to final locations in `install.sh`

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - First-Time Installation (Priority: P1) MVP

**Goal**: Enable users to install My Kit via single curl command with all files downloaded correctly

**Independent Test**: Run `curl -fsSL <url> | bash` on clean git repo, verify `.claude/commands/mykit.*.md` and `.mykit/scripts/*.sh` exist

### Implementation for User Story 1

- [x] T011 [US1] Implement `download_all_files()` to download commands, scripts, templates to temp dir in `install.sh`
- [x] T012 [US1] Implement `create_directories()` to ensure `.claude/commands/`, `.mykit/scripts/`, `.mykit/templates/lite/` exist in `install.sh`
- [x] T013 [US1] Implement `install_files()` to copy files from temp to final locations in `install.sh`
- [x] T014 [US1] Implement `create_default_config()` to create `.mykit/config.json` only if not exists in `install.sh`
- [x] T015 [US1] Implement `print_next_steps()` to display post-installation guidance in `install.sh`
- [x] T016 [US1] Wire up main execution flow: temp dir -> download -> install -> config -> next steps in `install.sh`

**Checkpoint**: User Story 1 complete - basic installation works end-to-end

---

## Phase 4: User Story 2 - Prerequisite Validation (Priority: P2)

**Goal**: Validate git and gh CLI are installed before proceeding; verify git repository

**Independent Test**: Run installer on system without git/gh; verify clear error messages with installation guidance

### Implementation for User Story 2

- [x] T017 [US2] Implement `check_command()` function using `command -v` in `install.sh`
- [x] T018 [US2] Implement `check_git_repo()` function using `git rev-parse --is-inside-work-tree` in `install.sh`
- [x] T019 [US2] Implement `check_write_permission()` function to verify directory is writable in `install.sh`
- [x] T020 [US2] Implement `print_prereq_error()` to display platform-specific installation guidance in `install.sh`
- [x] T021 [US2] Implement `check_all_prerequisites()` to run all checks and collect errors in `install.sh`
- [x] T022 [US2] Integrate prerequisite checks at start of main() before any file operations in `install.sh`

**Checkpoint**: User Story 2 complete - prerequisite failures show helpful messages

---

## Phase 5: User Story 3 - Installation Feedback (Priority: P3)

**Goal**: Provide clear progress feedback during installation

**Independent Test**: Run installer and verify progress messages appear for each step (checking, downloading, installing)

### Implementation for User Story 3

- [x] T023 [US3] Implement `info()` function for informational messages in `install.sh`
- [x] T024 [US3] Implement `success()` function for success checkmarks in `install.sh`
- [x] T025 [US3] Implement `error()` function for error messages to stderr in `install.sh`
- [x] T026 [US3] Add progress messages to prerequisite checking phase in `install.sh`
- [x] T027 [US3] Add progress messages to download phase (file counts) in `install.sh`
- [x] T028 [US3] Add progress messages to installation phase in `install.sh`
- [x] T029 [US3] Add final summary message with component locations in `install.sh`

**Checkpoint**: User Story 3 complete - installation provides clear feedback throughout

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final validation, edge cases, and code quality

- [x] T030 [P] Run shellcheck on `install.sh` and fix any warnings (shellcheck not available; bash -n syntax check passed)
- [ ] T031 [P] Test atomic rollback: interrupt mid-download and verify cleanup (manual test)
- [ ] T032 [P] Test idempotency: run installer twice, verify expected behavior (manual test)
- [ ] T033 [P] Test upgrade scenario: existing installation with modified config.json preserved (manual test)
- [x] T034 Ensure all exit codes match contract (0-4) in `install.sh`
- [ ] T035 Run quickstart.md validation: follow all steps on clean system (manual test)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-5)**: All depend on Foundational phase completion
  - US1 must complete before US2 and US3 (core flow needed first)
  - US2 and US3 can be done in parallel after US1
- **Polish (Phase 6)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - MVP delivery
- **User Story 2 (P2)**: Depends on US1 (needs main flow to integrate checks into)
- **User Story 3 (P3)**: Depends on US1 (needs main flow to add messages to)

### Within Each User Story

- Functions before integration
- Core implementation before edge cases
- Story complete before moving to next priority

### Parallel Opportunities

- **Phase 2**: T004-T010 are independent functions, can be written in parallel
- **Phase 4 & 5**: After US1 complete, US2 and US3 tasks can run in parallel
- **Phase 6**: T030-T033 are independent test scenarios, can run in parallel

---

## Parallel Example: Foundational Phase

```bash
# These functions can be written in parallel (independent utilities):
Task: "Implement cleanup() function in install.sh"
Task: "Implement download_file() function in install.sh"
Task: "Implement backup_existing() function in install.sh"
```

## Parallel Example: After US1 Complete

```bash
# US2 and US3 can progress in parallel:
Developer A: T017-T022 (Prerequisite Validation)
Developer B: T023-T029 (Installation Feedback)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001-T003)
2. Complete Phase 2: Foundational (T004-T010)
3. Complete Phase 3: User Story 1 (T011-T016)
4. **STOP and VALIDATE**: Test installation on clean git repo
5. Can deploy/demo basic installation capability

### Incremental Delivery

1. Setup + Foundational -> Core infrastructure ready
2. Add User Story 1 -> Test -> Deploy (MVP: basic installation works!)
3. Add User Story 2 -> Test -> Deploy (Better: helpful error messages)
4. Add User Story 3 -> Test -> Deploy (Complete: full user feedback)
5. Polish phase -> Production ready

### Single Developer Strategy

1. Complete Setup + Foundational sequentially
2. Complete US1 (MVP delivery point)
3. Complete US2 (error handling)
4. Complete US3 (polish)
5. Run all Phase 6 validations

---

## Notes

- Single file (`install.sh`) means no [P] markers within user stories - all tasks modify same file
- [P] markers only on Phase 2 (independent functions) and Phase 6 (independent tests)
- Manual testing per quickstart.md - no automated test suite
- shellcheck validation required before completion
- Commit after each phase or logical group of tasks

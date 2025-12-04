# Tasks: /mykit.setup - Onboarding Wizard

**Input**: Design documents from `/specs/003-setup-wizard/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md

**Tests**: Not explicitly requested - implementation tasks only.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Project type**: Single project (CLI toolkit)
- **Command files**: `.claude/commands/`
- **Scripts**: `.mykit/scripts/`
- **Config output**: `.mykit/config.json`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and script scaffolding

- [x] T001 Create setup-wizard.sh script file with shebang and strict mode in .mykit/scripts/setup-wizard.sh
- [x] T002 [P] Add script header documentation with usage and description in .mykit/scripts/setup-wizard.sh

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core wizard infrastructure that ALL user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [x] T003 Implement check_gh_auth() function for GitHub CLI auth detection in .mykit/scripts/setup-wizard.sh
- [x] T004 Implement detect_default_branch() function with fallback logic in .mykit/scripts/setup-wizard.sh
- [x] T005 [P] Implement prompt_boolean() helper for yes/no selections in .mykit/scripts/setup-wizard.sh
- [x] T006 [P] Implement prompt_string() helper for text input with defaults in .mykit/scripts/setup-wizard.sh
- [x] T007 Implement write_config() function with atomic temp file pattern in .mykit/scripts/setup-wizard.sh
- [x] T008 Implement read_existing_config() function for pre-population in .mykit/scripts/setup-wizard.sh
- [x] T009 Add trap handler for INT/TERM signals to clean up temp files in .mykit/scripts/setup-wizard.sh

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - First-Time Setup on Init (Priority: P1) 🎯 MVP

**Goal**: New user runs `/mykit.init` without config and wizard launches automatically, creating valid `.mykit/config.json`

**Independent Test**: Run `/mykit.init` in a repository with no `.mykit/config.json`. Wizard should launch, collect all settings, and create config file.

### Implementation for User Story 1

- [x] T010 [US1] Implement run_wizard() main function orchestrating all wizard steps in .mykit/scripts/setup-wizard.sh
- [x] T011 [US1] Add Step 1: GitHub auth check with warning output in run_wizard() in .mykit/scripts/setup-wizard.sh
- [x] T012 [US1] Add Step 2: Default branch detection and confirmation prompt in run_wizard() in .mykit/scripts/setup-wizard.sh
- [x] T013 [US1] Add Step 3: PR preferences prompts (auto-assign, draft mode) in run_wizard() in .mykit/scripts/setup-wizard.sh
- [x] T014 [US1] Add Step 4: Validation settings prompt (auto-fix) in run_wizard() in .mykit/scripts/setup-wizard.sh
- [x] T015 [US1] Add Step 5: Release settings prompt (version prefix) in run_wizard() in .mykit/scripts/setup-wizard.sh
- [x] T016 [US1] Add config file generation calling write_config() at wizard completion in .mykit/scripts/setup-wizard.sh
- [x] T017 [US1] Add success message and next steps guidance after config creation in .mykit/scripts/setup-wizard.sh
- [x] T018 [US1] Add cancel handling with cleanup message when user exits early in .mykit/scripts/setup-wizard.sh
- [x] T019 [US1] Update mykit.setup.md slash command to invoke setup-wizard.sh with 'run' action in .claude/commands/mykit.setup.md

**Checkpoint**: At this point, User Story 1 should be fully functional - first-time setup works end-to-end

---

## Phase 4: User Story 2 - Manual Setup Re-run (Priority: P2)

**Goal**: Existing user runs `/mykit.setup run` to reconfigure, with current values pre-filled

**Independent Test**: Run `/mykit.setup run` in a repository with existing `.mykit/config.json`. Wizard should show current values and allow modifications.

### Implementation for User Story 2

- [x] T020 [US2] Modify run_wizard() to call read_existing_config() when config exists in .mykit/scripts/setup-wizard.sh
- [x] T021 [US2] Update all prompts to show current values as defaults in prompt_boolean() and prompt_string() in .mykit/scripts/setup-wizard.sh
- [x] T022 [US2] Add logic to preserve unchanged values during re-run in .mykit/scripts/setup-wizard.sh
- [x] T023 [US2] Add "config updated" vs "config created" messaging based on prior existence in .mykit/scripts/setup-wizard.sh

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - Setup Preview Mode (Priority: P3)

**Goal**: User runs `/mykit.setup` (no action) to preview current config and wizard steps without modifications

**Independent Test**: Run `/mykit.setup` without action. Should display current/default configuration values and list wizard steps.

### Implementation for User Story 3

- [x] T024 [US3] Implement show_preview() function displaying current or default config values in .mykit/scripts/setup-wizard.sh
- [x] T025 [US3] Add wizard steps listing with descriptions in show_preview() in .mykit/scripts/setup-wizard.sh
- [x] T026 [US3] Add main script entry point parsing 'run' action vs preview mode in .mykit/scripts/setup-wizard.sh
- [x] T027 [US3] Update mykit.setup.md to show preview by default, require 'run' for execution in .claude/commands/mykit.setup.md

**Checkpoint**: All user stories should now be independently functional

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Edge cases, validation, and final quality checks

- [x] T028 [P] Add input validation for version prefix (allow empty or "v" only) in .mykit/scripts/setup-wizard.sh
- [x] T029 [P] Add JSON validation before writing config file in .mykit/scripts/setup-wizard.sh
- [x] T030 Handle partial config detection and offer to complete missing fields in .mykit/scripts/setup-wizard.sh
- [x] T031 [P] Add --help flag support to setup-wizard.sh in .mykit/scripts/setup-wizard.sh
- [x] T032 Run quickstart.md validation scenarios manually
- [x] T033 Verify shellcheck passes on .mykit/scripts/setup-wizard.sh

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can proceed sequentially in priority order (P1 → P2 → P3)
- **Polish (Final Phase)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Builds on US1 (modifies run_wizard) but is independently testable
- **User Story 3 (P3)**: Independent of US1/US2 (different code path for preview mode)

### Within Each User Story

- Helper functions before main logic
- Core implementation before integration
- Script changes before command file updates
- Story complete before moving to next priority

### Parallel Opportunities

- T002 can run in parallel with T001 (different sections of same file, but T001 creates file first)
- T005 and T006 can run in parallel (independent helper functions)
- T028 and T029 can run in parallel (independent validation functions)
- T031 can run in parallel with other polish tasks

---

## Parallel Example: Foundational Phase

```bash
# After T003-T004 complete, launch helper functions together:
Task: "Implement prompt_boolean() helper for yes/no selections in .mykit/scripts/setup-wizard.sh"
Task: "Implement prompt_string() helper for text input with defaults in .mykit/scripts/setup-wizard.sh"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001-T002)
2. Complete Phase 2: Foundational (T003-T009)
3. Complete Phase 3: User Story 1 (T010-T019)
4. **STOP and VALIDATE**: Test first-time setup flow
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP!)
3. Add User Story 2 → Test independently → Deploy/Demo
4. Add User Story 3 → Test independently → Deploy/Demo
5. Add Polish → Final validation

---

## Notes

- All implementation is in a single Bash script (.mykit/scripts/setup-wizard.sh)
- Slash command file (.claude/commands/mykit.setup.md) is updated in T019 and T027
- No test tasks included (tests not explicitly requested)
- JSON generation uses heredoc pattern from research.md
- Atomic file writes use temp file + mv pattern from research.md
- Follow Google Shell Style Guide and pass shellcheck

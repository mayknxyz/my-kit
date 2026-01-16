# Tasks: Validation Gates for Quality Enforcement

**Input**: Design documents from `specs/013-validation-gates/`
**Prerequisites**: spec.md (required), plan.md (required)

## Format: `[ID] [P?] Description`

- **[P]**: Can run in parallel (different files, no dependencies)

---

## Phase 1: Validation Infrastructure (Foundation)

**Purpose**: Build validation.sh script with tool checks and validation functions

**Critical Path**: Required for Phase 3

- [ ] T001 [P] Read existing utils.sh to understand helper patterns and error handling
- [ ] T002 Implement check_tool_available function in validation.sh for generic tool detection
- [ ] T003 Implement check_shellcheck function in validation.sh with version detection
- [ ] T004 Implement check_markdownlint function in validation.sh with version detection
- [ ] T005 Implement validate_shell_scripts function in validation.sh calling shellcheck on .mykit/scripts/*.sh
- [ ] T006 Implement validate_markdown function in validation.sh calling markdownlint on docs/, .claude/commands/
- [ ] T007 Implement aggregate_results function in validation.sh to combine shellcheck and markdownlint results
- [ ] T008 Implement format_validation_output function in validation.sh for user-friendly error display
- [ ] T009 Add graceful degradation for missing tools with warning messages in validation.sh
- [ ] T010 Test validation.sh functions by sourcing and calling directly with test files

**Checkpoint**: validation.sh complete and testable independently

---

## Phase 2: Git Operations Infrastructure

**Purpose**: Build git-ops.sh script with commit and CHANGELOG operations

**Critical Path**: Required for Phase 4

- [ ] T011 [P] Read existing git-ops.sh stub to understand structure
- [ ] T012 Implement has_uncommitted_changes function in git-ops.sh using git status --porcelain
- [ ] T013 Implement get_staged_files function in git-ops.sh for listing files to commit
- [ ] T014 Implement parse_conventional_commit function in git-ops.sh to extract type and scope
- [ ] T015 Implement determine_changelog_section function in git-ops.sh mapping commit types to sections
- [ ] T016 Implement update_changelog function in git-ops.sh to append entries to [Unreleased]
- [ ] T017 Implement generate_commit_message function in git-ops.sh analyzing changes
- [ ] T018 Implement create_commit function in git-ops.sh executing git commit with message
- [ ] T019 Test git-ops.sh functions by sourcing and calling with test repository

**Checkpoint**: git-ops.sh complete and testable independently

---

## Phase 3: /mykit.validate Command

**Purpose**: Validation command with preview and execute modes

**Dependencies**: Phase 1 (validation.sh)

- [ ] T020 Create .claude/commands/mykit.validate.md with Usage and Description sections
- [ ] T021 Implement Step 1: Git repository prerequisite check in mykit.validate.md
- [ ] T022 Implement Step 2: Argument parsing for `run` action in mykit.validate.md
- [ ] T023 Implement Step 3: No-action mode showing preview of files to validate
- [ ] T024 Implement Step 4: Tool availability check calling validation.sh functions
- [ ] T025 Implement Step 5: Run mode execution calling validate_shell_scripts and validate_markdown
- [ ] T026 Implement Step 6: Result display showing pass/fail counts and specific errors
- [ ] T027 Implement Step 7: State.json update with validation status, timestamp, and errors
- [ ] T028 Add error handling for missing validation.sh script
- [ ] T029 Test mykit.validate command in preview and run modes on test repository

**Checkpoint**: /mykit.validate command functional

---

## Phase 4: /mykit.commit Command

**Purpose**: Commit command with validation and CHANGELOG update

**Dependencies**: Phase 2 (git-ops.sh)

- [ ] T030 Create .claude/commands/mykit.commit.md with Usage and Description sections
- [ ] T031 Implement Step 1: Git repository prerequisite check in mykit.commit.md
- [ ] T032 Implement Step 2: Argument parsing for `create` action and `--force` flag
- [ ] T033 Implement Step 3: Uncommitted changes validation calling has_uncommitted_changes
- [ ] T034 Implement Step 4: No-action mode showing git diff and proposed commit message
- [ ] T035 Implement Step 5: Commit message generation analyzing staged changes
- [ ] T036 Implement Step 6: Conventional commit format prompt (feat, fix, docs, etc.)
- [ ] T037 Implement Step 7: CHANGELOG update calling update_changelog function
- [ ] T038 Implement Step 8: Commit creation calling create_commit function
- [ ] T039 Implement Step 9: Force flag handling with warning display
- [ ] T040 Implement Step 10: State.json update with commit SHA and timestamp
- [ ] T041 Add error messages for no changes, invalid commit type, etc.
- [ ] T042 Test mykit.commit command in preview and create modes

**Checkpoint**: /mykit.commit command functional

---

## Phase 5: Task Completion Validation

**Purpose**: Helper function to check tasks.md completion status

**Critical Path**: Required for Phase 6

- [ ] T043 [P] Read existing utils.sh to find best location for new function
- [ ] T044 Implement check_tasks_complete function in utils.sh
- [ ] T045 Implement parse_tasks_file function to extract all task markers from tasks.md
- [ ] T046 Implement find_incomplete_tasks function returning list of pending/in-progress tasks
- [ ] T047 Handle missing tasks.md file gracefully (not an error for ad-hoc branches)
- [ ] T048 Test check_tasks_complete with various tasks.md files (complete, incomplete, skipped)

**Checkpoint**: Task validation helper complete

---

## Phase 6: /mykit.pr Command

**Purpose**: PR command with comprehensive validation gates

**Dependencies**: Phase 3 (/mykit.validate), Phase 5 (task checking)

- [ ] T049 Create .claude/commands/mykit.pr.md with Usage and Description sections
- [ ] T050 Implement Step 1: Git repository prerequisite check in mykit.pr.md
- [ ] T051 Implement Step 2: Feature branch prerequisite check (issue number pattern)
- [ ] T052 Implement Step 3: Argument parsing for `create` action and `--force` flag
- [ ] T053 Implement Step 4: Validation gate 1 - Check tasks.md completion calling check_tasks_complete
- [ ] T054 Implement Step 5: Validation gate 2 - Check validation status from state.json
- [ ] T055 Implement Step 6: Validation gate 3 - Check commits exist on branch
- [ ] T056 Implement Step 7: Extract issue number from branch name for PR reference
- [ ] T057 Implement Step 8: Read spec.md for PR summary (if exists)
- [ ] T058 Implement Step 9: Read plan.md for PR context (if exists)
- [ ] T059 Implement Step 10: Get commit list for PR description
- [ ] T060 Implement Step 11: Generate PR description from spec/plan/commits
- [ ] T061 Implement Step 12: No-action mode showing PR preview
- [ ] T062 Implement Step 13: PR creation using gh pr create with "Closes #N"
- [ ] T063 Implement Step 14: Force flag handling with warnings for each bypassed gate
- [ ] T064 Implement Step 15: State.json update with PR URL and number
- [ ] T065 Add comprehensive error messages for each validation gate failure
- [ ] T066 Test mykit.pr command with complete and incomplete feature branches

**Checkpoint**: /mykit.pr command functional with all gates

---

## Phase 7: Templates and Distribution

**Purpose**: Create templates for installation and upgrade

**Dependencies**: Phase 3, 4, 6 (all commands complete)

- [ ] T067 [P] Copy .claude/commands/mykit.validate.md to .mykit/templates/commands/mykit.validate.md
- [ ] T068 [P] Copy .claude/commands/mykit.commit.md to .mykit/templates/commands/mykit.commit.md
- [ ] T069 [P] Copy .claude/commands/mykit.pr.md to .mykit/templates/commands/mykit.pr.md
- [ ] T070 Verify templates are byte-identical to command files

**Checkpoint**: Templates ready for distribution

---

## Phase 8: Documentation and Completion

**Purpose**: Update documentation and verify implementation

- [ ] T071 Update docs/COMMANDS.md with /mykit.validate command documentation
- [ ] T072 Update docs/COMMANDS.md with /mykit.commit command documentation (replace stub)
- [ ] T073 Update docs/COMMANDS.md with /mykit.pr command documentation (replace stub)
- [ ] T074 Add validation gates section to docs/COMMANDS.md explaining --force flag
- [ ] T075 Update CHANGELOG.md with [Unreleased] entries for three new commands
- [ ] T076 Update README.md workflow diagram if validation steps should be shown
- [ ] T077 Run /mykit.validate run on the repository to validate our own code
- [ ] T078 Commit changes using /mykit.commit create
- [ ] T079 Create PR using /mykit.pr create

**Checkpoint**: Feature complete and documented

---

## Summary

**Total Tasks**: 79 tasks across 8 phases
**Estimated Duration**: 8-12 hours
**Parallelizable**: T001, T011, T043, T067-T070 (7 tasks)

**Critical Path**:
Phase 1 → Phase 3 → Phase 6 → Phase 7 → Phase 8

**Key Deliverables**:
- `.mykit/scripts/validation.sh` (full implementation)
- `.mykit/scripts/git-ops.sh` (full implementation)
- `.mykit/scripts/utils.sh` (enhanced with task checking)
- `.claude/commands/mykit.validate.md` (new command)
- `.claude/commands/mykit.commit.md` (new command)
- `.claude/commands/mykit.pr.md` (new command)
- `.mykit/templates/commands/*.md` (3 templates)
- Updated documentation files

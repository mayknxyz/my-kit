# Tasks: Self-Upgrade Command

**Input**: Design documents from `/specs/002-mykit-upgrade/`
**Prerequisites**: plan.md ✓, spec.md ✓, research.md ✓, data-model.md ✓, quickstart.md ✓

**Tests**: Not requested - implementation tasks only.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3, US4)
- Include exact file paths in descriptions

## Path Conventions

- **Scripts**: `.mykit/scripts/` at repository root
- **Commands**: `.claude/commands/` at repository root
- **Backups**: `.mykit/backup/` at repository root
- **Manifests**: `.mykit/.manifests/` at repository root

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure for upgrade feature

- [X] T001 Create backup directory structure at .mykit/backup/.last-backup/
- [X] T002 Create manifests directory structure at .mykit/.manifests/
- [X] T003 [P] Add upgrade-related entries to .gitignore (backup/, lock files)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T004 Implement version utilities in .mykit/scripts/version.sh:
  - `get_current_version()` - Get installed version from git tag
  - `get_latest_version()` - Fetch latest from GitHub via gh CLI
  - `is_upgrade_available()` - Compare versions using sort -V with Bash fallback
  - `version_compare()` - Pure Bash version comparison fallback
  - `version_exists()` - Validate version tag exists on remote
- [X] T005 [P] Implement checksum utilities in .mykit/scripts/version.sh:
  - `calculate_checksum()` - Cross-platform SHA-256 (sha256sum/shasum/openssl)
  - `detect_modified_files()` - Compare local files against manifest
  - `generate_manifest()` - Create checksum manifest for a version
- [X] T006 [P] Implement lock file utilities in .mykit/scripts/upgrade.sh:
  - `acquire_lock()` - flock-based locking with timeout
  - `cleanup_lock()` - Release lock and clean up
  - Lock file location: `${XDG_RUNTIME_DIR}/mykit-upgrade.lock` or `/var/tmp/mykit-upgrade.lock`
- [X] T007 [P] Implement backup utilities in .mykit/scripts/upgrade.sh:
  - `create_backup()` - Backup commands/, scripts/, templates/ to .mykit/backup/.last-backup/
  - `restore_backup()` - Restore from .mykit/backup/.last-backup/
  - Record backup metadata (.backup-time, .backup-version)
- [X] T008 Implement core upgrade functions in .mykit/scripts/upgrade.sh:
  - `download_files()` - Fetch files from GitHub release via curl/gh
  - `verify_checksums()` - Validate downloaded files against manifest
  - `install_files()` - Copy files to target locations
  - `run_upgrade()` - Orchestrate full upgrade workflow with error handling

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Preview Available Updates (Priority: P1) 🎯 MVP

**Goal**: Users can see current version, latest version, and changelog summary without making any changes

**Independent Test**: Run `/mykit.upgrade` and verify it displays version info without modifying files

### Implementation for User Story 1

- [X] T009 [US1] Implement `list_all_versions()` in .mykit/scripts/version.sh:
  - Fetch versions via `gh release list --repo mayknxyz/my-kit`
  - Parse tagName and publishedAt fields
  - Return formatted version list
- [X] T010 [US1] Implement `get_changelog()` in .mykit/scripts/version.sh:
  - Fetch release body via `gh release view`
  - Parse and format changelog summary
- [X] T011 [US1] Implement preview mode in .mykit/scripts/upgrade.sh:
  - `show_preview()` - Display current version, latest version, changelog
  - Handle "already up to date" case
  - Handle network connectivity errors with clear messages
- [X] T012 [US1] Create slash command definition in .claude/commands/mykit.upgrade.md:
  - Preview mode as default (no flags)
  - Display instructions for `--run` to execute
  - Follow My Kit command conventions

**Checkpoint**: User Story 1 complete - users can preview available updates

---

## Phase 4: User Story 2 - Upgrade to Latest Version (Priority: P1)

**Goal**: Users can upgrade to latest version with backup, verification, and rollback on failure

**Independent Test**: Run `/mykit.upgrade --run` and verify files are updated while config.json is preserved

### Implementation for User Story 2

- [X] T013 [US2] Implement dependency validation in .mykit/scripts/upgrade.sh:
  - `validate_dependencies()` - Check curl, git, gh CLI availability
  - Validate write permissions to installation directory
  - Check disk space for backup (FR-012)
- [X] T014 [US2] Implement configuration preservation in .mykit/scripts/upgrade.sh:
  - Ensure .mykit/config.json is never overwritten (FR-004)
  - Handle config references to removed features (warning only)
- [X] T015 [US2] Implement error recovery in .mykit/scripts/upgrade.sh:
  - Detect incomplete upgrade state (handles interrupted downloads per Edge Case L78)
  - Auto-restore from backup on any failure (FR-005)
  - Provide clear error messages with exit codes
- [X] T016 [US2] Update .claude/commands/mykit.upgrade.md for execution mode:
  - `--run` flag triggers actual upgrade
  - Progress output: dependencies validated, backup created, files downloaded, checksums verified, files installed
  - Success/failure messaging

**Checkpoint**: User Stories 1 and 2 complete - core upgrade functionality works

---

## Phase 5: User Story 3 - List Available Versions (Priority: P2)

**Goal**: Users can see all available versions with release dates and identify their current version

**Independent Test**: Run `/mykit.upgrade --list` and verify all versions display with current marked

### Implementation for User Story 3

- [X] T017 [US3] Implement formatted version listing in .mykit/scripts/version.sh:
  - `format_version_list()` - Format versions with dates, mark current and latest
  - Order from newest to oldest
  - Include release date in format: `v0.2.0 (2025-12-04)`
- [X] T018 [US3] Update .claude/commands/mykit.upgrade.md for list mode:
  - `--list` flag shows all versions
  - Mark current version with `*` prefix
  - Mark latest version with `← latest` suffix

**Checkpoint**: User Story 3 complete - users can view all available versions

---

## Phase 6: User Story 4 - Upgrade to Specific Version (Priority: P2)

**Goal**: Users can upgrade or downgrade to a specific version with appropriate warnings

**Independent Test**: Run `/mykit.upgrade --run --version v0.2.0` and verify exact version is installed

### Implementation for User Story 4

- [X] T019 [US4] Implement version pinning in .mykit/scripts/upgrade.sh:
  - Accept `--version` parameter
  - Validate version exists before attempting upgrade (FR-008)
  - Show error with available versions if invalid
- [X] T020 [US4] Implement downgrade warning in .mykit/scripts/upgrade.sh:
  - `is_downgrade()` - Detect if target version is older than current
  - Display warning about potential issues (FR-009)
  - Require confirmation for downgrade
- [X] T021 [US4] Update .claude/commands/mykit.upgrade.md for version pinning:
  - `--version X` flag with `--run` to upgrade to specific version
  - Downgrade warning display
  - Invalid version error handling

**Checkpoint**: User Story 4 complete - all user stories implemented

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Edge cases, hardening, and cross-cutting improvements

- [X] T022 [P] Implement modified file detection in .mykit/scripts/upgrade.sh:
  - Warn user about locally modified files (FR-013)
  - Preserve modified files in backup
  - Allow upgrade to proceed after warning
- [X] T023 [P] Implement concurrent upgrade prevention in .mykit/scripts/upgrade.sh:
  - Use lock file with flock (FR-014)
  - Display PID of blocking process
  - Provide manual unlock instructions
- [X] T024 Implement exit codes per quickstart.md in .mykit/scripts/upgrade.sh:
  - 0: Success
  - 1: General error (lock failed, invalid version)
  - 2: Pre-condition failure (validation gate blocked)
  - 3: Network error
  - 4: Filesystem error
- [X] T025 Run quickstart.md validation scenarios manually
- [X] T026 Validate performance requirements manually:
  - SC-001: Version check completes in under 5 seconds
  - SC-002: Full upgrade completes in under 30 seconds
  - SC-004: Backup restore completes in under 10 seconds
  - Document results in quickstart.md testing notes

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-6)**: All depend on Foundational phase completion
  - US1 (Preview) and US2 (Upgrade) are both P1, implement in order
  - US3 (List) and US4 (Specific Version) are P2, implement after P1 stories
- **Polish (Phase 7)**: Can start after Phase 2, ideally after all stories complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational - No dependencies on other stories
- **User Story 2 (P1)**: Can start after Foundational - Builds on US1 infrastructure
- **User Story 3 (P2)**: Can start after Foundational - Independent of US1/US2
- **User Story 4 (P2)**: Can start after Foundational - Builds on US2 upgrade logic

### Within Each Phase

- Tasks marked [P] can run in parallel
- Non-[P] tasks should run sequentially as listed
- Commit after each task or logical group

### Parallel Opportunities

**Phase 1 (Setup)**:
- T003 can run in parallel with T001, T002

**Phase 2 (Foundational)**:
- T005, T006, T007 can all run in parallel (different functions/files)
- T004 should complete before T008
- T008 depends on T004, T005, T006, T007

**Phase 7 (Polish)**:
- T022, T023 can run in parallel

---

## Parallel Example: Foundational Phase

```bash
# Launch parallel utility implementations:
Task: "Implement checksum utilities in .mykit/scripts/version.sh"
Task: "Implement lock file utilities in .mykit/scripts/upgrade.sh"
Task: "Implement backup utilities in .mykit/scripts/upgrade.sh"

# Then sequentially:
Task: "Implement version utilities in .mykit/scripts/version.sh"
Task: "Implement core upgrade functions in .mykit/scripts/upgrade.sh"
```

---

## Implementation Strategy

### MVP First (User Story 1 + 2)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1 (Preview)
4. Complete Phase 4: User Story 2 (Upgrade)
5. **STOP and VALIDATE**: Test preview and upgrade independently
6. Deploy/demo if ready - users can preview and upgrade to latest

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test preview → Users can check for updates
3. Add User Story 2 → Test upgrade → Users can upgrade (MVP!)
4. Add User Story 3 → Test listing → Users can see all versions
5. Add User Story 4 → Test pinning → Users can pin versions
6. Add Polish → Complete feature

---

## Notes

- [P] tasks = different files or independent functions, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently testable via quickstart.md scenarios
- Config.json must NEVER be overwritten during upgrade
- Lock file prevents concurrent upgrades automatically via flock
- Backup is single retention - overwritten on each upgrade
- Follow existing patterns from install.sh where applicable

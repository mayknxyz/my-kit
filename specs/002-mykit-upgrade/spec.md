# Feature Specification: Self-Upgrade Command

**Feature Branch**: `002-mykit-upgrade`
**Created**: 2025-12-04
**Status**: Draft
**Input**: User description: "feat: /mykit.upgrade - self-upgrade command refer to github issue #2"
**GitHub Issue**: #2

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Preview Available Updates (Priority: P1)

As a My Kit user, I want to preview what updates are available before upgrading so that I can decide whether to proceed with the upgrade.

**Why this priority**: This is the most common entry point - users need to see what's available before committing to any changes. Preview-by-default follows the project's command conventions.

**Independent Test**: Can be fully tested by running `/mykit.upgrade` without any flags and verifying it shows current version, latest version, and change summary without modifying any files.

**Acceptance Scenarios**:

1. **Given** My Kit is installed at version 0.1.0, **When** I run `/mykit.upgrade`, **Then** I see my current version, the latest available version, and a summary of changes between them
2. **Given** My Kit is already at the latest version, **When** I run `/mykit.upgrade`, **Then** I see a message indicating I'm already up to date
3. **Given** there is no network connectivity, **When** I run `/mykit.upgrade`, **Then** I see a clear error message explaining the connection issue

---

### User Story 2 - Upgrade to Latest Version (Priority: P1)

As a My Kit user, I want to upgrade to the latest version so that I have the newest features and fixes.

**Why this priority**: This is the core functionality - the primary action users want to perform. Equal priority to preview since both are essential.

**Independent Test**: Can be fully tested by running `/mykit.upgrade --run` and verifying that all My Kit files are updated to the latest version while preserving user configuration.

**Acceptance Scenarios**:

1. **Given** My Kit is installed at version 0.1.0 and version 0.2.0 is available, **When** I run `/mykit.upgrade --run`, **Then** My Kit files are updated to version 0.2.0 and my configuration is preserved
2. **Given** an upgrade is in progress, **When** the upgrade encounters an error, **Then** the system restores from backup and shows an error message with details
3. **Given** My Kit is already at the latest version, **When** I run `/mykit.upgrade --run`, **Then** I see a message indicating no upgrade is needed

---

### User Story 3 - List Available Versions (Priority: P2)

As a My Kit user, I want to see a list of all available versions so that I can choose a specific version to install.

**Why this priority**: Supporting feature that enables version pinning. Less commonly needed than basic upgrade flow.

**Independent Test**: Can be fully tested by running `/mykit.upgrade --list` and verifying it displays all available versions with release dates and brief descriptions.

**Acceptance Scenarios**:

1. **Given** multiple versions exist (0.1.0, 0.2.0, 0.3.0), **When** I run `/mykit.upgrade --list`, **Then** I see all versions listed with their release dates, ordered from newest to oldest
2. **Given** I'm on version 0.1.0, **When** I run `/mykit.upgrade --list`, **Then** my current version is clearly marked in the list

---

### User Story 4 - Upgrade to Specific Version (Priority: P2)

As a My Kit user, I want to upgrade (or downgrade) to a specific version so that I can pin to a version that works for my workflow.

**Why this priority**: Power user feature for version pinning. Important for teams that need stability but not needed for basic usage.

**Independent Test**: Can be fully tested by running `/mykit.upgrade --run --version 0.2.0` and verifying that exact version is installed.

**Acceptance Scenarios**:

1. **Given** versions 0.1.0, 0.2.0, 0.3.0 exist and I'm on 0.1.0, **When** I run `/mykit.upgrade --run --version 0.2.0`, **Then** My Kit is updated to exactly version 0.2.0
2. **Given** I'm on version 0.3.0, **When** I run `/mykit.upgrade --run --version 0.2.0`, **Then** My Kit is downgraded to version 0.2.0 with a warning that this is a downgrade
3. **Given** version 9.9.9 does not exist, **When** I run `/mykit.upgrade --run --version 9.9.9`, **Then** I see an error message listing valid versions

---

### Edge Cases

- What happens when the user has modified core My Kit files? The system detects modifications by comparing file checksums against known values from the installed version, warns the user, but allows the upgrade to proceed while preserving a backup of modified files.
- What happens when disk space is insufficient for backup? The upgrade should fail gracefully before making any changes.
- What happens when the upgrade is interrupted (e.g., network drops mid-download)? The system should detect incomplete state and allow re-running the upgrade.
- What happens when user config references features removed in new version? The upgrade should complete but warn about deprecated configuration.
- What happens when a user runs upgrade while another is in progress? The system uses a lock file to prevent concurrent upgrades and shows an error if locked.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST check and compare current installed version against available versions from the remote repository
- **FR-002**: System MUST display current version, latest version, and changelog summary in preview mode
- **FR-003**: System MUST create a backup of current installation before performing any upgrade
- **FR-004**: System MUST preserve user configuration files (`.mykit/config.json`) during upgrade
- **FR-005**: System MUST restore from backup if upgrade fails at any point
- **FR-006**: System MUST support listing all available versions with release information
- **FR-007**: System MUST support upgrading to a specific version via `--version` flag
- **FR-008**: System MUST validate version exists before attempting upgrade
- **FR-009**: System MUST warn users when downgrading to an older version
- **FR-010**: System MUST follow the action-based command pattern (preview by default, `--run` to execute)
- **FR-011**: System MUST provide clear error messages for network failures, invalid versions, and other error conditions
- **FR-012**: System MUST validate required dependencies (curl, git, gh) are available before upgrade
- **FR-013**: System MUST detect local file modifications by comparing checksums against known values from the installed version and warn users before overwriting
- **FR-014**: System MUST use a lock file to prevent concurrent upgrade operations and display an error if another upgrade is in progress

### Key Entities

- **Version**: Represents a release of My Kit with version number (semver format), release date, and changelog
- **Backup**: A copy of the current installation before upgrade, including all files in `.claude/commands/` and `.mykit/`. Only the most recent backup is retained; previous backups are overwritten on each upgrade.
- **Configuration**: User settings stored in `.mykit/config.json` that persist across upgrades

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can check for available updates in under 5 seconds on standard internet connection
- **SC-002**: Users can complete a full upgrade in under 30 seconds on standard internet connection
- **SC-003**: 100% of user configuration is preserved after successful upgrade
- **SC-004**: Failed upgrades result in complete restoration to pre-upgrade state within 10 seconds
- **SC-005**: Users can list all available versions and identify their current version at a glance
- **SC-006**: Users can upgrade to any specific available version in a single command

## Assumptions

- Users have internet connectivity when running upgrade commands
- The GitHub repository (mayknxyz/my-kit) hosts version tags following semver format (vX.Y.Z)
- Users have write permissions to the My Kit installation directory
- Backup storage uses local filesystem at `.mykit/backup/.last-backup/` (single backup retained)
- Version information is retrieved from GitHub releases/tags via the gh CLI or git

## Clarifications

### Session 2025-12-04

- Q: How many backups should be retained? → A: Keep only the most recent backup (overwrite on next upgrade)
- Q: How should modified files be detected? → A: Compare file checksums against known values from installed version
- Q: How to handle concurrent upgrade attempts? → A: Use lock file to prevent concurrent upgrades; show error if locked

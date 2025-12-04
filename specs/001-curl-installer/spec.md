# Feature Specification: Curl-Based Installer

**Feature Branch**: `001-curl-installer`
**Created**: 2025-12-04
**Status**: Draft
**Input**: User description: "feat: install.sh - curl-based installer - refer/link to gh issue #1"
**GitHub Issue**: [#1](https://github.com/mayknxyz/my-kit/issues/1)

## Clarifications

### Session 2025-12-04

- Q: When existing directories contain files, what should the installer do? → A: Overwrite only My Kit files, preserve unrecognized files
- Q: If a file download fails mid-installation, what should happen? → A: Roll back all changes (atomic: all-or-nothing installation)
- Q: If user cancels mid-installation (Ctrl+C), what should happen? → A: Trap interrupt, perform cleanup/rollback, then exit
- Q: Should installer require target directory to be a git repository? → A: Yes, fail with helpful message if not a git repo

## Overview

A single-command installer that allows users to install My Kit directly from the repository using curl. The installer enables easy public distribution without requiring users to manually clone the repository or download files individually.

**Installation Command**:
```bash
curl -fsSL https://raw.githubusercontent.com/mayknxyz/my-kit/main/install.sh | bash
```

## User Scenarios & Testing *(mandatory)*

### User Story 1 - First-Time Installation (Priority: P1)

A developer wants to quickly install My Kit on their system to start using the spec-driven development workflow. They run the curl installation command and have a fully functional My Kit setup within seconds.

**Why this priority**: This is the core functionality - without successful installation, no other features matter. This enables the primary distribution mechanism for the toolkit.

**Independent Test**: Can be fully tested by running the curl command on a clean system with prerequisites installed and verifying all My Kit commands are available.

**Acceptance Scenarios**:

1. **Given** a system with git and gh CLI installed, **When** the user runs the curl installation command, **Then** all command files are downloaded to `.claude/commands/` and all scripts are downloaded to `.mykit/scripts/`

2. **Given** a system with git and gh CLI installed, **When** the installation completes, **Then** a default configuration is created and the user sees clear next steps for using My Kit

3. **Given** a successful installation, **When** the user opens Claude Code in the project, **Then** all `/mykit.*` slash commands are available and functional

---

### User Story 2 - Prerequisite Validation (Priority: P2)

A developer attempts to install My Kit but is missing required dependencies. The installer checks for prerequisites and provides clear guidance on what needs to be installed before proceeding.

**Why this priority**: Users need clear feedback when installation cannot proceed, preventing partial or broken installations and reducing support burden.

**Independent Test**: Can be tested by running the installer on a system missing git or gh CLI and verifying appropriate error messages are displayed.

**Acceptance Scenarios**:

1. **Given** a system without git installed, **When** the user runs the curl installation command, **Then** the installer displays a clear error message indicating git is required and provides installation guidance

2. **Given** a system without gh CLI installed, **When** the user runs the curl installation command, **Then** the installer displays a clear error message indicating gh CLI is required and provides installation guidance

3. **Given** a system missing multiple prerequisites, **When** the user runs the curl installation command, **Then** all missing prerequisites are listed together with installation guidance for each

---

### User Story 3 - Installation Feedback (Priority: P3)

A developer wants to know what the installer is doing during execution. The installer provides progress feedback so users understand what's being installed and where.

**Why this priority**: Transparency builds user trust and helps with troubleshooting if issues occur.

**Independent Test**: Can be tested by running the installer and verifying progress messages are displayed for each installation step.

**Acceptance Scenarios**:

1. **Given** a user running the installer, **When** each installation step executes, **Then** the user sees a progress indicator or message describing what's happening

2. **Given** a successful installation, **When** the installer finishes, **Then** a summary of installed components and their locations is displayed

---

### Edge Cases

- If no internet connectivity: Download fails, atomic rollback triggered, clear error message displayed
- If directory lacks write permissions: Fail early with clear error message before any downloads
- When `.claude/commands/` or `.mykit/scripts/` directories already exist: Installer overwrites only My Kit files (known filenames), preserving any unrecognized user-added files
- If download fails mid-installation: Roll back all changes to restore previous state (atomic installation)
- If user cancels mid-process (Ctrl+C): Trap interrupt signal, perform cleanup/rollback, then exit cleanly

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Installer MUST check for required prerequisites (git, gh CLI) before proceeding with installation
- **FR-002**: Installer MUST verify the current directory is a git repository and fail with a helpful message if not
- **FR-003**: Installer MUST download all command files to the `.claude/commands/` directory relative to the user's current working directory
- **FR-004**: Installer MUST download all script files to the `.mykit/scripts/` directory relative to the user's current working directory
- **FR-005**: Installer MUST create a default configuration if one does not exist
- **FR-006**: Installer MUST display clear next steps after successful installation
- **FR-007**: Installer MUST provide clear error messages when prerequisites are missing, including guidance on how to install them
- **FR-008**: Installer MUST be executable via single curl command: `curl -fsSL <url> | bash`
- **FR-009**: Installer MUST display progress feedback during installation steps
- **FR-010**: Installer MUST handle existing directories gracefully by overwriting only known My Kit files while preserving unrecognized user-added files
- **FR-011**: Installer MUST exit with appropriate status codes (0 for success, non-zero for failure)
- **FR-012**: Installer MUST implement atomic installation - if any step fails, roll back all changes to restore previous state
- **FR-013**: Installer MUST trap interrupt signals (Ctrl+C) and perform cleanup/rollback before exiting

### Key Entities

- **Command Files**: Slash command definitions (`.md` files) that define My Kit's CLI interface, stored in `.claude/commands/`
- **Script Files**: Shell utilities that support command execution, stored in `.mykit/scripts/`
- **Configuration**: Default settings for My Kit operation, created during installation

## Assumptions

- Users have a POSIX-compliant shell environment (bash, zsh, etc.)
- Users have curl installed (required to run the installation command)
- Users are running the installer from the root of an initialized git repository where they want to use My Kit
- The GitHub repository is publicly accessible
- Raw file access via `raw.githubusercontent.com` is available to the user

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can complete the full installation in under 30 seconds on a typical internet connection
- **SC-002**: 100% of prerequisite issues are detected and reported before any files are downloaded
- **SC-003**: Users can immediately use all My Kit commands after installation without additional configuration
- **SC-004**: 95% of users successfully complete installation on first attempt when prerequisites are met
- **SC-005**: Error messages enable users to resolve issues without external documentation or support

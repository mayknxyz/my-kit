# Feature Specification: /mykit.setup - Onboarding Wizard

**Feature Branch**: `003-setup-wizard`
**Created**: 2025-12-05
**Status**: Draft
**GitHub Issue**: [#3](https://github.com/mayknxyz/my-kit/issues/3)
**Input**: Interactive first-time setup wizard for configuring My Kit preferences

## User Scenarios & Testing *(mandatory)*

### User Story 1 - First-Time Setup on Init (Priority: P1)

A new user installs My Kit and runs `/mykit.init` for the first time. Since no configuration exists, the setup wizard automatically launches to guide them through essential configuration steps, ensuring they can use My Kit commands immediately after completion.

**Why this priority**: This is the primary entry point for new users. Without a working configuration, users cannot effectively use My Kit. Automating setup on first init removes friction and prevents configuration errors.

**Independent Test**: Can be fully tested by running `/mykit.init` in a repository with no `.mykit/config.json` file. Delivers a complete, valid configuration file upon completion.

**Acceptance Scenarios**:

1. **Given** a repository with no `.mykit/config.json`, **When** user runs `/mykit.init`, **Then** the setup wizard launches automatically
2. **Given** the setup wizard is running, **When** user completes all steps, **Then** `.mykit/config.json` is created with user preferences
3. **Given** the setup wizard is running, **When** user cancels the wizard, **Then** no configuration file is created and user is informed they can run setup later

---

### User Story 2 - Manual Setup Re-run (Priority: P2)

An existing user wants to update their My Kit configuration preferences. They run `/mykit.setup run` to re-launch the wizard and modify their settings without manually editing the config file.

**Why this priority**: Users' preferences change over time. Providing a guided way to reconfigure ensures users don't have to remember config file structure or valid option values.

**Independent Test**: Can be tested by running `/mykit.setup run` in a repository with an existing `.mykit/config.json`. Delivers an updated configuration file with new preferences.

**Acceptance Scenarios**:

1. **Given** a repository with existing `.mykit/config.json`, **When** user runs `/mykit.setup run`, **Then** the wizard launches and pre-fills current values
2. **Given** the wizard shows current config values, **When** user modifies settings and completes wizard, **Then** `.mykit/config.json` is updated with new values
3. **Given** the wizard is running, **When** user cancels without changes, **Then** existing configuration remains unchanged

---

### User Story 3 - Setup Preview Mode (Priority: P3)

A user wants to see what the setup wizard will configure without actually running it. They run `/mykit.setup` (without action) to preview the configuration steps and current values.

**Why this priority**: Follows the project's "preview by default" convention. Users should be able to understand what a command will do before committing to changes.

**Independent Test**: Can be tested by running `/mykit.setup` without action. Displays current configuration status and available settings without modifying anything.

**Acceptance Scenarios**:

1. **Given** any repository state, **When** user runs `/mykit.setup` without action, **Then** system displays current configuration values and wizard steps
2. **Given** no configuration exists, **When** user runs `/mykit.setup` without action, **Then** system shows what will be configured with default values

---

### Edge Cases

- What happens when GitHub CLI (`gh`) is not installed or not authenticated?
  - Wizard detects missing/unauthenticated `gh` and prompts user to install/authenticate before proceeding
- What happens when user has partial configuration (some settings but not all)?
  - Wizard detects incomplete config and offers to complete missing settings
- What happens when wizard is interrupted mid-way (terminal closed, Ctrl+C)?
  - No partial config is written; user is informed to run setup again
- What happens when `.mykit/` directory exists but `config.json` does not?
  - Wizard proceeds with creating `config.json` in existing directory

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Wizard MUST check GitHub CLI authentication status before proceeding with GitHub-related settings
- **FR-002**: Wizard MUST detect and configure the default branch (e.g., main, master) for the repository
- **FR-003**: Wizard MUST allow users to configure PR preferences: auto-assign (boolean) and draft mode default (boolean)
- **FR-004**: Wizard MUST allow users to configure validation settings including auto-fix behavior
- **FR-005**: Wizard MUST allow users to configure release settings: version prefix (string, e.g., "v" or empty)
- **FR-006**: Wizard MUST create `.mykit/config.json` upon successful completion
- **FR-007**: Wizard MUST be triggered automatically when `/mykit.init` runs and no config exists
- **FR-008**: Wizard MUST be manually triggerable via `/mykit.setup run`
- **FR-009**: Wizard MUST show preview of configuration when run without action
- **FR-010**: Wizard MUST pre-populate current values when re-running with existing config
- **FR-011**: Wizard MUST validate all inputs before writing configuration
- **FR-012**: Wizard MUST NOT write partial configuration if user cancels or wizard is interrupted

### Key Entities

- **Configuration**: User preferences stored in `.mykit/config.json` including GitHub settings, PR preferences, validation rules, and release settings
- **Setup Step**: An individual configuration category (GitHub auth, default branch, PR preferences, validation, release) with its prompts and valid options

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can complete the full setup wizard in under 2 minutes
- **SC-002**: 100% of completed wizard runs result in a valid, parseable configuration file
- **SC-003**: Users can successfully use any My Kit command immediately after completing setup
- **SC-004**: 90% of first-time users complete setup without errors or needing to restart

## Clarifications

### Session 2025-12-05

- Q: What PR preferences should be configurable? → A: Auto-assign and draft mode only (as specified in Issue #3)
- Q: What release settings should be configurable? → A: Version prefix only (e.g., "v" for v1.0.0 vs bare 1.0.0)

## Assumptions

- Users have basic familiarity with command-line interfaces
- GitHub CLI (`gh`) is the standard tool for GitHub authentication (industry standard for CLI-based GitHub workflows)
- Interactive prompts follow standard terminal input patterns (text input, selection menus)
- Configuration file format follows standard JSON conventions

# Feature Specification: /mykit.help Command

**Feature Branch**: `005-help`
**Created**: 2025-12-05
**Status**: Draft
**Input**: User description: "feat: /mykit.help refer to github issue #5"
**GitHub Issue**: #5

## Clarifications

### Session 2025-12-06

- Q: What happens when user runs help from outside a My Kit-enabled repository? → A: Works anywhere - show full help regardless of repository context
- Q: Which syntax for workflow help - positional or flag? → A: Positional only (`/mykit.help workflow`) for consistency with command-specific help

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Quick Command Reference (Priority: P1)

A developer working with My Kit wants to quickly see what commands are available and what they do without leaving their terminal or switching to documentation.

**Why this priority**: This is the core value proposition - immediate access to command information. Without this, users must context-switch to external documentation, breaking their flow.

**Independent Test**: Can be fully tested by running `/mykit.help` and verifying all available commands are displayed with clear descriptions. Delivers immediate value by providing at-a-glance command discovery.

**Acceptance Scenarios**:

1. **Given** a user in a My Kit-enabled repository, **When** they run `/mykit.help`, **Then** they see a list of all available commands with brief descriptions.
2. **Given** a user runs `/mykit.help`, **When** the output is displayed, **Then** commands are logically grouped by function (workflow, quality, management, etc.).
3. **Given** a new user unfamiliar with My Kit, **When** they run `/mykit.help`, **Then** they can identify the command they need within 30 seconds.

---

### User Story 2 - Detailed Command Help (Priority: P2)

A developer knows which command they want to use but needs to understand its specific usage, actions, flags, and examples.

**Why this priority**: After discovering commands exist, users need detailed usage information. This enables self-service learning without external documentation.

**Independent Test**: Can be fully tested by running `/mykit.help <command>` for any command and verifying comprehensive usage information is displayed.

**Acceptance Scenarios**:

1. **Given** a user wants help with a specific command, **When** they run `/mykit.help commit`, **Then** they see detailed information about `/mykit.commit` including usage, actions, flags, and examples.
2. **Given** a user runs `/mykit.help <command>` for any valid command, **When** the output is displayed, **Then** it includes: command description, usage syntax, available actions, available flags, and at least one usage example.
3. **Given** a user runs `/mykit.help <invalid-command>`, **When** the command is not found, **Then** they see a helpful message suggesting similar commands or directing them to the command list.

---

### User Story 3 - Workflow Guidance (Priority: P3)

A developer wants to understand the recommended workflow or how commands fit together in sequence.

**Why this priority**: Beyond individual commands, users benefit from understanding how commands work together. This accelerates learning the full workflow.

**Independent Test**: Can be fully tested by running `/mykit.help workflow` and verifying a clear workflow guide is displayed.

**Acceptance Scenarios**:

1. **Given** a user wants to understand the workflow, **When** they run `/mykit.help workflow`, **Then** they see the recommended command sequence for common workflows (full, lite, quick fix).
2. **Given** a user views workflow help, **When** the output is displayed, **Then** commands are shown in execution order with arrows or clear sequencing.

---

### Edge Cases

- What happens when the user types `/mykit.help` with a typo in the command name (e.g., `/mykit.help comit`)?
- How does the system handle when a command exists in documentation but is not yet implemented (stub)?
- When the user runs help from outside a My Kit-enabled repository, the full help is displayed (no repository context required).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display a categorized list of all available `/mykit.*` commands when `/mykit.help` is run without arguments.
- **FR-002**: System MUST group commands by function: Workflow, Issue & Branch, Specification, Quality & Commit, and Management.
- **FR-003**: System MUST display brief one-line descriptions for each command in the overview list.
- **FR-004**: System MUST display detailed help for a specific command when `/mykit.help <command>` is provided (e.g., `/mykit.help commit` shows help for `/mykit.commit`).
- **FR-005**: Detailed command help MUST include: description, usage syntax, available actions (if any), available flags (if any), and at least one example.
- **FR-006**: System MUST display a helpful error message when an unknown command is requested, including suggestions for similar commands.
- **FR-007**: System MUST display workflow cheatsheets when `/mykit.help workflow` is run, showing command sequences for Full, Lite, and Quick Fix workflows.
- **FR-008**: Command documentation MUST be sourced from the authoritative command files to ensure consistency.
- **FR-009**: System MUST indicate command implementation status (stub vs implemented) when displaying detailed help.
- **FR-010**: System MUST be a read-only command that executes immediately without requiring an action parameter.
- **FR-011**: System MUST display help content regardless of whether the current directory is a My Kit-enabled repository (no repository context required).

### Key Entities

- **Command**: A `/mykit.*` operation with properties including name, description, category, actions, flags, examples, and implementation status.
- **Command Category**: A logical grouping of related commands (Workflow, Quality, Management, etc.).
- **Workflow**: A sequence of commands that accomplish a specific development goal (Full, Lite, Quick Fix).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can find the command they need within 30 seconds of viewing `/mykit.help` output.
- **SC-002**: Users can successfully execute a command after reading its detailed help 95% of the time without consulting external documentation.
- **SC-003**: 100% of implemented commands are documented and accessible via `/mykit.help <command>`.
- **SC-004**: Help output renders correctly in terminal environments with standard 80-column width.
- **SC-005**: Users report help content is clear and actionable (qualitative feedback measure).

## Assumptions

- Users have a basic understanding of command-line interfaces.
- Terminal supports standard text output and basic formatting (bold, tables via ASCII).
- Command documentation will be maintained alongside command implementation.
- The help command follows the read-only command pattern (executes immediately, no action required).

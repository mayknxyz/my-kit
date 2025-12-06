# Feature Specification: Resume Interrupted Session

**Feature Branch**: `007-resume-session`
**Created**: 2025-12-06
**Status**: Complete
**Input**: User description: "feat: /mykit.resume - resume interrupted session refer to github issue #7"
**GitHub Issue**: #7

## Clarifications

### Session 2025-12-06

- Q: What happens when current branch differs from branch saved in state? → A: Show warning but continue displaying state with a note about the branch difference.
- Q: How should the session summary be formatted when displayed? → A: Structured card format with sections (branch, timestamp, workflow stage, suggested command).
- Q: How to handle state saved from a different project? → A: Store a unique project identifier in state; warn and suggest clearing if mismatch detected.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Resume with Saved State (Priority: P1)

A developer returns to a project after being interrupted (lunch, meeting, end of day). They want to quickly recall what they were working on and continue from where they left off without manually reviewing logs or files.

**Why this priority**: This is the core value proposition - reducing context-switching overhead when returning to work.

**Independent Test**: Can be fully tested by saving session state, closing the terminal, reopening, and running `/mykit.resume` to verify the previous context is restored and actionable.

**Acceptance Scenarios**:

1. **Given** a saved session state exists in `.mykit/state.json`, **When** user runs `/mykit.resume`, **Then** system displays the last session summary including branch, last command, and pending work.
2. **Given** a saved session state exists, **When** user runs `/mykit.resume`, **Then** system suggests the most logical next command to continue the workflow.
3. **Given** a saved session state exists with a spec-driven workflow in progress, **When** user runs `/mykit.resume`, **Then** system shows workflow progress (e.g., "Spec complete, ready for /speckit.plan").

---

### User Story 2 - Resume with No Saved State (Priority: P2)

A developer runs `/mykit.resume` but no previous session state exists (first use, state file deleted, or fresh clone).

**Why this priority**: Graceful handling of edge cases ensures a good user experience even when the expected state is missing.

**Independent Test**: Can be tested by removing `.mykit/state.json` and running `/mykit.resume` to verify helpful guidance is provided.

**Acceptance Scenarios**:

1. **Given** no `.mykit/state.json` file exists, **When** user runs `/mykit.resume`, **Then** system displays a friendly message explaining no session state was found.
2. **Given** no saved state exists, **When** user runs `/mykit.resume`, **Then** system suggests running `/mykit.start` to begin a new session or `/mykit.status` to view current project state.

---

### User Story 3 - Resume with Stale State (Priority: P3)

A developer returns to a project where the saved state is outdated (e.g., branch no longer exists, referenced files have changed significantly).

**Why this priority**: Handling stale data prevents confusion and incorrect suggestions.

**Independent Test**: Can be tested by modifying branch or deleting referenced files after saving state, then running `/mykit.resume`.

**Acceptance Scenarios**:

1. **Given** saved state references a branch that no longer exists, **When** user runs `/mykit.resume`, **Then** system warns that the referenced branch is missing and suggests alternatives.
2. **Given** saved state is older than 7 days, **When** user runs `/mykit.resume`, **Then** system displays a warning that the state may be outdated and asks for confirmation to proceed.

---

### Edge Cases

- What happens when `.mykit/state.json` exists but is corrupted or invalid JSON?
- When state contains a project identifier that doesn't match the current project, system warns the user and suggests clearing the stale state.
- When the current branch differs from the branch saved in state, system displays a warning but continues showing state with a note about the mismatch.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST read session state from `.mykit/state.json` when the file exists.
- **FR-002**: System MUST display a summary of the last session in a structured card format with distinct sections for: branch, timestamp, workflow stage, and suggested next command.
- **FR-003**: System MUST suggest the next logical command based on the workflow state (e.g., if spec exists but no plan, suggest `/speckit.plan`).
- **FR-004**: System MUST handle missing state file gracefully with a helpful message directing users to `/mykit.start` or `/mykit.status`.
- **FR-005**: System MUST validate that referenced resources (branch, spec files) still exist before making suggestions.
- **FR-006**: System MUST warn users when saved state is older than 7 days.
- **FR-007**: System MUST handle corrupted state files gracefully, displaying an error and suggesting to start fresh.
- **FR-008**: Command MUST be read-only and execute immediately without requiring an action parameter (consistent with `/mykit.status`).
- **FR-009**: System MUST display a warning when the current branch differs from the saved state branch, but continue showing the state with a note about the mismatch.
- **FR-010**: System MUST validate the project identifier in state matches the current project; if mismatched, warn the user and suggest clearing the stale state.

### Key Entities

- **Session State**: Represents the saved context of a work session including project identifier, branch name, last command, timestamp, workflow stage, and optional notes.
- **Project Identifier**: A unique identifier for the project, used to detect when state was saved from a different project.
- **Workflow Stage**: Indicates progress in the spec-driven workflow (e.g., "specify", "clarify", "plan", "tasks", "implement").

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can view their previous session context within 2 seconds of running the command.
- **SC-002**: Suggested next command is contextually appropriate for the workflow stage 95% of the time.
- **SC-003**: Users can resume work on an interrupted task without needing to manually review files or git history.
- **SC-004**: 90% of users successfully continue their workflow after running `/mykit.resume` on the first attempt.

## Assumptions

- The `.mykit/state.json` file format follows a consistent schema (to be defined during planning).
- State is saved by other mykit commands (e.g., `/mykit.start`, workflow commands) - this command only reads state.
- A 7-day threshold for "stale" state is appropriate for typical development workflows.
- The command follows the mykit convention of read-only commands executing immediately without requiring an action parameter.

## Dependencies

- Requires `.mykit/state.json` to be populated by other mykit commands.
- Depends on `/mykit.start` and `/mykit.status` being available as fallback recommendations.

## Out of Scope

- This command does not save or modify state (read-only).
- Does not implement session state saving (that is the responsibility of other commands).
- Does not provide interactive prompts to modify the resumed workflow.

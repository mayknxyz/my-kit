# Feature Specification: Session Purpose Prompt (/mykit.start)

**Feature Branch**: `004-session-purpose`
**Created**: 2025-12-05
**Status**: Draft
**GitHub Issue**: #4
**Input**: User description: "feat: /mykit.start - session purpose prompt"

## Clarifications

### Session 2025-12-05

- Q: How do users select their workflow option? → A: Chat-based selection (user types "1", "2", "3" or option name in reply)
- Q: When does session state expire/reset? → A: Session-scoped (in-memory only, resets when Claude Code session ends)

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Select Full Workflow for Complex Feature (Priority: P1)

A developer begins work on a complex feature that requires formal specification, planning, and structured implementation. They invoke `/mykit.start` to initiate their session and select the "Full workflow (Spec Kit)" option to access the complete spec-driven development toolchain.

**Why this priority**: This is the primary use case for My Kit - enabling structured, spec-driven development for complex features. Without this flow, the core value proposition cannot be delivered.

**Independent Test**: Can be fully tested by invoking `/mykit.start`, selecting option 1, verifying session state is set, and confirming direction to `/mykit.backlog`.

**Acceptance Scenarios**:

1. **Given** no active session exists, **When** user invokes `/mykit.start`, **Then** system displays three workflow options with clear descriptions
2. **Given** options are displayed, **When** user selects "Full workflow (Spec Kit)", **Then** system sets `session.type` to "full" in session state
3. **Given** session type is set, **When** selection is confirmed, **Then** system directs user to `/mykit.backlog` as the next step

---

### User Story 2 - Select Lite Workflow for Simple Changes (Priority: P2)

A developer has a straightforward enhancement or modification that doesn't require full specification documentation. They invoke `/mykit.start` and select the "Lite workflow (My Kit)" option for a streamlined process.

**Why this priority**: Supports the common case of simple changes that need some structure but not full spec-driven process. Essential for developer productivity on smaller tasks.

**Independent Test**: Can be fully tested by invoking `/mykit.start`, selecting option 2, verifying session state reflects lite mode, and confirming direction to backlog.

**Acceptance Scenarios**:

1. **Given** options are displayed, **When** user selects "Lite workflow (My Kit)", **Then** system sets `session.type` to "lite" in session state
2. **Given** lite workflow is selected, **When** selection is confirmed, **Then** system directs user to `/mykit.backlog` with appropriate lite workflow guidance

---

### User Story 3 - Select Quick Fix for Immediate Changes (Priority: P3)

A developer needs to make a rapid fix or minor change without any formal planning overhead. They invoke `/mykit.start` and select "Quick fix" to bypass the planning workflow entirely.

**Why this priority**: Provides flexibility for urgent fixes and trivial changes. Important for developer experience but not core to the spec-driven value proposition.

**Independent Test**: Can be fully tested by invoking `/mykit.start`, selecting option 3, verifying session state reflects quick fix mode, and confirming appropriate next steps.

**Acceptance Scenarios**:

1. **Given** options are displayed, **When** user selects "Quick fix", **Then** system sets `session.type` to "quickfix" in session state
2. **Given** quick fix is selected, **When** selection is confirmed, **Then** system directs user to `/mykit.backlog` with minimal workflow guidance

---

### Edge Cases

- What happens when user invokes `/mykit.start` with an existing active session?
  - System should prompt regardless; no session state is "remembered" between invocations
- What happens when user provides an invalid selection (not 1, 2, or 3)?
  - System should re-prompt with valid options until a valid selection is made
- What happens if session state storage is unavailable or fails?
  - System should display an error message and suggest troubleshooting steps

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display exactly three workflow options when `/mykit.start` is invoked:
  1. Full workflow (Spec Kit) - Complex features
  2. Lite workflow (My Kit) - Simple changes
  3. Quick fix - No formal planning
- **FR-002**: System MUST always prompt for workflow selection on each invocation (no remembered defaults)
- **FR-003**: System MUST set `session.type` in state with one of three values: "full", "lite", or "quickfix"
- **FR-004**: System MUST direct user to `/mykit.backlog` after successful workflow selection
- **FR-005**: System MUST provide clear, concise descriptions for each workflow option to help users make informed choices
- **FR-006**: System MUST handle invalid input gracefully by re-prompting for valid selection
- **FR-007**: System MUST display the current session type after selection confirmation
- **FR-008**: System MUST accept selection via chat-based input (user types "1", "2", "3" or the option name)

### Key Entities

- **Session State**: Represents the current workflow session; contains `session.type` attribute with values "full", "lite", or "quickfix". Session-scoped (in-memory only), resets when Claude Code session ends.
- **Workflow Option**: Represents a selectable workflow type; contains name, description, and associated session type value

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can complete workflow selection in under 30 seconds from command invocation
- **SC-002**: 100% of `/mykit.start` invocations prompt for selection (no cached/remembered defaults)
- **SC-003**: Session state correctly reflects the user's workflow choice after selection
- **SC-004**: Users are consistently directed to `/mykit.backlog` after completing selection
- **SC-005**: 95% of users successfully select their intended workflow option on first attempt (options are clear and unambiguous)

## Assumptions

- Session state is maintained in-memory within the Claude Code session (not persisted to disk)
- The `/mykit.backlog` command exists or will be implemented to receive users after workflow selection
- All three workflow types will have downstream commands/behavior that differ based on `session.type`
- This is a Phase 3 feature as indicated in GitHub issue #4

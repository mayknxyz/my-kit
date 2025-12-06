# Feature Specification: /mykit.reset - Clear State

**Feature Branch**: `008-reset-state`
**Created**: 2025-12-06
**Status**: Draft
**Input**: User description: "feat: /mykit.reset - clear state refer to github issue #8"
**GitHub Issue**: #8 - feat: /mykit.reset - clear state

## Clarifications

### Session 2025-12-06

- Q: Does a plain `/mykit.reset run` (without flags) delete spec files or preserve them? → A: Default preserves specs; `--keep-specs` is semantic/future-proof only

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Complete Reset (Priority: P1)

As a developer who wants to start fresh, I need to clear all workflow state so I can begin a new workflow from scratch without interference from a previous session.

**Why this priority**: This is the core functionality - clearing state is the primary purpose of the reset command. Without this, the command serves no purpose.

**Independent Test**: Can be fully tested by running `/mykit.reset run` and verifying that `.mykit/state.json` is deleted and session state is cleared. Delivers immediate value by allowing developers to start fresh.

**Acceptance Scenarios**:

1. **Given** a saved session state exists in `.mykit/state.json`, **When** the user runs `/mykit.reset run`, **Then** the state file is deleted and a confirmation message is displayed
2. **Given** no state file exists, **When** the user runs `/mykit.reset run`, **Then** the system displays "No state to reset" and exits gracefully
3. **Given** a state file exists, **When** the user runs `/mykit.reset` (without action), **Then** the system shows a preview of what would be cleared without actually clearing anything

---

### User Story 2 - Selective Reset with --keep-branch (Priority: P2)

As a developer working on a feature branch, I need to clear workflow state while staying on my current branch so I can restart the workflow without losing my branch context.

**Why this priority**: This enhances the reset command with selective behavior that preserves branch context, useful when developers want to restart a workflow on the same feature.

**Independent Test**: Can be fully tested by running `/mykit.reset run --keep-branch` while on a feature branch and verifying state is cleared but branch remains checked out. Delivers value by allowing workflow restart without branch switching.

**Acceptance Scenarios**:

1. **Given** a feature branch is checked out and state exists, **When** the user runs `/mykit.reset run --keep-branch`, **Then** the state file is deleted but the branch remains unchanged
2. **Given** the user is on the main branch, **When** the user runs `/mykit.reset run --keep-branch`, **Then** state is cleared (no branch switching would have occurred anyway)
3. **Given** a state file references a different branch than currently checked out, **When** the user runs `/mykit.reset run --keep-branch`, **Then** state is cleared and current branch remains (no automatic switch)

---

### User Story 3 - Explicit Spec Preservation with --keep-specs (Priority: P3)

As a developer who has created specifications, I want to explicitly declare my intent to preserve spec files during reset so that the command output confirms preservation and the behavior is future-proofed if defaults change.

**Why this priority**: This provides explicit intent declaration for spec preservation. While default behavior already preserves specs (per FR-009), this flag enables clear confirmation in output and future-proofs against potential default changes.

**Independent Test**: Can be fully tested by running `/mykit.reset run --keep-specs` and verifying state file is deleted but `specs/{branch}/` directory remains intact. Delivers value by preserving specification work.

**Acceptance Scenarios**:

1. **Given** spec files exist in `specs/{branch}/` and state exists, **When** the user runs `/mykit.reset run --keep-specs`, **Then** state file is deleted but spec files remain
2. **Given** no spec files exist, **When** the user runs `/mykit.reset run --keep-specs`, **Then** state is cleared normally (nothing extra to preserve)
3. **Given** the `--keep-specs` flag is used without `run` action, **When** the user runs `/mykit.reset --keep-specs`, **Then** the preview shows state would be cleared but specs would be preserved

---

### User Story 4 - Combined Flags (Priority: P3)

As a developer, I need to use multiple flags together to customize exactly what gets preserved during a reset.

**Why this priority**: Power user feature that combines P2 and P3 functionality. Lower priority because it's a combination of existing features.

**Independent Test**: Can be fully tested by running `/mykit.reset run --keep-branch --keep-specs` and verifying only state file is cleared while branch and specs are preserved.

**Acceptance Scenarios**:

1. **Given** the user is on a feature branch with specs and state, **When** the user runs `/mykit.reset run --keep-branch --keep-specs`, **Then** only the state file is deleted; branch and spec files remain
2. **Given** the user runs `/mykit.reset --keep-branch --keep-specs` (preview mode), **Then** the system shows what would be preserved and what would be cleared

---

### Edge Cases

- What happens when `.mykit/state.json` file permissions prevent deletion? System displays error message with guidance to manually delete or check permissions
- How does system handle corrupted state file? System attempts to delete regardless of content validity
- What happens when user has uncommitted changes? System proceeds with state reset (state file is typically not tracked in git)
- What happens when git operations fail? State file operations proceed independently of git operations
- How does system handle `--force` flag? Executes immediately without preview even on action command

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST delete `.mykit/state.json` file when `/mykit.reset run` is executed
- **FR-002**: System MUST show a preview of what would be cleared when `/mykit.reset` is executed without `run` action
- **FR-003**: System MUST preserve the current branch when `--keep-branch` flag is provided (by not switching branches as part of reset)
- **FR-004**: System MUST preserve spec files in `specs/{branch}/` directory when `--keep-specs` flag is provided
- **FR-005**: System MUST display confirmation message after successful reset including what was cleared and what was preserved
- **FR-006**: System MUST handle gracefully when no state file exists (display informative message, exit with success)
- **FR-007**: System MUST support combining `--keep-branch` and `--keep-specs` flags
- **FR-008**: System MUST execute immediately without preview when `--force` flag is provided with `run` action
- **FR-009**: System MUST NOT delete spec files by default; the `--keep-specs` flag provides explicit intent declaration and confirmation in output but does not change the preservation behavior
- **FR-010**: System MUST clear in-memory session state (conversation context) when reset is executed

### Key Entities

- **State File**: `.mykit/state.json` - Contains session metadata including version, projectId, branch, lastCommand, timestamp, workflowStage, sessionType, and optional notes
- **Spec Files**: Files in `specs/{branch}/` directory including `spec.md`, `plan.md`, `tasks.md`, and `checklists/` subdirectory
- **Session State**: In-memory conversation context that tracks current workflow type and progress

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can clear workflow state and return to initial state in under 5 seconds
- **SC-002**: 100% of reset operations complete without leaving partial state (atomic operation)
- **SC-003**: Users receive clear feedback indicating exactly what was cleared and what was preserved
- **SC-004**: Preview mode accurately reflects what the `run` action will do (no discrepancies between preview and execution)
- **SC-005**: System handles all edge cases (missing files, permission errors) gracefully without crashing

## Assumptions

- The `.mykit/state.json` file is the primary persistent state storage for My Kit workflows
- Spec files in `specs/{branch}/` are valuable artifacts that users may want to preserve
- In-memory session state (conversation context) is separate from persistent file state
- The command follows My Kit's action pattern where state-changing commands require explicit `run` action
- The `--force` flag bypasses preview mode for experienced users who want immediate execution

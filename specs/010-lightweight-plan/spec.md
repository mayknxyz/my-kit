# Feature Specification: /mykit.plan - Lightweight Plan (AI Skill)

**Feature Branch**: `010-lightweight-plan`
**Created**: 2025-12-07
**Status**: Draft
**GitHub Issue**: [#10](https://github.com/mayknxyz/my-kit/issues/010)

## Clarifications

### Session 2025-12-07

- Q: Where does the plan structure/template come from? → A: AI generates plan structure inline (no template file needed)
- Q: Relationship to /speckit.plan? → A: Mutually exclusive - one plan command per feature, not both

## User Scenarios & Testing

### User Story 1 - Create Implementation Plan from Spec (Priority: P1)

As a developer working on a feature, I want to run `/mykit.plan create` to generate an implementation plan that guides me through the technical design and architecture decisions, so that I can confidently implement the feature.

**Why this priority**: This is the core functionality - generating an implementation plan is the primary purpose of the command.

**Independent Test**: Can be fully tested by running `/mykit.plan create` on a feature branch with an existing spec.md, and verifying that a plan.md file is generated with technical context and design decisions.

**Acceptance Scenarios**:

1. **Given** a user is on a feature branch with an existing `specs/{branch}/spec.md` file, **When** they run `/mykit.plan create`, **Then** a `specs/{branch}/plan.md` file is created containing technical context, design decisions, and implementation phases.

2. **Given** a user is on a feature branch with an existing spec, **When** they run `/mykit.plan create`, **Then** the plan includes research findings for any unknowns identified in the spec.

3. **Given** a user is on a feature branch with an existing spec, **When** the plan is generated, **Then** the `.mykit/state.json` is updated with `workflow_step: "planning"` and the plan path.

---

### User Story 2 - Preview Implementation Plan (Priority: P1)

As a developer, I want to run `/mykit.plan` without an action to preview what the plan would look like before creating it, so that I can validate the approach before committing to files.

**Why this priority**: Preview mode follows the command pattern established in the toolkit and provides safety before file creation.

**Independent Test**: Can be tested by running `/mykit.plan` (no action) and verifying that plan content is displayed but no files are written.

**Acceptance Scenarios**:

1. **Given** a user is on a feature branch with an existing spec, **When** they run `/mykit.plan` without an action, **Then** a preview of the proposed plan is displayed without creating any files.

2. **Given** a user runs `/mykit.plan` in preview mode, **When** the preview is displayed, **Then** the output includes a note that no files were created and instructs the user to run `/mykit.plan create` to save.

---

### User Story 3 - Guided Conversation for Technical Decisions (Priority: P2)

As a developer, I want the planning process to ask me clarifying questions about technical choices when there are multiple valid approaches, so that the plan reflects my preferred implementation strategy.

**Why this priority**: Guided conversation ensures the plan matches developer preferences rather than making arbitrary technical decisions.

**Independent Test**: Can be tested by running `/mykit.plan create` on a spec that mentions a feature requiring technical choices (e.g., authentication, data storage), and verifying that the AI asks relevant questions.

**Acceptance Scenarios**:

1. **Given** the spec contains requirements with multiple valid technical approaches, **When** the user runs `/mykit.plan create`, **Then** the AI uses guided conversation to ask about key technical decisions (maximum 3-5 questions).

2. **Given** the AI identifies technical decisions to make, **When** presenting options to the user, **Then** each option includes a brief description of implications and trade-offs.

---

### User Story 4 - Handle Missing Prerequisites (Priority: P2)

As a developer, I want clear error messages when I try to run `/mykit.plan` without the required spec file, so that I know what steps to complete first.

**Why this priority**: Good error handling prevents confusion and guides users through the correct workflow sequence.

**Independent Test**: Can be tested by running `/mykit.plan create` on a branch without a spec.md file and verifying the error message.

**Acceptance Scenarios**:

1. **Given** a user is on a feature branch without a spec file, **When** they run `/mykit.plan create`, **Then** an error message is displayed indicating the spec is missing and suggesting `/mykit.specify create`.

2. **Given** a user is not on a feature branch, **When** they run `/mykit.plan create`, **Then** an error message is displayed indicating they need to select an issue first.

---

### User Story 5 - Force Overwrite Existing Plan (Priority: P3)

As a developer, I want to use `--force` to overwrite an existing plan when I need to regenerate it, so that I can iterate on my implementation approach.

**Why this priority**: Force flag is a convenience feature for iteration but not required for initial use.

**Independent Test**: Can be tested by running `/mykit.plan create --force` on a branch with an existing plan.md and verifying it is overwritten.

**Acceptance Scenarios**:

1. **Given** a user is on a branch with an existing `plan.md`, **When** they run `/mykit.plan create --force`, **Then** the existing plan is overwritten with a new plan.

2. **Given** a user is on a branch with an existing `plan.md`, **When** they run `/mykit.plan create` without `--force`, **Then** they are prompted to confirm overwrite or cancel.

---

### Edge Cases

- What happens when the spec file is empty or minimal? The command should generate a plan based on available information and note gaps.
- What happens when GitHub is unavailable? The command should work offline using only local spec content.
- What happens when the user interrupts the guided conversation? Progress should be lost; user must restart the command.
- What happens when the AI cannot generate a coherent plan from the spec? The command should report which sections are incomplete and suggest running `/mykit.specify` to improve the spec.
- What happens when `/speckit.plan` artifacts already exist? The command should error and direct user to continue with the full speckit workflow instead.

## Requirements

### Functional Requirements

- **FR-001**: System MUST check for an existing spec file at `specs/{branch}/spec.md` before proceeding with plan generation.
- **FR-002**: System MUST display a preview of the plan when run without an action (preview mode).
- **FR-003**: System MUST create a `specs/{branch}/plan.md` file when run with `create` action.
- **FR-004**: System MUST use guided conversation to ask about technical decisions when multiple valid approaches exist, limited to 3-5 questions maximum.
- **FR-005**: System MUST update `.mykit/state.json` with `workflow_step: "planning"` and `plan_path` after successful plan creation.
- **FR-006**: System MUST prompt for confirmation before overwriting an existing plan (unless `--force` is provided).
- **FR-007**: System MUST display clear error messages when prerequisites are not met (no git repo, not on feature branch, no spec file).
- **FR-008**: System MUST support the `--force` flag to overwrite existing plans without confirmation.

### Plan Content Requirements

- **FR-009**: The generated plan MUST include a Technical Context section listing technologies, dependencies, and integration points.
- **FR-010**: The generated plan MUST include a Design Decisions section documenting key architectural choices and rationale.
- **FR-011**: The generated plan MUST include Implementation Phases breaking down the work into logical steps.
- **FR-012**: The plan MUST derive its content from the feature specification, not from external sources.
- **FR-013**: The plan structure MUST be generated inline by the AI without requiring external template files (lightweight approach).
- **FR-014**: System MUST be mutually exclusive with `/speckit.plan` - if a `/speckit.plan` output already exists, display error and suggest using that workflow instead.

### Key Entities

- **Spec File**: The feature specification located at `specs/{branch}/spec.md` that provides requirements and acceptance criteria for the plan.
- **Plan File**: The implementation plan generated at `specs/{branch}/plan.md` containing technical context, design decisions, and implementation phases.
- **State File**: The workflow state at `.mykit/state.json` tracking current phase, file paths, and last command.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Users can generate an implementation plan from a spec in under 2 minutes of interactive time.
- **SC-002**: Generated plans include all three required sections: Technical Context, Design Decisions, and Implementation Phases.
- **SC-003**: 90% of users can successfully create a plan on their first attempt when a valid spec exists.
- **SC-004**: Error messages clearly indicate what action the user needs to take, with specific command suggestions.
- **SC-005**: Preview mode accurately reflects what would be created in execute mode (no surprises).
- **SC-006**: Technical decision questions are relevant to the feature being planned (not generic boilerplate questions).

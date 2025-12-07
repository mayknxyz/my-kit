# Feature Specification: /mykit.tasks - Task Generation (AI Skill)

**Feature Branch**: `011-task-generation`
**Created**: 2025-12-07
**Status**: Draft
**GitHub Issue**: [#11](https://github.com/mayknxyz/my-kit/issues/11)

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Generate Tasks from Existing Spec/Plan (Priority: P1)

A developer has created a specification and/or plan for a feature and wants to break it down into actionable, ordered tasks that can be tracked during implementation.

**Why this priority**: This is the core use case. Most users following the Lite or Full workflow will have existing artifacts to derive tasks from. Automating task generation from these documents saves significant time and ensures consistency.

**Independent Test**: Can be fully tested by running `/mykit.tasks create` on a feature branch with an existing `spec.md` and/or `plan.md` file. Delivers a structured `tasks.md` file with implementation tasks plus standard completion tasks.

**Acceptance Scenarios**:

1. **Given** a feature branch with `spec.md` exists, **When** user runs `/mykit.tasks create`, **Then** the system analyzes the spec, generates an ordered task list, and saves it to `specs/{branch}/tasks.md`

2. **Given** a feature branch with both `spec.md` and `plan.md` exist, **When** user runs `/mykit.tasks create`, **Then** the system uses both documents to generate more detailed, phased tasks aligned with the plan's implementation phases

3. **Given** a feature branch with `plan.md` but no `spec.md`, **When** user runs `/mykit.tasks create`, **Then** the system generates tasks from the plan alone

---

### User Story 2 - Generate Tasks via Guided Questions (Priority: P2)

A developer on a feature branch without spec/plan files wants to generate tasks through a conversational interface, answering questions about what needs to be done.

**Why this priority**: Supports the "minimal" flow where users skip `/mykit.specify` and `/mykit.plan`. Essential for quick implementations where formal documentation isn't needed.

**Independent Test**: Can be fully tested by running `/mykit.tasks create` on a feature branch with no `spec.md` or `plan.md`. Delivers tasks through a guided Q&A experience.

**Acceptance Scenarios**:

1. **Given** a feature branch with no spec/plan files, **When** user runs `/mykit.tasks create`, **Then** the system initiates a guided conversation asking about the work to be done

2. **Given** the guided conversation mode, **When** user answers all questions, **Then** the system generates appropriate implementation tasks based on their answers

3. **Given** incomplete answers in guided mode, **When** user provides minimal information, **Then** the system still generates a basic task structure that can be refined later

---

### User Story 3 - Preview Tasks Before Creating (Priority: P3)

A developer wants to see what tasks would be generated without committing to file creation, allowing them to review and potentially adjust their spec/plan first.

**Why this priority**: Follows the explicit execution pattern (R6) established in the blueprint. Preview mode provides safety and allows iteration.

**Independent Test**: Can be fully tested by running `/mykit.tasks` (without `create` action). Shows proposed tasks without writing any files.

**Acceptance Scenarios**:

1. **Given** a feature branch with existing artifacts, **When** user runs `/mykit.tasks` (no action), **Then** the system displays a preview of proposed tasks without creating any files

2. **Given** the preview is displayed, **When** user reviews the output, **Then** they see clear instructions on how to proceed with `/mykit.tasks create`

---

### User Story 4 - Append Standard Completion Tasks (Priority: P3)

A developer expects that every task list includes the standard workflow completion tasks (validate, commit, PR) so they don't forget these steps.

**Why this priority**: Ensures workflow completeness by always including the final steps. Prevents users from forgetting to validate, commit, and create PRs.

**Independent Test**: Can be tested by verifying any generated `tasks.md` includes completion tasks as the final items.

**Acceptance Scenarios**:

1. **Given** any task generation scenario, **When** tasks are generated, **Then** the final section includes: validate (`/mykit.validate`), commit (`/mykit.commit`), and PR (`/mykit.pr`) tasks

2. **Given** generated tasks, **When** user views the completion section, **Then** each completion task references the appropriate command

---

### Edge Cases

- What happens when the spec/plan files are empty or nearly empty? → System falls back to guided conversation mode
- How does system handle conflicting information between spec and plan? → Plan takes precedence for implementation details; spec takes precedence for requirements
- What happens when user cancels during guided conversation? → Display graceful cancellation message, no files created
- What happens when on main/develop branch (not a feature branch)? → Display error requiring feature branch
- What happens when `/speckit.plan` artifacts exist (full workflow)? → Direct user to `/speckit.tasks` instead
- What if tasks.md already exists? → Prompt for overwrite confirmation unless `--force` flag is used
- What happens with very large spec/plan files? → System processes all content but prioritizes P1 user stories and Phase 1 tasks

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST detect and read existing `spec.md` and/or `plan.md` files from `specs/{branch}/` directory
- **FR-002**: System MUST generate ordered tasks from available documentation artifacts
- **FR-003**: System MUST fall back to guided conversation when no documentation artifacts exist
- **FR-004**: System MUST always append standard completion tasks (validate, commit, PR) to generated task lists
- **FR-005**: System MUST support preview mode (no action) showing proposed tasks without file creation
- **FR-006**: System MUST support execute mode (`create` action) that writes `tasks.md` file
- **FR-007**: System MUST validate feature branch requirement before proceeding
- **FR-008**: System MUST detect `/speckit.plan` conflicts and redirect users appropriately
- **FR-009**: System MUST prompt for confirmation when overwriting existing `tasks.md` unless `--force` flag is used
- **FR-010**: System MUST update `.mykit/state.json` with task generation metadata on successful creation
- **FR-011**: System MUST generate tasks in a checkable format (checkbox list) for progress tracking
- **FR-012**: System MUST provide task numbering (T001, T002, etc.) for reference and ordering
- **FR-013**: Guided conversation MUST ask exactly 3 questions: (1) What needs to be built or changed, (2) What components or files are affected, (3) What defines "done" for this work
- **FR-014**: System MUST generate between 5-15 implementation tasks (excluding standard completion tasks) for typical features

### Key Entities

- **Task**: An actionable work item with ID (T###), description, and checkbox status. Tasks are ordered by dependency and priority. Each task represents approximately 30 minutes to 2 hours of focused work.
- **Task Section**: A grouping of related tasks (Implementation, Testing, Completion). Each section has a heading and contains ordered tasks.
- **Documentation Artifact**: Source material for task generation (spec.md, plan.md). Each artifact provides different context for task derivation.
- **Feature Context**: The combination of branch name, issue number, and existing artifacts that inform task generation.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can generate a complete task list from existing documentation in under 30 seconds
- **SC-002**: Users can generate tasks via guided conversation in under 3 minutes
- **SC-003**: 100% of generated task files include the standard completion tasks (validate, commit, PR)
- **SC-004**: Generated tasks follow a consistent format that integrates with `/mykit.implement` for execution tracking
- **SC-005**: Users reviewing preview mode can understand exactly what will be created before committing
- **SC-006**: Task generation requires no manual reformatting to be usable in the implementation phase

## Clarifications

### Session 2025-12-07

- Q: What is the target task granularity level? → A: Medium-grained (~30 min to 2 hours of focused work per task)
- Q: How many guided conversation questions when no artifacts exist? → A: 3 questions (What needs to be built/changed, What components/files affected, What defines done)
- Q: What are the task count bounds for generated task lists? → A: 5-15 tasks typical range (excluding completion tasks)

## Assumptions

- The `specs/{branch}/` directory structure is already established by prior commands (`/mykit.specify` or `/mykit.plan`)
- Claude Code's conversation context is available for the AI skill to analyze documents and generate appropriate tasks
- Users understand the task numbering convention (T001, T002, etc.) from other My Kit commands
- The `gh` CLI may or may not be available; task generation should work offline (no GitHub API dependency)

# Feature Specification: Lightweight Spec Command

**Feature Branch**: `009-lightweight-spec`
**Created**: 2025-12-07
**Status**: Draft
**Input**: User description: "feat: /mykit.specify - lightweight spec (AI skill) refer to github issue #9"

## Clarifications

### Session 2025-12-07

- Q: What constitutes "extractable content" in a GitHub issue body? → A: Issue body has at least 50 characters of content
- Q: When GitHub API is unavailable, should the command block or allow continuation? → A: Non-blocking - warn user, proceed with guided conversation (no issue extraction)

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Create Spec from GitHub Issue (Priority: P1)

A developer selects a GitHub issue via `/mykit.backlog` and wants to quickly create a lightweight specification. They run `/mykit.specify create` and the command automatically extracts information from the linked GitHub issue body to pre-fill the spec, then guides them through any missing details via a conversational flow.

**Why this priority**: This is the primary use case—creating a spec from an existing issue streamlines the workflow and avoids duplicate data entry. Most users will have an issue already selected.

**Independent Test**: Can be fully tested by selecting an issue with a descriptive body and running `/mykit.specify create`. The spec file should be created with relevant content extracted from the issue.

**Acceptance Scenarios**:

1. **Given** a developer has selected issue #42 via `/mykit.backlog` with a descriptive issue body, **When** they run `/mykit.specify create`, **Then** the command reads the issue body, extracts summary/problem/acceptance criteria, and presents a pre-filled spec for confirmation.

2. **Given** the GitHub issue body contains "## Problem" and "## Acceptance Criteria" sections, **When** `/mykit.specify create` runs, **Then** those sections are mapped directly to the corresponding spec sections without requiring user input.

3. **Given** the issue body is minimal (just a title or one-liner), **When** `/mykit.specify create` runs, **Then** the command prompts the user with guided questions to fill in missing sections.

---

### User Story 2 - Create Spec via Guided Conversation (Priority: P2)

A developer has an issue selected but the issue body is empty or lacks structure. They run `/mykit.specify create` and are guided through a brief conversational flow: "What is this about?", "What problem does it solve?", "What should be true when done?" The answers populate the spec.

**Why this priority**: Fallback path when issue extraction fails or when users prefer interactive creation. Ensures specs can always be created regardless of issue quality.

**Independent Test**: Can be tested by selecting an issue with an empty body and running `/mykit.specify create`. The conversation flow should guide the user to complete a spec.

**Acceptance Scenarios**:

1. **Given** an issue with an empty body is selected, **When** `/mykit.specify create` runs, **Then** the command asks "What is this feature/change about?" and waits for user input.

2. **Given** the user answers the first question, **When** they submit their response, **Then** the command asks "What problem does it solve?" and continues the flow.

3. **Given** all three guided questions are answered, **When** the user confirms, **Then** a spec file is created at `specs/{branch-name}/spec.md` with the responses mapped to Summary, Problem, and Acceptance Criteria sections.

---

### User Story 3 - Preview Spec Before Creation (Priority: P3)

A developer runs `/mykit.specify` without an action to see what would be created. This preview mode shows the proposed spec content without writing any files, following the "explicit execution" pattern (R6).

**Why this priority**: Aligns with My Kit's safety-first approach where state-changing commands require explicit action flags. Allows review before committing to a spec.

**Independent Test**: Can be tested by running `/mykit.specify` (no action) after issue selection. Should display proposed spec content without creating files.

**Acceptance Scenarios**:

1. **Given** an issue is selected, **When** the user runs `/mykit.specify` (no action), **Then** the command displays what the spec would contain based on issue extraction.

2. **Given** a preview is displayed, **When** the user runs `/mykit.specify create`, **Then** the spec is actually written to disk.

---

### User Story 4 - Create Spec Without Issue (Priority: P3)

A developer wants to create a spec for exploratory work without a linked GitHub issue. They run `/mykit.specify create --no-issue` and provides feature details through the guided conversation. The spec is created in a temporary location or with a generated identifier.

**Why this priority**: Supports ad-hoc workflows while maintaining spec-driven development. Lower priority as most work should be issue-linked per R1.

**Independent Test**: Can be tested by running `/mykit.specify create --no-issue` without prior issue selection. Should proceed with guided questions and create spec.

**Acceptance Scenarios**:

1. **Given** no issue is selected, **When** the user runs `/mykit.specify create --no-issue`, **Then** the command proceeds with guided questions instead of failing.

2. **Given** the `--no-issue` flag is used, **When** the spec is created, **Then** it is saved to a location using a generated identifier (e.g., `specs/adhoc-{slug}/spec.md`).

---

### Edge Cases

- What happens when GitHub API is unavailable? Command displays a warning message and proceeds with guided conversation flow (non-blocking); issue extraction is skipped.
- What happens when issue body contains unsupported markdown formatting? Extract plain text content, ignore complex formatting.
- What happens when spec file already exists at target path? Prompt user to overwrite, merge, or cancel.
- What happens when user interrupts the guided conversation? Save partial progress to state for `/mykit.resume`.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Command MUST support both preview mode (no action) and execution mode (`create` action) per R6.
- **FR-002**: Command MUST read the linked GitHub issue body and attempt to extract spec content (summary, problem, acceptance criteria).
- **FR-003**: Command MUST fall back to guided conversation when issue body has fewer than 50 characters of content.
- **FR-004**: Guided conversation MUST ask exactly three questions: summary, problem statement, and acceptance criteria.
- **FR-005**: Command MUST validate that an issue is selected before proceeding (unless `--no-issue` flag is provided).
- **FR-006**: Command MUST create spec file at `specs/{branch-name}/spec.md` using the lite spec template.
- **FR-007**: Command MUST update `.mykit/state.json` with `spec_path` and `workflow_step` after successful creation.
- **FR-008**: Command MUST support `--no-issue` flag to bypass issue requirement for ad-hoc work.
- **FR-009**: Command MUST display confirmation message with spec file path after successful creation.
- **FR-010**: Command MUST handle existing spec files by prompting for overwrite confirmation (unless `--force` flag is used).

### Key Entities

- **Spec File**: Lightweight markdown document containing Summary, Problem, and Acceptance Criteria sections. Located at `specs/{branch-name}/spec.md`.
- **State**: Workflow state tracking current feature including `issue_number`, `branch`, `spec_path`, and `workflow_step`. Persisted in `.mykit/state.json`.
- **GitHub Issue**: Source of feature context including title and body. Accessed via `gh` CLI.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can create a lightweight spec in under 2 minutes when issue body contains structured content.
- **SC-002**: Users can complete the guided conversation flow in under 3 minutes for minimal issues.
- **SC-003**: 90% of specs created via issue extraction require no additional editing by the user.
- **SC-004**: Command execution time is under 5 seconds (excluding user input time).
- **SC-005**: Zero data loss when session is interrupted—partial progress is recoverable via `/mykit.resume`.

## Assumptions

- GitHub CLI (`gh`) is installed and authenticated (validated at runtime).
- User has already run `/mykit.backlog` to select an issue and create a branch (unless using `--no-issue`).
- The lite spec template exists at `.mykit/templates/lite/spec.md`.
- State file `.mykit/state.json` is writable and properly initialized.
- Issue body parsing uses common markdown patterns (## headers, bullet lists) without requiring strict templates.

## Out of Scope

- Full Spec Kit integration (handled by `/speckit.specify`).
- Automatic task generation from spec (handled by `/mykit.tasks`).
- GitHub issue creation (handled by `/mykit.backlog --create`).
- Validation of spec content quality (handled by `/mykit.validate`).

# Feature Specification: Enhanced Status Dashboard

**Feature Branch**: `006-status-dashboard`
**Created**: 2025-12-06
**Status**: Draft
**GitHub Issue**: #6
**Input**: User description: "feat: /mykit.status - enhanced dashboard refer to github issue #6"

## Clarifications

### Session 2025-12-06

- Q: How should the dashboard handle repositories with many uncommitted changes (50+ files)? → A: Show first 10 files with "+N more" summary if exceeded
- Q: What determines the "implementation" phase for workflow state detection? → A: Implementation phase starts when tasks.md exists

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Quick Context Overview (Priority: P1)

As a developer working on a feature, I want to run `/mykit.status` and immediately see my current context (branch, linked issue, workflow step) so I can quickly orient myself without checking multiple sources.

**Why this priority**: This is the core value proposition - developers need quick orientation before making decisions about what to do next. Without context awareness, all other dashboard features are less useful.

**Independent Test**: Can be fully tested by running `/mykit.status` on any feature branch and verifying that issue info, branch name, and current workflow phase are displayed accurately.

**Acceptance Scenarios**:

1. **Given** I am on a feature branch linked to an issue, **When** I run `/mykit.status`, **Then** I see the issue number, title, and branch name displayed prominently
2. **Given** I am on a feature branch with spec files, **When** I run `/mykit.status`, **Then** I see which workflow step I'm currently at (spec, plan, tasks, implementation)
3. **Given** I am on the main branch with no active feature, **When** I run `/mykit.status`, **Then** I see a message indicating no active feature context

---

### User Story 2 - File Status Visibility (Priority: P2)

As a developer making changes, I want to see uncommitted file changes and their status so I can track my work progress and know what needs to be committed.

**Why this priority**: After knowing context, developers need visibility into their working state. This informs decisions about committing, continuing work, or switching tasks.

**Independent Test**: Can be fully tested by making file changes and running `/mykit.status` to verify changed files are listed with appropriate status indicators.

**Acceptance Scenarios**:

1. **Given** I have modified files in my working directory, **When** I run `/mykit.status`, **Then** I see a list of changed files with their status (modified, added, deleted)
2. **Given** I have staged files for commit, **When** I run `/mykit.status`, **Then** staged files are visually distinguished from unstaged changes
3. **Given** I have no uncommitted changes, **When** I run `/mykit.status`, **Then** I see a clean working directory indicator

---

### User Story 3 - Next Command Suggestion (Priority: P3)

As a developer following the spec-driven workflow, I want to see a suggested next command based on my current state so I can efficiently progress through the workflow without memorizing command sequences.

**Why this priority**: Guidance reduces cognitive load and helps developers learn the workflow. It's valuable but depends on context and file status information being available first.

**Independent Test**: Can be fully tested by being at different workflow stages and verifying appropriate next commands are suggested.

**Acceptance Scenarios**:

1. **Given** I have a spec.md but no plan.md, **When** I run `/mykit.status`, **Then** I see `/speckit.plan` suggested as the next step
2. **Given** I have uncommitted changes after implementation, **When** I run `/mykit.status`, **Then** I see `/mykit.commit create` suggested
3. **Given** I have completed all workflow steps, **When** I run `/mykit.status`, **Then** I see a completion message or PR creation suggestion

---

### Edge Cases

- What happens when the user is on a feature branch not created by My Kit (no linked issue)? → Display available git info with a note that no linked issue was found
- What happens when git is not initialized in the directory? → Display an error message guiding the user to initialize git
- What happens when GitHub CLI is not authenticated? → Display local information and indicate GitHub features are unavailable
- How does the system handle detached HEAD state? → Display warning about detached state and current commit info

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST detect and display the current git branch name
- **FR-002**: System MUST identify and display the linked GitHub issue number and title when available
- **FR-003**: System MUST determine current workflow phase by checking for existence of spec.md, plan.md, and tasks.md files (phases: none → spec exists → plan exists → tasks exists = implementation)
- **FR-004**: System MUST display file status showing modified, added, deleted, and staged files (maximum 10 files displayed; show "+N more" summary when exceeded)
- **FR-005**: System MUST differentiate between staged and unstaged changes visually
- **FR-006**: System MUST suggest the next logical command based on current workflow state
- **FR-007**: System MUST display gracefully when running outside a git repository (clear error message)
- **FR-008**: System MUST display partial information when GitHub CLI is unavailable (local git info only)
- **FR-009**: System MUST use clear visual formatting to organize dashboard sections (issue info, workflow step, file status, next action)
- **FR-010**: System MUST execute as a read-only command (no state changes)

### Key Entities

- **Feature Context**: Current branch, linked issue number, issue title, issue state
- **Workflow State**: Current phase determined by file existence (none → spec → plan → implementation when tasks.md exists)
- **File Status**: List of changed files (max 10 displayed) with modification type (modified, added, deleted, renamed) and staging status
- **Command Suggestion**: Recommended next command based on current state

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Developers can assess their current working context in under 5 seconds by running a single command
- **SC-002**: 100% of displayed information is accurate and reflects actual repository state
- **SC-003**: Dashboard displays all relevant context without requiring additional commands or terminal scrolling for typical workflows
- **SC-004**: New users can understand the workflow progression by following suggested next commands
- **SC-005**: Command responds within 2 seconds under normal conditions (local repository, authenticated GitHub CLI)

## Assumptions

- Users have git installed and are working within a git repository
- Feature branches follow the My Kit naming convention (`###-feature-name`)
- GitHub CLI (`gh`) is available for issue lookup, but graceful degradation is expected when unavailable
- Spec files are located in `specs/{branch-name}/` directory following existing project structure
- The command is invoked as a Claude Code slash command (`/mykit.status`)

# Feature Specification: /mykit.implement - Task Execution

**Feature Branch**: `012-task-execution`
**Created**: 2025-12-09
**Status**: Draft
**Input**: User description: "feat: /mykit.implement - task execution refer to github issue #12 - Execute tasks one by one, mark complete, suggest next task."

## Clarifications

### Session 2025-12-09

- Q: How is the "in-progress" task state set? → A: Implicit on run - running `/mykit.implement run` automatically marks the first incomplete task as in-progress
- Q: What does "execution guidance" mean operationally? → A: Autonomous execution - Claude Code displays the task then attempts to execute it (write code, run commands) autonomously
- Q: After autonomous execution, should task be auto-completed? → A: Yes, auto-complete on success and suggest/start next task
- Q: What happens when autonomous execution fails? → A: Keep task in-progress, report failure, let user decide next action (complete, skip, or retry via run)

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Execute Next Available Task (Priority: P1)

A developer wants to work through their task list systematically, having Claude Code execute each task and provide guidance on what comes next.

**Why this priority**: This is the core value proposition - executing tasks from tasks.md is the primary function of the implement command. Without this, the command has no purpose.

**Independent Test**: Can be fully tested by running `/mykit.implement run` on a feature branch with tasks.md containing uncompleted tasks, and verifying the first incomplete task is identified, marked in-progress, and autonomously executed.

**Acceptance Scenarios**:

1. **Given** a feature branch with tasks.md containing incomplete tasks, **When** user runs `/mykit.implement run`, **Then** the system identifies the first incomplete task, marks it in-progress, and autonomously executes it
2. **Given** a feature branch with tasks.md where first task is complete, **When** user runs `/mykit.implement run`, **Then** the system skips completed tasks and identifies the next incomplete task
3. **Given** a feature branch with tasks.md containing a task in progress, **When** user runs `/mykit.implement run`, **Then** the system resumes that in-progress task rather than starting a new one

---

### User Story 2 - Mark Task Complete (Priority: P2)

A developer has finished working on a task and wants to mark it complete, updating the tasks.md file and seeing what comes next.

**Why this priority**: Task completion tracking is essential for progress visibility and workflow continuity. Without marking tasks complete, the system cannot suggest the next task.

**Independent Test**: Can be fully tested by running `/mykit.implement complete` after finishing a task, verifying the task is marked with [x] in tasks.md and the next task is displayed.

**Acceptance Scenarios**:

1. **Given** a task currently in progress, **When** user runs `/mykit.implement complete`, **Then** the task is marked as complete in tasks.md with [x] checkbox
2. **Given** the last implementation task is completed, **When** user runs `/mykit.implement complete`, **Then** the system indicates completion tasks remain (validation, commit, PR)
3. **Given** all tasks including completion tasks are done, **When** user runs `/mykit.implement complete`, **Then** the system celebrates completion and suggests `/mykit.pr create`

---

### User Story 3 - View Task Progress Dashboard (Priority: P3)

A developer wants to see their current progress through the task list without starting or completing any tasks.

**Why this priority**: Read-only status visibility helps developers understand where they are in the implementation without triggering any actions.

**Independent Test**: Can be fully tested by running `/mykit.implement` (no action) on a feature branch with tasks.md, verifying a progress summary is displayed without modifying any files.

**Acceptance Scenarios**:

1. **Given** a feature branch with tasks.md, **When** user runs `/mykit.implement` (no action), **Then** a progress dashboard shows completed vs remaining tasks
2. **Given** no tasks.md exists, **When** user runs `/mykit.implement`, **Then** an error message suggests running `/mykit.tasks create` first
3. **Given** a feature branch with partially completed tasks, **When** user runs `/mykit.implement`, **Then** the dashboard shows percentage complete and current/next task

---

### User Story 4 - Skip Current Task (Priority: P3)

A developer wants to skip a task and move to the next one, perhaps because they're blocked or the task is no longer relevant.

**Why this priority**: Flexibility in task execution order improves developer experience when facing blockers or changing requirements.

**Independent Test**: Can be fully tested by running `/mykit.implement skip` when a task is in progress, verifying the task is marked skipped and the next task is identified.

**Acceptance Scenarios**:

1. **Given** a task in progress, **When** user runs `/mykit.implement skip`, **Then** the current task is marked with [~] (skipped) and the next task is identified
2. **Given** user skips a task, **When** all other tasks are complete, **Then** the system reminds user of skipped tasks before final completion
3. **Given** no task is currently in progress, **When** user runs `/mykit.implement skip`, **Then** an error indicates no active task to skip

---

### Edge Cases

- **Invalid tasks.md format**: System displays error with specific parsing issue and suggests fixing the file manually
- **tasks.md deleted mid-workflow**: System detects missing file and suggests running `/mykit.tasks create`
- **Not on feature branch**: System displays error per FR-009, suggests `/mykit.backlog select`
- **All tasks complete**: System displays completion summary and suggests `/mykit.pr create`
- **Manual tasks.md edits**: System re-reads file on each command invocation, respects manual changes
- **Execution failure**: System keeps task in-progress, reports failure, awaits user decision (per FR-015)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST read tasks from `specs/{branch}/tasks.md` file
- **FR-002**: System MUST identify incomplete tasks by checking for `- [ ]` checkbox pattern
- **FR-003**: System MUST identify completed tasks by checking for `- [x]` checkbox pattern
- **FR-004**: System MUST identify skipped tasks by checking for `- [~]` checkbox pattern
- **FR-005**: System MUST update tasks.md when marking tasks complete or skipped
- **FR-006**: System MUST display the current task clearly with its full description
- **FR-007**: System MUST suggest the next incomplete task after completing the current one
- **FR-008**: System MUST update `.mykit/state.json` with current task context
- **FR-009**: System MUST validate that user is on a feature branch before executing tasks
- **FR-010**: System MUST handle the distinction between implementation tasks and completion tasks
- **FR-011**: System MUST preserve task ordering when updating the tasks.md file
- **FR-012**: System MUST autonomously execute the current task (write code, run commands, perform validation) appropriate to the task type
- **FR-013**: System MUST automatically mark the first incomplete task as in-progress when `/mykit.implement run` is executed
- **FR-014**: System MUST automatically mark task complete upon successful autonomous execution and proceed to next task
- **FR-015**: System MUST keep task in-progress on execution failure, report the failure details, and await user action (complete, skip, or retry)

### Key Entities

- **Task**: A single work item with ID (T###), status (pending/in-progress/complete/skipped), and description. State transitions: pending → in-progress (via `run`), in-progress → complete (auto on successful execution, or manual via `complete`), in-progress → skipped (via `skip`)
- **Task List**: The collection of tasks in tasks.md, divided into Implementation and Completion sections
- **Current Task**: The task currently being worked on (tracked in state.json)
- **Task Progress**: Aggregate metrics of completed, pending, and skipped tasks

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Developers can complete all implementation tasks using only `/mykit.implement` commands without manually editing tasks.md
- **SC-002**: Task progress is accurately reflected after each command (completed count matches [x] checkboxes)
- **SC-003**: 95% of task transitions (start → complete/skip → next) complete without errors
- **SC-004**: Developers can resume interrupted implementation sessions and continue from the correct task
- **SC-005**: Progress dashboard displays accurate completion percentage matching actual task states
- **SC-006**: System guides developers through the correct sequence: implementation tasks → validation → commit → PR

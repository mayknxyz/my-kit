# /mykit.tasks

Generate a task breakdown from feature specification and/or implementation plan, or via guided conversation.

## Usage

```
/mykit.tasks
```

- Default: Display current tasks and progress, or generate if none exist

## Description

This command generates task breakdowns for the development workflow. It analyzes existing spec.md and/or plan.md files to extract user stories and implementation phases, or guides users through a 3-question conversation when no documentation exists. The output is a structured tasks.md file with implementation tasks and standard completion tasks.

## Implementation

When this command is invoked, perform the following steps:

### Step 1: Check Prerequisites

First, verify we're in a git repository:

```bash
git rev-parse --git-dir 2>/dev/null
```

**If not in a git repository**, display the following message and stop:

```
**Error**: Not in a git repository.

Run `git init` to initialize a repository, or navigate to an existing git repository.
```

### Step 2: Get Current Branch and Extract Issue Number

Get the current branch name:

```bash
git rev-parse --abbrev-ref HEAD
```

Extract the issue number from the branch name using pattern `^([0-9]+)-`:

- **If branch matches pattern** (e.g., `042-feature-name`):
  - Extract issue number (e.g., `42`)
  - Set `issueNumber` to the extracted number
  - Set `isFeatureBranch = true`
- **If branch does NOT match pattern** (e.g., `main`, `develop`):
  - Set `issueNumber = null`
  - Set `isFeatureBranch = false`

### Step 3: Validate Feature Branch Requirement

**If `isFeatureBranch` is false**:

Display error and stop:

```
**Error**: No feature branch detected.

You must be on a feature branch (e.g., `042-feature-name`) to generate tasks.

To select an issue and create a branch: `/mykit.specify`
```

### Step 4: Determine Paths

Set the following paths based on the current branch:

- `specPath = specs/{branch}/spec.md`
- `planPath = specs/{branch}/plan.md`
- `tasksPath = specs/{branch}/tasks.md`
- `specsDir = specs/{branch}/`

### Step 5: Check for Existing Tasks

**If tasks file exists at `tasksPath`**:

Use `AskUserQuestion` to prompt:

- header: "Existing Tasks"
- question: "A tasks file already exists. What would you like to do?"
- options:
  1. label: "View", description: "Display current tasks and progress"
  2. label: "Overwrite", description: "Replace the existing tasks entirely"
  3. label: "Cancel", description: "Abort and keep the existing tasks"

- If user selects "View": Display the tasks content and stop.
- If user selects "Cancel": Display "Operation cancelled. Existing tasks preserved." and stop.
- If user selects "Overwrite": Continue with task generation.

### Step 6: Detect Available Artifacts

Check which documentation artifacts exist:

- `hasSpec`: true if spec.md exists and has content >= 50 characters
- `hasPlan`: true if plan.md exists and has content >= 50 characters

**Determine content source**:

- If both exist: `contentSource = "spec+plan"`
- If only spec exists: `contentSource = "spec"`
- If only plan exists: `contentSource = "plan"`
- If neither exists or both are too short: `contentSource = "guided"` (trigger Step 8)

### Step 7: Read and Analyze Artifacts (if available)

**If `hasSpec` is true**:

Read the spec file content from `specPath`.

Extract the following information:

- **Feature name**: From the `# Feature Specification:` heading
- **User Stories**: All sections matching `### User Story N - {title} (Priority: {P#})`
  - Extract: story number, title, priority, description, acceptance scenarios
- **Functional Requirements**: All items under `### Functional Requirements`
  - Extract: FR-### IDs and descriptions
- **Success Criteria**: All items under `### Measurable Outcomes`
  - Extract: SC-### IDs and descriptions

**If `hasPlan` is true**:

Read the plan file content from `planPath`.

Extract the following information:

- **Summary**: From `## Summary` section
- **Implementation Phases**: All sections matching `### Phase N: {title}`
  - Extract: phase number, title, description, key tasks
- **Design Decisions**: All sections matching `### DD-###: {title}`
  - Extract: decision title, choice, rationale

### Step 8: Guided Conversation (if no artifacts)

**Trigger conversation if `contentSource` is "guided"**:

**Question 1: What to Build**

Use `AskUserQuestion` tool:

- header: "Tasks: Q1/3"
- question: "What needs to be built or changed?"
- multiSelect: false
- options: (none - free text response expected)

Wait for user response and store as `whatToBuild`.

**Question 2: Components Affected**

Use `AskUserQuestion` tool:

- header: "Tasks: Q2/3"
- question: "What components or files are affected?"
- multiSelect: false
- options: (none - free text response expected)

Wait for user response and store as `componentsAffected`.

**Question 3: Definition of Done**

Use `AskUserQuestion` tool:

- header: "Tasks: Q3/3"
- question: "What defines 'done' for this work?"
- multiSelect: false
- options: (none - free text response expected)

Wait for user response and store as `definitionOfDone`.

### Step 9: Generate Task List

Generate tasks based on the content source:

**Task Generation Rules**:

- Generate 5-15 implementation tasks (excluding completion tasks)
- Each task should represent approximately 30 minutes to 2 hours of focused work
- Tasks should be ordered by dependency and priority
- Include task numbering (T001, T002, etc.)
- Format: `- [ ] T### {task description}`

**If `contentSource` is "spec" or "spec+plan"**:

- Prioritize P1 user stories for task extraction
- Map functional requirements to implementation tasks
- If plan phases exist, align tasks with phase structure

**If `contentSource` is "plan"**:

- Extract tasks from implementation phases
- Use key tasks from each phase
- Order by phase number

**If `contentSource` is "guided"**:

- Generate tasks from the three guided answers
- Break down `whatToBuild` into logical implementation steps
- Consider `componentsAffected` for task scoping
- Use `definitionOfDone` to ensure completion criteria are covered

### Step 10: Append Completion Tasks

Always append the following standard completion tasks at the end:

```markdown
## Completion

- [ ] T0XX Run validation: `/mykit.audit.all`
- [ ] T0XX Create commit: `/mykit.commit`
- [ ] T0XX Create pull request: `/mykit.pr`
```

Where `T0XX` continues the task numbering sequence from Step 9.

### Step 11: Format Tasks Content

Generate the tasks.md content using this structure:

```markdown
# Tasks: {featureName}

**Branch**: `{branch}` | **Created**: {currentDate} | **Source**: {contentSource}

## Implementation

- [ ] T001 {first task description}
- [ ] T002 {second task description}
...
- [ ] T0XX {last implementation task}

## Completion

- [ ] T0XX Run validation: `/mykit.audit.all`
- [ ] T0XX Create commit: `/mykit.commit`
- [ ] T0XX Create pull request: `/mykit.pr`
```

Where:

- `featureName` = extracted from spec header, plan summary, or derived from guided answers
- `branch` = current git branch
- `currentDate` = today's date in YYYY-MM-DD format
- `contentSource` = one of: "spec", "plan", "spec+plan", "guided"

### Step 12: Write Tasks File

1. Create the specs directory if it doesn't exist
2. Write the tasks content to `tasksPath`
3. Display confirmation:

```
**Tasks generated successfully!**

**File**: {tasksPath}
**Source**: {contentSource description}
**Task Count**: {implementationTaskCount} implementation + 3 completion = {totalTaskCount} total

Next step: `/mykit.implement` to start working through tasks.
```

Where `contentSource description` is:

- "spec": "Extracted from feature specification"
- "plan": "Extracted from implementation plan"
- "spec+plan": "Combined from specification and plan"
- "guided": "Generated from guided conversation"

## Error Handling

| Error | Message |
|-------|---------|
| Not a git repository | "Not in a git repository. Run `git init` to initialize." |
| Not on feature branch | "No feature branch detected. Use `/mykit.specify` first." |
| File write failed | "Error: Unable to create tasks file at {path}. Check permissions." |

## Example Outputs

### View Existing Tasks

```
/mykit.tasks

## Current Task List

# Tasks: Add user authentication

**Branch**: `042-auth` | **Created**: 2025-12-07 | **Source**: spec+plan

## Implementation

- [ ] T001 Create user model with email and password fields
- [ ] T002 Implement password hashing service
- [x] T003 Create login endpoint
- [>] T004 Create registration endpoint
- [ ] T005 Add session management

## Completion

- [ ] T006 Run validation: `/mykit.audit.all`
- [ ] T007 Create commit: `/mykit.commit`
- [ ] T008 Create pull request: `/mykit.pr`
```

### Generate New Tasks

```
/mykit.tasks

**Tasks generated successfully!**

**File**: specs/042-auth/tasks.md
**Source**: Combined from specification and plan
**Task Count**: 7 implementation + 3 completion = 10 total

Next step: `/mykit.implement` to start working through tasks.
```

## Related Commands

| Command | Relationship |
|---------|------------|
| `/mykit.specify` | Create spec before running this command (optional) |
| `/mykit.plan` | Create plan before running this command (optional) |
| `/mykit.implement` | Next step after task generation |
| `/mykit.status` | Shows current workflow phase |

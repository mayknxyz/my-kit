# /mykit.tasks

Generate a task breakdown from feature specification and/or implementation plan, or via guided conversation.

## Usage

```
/mykit.tasks [-c|-r|-u|-d] [--force]
```

- `-c`: Create — generate a new tasks file
- `-r`: Read — display current tasks and progress (default if no flag)
- `-u`: Update — regenerate tasks from updated spec/plan
- `-d`: Delete — remove the tasks file
- `--force`: Skip confirmation prompts

## Description

This command generates task breakdowns for the Minor workflow. It analyzes existing spec.md and/or plan.md files to extract user stories and implementation phases, or guides users through a 3-question conversation when no documentation exists. The output is a structured tasks.md file with implementation tasks and standard completion tasks.

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

### Step 2: Parse Arguments

Parse the command arguments to determine:
- `flag`: one of `-c`, `-r`, `-u`, `-d`, or `null` (defaults to `-r`)
- `hasForceFlag`: true if `--force` is present

### Step 3: Get Current Branch and Extract Issue Number

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

### Step 4: Validate Feature Branch Requirement

**If `isFeatureBranch` is false**:

Display error and stop:
```
**Error**: No feature branch detected.

You must be on a feature branch (e.g., `042-feature-name`) to generate tasks.

To select an issue and create a branch: `/mykit.start`
```

### Step 5: Determine Paths

Set the following paths based on the current branch:
- `specPath = specs/{branch}/spec.md`
- `planPath = specs/{branch}/plan.md`
- `tasksPath = specs/{branch}/tasks.md`
- `specsDir = specs/{branch}/`

### Step 6: Detect Full-Mode Artifacts

Check if any full-mode planning artifacts exist in `specsDir`:
- `research.md`
- `data-model.md`
- `contracts/` directory

**If any of these exist and `session.type` is not `major`**:

Display info and suggest switching to major mode:
```
**Note**: Major-mode planning artifacts detected (research.md, data-model.md, contracts/).

Consider using `/mykit.start` to select Major mode for story-driven task generation
with dependency graphs and parallel markers.
```

Continue with task generation regardless.

### Step 7: Check for Existing Tasks

**If tasks file exists at `tasksPath`**:

**If `hasForceFlag` is true**:
- Continue (will overwrite)

**If `hasForceFlag` is false AND `flag` is `-c` or `-u`**:
- Use `AskUserQuestion` tool to prompt:
  - header: "Existing Tasks"
  - question: "A tasks file already exists at this location. What would you like to do?"
  - options:
    1. label: "Overwrite", description: "Replace the existing tasks entirely"
    2. label: "Cancel", description: "Abort and keep the existing tasks"

- If user selects "Cancel", display message and stop:
  ```
  Operation cancelled. Existing tasks preserved.
  ```

### Step 8: Detect Available Artifacts

Check which documentation artifacts exist:
- `hasSpec`: true if spec.md exists and has content >= 50 characters
- `hasplan`: true if plan.md exists and has content >= 50 characters

**Determine content source**:
- If both exist: `contentSource = "spec+plan"`
- If only spec exists: `contentSource = "spec"`
- If only plan exists: `contentSource = "plan"`
- If neither exists or both are too short: `contentSource = "guided"` (trigger Step 9)

### Step 9: Read and Analyze Artifacts (if available)

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

### Step 10: Guided Conversation (if no artifacts)

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

Set `contentSource = "guided"` if not already set.

### Step 11: Generate Task List

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

### Step 12: Append Completion Tasks

Always append the following standard completion tasks at the end:

```markdown
## Completion

- [ ] T0XX Run validation: `/mykit.audit`
- [ ] T0XX Create commit: `/mykit.commit`
- [ ] T0XX Create pull request: `/mykit.pr -c`
```

Where `T0XX` continues the task numbering sequence from Step 11.

### Step 13: Format Tasks Content

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

- [ ] T0XX Run validation: `/mykit.audit`
- [ ] T0XX Create commit: `/mykit.commit`
- [ ] T0XX Create pull request: `/mykit.pr -c`
```

Where:
- `featureName` = extracted from spec header, plan summary, or derived from guided answers
- `branch` = current git branch
- `currentDate` = today's date in YYYY-MM-DD format
- `contentSource` = one of: "spec", "plan", "spec+plan", "guided"

### Step 14: Preview or Execute

**If `flag` is `-r` (Read Mode)**:

Display the tasks content with a preview header:

```
## Current Task List

{formatted tasks content from Step 13}
```

Stop execution here.

**If `flag` is `-c` or `-u` (Create/Update Mode)**:

1. Create the specs directory if it doesn't exist
2. Write the tasks content to `tasksPath`
3. Update `.mykit/state.json` with:
   - `workflow_step` = "tasks"
   - `tasks_path` = tasksPath
   - `last_command` = "/mykit.tasks"
   - `last_command_time` = current ISO timestamp

4. Display confirmation:

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
| Not on feature branch | "No feature branch detected. Use `/mykit.start` first." |
| Major-mode artifacts detected | "Major-mode planning artifacts detected. Consider using Major mode for richer task generation." |
| File write failed | "Error: Unable to create tasks file at {path}. Check permissions." |

## Example Outputs

### Read Mode (default)

```
/mykit.tasks

## Current Task List

# Tasks: Add user authentication

**Branch**: `042-auth` | **Created**: 2025-12-07 | **Source**: spec+plan

## Implementation

- [ ] T001 Create user model with email and password fields
- [ ] T002 Implement password hashing service
- [ ] T003 Create login endpoint
- [ ] T004 Create registration endpoint
- [ ] T005 Add session management
- [ ] T006 Implement logout functionality
- [ ] T007 Add authentication middleware

## Completion

- [ ] T008 Run validation: `/mykit.audit`
- [ ] T009 Create commit: `/mykit.commit`
- [ ] T010 Create pull request: `/mykit.pr -c`
```

### Create Mode

```
/mykit.tasks -c

**Tasks generated successfully!**

**File**: specs/042-auth/tasks.md
**Source**: Combined from specification and plan
**Task Count**: 7 implementation + 3 completion = 10 total

Next step: `/mykit.implement` to start working through tasks.
```

### Guided Conversation Mode

```
/mykit.tasks -c

No spec or plan found. Starting guided conversation.

**Tasks: Q1/3**
What needs to be built or changed?
> Add a dark mode toggle to the settings page

**Tasks: Q2/3**
What components or files are affected?
> Settings component, theme context, CSS variables

**Tasks: Q3/3**
What defines 'done' for this work?
> User can toggle between light and dark mode, preference is saved

**Tasks generated successfully!**

**File**: specs/042-dark-mode/tasks.md
**Source**: Generated from guided conversation
**Task Count**: 6 implementation + 3 completion = 9 total

Next step: `/mykit.implement` to start working through tasks.
```

## Related Commands

| Command | Relationship |
|---------|--------------|
| `/mykit.specify` | Create spec before running this command (optional) |
| `/mykit.plan` | Create plan before running this command (optional) |
| `/mykit.start` | Select issue and create branch |
| `/mykit.implement` | Next step after task generation |
| `/mykit.status` | Shows current workflow phase |

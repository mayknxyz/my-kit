<!-- Minor mode: custom lightweight task generation workflow -->

## Minor Mode Tasks

Generate a lightweight task breakdown from feature specification and/or implementation plan, or via guided conversation.

### Step 1: Check Prerequisites

Verify we're in a git repository:

```bash
git rev-parse --git-dir 2>/dev/null
```

**If not in a git repository**, display error and stop:

```
**Error**: Not in a git repository.

Run `git init` to initialize a repository, or navigate to an existing git repository.
```

### Step 2: Parse Arguments

Parse the command arguments to determine:
- `hasCreateAction`: always true (CRUD routing handled by command router)
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

### Step 6: Check for Full-Mode Artifacts

Check if any of these full-mode planning artifacts exist in `specsDir`:
- `research.md`
- `data-model.md`
- `contracts/` directory

**If any of these exist**:

Display notice and continue:
```
**Notice**: Full-mode artifacts detected (research.md, data-model.md, contracts/).

These artifacts won't be leveraged in minor mode. Proceeding with minor task generation.
```

### Step 7: Check for Existing Tasks

**If tasks file exists at `tasksPath`**:

**If `hasForceFlag` is true**:
- Continue (will overwrite)

**If `hasForceFlag` is false AND `hasCreateAction` is true**:
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
- `hasPlan`: true if plan.md exists and has content >= 50 characters

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
- Generate 5-15 implementation tasks
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

### Step 12: Format Tasks Content

Generate the tasks.md content using this structure:

```markdown
# Tasks: {featureName}

**Branch**: `{branch}` | **Created**: {currentDate} | **Source**: {contentSource}

## Implementation

- [ ] T001 {first task description}
- [ ] T002 {second task description}
...
- [ ] T0XX {last implementation task}
```

Where:
- `featureName` = extracted from spec header, plan summary, or derived from guided answers
- `branch` = current git branch
- `currentDate` = today's date in YYYY-MM-DD format
- `contentSource` = one of: "spec", "plan", "spec+plan", "guided"

### Step 13: Preview or Execute

**If `hasCreateAction` is false (Preview Mode — deprecated, handled by router)**:

Display the tasks content with a preview header:

```
## PREVIEW - Proposed Task List

{formatted tasks content from Step 12}

---

**Note**: This is a preview. No files have been created.

To save these tasks, run: `/mykit.tasks -c`
```

Stop execution here.

**If `hasCreateAction` is true (Execute Mode)**:

1. Create the specs directory if it doesn't exist
2. Write the tasks content to `tasksPath`
3. Display confirmation:

```
**Tasks generated successfully!**

**File**: {tasksPath}
**Source**: {contentSource description}
**Task Count**: {totalTaskCount} tasks

Next step: `/mykit.implement` to start working through tasks.
```

Where `contentSource description` is:
- "spec": "Extracted from feature specification"
- "plan": "Extracted from implementation plan"
- "spec+plan": "Combined from specification and plan"
- "guided": "Generated from guided conversation"

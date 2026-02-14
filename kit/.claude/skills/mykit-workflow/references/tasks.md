<!-- Task generation workflow -->

## Tasks

Generate a lightweight task breakdown from feature specification and/or implementation plan, or via guided conversation.

### Step 1: Check Prerequisite

```bash
source $HOME/.claude/skills/mykit/references/scripts/fetch-branch-info.sh
```

Check if the plan file exists at `PLAN_PATH`. **If not**, display error and stop:

```
**Error**: No implementation plan found at `{PLAN_PATH}`.

Run `/mykit.plan` first.
```

### Step 2: Check for Existing Tasks

**If tasks file exists at `tasksPath`**:

Use `AskUserQuestion` tool to prompt:
  - header: "Existing Tasks"
  - question: "A tasks file already exists at this location. What would you like to do?"
  - options:
    1. label: "Overwrite", description: "Replace the existing tasks entirely"
    2. label: "Cancel", description: "Abort and keep the existing tasks"

- If user selects "Cancel", display message and stop:
  ```
  Operation cancelled. Existing tasks preserved.
  ```

### Step 3: Read and Analyze Artifacts

Read both `specPath` and `planPath`.

**From spec**, extract:
- **Feature name**: From the `# Feature Specification:` heading
- **User Stories**: All sections matching `### User Story N - {title} (Priority: {P#})`
- **Functional Requirements**: All items under `### Functional Requirements`
- **Success Criteria**: All items under `### Measurable Outcomes`

**From plan**, extract:
- **Skills**: All items under `## Skills`
- **Implementation Phases**: All sections matching `### Phase N: {title}` with key tasks
- **Design Decisions**: All sections under `## Design Decisions`

### Step 4: Generate Task List

**Rules**:
- Generate 5-15 implementation tasks
- Each task should represent approximately 30 minutes to 2 hours of focused work
- Align tasks with plan phase structure
- Prioritize P1 user stories from spec
- Map functional requirements to implementation tasks
- Order by dependency and phase number
- Format: `- [ ] T### {task description}`

### Step 5: Format and Write Tasks

Generate and write `tasksPath` using this structure:

```markdown
# Tasks: {featureName}

**Branch**: `{branch}` | **Created**: {currentDate} | **Status**: Pending

## Skills

{Copy the ## Skills section from plan.md}

## Implementation

- [ ] T001 {first task description}
- [ ] T002 {second task description}
...
- [ ] T0XX {last implementation task}
```

Where:
- `featureName` = extracted from spec header
- `branch` = current git branch
- `currentDate` = today's date in YYYY-MM-DD format

Display confirmation:

```
**Tasks generated successfully!**

**File**: {tasksPath}
**Task Count**: {totalTaskCount} tasks

Next step: `/mykit.implement` to start working through tasks.
```

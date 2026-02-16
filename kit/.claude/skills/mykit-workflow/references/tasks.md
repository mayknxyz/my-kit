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

**Broaden skills detection**: In addition to skills explicitly listed in the plan, scan the spec and plan content for keywords that match other available skills (see the skill keyword table in `references/plan.md` Step 5). Add any additionally detected skills to the `## Skills` section in tasks.md. This ensures the implement step has all relevant domain skills active, not just the ones originally identified during planning.

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

Read the template at `$HOME/.claude/skills/mykit/references/templates/tasks.md` and generate `tasksPath` by filling placeholders:

- `[FEATURE NAME]` = extracted from spec header
- `[BRANCH]` = current git branch
- `[DATE]` = today's date in YYYY-MM-DD format
- `[SKILLS FROM PLAN]` = copy the `## Skills` section content from plan.md
- Replace the example `T001`–`T003` rows with the actual generated tasks

Display confirmation:

```
**Tasks generated successfully!**

**File**: {tasksPath}
**Task Count**: {totalTaskCount} tasks

Next step: `/mykit.implement` to start working through tasks.
```

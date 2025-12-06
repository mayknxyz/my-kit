# /mykit.plan

Create a lightweight implementation plan from a feature specification via guided conversation.

## Usage

```
/mykit.plan [create] [--force]
```

- No action: Preview mode (shows what would be created without writing files)
- `create`: Execute mode (creates the plan file)
- `--force`: Overwrite existing plan without confirmation

## Description

This command creates lightweight implementation plans for the Lite workflow. It reads the feature specification, optionally asks clarifying technical questions (0-5), and generates a plan with Technical Context, Design Decisions, and Implementation Phases sections.

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
- `hasCreateAction`: true if `create` is present
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

You must be on a feature branch (e.g., `042-feature-name`) to create a plan.

To select an issue and create a branch: `/mykit.backlog select`
```

### Step 5: Determine Paths

Set the following paths based on the current branch:
- `specPath = specs/{branch}/spec.md`
- `planPath = specs/{branch}/plan.md`
- `specsDir = specs/{branch}/`

### Step 6: Check for Existing Spec File

Check if the spec file exists at `specPath`.

**If spec file does NOT exist**:

Display error and stop:
```
**Error**: No specification found.

A spec file is required before creating a plan.

To create a specification: `/mykit.specify create`
```

### Step 7: Check for Speckit Conflict

Check if any of these `/speckit.plan` artifacts exist in `specsDir`:
- `research.md`
- `data-model.md`
- `contracts/` directory

**If any of these exist**:

Display error and stop:
```
**Error**: This feature uses the full /speckit.plan workflow.

Found existing planning artifacts that indicate you started with /speckit.plan.
The /mykit.plan command is mutually exclusive with /speckit.plan.

To continue with the full workflow: `/speckit.tasks`
```

### Step 8: Check for Existing Plan

**If plan file exists at `planPath`**:

**If `hasForceFlag` is true**:
- Continue (will overwrite)

**If `hasForceFlag` is false AND `hasCreateAction` is true**:
- Use `AskUserQuestion` tool to prompt:
  - header: "Existing Plan"
  - question: "A plan file already exists at this location. What would you like to do?"
  - options:
    1. label: "Overwrite", description: "Replace the existing plan entirely"
    2. label: "Cancel", description: "Abort and keep the existing plan"

- If user selects "Cancel", display message and stop:
  ```
  Operation cancelled. Existing plan preserved.
  ```

### Step 9: Read and Analyze Spec File

Read the spec file content from `specPath`.

Extract the following information from the spec:
- **Feature name**: From the `# Feature Specification:` heading
- **User Stories**: All sections matching `### User Story N -`
- **Functional Requirements**: All items under `### Functional Requirements`
- **Key Entities**: All items under `### Key Entities` (if present)
- **Success Criteria**: All items under `### Measurable Outcomes`
- **Clarifications**: Any recorded clarifications from `## Clarifications` section

### Step 10: Identify Technical Decisions (Guided Conversation)

Analyze the spec content to identify areas that may need technical clarification.

**Question triggers** (ask only if relevant to the spec):

1. **Technology stack**: If spec mentions features requiring specific tech choices (e.g., authentication, data storage, APIs)
2. **Integration approach**: If spec mentions external services or integrations
3. **Performance approach**: If spec has specific performance requirements
4. **Testing strategy**: If spec mentions testing requirements without specifying approach

**For each identified ambiguity** (maximum 3-5 questions total):

Use `AskUserQuestion` tool with:
- header: "Plan: {topic}"
- question: "{specific question about the technical decision}"
- multiSelect: false
- options: 2-4 relevant options with descriptions

Record each answer for use in plan generation.

**If no ambiguities detected**: Skip to Step 11 without asking questions.

### Step 11: Generate Plan Content

Generate the plan content using this structure:

```markdown
# Implementation Plan: {featureName}

**Branch**: `{branch}` | **Created**: {currentDate} | **Spec**: [spec.md](./spec.md)

## Technical Context

- **Technologies**: {list technologies from spec, codebase context, or guided conversation answers}
- **Dependencies**: {list external dependencies identified}
- **Integration Points**: {list what this feature connects to}

## Design Decisions

### {Decision Title from guided conversation or spec}

**Choice**: {what was decided}
**Rationale**: {why this choice makes sense}

{Repeat for each significant design decision}

## Implementation Phases

### Phase 1: {phase-title}

{description of what this phase accomplishes}

**Key Tasks**:
- {task 1}
- {task 2}
- {task 3}

### Phase 2: {phase-title}

{description of what this phase accomplishes}

**Key Tasks**:
- {task 1}
- {task 2}

{Continue for additional phases as needed}

## Success Criteria Reference

{Reference the success criteria from the spec that this plan addresses}
```

Where:
- `featureName` = extracted from spec header
- `branch` = current git branch
- `currentDate` = today's date in YYYY-MM-DD format

### Step 12: Preview or Execute

**If `hasCreateAction` is false (Preview Mode)**:

Display the plan content with a preview header:

```
## PREVIEW - Proposed Implementation Plan

{formatted plan content from Step 11}

---

**Note**: This is a preview. No files have been created.

To save this plan, run: `/mykit.plan create`
```

Stop execution here.

**If `hasCreateAction` is true (Execute Mode)**:

1. Create the specs directory if it doesn't exist
2. Write the plan content to `planPath`
3. Update `.mykit/state.json` with:
   - `workflow_step` = "planning"
   - `plan_path` = planPath
   - `last_command` = "/mykit.plan"
   - `last_command_time` = current ISO timestamp

4. Display confirmation:

```
**Plan created successfully!**

**File**: {planPath}
**Source**: {questionCount > 0 ? "Spec analysis + guided conversation" : "Spec analysis"}

Next step: `/mykit.tasks generate` to create the task breakdown.
```

## Error Handling

| Error | Message |
|-------|---------|
| Not a git repository | "Not in a git repository. Run `git init` to initialize." |
| Not on feature branch | "No feature branch detected. Use `/mykit.backlog select` first." |
| No spec file | "No specification found. Run `/mykit.specify create` first." |
| Speckit conflict | "This feature uses /speckit.plan workflow. Continue with `/speckit.tasks` instead." |
| File write failed | "Error: Unable to create plan file at {path}. Check permissions." |

## Example Outputs

### Preview Mode

```
/mykit.plan

## PREVIEW - Proposed Implementation Plan

# Implementation Plan: Add user authentication

**Branch**: `042-auth` | **Created**: 2025-12-07 | **Spec**: [spec.md](./spec.md)

## Technical Context

- **Technologies**: Markdown (Claude Code slash command), Bash, git CLI
- **Dependencies**: Claude Code conversation context
- **Integration Points**: .mykit/state.json, specs/{branch}/

## Design Decisions

### Authentication Method

**Choice**: Session-based authentication with JWT tokens
**Rationale**: Standard approach for web applications, well-supported by frameworks

## Implementation Phases

### Phase 1: Core Authentication

Set up the basic authentication flow.

**Key Tasks**:
- Create user model
- Implement login endpoint
- Add session management

...

---

**Note**: This is a preview. No files have been created.

To save this plan, run: `/mykit.plan create`
```

### Execute Mode

```
/mykit.plan create

**Plan created successfully!**

**File**: specs/042-auth/plan.md
**Source**: Spec analysis + guided conversation

Next step: `/mykit.tasks generate` to create the task breakdown.
```

### Guided Conversation Mode

```
/mykit.plan create

**Plan: Technology Stack**

The spec mentions data persistence but doesn't specify a storage approach.

| Option | Description |
|--------|-------------|
| A | File-based JSON storage (simple, no external deps) |
| B | SQLite database (relational, single file) |
| C | PostgreSQL (full database server) |

Reply with option letter or provide your own answer.

> A

**Plan created successfully!**

**File**: specs/042-feature/plan.md
**Source**: Spec analysis + guided conversation

Next step: `/mykit.tasks generate` to create the task breakdown.
```

## Related Commands

| Command | Relationship |
|---------|--------------|
| `/mykit.specify` | Create spec before running this command |
| `/mykit.backlog` | Select issue before creating spec |
| `/mykit.tasks` | Next step after plan creation |
| `/mykit.status` | Shows current workflow phase |

<!-- Patch mode: optional lightweight planning workflow -->

## Patch Mode Plan

Create an optional lightweight implementation plan from a feature specification or via guided conversation.

In Patch mode, creating a plan is optional. For simple fixes, skip directly to `/mykit.implement`. For complex patches that benefit from a documented approach, use this planning workflow.

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

You must be on a feature branch (e.g., `042-feature-name`) to create a plan.

To select an issue and create a branch: `/mykit.start`
```

### Step 5: Determine Paths

Set the following paths based on the current branch:
- `specPath = specs/{branch}/spec.md`
- `planPath = specs/{branch}/plan.md`
- `specsDir = specs/{branch}/`

### Step 6: Check for Existing Spec File

Check if the spec file exists at `specPath`.

**If spec file does NOT exist**:

Display notice and continue to Step 10 (guided conversation):

```
**Notice**: No specification found at `{specPath}`. Proceeding with guided plan creation.
```

Skip Steps 7-9 and go directly to Step 10.

### Step 7: Check for Full-Mode Artifacts

Check if any of these full-mode planning artifacts exist in `specsDir`:
- `research.md`
- `data-model.md`
- `contracts/` directory

**If any of these exist**:

Display notice and continue:
```
**Notice**: Full-mode artifacts detected (research.md, data-model.md, contracts/).

These artifacts won't be leveraged in patch mode. Proceeding with patch plan.
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

Go to Step 11 (Identify Technical Decisions).

### Step 10: Guided Conversation (if no spec)

**Trigger this step when spec file does not exist.**

**Question 1: What to fix/change**

Use `AskUserQuestion` tool:
- header: "Plan: Q1/3"
- question: "What is the fix or change you're planning?"
- multiSelect: false
- options: (none - free text response expected)

Wait for user response and store as `whatToChange`.

**Question 2: Technical approach**

Use `AskUserQuestion` tool:
- header: "Plan: Q2/3"
- question: "What technical approach will you take?"
- multiSelect: false
- options: (none - free text response expected)

Wait for user response and store as `technicalApproach`.

**Question 3: Areas affected**

Use `AskUserQuestion` tool:
- header: "Plan: Q3/3"
- question: "What areas of the codebase are affected?"
- multiSelect: false
- options: (none - free text response expected)

Wait for user response and store as `areasAffected`.

Set `contentSource = "guided"`. Go to Step 12 (Generate Plan Content).

### Step 11: Identify Technical Decisions (Guided Conversation)

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

**If no ambiguities detected**: Skip to Step 12 without asking questions.

### Step 12: Generate Plan Content

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
- `featureName` = extracted from spec header, or derived from guided answers
- `branch` = current git branch
- `currentDate` = today's date in YYYY-MM-DD format

### Step 13: Preview or Execute

**If `hasCreateAction` is false (Preview Mode — deprecated, handled by router)**:

Display the plan content with a preview header:

```
## PREVIEW - Proposed Implementation Plan

{formatted plan content from Step 12}

---

**Note**: This is a preview. No files have been created.

To save this plan, run: `/mykit.plan -c`
```

Stop execution here.

**If `hasCreateAction` is true (Execute Mode)**:

1. Create the specs directory if it doesn't exist
2. Write the plan content to `planPath`
3. Display confirmation:

```
**Plan created successfully!**

**File**: {planPath}
**Source**: {questionCount > 0 ? "Spec analysis + guided conversation" : contentSource === "guided" ? "Guided conversation" : "Spec analysis"}

Next step: `/mykit.tasks -c` to create a task breakdown, or `/mykit.implement` to start implementing directly.
```

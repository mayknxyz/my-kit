<!-- Plan workflow -->

## Plan

Create a lightweight implementation plan from a feature specification via guided conversation.

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

You must be on a feature branch (e.g., `042-feature-name`) to create a plan.

To create a branch: `/mykit.specify`
```

### Step 4: Determine Paths

Set the following paths based on the current branch:
- `specPath = specs/{branch}/spec.md`
- `planPath = specs/{branch}/plan.md`
- `specsDir = specs/{branch}/`

### Step 5: Check for Existing Spec File

Check if the spec file exists at `specPath`.

**If spec file does NOT exist**:

Display error and stop:
```
**Error**: No specification found.

A spec file is required before creating a plan.

To create a specification: `/mykit.specify`
```

### Step 6: Check for Existing Plan

**If plan file exists at `planPath`**:

Use `AskUserQuestion` tool to prompt:
  - header: "Existing Plan"
  - question: "A plan file already exists at this location. What would you like to do?"
  - options:
    1. label: "Overwrite", description: "Replace the existing plan entirely"
    2. label: "Cancel", description: "Abort and keep the existing plan"

- If user selects "Cancel", display message and stop:
  ```
  Operation cancelled. Existing plan preserved.
  ```

### Step 7: Read and Analyze Spec File

Read the spec file content from `specPath`.

Extract the following information from the spec:
- **Feature name**: From the `# Feature Specification:` heading
- **User Stories**: All sections matching `### User Story N -`
- **Functional Requirements**: All items under `### Functional Requirements`
- **Key Entities**: All items under `### Key Entities` (if present)
- **Success Criteria**: All items under `### Measurable Outcomes`
- **Clarifications**: Any recorded clarifications from `## Clarifications` section

### Step 8: Identify Technical Decisions (Guided Conversation)

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

**If no ambiguities detected**: Skip to Step 9 without asking questions.

### Step 9: Generate Plan Content

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

### Step 10: Write Plan

1. Create the specs directory if it doesn't exist
2. Write the plan content to `planPath`
3. Display confirmation:

```
**Plan created successfully!**

**File**: {planPath}
**Source**: {questionCount > 0 ? "Spec analysis + guided conversation" : "Spec analysis"}

Next step: `/mykit.tasks` to create the task breakdown.
```

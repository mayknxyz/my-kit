# Data Model: /mykit.tasks

**Date**: 2025-12-07
**Branch**: `011-task-generation`

## Overview

This document defines the data structures used by the `/mykit.tasks` command. Since this is a Claude Code slash command (not a traditional application), the "data model" focuses on:
1. Input artifacts the command reads
2. Output file structure the command produces
3. State management fields the command updates

## Input Artifacts

### FeatureContext

The context derived from the current git branch and filesystem.

| Field | Type | Source | Description |
|-------|------|--------|-------------|
| `branchName` | string | `git rev-parse --abbrev-ref HEAD` | Current git branch name |
| `issueNumber` | number \| null | Extracted from branch pattern `^([0-9]+)-` | GitHub issue number if on feature branch |
| `isFeatureBranch` | boolean | Derived from issueNumber presence | Whether on a valid feature branch |
| `specsDir` | string | `specs/{branchName}/` | Directory containing feature artifacts |

### DocumentationArtifacts

Files that may exist and inform task generation.

| Artifact | Path | Purpose |
|----------|------|---------|
| `spec.md` | `specs/{branch}/spec.md` | Feature specification with user stories and requirements |
| `plan.md` | `specs/{branch}/plan.md` | Implementation plan with phases and design decisions |
| `research.md` | `specs/{branch}/research.md` | **Speckit indicator** - if exists, redirect to /speckit.tasks |
| `data-model.md` | `specs/{branch}/data-model.md` | **Speckit indicator** - if exists, redirect to /speckit.tasks |
| `contracts/` | `specs/{branch}/contracts/` | **Speckit indicator** - if exists, redirect to /speckit.tasks |

### SpecContent (extracted from spec.md)

| Field | Type | Extraction Pattern | Description |
|-------|------|-------------------|-------------|
| `featureName` | string | `# Feature Specification: {name}` | Name of the feature |
| `userStories` | UserStory[] | `### User Story N - {title} (Priority: {P#})` | Ordered list of user stories |
| `requirements` | Requirement[] | `- **FR-###**: {description}` | Functional requirements |
| `successCriteria` | string[] | `- **SC-###**: {description}` | Success criteria items |
| `clarifications` | Clarification[] | `- Q: {question} → A: {answer}` | Recorded clarifications |

#### UserStory

| Field | Type | Description |
|-------|------|-------------|
| `number` | number | Story number (1, 2, 3...) |
| `title` | string | Brief title of the story |
| `priority` | string | Priority level (P1, P2, P3...) |
| `description` | string | Full story description |
| `acceptanceScenarios` | string[] | Given/When/Then scenarios |

#### Requirement

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Requirement ID (FR-001, FR-002...) |
| `description` | string | Requirement text |

### PlanContent (extracted from plan.md)

| Field | Type | Extraction Pattern | Description |
|-------|------|-------------------|-------------|
| `summary` | string | `## Summary` section | Brief feature summary |
| `phases` | Phase[] | `### Phase N: {title}` | Implementation phases |
| `designDecisions` | DesignDecision[] | `### DD-###: {title}` | Key design decisions |

#### Phase

| Field | Type | Description |
|-------|------|-------------|
| `number` | number | Phase number (1, 2, 3...) |
| `title` | string | Phase title |
| `description` | string | What this phase accomplishes |
| `keyTasks` | string[] | Bullet points under "Key Tasks" |

### GuidedAnswers (from conversation)

When no artifacts exist, answers to the 3 guided questions.

| Field | Type | Question | Description |
|-------|------|----------|-------------|
| `whatToBuild` | string | "What needs to be built or changed?" | Core work description |
| `componentsAffected` | string | "What components or files are affected?" | Scope of changes |
| `definitionOfDone` | string | "What defines 'done' for this work?" | Completion criteria |

## Output Structure

### tasks.md File Format

```markdown
# Tasks: {featureName}

**Branch**: `{branch}` | **Created**: {date} | **Source**: {source}

## Implementation

- [ ] T001 {task description}
- [ ] T002 {task description}
...
- [ ] T0XX {task description}

## Completion

- [ ] T0XX Run validation: `/mykit.validate`
- [ ] T0XX Create commit: `/mykit.commit create`
- [ ] T0XX Create pull request: `/mykit.pr create`
```

### Task Entity

Each generated task follows this structure:

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Task identifier (T001, T002...) |
| `description` | string | Actionable task description |
| `checked` | boolean | Completion status (always false when generated) |
| `estimatedEffort` | string | ~30min-2hr (implicit, not rendered) |

### TaskMetadata

Additional context tracked but not rendered in tasks.md:

| Field | Type | Description |
|-------|------|-------------|
| `source` | enum | `"spec"` \| `"plan"` \| `"guided"` \| `"spec+plan"` |
| `totalTasks` | number | Count including completion tasks |
| `implementationTasks` | number | Count excluding completion tasks |

## State Management

### state.json Updates

Fields updated in `.mykit/state.json` after successful task generation:

| Field | Type | Value |
|-------|------|-------|
| `workflow_step` | string | `"tasks"` |
| `tasks_path` | string | `"specs/{branch}/tasks.md"` |
| `last_command` | string | `"/mykit.tasks"` |
| `last_command_time` | string | ISO 8601 timestamp |

### Full State Shape (context)

```json
{
  "version": "1.0.0",
  "current_feature": {
    "issue_number": 11,
    "issue_title": "Task Generation",
    "branch": "011-task-generation",
    "spec_path": "specs/011-task-generation/spec.md"
  },
  "workflow_step": "tasks",
  "tasks_path": "specs/011-task-generation/tasks.md",
  "last_command": "/mykit.tasks",
  "last_command_time": "2025-12-07T12:00:00Z"
}
```

## Constraints

### Task Generation Rules

| Constraint | Value | Source |
|------------|-------|--------|
| Minimum implementation tasks | 5 | Spec clarification |
| Maximum implementation tasks | 15 | Spec clarification |
| Task granularity | 30min-2hr | Spec clarification |
| Completion tasks | Always 3 | FR-004 |
| Total task range | 8-18 | Derived (5-15 + 3) |

### Validation Rules

| Rule | Description |
|------|-------------|
| Feature branch required | Must match pattern `^([0-9]+)-` |
| No speckit conflict | research.md, data-model.md, contracts/ must not exist |
| Task ID uniqueness | T### IDs must be sequential and unique |
| Completion tasks last | Always appended as final section |

## Relationships

```
FeatureContext
    │
    ├── specsDir
    │       │
    │       ├── spec.md ──────► SpecContent
    │       │                       │
    │       │                       ├── userStories[]
    │       │                       ├── requirements[]
    │       │                       └── successCriteria[]
    │       │
    │       └── plan.md ──────► PlanContent
    │                               │
    │                               ├── phases[]
    │                               └── designDecisions[]
    │
    └── GuidedAnswers (fallback)
            │
            ├── whatToBuild
            ├── componentsAffected
            └── definitionOfDone

        ▼ (Task Generation)

    tasks.md
        │
        ├── Implementation Tasks[]
        │       └── Task { id, description, checked }
        │
        └── Completion Tasks[]
                └── Task { id, description, checked }

        ▼ (State Update)

    .mykit/state.json
        │
        └── { workflow_step, tasks_path, last_command, last_command_time }
```

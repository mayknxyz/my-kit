# Data Model: Lightweight Spec Command

**Branch**: `009-lightweight-spec` | **Date**: 2025-12-07

## Entities

### 1. Spec File

**Description**: Lightweight markdown specification document created by the command.

**Location**: `specs/{branch-name}/spec.md`

**Structure**:
```markdown
# Feature Specification: {FEATURE_NAME}

**Feature Branch**: `{branch}`
**Created**: {date}
**Status**: Draft
**GitHub Issue**: #{issue_number} (link)

## Overview

{summary_content}

## User Scenarios

### User Story 1 - {title} (Priority: P1)

{scenario_description}

**Acceptance Scenarios**:

1. **Given** {context}, **When** {action}, **Then** {outcome}

## Requirements

### Functional Requirements

- **FR-001**: {requirement}

## Success Criteria

- **SC-001**: {measurable_outcome}
```

**Fields**:

| Field | Type | Source | Required |
|-------|------|--------|----------|
| FEATURE_NAME | string | Issue title or user input | Yes |
| branch | string | Current git branch | Yes |
| date | ISO date | System date | Yes |
| issue_number | integer | State or extracted from branch | No* |
| summary_content | string | Issue body or Q1 answer | Yes |
| problem_content | string | Issue body or Q2 answer | Yes |
| acceptance_criteria | string[] | Issue body or Q3 answer | Yes |

*Required unless `--no-issue` flag is used

**Validation Rules**:
- File path must match pattern: `specs/{branch}/spec.md`
- Summary must not be empty
- At least one acceptance criterion required

---

### 2. Workflow State

**Description**: Current workflow progress tracked in state file.

**Location**: `.mykit/state.json`

**Structure** (relevant fields only):
```json
{
  "version": "1.0.0",
  "current_feature": {
    "issue_number": 42,
    "issue_title": "Add dark mode toggle",
    "branch": "042-dark-mode",
    "spec_path": "specs/042-dark-mode/spec.md"
  },
  "workflow_step": "specification",
  "last_command": "/mykit.specify",
  "last_command_time": "2025-12-07T14:30:00Z"
}
```

**Fields Updated by `/mykit.specify`**:

| Field | Type | Update Condition |
|-------|------|------------------|
| current_feature.spec_path | string | On successful spec creation |
| workflow_step | enum | Set to "specification" |
| last_command | string | Always (set to "/mykit.specify") |
| last_command_time | ISO datetime | Always |

**State Transitions**:
```
workflow_step values:
  "not_started" → "specification" (after /mykit.specify create)
  "specification" → "planning" (after /speckit.plan or /mykit.plan)
```

---

### 3. GitHub Issue (External)

**Description**: Source data for spec extraction, accessed via `gh` CLI.

**Access Pattern**: `gh issue view {number} --json body,title,state`

**Response Structure**:
```json
{
  "body": "## Problem\n\nUsers need...\n\n## Acceptance Criteria\n\n- [ ] When...",
  "title": "feat: Add dark mode toggle",
  "state": "OPEN"
}
```

**Extraction Mapping**:

| Issue Field | Spec Section | Extraction Logic |
|-------------|--------------|------------------|
| title | FEATURE_NAME | Direct mapping |
| body (## Summary or ## Description) | Overview | Heading extraction |
| body (## Problem or ## Why) | Problem section | Heading extraction |
| body (## Acceptance or ## Criteria) | Acceptance Criteria | Heading extraction |
| body (if no headings, >= 50 chars) | Overview | Full body as context |

---

### 4. Command Arguments

**Description**: Input parsed from command invocation.

**Pattern**: `/mykit.specify [action] [flags]`

**Arguments**:

| Argument | Type | Values | Default |
|----------|------|--------|---------|
| action | string | `create`, (empty) | (empty) = preview |
| --no-issue | flag | present/absent | absent |
| --force | flag | present/absent | absent |

**Behavior Matrix**:

| action | --no-issue | --force | Behavior |
|--------|------------|---------|----------|
| (empty) | - | - | Preview mode: show spec, don't write |
| create | no | no | Execute: require issue, prompt on existing |
| create | yes | no | Execute: skip issue validation |
| create | no | yes | Execute: overwrite without prompt |
| create | yes | yes | Execute: skip issue, overwrite without prompt |

---

## Relationships

```
┌─────────────────┐
│  GitHub Issue   │ ──extracts──▶ ┌─────────────┐
│  (external)     │               │  Spec File  │
└─────────────────┘               └─────────────┘
                                        │
                                        │ path stored in
                                        ▼
┌─────────────────┐               ┌─────────────────┐
│ Command Args    │ ──triggers──▶ │ Workflow State  │
└─────────────────┘               └─────────────────┘
```

---

## File System Layout

```
.mykit/
├── state.json                    # Updated by command
└── templates/
    └── lite/
        └── spec.md               # Template (read-only)

specs/
└── {issue-number}-{slug}/
    └── spec.md                   # Created by command
```

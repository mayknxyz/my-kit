# Data Model: /mykit.plan

**Feature**: 010-lightweight-plan
**Date**: 2025-12-07

## Entities

### Plan File (Output)

**Location**: `specs/{branch}/plan.md`
**Format**: Markdown

**Structure**:
```markdown
# Implementation Plan: {feature-name}

**Branch**: `{branch}` | **Created**: {date} | **Spec**: [spec.md](./spec.md)

## Technical Context
- **Technologies**: {list}
- **Dependencies**: {list}
- **Integration Points**: {list}

## Design Decisions
### {Decision Title}
**Choice**: {decision}
**Rationale**: {why}

## Implementation Phases
### Phase 1: {title}
{description and tasks}
```

**Validation Rules**:
- Must contain all three sections: Technical Context, Design Decisions, Implementation Phases
- Branch must match current git branch
- Date must be in YYYY-MM-DD format
- Spec link must be relative path to spec.md

---

### State File (Updated)

**Location**: `.mykit/state.json`
**Format**: JSON

**Fields Updated by /mykit.plan**:

| Field | Type | Description |
|-------|------|-------------|
| `workflow_step` | string | Set to `"planning"` |
| `plan_path` | string | Absolute or relative path to plan.md |
| `last_command` | string | Set to `"/mykit.plan"` |
| `last_command_time` | string | ISO 8601 timestamp |

**Example**:
```json
{
  "workflow_step": "planning",
  "plan_path": "specs/010-lightweight-plan/plan.md",
  "last_command": "/mykit.plan",
  "last_command_time": "2025-12-07T12:00:00Z",
  "current_feature": {
    "branch": "010-lightweight-plan",
    "issue_number": 10,
    "spec_path": "specs/010-lightweight-plan/spec.md"
  }
}
```

---

### Spec File (Input)

**Location**: `specs/{branch}/spec.md`
**Format**: Markdown

**Required Sections for Plan Generation**:
- User Scenarios (for implementation phases)
- Functional Requirements (for technical context)
- Key Entities (for data model awareness)
- Success Criteria (for validation)

**Optional Sections**:
- Clarifications (provides additional context)
- Edge Cases (informs error handling)

---

## Relationships

```
┌─────────────────┐
│   spec.md       │ ─── Input ───▶ /mykit.plan command
│   (required)    │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│  /mykit.plan    │ ─── Reads ───▶ Spec content
│   command       │ ─── Writes ──▶ plan.md
│                 │ ─── Updates ─▶ state.json
└─────────────────┘
         │
         ▼
┌─────────────────┐     ┌─────────────────┐
│   plan.md       │     │  state.json     │
│   (output)      │     │  (updated)      │
└─────────────────┘     └─────────────────┘
```

---

## State Transitions

### Workflow Step Progression

```
"specification" ──▶ "planning" ──▶ "tasks" ──▶ "implementation"
       │                │              │              │
       ▼                ▼              ▼              ▼
 /mykit.specify   /mykit.plan   /mykit.tasks   /mykit.implement
```

### Command Preconditions

| Current Step | Required for /mykit.plan |
|--------------|--------------------------|
| (none) | ERROR: Run /mykit.specify first |
| specification | ✅ Can proceed |
| planning | ✅ Can overwrite with --force |
| tasks | ✅ Can regenerate plan |
| implementation | ✅ Can regenerate plan |

---

## Validation Rules

### Pre-execution Checks

1. **Git Repository**: `git rev-parse --git-dir` must succeed
2. **Feature Branch**: Branch name must match `^[0-9]+-` pattern
3. **Spec File Exists**: `specs/{branch}/spec.md` must exist
4. **No Speckit Conflict**: `research.md`, `data-model.md`, `contracts/` must NOT exist

### Post-execution Validation

1. **Plan Written**: `specs/{branch}/plan.md` exists
2. **State Updated**: `.mykit/state.json` contains `workflow_step: "planning"`
3. **Three Sections**: Plan contains Technical Context, Design Decisions, Implementation Phases

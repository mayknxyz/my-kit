# Research: /mykit.tasks - Task Generation

**Date**: 2025-12-07
**Branch**: `011-task-generation`

## Research Objectives

1. Understand existing command patterns in My Kit
2. Determine task output format compatibility with `/mykit.implement`
3. Identify speckit vs mykit workflow differentiation

## Findings

### 1. Command Pattern Analysis

**Source**: `/mykit.specify.md`, `/mykit.plan.md`

**Decision**: Follow the established step-by-step implementation pattern

**Rationale**: Both existing commands share identical structure:
- Step 1: Check git repository prerequisite
- Step 2: Parse arguments (`create`, `--force`)
- Step 3: Get branch and extract issue number
- Step 4: Validate feature branch requirement
- Step 5-6: Determine paths and check for existing files
- Step 7+: Core logic (extraction or guided conversation)
- Final: Preview vs Execute mode handling, state update

**Alternatives Considered**:
- Custom structure → Rejected: Would confuse users and complicate maintenance
- Simplified structure → Rejected: Missing validation gates (R7 violation)

### 2. Task Output Format

**Source**: `.mykit/templates/lite/tasks.md`, `.specify/templates/tasks-template.md`

**Decision**: Use simplified lite template format for `/mykit.tasks` (vs full speckit template)

**Rationale**:
- Lite template: Simple phases with `- [ ] T### Description` format
- Speckit template: Complex structure with user story groupings, parallel markers, checkpoints
- `/mykit.tasks` serves the Lite workflow, should generate simpler output
- Must include standard completion tasks section

**Output Format**:
```markdown
# Tasks: {FEATURE NAME}

**Branch**: `{branch}` | **Created**: {date} | **Spec**: [spec.md](./spec.md)

## Implementation

- [ ] T001 {task description}
- [ ] T002 {task description}
...

## Completion

- [ ] T0XX Run validation: `/mykit.validate`
- [ ] T0XX Create commit: `/mykit.commit create`
- [ ] T0XX Create pull request: `/mykit.pr create`
```

**Alternatives Considered**:
- Full speckit template → Rejected: Too complex for lite workflow
- No template, pure freeform → Rejected: Inconsistent output

### 3. Speckit vs Mykit Differentiation

**Source**: `/mykit.plan.md` Step 7

**Decision**: Detect speckit artifacts and redirect user to `/speckit.tasks`

**Rationale**: `/mykit.plan` already implements this check:
- If `research.md`, `data-model.md`, or `contracts/` exist → speckit workflow
- This prevents mixing lite and full workflows

**Implementation**: Reuse same detection logic in `/mykit.tasks`:
```
Check for speckit artifacts:
- specs/{branch}/research.md
- specs/{branch}/data-model.md
- specs/{branch}/contracts/

If any exist → Error: "Use /speckit.tasks for full workflow"
```

### 4. Artifact Analysis Strategy

**Source**: Spec clarifications, existing command patterns

**Decision**: Priority-based extraction from available artifacts

**Extraction Priority**:
1. If `plan.md` exists: Extract implementation phases as task groupings
2. If `spec.md` exists: Extract user stories (prioritize P1), functional requirements
3. If both exist: Combine plan phases with spec requirements
4. If neither exist: Trigger guided conversation

**Task Generation Heuristics**:
- Target 5-15 implementation tasks
- Each task ~30min-2hr of work
- Completion tasks always appended (3 tasks: validate, commit, PR)
- Total output: 8-18 tasks typical

### 5. Guided Conversation Questions

**Source**: Spec clarification session, FR-013

**Decision**: 3 structured questions using AskUserQuestion tool

**Questions**:
1. **What**: "What needs to be built or changed?"
2. **Scope**: "What components or files are affected?"
3. **Done**: "What defines 'done' for this work?"

**Implementation**:
```
Use AskUserQuestion tool:
- header: "Tasks: Q1/3"
- question: "What needs to be built or changed?"
- multiSelect: false
- options: (none - free text)
```

### 6. State Management

**Source**: `/mykit.specify.md`, `.mykit/state.json` pattern

**Decision**: Update state.json with task generation metadata

**State Fields to Update**:
```json
{
  "workflow_step": "tasks",
  "tasks_path": "specs/{branch}/tasks.md",
  "last_command": "/mykit.tasks",
  "last_command_time": "ISO timestamp"
}
```

## Summary of Decisions

| Topic | Decision |
|-------|----------|
| Command Pattern | Follow mykit.specify/plan step structure |
| Output Format | Simplified lite template |
| Speckit Detection | Check for research.md, data-model.md, contracts/ |
| Artifact Analysis | Priority: plan.md → spec.md → guided conversation |
| Task Count | 5-15 implementation + 3 completion tasks |
| Granularity | ~30min-2hr per task |
| Guided Questions | 3 questions: What, Scope, Done |
| State Update | workflow_step, tasks_path, last_command fields |

## Open Items Resolved

All research objectives completed. No NEEDS CLARIFICATION items remain.

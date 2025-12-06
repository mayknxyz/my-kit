# Research: /mykit.plan - Lightweight Plan

**Feature**: 010-lightweight-plan
**Date**: 2025-12-07

## Research Summary

This feature implements a lightweight planning command that follows established patterns in the codebase. No external research was required as all decisions are informed by existing code and clarifications.

---

## Decision Log

### R-001: Command Implementation Pattern

**Decision**: Use Claude Code slash command markdown pattern (same as `/mykit.specify`)

**Rationale**:
- Existing `/mykit.specify` command provides a proven template
- Step-by-step markdown instructions are executed by Claude Code
- No external runtime dependencies required
- Consistent with project's AI skill approach

**Alternatives Considered**:
- Shell script implementation: More complex, requires external execution
- Hybrid (markdown + shell helpers): Adds unnecessary indirection

### R-002: State File Structure

**Decision**: Use existing `.mykit/state.json` structure with workflow_step field

**Rationale**:
- Existing commands already update this file
- Compatible with `/mykit.status` and `/mykit.resume` commands
- Simple JSON structure, easy to read/write

**State Fields**:
```json
{
  "workflow_step": "planning",
  "plan_path": "specs/{branch}/plan.md",
  "last_command": "/mykit.plan",
  "last_command_time": "2025-12-07T12:00:00Z"
}
```

### R-003: Speckit Conflict Detection

**Decision**: Check for `research.md`, `data-model.md`, or `contracts/` directory in specs folder

**Rationale**:
- These files are only created by `/speckit.plan`, not `/mykit.plan`
- Presence indicates user started with full workflow
- Simple file existence check, no parsing required

**Implementation**:
```bash
# Check for speckit artifacts
ls specs/{branch}/research.md specs/{branch}/data-model.md specs/{branch}/contracts/ 2>/dev/null
```

### R-004: AskUserQuestion Tool Usage

**Decision**: Use Claude Code's `AskUserQuestion` tool for guided conversation

**Rationale**:
- Native Claude Code tool, already used by `/mykit.specify`
- Supports multiple choice and free-form answers
- Provides consistent UX across commands

**Usage Pattern**:
```
Use AskUserQuestion tool:
- header: "Plan: {topic}"
- question: "{question text}"
- multiSelect: false
- options: [
    {label: "A", description: "Option A description"},
    {label: "B", description: "Option B description"}
  ]
```

### R-005: Plan Content Generation

**Decision**: AI generates plan content inline based on spec analysis

**Rationale**:
- Per clarification, this is a "lightweight" approach without external templates
- AI can adapt plan structure to feature complexity
- Three mandatory sections provide consistent output

**Section Requirements**:
1. **Technical Context**: Technologies, dependencies, integration points (derived from spec entities and requirements)
2. **Design Decisions**: Key choices with rationale (derived from guided conversation answers)
3. **Implementation Phases**: Ordered tasks (derived from functional requirements)

---

## Best Practices Applied

### Claude Code Slash Commands

- Clear step-by-step instructions in markdown
- Use of conditional logic ("If X, then Y")
- Error messages with actionable next steps
- Preview/execute pattern with `create` action

### My Kit Conventions

- Branch naming: `{issue-number}-{slug}`
- Spec path: `specs/{branch}/spec.md`
- Plan path: `specs/{branch}/plan.md`
- State file: `.mykit/state.json`

### Simplicity Principle

- No external template files
- No shell script dependencies
- Single command file contains all logic
- Maximum 5 questions to avoid decision fatigue

---

## Open Questions Resolved

| Question | Resolution | Source |
|----------|------------|--------|
| Template source? | AI generates inline | Clarification session |
| Relationship to speckit.plan? | Mutually exclusive | Clarification session |
| How many questions? | 0-5 based on spec | Spec FR-004 |
| State update format? | Match existing pattern | Existing mykit.specify |

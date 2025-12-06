# Quickstart: /mykit.plan

## Usage

```bash
# Preview mode (no files created)
/mykit.plan

# Execute mode (creates plan.md)
/mykit.plan create

# Force overwrite existing plan
/mykit.plan create --force
```

## Prerequisites

1. Be on a feature branch (e.g., `010-feature-name`)
2. Have a spec file at `specs/{branch}/spec.md`
3. Not using `/speckit.plan` workflow for this feature

## Workflow

```
/mykit.specify create  →  /mykit.plan create  →  /mykit.tasks generate
```

## What It Does

1. **Reads** your spec file
2. **Asks** 0-5 technical questions (if needed)
3. **Generates** a plan with:
   - Technical Context
   - Design Decisions
   - Implementation Phases
4. **Updates** workflow state

## Output

Creates `specs/{branch}/plan.md`:

```markdown
# Implementation Plan: {feature}

**Branch**: `{branch}` | **Created**: {date} | **Spec**: [spec.md](./spec.md)

## Technical Context
- Technologies, dependencies, integrations

## Design Decisions
- Key choices with rationale

## Implementation Phases
- Ordered steps to build the feature
```

## Common Errors

| Error | Solution |
|-------|----------|
| "Not in a git repository" | Run `git init` or navigate to repo |
| "No feature branch detected" | Run `/mykit.backlog select` |
| "No specification found" | Run `/mykit.specify create` |
| "This feature uses /speckit.plan" | Continue with `/speckit.tasks` instead |

## Next Step

After creating plan:
```
/mykit.tasks generate
```

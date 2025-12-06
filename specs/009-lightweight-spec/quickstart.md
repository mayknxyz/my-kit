# Quickstart: Lightweight Spec Command

**Branch**: `009-lightweight-spec` | **Date**: 2025-12-07

## Overview

The `/mykit.specify` command creates lightweight feature specifications through an AI-guided workflow. It's part of the "Lite workflow" in My Kit.

## Prerequisites

- My Kit initialized in repository (`/mykit.init`)
- GitHub CLI (`gh`) installed and authenticated
- Issue selected via `/mykit.backlog` (unless using `--no-issue`)

## Basic Usage

### Preview Mode (Default)

```
/mykit.specify
```

Shows what the spec would contain without creating files. Useful for reviewing before committing.

### Create Spec

```
/mykit.specify create
```

Creates the spec file at `specs/{branch}/spec.md`. If a GitHub issue is linked and has substantial content (50+ chars), extracts information automatically. Otherwise, guides you through 3 questions.

## Workflow Examples

### From a Well-Documented Issue

1. Select issue: `/mykit.backlog select`
2. Preview spec: `/mykit.specify`
3. Create spec: `/mykit.specify create`
4. Continue to planning: `/mykit.plan create`

### From an Empty Issue

1. Select issue: `/mykit.backlog select`
2. Create spec: `/mykit.specify create`
3. Answer guided questions:
   - "What is this feature/change about?"
   - "What problem does it solve?"
   - "What should be true when done?"
4. Confirm spec creation

### Ad-hoc Work (No Issue)

```
/mykit.specify create --no-issue
```

Creates spec without requiring a linked GitHub issue. Useful for exploratory work.

## Flags

| Flag | Description |
|------|-------------|
| `create` | Execute spec creation (required for file write) |
| `--no-issue` | Skip issue requirement |
| `--force` | Overwrite existing spec without prompt |

## Output

Creates: `specs/{branch-name}/spec.md`

Updates: `.mykit/state.json` with:
- `current_feature.spec_path`
- `workflow_step: "specification"`

## Next Steps

After creating a spec:

| Workflow | Next Command |
|----------|--------------|
| Lite (My Kit) | `/mykit.plan create` |
| Full (Spec Kit) | `/speckit.clarify` or `/speckit.plan` |
| Quick | Skip to implementation |

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "No issue selected" | Run `/mykit.backlog select` first, or use `--no-issue` |
| "Spec file already exists" | Choose Overwrite, Merge, or Cancel when prompted |
| "GitHub API unavailable" | Command proceeds with guided conversation (non-blocking) |

## Related Commands

- `/mykit.start` - Select workflow type
- `/mykit.backlog` - Select issue and create branch
- `/mykit.plan` - Create implementation plan (next step)
- `/mykit.status` - View current workflow state

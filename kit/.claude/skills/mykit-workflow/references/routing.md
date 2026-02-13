# Shared Routing Patterns

Common patterns used across all mykit-workflow steps.

## Artifact Handling

Steps that produce artifacts (specify, plan, tasks) follow this pattern:

### If Artifact Exists

When the target artifact already exists, prompt via `AskUserQuestion`:

```
header: "{Step Name}"
question: "A {artifact} already exists. What would you like to do?"
options:
  1. Overwrite — Replace the existing {artifact}
  2. View — Display the current {artifact}
  3. Cancel — Keep the existing {artifact}
```

- **Overwrite**: Continue with creation (will replace the file)
- **View**: Display file contents and stop
- **Cancel**: Display "Operation cancelled." and stop

### If Artifact Does Not Exist

Proceed directly to creation.

### View Operation

1. Determine artifact path: `specs/{current-branch}/{artifact}.md`
2. If file exists, display its contents
3. If file does not exist: "No {artifact} found at `{path}`. Run `/mykit.{step}` to create one."

## Branch and Path Conventions

- Feature branch pattern: `{issue-number}-{slug}` (e.g., `042-feature-name`)
- Spec directory: `specs/{branch}/`
- Artifacts: `spec.md`, `plan.md`, `tasks.md` within spec directory

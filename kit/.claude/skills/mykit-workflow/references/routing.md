# Shared Routing Patterns

Common patterns used across all mykit-workflow steps.

## CRUD Routing

Steps that support CRUD operations (specify, plan, tasks) follow this pattern:

### Flag Parsing

Parse user input for CRUD flags:
- `-c` / `--create` → Create operation
- `-r` / `--read` → Read operation
- `-u` / `--update` → Update operation (same as create with `--force`)
- `-d` / `--delete` → Delete operation

Additional flags:
- `--force` → Skip confirmation prompts
- `--no-issue` → Skip issue requirement (specify only)

### Interactive Menu

If no CRUD flag is found, present an interactive menu using `AskUserQuestion`:

```
header: "{Step Name}"
question: "What would you like to do?"
options:
  1. Create — Generate a new {artifact}
  2. View — Display the current {artifact}
  3. Update — Regenerate the {artifact} (overwrites existing)
  4. Delete — Remove {artifact} files
```

Route to the selected operation.

### Read Operation

1. Determine artifact path: `specs/{current-branch}/{artifact}.md`
2. If file exists, display its contents
3. If file does not exist: "No {artifact} found at `{path}`. Run `/mykit.{step} -c` to create one."

### Delete Operation

1. Determine artifact path: `specs/{current-branch}/{artifact}.md`
2. If file does not exist: "No {artifact} found to delete."
3. If file exists, confirm deletion (unless `--force`):
   - Use `AskUserQuestion` with Confirm Delete header
   - If cancelled, display "Operation cancelled." and stop
4. Delete the file
5. Display: "{Artifact} deleted: `{path}`"

### Update Operation

Same as Create, but with `--force` flag implicitly set.

## State Management

### Reading State

Read `.mykit/state.json` for session context:

```bash
# Read with jq
jq -r '.session.type // empty' .mykit/state.json 2>/dev/null
```

Key fields:
- `session.type` — Workflow mode (major/minor/patch)
- `workflow_step` — Current step name
- `current_feature` — Feature branch and issue info
- `last_command` — Last executed command
- `last_command_time` — Timestamp of last command

### Writing State

After successful step execution, update state:

```json
{
  "workflow_step": "{step}",
  "last_command": "/mykit.{step}",
  "last_command_time": "{ISO 8601 timestamp}"
}
```

Merge updates into existing state — do not overwrite the entire file.

## Mode Validation

For major-only steps (clarify, analyze, checklist):

```
If session.type is "minor":
  Error: `/mykit.{step}` requires Major workflow mode.
  Suggest: /mykit.plan -c (for clarify) or /mykit.implement (for analyze/checklist)

If session.type is "patch":
  Error: `/mykit.{step}` requires Major workflow mode.
  Suggest: /mykit.implement
```

## Branch and Path Conventions

- Feature branch pattern: `{issue-number}-{slug}` (e.g., `042-feature-name`)
- Spec directory: `specs/{branch}/`
- Artifacts: `spec.md`, `plan.md`, `tasks.md` within spec directory
- State file: `.mykit/state.json` (per-project root)
- Config file: `.mykit/config.json` (per-project root)

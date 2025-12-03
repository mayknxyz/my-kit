# My Kit Commands

Quick reference for all `/mykit.*` commands.

## Command Pattern

```
/mykit.{command} [action] [flags]
```

## Read-Only Commands

These execute immediately without an action.

| Command | Description |
|---------|-------------|
| `/mykit.status` | Show current workflow state and progress |
| `/mykit.help` | Show command documentation |

## State-Changing Commands

These require an action to execute. Without an action, they show a preview.

### Workflow

| Command | Actions | Flags | Description |
|---------|---------|-------|-------------|
| `/mykit.init` | `create` | | Initialize My Kit in repository |
| `/mykit.setup` | `run` | | Run first-time onboarding wizard |
| `/mykit.start` | `run` | | Begin workflow session |
| `/mykit.resume` | `run` | | Resume interrupted session |
| `/mykit.reset` | `run` | `--yes` | Clear state, start fresh |

### Issue & Branch

| Command | Actions | Flags | Description |
|---------|---------|-------|-------------|
| `/mykit.backlog` | `select` | `--label`, `--assignee`, `--no-issue` | Select issue and create branch |

### Lite Workflow (AI-Guided)

| Command | Actions | Flags | Description |
|---------|---------|-------|-------------|
| `/mykit.specify` | `create` | `--no-issue` | Create lightweight spec |
| `/mykit.plan` | `create` | | Create implementation plan |
| `/mykit.tasks` | `generate` | | Generate task breakdown |
| `/mykit.implement` | `run` | | Execute tasks one by one |

### Quality & Commit

| Command | Actions | Flags | Description |
|---------|---------|-------|-------------|
| `/mykit.validate` | `run`, `fix` | `--force`, `--json` | Run quality checks / auto-fix |
| `/mykit.commit` | `create` | `--force`, `--yes` | Create commit with CHANGELOG |
| `/mykit.pr` | `create`, `update` | `--force`, `--yes` | Create or update pull request |
| `/mykit.release` | `publish` | `--yes` | Create release with versioning |

### Management

| Command | Actions | Flags | Description |
|---------|---------|-------|-------------|
| `/mykit.upgrade` | `run` | | Upgrade My Kit to latest version |

## Flag Reference

| Flag | Short | Description |
|------|-------|-------------|
| `--force` | | Bypass validation gates (with warning) |
| `--yes` | `-y` | Skip confirmation prompts |
| `--json` | | Output in JSON format |
| `--no-issue` | | Work without linking to an issue |
| `--label` | | Filter issues by label |
| `--assignee` | | Filter issues by assignee |

## Examples

```bash
# Initialize My Kit
/mykit.init create

# Start a workflow session
/mykit.start run

# Select issue #42 and create branch
/mykit.backlog select

# Preview what will be committed
/mykit.commit

# Create the commit
/mykit.commit create

# Run validation and auto-fix issues
/mykit.validate fix

# Create a pull request
/mykit.pr create

# Publish a release
/mykit.release publish
```

## Workflow Cheatsheet

### Full Workflow (with Spec Kit)

```
/mykit.start run → /mykit.backlog select → /speckit.specify → /speckit.plan →
/speckit.tasks → /speckit.implement → /mykit.validate run → /mykit.commit create → /mykit.pr create
```

### Lite Workflow (My Kit only)

```
/mykit.start run → /mykit.backlog select → /mykit.specify create → /mykit.plan create →
/mykit.tasks generate → /mykit.implement run → /mykit.validate run → /mykit.commit create → /mykit.pr create
```

### Quick Fix

```
/mykit.start run → /mykit.backlog select → (implement) → /mykit.validate run →
/mykit.commit create → /mykit.pr create
```

# /mykit.help [topic]

Show My Kit command documentation and workflow guidance.

## User Input

```text
$ARGUMENTS
```

## Behavior

Based on the input, display one of three help modes:

### Mode 1: Command Overview (when topic is empty)

If `$ARGUMENTS` is empty, display the categorized command list:

---

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

---

**Tip**: Run `/mykit.help <command>` for detailed help on a specific command, or `/mykit.help workflow` for workflow cheatsheets.

---

### Mode 2: Specific Command Help (when topic is a command name)

If `$ARGUMENTS` matches a known command name (e.g., "commit", "start", "backlog"):

1. Read the command file at `.claude/commands/mykit.{topic}.md`
2. Check if the file contains `**Stub**` to determine implementation status
3. Display detailed help in this format:

---

# /mykit.{topic}

[First paragraph from command file as description]

**Status**: [If file contains `**Stub**`: "⚠️ Stub - Implementation pending" | Otherwise: "✓ Implemented"]

## Usage

```
/mykit.{topic} [action] [flags]
```

## Actions

[Extract from docs/COMMANDS.md for this command]

## Flags

[Extract applicable flags from docs/COMMANDS.md for this command]

## Examples

[Provide 2-3 usage examples based on the command type]

---

### Mode 3: Workflow Cheatsheets (when topic is "workflow")

If `$ARGUMENTS` equals "workflow", display workflow guidance:

---

# My Kit Workflows

Choose a workflow based on your task complexity.

## Full Workflow (with Spec Kit)

For complex features requiring detailed specifications:

```
/mykit.start run → /mykit.backlog select → /speckit.specify →
/speckit.plan → /speckit.tasks → /speckit.implement →
/mykit.validate run → /mykit.commit create → /mykit.pr create
```

## Lite Workflow (My Kit only)

For simpler features using AI-guided development:

```
/mykit.start run → /mykit.backlog select → /mykit.specify create →
/mykit.plan create → /mykit.tasks generate → /mykit.implement run →
/mykit.validate run → /mykit.commit create → /mykit.pr create
```

## Quick Fix

For bug fixes and small changes:

```
/mykit.start run → /mykit.backlog select → (implement changes) →
/mykit.validate run → /mykit.commit create → /mykit.pr create
```

## Choosing a Workflow

| Scenario | Recommended Workflow |
|----------|---------------------|
| New feature with complex requirements | Full Workflow |
| Feature with clear requirements | Lite Workflow |
| Bug fix or small enhancement | Quick Fix |
| Refactoring existing code | Quick Fix or Lite |
| Exploratory/prototype work | Quick Fix |

---

### Mode 4: Unknown Command Error

If `$ARGUMENTS` doesn't match any known command name or "workflow":

---

**Unknown topic**: "{$ARGUMENTS}"

Available commands:
- `/mykit.backlog` - Select issue and create branch
- `/mykit.commit` - Create commit with CHANGELOG
- `/mykit.help` - Show command documentation
- `/mykit.implement` - Execute tasks one by one
- `/mykit.init` - Initialize My Kit in repository
- `/mykit.plan` - Create implementation plan
- `/mykit.pr` - Create or update pull request
- `/mykit.release` - Create release with versioning
- `/mykit.reset` - Clear state, start fresh
- `/mykit.resume` - Resume interrupted session
- `/mykit.setup` - Run first-time onboarding wizard
- `/mykit.specify` - Create lightweight spec
- `/mykit.start` - Begin workflow session
- `/mykit.status` - Show current workflow state
- `/mykit.tasks` - Generate task breakdown
- `/mykit.upgrade` - Upgrade My Kit to latest version
- `/mykit.validate` - Run quality checks

Special topics:
- `workflow` - Show workflow cheatsheets

Run `/mykit.help` for the full command reference.

---

## Valid Command Names

For reference, these are valid command names to check against:
- `backlog`
- `commit`
- `help`
- `implement`
- `init`
- `plan`
- `pr`
- `release`
- `reset`
- `resume`
- `setup`
- `specify`
- `start`
- `status`
- `tasks`
- `upgrade`
- `validate`

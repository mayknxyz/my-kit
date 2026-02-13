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

## Invocation Methods

**Slash commands** (explicit):
```
/mykit.{command}
```

**Natural language** (skill auto-trigger):
```
"Write the spec for this feature"  → mykit-workflow activates → specify step
"Let's plan the implementation"    → mykit-workflow activates → plan step
"Commit these changes"             → mykit-ship activates → commit step
"Run an audit"                     → mykit-ops activates → audit step
```

Both methods produce the same result — slash commands invoke thin stubs that delegate to skills, while natural language triggers the skills directly.

## Read-Only Commands

These execute immediately without an action.

| Command | Description |
|---------|-------------|
| `/mykit.status` | Show current workflow state and progress |
| `/mykit.help` | Show command documentation |

## Setup Commands

| Command | Description |
|---------|-------------|
| `/mykit.init` | Initialize My Kit in repository |
| `/mykit.setup` | Run first-time onboarding wizard |
| `/mykit.sync` | Install/upgrade My Kit v2 |

## Development Workflow

| Command | Description |
|---------|-------------|
| `/mykit.specify` | Create feature specification |
| `/mykit.plan` | Create implementation plan |
| `/mykit.tasks` | Generate task breakdown |
| `/mykit.implement` | Execute tasks one by one |

## Commit & Release

| Command | Description |
|---------|-------------|
| `/mykit.commit` | Create commit with CHANGELOG |
| `/mykit.pr` | Create or update pull request |
| `/mykit.release` | Create release with versioning |

## Utilities

| Command | Description |
|---------|-------------|
| `/mykit.audit` | Run comprehensive audit (quality, security, perf, a11y, deps) |
| `/mykit.constitution` | Create or update project constitution |
| `/mykit.taskstoissues` | Convert tasks to GitHub issues |
| `/mykit.log` | Export session summary to ~/my-log |
| `/mykit.skill.review` | Review activated skills and propose improvements |

---

**Tip**: Run `/mykit.help <command>` for detailed help on a specific command, or `/mykit.help workflow` for workflow cheatsheets. You can also just describe what you want to do in natural language — the skills will auto-activate.

---

### Mode 2: Specific Command Help (when topic is a command name)

If `$ARGUMENTS` matches a known command name (e.g., "commit", "specify"):

1. Read the command file at `.claude/commands/mykit.{topic}.md`
2. Check if the file contains `**Stub**` to determine implementation status
3. Display detailed help in this format:

---

# /mykit.{topic}

[First paragraph from command file as description]

**Status**: [If file contains `**Stub**`: "Stub - Implementation pending" | Otherwise: "Implemented"]

## Usage

```
/mykit.{topic}
```

## Examples

[Provide 2-3 usage examples based on the command type]

---

### Mode 3: Workflow Cheatsheets (when topic is "workflow")

If `$ARGUMENTS` equals "workflow", display workflow guidance:

---

# My Kit Workflow

Development workflow using 4 steps:

```
/mykit.specify → /mykit.plan → /mykit.tasks → /mykit.implement →
/mykit.audit → /mykit.commit → /mykit.pr
```

## Minimal Flow

For bug fixes and small changes — workflow steps are optional:

```
/mykit.specify → /mykit.implement → /mykit.commit → /mykit.pr
```

## Choosing an Approach

| Scenario | Recommended Flow |
|----------|-----------------|
| New feature with clear requirements | Full workflow (specify → plan → tasks → implement) |
| Bug fix or small enhancement | Minimal (specify → implement) |
| Refactoring existing code | Minimal (specify → implement) |
| Performance improvements | Minimal (specify → implement) |

---

### Mode 4: Unknown Command Error

If `$ARGUMENTS` doesn't match any known command name or "workflow":

---

**Unknown topic**: "{$ARGUMENTS}"

Available commands:
- `/mykit.audit` - Run comprehensive audit
- `/mykit.commit` - Create commit with CHANGELOG
- `/mykit.constitution` - Create or update project constitution
- `/mykit.help` - Show command documentation
- `/mykit.implement` - Execute tasks one by one
- `/mykit.init` - Initialize My Kit in repository
- `/mykit.log` - Export session summary to ~/my-log
- `/mykit.plan` - Create implementation plan
- `/mykit.pr` - Create or update pull request
- `/mykit.release` - Create release with versioning
- `/mykit.setup` - Run first-time onboarding wizard
- `/mykit.specify` - Create feature specification
- `/mykit.status` - Show current workflow state
- `/mykit.sync` - Install/upgrade My Kit v2
- `/mykit.skill.review` - Review activated skills and propose improvements
- `/mykit.tasks` - Generate task breakdown
- `/mykit.taskstoissues` - Convert tasks to GitHub issues
Special topics:
- `workflow` - Show workflow cheatsheets

Run `/mykit.help` for the full command reference.

---

## Valid Command Names

For reference, these are valid command names to check against:
- `audit`
- `commit`
- `constitution`
- `help`
- `implement`
- `init`
- `log`
- `plan`
- `pr`
- `release`
- `setup`
- `specify`
- `status`
- `sync`
- `skill.review`
- `tasks`
- `taskstoissues`

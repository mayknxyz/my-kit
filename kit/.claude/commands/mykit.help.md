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
/mykit.{command} [action] [flags]
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

### Development Workflow

| Command | Actions | Flags | Description |
|---------|---------|-------|-------------|
| `/mykit.specify` | `create` | `--no-issue`, `--force` | Create feature specification |
| `/mykit.plan` | `create` | `--force` | Create implementation plan |
| `/mykit.tasks` | `generate` | `--force` | Generate task breakdown |
| `/mykit.implement` | `run`, `complete`, `skip` | `--force` | Execute tasks one by one |

### Major Mode Commands

These commands are only available in Major workflow mode.

| Command | Actions | Flags | Description |
|---------|---------|-------|-------------|
| `/mykit.clarify` | | | Identify and resolve spec ambiguities |
| `/mykit.analyze` | | | Cross-artifact consistency analysis |
| `/mykit.checklist` | | | Generate requirements quality checklist |

### Mode-Independent Commands

| Command | Actions | Flags | Description |
|---------|---------|-------|-------------|
| `/mykit.constitution` | | | Create or update project constitution |
| `/mykit.taskstoissues` | | | Convert tasks to GitHub issues |

### Checks

| Command | Actions | Flags | Description |
|---------|---------|-------|-------------|
| `/mykit.audit` | `run` | `--only` | Run comprehensive audit (quality, security, perf, a11y, deps) |

### Commit & Release

| Command | Actions | Flags | Description |
|---------|---------|-------|-------------|
| `/mykit.commit` | `create` | `--force`, `--yes` | Create commit with CHANGELOG |
| `/mykit.pr` | `create`, `update` | `--force`, `--yes` | Create or update pull request |
| `/mykit.release` | `publish` | `--yes` | Create release with versioning |

### Management

| Command | Actions | Flags | Description |
|---------|---------|-------|-------------|
| `/mykit.upgrade` | `run` | | Upgrade My Kit to latest version |
| `/mykit.sync` | `run` | | Sync spec-kit upstream (my-kit repo only) |
| `/mykit.skill.review` | | | Review activated skills and propose improvements |

## Flag Reference

| Flag | Short | Description |
|------|-------|-------------|
| `--force` | | Skip confirmation prompts / overwrite existing files |
| `--yes` | `-y` | Skip confirmation prompts |
| `--json` | | Output in JSON format |
| `--no-issue` | | Work without linking to an issue |

---

**Tip**: Run `/mykit.help <command>` for detailed help on a specific command, or `/mykit.help workflow` for workflow cheatsheets. You can also just describe what you want to do in natural language — the skills will auto-activate.

---

### Mode 2: Specific Command Help (when topic is a command name)

If `$ARGUMENTS` matches a known command name (e.g., "commit", "start", "specify"):

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

## Major Workflow

For breaking changes or new projects requiring detailed specifications and quality gates:

```
/mykit.start → /mykit.specify -c → /mykit.clarify →
/mykit.plan -c → /mykit.tasks -c → /mykit.analyze →
/mykit.checklist → /mykit.implement → /mykit.audit →
/mykit.commit → /mykit.pr -c
```

## Minor Workflow

For new backward-compatible capabilities using AI-guided development:

```
/mykit.start → /mykit.specify -c → /mykit.plan -c →
/mykit.tasks -c → /mykit.implement → /mykit.audit →
/mykit.commit → /mykit.pr -c
```

## Patch Workflow

For bug fixes, refactoring, and small changes — all workflow steps are optional:

**Minimal** (skip straight to implementation):
```
/mykit.start → /mykit.implement → /mykit.audit →
/mykit.commit → /mykit.pr -c
```

**Full** (same steps as Minor, all optional):
```
/mykit.start → /mykit.specify -c → /mykit.plan -c →
/mykit.tasks -c → /mykit.implement → /mykit.audit →
/mykit.commit → /mykit.pr -c
```

## Choosing a Workflow

| Scenario | Recommended Workflow |
|----------|---------------------|
| Breaking change or new project | Major Workflow |
| New backward-compatible feature | Minor Workflow |
| Bug fix or small enhancement | Patch |
| Refactoring existing code | Patch |
| Performance improvements | Patch |

---

### Mode 4: Unknown Command Error

If `$ARGUMENTS` doesn't match any known command name or "workflow":

---

**Unknown topic**: "{$ARGUMENTS}"

Available commands:
- `/mykit.analyze` - Cross-artifact consistency analysis (Major mode)
- `/mykit.checklist` - Generate requirements quality checklist (Major mode)
- `/mykit.clarify` - Identify and resolve spec ambiguities (Major mode)
- `/mykit.commit` - Create commit with CHANGELOG
- `/mykit.constitution` - Create or update project constitution
- `/mykit.help` - Show command documentation
- `/mykit.implement` - Execute tasks one by one
- `/mykit.init` - Initialize My Kit in repository
- `/mykit.plan` - Create implementation plan
- `/mykit.pr` - Create or update pull request
- `/mykit.release` - Create release with versioning
- `/mykit.reset` - Clear state, start fresh
- `/mykit.resume` - Resume interrupted session
- `/mykit.setup` - Run first-time onboarding wizard
- `/mykit.specify` - Create feature specification
- `/mykit.start` - Begin workflow session
- `/mykit.status` - Show current workflow state
- `/mykit.skill.review` - Review activated skills and propose improvements
- `/mykit.sync` - Sync spec-kit upstream (my-kit repo only)
- `/mykit.tasks` - Generate task breakdown
- `/mykit.taskstoissues` - Convert tasks to GitHub issues
- `/mykit.upgrade` - Upgrade My Kit to latest version
Special topics:
- `workflow` - Show workflow cheatsheets

Run `/mykit.help` for the full command reference.

---

## Valid Command Names

For reference, these are valid command names to check against:
- `analyze`
- `checklist`
- `clarify`
- `commit`
- `constitution`
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
- `skill.review`
- `sync`
- `tasks`
- `taskstoissues`
- `upgrade`

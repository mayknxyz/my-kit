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
| `/mykit.status` | Display workflow dashboard with feature context, phase, file status, and next step |
| `/mykit.help` | Show command documentation |

### /mykit.status

Display a comprehensive status dashboard showing:

- **Feature Context**: Current branch and linked GitHub issue
- **Workflow Phase**: Specification, Planning, or Implementation progress
- **File Status**: Uncommitted changes with staged/unstaged distinction
- **Next Step**: Suggested command based on current state

Example output:

```
# My Kit Status

## Feature Context
**Branch**: 006-status-dashboard
**Issue**: #6 - feat: /mykit.status - enhanced dashboard (OPEN)

## Workflow Phase
**Current**: Implementation
**Progress**: spec.md ✓ | plan.md ✓ | tasks.md ✓

## File Status
✓ modified  .claude/commands/mykit.status.md
  modified  CLAUDE.md

(2 file(s) changed)

## Next Step
`/mykit.commit create` - Commit your implementation changes
```

## State-Changing Commands

These require an action to execute. Without an action, they show a preview.

### /mykit.specify

Create a lightweight feature specification from a GitHub issue or via guided conversation.

**Usage**:
```
/mykit.specify [create] [--no-issue] [--force]
```

**Behavior**:
- **No action**: Preview mode - shows proposed spec without creating files
- **create**: Execute mode - creates spec file at `specs/{branch}/spec.md`

**Content Sources**:
1. **Issue extraction**: If the linked GitHub issue body has 50+ characters, extracts Summary, Problem, and Acceptance Criteria sections automatically
2. **Guided conversation**: Falls back to asking 3 questions:
   - "What is this feature/change about?"
   - "What problem does it solve?"
   - "What should be true when done?"

**Flags**:
- `--no-issue`: Skip issue requirement for ad-hoc work (creates `specs/adhoc-{slug}/spec.md`)
- `--force`: Overwrite existing spec without confirmation

**Examples**:
```bash
# Preview what spec would be created
/mykit.specify

# Create spec from GitHub issue
/mykit.specify create

# Create ad-hoc spec without issue
/mykit.specify create --no-issue

# Force overwrite existing spec
/mykit.specify create --force
```

### /mykit.plan

Create a lightweight implementation plan from a feature specification via guided conversation.

**Usage**:
```
/mykit.plan [create] [--force]
```

**Behavior**:
- **No action**: Preview mode - shows proposed plan without creating files
- **create**: Execute mode - creates plan file at `specs/{branch}/plan.md`

**Prerequisites**:
- Must be on a feature branch (e.g., `042-feature-name`)
- Must have a spec file at `specs/{branch}/spec.md`
- Must NOT have `/speckit.plan` artifacts (mutually exclusive workflows)

**Plan Sections**:
1. **Technical Context**: Technologies, dependencies, integration points
2. **Design Decisions**: Key architectural choices with rationale
3. **Implementation Phases**: Ordered steps to implement the feature

**Guided Conversation**:
- Analyzes spec for technical ambiguities
- Asks 0-5 clarifying questions about tech stack, integrations, etc.
- Records answers to inform plan generation

**Flags**:
- `--force`: Overwrite existing plan without confirmation

**Examples**:
```bash
# Preview what plan would be created
/mykit.plan

# Create plan from spec
/mykit.plan create

# Force overwrite existing plan
/mykit.plan create --force
```

### Workflow

| Command | Actions | Flags | Description |
|---------|---------|-------|-------------|
| `/mykit.init` | `create` | | Initialize My Kit in repository |
| `/mykit.setup` | `run` | | Run first-time onboarding wizard |
| `/mykit.start` | `run` | | Begin workflow session |
| `/mykit.resume` | `run` | | Resume interrupted session |
| `/mykit.reset` | `run` | `--keep-branch`, `--keep-specs`, `--force` | Clear state, start fresh |

### Issue & Branch

| Command | Actions | Flags | Description |
|---------|---------|-------|-------------|
| `/mykit.backlog` | `select` | `--label`, `--assignee`, `--no-issue` | Select issue and create branch |

### Lite Workflow (AI-Guided)

| Command | Actions | Flags | Description |
|---------|---------|-------|-------------|
| `/mykit.specify` | `create` | `--no-issue`, `--force` | Create lightweight spec from issue or guided conversation |
| `/mykit.plan` | `create` | `--force` | Create implementation plan from spec via guided conversation |
| `/mykit.tasks` | `generate` | | Generate task breakdown |
| `/mykit.implement` | `run` | | Execute tasks one by one |

### /mykit.validate

Run code quality validation checks on shell scripts and markdown files.

**Usage**:
```
/mykit.validate [run]
```

**Behavior**:
- **No action**: Preview mode - shows files that will be validated and tool availability
- **run**: Execute mode - runs shellcheck and markdownlint, updates state.json

**Validation Tools**:
- **shellcheck**: Lints shell scripts in `.mykit/scripts/*.sh`
- **markdownlint**: Lints markdown files in `.claude/commands/`, `docs/`, `specs/`, and root documentation

**Features**:
- Graceful degradation - warns if tools missing, doesn't fail
- Results stored in `.mykit/state.json` for `/mykit.pr` to check
- Clear error messages with file names and line numbers
- Exit codes: 0 if passed, 1 if failed

**Examples**:
```bash
# Preview what will be validated
/mykit.validate

# Run validation checks
/mykit.validate run
```

### /mykit.commit

Create commits with conventional format and automatically update CHANGELOG.md.

**Usage**:
```
/mykit.commit [create] [--force]
```

**Behavior**:
- **No action**: Preview mode - shows changed files, diff stats, and suggested commit type
- **create**: Execute mode - prompts for commit details, updates CHANGELOG, creates commit

**Commit Format**:
Follows [Conventional Commits](https://www.conventionalcommits.org/):
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `perf`: Performance improvements
- `style`: Code style/formatting

**Interactive Prompts**:
1. Commit type selection (with suggestions based on changed files)
2. Commit description (concise one-liner)
3. Optional scope (e.g., auth, api, ui)

**CHANGELOG Updates**:
Automatically appends entry to `[Unreleased]` section in correct category:
- `feat` → Added
- `fix` → Fixed
- `docs` → Documentation
- `refactor` → Changed
- etc.

**Flags**:
- `--force`: Skip validation checks (not recommended)

**Examples**:
```bash
# Preview changes
/mykit.commit

# Create a commit interactively
/mykit.commit create

# Force commit without validation
/mykit.commit create --force
```

### /mykit.pr

Create pull requests with comprehensive validation gates and rich descriptions.

**Usage**:
```
/mykit.pr [create] [--force]
```

**Behavior**:
- **No action**: Preview mode - shows PR description, validation gate status
- **create**: Execute mode - validates gates, creates PR on GitHub

**Validation Gates**:
Three gates must pass before PR creation (unless `--force` used):

1. **Tasks Complete**: All tasks in `tasks.md` must be marked `[x]` or `[~]` (no `[ ]` or `[>]`)
2. **Validation Passed**: `/mykit.validate run` must have been run and passed
3. **Commits Exist**: At least one commit must exist on the branch

**PR Description Generation**:
Automatically generates rich PR description from:
- **Summary**: Extracted from `spec.md` (if exists) or generated from commits
- **Changes**: List of commits on the branch
- **Test Plan**: Extracted from `plan.md` (if exists)
- **Issue Link**: Automatically adds `Closes #{issue_number}`

**Prerequisites**:
- Must be on a feature branch (format: `{number}-{slug}`)
- GitHub CLI (`gh`) must be installed and authenticated
- Branch must be pushed to remote (command will push if needed)

**Flags**:
- `--force`: Bypass all validation gates (with warnings)

**Examples**:
```bash
# Preview PR and check validation status
/mykit.pr

# Create PR (gates must pass)
/mykit.pr create

# Force create PR bypassing gates
/mykit.pr create --force
```

**Error Messages**:
If validation gates fail, command provides actionable remediation:
- Tasks incomplete → `/mykit.implement run`
- Validation not run → `/mykit.validate run`
- No commits → `/mykit.commit create`

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

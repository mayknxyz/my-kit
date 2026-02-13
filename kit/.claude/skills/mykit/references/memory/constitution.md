<!--
Sync Impact Report
==================
Version change: 1.0.0 (initial)
Modified principles: N/A (first version)
Added sections:
  - Core Principles (5 principles)
  - Command Conventions
  - Governance
Removed sections: N/A
Templates requiring updates:
  - $HOME/.claude/skills/mykit/references/templates/major/plan-template.md: ✅ Constitution Check section exists
  - $HOME/.claude/skills/mykit/references/templates/major/spec-template.md: ✅ Aligned with spec-first approach
  - $HOME/.claude/skills/mykit/references/templates/major/tasks-template.md: ✅ Aligned with user story organization
Follow-up TODOs: None
-->

# My Kit Constitution

## Core Principles

### I. Spec-First Development

All features and significant changes MUST be specified before implementation begins.

**Rules**:
- Features require a specification document (`spec.md`) that defines WHAT and WHY
- Implementation plans (`plan.md`) document HOW, created after specification approval
- Tasks (`tasks.md`) break down work into actionable, trackable items
- Patch mode for trivial changes MAY bypass specification, but MUST still link to an issue

**Rationale**: Specifications prevent scope creep, ensure shared understanding, and create
documentation that outlives the implementation session.

### II. Issue-Linked Traceability

All work MUST be linked to a GitHub Issue. No orphan commits, branches, or PRs.

**Rules**:
- Every branch MUST include the issue number prefix: `{issue-number}-{slug}`
- Every spec directory MUST match: `specs/{issue-number}-{slug}/`
- Every PR MUST reference its issue with `Closes #{issue-number}`
- Patch mode also requires issues - every change is documented, no matter how small
- Exception: The `--no-issue` flag MAY be used for exploratory work, but MUST NOT be merged

**Rationale**: GitHub Issues provide the documentation trail from idea to deployment.
Traceability enables project history reconstruction and accountability.

### III. Explicit Execution

Commands MUST preview by default. Execution requires explicit action flags.

**Rules**:
- All state-changing commands show preview/dry-run without action flags
- Execution requires explicit flags: `--run`, `create`, `select`, etc.
- Read-only commands (`/mykit.status`, `/mykit.help`) execute immediately
- Confirmations MUST be shown for irreversible operations unless `--yes` is passed

**Rationale**: Prevents accidental execution, allows reviewing changes before commitment,
and provides safer interaction with destructive operations.

### IV. Validation Gates

Critical workflow steps MUST pass validation before proceeding.

**Rules**:
- `/mykit.pr` displays an informational check dashboard (quality, security) — checks never block
- `/mykit.commit` requires uncommitted changes to exist
- `/mykit.specify` requires an issue to be selected
- `/mykit.release` requires PR to be merged with no blocking issues
- Gates MAY be bypassed with `--force` flag, but a warning MUST be displayed

**Rationale**: Quality enforcement prevents broken or incomplete work from progressing
through the pipeline. Gates catch issues early when they're cheapest to fix.

### V. Simplicity

Start simple. Add complexity only when justified by concrete need.

**Rules**:
- YAGNI (You Aren't Gonna Need It) - do not build for hypothetical requirements
- Prefer editing existing files over creating new ones
- Avoid abstractions until patterns emerge from duplication
- Shell scripts follow Google Shell Style Guide and pass shellcheck
- Conventional commits (`feat:`, `fix:`, `docs:`) enable automated versioning

**Rationale**: Simple solutions are easier to understand, maintain, and debug.
Complexity debt accumulates interest; simplicity preserves velocity.

## Command Conventions

Commands follow a consistent pattern for predictable behavior.

**Pattern**: `/mykit.{command} [action] [flags]`

**Actions**:
- Read-only: Execute immediately (e.g., `/mykit.status`)
- State-changing: Require action (e.g., `/mykit.commit create`)

**Standard Flags**:
- `--force`: Bypass validation gates (with warning)
- `--yes`, `-y`: Skip confirmation prompts
- `--json`: Machine-readable output
- `--no-issue`: Work without issue linking (exceptional use only)

**Exit Codes**:
- 0: Success
- 1: General error
- 2: Pre-condition failure (validation gate blocked)
- 3: Authentication or network error
- 4: Git operation error

## Governance

This constitution supersedes all other development practices for My Kit.

**Amendment Process**:
1. Propose amendment via GitHub Issue with `constitution` label
2. Document rationale and impact on existing workflows
3. Create migration plan for any breaking changes
4. Require review and approval before merge
5. Update version according to semantic versioning

**Versioning**:
- MAJOR: Backward-incompatible principle removal or redefinition
- MINOR: New principle or materially expanded guidance
- PATCH: Clarifications, wording improvements, non-semantic refinements

**Compliance**:
- All PRs and code reviews MUST verify adherence to these principles
- Complexity beyond these principles MUST be justified in the plan
- Runtime development guidance is provided in `CLAUDE.md`

**Version**: 1.0.0 | **Ratified**: 2025-12-04 | **Last Amended**: 2025-12-04

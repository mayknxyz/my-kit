# Feature: Validation Gates for Quality Enforcement

**Branch**: `013-validation-gates` | **Issue**: #13 | **Mode**: My Kit Lite

## Summary

Implement validation gates for `/mykit.commit` and `/mykit.pr` commands to enforce quality checks and task completion before critical workflow steps, preventing incomplete or broken work from progressing.

## Problem

Currently, the My Kit workflow allows users to:
- Create commits without validating code quality
- Create pull requests without completing all tasks
- Proceed through workflow steps without running checks

This can result in:
- Broken or untested code being committed
- PRs created with incomplete implementations
- Failed CI/CD pipelines
- Technical debt accumulation
- Time wasted reviewing incomplete work

The Blueprint (Phase 6, R7) specifies validation gates as a critical requirement for quality enforcement.

## Acceptance Criteria

### AC1: `/mykit.validate` Command Implementation

The `/mykit.validate` command must:
- ✓ Run shellcheck on all `.sh` files in `.mykit/scripts/`
- ✓ Run markdownlint on all `.md` files in `.claude/commands/` and `docs/`
- ✓ Report validation results with clear success/failure messages
- ✓ Store validation results in `.mykit/state.json` with timestamp
- ✓ Support `run` action for execution mode
- ✓ Show preview of what will be validated in no-action mode
- ✓ Exit with non-zero code on validation failure

### AC2: `/mykit.commit` Command Implementation

The `/mykit.commit` command must:
- ✓ Validate uncommitted changes exist (git status check)
- ✓ Show preview of changes to be committed (git diff)
- ✓ Support conventional commit format (feat, fix, docs, refactor, etc.)
- ✓ Generate commit message from changes
- ✓ Update CHANGELOG.md based on commit type
- ✓ Create commit with `create` action
- ✓ Support `--force` flag to bypass validation with warning
- ✓ Provide clear error messages when prerequisites fail

### AC3: `/mykit.pr` Command Implementation

The `/mykit.pr` command must:
- ✓ Validate all tasks in tasks.md are complete (no `[ ]` or `[>]` markers)
- ✓ Validate `/mykit.validate` has been run successfully
- ✓ Validate at least one commit exists on the branch
- ✓ Generate PR description from commits, spec, and plan
- ✓ Include "Closes #N" reference to issue
- ✓ Create PR with `create` action
- ✓ Support `--force` flag to bypass validation with warning
- ✓ Provide clear error messages explaining validation failures

### AC4: Validation Gate Error Messages

Error messages must:
- ✓ Clearly state what validation failed
- ✓ Explain why the validation is required
- ✓ Provide actionable remediation steps
- ✓ Suggest the `--force` flag option when appropriate

### AC5: State Tracking

State tracking must:
- ✓ Store validation results in `.mykit/state.json`
- ✓ Include timestamp of last validation run
- ✓ Include validation status (passed/failed)
- ✓ Include list of validation errors if failed
- ✓ Be updated after each command execution

## User Stories

### US1: Developer validates code quality

**As a** developer
**I want to** run validation checks before committing
**So that** I can catch quality issues early

**Acceptance**:
- Run `/mykit.validate` shows preview of checks
- Run `/mykit.validate run` executes shellcheck and markdownlint
- Results show which files passed/failed with specific errors
- Validation status is stored for later commands to check

### US2: Developer creates a quality commit

**As a** developer
**I want to** create commits that follow conventions and pass validation
**So that** the commit history is clean and consistent

**Acceptance**:
- Run `/mykit.commit` shows preview of changes
- Run `/mykit.commit create` creates conventional commit
- CHANGELOG.md is automatically updated
- Command fails if no uncommitted changes exist
- Can bypass with `--force` if needed

### US3: Developer creates a complete PR

**As a** developer
**I want to** create PRs only when work is complete and validated
**So that** reviewers receive ready-to-review code

**Acceptance**:
- Run `/mykit.pr` shows preview of PR content
- Run `/mykit.pr create` validates all gates before creating PR
- Command fails if tasks incomplete with clear message
- Command fails if validation not run/failed
- Can bypass with `--force` if needed for special cases

### US4: Developer understands validation failures

**As a** developer
**I want to** receive clear error messages when validation fails
**So that** I know exactly what to fix

**Acceptance**:
- Error messages state which gate failed
- Error messages explain why it's required
- Error messages provide fix instructions
- Error messages mention `--force` option

## Technical Context

### Existing Infrastructure

- Task tracking system in `/mykit.implement` using checkbox markers
- State management in `.mykit/state.json`
- Template system in `.mykit/templates/`
- Stub scripts in `.mykit/scripts/`

### Dependencies

- `shellcheck` command (for shell script linting)
- `markdownlint-cli` or `markdownlint-cli2` (for markdown linting)
- `git` command (for status, diff, commit operations)
- `gh` CLI (for PR creation)

### Validation Tools

**shellcheck**: Lints shell scripts for common errors
```bash
shellcheck --severity=warning .mykit/scripts/*.sh
```

**markdownlint**: Lints markdown files for formatting
```bash
markdownlint '**/*.md' --ignore node_modules --ignore .git
```

### State Schema

Add to `.mykit/state.json`:
```json
{
  "validation": {
    "last_run": "2026-01-16T10:30:00Z",
    "status": "passed",
    "errors": [],
    "files_checked": 42
  },
  "last_commit": {
    "sha": "abc123",
    "message": "feat: add validation gates",
    "timestamp": "2026-01-16T10:35:00Z"
  }
}
```

## Constraints

1. **Graceful degradation**: Commands should warn but not fail if validation tools are missing
2. **Performance**: Validation should complete in < 5 seconds for typical projects
3. **Backward compatibility**: Existing workflows without tasks.md should still work
4. **User control**: Force flag allows bypassing gates for emergency situations

## Out of Scope

- Test execution (unit tests, integration tests)
- Code coverage requirements
- Custom validation rules configuration
- Validation reports/history
- Git hooks integration
- Pre-commit hooks

## Success Metrics

- Zero PRs created with incomplete tasks
- Validation runs on 100% of commits
- Clear error messages reduce support questions
- Force flag used < 5% of the time

## References

- Blueprint: `docs/001_BLUEPRINT.md` (Phase 6, R7: Validation Gates)
- Task tracking: `.claude/commands/mykit.implement.md`
- Existing commands: `.claude/commands/mykit.*.md`

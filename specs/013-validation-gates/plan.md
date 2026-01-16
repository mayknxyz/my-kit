# Implementation Plan: Validation Gates

**Feature**: Validation gates for `/mykit.commit` and `/mykit.pr`
**Spec**: `specs/013-validation-gates/spec.md`

## Technical Context

### Current State

- Commands are stubs: `/mykit.validate`, `/mykit.commit`, `/mykit.pr`
- Scripts are stubs: `validation.sh`, `git-ops.sh`
- State management exists: `.mykit/state.json`
- Task tracking implemented: `/mykit.implement`

### Technology Stack

- Bash 4.0+ for scripts
- Markdown for command files
- JSON for state management
- External tools: shellcheck, markdownlint, git, gh

### Integration Points

- `.mykit/state.json` - State persistence
- `specs/{branch}/tasks.md` - Task completion tracking
- `CHANGELOG.md` - Commit history
- `.claude/commands/` - Command files
- `.mykit/scripts/` - Utility scripts

## Design Decisions

### D1: Validation Tool Requirements

**Decision**: Validate tool availability but warn gracefully if missing

**Options considered**:
1. Hard require tools, fail if missing
2. Warn if missing, skip validation
3. Offer to install missing tools

**Chosen**: Option 2 - Warn and skip

**Rationale**:
- Users may not have npm/package manager access
- Some environments restrict installations
- Warning allows workflow to continue
- Can still use `--force` flag

### D2: Validation Scope

**Decision**: Validate only project files, exclude dependencies

**Files to validate**:
- Shell scripts: `.mykit/scripts/*.sh`
- Commands: `.claude/commands/mykit.*.md`
- Documentation: `docs/*.md`, `README.md`, `CLAUDE.md`
- Specs: `specs/**/*.md`

**Files to exclude**:
- `node_modules/`
- `.git/`
- Third-party dependencies
- Generated files

**Rationale**:
- Fast validation (< 5 seconds)
- Only check code we control
- Standard exclusion patterns

### D3: Task Completion Check

**Decision**: Check for any incomplete task markers in tasks.md

**Validation logic**:
```bash
# Fail if any tasks are pending or in-progress
grep -E '^\- \[([ >])\]' tasks.md && echo "Incomplete tasks found"
```

**Considered**:
1. Check only "in-progress" tasks
2. Check pending and in-progress
3. Allow skipped tasks

**Chosen**: Option 3 - Pending and in-progress fail, skipped OK

**Rationale**:
- Skipped tasks are intentional decisions
- Pending tasks are not started
- In-progress tasks are incomplete

### D4: CHANGELOG Update Strategy

**Decision**: Append entries, don't regenerate entire file

**Format**:
```markdown
## [Unreleased]

### {Type}
- {Description}
```

**Mapping**:
- `feat:` → Added section
- `fix:` → Fixed section
- `docs:` → Documentation section
- `refactor:` → Changed section
- `test:` → Testing section
- `chore:` → Maintenance section

**Rationale**:
- Preserves manual edits
- Standard Keep a Changelog format
- Simple append operation
- Can be edited later

### D5: PR Description Generation

**Decision**: Use template with smart content extraction

**Sources** (in priority order):
1. Spec summary (if exists)
2. Plan overview (if exists)
3. Commit messages (fallback)
4. Git diff stats (always include)

**Template**:
```markdown
## Summary
{from spec or commits}

## Changes
{commit list}

## Test Plan
{from plan or manual}

Closes #{issue_number}
```

**Rationale**:
- Reuses existing documentation
- Works without spec/plan
- Consistent format
- Links to issue automatically

### D6: State Storage Structure

**Decision**: Flat validation object with timestamps

**Schema**:
```json
{
  "validation": {
    "last_run": "ISO-8601 timestamp",
    "status": "passed|failed|not_run",
    "errors": ["error1", "error2"],
    "files_checked": 42,
    "tools": {
      "shellcheck": "available|missing",
      "markdownlint": "available|missing"
    }
  }
}
```

**Rationale**:
- Simple to read/write
- Easy to check in other commands
- Includes tool availability for debugging
- Error list helps user fix issues

## Implementation Phases

### Phase 1: Validation Infrastructure (Foundation)

**Purpose**: Build validation.sh script with tool checks

**Tasks**:
1. Implement tool detection functions (check_shellcheck, check_markdownlint)
2. Implement validation functions (validate_shell_scripts, validate_markdown)
3. Implement result aggregation and reporting
4. Add state.json update logic
5. Handle missing tools gracefully with warnings

**Output**: `.mykit/scripts/validation.sh` with reusable functions

**Dependencies**: None

**Validation**: Can source script and call functions directly

### Phase 2: Git Operations Infrastructure

**Purpose**: Build git-ops.sh script with commit/diff operations

**Tasks**:
1. Implement uncommitted changes check (has_uncommitted_changes)
2. Implement commit message parsing (parse_conventional_commit)
3. Implement CHANGELOG update logic (update_changelog)
4. Implement commit creation (create_commit)
5. Implement branch/commit info functions

**Output**: `.mykit/scripts/git-ops.sh` with reusable functions

**Dependencies**: None

**Validation**: Can source script and call functions directly

### Phase 3: `/mykit.validate` Command

**Purpose**: Validation command with preview and execute modes

**Tasks**:
1. Create command file structure (usage, description, implementation)
2. Implement prerequisite checks (git repo, feature branch)
3. Implement no-action mode (preview of what will be validated)
4. Implement `run` action (execute validation via validation.sh)
5. Implement result display (success/failure with file counts)
6. Implement state.json update
7. Add error handling and exit codes

**Output**: `.claude/commands/mykit.validate.md`

**Dependencies**: Phase 1 (validation.sh)

**Validation**: Run on feature branch with/without validation tools

### Phase 4: `/mykit.commit` Command

**Purpose**: Commit command with validation gate

**Tasks**:
1. Create command file structure
2. Implement prerequisite checks (git repo, uncommitted changes)
3. Implement no-action mode (preview changes, proposed commit message)
4. Implement conventional commit message generation
5. Implement `create` action (update CHANGELOG, create commit)
6. Add `--force` flag support with warning
7. Implement state.json update
8. Add error handling

**Output**: `.claude/commands/mykit.commit.md`

**Dependencies**: Phase 2 (git-ops.sh)

**Validation**: Run on branch with uncommitted changes

### Phase 5: Task Completion Validation

**Purpose**: Helper function to check tasks.md completion

**Tasks**:
1. Add check_tasks_complete function to utils.sh
2. Parse tasks.md for incomplete markers
3. Return list of incomplete tasks
4. Handle missing tasks.md file gracefully

**Output**: Function in `.mykit/scripts/utils.sh`

**Dependencies**: None (but uses existing utils.sh)

**Validation**: Call function on various tasks.md files

### Phase 6: `/mykit.pr` Command

**Purpose**: PR command with all validation gates

**Tasks**:
1. Create command file structure
2. Implement prerequisite checks (git repo, feature branch)
3. Implement validation gates (tasks complete, validation passed, commits exist)
4. Implement no-action mode (preview PR description)
5. Implement PR description generation (from spec/plan/commits)
6. Implement `create` action (create PR via gh)
7. Add `--force` flag support with warning
8. Implement state.json update
9. Add comprehensive error messages

**Output**: `.claude/commands/mykit.pr.md`

**Dependencies**: Phase 3 (validate), Phase 5 (task checking)

**Validation**: Run on complete feature branch

### Phase 7: Templates and Distribution

**Purpose**: Create templates for installation/upgrade

**Tasks**:
1. Copy mykit.validate.md to `.mykit/templates/commands/`
2. Copy mykit.commit.md to `.mykit/templates/commands/`
3. Copy mykit.pr.md to `.mykit/templates/commands/`
4. Ensure templates match command files

**Output**: Templates in `.mykit/templates/commands/`

**Dependencies**: Phases 3, 4, 6

**Validation**: Templates identical to command files

## Critical Path

```
Phase 1 (validation.sh) ─┐
                         ├─→ Phase 3 (/mykit.validate) ─┐
Phase 2 (git-ops.sh) ────→ Phase 4 (/mykit.commit)      ├─→ Phase 6 (/mykit.pr) → Phase 7 (templates)
                                                         │
Phase 5 (task checking) ─────────────────────────────────┘
```

**Parallel work possible**:
- Phases 1, 2, 5 can be done in parallel
- Phase 3 requires Phase 1
- Phase 4 requires Phase 2
- Phase 6 requires Phases 3 and 5
- Phase 7 requires Phases 3, 4, 6

## Error Handling

### Missing Prerequisites

**Scenario**: Not in git repo, not on feature branch
**Response**: Clear error message with remediation steps
**Exit code**: 2 (precondition failure)

### Missing Validation Tools

**Scenario**: shellcheck or markdownlint not found
**Response**: Warning message, skip that validation type
**Exit code**: 0 (warning, not error)

### Validation Failures

**Scenario**: shellcheck or markdownlint find issues
**Response**: Display errors, update state, suggest fixes
**Exit code**: 1 (validation failed)

### Incomplete Tasks

**Scenario**: tasks.md has `[ ]` or `[>]` markers
**Response**: List incomplete tasks, suggest `/mykit.implement run`
**Exit code**: 1 (validation failed)

### Force Flag Behavior

**Scenario**: User adds `--force` flag
**Response**: Show warning, proceed with command
**Exit code**: 0 (forced success)

## Testing Strategy

### Unit Testing

Test individual functions in scripts:
```bash
source .mykit/scripts/validation.sh
test_check_shellcheck
test_validate_shell_scripts
```

### Integration Testing

Test commands end-to-end:
1. Create test feature branch
2. Add test files with intentional errors
3. Run commands in various states
4. Verify error messages and state updates

### Edge Cases

- Empty git repos
- Branches without tasks.md
- tasks.md with all tasks skipped
- Missing CHANGELOG.md
- Uncommitted CHANGELOG changes
- Multiple validation tool failures

## Risks and Mitigations

### Risk 1: Tool version differences

**Impact**: Different shellcheck/markdownlint versions give different results
**Mitigation**: Document minimum versions, use common flags only
**Probability**: Medium

### Risk 2: State file corruption

**Impact**: Commands can't read validation status
**Mitigation**: Add JSON validation, recreate if corrupted
**Probability**: Low

### Risk 3: CHANGELOG merge conflicts

**Impact**: Multiple branches update same section
**Mitigation**: Document pattern, add to [Unreleased] only
**Probability**: Medium

### Risk 4: gh CLI not available

**Impact**: Can't create PRs
**Mitigation**: Detect early, fail with setup instructions
**Probability**: Low (My Kit requires gh CLI)

## Success Criteria

- ✓ All validation gates functional
- ✓ Clear error messages for all failure cases
- ✓ Force flag works as escape hatch
- ✓ State tracking persists between commands
- ✓ Performance < 5 seconds for validation
- ✓ Works with/without optional tools
- ✓ Templates ready for distribution

## Documentation Updates

Files to update after implementation:
- `docs/COMMANDS.md` - Add `/mykit.validate`, update `/mykit.commit` and `/mykit.pr`
- `CHANGELOG.md` - Document new commands in [Unreleased]
- `README.md` - Update workflow diagram if needed

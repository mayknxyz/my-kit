# Research: Enhanced Status Dashboard

**Feature**: 006-status-dashboard
**Date**: 2025-12-06

## Research Summary

This document consolidates research findings for implementing `/mykit.status` as a Claude Code slash command.

---

## 1. Git Branch Detection

**Decision**: Use `git rev-parse --abbrev-ref HEAD` for branch name detection

**Rationale**:
- Standard git command, works in all git repositories
- Returns clean branch name without refs/heads prefix
- Returns "HEAD" when in detached HEAD state (allows edge case detection)

**Alternatives Considered**:
- `git branch --show-current`: Only works in git 2.22+, may not be available on all systems
- `git symbolic-ref --short HEAD`: Fails in detached HEAD state instead of returning useful info

**Edge Cases**:
- Detached HEAD: Returns "HEAD" - display warning to user
- Not a git repo: Command fails - display "not in git repository" message

---

## 2. Issue Number Extraction from Branch

**Decision**: Parse branch name using pattern `^([0-9]+)-` to extract leading issue number

**Rationale**:
- My Kit convention: branches named `{issue-number}-{slug}` (e.g., `006-status-dashboard`)
- Simple regex extraction, no external dependencies
- Fails gracefully for non-conforming branches

**Alternatives Considered**:
- State file lookup (`.mykit/state.json`): Adds file I/O dependency, may be stale
- GitHub API branch metadata: Over-engineering for simple extraction

**Pattern Implementation**:
```
Branch: 006-status-dashboard
Match: ^([0-9]+)-
Result: 006
```

---

## 3. GitHub Issue Lookup

**Decision**: Use `gh issue view {number} --json number,title,state` for issue details

**Rationale**:
- GitHub CLI is already a project dependency (documented in assumptions)
- JSON output is easily parseable
- Provides exactly the fields needed: number, title, state

**Alternatives Considered**:
- GitHub REST API via curl: Requires manual auth token handling
- GraphQL: Over-engineering for single issue lookup

**Graceful Degradation**:
- If `gh` not available or not authenticated: Display branch info only with note "GitHub info unavailable"
- If issue not found: Display "Issue #{number} not found"

---

## 4. Workflow Phase Detection

**Decision**: Check file existence in `specs/{branch-name}/` directory

**Rationale**:
- Aligns with clarification: "Implementation phase starts when tasks.md exists"
- Simple file existence checks, no parsing required
- Matches project structure convention

**Phase Logic**:
```
if tasks.md exists → "Implementation"
else if plan.md exists → "Planning"
else if spec.md exists → "Specification"
else → "Not started"
```

**Directory Path**: `specs/{branch-name}/` where branch-name is the current git branch

---

## 5. File Status Display

**Decision**: Use `git status --porcelain` for machine-parseable file status

**Rationale**:
- Porcelain format is stable across git versions
- Two-character status codes provide staging info (index vs working tree)
- Easy to parse and categorize files

**Alternatives Considered**:
- `git status --short`: Human-readable but less stable format
- `git diff --name-status`: Doesn't show untracked files

**Status Code Mapping**:
| Code | Meaning | Display |
|------|---------|---------|
| M_ | Modified (staged) | ✓ staged |
| _M | Modified (unstaged) | modified |
| A_ | Added (staged) | ✓ added |
| _A | Added (unstaged) | added |
| D_ | Deleted (staged) | ✓ deleted |
| _D | Deleted (unstaged) | deleted |
| ?? | Untracked | untracked |
| R_ | Renamed (staged) | ✓ renamed |

**Limit**: Display max 10 files, show "+N more" summary when exceeded (per clarification)

---

## 6. Next Command Suggestion Logic

**Decision**: State machine based on workflow phase and file status

**Rationale**:
- Deterministic suggestions based on observable state
- Helps users learn the workflow progression
- No external configuration needed

**Suggestion Matrix**:

| Workflow Phase | Has Uncommitted Changes | Suggested Command |
|----------------|------------------------|-------------------|
| Not started | Any | `/mykit.backlog select` or `/speckit.specify` |
| Specification | No | `/speckit.clarify` or `/speckit.plan` |
| Specification | Yes | `/mykit.commit create` |
| Planning | No | `/speckit.tasks` |
| Planning | Yes | `/mykit.commit create` |
| Implementation | No | `/mykit.implement run` or `/mykit.pr create` |
| Implementation | Yes | `/mykit.commit create` |

**Alternatives Considered**:
- User-configurable suggestion rules: Adds complexity without clear benefit
- ML-based suggestions: Massive over-engineering

---

## 7. Output Formatting

**Decision**: Structured markdown sections with clear visual hierarchy

**Rationale**:
- Claude Code renders markdown in terminal
- Consistent with other My Kit command outputs
- Sections allow quick scanning

**Dashboard Layout**:
```markdown
# My Kit Status

## Feature Context
**Branch**: {branch}
**Issue**: #{number} - {title} ({state})

## Workflow Phase
**Current**: {phase}
**Progress**: spec.md ✓ | plan.md ✓ | tasks.md ○

## File Status
{file list or "Working directory clean"}

## Next Step
{suggested command with brief explanation}
```

---

## 8. Error Handling Strategy

**Decision**: Graceful degradation with informative messages

**Rationale**:
- Read-only command should never fail catastrophically
- Partial information is better than no information
- Clear error messages help users resolve issues

**Error Scenarios**:

| Scenario | Behavior |
|----------|----------|
| Not a git repo | Display: "Not in a git repository. Run `git init` to initialize." |
| No feature branch | Display branch info with: "Not on a feature branch. Use `/mykit.backlog select` to start." |
| gh not available | Display local info with: "GitHub CLI not available. Issue details unavailable." |
| gh not authenticated | Display local info with: "GitHub CLI not authenticated. Run `gh auth login`." |
| Detached HEAD | Display: "Warning: Detached HEAD state at {commit}. Branch info unavailable." |

---

## Research Complete

All NEEDS CLARIFICATION items resolved. Ready for Phase 1 design.

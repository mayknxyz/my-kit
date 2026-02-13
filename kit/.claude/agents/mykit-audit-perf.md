# Audit Subagent: Performance

Analyze the codebase for performance anti-patterns and bottlenecks using AI-driven code review, then write a structured audit report.

## Inputs

You will receive these variables from the orchestrator:
- `REPO_ROOT`: Absolute path to the repository root
- `REPORT_PATH`: Absolute path where the report should be written (e.g., `specs/{branch}/audit/perf.md`)

## Execution

### 1. Discover Code Files

Search the repository for code files to analyze. Prioritize:
- Shell scripts: `$HOME/.claude/skills/mykit/references/scripts/*.sh`
- Command prompts: `.claude/commands/*.md` (check for embedded bash)
- Application code: `src/`, `lib/`, `app/` directories
- Configuration: `*.json`, `*.yaml`, `*.toml` with processing logic

Use Glob and Read tools to discover and read files. Focus on the most impactful files first.

### 2. Analyze for Performance Anti-Patterns

Check for these categories:

**Shell Script Performance**:
- Unnecessary subshell spawning in loops (e.g., `$(cmd)` inside `while` loops)
- Repeated file reads that could be cached in a variable
- Using `cat file | cmd` instead of `cmd < file` (useless use of cat)
- Inefficient `find` + `exec` patterns vs `find -print0 | xargs -0`
- Using `grep` + `awk` when `awk` alone suffices
- Large file processing without streaming (loading entire file into memory)
- Unnecessary use of external commands where bash builtins suffice

**General Code Performance**:
- N+1 query patterns (repeated calls inside loops)
- Missing caching for expensive operations
- Synchronous operations that could be parallelized
- Inefficient data structure choices
- Redundant computations

**I/O Performance**:
- Excessive disk reads/writes
- Missing buffering for file operations
- Unnecessary file existence checks before reads

### 3. Assess Severity

- **low**: Style preference, minimal real-world impact
- **medium**: Measurable impact on large codebases or repeated operations
- **high**: Significant performance impact, scales poorly

### 4. Generate Proposed Fixes

For each finding:
- Show the current code (problematic pattern)
- Show the improved code (with the fix applied)
- Explain the performance difference

### 5. Write Report

Write the report to `{REPORT_PATH}` using this format:

```markdown
# Audit Report: Performance

**Domain**: perf
**Date**: {YYYY-MM-DD}
**Tools**: AI analysis
**Status**: {passed|failed}

## Summary

- **Files analyzed**: {count}
- **Issues found**: {count}
- **Severity**: {none|low|medium|high}

## Findings

### {Finding title, e.g., "Subshell spawning in loop in version.sh"}

- **File**: {file path relative to repo root}
- **Line**: {line number or range}
- **Severity**: {low|medium|high}
- **Category**: {shell-perf|io-perf|algorithm|caching}
- **Description**: {what's wrong and why it matters}
- **Current Code**:
  ```bash
  {problematic code snippet}
  ```
- **Proposed Fix**:
  ```bash
  {improved code snippet}
  ```
- **Impact**: {expected improvement}

---

{Repeat for each finding. If no findings, write: "No performance issues found."}
```

## Return Value

Return a one-line summary: `"{status}: {issue_count} performance issues found in {files_analyzed} files"`

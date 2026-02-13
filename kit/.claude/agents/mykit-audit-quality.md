# Audit Subagent: Quality

Run code quality checks using shellcheck and markdownlint, then write a structured audit report.

## Inputs

You will receive these variables from the orchestrator:
- `REPO_ROOT`: Absolute path to the repository root
- `REPORT_PATH`: Absolute path where the report should be written (e.g., `specs/{branch}/audit/quality.md`)

## Execution

### 1. Run Quality Checks

```bash
cd {REPO_ROOT}
source $HOME/.claude/skills/mykit/references/scripts/validation.sh
run_all_validations 2>&1
```

Capture the output and the exit code:
- Exit 0 = all checks passed
- Exit 1 = one or more checks failed

If `validation.sh` cannot be sourced, set status to "error" and note the issue.

### 2. Check Tool Availability

```bash
command -v shellcheck
command -v markdownlint-cli2 || command -v markdownlint
```

If a tool is not installed, note it as "not installed" in the report. If neither tool is installed, set status to "skipped".

### 3. Parse Results

From the validation output, extract:
- Total files checked (from `VALIDATION_FILES_CHECKED`)
- Individual findings with file path, line number, and description
- Distinguish between shellcheck findings and markdownlint findings

### 4. Generate Proposed Fixes

For each finding:
- **shellcheck issues**: Reference the shellcheck wiki (SC####) and provide the corrected code
- **markdownlint issues**: Describe the markdown rule violation and show the corrected markup

### 5. Write Report

Write the report to `{REPORT_PATH}` using this format:

```markdown
# Audit Report: Quality

**Domain**: quality
**Date**: {YYYY-MM-DD}
**Tools**: shellcheck {version|not installed}, markdownlint {version|not installed}
**Status**: {passed|failed|skipped}

## Summary

- **Files checked**: {count}
- **Issues found**: {count}
- **Severity**: {none|low|medium|high}

## Findings

### {Finding title}

- **File**: {file path relative to repo root}
- **Line**: {line number}
- **Severity**: {low|medium|high}
- **Tool**: {shellcheck|markdownlint}
- **Rule**: {rule code, e.g., SC2086 or MD013}
- **Description**: {what's wrong}
- **Proposed Fix**: {how to fix it, with code snippet}

---

{Repeat for each finding. If no findings, write: "No issues found."}
```

## Return Value

Return a one-line summary: `"{status}: {issue_count} issues found in {files_checked} files"`

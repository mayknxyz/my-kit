# Audit Subagent: Link Check

Run link validation using lychee and linkinator to detect broken links in markdown, HTML, and documentation files, then write a structured audit report.

## Inputs

You will receive these variables from the orchestrator:

- `REPO_ROOT`: Absolute path to the repository root
- `REPORT_PATH`: Absolute path where the report should be written (e.g., `specs/{branch}/audit/linkcheck.md`)

## Execution

### 1. Run Link Checks

```bash
cd {REPO_ROOT}
source $HOME/.claude/skills/mykit/references/scripts/linkcheck.sh
run_all_link_checks 2>&1
```

Capture the output and the exit code:

- Exit 0 = all links valid
- Exit 1 = broken links detected or error

If `linkcheck.sh` cannot be sourced, set status to "error" and note the issue.

### 2. Check Tool Availability

```bash
command -v lychee
command -v linkinator
```

If a tool is not installed, note it as "not installed" in the report. If neither tool is installed, set status to "skipped".

### 3. Parse Results

From the link check output, extract:

- Whether broken links were detected
- For each broken link: source file path, line number (if available), target URL, HTTP status code or error type, which tool detected it
- Deduplicate findings reported by both tools (same source file + target URL)

### 4. Generate Proposed Fixes

For each finding:

- **Dead external links (404, timeout)**: Suggest removing the link or replacing with an archived URL (web.archive.org)
- **Moved resources (301, 302)**: Suggest updating to the final redirect target URL
- **Malformed URLs**: Show the corrected URL syntax
- **Relative path errors**: Suggest the correct relative path
- **Anchor/fragment errors**: Suggest removing or correcting the fragment identifier

### 5. Write Report

Write the report to `{REPORT_PATH}` using this format:

```markdown
# Audit Report: Link Check

**Domain**: linkcheck
**Date**: {YYYY-MM-DD}
**Tools**: lychee {version|not installed}, linkinator {version|not installed}
**Status**: {passed|failed|skipped}

## Summary

- **Files scanned**: {count or "all markdown and HTML files"}
- **Links checked**: {count}
- **Broken links found**: {count}
- **Severity**: {none|low|medium|high}

## Findings

### {Finding title, e.g., "Broken link in README.md"}

- **File**: {file path relative to repo root}
- **Line**: {line number or "N/A"}
- **Severity**: {low|medium|high}
- **Tool**: {lychee|linkinator|both}
- **Target URL**: {the broken URL}
- **Error**: {HTTP status code or error description}
- **Description**: {context about the broken link}
- **Proposed Fix**: {corrected URL, removal suggestion, or archive link}

---

{Repeat for each finding. If no findings, write: "No broken links found."}
```

## Return Value

Return a one-line summary: `"{status}: {broken_count} broken links found"`

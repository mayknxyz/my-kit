# Audit Subagent: Security

Run security scans using gitleaks to detect leaked secrets, API keys, tokens, and passwords, then write a structured audit report.

## Inputs

You will receive these variables from the orchestrator:

- `REPO_ROOT`: Absolute path to the repository root
- `REPORT_PATH`: Absolute path where the report should be written (e.g., `specs/{branch}/audit/security.md`)

## Execution

### 1. Run Security Scan

```bash
cd {REPO_ROOT}
source $HOME/.claude/skills/mykit/references/scripts/security.sh
run_all_security_checks 2>&1
```

Capture the output and the exit code:

- Exit 0 = no secrets detected
- Exit 1 = secrets found or scan error

If `security.sh` cannot be sourced, set status to "error" and note the issue.

### 2. Check Tool Availability

```bash
command -v gitleaks
```

If gitleaks is not installed, set status to "skipped" and note install instructions.

### 3. Parse Results

From the security scan output, extract:

- Whether secrets were detected
- For each detected secret: file path, line number, rule that matched, type of secret

### 4. Generate Proposed Fixes

For each finding:

- Identify the type of secret (API key, token, password, private key)
- Recommend removal from source code
- Suggest environment variable or secret manager alternative
- Recommend adding the file to `.gitignore` if appropriate
- Recommend rotating the exposed credential

### 5. Write Report

Write the report to `{REPORT_PATH}` using this format:

```markdown
# Audit Report: Security

**Domain**: security
**Date**: {YYYY-MM-DD}
**Tools**: gitleaks {version|not installed}
**Status**: {passed|failed|skipped}

## Summary

- **Files scanned**: all tracked files
- **Secrets found**: {count}
- **Severity**: {none|high|critical}

## Findings

### {Finding title, e.g., "API key detected in config.js"}

- **File**: {file path relative to repo root}
- **Line**: {line number}
- **Severity**: {high|critical}
- **Rule**: {gitleaks rule name}
- **Description**: {type of secret and context}
- **Proposed Fix**: {removal steps, env var suggestion, rotation recommendation}

---

{Repeat for each finding. If no findings, write: "No secrets detected."}
```

## Return Value

Return a one-line summary: `"{status}: {secret_count} secrets found"`

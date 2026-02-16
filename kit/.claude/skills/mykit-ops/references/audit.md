# /mykit.audit.*

Run audits across check domains: quality, security, performance, accessibility, and dependencies.

## Commands

| Command | Description |
|---------|-------------|
| `/mykit.audit.all` | Run all domains |
| `/mykit.audit.quality` | Quality only (shellcheck, markdownlint) |
| `/mykit.audit.security` | Security only (gitleaks) |
| `/mykit.audit.perf` | Performance only (AI analysis) |
| `/mykit.audit.a11y` | Accessibility only (AI analysis) |
| `/mykit.audit.deps` | Dependencies only (AI analysis) |

## Usage

```
/mykit.audit.all [--only domain1,domain2]
/mykit.audit.{domain}
```

- `/mykit.audit.all`: Launch all subagents in parallel, collect reports, display summary, propose fixes
- `/mykit.audit.{domain}`: Run a single domain audit
- `--only`: Comma-separated list of domains to run (e.g., `--only quality,security`). Valid domains: `quality`, `security`, `perf`, `a11y`, `deps`

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Description

This command orchestrates multiple check/validation subagents in parallel using the Task tool. Each subagent produces a markdown report stored in the spec's audit directory. After all subagents complete, the command displays a consolidated summary, proposes fixes, and lets the user choose to fix all or selectively apply solutions.

### Subagent Domains

| Domain | Report File | Tool(s) | Checks |
|--------|------------|---------|--------|
| quality | `quality.md` | shellcheck, markdownlint | Shell script lint, markdown lint |
| security | `security.md` | gitleaks | Secret detection, leaked credentials |
| perf | `perf.md` | AI-driven analysis | Performance anti-patterns, bottlenecks |
| a11y | `a11y.md` | AI-driven analysis | Accessibility issues in UI code |
| deps | `deps.md` | AI-driven analysis + package managers | Outdated deps, known vulnerabilities, license issues |

## Implementation

When this command is invoked, perform the following steps:

### Step 1: Check Prerequisites

Verify we're in a git repository:

```bash
git rev-parse --git-dir 2>/dev/null
```

**If not in a git repository**, display error and stop:

```
**Error**: Not in a git repository.

Run `git init` to initialize a repository, or navigate to an existing git repository.
```

### Step 2: Parse Arguments

Parse the command arguments to determine:
- `action`: `null` (no action = preview) or `"run"` (execute)
- `onlyDomains`: If `--only` flag is present, parse the comma-separated domain list. If not present, default to all domains: `["quality", "security", "perf", "a11y", "deps"]`

**Validation**:
- If an invalid action is provided (not `run`), display error:
  ```
  **Error**: Invalid action '{action}'.

  Valid actions: run
  Or run without an action to preview available checks.
  ```

- If `--only` contains an invalid domain name, display error:
  ```
  **Error**: Invalid domain '{domain}'.

  Valid domains: quality, security, perf, a11y, deps
  Example: `/mykit.audit.all --only quality,security`
  ```

### Step 3: Get Current Branch and Determine Report Directory

Get the current branch name:

```bash
git rev-parse --abbrev-ref HEAD
```

Extract the issue number from the branch name using pattern `^([0-9]+)-`:

**If on a feature branch** (e.g., `116-audit-command`):
- Set `reportDir = specs/{branch}/audit/`

**If NOT on a feature branch** (e.g., `main`):
- Set `reportDir = specs/audit/`

### Step 4: Route Based on Action

- **If `action` is null**: Go to Preview Mode (Step 5)
- **If `action` is "run"**: Go to Run Mode (Step 6)

---

## Preview Mode (No Action)

### Step 5: Display Audit Preview

Check tool availability for each domain:

```bash
# Quality tools
command -v shellcheck
command -v markdownlint-cli2 || command -v markdownlint

# Security tools
command -v gitleaks
```

Display:

```
## Audit Preview

The following checks will be performed:

| Domain | Tool(s) | Status | Checks |
|--------|---------|--------|--------|
| quality | shellcheck, markdownlint | {available/partial/missing} | Shell script lint, markdown lint |
| security | gitleaks | {available/missing} | Secret detection, leaked credentials |
| perf | AI analysis | ready | Performance anti-patterns, bottlenecks |
| a11y | AI analysis | ready | Accessibility issues in UI code |
| deps | AI analysis | ready | Outdated deps, vulnerabilities, licenses |

**Report directory**: `{reportDir}`

---

**Next Steps**:
- Run `/mykit.audit.all` to execute all checks
- Run `/mykit.audit.{domain}` to run a specific domain (e.g., `/mykit.audit.quality`)
- Run `/mykit.audit.all --only quality,security` to run specific checks only
```

Stop after displaying preview.

---

## Run Mode

### Step 6: Create Report Directory

```bash
mkdir -p {reportDir}
```

### Step 7: Load and Launch Subagents in Parallel

Subagent prompt files live in `$HOME/.claude/agents/`. Each file contains the full instructions for one audit domain.

| Domain | Subagent File | `subagent_type` |
|--------|--------------|-----------------|
| quality | `$HOME/.claude/agents/audit-quality.md` | `Bash` |
| security | `$HOME/.claude/agents/audit-security.md` | `Bash` |
| perf | `$HOME/.claude/agents/audit-perf.md` | `general-purpose` |
| a11y | `$HOME/.claude/agents/audit-a11y.md` | `general-purpose` |
| deps | `$HOME/.claude/agents/audit-deps.md` | `general-purpose` |

**For each domain in `onlyDomains`**:

1. Read the subagent prompt file from `$HOME/.claude/agents/audit-{domain}.md`
2. Construct the Task tool call by prepending these runtime variables to the prompt:
   ```
   REPO_ROOT: {absolute path to repository root}
   REPORT_PATH: {absolute path to reportDir}/{domain}.md

   {contents of the subagent prompt file}
   ```
3. Set `subagent_type` from the table above
4. Set `description` to `"audit-{domain}"`

**Launch ALL subagents in a single message** (parallel execution). Use the Task tool with `run_in_background: false` so all complete before proceeding.

Example for quality:
```
Task(
  subagent_type: "Bash",
  description: "audit-quality",
  prompt: "REPO_ROOT: /path/to/repo\nREPORT_PATH: /path/to/specs/{branch}/audit/quality.md\n\n{contents of $HOME/.claude/agents/audit-quality.md}"
)
```

Repeat for each domain. All Task calls go in a single message for parallel execution.

### Step 8: Collect Results

After all subagents complete, read all report files from `{reportDir}/`:
- `quality.md`
- `security.md`
- `perf.md`
- `a11y.md`
- `deps.md`

For each report, extract:
- `status`: passed, failed, or skipped
- `issueCount`: Number of findings
- `findings`: List of individual issues with proposed fixes

### Step 9: Display Consolidated Summary

Display the summary table:

```
## Audit Results

| Domain | Status | Issues | Severity |
|--------|--------|--------|----------|
| quality | {pass/fail/skip} | {count} | {highest severity} |
| security | {pass/fail/skip} | {count} | {highest severity} |
| perf | {pass/fail/skip} | {count} | {highest severity} |
| a11y | {pass/fail/skip} | {count} | {highest severity} |
| deps | {pass/fail/skip} | {count} | {highest severity} |

**Total issues**: {totalIssueCount}
**Reports saved to**: `{reportDir}`
```

**If no issues found across all domains**:

```
All clear! No issues found across all audit domains.

**Reports saved to**: `{reportDir}`
```

Stop here (no fix prompt needed).

### Step 10: Display Proposed Fixes

**If issues were found**, display a grouped summary of proposed fixes:

```
## Proposed Fixes

### Quality ({count} fixes)
1. **{file}:{line}** — {description} → {fix summary}
2. ...

### Security ({count} fixes)
1. ...

### Performance ({count} fixes)
1. ...

{Continue for each domain with findings}
```

### Step 11: Selective Fix Flow

Use `AskUserQuestion` to prompt the user:

- header: "Fix Issues"
- question: "How would you like to handle the issues found?"
- options:
  1. label: "Fix all", description: "Apply all proposed fixes automatically"
  2. label: "Select fixes", description: "Choose which fixes to apply domain by domain"
  3. label: "Skip fixes", description: "Save reports only — fix nothing now"

**If user selects "Fix all"**:
- Apply all proposed fixes from all reports
- Display what was changed

**If user selects "Select fixes"**:
- For each domain that has findings, use `AskUserQuestion` with multiSelect:
  - header: "{Domain} fixes"
  - question: "Which {domain} fixes should be applied?"
  - options: List of fixes (up to 4 per prompt, paginate if more)
- Apply only selected fixes
- Display what was changed

**If user selects "Skip fixes"**:
- Display:
  ```
  Reports saved. No fixes applied.

  Review reports in `{reportDir}` and fix manually, or re-run `/mykit.audit.all` later.
  ```

---

## Error Handling

| Error | Message |
|-------|---------|
| Not a git repository | "Not in a git repository. Run `git init` to initialize." |
| Invalid action | "Invalid action '{action}'. Valid actions: run" |
| Invalid domain | "Invalid domain '{domain}'. Valid domains: quality, security, perf, a11y, deps" |
| Subagent timeout | "Subagent '{domain}' timed out. Partial results collected." |
| Subagent error | "Subagent '{domain}' encountered an error. Check `{reportDir}/{domain}.md` for details." |
| Report write failure | "Could not write report to `{reportDir}/{domain}.md`. Check directory permissions." |

## Notes

- All checks are non-destructive (read-only analysis) until fixes are applied
- Missing tools cause graceful degradation (domain reports "skipped")
- Reports persist in the spec directory for reference across sessions
- Audit results are also written to `checks.quality` and `checks.security` for the PR check dashboard

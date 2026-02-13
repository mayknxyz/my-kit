# Audit Subagent: Dependencies

Analyze project dependencies for outdated packages, known vulnerabilities, license issues, and unpinned versions, then write a structured audit report.

## Inputs

You will receive these variables from the orchestrator:
- `REPO_ROOT`: Absolute path to the repository root
- `REPORT_PATH`: Absolute path where the report should be written (e.g., `specs/{branch}/audit/deps.md`)

## Execution

### 1. Discover Package Manifests

Search for dependency files in the repository root and common subdirectories:

**Package managers**:
- Node.js: `package.json`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
- Python: `requirements.txt`, `pyproject.toml`, `Pipfile`, `setup.py`, `setup.cfg`
- Rust: `Cargo.toml`, `Cargo.lock`
- Go: `go.mod`, `go.sum`
- Ruby: `Gemfile`, `Gemfile.lock`
- PHP: `composer.json`, `composer.lock`
- Java: `pom.xml`, `build.gradle`, `build.gradle.kts`
- .NET: `*.csproj`, `packages.config`

Use Glob to search. Read each manifest found.

### 2. Analyze Package Dependencies

**If package manifests exist**:

**Version Pinning**:
- Flag dependencies using ranges (`^`, `~`, `>=`, `*`) without lock files
- Flag unpinned dependencies in requirements.txt (no `==`)
- Note which dependencies have lock files for reproducibility

**Known Vulnerabilities**:
- Cross-reference dependencies against your knowledge of known CVEs
- Check for packages with major known security issues
- Flag any dependency with a critical or high severity CVE

**Outdated Packages**:
- If lock files exist, check for significantly outdated major versions
- Note packages that are end-of-life or unmaintained

**Deprecated Packages**:
- Flag packages known to be deprecated with recommended replacements

**License Issues**:
- If license info is available (package.json `license` field, Cargo.toml `license`), check for:
  - Copyleft licenses (GPL) in permissive-licensed projects
  - Missing license declarations
  - License incompatibilities

### 3. Analyze Shell Script Dependencies

Also check `$HOME/.claude/skills/mykit/references/scripts/*.sh` for external tool dependencies:
- Read each script and identify `command -v` checks and direct tool invocations
- List all external tools the scripts depend on (e.g., `gh`, `jq`, `shellcheck`, `gitleaks`, `git`)
- Note which are required vs optional (checked with `command -v` guards)
- Flag any tools that are invoked without availability checks

### 4. Assess Severity

- **critical**: Known CVE with active exploitation or remote code execution
- **high**: Known CVE or deprecated package with security implications
- **medium**: Significantly outdated major version, unpinned dependency, license concern
- **low**: Minor version behind, style preference, informational

### 5. Generate Proposed Fixes

For each finding:
- **Vulnerable package**: Specify the safe version to upgrade to
- **Unpinned dependency**: Show the pinned version syntax
- **Deprecated package**: Name the recommended replacement
- **License issue**: Suggest alternative package or license resolution
- **Missing tool check**: Show the `command -v` guard pattern

### 6. Write Report

Write the report to `{REPORT_PATH}` using this format:

```markdown
# Audit Report: Dependencies

**Domain**: deps
**Date**: {YYYY-MM-DD}
**Tools**: AI analysis
**Status**: {passed|failed|not-applicable}

## Summary

- **Manifests found**: {list of manifest files}
- **Total dependencies**: {count}
- **Issues found**: {count}
- **Severity**: {none|low|medium|high|critical}

## Package Dependencies

{List all dependencies found with current versions, grouped by manifest file}

## Shell Tool Dependencies

{List all external tools used by $HOME/.claude/skills/mykit/references/scripts/ with availability check status}

## Findings

### {Finding title, e.g., "Unpinned dependency: lodash in package.json"}

- **File**: {manifest file path}
- **Package**: {package name}
- **Current Version**: {version or range}
- **Severity**: {low|medium|high|critical}
- **Category**: {vulnerability|outdated|unpinned|deprecated|license|missing-check}
- **Description**: {what's wrong}
- **Proposed Fix**: {specific version to use, replacement package, or code change}

---

{Repeat for each finding. If no findings, write: "No dependency issues found." or "No package manifests found — analyzed shell tool dependencies only."}
```

## Return Value

Return a one-line summary: `"{status}: {issue_count} dependency issues found across {manifest_count} manifests"`

# /mykit.validate

Run code quality validation checks on shell scripts and markdown files.

## Usage

```
/mykit.validate [run]
```

- No action: Display validation preview (files that will be checked)
- `run`: Execute validation checks and update state

## Description

This command validates code quality by running shellcheck on shell scripts and markdownlint on markdown files. It provides clear feedback on validation status and stores results in state.json for other commands to check.

## Implementation

When this command is invoked, perform the following steps:

### Step 1: Check Prerequisites

First, verify we're in a git repository:

```bash
git rev-parse --git-dir 2>/dev/null
```

**If not in a git repository**, display the following message and stop:

```
**Error**: Not in a git repository.

Run `git init` to initialize a repository, or navigate to an existing git repository.
```

### Step 2: Parse Arguments

Parse the command arguments to determine the action:
- If no arguments: `action = null` (preview mode)
- If first argument is `run`: `action = "run"` (execute mode)
- If first argument is anything else: show error

**If an invalid action is provided**, display:

```
**Error**: Invalid action '{action}'.

Valid actions: run
Or run without an action to preview what will be validated.
```

### Step 3: Source Validation Script

Source the validation.sh script to access validation functions:

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/.mykit/scripts/validation.sh"
```

**If validation.sh cannot be sourced**, display:

```
**Error**: validation.sh script not found.

Expected location: .mykit/scripts/validation.sh
```

### Step 4: Route Based on Action

Based on the parsed action:
- **If action is null**: Go to Step 5 (Preview Mode)
- **If action is "run"**: Go to Step 6 (Run Mode)

---

## Preview Mode (No Action)

### Step 5: Display Validation Preview

Show what files will be validated:

```
## Code Quality Validation

This command will validate the following:

### Shell Scripts
- Location: `.mykit/scripts/*.sh`
- Tool: shellcheck
- Status: {available|not installed}

### Markdown Files
- Locations:
  - `.claude/commands/*.md`
  - `docs/*.md`
  - `specs/**/*.md`
  - `README.md`, `CLAUDE.md`, `CHANGELOG.md`
- Tool: markdownlint
- Status: {available|not installed}

---

**Next Steps**:
- Run `/mykit.validate run` to execute validation checks
- Install missing tools:
  - shellcheck: `brew install shellcheck` (macOS) or `apt-get install shellcheck` (Linux)
  - markdownlint: `npm install -g markdownlint-cli2`
```

Where `{available|not installed}` is determined by checking:
- shellcheck: `command -v shellcheck &>/dev/null`
- markdownlint: `command -v markdownlint-cli2 &>/dev/null || command -v markdownlint &>/dev/null`

Stop after displaying preview.

---

## Run Mode

### Step 6: Display Run Mode Header

Display:

```
## Running Code Quality Validation

Checking code quality using available validation tools...

```

### Step 7: Check Tool Availability

Check which validation tools are available:

```bash
source .mykit/scripts/validation.sh

SHELLCHECK_AVAILABLE=0
MARKDOWNLINT_AVAILABLE=0

if check_shellcheck &>/dev/null; then
  SHELLCHECK_AVAILABLE=1
  echo "✓ shellcheck available"
fi

if check_markdownlint &>/dev/null; then
  MARKDOWNLINT_AVAILABLE=1
  echo "✓ markdownlint available"
fi

echo ""
```

If neither tool is available:

```
**Warning**: No validation tools found.

Validation requires at least one of:
- shellcheck (for shell scripts)
- markdownlint (for markdown files)

Install shellcheck: `brew install shellcheck` (macOS) or `apt-get install shellcheck` (Linux)
Install markdownlint: `npm install -g markdownlint-cli2`

Skipping validation.
```

Update state.json with "not_run" status and stop.

### Step 8: Run Validation

Execute validation using the sourced functions:

```bash
source .mykit/scripts/validation.sh

# Run all validations
if run_all_validations; then
  VALIDATION_STATUS="passed"
  VALIDATION_EXIT_CODE=0
else
  VALIDATION_STATUS="failed"
  VALIDATION_EXIT_CODE=1
fi
```

The `run_all_validations` function will:
- Call `validate_shell_scripts` (if shellcheck available)
- Call `validate_markdown` (if markdownlint available)
- Display results with `format_validation_output`
- Return 0 if passed, 1 if failed

### Step 9: Update State

Update `.mykit/state.json` with validation results.

First, read existing state (create empty object if file doesn't exist):

```bash
STATE_FILE=".mykit/state.json"

if [[ -f "$STATE_FILE" ]]; then
  STATE_JSON=$(cat "$STATE_FILE")
else
  STATE_JSON="{}"
fi
```

Then update with validation results using jq:

```bash
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Determine tool status
SHELLCHECK_STATUS="missing"
MARKDOWNLINT_STATUS="missing"

if command -v shellcheck &>/dev/null; then
  SHELLCHECK_STATUS="available"
fi

if command -v markdownlint-cli2 &>/dev/null || command -v markdownlint &>/dev/null; then
  MARKDOWNLINT_STATUS="available"
fi

# Build errors array (from VALIDATION_ERRORS global if validation failed)
ERRORS_JSON="[]"
if [[ "$VALIDATION_STATUS" == "failed" ]]; then
  # Convert bash array to JSON array
  ERRORS_JSON=$(printf '%s\n' "${VALIDATION_ERRORS[@]}" | jq -R . | jq -s .)
fi

# Update state
UPDATED_STATE=$(echo "$STATE_JSON" | jq \
  --arg timestamp "$TIMESTAMP" \
  --arg status "$VALIDATION_STATUS" \
  --argjson errors "$ERRORS_JSON" \
  --argjson files_checked "$VALIDATION_FILES_CHECKED" \
  --arg shellcheck "$SHELLCHECK_STATUS" \
  --arg markdownlint "$MARKDOWNLINT_STATUS" \
  '.validation = {
    last_run: $timestamp,
    status: $status,
    errors: $errors,
    files_checked: $files_checked,
    tools: {
      shellcheck: $shellcheck,
      markdownlint: $markdownlint
    }
  }')

echo "$UPDATED_STATE" > "$STATE_FILE"
```

### Step 10: Display Completion Message

Based on validation status:

**If validation passed**:

```
---

✅ **Validation complete**

All checks passed. Results saved to state.json.

**Next Steps**:
- Make changes: Continue development
- Commit changes: `/mykit.commit create`
```

**If validation failed**:

```
---

❌ **Validation failed**

Please fix the issues above before committing.

**Next Steps**:
- Fix issues: Address the errors listed above
- Re-run validation: `/mykit.validate run`
- Skip validation: Use `--force` flag with `/mykit.commit` (not recommended)
```

### Step 11: Exit with Status Code

Exit with appropriate code:
- Exit 0 if validation passed
- Exit 1 if validation failed

This allows the command to be used in scripts/chains.

---

## Error Handling

### Missing validation.sh

If the validation.sh script cannot be sourced:

```
**Error**: validation.sh script not found at .mykit/scripts/validation.sh

This is a My Kit installation issue. Try:
1. Re-run installation: `curl -fsSL https://raw.githubusercontent.com/mayknxyz/my-kit/main/install.sh | bash`
2. Or run `/mykit.upgrade` if you have My Kit installed
```

### State.json Update Failure

If state.json cannot be written:

```
**Warning**: Could not update state.json

Validation completed but state was not saved. This may affect other commands like `/mykit.pr`.

Error: {error message}
```

Show warning but don't fail the command (validation still completed).

### Permission Issues

If files cannot be read:

```
**Error**: Permission denied reading files for validation

Check file permissions in:
- .mykit/scripts/
- .claude/commands/
- docs/

You may need to run: chmod -R u+r {directory}
```

---

## Notes

- Validation is non-destructive (read-only operation)
- Missing tools cause warnings, not errors (graceful degradation)
- Results are stored in state.json for `/mykit.pr` to check
- Force flag support will be added in `/mykit.commit` and `/mykit.pr` commands

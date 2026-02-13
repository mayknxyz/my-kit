#!/usr/bin/env bash
#
# validation.sh - Code quality validation functions for My Kit
#
# DESCRIPTION:
#   Provides validation functions for shell scripts and markdown files.
#   Checks for shellcheck and markdownlint availability, runs validation,
#   aggregates results, and formats output for user display.
#
# USAGE:
#   source $HOME/.claude/skills/mykit/references/scripts/validation.sh
#   check_tool_available "shellcheck"
#   validate_shell_scripts
#   validate_markdown
#
# EXIT CODES:
#   0  Validation passed or warnings only
#   1  Validation failed with errors
#
# REQUIREMENTS:
#   - Bash 4.0+
#   - shellcheck (optional, warns if missing)
#   - markdownlint or markdownlint-cli2 (optional, warns if missing)
#

set -euo pipefail

# Script directory and paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# Validation results (populated by validation functions)
declare -a VALIDATION_ERRORS=()
declare -a VALIDATION_WARNINGS=()
declare -i VALIDATION_FILES_CHECKED=0

#######################################
# Check if a command-line tool is available
# Globals:
#   None
# Arguments:
#   $1 - Tool name to check
# Outputs:
#   None
# Returns:
#   0 if available, 1 if not
#######################################
check_tool_available() {
  local tool="$1"
  command -v "$tool" &>/dev/null
}

#######################################
# Check if shellcheck is available and get version
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Writes version info to stdout if available
# Returns:
#   0 if available, 1 if not
#######################################
check_shellcheck() {
  if check_tool_available "shellcheck"; then
    local version
    version=$(shellcheck --version | grep -oP 'version: \K[0-9.]+' || echo "unknown")
    echo "shellcheck version $version"
    return 0
  else
    return 1
  fi
}

#######################################
# Check if markdownlint is available and get version
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Writes version info to stdout if available
# Returns:
#   0 if available, 1 if not
#######################################
check_markdownlint() {
  # Try markdownlint-cli2 first, then markdownlint-cli
  if check_tool_available "markdownlint-cli2"; then
    local version
    version=$(markdownlint-cli2 --version 2>/dev/null || echo "unknown")
    echo "markdownlint-cli2 version $version"
    return 0
  elif check_tool_available "markdownlint"; then
    local version
    version=$(markdownlint --version 2>/dev/null || echo "unknown")
    echo "markdownlint version $version"
    return 0
  else
    return 1
  fi
}

#######################################
# Validate shell scripts using shellcheck
# Globals:
#   VALIDATION_ERRORS (modified)
#   VALIDATION_WARNINGS (modified)
#   VALIDATION_FILES_CHECKED (modified)
#   REPO_ROOT
# Arguments:
#   None
# Outputs:
#   Writes validation progress to stdout
# Returns:
#   0 if validation passed, 1 if errors found
#######################################
validate_shell_scripts() {
  local scripts_dir="$HOME/.claude/skills/mykit/references/scripts"
  local exit_code=0

  # Check if shellcheck is available
  if ! check_tool_available "shellcheck"; then
    VALIDATION_WARNINGS+=("shellcheck not found - skipping shell script validation")
    echo "⚠️  shellcheck not found - install with: brew install shellcheck (macOS) or apt-get install shellcheck (Linux)"
    return 0
  fi

  # Find all .sh files in scripts directory
  local -a script_files=()
  if [[ -d "$scripts_dir" ]]; then
    while IFS= read -r -d '' file; do
      script_files+=("$file")
    done < <(find "$scripts_dir" -name "*.sh" -type f -print0)
  fi

  if [[ ${#script_files[@]} -eq 0 ]]; then
    echo "No shell scripts found to validate"
    return 0
  fi

  echo "Validating ${#script_files[@]} shell script(s)..."

  # Run shellcheck on each file
  for script in "${script_files[@]}"; do
    ((VALIDATION_FILES_CHECKED++))
    local filename
    filename=$(basename "$script")

    local issues
    issues=$(shellcheck --severity=warning "$script" 2>&1) || true
    if grep -q "^In" <<< "$issues"; then
      # Issues were found by shellcheck
      VALIDATION_ERRORS+=("$filename: shellcheck issues found")
      echo "  ❌ $filename - issues found"
      # Add detailed output to errors
      while IFS= read -r line; do
        VALIDATION_ERRORS+=("    $line")
      done <<< "$issues"
      exit_code=1
    else
      echo "  ✓ $filename"
    fi
  done

  return $exit_code
}

#######################################
# Validate markdown files using markdownlint
# Globals:
#   VALIDATION_ERRORS (modified)
#   VALIDATION_WARNINGS (modified)
#   VALIDATION_FILES_CHECKED (modified)
#   REPO_ROOT
# Arguments:
#   None
# Outputs:
#   Writes validation progress to stdout
# Returns:
#   0 if validation passed, 1 if errors found
#######################################
validate_markdown() {
  local exit_code=0
  local markdownlint_cmd=""

  # Determine which markdownlint command to use
  if check_tool_available "markdownlint-cli2"; then
    markdownlint_cmd="markdownlint-cli2"
  elif check_tool_available "markdownlint"; then
    markdownlint_cmd="markdownlint"
  else
    VALIDATION_WARNINGS+=("markdownlint not found - skipping markdown validation")
    echo "⚠️  markdownlint not found - install with: npm install -g markdownlint-cli2"
    return 0
  fi

  # Paths to validate
  local -a paths_to_check=(
    "$REPO_ROOT/.claude/commands"
    "$REPO_ROOT/docs"
    "$REPO_ROOT/specs"
    "$REPO_ROOT/README.md"
    "$REPO_ROOT/CLAUDE.md"
    "$REPO_ROOT/CHANGELOG.md"
  )

  # Find all markdown files
  local -a markdown_files=()
  for path in "${paths_to_check[@]}"; do
    if [[ -d "$path" ]]; then
      while IFS= read -r -d '' file; do
        markdown_files+=("$file")
      done < <(find "$path" -name "*.md" -type f -print0)
    elif [[ -f "$path" ]]; then
      markdown_files+=("$path")
    fi
  done

  if [[ ${#markdown_files[@]} -eq 0 ]]; then
    echo "No markdown files found to validate"
    return 0
  fi

  echo "Validating ${#markdown_files[@]} markdown file(s)..."

  # Run markdownlint on each file
  for mdfile in "${markdown_files[@]}"; do
    ((VALIDATION_FILES_CHECKED++))
    local filename
    filename=$(basename "$mdfile")

    # Run markdownlint and capture output
    local issues
    if issues=$($markdownlint_cmd "$mdfile" 2>&1); then
      echo "  ✓ $filename"
    else
      # markdownlint found issues
      VALIDATION_ERRORS+=("$filename: markdownlint issues found")
      echo "  ❌ $filename - issues found"
      # Add detailed output to errors
      while IFS= read -r line; do
        [[ -n "$line" ]] && VALIDATION_ERRORS+=("    $line")
      done <<< "$issues"
      exit_code=1
    fi
  done

  return $exit_code
}

#######################################
# Aggregate validation results from all checks
# Globals:
#   VALIDATION_ERRORS (read)
#   VALIDATION_WARNINGS (read)
# Arguments:
#   None
# Outputs:
#   None
# Returns:
#   0 if no errors, 1 if errors found
#######################################
aggregate_results() {
  if [[ ${#VALIDATION_ERRORS[@]} -gt 0 ]]; then
    return 1
  else
    return 0
  fi
}

#######################################
# Format validation output for display
# Globals:
#   VALIDATION_ERRORS (read)
#   VALIDATION_WARNINGS (read)
#   VALIDATION_FILES_CHECKED (read)
# Arguments:
#   None
# Outputs:
#   Writes formatted summary to stdout
# Returns:
#   0 always
#######################################
format_validation_output() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Validation Summary"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Files checked: $VALIDATION_FILES_CHECKED"
  echo "Warnings: ${#VALIDATION_WARNINGS[@]}"
  echo "Errors: ${#VALIDATION_ERRORS[@]}"
  echo ""

  # Display warnings
  if [[ ${#VALIDATION_WARNINGS[@]} -gt 0 ]]; then
    echo "Warnings:"
    for warning in "${VALIDATION_WARNINGS[@]}"; do
      echo "  ⚠️  $warning"
    done
    echo ""
  fi

  # Display errors
  if [[ ${#VALIDATION_ERRORS[@]} -gt 0 ]]; then
    echo "Errors:"
    for error in "${VALIDATION_ERRORS[@]}"; do
      # Check if error is indented detail line
      if [[ "$error" == "    "* ]]; then
        echo "$error"
      else
        echo "  ❌ $error"
      fi
    done
    echo ""
    echo "❌ Validation failed"
    return 1
  else
    echo "✅ Validation passed"
    return 0
  fi
}

#######################################
# Reset validation state for new run
# Globals:
#   VALIDATION_ERRORS (modified)
#   VALIDATION_WARNINGS (modified)
#   VALIDATION_FILES_CHECKED (modified)
# Arguments:
#   None
# Outputs:
#   None
# Returns:
#   0 always
#######################################
reset_validation_state() {
  VALIDATION_ERRORS=()
  VALIDATION_WARNINGS=()
  VALIDATION_FILES_CHECKED=0
}

#######################################
# Run all validation checks
# Globals:
#   All validation globals (via called functions)
# Arguments:
#   None
# Outputs:
#   Writes validation results to stdout
# Returns:
#   0 if all validations passed, 1 if any failed
#######################################
run_all_validations() {
  reset_validation_state

  # Run validations
  validate_shell_scripts || true
  echo ""
  validate_markdown || true

  # Aggregate and format
  aggregate_results || return 1
  format_validation_output

  return 0
}

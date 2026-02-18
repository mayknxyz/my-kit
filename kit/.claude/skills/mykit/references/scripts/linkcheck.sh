#!/usr/bin/env bash
#
# linkcheck.sh - Link checking functions for My Kit
#
# DESCRIPTION:
#   Provides link checking functions using lychee and linkinator to detect
#   broken links in markdown, HTML, and other documentation files.
#
# USAGE:
#   source $HOME/.claude/skills/mykit/references/scripts/linkcheck.sh
#   check_lychee
#   check_linkinator
#   run_all_link_checks
#
# EXIT CODES:
#   0  All links valid (no broken links detected)
#   1  Broken links detected or error
#
# REQUIREMENTS:
#   - Bash 4.0+
#   - lychee (optional, warns if missing)
#   - linkinator (optional, warns if missing)
#

set -euo pipefail

# Paths
LINKCHECK_REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# Link check results (populated by scan functions)
declare -a LINKCHECK_ERRORS=()
declare -a LINKCHECK_WARNINGS=()
declare -i LINKCHECK_FILES_CHECKED=0

#######################################
# Check if lychee is available and get version
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Writes version info to stdout if available
# Returns:
#   0 if available, 1 if not
#######################################
check_lychee() {
  if command -v lychee &>/dev/null; then
    local version
    version=$(lychee --version 2>/dev/null || echo "unknown")
    echo "$version"
    return 0
  else
    return 1
  fi
}

#######################################
# Check if linkinator is available and get version
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Writes version info to stdout if available
# Returns:
#   0 if available, 1 if not
#######################################
check_linkinator() {
  if command -v linkinator &>/dev/null; then
    local version
    version=$(linkinator --version 2>/dev/null || echo "unknown")
    echo "linkinator version $version"
    return 0
  else
    return 1
  fi
}

#######################################
# Run link check using lychee
# Globals:
#   LINKCHECK_ERRORS (modified)
#   LINKCHECK_WARNINGS (modified)
#   LINKCHECK_FILES_CHECKED (modified)
#   LINKCHECK_REPO_ROOT
# Arguments:
#   None
# Outputs:
#   Writes scan progress to stdout
# Returns:
#   0 if scan passed, 1 if broken links detected
#######################################
run_lychee_scan() {
  local exit_code=0

  if ! command -v lychee &>/dev/null; then
    LINKCHECK_WARNINGS+=("lychee not found - skipping lychee scan")
    echo "  lychee not found - install with:"
    echo "    pacman -S lychee (Arch)"
    echo "    brew install lychee (macOS)"
    echo "    cargo install lychee (Cargo)"
    return 0
  fi

  echo "Scanning links with lychee..."

  local scan_output
  if scan_output=$(lychee --no-progress "$LINKCHECK_REPO_ROOT" 2>&1); then
    echo "  All links valid (lychee)"
  else
    local lychee_exit=$?
    # Exit code 2 = broken links found, 1 = other error
    if [[ $lychee_exit -eq 2 ]]; then
      LINKCHECK_ERRORS+=("Broken links detected by lychee")
      echo "  Broken links detected (lychee)"
      while IFS= read -r line; do
        [[ -n "$line" ]] && LINKCHECK_ERRORS+=("    $line")
      done <<< "$scan_output"
      exit_code=1
    else
      # Could be exit code 1 (also broken links) or other error
      LINKCHECK_ERRORS+=("lychee found issues (exit code: $lychee_exit)")
      echo "  lychee found issues (exit code: $lychee_exit)"
      while IFS= read -r line; do
        [[ -n "$line" ]] && LINKCHECK_ERRORS+=("    $line")
      done <<< "$scan_output"
      exit_code=1
    fi
  fi

  return $exit_code
}

#######################################
# Run link check using linkinator
# Globals:
#   LINKCHECK_ERRORS (modified)
#   LINKCHECK_WARNINGS (modified)
#   LINKCHECK_FILES_CHECKED (modified)
#   LINKCHECK_REPO_ROOT
# Arguments:
#   None
# Outputs:
#   Writes scan progress to stdout
# Returns:
#   0 if scan passed, 1 if broken links detected
#######################################
run_linkinator_scan() {
  local exit_code=0

  if ! command -v linkinator &>/dev/null; then
    LINKCHECK_WARNINGS+=("linkinator not found - skipping linkinator scan")
    echo "  linkinator not found - install with:"
    echo "    npm install -g linkinator"
    echo "    bun install -g linkinator"
    return 0
  fi

  echo "Scanning links with linkinator..."

  local scan_output
  if scan_output=$(linkinator --markdown --recurse "$LINKCHECK_REPO_ROOT" 2>&1); then
    echo "  All links valid (linkinator)"
  else
    LINKCHECK_ERRORS+=("Broken links detected by linkinator")
    echo "  Broken links detected (linkinator)"
    while IFS= read -r line; do
      [[ -n "$line" ]] && LINKCHECK_ERRORS+=("    $line")
    done <<< "$scan_output"
    exit_code=1
  fi

  return $exit_code
}

#######################################
# Format link check output for display
# Globals:
#   LINKCHECK_ERRORS (read)
#   LINKCHECK_WARNINGS (read)
# Arguments:
#   None
# Outputs:
#   Writes formatted summary to stdout
# Returns:
#   0 if no errors, 1 if errors found
#######################################
format_linkcheck_output() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Link Check Summary"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Warnings: ${#LINKCHECK_WARNINGS[@]}"
  echo "Errors: ${#LINKCHECK_ERRORS[@]}"
  echo ""

  # Display warnings
  if [[ ${#LINKCHECK_WARNINGS[@]} -gt 0 ]]; then
    echo "Warnings:"
    for warning in "${LINKCHECK_WARNINGS[@]}"; do
      echo "  $warning"
    done
    echo ""
  fi

  # Display errors
  if [[ ${#LINKCHECK_ERRORS[@]} -gt 0 ]]; then
    echo "Errors:"
    for error in "${LINKCHECK_ERRORS[@]}"; do
      if [[ "$error" == "    "* ]]; then
        echo "$error"
      else
        echo "  $error"
      fi
    done
    echo ""
    echo "Link check failed"
    return 1
  else
    echo "Link check passed"
    return 0
  fi
}

#######################################
# Reset link check state for new run
# Globals:
#   LINKCHECK_ERRORS (modified)
#   LINKCHECK_WARNINGS (modified)
#   LINKCHECK_FILES_CHECKED (modified)
# Arguments:
#   None
# Outputs:
#   None
# Returns:
#   0 always
#######################################
reset_linkcheck_state() {
  LINKCHECK_ERRORS=()
  LINKCHECK_WARNINGS=()
  LINKCHECK_FILES_CHECKED=0
}

#######################################
# Run full link check with both tools
# Globals:
#   All linkcheck globals (via called functions)
# Arguments:
#   None
# Outputs:
#   Writes link check results to stdout
# Returns:
#   0 if all checks passed, 1 if any failed
#######################################
run_all_link_checks() {
  reset_linkcheck_state

  # Run both scanners
  run_lychee_scan || true
  echo ""
  run_linkinator_scan || true

  # Format and return
  if [[ ${#LINKCHECK_ERRORS[@]} -gt 0 ]]; then
    format_linkcheck_output
    return 1
  else
    format_linkcheck_output
    return 0
  fi
}

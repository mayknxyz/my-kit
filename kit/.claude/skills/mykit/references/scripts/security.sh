#!/usr/bin/env bash
#
# security.sh - Security scanning functions for My Kit
#
# DESCRIPTION:
#   Provides security scanning functions using gitleaks to detect
#   leaked secrets, API keys, tokens, and passwords in the working directory.
#
# USAGE:
#   source $HOME/.claude/skills/mykit/references/scripts/security.sh
#   check_gitleaks
#   run_security_scan
#
# EXIT CODES:
#   0  Scan passed (no secrets detected)
#   1  Scan failed (secrets detected or error)
#
# REQUIREMENTS:
#   - Bash 4.0+
#   - gitleaks (optional, warns if missing)
#

set -euo pipefail

# Paths
SECURITY_REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# Security scan results (populated by scan functions)
declare -a SECURITY_ERRORS=()
declare -a SECURITY_WARNINGS=()

#######################################
# Check if gitleaks is available and get version
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Writes version info to stdout if available
# Returns:
#   0 if available, 1 if not
#######################################
check_gitleaks() {
  if command -v gitleaks &>/dev/null; then
    local version
    version=$(gitleaks version 2>/dev/null || echo "unknown")
    echo "gitleaks version $version"
    return 0
  else
    return 1
  fi
}

#######################################
# Run security scan using gitleaks
# Globals:
#   SECURITY_ERRORS (modified)
#   SECURITY_WARNINGS (modified)
#   SECURITY_REPO_ROOT
# Arguments:
#   None
# Outputs:
#   Writes scan progress to stdout
# Returns:
#   0 if scan passed, 1 if secrets detected
#######################################
run_security_scan() {
  local exit_code=0

  # Check if gitleaks is available
  if ! command -v gitleaks &>/dev/null; then
    SECURITY_WARNINGS+=("gitleaks not found - skipping security scan")
    echo "⚠️  gitleaks not found - install with:"
    echo "    brew install gitleaks (macOS)"
    echo "    pacman -S gitleaks (Arch)"
    echo "    https://github.com/gitleaks/gitleaks#installing"
    return 0
  fi

  echo "Scanning for secrets with gitleaks..."

  # Run gitleaks on the working directory
  local scan_output
  if scan_output=$(gitleaks detect --source "$SECURITY_REPO_ROOT" --no-banner 2>&1); then
    echo "  ✓ No secrets detected"
  else
    local gitleaks_exit=$?
    # Exit code 1 = leaks found, other codes = error
    if [[ $gitleaks_exit -eq 1 ]]; then
      SECURITY_ERRORS+=("Secrets detected in repository")
      echo "  ❌ Secrets detected"
      while IFS= read -r line; do
        [[ -n "$line" ]] && SECURITY_ERRORS+=("    $line")
      done <<< "$scan_output"
      exit_code=1
    else
      SECURITY_WARNINGS+=("gitleaks encountered an error (exit code: $gitleaks_exit)")
      echo "  ⚠️  gitleaks error (exit code: $gitleaks_exit)"
    fi
  fi

  return $exit_code
}

#######################################
# Format security scan output for display
# Globals:
#   SECURITY_ERRORS (read)
#   SECURITY_WARNINGS (read)
# Arguments:
#   None
# Outputs:
#   Writes formatted summary to stdout
# Returns:
#   0 if no errors, 1 if errors found
#######################################
format_security_output() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Security Scan Summary"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Warnings: ${#SECURITY_WARNINGS[@]}"
  echo "Errors: ${#SECURITY_ERRORS[@]}"
  echo ""

  # Display warnings
  if [[ ${#SECURITY_WARNINGS[@]} -gt 0 ]]; then
    echo "Warnings:"
    for warning in "${SECURITY_WARNINGS[@]}"; do
      echo "  ⚠️  $warning"
    done
    echo ""
  fi

  # Display errors
  if [[ ${#SECURITY_ERRORS[@]} -gt 0 ]]; then
    echo "Errors:"
    for error in "${SECURITY_ERRORS[@]}"; do
      if [[ "$error" == "    "* ]]; then
        echo "$error"
      else
        echo "  ❌ $error"
      fi
    done
    echo ""
    echo "❌ Security scan failed"
    return 1
  else
    echo "✅ Security scan passed"
    return 0
  fi
}

#######################################
# Reset security state for new run
# Globals:
#   SECURITY_ERRORS (modified)
#   SECURITY_WARNINGS (modified)
# Arguments:
#   None
# Outputs:
#   None
# Returns:
#   0 always
#######################################
reset_security_state() {
  SECURITY_ERRORS=()
  SECURITY_WARNINGS=()
}

#######################################
# Run full security check
# Globals:
#   All security globals (via called functions)
# Arguments:
#   None
# Outputs:
#   Writes security results to stdout
# Returns:
#   0 if scan passed, 1 if failed
#######################################
run_all_security_checks() {
  reset_security_state

  # Run scan
  run_security_scan || true

  # Format and return
  if [[ ${#SECURITY_ERRORS[@]} -gt 0 ]]; then
    format_security_output
    return 1
  else
    format_security_output
    return 0
  fi
}

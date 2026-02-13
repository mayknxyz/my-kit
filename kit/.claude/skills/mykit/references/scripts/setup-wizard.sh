#!/usr/bin/env bash
#
# setup-wizard.sh - Interactive setup wizard for My Kit configuration
#
# DESCRIPTION:
#   Guides users through configuring My Kit preferences via an interactive
#   CLI flow. Collects GitHub auth status, default branch, PR preferences,
#   PR title template, auto-branch creation, validation settings, and
#   release settings. Writes configuration to .mykit/config.json using
#   atomic file operations.
#
# USAGE:
#   ./setup-wizard.sh [run|preview|--help]
#
# ARGUMENTS:
#   run       Launch the interactive wizard to configure settings
#   preview   Show current configuration status (default if no argument)
#   --help    Display this help message
#
# EXIT CODES:
#   0  Success
#   1  Error or user cancelled
#
# FILES:
#   .mykit/config.json  - Generated configuration file
#
# REQUIREMENTS:
#   - Bash 4.0+
#   - git (for branch detection)
#   - gh CLI (optional, for GitHub authentication check)
#

set -euo pipefail

# Script directory and paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
CONFIG_FILE="$REPO_ROOT/.mykit/config.json"
CONFIG_DIR="$REPO_ROOT/.mykit"

# Temporary file for atomic writes (set in main)
TEMP_CONFIG=""

# Default values
DEFAULT_BRANCH="main"
DEFAULT_AUTO_ASSIGN=true
DEFAULT_DRAFT_MODE=false
DEFAULT_AUTO_FIX=true
DEFAULT_VERSION_PREFIX="v"
DEFAULT_TITLE_TEMPLATE="{version}: {title} (#{issue})"
DEFAULT_AUTO_CREATE_BRANCH=true

# Current config values (populated by read_existing_config)
CURRENT_BRANCH=""
CURRENT_AUTO_ASSIGN=""
CURRENT_DRAFT_MODE=""
CURRENT_TITLE_TEMPLATE=""
CURRENT_AUTO_CREATE_BRANCH=""
CURRENT_AUTO_FIX=""
CURRENT_VERSION_PREFIX=""
CURRENT_GH_AUTH=""

#######################################
# Check if GitHub CLI is authenticated
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Writes warning to stderr if not authenticated
# Returns:
#   0 if authenticated, 1 if not
#######################################
check_gh_auth() {
  if command -v gh &>/dev/null && gh auth status &>/dev/null; then
    return 0
  else
    return 1
  fi
}

#######################################
# Detect the default branch for the repository
# Globals:
#   DEFAULT_BRANCH
# Arguments:
#   None
# Outputs:
#   Writes detected branch name to stdout
# Returns:
#   0 always (uses fallbacks)
#######################################
detect_default_branch() {
  local branch

  # Try to get from remote HEAD
  branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')

  if [[ -z "$branch" ]]; then
    # Fallback: check if main or master exists locally
    if git show-ref --verify --quiet refs/heads/main 2>/dev/null; then
      branch="main"
    elif git show-ref --verify --quiet refs/heads/master 2>/dev/null; then
      branch="master"
    else
      branch="$DEFAULT_BRANCH"
    fi
  fi

  echo "$branch"
}

#######################################
# Prompt user for a boolean (yes/no) selection
# Globals:
#   None
# Arguments:
#   $1 - Prompt message
#   $2 - Default value (true/false)
# Outputs:
#   Writes prompt to stderr, result to stdout
# Returns:
#   0 on success, 1 on invalid input after retries
#######################################
prompt_boolean() {
  local prompt="$1"
  local default="$2"
  local default_hint
  local choice

  if [[ "$default" == "true" ]]; then
    default_hint="Y/n"
  else
    default_hint="y/N"
  fi

  while true; do
    read -rp "$prompt [$default_hint]: " choice
    choice="${choice:-}"

    # Handle empty input (use default)
    if [[ -z "$choice" ]]; then
      echo "$default"
      return 0
    fi

    # Handle yes/no variations
    case "${choice,,}" in
      y|yes)
        echo "true"
        return 0
        ;;
      n|no)
        echo "false"
        return 0
        ;;
      *)
        echo "Please enter 'y' or 'n'" >&2
        ;;
    esac
  done
}

#######################################
# Prompt user for a string input with default
# Globals:
#   None
# Arguments:
#   $1 - Prompt message
#   $2 - Default value
# Outputs:
#   Writes prompt to stderr, result to stdout
# Returns:
#   0 always
#######################################
prompt_string() {
  local prompt="$1"
  local default="$2"
  local value

  if [[ -n "$default" ]]; then
    read -rp "$prompt [$default]: " value
    value="${value:-$default}"
  else
    read -rp "$prompt: " value
  fi

  echo "$value"
}

#######################################
# Write configuration to file atomically
# Globals:
#   CONFIG_FILE, CONFIG_DIR, TEMP_CONFIG
# Arguments:
#   $1 - gh_authenticated (true/false)
#   $2 - default_branch
#   $3 - auto_assign (true/false)
#   $4 - draft_mode (true/false)
#   $5 - title_template
#   $6 - auto_create_branch (true/false)
#   $7 - auto_fix (true/false)
#   $8 - version_prefix
# Outputs:
#   Writes status to stderr
# Returns:
#   0 on success, 1 on failure
#######################################
write_config() {
  local gh_authenticated="$1"
  local default_branch="$2"
  local auto_assign="$3"
  local draft_mode="$4"
  local title_template="$5"
  local auto_create_branch="$6"
  local auto_fix="$7"
  local version_prefix="$8"

  # Escape double quotes in title template for JSON safety
  title_template="${title_template//\"/\\\"}"

  # Ensure config directory exists
  mkdir -p "$CONFIG_DIR"

  # Create temp file for atomic write
  TEMP_CONFIG=$(mktemp)

  # Generate JSON config
  cat > "$TEMP_CONFIG" << EOF
{
  "version": "1.0.0",
  "github": {
    "authenticated": $gh_authenticated
  },
  "defaults": {
    "branch": "$default_branch"
  },
  "pr": {
    "autoAssign": $auto_assign,
    "draftMode": $draft_mode,
    "titleTemplate": "$title_template"
  },
  "specify": {
    "autoCreateBranch": $auto_create_branch
  },
  "validation": {
    "autoFix": $auto_fix
  },
  "release": {
    "versionPrefix": "$version_prefix"
  }
}
EOF

  # Validate JSON before moving (basic check)
  if ! grep -q '"github"' "$TEMP_CONFIG" || ! grep -q '"defaults"' "$TEMP_CONFIG"; then
    echo "Error: Generated config is invalid" >&2
    rm -f "$TEMP_CONFIG"
    return 1
  fi

  # Atomic move
  mv "$TEMP_CONFIG" "$CONFIG_FILE"
  TEMP_CONFIG=""

  return 0
}

#######################################
# Read existing configuration for pre-population
# Globals:
#   CONFIG_FILE, CURRENT_* variables
# Arguments:
#   None
# Outputs:
#   None (sets global variables)
# Returns:
#   0 if config exists and was read, 1 if no config
#######################################
read_existing_config() {
  if [[ ! -f "$CONFIG_FILE" ]]; then
    return 1
  fi

  # Extract values using grep/sed (avoiding jq dependency)
  local config_content
  config_content=$(<"$CONFIG_FILE") || return 1
  CURRENT_BRANCH=$(echo "$config_content" | grep -o '"branch": *"[^"]*"' | head -1 | cut -d'"' -f4) || true
  CURRENT_AUTO_ASSIGN=$(echo "$config_content" | grep -o '"autoAssign": *[^,}]*' | head -1 | sed 's/.*: *//' | tr -d ' ') || true
  CURRENT_DRAFT_MODE=$(echo "$config_content" | grep -o '"draftMode": *[^,}]*' | head -1 | sed 's/.*: *//' | tr -d ' ') || true
  CURRENT_TITLE_TEMPLATE=$(echo "$config_content" | grep -o '"titleTemplate": *"[^"]*"' | head -1 | cut -d'"' -f4) || true
  CURRENT_AUTO_CREATE_BRANCH=$(echo "$config_content" | grep -o '"autoCreateBranch": *[^,}]*' | head -1 | sed 's/.*: *//' | tr -d ' ') || true
  CURRENT_AUTO_FIX=$(echo "$config_content" | grep -o '"autoFix": *[^,}]*' | head -1 | sed 's/.*: *//' | tr -d ' ') || true
  CURRENT_VERSION_PREFIX=$(echo "$config_content" | grep -o '"versionPrefix": *"[^"]*"' | head -1 | cut -d'"' -f4) || true
  CURRENT_GH_AUTH=$(echo "$config_content" | grep -o '"authenticated": *[^,}]*' | head -1 | sed 's/.*: *//' | tr -d ' ') || true

  return 0
}

#######################################
# Clean up temporary files on exit
# Globals:
#   TEMP_CONFIG
# Arguments:
#   None
# Outputs:
#   None
# Returns:
#   None
#######################################
cleanup() {
  if [[ -n "$TEMP_CONFIG" && -f "$TEMP_CONFIG" ]]; then
    rm -f "$TEMP_CONFIG"
  fi
}

#######################################
# Run the interactive setup wizard
# Globals:
#   Multiple config-related globals
# Arguments:
#   None
# Outputs:
#   Interactive prompts and status messages
# Returns:
#   0 on success, 1 on cancel/error
#######################################
run_wizard() {
  local gh_authenticated
  local detected_branch
  local default_branch
  local auto_assign
  local draft_mode
  local title_template
  local auto_create_branch
  local auto_fix
  local version_prefix
  local config_existed=false

  echo ""
  echo "╔══════════════════════════════════════════╗"
  echo "║       My Kit Setup Wizard                ║"
  echo "╚══════════════════════════════════════════╝"
  echo ""

  # Check if config exists for pre-population
  if read_existing_config; then
    config_existed=true
    echo "Existing configuration found. Current values will be shown as defaults."
    echo ""
  fi

  # Step 1: GitHub Auth Check
  echo "─── Step 1/7: GitHub Authentication ───"
  if check_gh_auth; then
    gh_authenticated=true
    echo "✓ GitHub CLI is authenticated"
  else
    gh_authenticated=false
    echo "⚠ GitHub CLI not authenticated. Some features will be limited."
    echo "  Run 'gh auth login' to enable GitHub integration."
  fi
  echo ""

  # Step 2: Default Branch Detection
  echo "─── Step 2/7: Default Branch ───"
  detected_branch=$(detect_default_branch)

  if $config_existed && [[ -n "$CURRENT_BRANCH" ]]; then
    default_branch=$(prompt_string "Default branch for PRs" "$CURRENT_BRANCH")
  else
    echo "Detected default branch: $detected_branch"
    default_branch=$(prompt_string "Default branch for PRs" "$detected_branch")
  fi
  echo ""

  # Step 3: PR Preferences
  echo "─── Step 3/7: PR Preferences ───"

  if $config_existed && [[ -n "$CURRENT_AUTO_ASSIGN" ]]; then
    auto_assign=$(prompt_boolean "Auto-assign yourself to PRs?" "$CURRENT_AUTO_ASSIGN")
  else
    auto_assign=$(prompt_boolean "Auto-assign yourself to PRs?" "$DEFAULT_AUTO_ASSIGN")
  fi

  if $config_existed && [[ -n "$CURRENT_DRAFT_MODE" ]]; then
    draft_mode=$(prompt_boolean "Create PRs as drafts by default?" "$CURRENT_DRAFT_MODE")
  else
    draft_mode=$(prompt_boolean "Create PRs as drafts by default?" "$DEFAULT_DRAFT_MODE")
  fi
  echo ""

  # Step 4: PR Title Template
  echo "─── Step 4/7: PR Title Template ───"
  echo "Placeholders: {version}, {title}, {issue}"
  echo "Example output: v0.17.0: Add dark mode (#42)"

  if $config_existed && [[ -n "$CURRENT_TITLE_TEMPLATE" ]]; then
    title_template=$(prompt_string "PR title template" "$CURRENT_TITLE_TEMPLATE")
  else
    title_template=$(prompt_string "PR title template" "$DEFAULT_TITLE_TEMPLATE")
  fi
  echo ""

  # Step 5: Auto-Branch on Specify
  echo "─── Step 5/7: Auto-Branch Creation ───"
  echo "When running /mykit.specify on main, auto-create a feature branch"

  if $config_existed && [[ -n "$CURRENT_AUTO_CREATE_BRANCH" ]]; then
    auto_create_branch=$(prompt_boolean "Auto-create branch on specify?" "$CURRENT_AUTO_CREATE_BRANCH")
  else
    auto_create_branch=$(prompt_boolean "Auto-create branch on specify?" "$DEFAULT_AUTO_CREATE_BRANCH")
  fi
  echo ""

  # Step 6: Validation Settings
  echo "─── Step 6/7: Validation Settings ───"

  if $config_existed && [[ -n "$CURRENT_AUTO_FIX" ]]; then
    auto_fix=$(prompt_boolean "Auto-fix linting issues?" "$CURRENT_AUTO_FIX")
  else
    auto_fix=$(prompt_boolean "Auto-fix linting issues?" "$DEFAULT_AUTO_FIX")
  fi
  echo ""

  # Step 7: Release Settings
  echo "─── Step 7/7: Release Settings ───"
  echo "Version prefix appears before version numbers (e.g., 'v' for v1.0.0, or empty for 1.0.0)"

  if $config_existed && [[ -n "$CURRENT_VERSION_PREFIX" || "$CURRENT_VERSION_PREFIX" == "" ]]; then
    # Use existing value even if empty
    local current_prefix="${CURRENT_VERSION_PREFIX:-}"
    if [[ -z "$current_prefix" ]]; then
      version_prefix=$(prompt_string "Version prefix (empty for none, or 'v')" "")
    else
      version_prefix=$(prompt_string "Version prefix (empty for none, or 'v')" "$current_prefix")
    fi
  else
    version_prefix=$(prompt_string "Version prefix (empty for none, or 'v')" "$DEFAULT_VERSION_PREFIX")
  fi

  # Validate version prefix
  if [[ "$version_prefix" != "" && "$version_prefix" != "v" ]]; then
    echo "⚠ Non-standard prefix '$version_prefix'. Common values are 'v' or empty."
  fi
  echo ""

  # Write configuration
  echo "─── Writing Configuration ───"
  if write_config "$gh_authenticated" "$default_branch" "$auto_assign" "$draft_mode" "$title_template" "$auto_create_branch" "$auto_fix" "$version_prefix"; then
    echo ""
    if $config_existed; then
      echo "✓ Configuration updated: $CONFIG_FILE"
    else
      echo "✓ Configuration created: $CONFIG_FILE"
    fi
    echo ""
    echo "Next steps:"
    echo "  • Run /mykit.status to see your configuration"
    echo "  • Run /mykit.setup to preview settings"
    echo "  • Run /mykit.setup run to reconfigure"
    echo ""
    return 0
  else
    echo "✗ Failed to write configuration" >&2
    return 1
  fi
}

#######################################
# Show preview of current or default configuration
# Globals:
#   CONFIG_FILE, DEFAULT_* variables
# Arguments:
#   None
# Outputs:
#   Configuration preview
# Returns:
#   0 always
#######################################
show_preview() {
  local gh_status
  local branch
  local auto_assign
  local draft_mode
  local title_template
  local auto_create_branch
  local auto_fix
  local version_prefix

  echo ""
  echo "╔══════════════════════════════════════════╗"
  echo "║       My Kit Setup Preview               ║"
  echo "╚══════════════════════════════════════════╝"
  echo ""

  if read_existing_config; then
    echo "Configuration file: $CONFIG_FILE"
    echo ""

    # Use existing values
    if [[ "$CURRENT_GH_AUTH" == "true" ]]; then
      gh_status="✓ Authenticated"
    else
      gh_status="✗ Not authenticated"
    fi
    branch="$CURRENT_BRANCH"
    auto_assign="$CURRENT_AUTO_ASSIGN"
    draft_mode="$CURRENT_DRAFT_MODE"
    title_template="${CURRENT_TITLE_TEMPLATE:-<not set>}"
    auto_create_branch="${CURRENT_AUTO_CREATE_BRANCH:-<not set>}"
    auto_fix="$CURRENT_AUTO_FIX"
    version_prefix="${CURRENT_VERSION_PREFIX:-<empty>}"
  else
    echo "No configuration file found."
    echo "Showing default values that would be used:"
    echo ""

    # Show what would be detected/used
    if check_gh_auth; then
      gh_status="✓ Authenticated (detected)"
    else
      gh_status="✗ Not authenticated (detected)"
    fi
    branch=$(detect_default_branch)
    branch="$branch (detected)"
    auto_assign="$DEFAULT_AUTO_ASSIGN (default)"
    draft_mode="$DEFAULT_DRAFT_MODE (default)"
    title_template="$DEFAULT_TITLE_TEMPLATE (default)"
    auto_create_branch="$DEFAULT_AUTO_CREATE_BRANCH (default)"
    auto_fix="$DEFAULT_AUTO_FIX (default)"
    version_prefix="$DEFAULT_VERSION_PREFIX (default)"
  fi

  echo "Current Settings:"
  echo "─────────────────"
  echo "  GitHub Auth:    $gh_status"
  echo "  Default Branch: $branch"
  echo "  Auto-assign PR: $auto_assign"
  echo "  Draft Mode:     $draft_mode"
  echo "  Title Template: $title_template"
  echo "  Auto-Branch:    $auto_create_branch"
  echo "  Auto-fix:       $auto_fix"
  echo "  Version Prefix: $version_prefix"
  echo ""
  echo "Wizard Steps:"
  echo "─────────────"
  echo "  1. Check GitHub CLI authentication status"
  echo "  2. Detect/confirm default branch for PRs"
  echo "  3. Configure PR preferences (auto-assign, draft mode)"
  echo "  4. Configure PR title template (format with placeholders)"
  echo "  5. Configure auto-branch creation on specify"
  echo "  6. Configure validation settings (auto-fix)"
  echo "  7. Configure release settings (version prefix)"
  echo ""
  echo "To run the wizard: /mykit.setup run"
  echo ""
}

#######################################
# Display help message
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Help text
# Returns:
#   0 always
#######################################
show_help() {
  cat << 'EOF'
setup-wizard.sh - Interactive setup wizard for My Kit configuration

USAGE:
  ./setup-wizard.sh [run|preview|--help]

ARGUMENTS:
  run       Launch the interactive wizard to configure settings
  preview   Show current configuration status (default if no argument)
  --help    Display this help message

DESCRIPTION:
  Guides users through configuring My Kit preferences via an interactive
  CLI flow. The wizard collects:
    • GitHub CLI authentication status
    • Default branch for PRs
    • PR preferences (auto-assign, draft mode)
    • PR title template (format with placeholders)
    • Auto-branch creation on specify
    • Validation settings (auto-fix)
    • Release settings (version prefix)

  Configuration is saved to .mykit/config.json using atomic file operations
  to prevent corruption if interrupted.

EXAMPLES:
  ./setup-wizard.sh              # Preview current config (same as 'preview')
  ./setup-wizard.sh preview      # Preview current config
  ./setup-wizard.sh run          # Run the interactive wizard
  ./setup-wizard.sh --help       # Show this help message

EXIT CODES:
  0  Success
  1  Error or user cancelled

FILES:
  .mykit/config.json  - Generated configuration file
EOF
}

#######################################
# Handle partial config detection and offer completion
# Globals:
#   CONFIG_FILE, CURRENT_* variables
# Arguments:
#   None
# Outputs:
#   Warning message if partial config detected
# Returns:
#   0 if config is complete or doesn't exist, 1 if partial
#######################################
check_partial_config() {
  if [[ ! -f "$CONFIG_FILE" ]]; then
    return 0
  fi

  read_existing_config

  local missing=()

  [[ -z "$CURRENT_BRANCH" ]] && missing+=("branch")
  [[ -z "$CURRENT_AUTO_ASSIGN" ]] && missing+=("autoAssign")
  [[ -z "$CURRENT_DRAFT_MODE" ]] && missing+=("draftMode")
  [[ -z "$CURRENT_TITLE_TEMPLATE" ]] && missing+=("titleTemplate")
  [[ -z "$CURRENT_AUTO_CREATE_BRANCH" ]] && missing+=("autoCreateBranch")
  [[ -z "$CURRENT_AUTO_FIX" ]] && missing+=("autoFix")
  # versionPrefix can be empty string, so check differently
  if ! grep -q '"versionPrefix"' "$CONFIG_FILE" 2>/dev/null; then
    missing+=("versionPrefix")
  fi

  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "⚠ Partial configuration detected. Missing fields: ${missing[*]}" >&2
    echo "  Running the wizard will complete the configuration." >&2
    return 1
  fi

  return 0
}

#######################################
# Main entry point
# Globals:
#   None
# Arguments:
#   $1 - Action (run, preview, --help)
# Outputs:
#   Depends on action
# Returns:
#   0 on success, 1 on error
#######################################
main() {
  local action="${1:-preview}"

  # Set up trap for cleanup
  trap cleanup INT TERM EXIT

  case "$action" in
    run)
      check_partial_config || true  # Just warn, don't block
      run_wizard
      ;;
    preview)
      check_partial_config || true  # Just warn, don't block
      show_preview
      ;;
    --help|-h|help)
      show_help
      ;;
    *)
      echo "Error: Unknown action '$action'" >&2
      echo "Usage: setup-wizard.sh [run|preview|--help]" >&2
      exit 1
      ;;
  esac
}

# Run main with all arguments
main "$@"

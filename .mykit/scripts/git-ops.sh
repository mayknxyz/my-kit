#!/usr/bin/env bash
#
# git-ops.sh - Git operations and CHANGELOG management for My Kit
#
# DESCRIPTION:
#   Provides functions for git status checking, commit operations, and
#   CHANGELOG.md updates following conventional commit format and
#   Keep a Changelog standard.
#
# USAGE:
#   source .mykit/scripts/git-ops.sh
#   has_uncommitted_changes
#   parse_conventional_commit "feat(auth): add login"
#   update_changelog "feat" "add user authentication"
#
# EXIT CODES:
#   0  Success
#   1  Error or validation failure
#
# REQUIREMENTS:
#   - Bash 4.0+
#   - git
#

set -euo pipefail

# Script directory and paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CHANGELOG_FILE="$REPO_ROOT/CHANGELOG.md"

#######################################
# Check if there are uncommitted changes
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
# Returns:
#   0 if there are uncommitted changes, 1 if not
#######################################
has_uncommitted_changes() {
  [[ -n "$(git status --porcelain)" ]]
}

#######################################
# Get list of staged files
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Writes list of staged files to stdout
# Returns:
#   0 always
#######################################
get_staged_files() {
  git diff --cached --name-only
}

#######################################
# Get list of all changed files (staged + unstaged)
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Writes list of changed files to stdout
# Returns:
#   0 always
#######################################
get_changed_files() {
  git status --porcelain | awk '{print $2}'
}

#######################################
# Parse conventional commit message
# Format: type(scope): description
# Globals:
#   None
# Arguments:
#   $1 - Commit message to parse
# Outputs:
#   Writes JSON object with type, scope, description to stdout
# Returns:
#   0 if valid format, 1 if invalid
#######################################
parse_conventional_commit() {
  local message="$1"
  local pattern='^([a-z]+)(\([a-z0-9-]+\))?: (.+)$'

  if [[ "$message" =~ $pattern ]]; then
    local type="${BASH_REMATCH[1]}"
    local scope="${BASH_REMATCH[2]#(}"  # Remove leading (
    scope="${scope%)}"  # Remove trailing )
    local description="${BASH_REMATCH[3]}"

    echo "{\"type\":\"$type\",\"scope\":\"$scope\",\"description\":\"$description\"}"
    return 0
  else
    return 1
  fi
}

#######################################
# Determine CHANGELOG section from commit type
# Globals:
#   None
# Arguments:
#   $1 - Commit type (feat, fix, docs, etc.)
# Outputs:
#   Writes CHANGELOG section name to stdout
# Returns:
#   0 always
#######################################
determine_changelog_section() {
  local type="$1"

  case "$type" in
    feat)
      echo "Added"
      ;;
    fix)
      echo "Fixed"
      ;;
    docs)
      echo "Documentation"
      ;;
    refactor)
      echo "Changed"
      ;;
    test)
      echo "Testing"
      ;;
    chore|build|ci)
      echo "Maintenance"
      ;;
    perf)
      echo "Performance"
      ;;
    style)
      echo "Style"
      ;;
    *)
      echo "Changed"
      ;;
  esac
}

#######################################
# Update CHANGELOG.md with new entry
# Adds entry under [Unreleased] section in appropriate subsection
# Globals:
#   CHANGELOG_FILE
# Arguments:
#   $1 - Commit type (feat, fix, etc.)
#   $2 - Commit description
# Outputs:
#   Writes status to stdout
# Returns:
#   0 if updated, 1 if error
#######################################
update_changelog() {
  local type="$1"
  local description="$2"
  local section
  section=$(determine_changelog_section "$type")

  # Create CHANGELOG if it doesn't exist
  if [[ ! -f "$CHANGELOG_FILE" ]]; then
    cat > "$CHANGELOG_FILE" <<'EOF'
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

EOF
    echo "Created CHANGELOG.md"
  fi

  # Check if [Unreleased] section exists
  if ! grep -q "^## \[Unreleased\]" "$CHANGELOG_FILE"; then
    # Add [Unreleased] section after header
    local temp_file
    temp_file=$(mktemp)
    awk '
      /^# Changelog/ { print; header_found=1; next }
      header_found && /^$/ { print; print "## [Unreleased]\n"; header_found=0; next }
      { print }
    ' "$CHANGELOG_FILE" > "$temp_file"
    mv "$temp_file" "$CHANGELOG_FILE"
  fi

  # Find or create the section under [Unreleased]
  local temp_file
  temp_file=$(mktemp)
  local in_unreleased=0
  local section_found=0
  local entry_added=0

  while IFS= read -r line; do
    echo "$line" >> "$temp_file"

    # Track if we're in [Unreleased] section
    if [[ "$line" == "## [Unreleased]" ]]; then
      in_unreleased=1
      continue
    fi

    # If we hit another version section, we're done with [Unreleased]
    if [[ "$in_unreleased" -eq 1 ]] && [[ "$line" =~ ^##\ \[[0-9] ]]; then
      # Add section and entry before this version if not added yet
      if [[ "$entry_added" -eq 0 ]]; then
        echo "" >> "$temp_file"
        echo "### $section" >> "$temp_file"
        echo "- $description" >> "$temp_file"
        entry_added=1
      fi
      in_unreleased=0
      continue
    fi

    # If we're in [Unreleased] and find our section
    if [[ "$in_unreleased" -eq 1 ]] && [[ "$line" == "### $section" ]]; then
      section_found=1
      # Read next line (should be entry or empty)
      IFS= read -r next_line
      echo "- $description" >> "$temp_file"
      echo "$next_line" >> "$temp_file"
      entry_added=1
      continue
    fi
  done < "$CHANGELOG_FILE"

  # If we're still in [Unreleased] at EOF and haven't added entry
  if [[ "$in_unreleased" -eq 1 ]] && [[ "$entry_added" -eq 0 ]]; then
    echo "" >> "$temp_file"
    echo "### $section" >> "$temp_file"
    echo "- $description" >> "$temp_file"
    entry_added=1
  fi

  mv "$temp_file" "$CHANGELOG_FILE"
  echo "Updated CHANGELOG.md (${section}): $description"
  return 0
}

#######################################
# Generate commit message from staged changes
# Analyzes staged files to suggest conventional commit type
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Writes suggested commit type to stdout
# Returns:
#   0 always
#######################################
generate_commit_message() {
  local staged_files
  staged_files=$(get_staged_files)

  # Analyze file patterns to suggest type
  if echo "$staged_files" | grep -qE '\.md$'; then
    if echo "$staged_files" | grep -qE 'docs/|README|CHANGELOG'; then
      echo "docs"
      return 0
    fi
  fi

  if echo "$staged_files" | grep -qE '\.sh$'; then
    if echo "$staged_files" | grep -qE 'scripts/'; then
      echo "feat"
      return 0
    fi
  fi

  if echo "$staged_files" | grep -qE 'test|spec'; then
    echo "test"
    return 0
  fi

  # Default to feat for code changes
  echo "feat"
}

#######################################
# Create a git commit with conventional format
# Globals:
#   None
# Arguments:
#   $1 - Commit type (feat, fix, etc.)
#   $2 - Commit description
#   $3 - Optional scope
# Outputs:
#   Writes commit SHA to stdout
# Returns:
#   0 if successful, 1 if error
#######################################
create_commit() {
  local type="$1"
  local description="$2"
  local scope="${3:-}"

  local message
  if [[ -n "$scope" ]]; then
    message="${type}(${scope}): ${description}"
  else
    message="${type}: ${description}"
  fi

  if git commit -m "$message"; then
    local sha
    sha=$(git rev-parse HEAD)
    echo "$sha"
    return 0
  else
    echo "Error: Failed to create commit" >&2
    return 1
  fi
}

#######################################
# Get current branch name
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Writes branch name to stdout
# Returns:
#   0 if successful, 1 if error
#######################################
get_current_branch() {
  git rev-parse --abbrev-ref HEAD
}

#######################################
# Extract issue number from branch name
# Expects format: {number}-{slug}
# Globals:
#   None
# Arguments:
#   $1 - Optional branch name (uses current if not provided)
# Outputs:
#   Writes issue number to stdout
# Returns:
#   0 if found, 1 if not
#######################################
extract_issue_number() {
  local branch="${1:-$(get_current_branch)}"

  if [[ "$branch" =~ ^([0-9]+)- ]]; then
    echo "${BASH_REMATCH[1]}"
    return 0
  else
    return 1
  fi
}

#######################################
# Check if current branch is a feature branch
# Feature branch format: {number}-{slug}
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
# Returns:
#   0 if feature branch, 1 if not
#######################################
is_feature_branch() {
  local branch
  branch=$(get_current_branch)
  extract_issue_number "$branch" &>/dev/null
}

#######################################
# Get commit count on current branch vs base
# Globals:
#   None
# Arguments:
#   $1 - Base branch (default: main)
# Outputs:
#   Writes commit count to stdout
# Returns:
#   0 if successful, 1 if error
#######################################
get_commit_count() {
  local base_branch="${1:-main}"
  local current_branch
  current_branch=$(get_current_branch)

  # Get commits on current branch not in base
  git rev-list --count "${base_branch}..${current_branch}" 2>/dev/null || echo "0"
}

#######################################
# Get list of commits on current branch
# Globals:
#   None
# Arguments:
#   $1 - Base branch (default: main)
#   $2 - Format (default: oneline)
# Outputs:
#   Writes commit list to stdout
# Returns:
#   0 if successful, 1 if error
#######################################
get_branch_commits() {
  local base_branch="${1:-main}"
  local format="${2:-oneline}"
  local current_branch
  current_branch=$(get_current_branch)

  case "$format" in
    oneline)
      git log --oneline "${base_branch}..${current_branch}"
      ;;
    full)
      git log "${base_branch}..${current_branch}"
      ;;
    pretty)
      git log --pretty=format:"- %s (%h)" "${base_branch}..${current_branch}"
      ;;
    *)
      git log --oneline "${base_branch}..${current_branch}"
      ;;
  esac
}

#######################################
# Get diff stats for current changes
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Writes diff stats to stdout
# Returns:
#   0 always
#######################################
get_diff_stats() {
  git diff --stat
}

#######################################
# Stage all changes
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
# Returns:
#   0 if successful, 1 if error
#######################################
stage_all_changes() {
  git add -A
}

#######################################
# Stage specific files
# Globals:
#   None
# Arguments:
#   $@ - Files to stage
# Outputs:
#   None
# Returns:
#   0 if successful, 1 if error
#######################################
stage_files() {
  git add "$@"
}

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
#   source $HOME/.claude/skills/mykit/references/scripts/git-ops.sh
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

cleanup() {
  :
}
trap cleanup EXIT

# Script directory and paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
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
  git diff --name-only HEAD 2>/dev/null
  git ls-files --others --exclude-standard 2>/dev/null
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
    breaking)
      echo "Breaking"
      ;;
    *)
      echo "Changed"
      ;;
  esac
}

#######################################
# Update CHANGELOG.md with new entry
# Adds entry under the specified version section in appropriate subsection.
# If no version is provided, falls back to [Unreleased].
# Globals:
#   CHANGELOG_FILE
# Arguments:
#   $1 - Commit type (feat, fix, etc.)
#   $2 - Commit description
#   $3 - Optional version string (e.g., "0.27.0") — without 'v' prefix
# Outputs:
#   Writes status to stdout
# Returns:
#   0 if updated, 1 if error
#######################################
update_changelog() {
  local type="$1"
  local description="$2"
  local version="${3:-}"
  local section
  section=$(determine_changelog_section "$type")

  # Determine the version header to use
  local version_header
  if [[ -n "$version" ]]; then
    local today
    today=$(date +%Y-%m-%d)
    version_header="[${version}] - ${today}"
  else
    version_header="[Unreleased]"
  fi

  # Create CHANGELOG if it doesn't exist
  if [[ ! -f "$CHANGELOG_FILE" ]]; then
    cat > "$CHANGELOG_FILE" <<EOF
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## ${version_header}

EOF
    echo "Created CHANGELOG.md"
  fi

  # Check if the target version section exists
  local version_pattern
  if [[ -n "$version" ]]; then
    # Match version section with or without date (to handle appending to existing section)
    version_pattern="^## \\[${version}\\]"
  else
    version_pattern="^## \\[Unreleased\\]"
  fi

  if ! grep -qE "$version_pattern" "$CHANGELOG_FILE"; then
    # Add version section after the changelog header (before any existing version sections)
    local temp_file
    temp_file=$(mktemp)
    local inserted=0
    while IFS= read -r line; do
      # Insert before the first ## section
      if [[ "$inserted" -eq 0 ]] && [[ "$line" =~ ^##\  ]]; then
        echo "## ${version_header}" >> "$temp_file"
        echo "" >> "$temp_file"
        inserted=1
      fi
      echo "$line" >> "$temp_file"
    done < "$CHANGELOG_FILE"
    # If no ## section found, append at end
    if [[ "$inserted" -eq 0 ]]; then
      {
        echo ""
        echo "## ${version_header}"
        echo ""
      } >> "$temp_file"
    fi
    mv "$temp_file" "$CHANGELOG_FILE"
  fi

  # Find or create the subsection under the target version and append entry
  local temp_file
  temp_file=$(mktemp)
  local in_target_version=0
  local entry_added=0

  while IFS= read -r line; do
    # Track if we're in the target version section
    if [[ "$line" =~ $version_pattern ]]; then
      in_target_version=1
      echo "$line" >> "$temp_file"
      continue
    fi

    # If we hit another version section, we're done with the target version
    if [[ "$in_target_version" -eq 1 ]] && [[ "$line" =~ ^##\  ]]; then
      # Add new section and entry before this version if not added yet
      if [[ "$entry_added" -eq 0 ]]; then
        {
          echo ""
          echo "### $section"
          echo "- $description"
          echo ""
        } >> "$temp_file"
        entry_added=1
      fi
      in_target_version=0
      echo "$line" >> "$temp_file"
      continue
    fi

    # If we're in the target version and find the matching subsection heading
    if [[ "$in_target_version" -eq 1 ]] && [[ "$line" == "### $section" ]]; then
      echo "$line" >> "$temp_file"
      echo "- $description" >> "$temp_file"
      entry_added=1
      continue
    fi

    echo "$line" >> "$temp_file"
  done < "$CHANGELOG_FILE"

  # If we're still in the target version at EOF and haven't added entry
  if [[ "$in_target_version" -eq 1 ]] && [[ "$entry_added" -eq 0 ]]; then
    {
      echo ""
      echo "### $section"
      echo "- $description"
    } >> "$temp_file"
    entry_added=1
  fi

  mv "$temp_file" "$CHANGELOG_FILE"
  echo "Updated CHANGELOG.md (${section}): $description"
  return 0
}

#######################################
# Generate commit message from all changed files
# Analyzes all changed files (staged + unstaged) to suggest conventional commit type
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
  local changed_files
  changed_files=$(get_changed_files)

  # Analyze file patterns to suggest type
  if grep -qE '\.md$' <<< "$changed_files"; then
    if grep -qE 'docs/|README|CHANGELOG' <<< "$changed_files"; then
      echo "docs"
      return 0
    fi
  fi

  if grep -qE '\.sh$' <<< "$changed_files"; then
    if grep -qE 'scripts/' <<< "$changed_files"; then
      echo "feat"
      return 0
    fi
  fi

  if grep -qE 'test|spec' <<< "$changed_files"; then
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
#   $4 - Optional body (multi-line footers, e.g. BREAKING CHANGE, Refs #)
# Outputs:
#   Writes commit SHA to stdout
# Returns:
#   0 if successful, 1 if error
#######################################
create_commit() {
  local type="$1"
  local description="$2"
  local scope="${3:-}"
  local body="${4:-}"

  local subject
  if [[ -n "$scope" ]]; then
    subject="${type}(${scope}): ${description}"
  else
    subject="${type}: ${description}"
  fi

  local commit_result
  if [[ -n "$body" ]]; then
    # Multi-line commit: subject + blank line + body via temp file
    local msg_file
    msg_file=$(mktemp)
    printf '%s\n\n%s\n' "$subject" "$body" > "$msg_file"
    commit_result=$(git commit -F "$msg_file" 2>&1)
    local exit_code=$?
    rm -f "$msg_file"
    if [[ $exit_code -ne 0 ]]; then
      echo "Error: Failed to create commit" >&2
      echo "$commit_result" >&2
      return 1
    fi
  else
    if ! git commit -m "$subject" > /dev/null 2>&1; then
      echo "Error: Failed to create commit" >&2
      return 1
    fi
  fi

  local sha
  sha=$(git rev-parse HEAD)
  echo "$sha"
  return 0
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
# Calculate next semantic version from conventional commits
# Analyzes commit messages since the latest tag and determines
# the appropriate version bump (major, minor, or patch).
# Globals:
#   None
# Arguments:
#   $1 - Optional base tag (uses latest semver tag if not provided)
# Outputs:
#   Writes next version string (e.g., "v0.25.0") to stdout
# Returns:
#   0 if successful, 1 if error
#######################################
calculate_next_version() {
  local base_tag="${1:-}"

  # Find latest semver tag if not provided
  if [[ -z "$base_tag" ]]; then
    base_tag=$(git describe --tags --abbrev=0 --match 'v[0-9]*.[0-9]*.[0-9]*' 2>/dev/null || echo "")
  fi

  # Fall back to v0.0.0 if no valid semver tag
  if [[ -z "$base_tag" ]] || ! [[ "$base_tag" =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
    base_tag="v0.0.0"
  fi

  # Parse current version
  [[ "$base_tag" =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]
  local major="${BASH_REMATCH[1]}"
  local minor="${BASH_REMATCH[2]}"
  local patch="${BASH_REMATCH[3]}"

  # Get commits since tag (or all commits if tag is v0.0.0 and doesn't exist as a real tag)
  local commits
  if git rev-parse "$base_tag" &>/dev/null; then
    commits=$(git log --oneline "${base_tag}..HEAD" 2>/dev/null || echo "")
  else
    commits=$(git log --oneline 2>/dev/null || echo "")
  fi

  if [[ -z "$commits" ]]; then
    echo "v${major}.${minor}.${patch}"
    return 0
  fi

  # Determine bump level from commit messages
  local bump="patch"

  # Also fetch full commit bodies for BREAKING CHANGE footers
  local full_log
  if git rev-parse "$base_tag" &>/dev/null; then
    full_log=$(git log --format="%B" "${base_tag}..HEAD" 2>/dev/null || echo "")
  else
    full_log=$(git log --format="%B" 2>/dev/null || echo "")
  fi

  # Check for breaking changes (major bump)
  # Pattern 1: type! or type(scope)!: in subject line
  if echo "$commits" | grep -qE '^[a-f0-9]+ [a-z]+(\([a-z0-9-]+\))?!:'; then
    bump="major"
  fi
  # Pattern 2: BREAKING CHANGE: or BREAKING-CHANGE: in commit body
  if [[ "$bump" != "major" ]] && echo "$full_log" | grep -qE '^BREAKING[ -]CHANGE:'; then
    bump="major"
  fi

  # Check for feat: commits (minor bump) if not already major
  if [[ "$bump" == "patch" ]] && echo "$commits" | grep -qE '^[a-f0-9]+ feat(\([a-z0-9-]+\))?[!]?:'; then
    bump="minor"
  fi

  # Apply bump
  case "$bump" in
    major)
      major=$((major + 1))
      minor=0
      patch=0
      ;;
    minor)
      minor=$((minor + 1))
      patch=0
      ;;
    patch)
      patch=$((patch + 1))
      ;;
  esac

  echo "v${major}.${minor}.${patch}"
  return 0
}

#######################################
# Get PR details for the current branch
# Fetches the open PR number, title, and head commit SHA
# for the current branch using the GitHub CLI.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Writes JSON object with number, title, headSha to stdout
# Returns:
#   0 if PR found, 1 if no PR or gh unavailable
#######################################
get_pr_for_branch() {
  if ! command -v gh &>/dev/null; then
    echo "Error: gh CLI not found" >&2
    return 1
  fi

  local pr_json
  pr_json=$(gh pr view --json number,title,headRefOid 2>/dev/null) || {
    echo "Error: No open PR found for current branch" >&2
    return 1
  }

  echo "$pr_json"
  return 0
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

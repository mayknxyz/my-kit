#!/usr/bin/env bash
#
# utils.sh - Utility functions for My Kit
#
# DESCRIPTION:
#   Common utility functions for My Kit commands including task completion
#   checking, state management helpers, and general utilities.
#
# USAGE:
#   source .mykit/scripts/utils.sh
#   check_tasks_complete "specs/042-feature/tasks.md"
#
# EXIT CODES:
#   0  Success
#   1  Error or validation failure
#
# REQUIREMENTS:
#   - Bash 4.0+
#

set -euo pipefail

# Script directory and paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

#######################################
# Check if all tasks in tasks.md are complete
# Globals:
#   None
# Arguments:
#   $1 - Path to tasks.md file
# Outputs:
#   Writes list of incomplete tasks to stdout (if any)
# Returns:
#   0 if all tasks complete, 1 if incomplete tasks exist
#######################################
check_tasks_complete() {
  local tasks_file="$1"

  # If file doesn't exist, consider it complete (ad-hoc branch without tasks)
  if [[ ! -f "$tasks_file" ]]; then
    return 0
  fi

  # Find incomplete tasks (pending or in-progress)
  local incomplete_tasks
  incomplete_tasks=$(grep -nE '^\- \[([ >])\]' "$tasks_file" || true)

  if [[ -n "$incomplete_tasks" ]]; then
    return 1
  else
    return 0
  fi
}

#######################################
# Parse tasks file and extract all task information
# Globals:
#   None
# Arguments:
#   $1 - Path to tasks.md file
# Outputs:
#   Writes JSON array of tasks to stdout
# Returns:
#   0 if parsed successfully, 1 if error
#######################################
parse_tasks_file() {
  local tasks_file="$1"

  if [[ ! -f "$tasks_file" ]]; then
    echo "[]"
    return 0
  fi

  # Extract tasks with their status
  local tasks_json="["
  local first_task=true

  while IFS= read -r line; do
    # Match task lines: - [x] T001 Description
    if [[ "$line" =~ ^-\ \[(.)\]\ (T[0-9]{3})\ (.+)$ ]]; then
      local marker="${BASH_REMATCH[1]}"
      local id="${BASH_REMATCH[2]}"
      local description="${BASH_REMATCH[3]}"

      # Determine status from marker
      local status="pending"
      case "$marker" in
        " ") status="pending" ;;
        ">") status="in-progress" ;;
        "x") status="complete" ;;
        "~") status="skipped" ;;
      esac

      # Add to JSON array
      if [[ "$first_task" == false ]]; then
        tasks_json+=","
      fi
      first_task=false

      # Escape description for JSON
      description=$(echo "$description" | sed 's/"/\\"/g')

      tasks_json+="{\"id\":\"$id\",\"status\":\"$status\",\"description\":\"$description\"}"
    fi
  done < "$tasks_file"

  tasks_json+="]"
  echo "$tasks_json"
}

#######################################
# Find all incomplete tasks in tasks.md
# Globals:
#   None
# Arguments:
#   $1 - Path to tasks.md file
# Outputs:
#   Writes list of incomplete task IDs and descriptions to stdout
# Returns:
#   0 always
#######################################
find_incomplete_tasks() {
  local tasks_file="$1"

  if [[ ! -f "$tasks_file" ]]; then
    return 0
  fi

  # Find and display incomplete tasks
  grep -nE '^\- \[([ >])\]' "$tasks_file" | while IFS=: read -r line_num line_content; do
    # Extract task ID and description
    if [[ "$line_content" =~ ^\-\ \[(.)\]\ (T[0-9]{3})\ (.+)$ ]]; then
      local marker="${BASH_REMATCH[1]}"
      local id="${BASH_REMATCH[2]}"
      local description="${BASH_REMATCH[3]}"

      # Determine status
      local status
      if [[ "$marker" == " " ]]; then
        status="pending"
      else
        status="in-progress"
      fi

      echo "  - $id [$status]: $description"
    fi
  done
}

#######################################
# Get task completion statistics
# Globals:
#   None
# Arguments:
#   $1 - Path to tasks.md file
# Outputs:
#   Writes JSON object with stats to stdout
# Returns:
#   0 always
#######################################
get_task_stats() {
  local tasks_file="$1"

  if [[ ! -f "$tasks_file" ]]; then
    echo "{\"total\":0,\"complete\":0,\"pending\":0,\"in_progress\":0,\"skipped\":0}"
    return 0
  fi

  local total=0
  local complete=0
  local pending=0
  local in_progress=0
  local skipped=0

  # Count tasks by status
  while IFS= read -r line; do
    if [[ "$line" =~ ^-\ \[(.)\]\ T[0-9]{3} ]]; then
      ((total++))
      local marker="${BASH_REMATCH[1]}"

      case "$marker" in
        " ") ((pending++)) ;;
        ">") ((in_progress++)) ;;
        "x") ((complete++)) ;;
        "~") ((skipped++)) ;;
      esac
    fi
  done < "$tasks_file"

  echo "{\"total\":$total,\"complete\":$complete,\"pending\":$pending,\"in_progress\":$in_progress,\"skipped\":$skipped}"
}

#######################################
# Read state.json safely
# Globals:
#   REPO_ROOT
# Arguments:
#   None
# Outputs:
#   Writes state JSON to stdout (or empty object if not found)
# Returns:
#   0 always
#######################################
read_state() {
  local state_file="$REPO_ROOT/.mykit/state.json"

  if [[ -f "$state_file" ]]; then
    cat "$state_file"
  else
    echo "{}"
  fi
}

#######################################
# Write state.json safely with atomic write
# Globals:
#   REPO_ROOT
# Arguments:
#   $1 - JSON string to write
# Outputs:
#   None
# Returns:
#   0 if successful, 1 if error
#######################################
write_state() {
  local state_json="$1"
  local state_file="$REPO_ROOT/.mykit/state.json"
  local state_dir="$REPO_ROOT/.mykit"

  # Ensure directory exists
  mkdir -p "$state_dir"

  # Atomic write using temp file
  local temp_file
  temp_file=$(mktemp "${state_file}.XXXXXX")

  if echo "$state_json" > "$temp_file"; then
    mv "$temp_file" "$state_file"
    return 0
  else
    rm -f "$temp_file"
    return 1
  fi
}

#######################################
# Update a specific field in state.json
# Globals:
#   None
# Arguments:
#   $1 - jq path (e.g., ".validation.status")
#   $2 - Value to set
# Outputs:
#   None
# Returns:
#   0 if successful, 1 if error
#######################################
update_state_field() {
  local jq_path="$1"
  local value="$2"

  local current_state
  current_state=$(read_state)

  local updated_state
  updated_state=$(echo "$current_state" | jq --arg val "$value" "${jq_path} = \$val")

  write_state "$updated_state"
}

#######################################
# Get a specific field from state.json
# Globals:
#   None
# Arguments:
#   $1 - jq path (e.g., ".validation.status")
# Outputs:
#   Writes field value to stdout
# Returns:
#   0 if successful, 1 if field not found
#######################################
get_state_field() {
  local jq_path="$1"

  local state
  state=$(read_state)

  local value
  value=$(echo "$state" | jq -r "$jq_path")

  if [[ "$value" == "null" ]]; then
    return 1
  else
    echo "$value"
    return 0
  fi
}

#######################################
# Check if jq is available
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
# Returns:
#   0 if available, 1 if not
#######################################
check_jq_available() {
  command -v jq &>/dev/null
}

#######################################
# Ensure jq is available or show error
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Writes error to stderr if jq not found
# Returns:
#   0 if available, exits with 1 if not
#######################################
require_jq() {
  if ! check_jq_available; then
    echo "Error: jq is required but not installed" >&2
    echo "" >&2
    echo "Install jq:" >&2
    echo "  - macOS: brew install jq" >&2
    echo "  - Ubuntu/Debian: apt-get install jq" >&2
    echo "  - CentOS/RHEL: yum install jq" >&2
    exit 1
  fi
}

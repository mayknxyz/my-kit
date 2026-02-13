#!/usr/bin/env bash
#
# utils.sh - Utility functions for My Kit
#
# DESCRIPTION:
#   Common utility functions for My Kit commands including task completion
#   checking, state management helpers, and general utilities.
#
# USAGE:
#   source $HOME/.claude/skills/mykit/references/scripts/utils.sh
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
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

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
  local enriched="${2:-false}"

  if [[ ! -f "$tasks_file" ]]; then
    echo "[]"
    return 0
  fi

  # Extract tasks with their status
  local tasks_json="["
  local first_task=true
  local current_phase=""
  local current_phase_num=""
  local current_priority=""

  while IFS= read -r line; do
    # Track phase headings: ## Phase N: Title (Priority: PN)
    if [[ "$line" =~ ^##\ Phase\ ([0-9]+):\ (.+)$ ]]; then
      current_phase_num="${BASH_REMATCH[1]}"
      local phase_title="${BASH_REMATCH[2]}"
      # Extract priority from phase title if present
      if [[ "$phase_title" =~ \(Priority:\ (P[0-9]+)\) ]]; then
        current_priority="${BASH_REMATCH[1]}"
      else
        current_priority=""
      fi
      # Clean phase name: strip trailing context like (Priority: P1) or emoji
      current_phase=$(echo "$phase_title" | sed -E 's/ *\(Priority:[^)]*\)//; s/ *🎯.*//; s/ *\([^)]*\) *$//' | sed 's/ *$//')
      continue
    fi

    # Also track ## Implementation / ## Completion sections (lite format)
    if [[ "$line" =~ ^##\ (Implementation|Completion)$ ]]; then
      current_phase="${BASH_REMATCH[1]}"
      current_phase_num=""
      current_priority=""
      continue
    fi

    # Match task lines: - [x] T001 [P] [US1] Description (depends on T002, T003)
    if [[ "$line" =~ ^-\ \[(.)\]\ (T[0-9]{3})\ (.+)$ ]]; then
      local marker="${BASH_REMATCH[1]}"
      local id="${BASH_REMATCH[2]}"
      local rest="${BASH_REMATCH[3]}"

      # Determine status from marker
      local status="pending"
      case "$marker" in
        " ") status="pending" ;;
        ">") status="in-progress" ;;
        "x"|"X") status="complete" ;;
        "~") status="skipped" ;;
      esac

      # Extract parallel marker [P]
      local parallel="false"
      if [[ "$rest" =~ ^\[P\]\ (.+)$ ]]; then
        parallel="true"
        rest="${BASH_REMATCH[1]}"
      fi

      # Extract story marker [US#]
      local story=""
      if [[ "$rest" =~ ^\[US([0-9]+)\]\ (.+)$ ]]; then
        story="US${BASH_REMATCH[1]}"
        rest="${BASH_REMATCH[2]}"
      fi

      # Extract inline dependencies: (depends on T001, T002)
      local deps="[]"
      if [[ "$rest" =~ \(depends\ on\ (T[0-9]{3}(,\ T[0-9]{3})*)\) ]]; then
        local dep_str="${BASH_REMATCH[1]}"
        deps="["
        local first_dep=true
        while [[ "$dep_str" =~ (T[0-9]{3}) ]]; do
          if [[ "$first_dep" == false ]]; then
            deps+=","
          fi
          first_dep=false
          deps+="\"${BASH_REMATCH[1]}\""
          dep_str="${dep_str#*"${BASH_REMATCH[1]}"}"
        done
        deps+="]"
      fi

      local description="$rest"

      # Add to JSON array
      if [[ "$first_task" == false ]]; then
        tasks_json+=","
      fi
      first_task=false

      # Escape description for JSON
      description="${description//\"/\\\"}"

      if [[ "$enriched" == "true" ]]; then
        # Escape phase for JSON
        local phase_escaped
        phase_escaped="${current_phase//\"/\\\"}"
        tasks_json+="{\"id\":\"$id\",\"status\":\"$status\",\"description\":\"$description\""
        tasks_json+=",\"phase\":\"$phase_escaped\",\"phase_num\":\"$current_phase_num\""
        tasks_json+=",\"parallel\":$parallel,\"story\":\"$story\""
        tasks_json+=",\"priority\":\"$current_priority\",\"dependencies\":$deps}"
      else
        tasks_json+="{\"id\":\"$id\",\"status\":\"$status\",\"description\":\"$description\"}"
      fi
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
  grep -nE '^\- \[([ >])\]' "$tasks_file" | while IFS=: read -r _line_num line_content; do
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
  require_jq

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
  require_jq

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
# Read config.json safely
# Globals:
#   REPO_ROOT
# Arguments:
#   None
# Outputs:
#   Writes config JSON to stdout (or empty object if not found)
# Returns:
#   0 always
#######################################
read_config() {
  local config_file="$REPO_ROOT/.mykit/config.json"

  if [[ -f "$config_file" ]]; then
    cat "$config_file"
  else
    echo "{}"
  fi
}

#######################################
# Get a specific field from config.json
# Globals:
#   None
# Arguments:
#   $1 - jq path (e.g., ".pr.titleTemplate")
# Outputs:
#   Writes field value to stdout
# Returns:
#   0 if successful, 1 if field not found
#######################################
get_config_field() {
  local jq_path="$1"

  local config
  config=$(read_config)

  local value
  value=$(echo "$config" | jq -r "$jq_path" 2>/dev/null)

  if [[ "$value" == "null" || -z "$value" ]]; then
    return 1
  else
    echo "$value"
    return 0
  fi
}

#######################################
# Get a specific field from config.json with a default fallback
# Globals:
#   None
# Arguments:
#   $1 - jq path (e.g., ".pr.titleTemplate")
#   $2 - Default value if field not found
# Outputs:
#   Writes field value or default to stdout
# Returns:
#   0 always
#######################################
get_config_field_or_default() {
  local jq_path="$1"
  local default_value="$2"

  local value
  if value=$(get_config_field "$jq_path"); then
    echo "$value"
  else
    echo "$default_value"
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

#######################################
# Parse CRUD action flags from command arguments
#
# Extracts the first CRUD flag found in the arguments:
#   -c / --create  → "create"
#   -r / --read    → "read"
#   -u / --update  → "update"
#   -d / --delete  → "delete"
#
# If multiple CRUD flags are present, the first one wins.
# Non-CRUD flags are ignored and left for the caller to handle.
#
# Globals:
#   None
# Arguments:
#   $@ - Command arguments to parse
# Outputs:
#   Writes the CRUD action to stdout ("create", "read",
#   "update", "delete", or "" if no CRUD flag found)
# Returns:
#   0 always
#######################################
parse_crud_action() {
  local args="$*"

  for arg in $args; do
    case "$arg" in
      -c|--create) echo "create"; return 0 ;;
      -r|--read)   echo "read";   return 0 ;;
      -u|--update) echo "update"; return 0 ;;
      -d|--delete) echo "delete"; return 0 ;;
    esac
  done

  echo ""
  return 0
}

# =========================================================================
# Functions originally from common.sh, now maintained here
# =========================================================================

#######################################
# Get repository root, with fallback for non-git repositories
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Writes repo root path to stdout
# Returns:
#   0 always
#######################################
get_repo_root() {
  if git rev-parse --show-toplevel >/dev/null 2>&1; then
    git rev-parse --show-toplevel
  else
    # Fall back to script location for non-git repos
    local script_dir
    script_dir="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    (cd "$script_dir/../.." && pwd)
  fi
}

#######################################
# Get current branch, with fallback for non-git repositories
# Globals:
#   MYKIT_FEATURE (optional override, replaces SPECIFY_FEATURE)
# Arguments:
#   None
# Outputs:
#   Writes branch name to stdout
# Returns:
#   0 always
#######################################
get_current_branch() {
  # First check if MYKIT_FEATURE environment variable is set
  if [[ -n "${MYKIT_FEATURE:-}" ]]; then
    echo "$MYKIT_FEATURE"
    return
  fi

  # Legacy support: check SPECIFY_FEATURE too
  if [[ -n "${SPECIFY_FEATURE:-}" ]]; then
    echo "$SPECIFY_FEATURE"
    return
  fi

  # Then check git if available
  if git rev-parse --abbrev-ref HEAD >/dev/null 2>&1; then
    git rev-parse --abbrev-ref HEAD
    return
  fi

  # For non-git repos, try to find the latest feature directory
  local repo_root
  repo_root=$(get_repo_root)
  local specs_dir="$repo_root/specs"

  if [[ -d "$specs_dir" ]]; then
    local latest_feature=""
    local highest=0

    for dir in "$specs_dir"/*; do
      if [[ -d "$dir" ]]; then
        local dirname
        dirname=$(basename "$dir")
        if [[ "$dirname" =~ ^([0-9]{3})- ]]; then
          local number=${BASH_REMATCH[1]}
          number=$((10#$number))
          if [[ "$number" -gt "$highest" ]]; then
            highest=$number
            latest_feature=$dirname
          fi
        fi
      fi
    done

    if [[ -n "$latest_feature" ]]; then
      echo "$latest_feature"
      return
    fi
  fi

  echo "main"  # Final fallback
}

#######################################
# Check if we have git available
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   None
# Returns:
#   0 if git repo available, 1 if not
#######################################
has_git() {
  git rev-parse --show-toplevel >/dev/null 2>&1
}

#######################################
# Validate feature branch naming convention
# Globals:
#   None
# Arguments:
#   $1 - Branch name
#   $2 - Whether git repo is available ("true"/"false")
# Outputs:
#   Writes warnings/errors to stderr
# Returns:
#   0 if valid, 1 if invalid
#######################################
check_feature_branch() {
  local branch="$1"
  local has_git_repo="$2"

  # For non-git repos, we can't enforce branch naming but still provide output
  if [[ "$has_git_repo" != "true" ]]; then
    echo "[mykit] Warning: Git repository not detected; skipped branch validation" >&2
    return 0
  fi

  if [[ ! "$branch" =~ ^[0-9]{3}- ]]; then
    echo "ERROR: Not on a feature branch. Current branch: $branch" >&2
    echo "Feature branches should be named like: 001-feature-name" >&2
    return 1
  fi

  return 0
}

#######################################
# Find feature directory by numeric prefix
# Allows multiple branches to work on the same spec
# Globals:
#   None
# Arguments:
#   $1 - Repository root path
#   $2 - Branch name
# Outputs:
#   Writes feature directory path to stdout
# Returns:
#   0 always
#######################################
find_feature_dir_by_prefix() {
  local repo_root="$1"
  local branch_name="$2"
  local specs_dir="$repo_root/specs"

  # Extract numeric prefix from branch (e.g., "004" from "004-whatever")
  if [[ ! "$branch_name" =~ ^([0-9]{3})- ]]; then
    # If branch doesn't have numeric prefix, fall back to exact match
    echo "$specs_dir/$branch_name"
    return
  fi

  local prefix="${BASH_REMATCH[1]}"

  # Search for directories in specs/ that start with this prefix
  local matches=()
  if [[ -d "$specs_dir" ]]; then
    for dir in "$specs_dir"/"$prefix"-*; do
      if [[ -d "$dir" ]]; then
        matches+=("$(basename "$dir")")
      fi
    done
  fi

  # Handle results
  if [[ ${#matches[@]} -eq 0 ]]; then
    # No match found - return the branch name path (will fail later with clear error)
    echo "$specs_dir/$branch_name"
  elif [[ ${#matches[@]} -eq 1 ]]; then
    # Exactly one match
    echo "$specs_dir/${matches[0]}"
  else
    # Multiple matches - this shouldn't happen with proper naming convention
    echo "ERROR: Multiple spec directories found with prefix '$prefix': ${matches[*]}" >&2
    echo "Please ensure only one spec directory exists per numeric prefix." >&2
    echo "$specs_dir/$branch_name"  # Return something to avoid breaking the script
  fi
}

#######################################
# Get all feature-related paths for the current branch
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Writes shell variable assignments to stdout (eval-friendly)
# Returns:
#   0 always
#######################################
get_feature_paths() {
  local repo_root
  repo_root=$(get_repo_root)
  local current_branch
  current_branch=$(get_current_branch)
  local has_git_repo="false"

  if has_git; then
    has_git_repo="true"
  fi

  # Use prefix-based lookup to support multiple branches per spec
  local feature_dir
  feature_dir=$(find_feature_dir_by_prefix "$repo_root" "$current_branch")

  cat <<EOF
REPO_ROOT='$repo_root'
CURRENT_BRANCH='$current_branch'
HAS_GIT='$has_git_repo'
FEATURE_DIR='$feature_dir'
FEATURE_SPEC='$feature_dir/spec.md'
IMPL_PLAN='$feature_dir/plan.md'
TASKS='$feature_dir/tasks.md'
RESEARCH='$feature_dir/research.md'
DATA_MODEL='$feature_dir/data-model.md'
QUICKSTART='$feature_dir/quickstart.md'
CONTRACTS_DIR='$feature_dir/contracts'
EOF
}

#######################################
# Validate that the git remote is a GitHub URL and extract owner/repo
# Globals:
#   None
# Arguments:
#   $1 - Remote name (default: "origin")
# Outputs:
#   JSON object: {"valid":true,"owner":"...","repo":"...","remote_url":"..."}
#   or: {"valid":false,"error":"...","remote_url":"..."}
# Returns:
#   0 if valid GitHub remote, 1 if not
#######################################
validate_github_remote() {
  local remote_name="${1:-origin}"

  local remote_url
  remote_url=$(git config --get "remote.${remote_name}.url" 2>/dev/null || echo "")

  if [[ -z "$remote_url" ]]; then
    echo "{\"valid\":false,\"error\":\"No remote '${remote_name}' configured\",\"remote_url\":\"\"}"
    return 1
  fi

  local owner=""
  local repo=""

  # Match HTTPS: https://github.com/owner/repo.git or https://github.com/owner/repo
  if [[ "$remote_url" =~ ^https://github\.com/([^/]+)/([^/.]+)(\.git)?$ ]]; then
    owner="${BASH_REMATCH[1]}"
    repo="${BASH_REMATCH[2]}"
  # Match SSH: git@github.com:owner/repo.git or git@github.com:owner/repo
  elif [[ "$remote_url" =~ ^git@github\.com:([^/]+)/([^/.]+)(\.git)?$ ]]; then
    owner="${BASH_REMATCH[1]}"
    repo="${BASH_REMATCH[2]}"
  else
    echo "{\"valid\":false,\"error\":\"Remote is not a GitHub URL\",\"remote_url\":\"$remote_url\"}"
    return 1
  fi

  echo "{\"valid\":true,\"owner\":\"$owner\",\"repo\":\"$repo\",\"remote_url\":\"$remote_url\"}"
  return 0
}

#######################################
# Find existing GitHub issues that match task IDs from tasks.md
# Uses [TXXX] prefix convention in issue titles for deduplication.
# Globals:
#   None
# Arguments:
#   $1 - owner/repo (e.g., "mayknxyz/my-kit")
#   $2 - Space-separated list of task IDs to check (e.g., "T001 T002 T003")
# Outputs:
#   JSON object mapping task IDs to issue numbers for already-created issues
#   e.g., {"T001":123,"T003":456}
# Returns:
#   0 always
#######################################
find_existing_task_issues() {
  require_jq

  local owner_repo="$1"
  local task_ids="$2"

  # Fetch all open issues with titles matching [T###] pattern
  local issues
  issues=$(gh issue list --repo "$owner_repo" --state all --search "[T" --json number,title --limit 200 2>/dev/null || echo "[]")

  # Build result JSON mapping task IDs to issue numbers
  local result="{"
  local first=true

  for tid in $task_ids; do
    # Search for issue with title starting with [TXXX]
    local issue_num
    issue_num=$(echo "$issues" | jq -r --arg tid "$tid" \
      '.[] | select(.title | startswith("[" + $tid + "]")) | .number' 2>/dev/null | head -1)

    if [[ -n "$issue_num" && "$issue_num" != "null" ]]; then
      if [[ "$first" == false ]]; then
        result+=","
      fi
      first=false
      result+="\"$tid\":$issue_num"
    fi
  done

  result+="}"
  echo "$result"
}

#######################################
# Topological sort of tasks by dependency order (Kahn's algorithm)
# Tasks without dependencies come first. Tasks depending on others
# are placed after their dependencies. Cycle detection included.
# Globals:
#   None
# Arguments:
#   $1 - Enriched tasks JSON array (from parse_tasks_file with enriched=true)
# Outputs:
#   Space-separated task IDs in dependency-respecting creation order
# Returns:
#   0 if successful, 1 if cycle detected
#######################################
toposort_tasks() {
  require_jq

  local tasks_json="$1"

  # Use jq to perform topological sort
  local result
  result=$(echo "$tasks_json" | jq -r '
    # Build adjacency and in-degree maps
    def toposort:
      # Collect all task IDs
      [.[] | .id] as $all_ids |

      # Build in-degree count for each task
      (reduce .[] as $task (
        {};
        . + {($task.id): ([$task.dependencies[] | select(. as $d | $all_ids | index($d))] | length)}
      )) as $in_degree |

      # Initialize queue with zero in-degree tasks
      [$all_ids[] | select($in_degree[.] == 0)] as $queue |

      # Build adjacency list (task -> tasks that depend on it)
      (reduce .[] as $task (
        {};
        reduce ($task.dependencies[] | select(. as $d | $all_ids | index($d))) as $dep (
          .;
          .[$dep] = ((.[$dep] // []) + [$task.id])
        )
      )) as $adj |

      # Process queue (BFS)
      {queue: $queue, result: [], in_degree: $in_degree, adj: $adj} |
      until(.queue | length == 0;
        .queue[0] as $node |
        .result += [$node] |
        .queue = .queue[1:] |
        # Reduce in-degree of neighbors
        reduce ((.adj[$node] // [])[] ) as $neighbor (
          .;
          .in_degree[$neighbor] = (.in_degree[$neighbor] - 1) |
          if .in_degree[$neighbor] == 0
          then .queue += [$neighbor]
          else . end
        )
      ) |
      .result;

    toposort | join(" ")
  ' 2>/dev/null)

  if [[ -z "$result" ]]; then
    # Fallback: return task IDs in original order
    echo "$tasks_json" | jq -r '[.[] | .id] | join(" ")'
    return 1
  fi

  echo "$result"
  return 0
}

#######################################
# Check if a file exists and display status
# Globals:
#   None
# Arguments:
#   $1 - File path
#   $2 - Display label
# Outputs:
#   Writes check/cross mark with label to stdout
# Returns:
#   0 always
#######################################
check_file() { [[ -f "$1" ]] && echo "  ✓ $2" || echo "  ✗ $2"; }

#######################################
# Check if a directory exists and is non-empty
# Globals:
#   None
# Arguments:
#   $1 - Directory path
#   $2 - Display label
# Outputs:
#   Writes check/cross mark with label to stdout
# Returns:
#   0 always
#######################################
check_dir() { [[ -d "$1" && -n $(ls -A "$1" 2>/dev/null) ]] && echo "  ✓ $2" || echo "  ✗ $2"; }

#!/usr/bin/env bash
#
# check-upstream-drift.sh - Detect drift between Major mode files and upstream
#
# DESCRIPTION:
#   Compares $HOME/.claude/skills/mykit-workflow/references/major/ against $HOME/.claude/skills/mykit/references/upstream/commands/ (with expected
#   substitutions) and $HOME/.claude/skills/mykit/references/templates/major/ against $HOME/.claude/skills/mykit/references/upstream/templates/
#   to detect unexpected differences.
#
# USAGE:
#   $HOME/.claude/skills/mykit/references/scripts/check-upstream-drift.sh [--verbose]
#
# EXIT CODES:
#   0  In sync (no drift detected)
#   1  Drift detected
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

UPSTREAM_DIR="$HOME/.claude/skills/mykit/references/upstream"
MODES_FULL_DIR="$HOME/.claude/skills/mykit-workflow/references/major"
TEMPLATES_FULL_DIR="$HOME/.claude/skills/mykit/references/templates/major"

VERBOSE=false
DRIFT_COUNT=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --verbose|-v)
      VERBOSE=true
      shift
      ;;
    --help|-h)
      echo "Usage: $0 [--verbose]"
      echo ""
      echo "Compares Major mode files against upstream spec-kit (with expected substitutions)."
      echo "Exit code 0 = in sync, 1 = drift detected."
      exit 0
      ;;
    *)
      echo "Error: Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

# Check prerequisites
if [[ ! -d "$UPSTREAM_DIR" ]]; then
  echo "Error: Upstream directory not found at $UPSTREAM_DIR" >&2
  echo "Run $HOME/.claude/skills/mykit/references/scripts/sync-upstream.sh first." >&2
  exit 1
fi

#######################################
# Apply expected path substitutions to upstream content for comparison
# Arguments:
#   $1 - Upstream file content (via stdin)
# Outputs:
#   Transformed content to stdout
#######################################
apply_expected_substitutions() {
  sed \
    -e 's|\.specify/templates/|$HOME/.claude/skills/mykit/references/templates/major/|g' \
    -e 's|\.specify/|.mykit/|g' \
    -e 's|scripts/bash/|$HOME/.claude/skills/mykit/references/scripts/|g' \
    -e 's|templates/spec-template\.md|$HOME/.claude/skills/mykit/references/templates/major/spec-template.md|g' \
    -e 's|templates/plan-template\.md|$HOME/.claude/skills/mykit/references/templates/major/plan-template.md|g' \
    -e 's|templates/tasks-template\.md|$HOME/.claude/skills/mykit/references/templates/major/tasks-template.md|g' \
    -e 's|templates/checklist-template\.md|$HOME/.claude/skills/mykit/references/templates/major/checklist-template.md|g' \
    -e 's|templates/agent-file-template\.md|$HOME/.claude/skills/mykit/references/templates/major/agent-file-template.md|g' \
    -e 's|/speckit\.|/mykit.|g' \
    -e 's|speckit\.|mykit.|g' \
    -e 's|`/memory/|`.mykit/memory/|g' \
    -e 's| /memory/| .mykit/memory/|g'
}

#######################################
# Strip YAML frontmatter and User Input section from upstream content
# Arguments:
#   stdin - File content
# Outputs:
#   Stripped content to stdout
#######################################
strip_upstream_wrappers() {
  local in_frontmatter=false
  local frontmatter_ended=false
  local skip_input_section=false

  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == "---" && "$frontmatter_ended" == false ]]; then
      if [[ "$in_frontmatter" == false ]]; then
        in_frontmatter=true
        continue
      else
        in_frontmatter=false
        frontmatter_ended=true
        continue
      fi
    fi

    if [[ "$in_frontmatter" == true ]]; then
      continue
    fi

    if [[ "$line" =~ ^##\ User\ Input ]]; then
      skip_input_section=true
      continue
    fi

    if [[ "$skip_input_section" == true ]]; then
      if [[ "$line" =~ ^## && ! "$line" =~ ^##\ User\ Input ]]; then
        skip_input_section=false
      else
        continue
      fi
    fi

    echo "$line"
  done | sed '/./,$!d'
}

echo "=== Upstream Drift Check ==="
echo ""

if [[ -f "$UPSTREAM_DIR/VERSION" ]]; then
  echo "Upstream version:"
  sed 's/^/  /' "$UPSTREAM_DIR/VERSION"
  echo ""
fi

# Check command files
echo "--- Checking Full Mode Commands ---"

COMMANDS=(specify clarify plan tasks implement analyze checklist)
for cmd in "${COMMANDS[@]}"; do
  upstream_file="$UPSTREAM_DIR/commands/speckit.${cmd}.md"
  full_file="$MODES_FULL_DIR/${cmd}.md"

  if [[ ! -f "$upstream_file" ]]; then
    echo "  [WARN] Missing upstream: speckit.${cmd}.md"
    continue
  fi

  if [[ ! -f "$full_file" ]]; then
    echo "  [DRIFT] Missing major mode: ${cmd}.md"
    ((DRIFT_COUNT++))
    continue
  fi

  # Generate expected major mode content from upstream and normalize in one pass
  expected_normalized=$(strip_upstream_wrappers < "$upstream_file" | apply_expected_substitutions | sed 's/[[:space:]]*$//; /^$/N;/^\n$/d')

  # Read and normalize actual major mode content in one pass
  actual_normalized=$(sed 's/[[:space:]]*$//; /^$/N;/^\n$/d' "$full_file")

  if [[ "$expected_normalized" == "$actual_normalized" ]]; then
    echo "  [OK] ${cmd}.md"
  else
    echo "  [DRIFT] ${cmd}.md — differences detected"
    ((DRIFT_COUNT++))

    if [[ "$VERBOSE" == true ]]; then
      echo ""
      diff <(echo "$expected_normalized") <(echo "$actual_normalized") | head -30 | sed 's/^/    /'
      echo ""
    fi
  fi
done

echo ""
echo "--- Checking Full Mode Templates ---"

TEMPLATES=(spec-template.md plan-template.md tasks-template.md checklist-template.md agent-file-template.md)
for tmpl in "${TEMPLATES[@]}"; do
  upstream_file="$UPSTREAM_DIR/templates/${tmpl}"
  full_file="$TEMPLATES_FULL_DIR/${tmpl}"

  if [[ ! -f "$upstream_file" ]]; then
    echo "  [WARN] Missing upstream: ${tmpl}"
    continue
  fi

  if [[ ! -f "$full_file" ]]; then
    echo "  [DRIFT] Missing full template: ${tmpl}"
    ((DRIFT_COUNT++))
    continue
  fi

  # Apply path substitutions to upstream template for comparison
  expected_content=$(apply_expected_substitutions < "$upstream_file")
  actual_content=$(<"$full_file")

  # shellcheck disable=SC2001
  expected_normalized=$(echo "$expected_content" | sed 's/[[:space:]]*$//')
  # shellcheck disable=SC2001
  actual_normalized=$(echo "$actual_content" | sed 's/[[:space:]]*$//')

  if [[ "$expected_normalized" == "$actual_normalized" ]]; then
    echo "  [OK] ${tmpl}"
  else
    echo "  [DRIFT] ${tmpl} — differences detected"
    ((DRIFT_COUNT++))

    if [[ "$VERBOSE" == true ]]; then
      echo ""
      diff <(echo "$expected_normalized") <(echo "$actual_normalized") | head -30 | sed 's/^/    /'
      echo ""
    fi
  fi
done

echo ""
echo "=== Summary ==="

if [[ $DRIFT_COUNT -eq 0 ]]; then
  echo "All Major mode files are in sync with upstream."
  exit 0
else
  echo "$DRIFT_COUNT file(s) have drift from upstream."
  echo ""
  echo "To fix: run $HOME/.claude/skills/mykit/references/scripts/sync-upstream.sh to re-sync from spec-kit."
  echo "Use --verbose flag for detailed diffs."
  exit 1
fi

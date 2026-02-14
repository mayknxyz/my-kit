#!/usr/bin/env bash
# fetch-branch-info.sh — Resolve branch context for mykit commands.
# Source this script to set: BRANCH, ISSUE_NUMBER, SPEC_PATH, PLAN_PATH, TASKS_PATH
#
# Usage:
#   source $HOME/.claude/skills/mykit/references/scripts/fetch-branch-info.sh

set -euo pipefail

# Current branch name
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

if [[ -z "$BRANCH" ]]; then
  echo "**Error**: Not in a git repository."
  return 1 2>/dev/null || exit 1
fi

# Extract issue number from branch pattern ^([0-9]+)-
if [[ "$BRANCH" =~ ^([0-9]+)- ]]; then
  ISSUE_NUMBER="${BASH_REMATCH[1]#0}"
else
  ISSUE_NUMBER=""
fi

# Spec directory paths
SPEC_PATH="specs/${BRANCH}/spec.md"
PLAN_PATH="specs/${BRANCH}/plan.md"
TASKS_PATH="specs/${BRANCH}/tasks.md"

export BRANCH ISSUE_NUMBER SPEC_PATH PLAN_PATH TASKS_PATH

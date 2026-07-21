#!/usr/bin/env bash
# Prints the absolute path of the current repo's bare root if this is a
# bare-repo-and-worktrees setup, or nothing if it's a normal single-checkout
# repo. Callers treat empty output as "use the sibling <repo>-worktrees/
# convention instead."
set -euo pipefail

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

{ git worktree list --porcelain; echo; } | awk '
  /^worktree / { path = $0; sub(/^worktree /, "", path); bare = 0 }
  /^bare/ { bare = 1 }
  /^$/ {
    if (bare) { print path; exit }
  }
'

#!/usr/bin/env bash
# Prints the absolute path of the current repo's main/master worktree, or
# nothing if none is found. Callers treat empty output as "no redirect needed,
# use the current directory as-is."
set -euo pipefail

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

{ git worktree list --porcelain; echo; } | awk '
  /^worktree / { path = $0; sub(/^worktree /, "", path); branch = ""; prunable = 0 }
  /^branch refs\/heads\// { branch = $0; sub(/^branch refs\/heads\//, "", branch) }
  /^prunable/ { prunable = 1 }
  /^$/ {
    if (!prunable) {
      if (branch == "master") master_path = path
      if (branch == "main" && main_path == "") main_path = path
    }
  }
  END {
    if (master_path != "") { print master_path; exit }
    if (main_path != "") { print main_path; exit }
  }
'

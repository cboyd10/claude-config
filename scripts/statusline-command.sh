#!/usr/bin/env bash
# Claude Code status line script
# Receives JSON via stdin; outputs a single status line string.

input=$(cat)

# ── Model ──────────────────────────────────────────────────────────────────
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')

# ── Working directory (short form) ─────────────────────────────────────────
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
short_cwd=$(echo "$cwd" | sed "s|^$HOME|~|")

# ── Git repo (owner/name) ───────────────────────────────────────────────────
repo=$(echo "$input" | jq -r '.workspace.repo | if . then .owner + "/" + .name else empty end')

# ── Open PR ─────────────────────────────────────────────────────────────────
pr_num=$(echo "$input" | jq -r '.pr.number // empty')
pr_state=$(echo "$input" | jq -r '.pr.review_state // "open"')

# ── Context window ──────────────────────────────────────────────────────────
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // empty')

# ── Rate limits (Claude.ai subscription) ───────────────────────────────────
five_pct=$(echo  "$input" | jq -r '.rate_limits.five_hour.used_percentage  // empty')
week_pct=$(echo  "$input" | jq -r '.rate_limits.seven_day.used_percentage  // empty')

# ── Effort / thinking ───────────────────────────────────────────────────────
effort=$(echo "$input" | jq -r '.effort.level // empty')
thinking=$(echo "$input" | jq -r 'if .thinking.enabled then "think" else empty end')

# ── Vim mode ────────────────────────────────────────────────────────────────
vim_mode=$(echo "$input" | jq -r '.vim.mode // empty')

# ── Build the output line ───────────────────────────────────────────────────
# ANSI colours (will be further dimmed by Claude Code's status-line rendering)
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

parts=()

# Model
parts+=("$(printf "${CYAN}%s${RESET}" "$model")")

# Directory
parts+=("$(printf "${BLUE}%s${RESET}" "$short_cwd")")

# Repo
if [ -n "$repo" ]; then
  repo_str="$repo"
  [ -n "$pr_num" ] && repo_str="$repo_str PR#${pr_num}(${pr_state})"
  parts+=("$(printf "${GREEN}%s${RESET}" "$repo_str")")
fi

# Context usage
if [ -n "$used_pct" ]; then
  int_pct=$(printf '%.0f' "$used_pct")
  if   [ "$int_pct" -ge 80 ]; then color="$RED"
  elif [ "$int_pct" -ge 50 ]; then color="$YELLOW"
  else                              color="$GREEN"
  fi
  parts+=("$(printf "${color}ctx:%d%%${RESET}" "$int_pct")")
fi

# Session tokens
if [ -n "$total_input" ] && [ -n "$total_output" ]; then
  total_tokens=$((total_input + total_output))
  if [ "$total_tokens" -ge 1000 ]; then
    tok_str=$(awk "BEGIN {printf \"%.1fk\", $total_tokens/1000}")
  else
    tok_str="$total_tokens"
  fi
  parts+=("$(printf "${CYAN}tok:%s${RESET}" "$tok_str")")
fi

# Rate limits
rate_str=""
if [ -n "$five_pct" ]; then
  rate_str="5h:$(printf '%.0f' "$five_pct")%"
fi
if [ -n "$week_pct" ]; then
  [ -n "$rate_str" ] && rate_str="$rate_str "
  rate_str="${rate_str}7d:$(printf '%.0f' "$week_pct")%"
fi
if [ -n "$rate_str" ]; then
  parts+=("$(printf "${MAGENTA}%s${RESET}" "$rate_str")")
fi

# Effort / thinking
if [ -n "$effort" ]; then
  parts+=("$(printf "${YELLOW}effort:%s${RESET}" "$effort")")
elif [ -n "$thinking" ]; then
  parts+=("$(printf "${YELLOW}thinking${RESET}")")
fi

# Vim mode
if [ -n "$vim_mode" ]; then
  parts+=("$(printf "${MAGENTA}[%s]${RESET}" "$vim_mode")")
fi

# Join with separator
sep=" | "
result=""
for part in "${parts[@]}"; do
  if [ -z "$result" ]; then
    result="$part"
  else
    result="${result}${sep}${part}"
  fi
done

printf "%b\n" "$result"

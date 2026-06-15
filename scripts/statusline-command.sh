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

# ── Session tokens ──────────────────────────────────────────────────────────
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // empty')

# ── Rate limits (Claude.ai subscription) ───────────────────────────────────
five_pct=$(echo   "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at       // empty')
week_pct=$(echo   "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
week_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at       // empty')

# ── Effort / thinking ───────────────────────────────────────────────────────
effort=$(echo "$input" | jq -r '.effort.level // empty')
thinking=$(echo "$input" | jq -r 'if .thinking.enabled then "think" else empty end')

# ── Vim mode ────────────────────────────────────────────────────────────────
vim_mode=$(echo "$input" | jq -r '.vim.mode // empty')

# ── 5h reset countdown ──────────────────────────────────────────────────────
five_countdown=""
if [ -n "$five_reset" ]; then
  now_epoch=$(date +%s)
  diff=$(( five_reset - now_epoch ))
  if [ "$diff" -gt 0 ]; then
    hrs=$(( diff / 3600 ))
    mins=$(( (diff % 3600) / 60 ))
    five_countdown=$(printf "%dh %02dm" "$hrs" "$mins")
  fi
fi

# ── 7d pace gate (show only when ahead of linear pace) ──────────────────────
show_week=false
if [ -n "$week_pct" ] && [ -n "$week_reset" ]; then
  now_epoch=$(date +%s)
  SEVEN_DAYS=604800
  elapsed=$(( SEVEN_DAYS - (week_reset - now_epoch) ))
  if [ "$elapsed" -gt 0 ]; then
    over_pace=$(awk "BEGIN { print ($week_pct > ($elapsed / $SEVEN_DAYS) * 100) ? 1 : 0 }")
    [ "$over_pace" = "1" ] && show_week=true
  fi
fi

# ── Build the output line ───────────────────────────────────────────────────
# Colours — Gruvbox Material Hard Dark fall palette
# ANSI slots: green=#a9b665 magenta=#d3869b red=#ea6962
# True-color: brick=#bf4b46 orange=#e78a4e burnt=#c0540e steel=#6d8494
OLIVE='\033[0;32m'
BRICK='\033[38;2;191;75;70m'
STEEL='\033[38;2;109;132;148m'
ORANGE='\033[38;2;231;138;78m'
BURNT='\033[38;2;192;84;14m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

parts=()

# Model — olive green
parts+=("$(printf "${OLIVE}%s${RESET}" "$model")")

# Directory — amber, only when outside the repo root (or not in a git repo)
if [ -n "$cwd" ]; then
  git_root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)
  if [ -z "$git_root" ] || [ "$cwd" != "$git_root" ]; then
    parts+=("$(printf "${YELLOW}%s${RESET}" "$short_cwd")")
  fi
fi

# Repo — red, primary identifier
if [ -n "$repo" ]; then
  repo_str="$repo"
  [ -n "$pr_num" ] && repo_str="$repo_str PR#${pr_num}(${pr_state})"
  parts+=("$(printf "${BRICK}%s${RESET}" "$repo_str")")
fi

# Session tokens — warm cream, secondary info
if [ -n "$total_input" ] && [ -n "$total_output" ]; then
  total_tokens=$(( total_input + total_output ))
  if [ "$total_tokens" -ge 1000 ]; then
    tok_str=$(awk "BEGIN {printf \"%.1fk\", $total_tokens/1000}")
  else
    tok_str="$total_tokens"
  fi
  parts+=("$(printf "${STEEL}tok:%s${RESET}" "$tok_str")")
fi

# 5h rate limit + countdown — amber normally, red when ≥80%
if [ -n "$five_pct" ]; then
  five_int=$(printf '%.0f' "$five_pct")
  rate_str="5h:${five_int}%"
  [ -n "$five_countdown" ] && rate_str="$rate_str ($five_countdown)"
  if [ "$five_int" -ge 80 ]; then
    parts+=("$(printf "${RED}%s${RESET}" "$rate_str")")
  else
    parts+=("$(printf "${ORANGE}%s${RESET}" "$rate_str")")
  fi
fi

# 7d rate limit — red, only when over pace
if $show_week; then
  week_int=$(printf '%.0f' "$week_pct")
  parts+=("$(printf "${RED}7d:%d%%${RESET}" "$week_int")")
fi

# Effort / thinking — burnt orange
if [ -n "$effort" ]; then
  parts+=("$(printf "${BURNT}effort:%s${RESET}" "$effort")")
elif [ -n "$thinking" ]; then
  parts+=("$(printf "${BURNT}thinking${RESET}")")
fi

# Vim mode — rose accent
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

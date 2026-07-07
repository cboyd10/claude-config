#!/usr/bin/env bash
# Claude Code status line script
# Receives JSON via stdin; outputs a single status line string.

input=$(cat)
MODE=$(cat "$HOME/.claude/statusline_mode" 2>/dev/null || echo "default")

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

# ── Colours — Gruvbox Material Hard Dark fall palette ──────────────────────
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

# ── Cost mode ──────────────────────────────────────────────────────────────
if [ "$MODE" = "cost" ]; then
  # Pricing lookup by model ID ($/token = $/MTok ÷ 1,000,000)
  model_id=$(echo "$input" | jq -r '.model.id // .model.name // ""')
  case "$model_id" in
    *sonnet*4*6*)  INPUT_PRICE="0.000003";  OUTPUT_PRICE="0.000015"  ;;  # $3/$15 per MTok
    *opus*4*)      INPUT_PRICE="0.000015";  OUTPUT_PRICE="0.000075"  ;;  # $15/$75 per MTok
    *haiku*4*5*)   INPUT_PRICE="0.0000008"; OUTPUT_PRICE="0.000004"  ;;  # $0.80/$4 per MTok
    *)             INPUT_PRICE="0.000003";  OUTPUT_PRICE="0.000015"  ;;  # sonnet default
  esac

  cur_in="${total_input:-0}"
  cur_out="${total_output:-0}"

  # Format a raw token count as Mk / Xk / plain integer
  _fmt_tok() {
    local n="${1:-0}"
    if [ "$n" -ge 1000000 ] 2>/dev/null; then
      awk "BEGIN {printf \"%.1fM\", $n/1000000}"
    elif [ "$n" -ge 1000 ] 2>/dev/null; then
      awk "BEGIN {printf \"%.1fk\", $n/1000}"
    else
      echo "$n"
    fi
  }

  # Cross-session window token accumulator.
  # Reads/writes a JSON state file; sets globals _WIN_IN and _WIN_OUT.
  # State format: {"resets_at":N,"accum_in":N,"accum_out":N,"prev_in":N,"prev_out":N}
  _track_window() {
    local state_file="$1" cur_reset="${2:-0}" cur_in_v="${3:-0}" cur_out_v="${4:-0}"
    local stored_reset=0 accum_in=0 accum_out=0 prev_in=0 prev_out=0

    if [ -f "$state_file" ]; then
      stored_reset=$(jq -r '.resets_at // 0' "$state_file" 2>/dev/null || echo 0)
      accum_in=$(    jq -r '.accum_in  // 0' "$state_file" 2>/dev/null || echo 0)
      accum_out=$(   jq -r '.accum_out // 0' "$state_file" 2>/dev/null || echo 0)
      prev_in=$(     jq -r '.prev_in   // 0' "$state_file" 2>/dev/null || echo 0)
      prev_out=$(    jq -r '.prev_out  // 0' "$state_file" 2>/dev/null || echo 0)
    fi

    if [ "$cur_reset" != "${stored_reset:-0}" ]; then
      # Rate-limit window rolled over — start fresh
      accum_in=0; accum_out=0; prev_in=0; prev_out=0
    elif [ "${cur_in_v:-0}" -lt "${prev_in:-0}" ] 2>/dev/null; then
      # Session token count went backwards — new Claude Code session started
      accum_in=$(( accum_in + prev_in ))
      accum_out=$(( accum_out + prev_out ))
      prev_in=0; prev_out=0
    fi

    printf '{"resets_at":%s,"accum_in":%s,"accum_out":%s,"prev_in":%s,"prev_out":%s}\n' \
      "$cur_reset" "$accum_in" "$accum_out" "$cur_in_v" "$cur_out_v" > "$state_file"

    _WIN_IN=$(( accum_in + cur_in_v ))
    _WIN_OUT=$(( accum_out + cur_out_v ))
  }

  # Try raw window token fields first (may be absent in current JSON schema)
  five_in_raw=$(echo "$input"  | jq -r '.rate_limits.five_hour.used_input_tokens  // empty')
  five_out_raw=$(echo "$input" | jq -r '.rate_limits.five_hour.used_output_tokens // empty')
  week_in_raw=$(echo "$input"  | jq -r '.rate_limits.seven_day.used_input_tokens  // empty')
  week_out_raw=$(echo "$input" | jq -r '.rate_limits.seven_day.used_output_tokens // empty')

  FIVE_STATE="$HOME/.claude/statusline_5h_state"
  SEVEN_STATE="$HOME/.claude/statusline_7d_state"

  if [ -n "$five_in_raw" ]; then
    five_win_in="$five_in_raw"; five_win_out="${five_out_raw:-0}"
  else
    _track_window "$FIVE_STATE" "${five_reset:-0}" "$cur_in" "$cur_out"
    five_win_in="$_WIN_IN"; five_win_out="$_WIN_OUT"
  fi

  if [ -n "$week_in_raw" ]; then
    week_win_in="$week_in_raw"; week_win_out="${week_out_raw:-0}"
  else
    _track_window "$SEVEN_STATE" "${week_reset:-0}" "$cur_in" "$cur_out"
    week_win_in="$_WIN_IN"; week_win_out="$_WIN_OUT"
  fi

  # Dollar costs
  session_in_cost=$( awk "BEGIN { printf \"%.4f\", ${cur_in}           * $INPUT_PRICE }")
  session_out_cost=$(awk "BEGIN { printf \"%.4f\", ${cur_out}          * $OUTPUT_PRICE }")
  session_total=$(   awk "BEGIN { printf \"%.4f\", ${cur_in}           * $INPUT_PRICE + ${cur_out}          * $OUTPUT_PRICE }")
  five_cost=$(       awk "BEGIN { printf \"%.4f\", ${five_win_in:-0}   * $INPUT_PRICE + ${five_win_out:-0}  * $OUTPUT_PRICE }")
  week_cost=$(       awk "BEGIN { printf \"%.4f\", ${week_win_in:-0}   * $INPUT_PRICE + ${week_win_out:-0}  * $OUTPUT_PRICE }")

  in_str=$( _fmt_tok "$cur_in")
  out_str=$(_fmt_tok "$cur_out")

  parts=()
  parts+=("$(printf "${OLIVE}%s${RESET} ${MAGENTA}(cost)${RESET}" "$model")")
  parts+=("$(printf "${STEEL}%s in (\$%s)${RESET}"  "$in_str"  "$session_in_cost")")
  parts+=("$(printf "${STEEL}%s out (\$%s)${RESET}" "$out_str" "$session_out_cost")")
  parts+=("$(printf "${OLIVE}session \$%s${RESET}"  "$session_total")")
  parts+=("$(printf "${ORANGE}5h \$%s${RESET}"      "$five_cost")")
  parts+=("$(printf "${BURNT}7d \$%s${RESET}"       "$week_cost")")

  sep=" | "
  result=""
  for part in "${parts[@]}"; do
    [ -z "$result" ] && result="$part" || result="${result}${sep}${part}"
  done
  printf "%b\n" "$result"
  exit 0
fi

# ── Default mode ────────────────────────────────────────────────────────────
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

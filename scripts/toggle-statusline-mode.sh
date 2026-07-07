#!/usr/bin/env bash
STATE="$HOME/.claude/statusline_mode"
current=$(cat "$STATE" 2>/dev/null || echo "default")
[ "$current" = "default" ] && echo "cost" > "$STATE" || echo "default" > "$STATE"

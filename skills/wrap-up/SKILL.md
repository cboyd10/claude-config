---
name: wrap-up
description: Gracefully end a session that has grown long (around 100-120K tokens) by writing a handoff so the next session can resume without re-grilling. Two modes, detected from the session: planning sessions write ready issue files and PLANNING-HANDOFF.md into the planning folder; implementation sessions (pickup-issue, pickup-issue-personal, address-pr-comments) write IMPLEMENTATION-HANDOFF.md into the worktree recording slice state, commits, and verification state. Invoke with /wrap-up.
---

# wrap-up

Gracefully close a long session. The goal is a clean handoff so the next Claude Code
session can resume without re-grilling decisions already made or re-deriving state
already reached.

## When to run

The user invokes `/wrap-up` explicitly — typically when approaching 100–120K tokens.
Do not run automatically.

## Mode detection

Pick the mode from what this session actually did, then read ONLY the matching
supporting file in this skill directory:

- **Planning mode** — the session worked in a planning folder
  (`.claude/jira-planning/...`): grilling a feature, breaking down issues, any
  plan-with-me flow. Follow `PLANNING.md`.
- **Implementation mode** — the session implemented inside a Git worktree via
  pickup-issue, pickup-issue-personal, or address-pr-comments. Follow
  `IMPLEMENTATION.md`.
- **Ambiguous** — the session did both (e.g. planned, then picked up an issue), or
  neither cleanly. Ask the user one question: which handoff (or both) do they want.
  Then follow the corresponding file(s).

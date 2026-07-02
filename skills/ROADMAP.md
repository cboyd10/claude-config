# Skill roadmap — deferred work

Seed notes for future skill-building sessions. Each entry gets its own
grill-with-docs session. Written 2026-07-02 during the Sonnet-readiness audit.

## 2. documentation formats + keep-docs-updated

Create/maintain repo documentation so a brand-new junior dev with little
experience can build product knowledge quickly. Two-part shape, mirroring
jira-formats + plan-to-jira: a formats/conventions skill and a doing skill.

User's framing, verbatim: "I'd like to explore a documentation format (e.g.,
what goes in the README.md, what goes in a root docs folder, what goes in
service/client README.md or docs folder) and how the documentation relates and
builds an easy to navigate picture a brand new junior dev with little
experience could use to gain product knowledge quickly."

- Decide the layered map: root README vs `docs/` vs per-service/client README
  vs `.claude/context/` (CONTEXT.md/ADRs already have owners — don't overlap).
- "Keep up to date" mode: detect drift between docs and code; "create" mode:
  bootstrap docs where none exist.

## 3. iOS-chat grilling variant

A grill-with-docs adaptation for plain Claude chat on iOS (NOT the iOS Claude
Code feature, which is full Claude Code and needs no variant). Constraints
learned 2026-07-02:

- No Agent tool, no filesystem, no git. Skills arrive via `ios-instructions.md`
  raw-URL fetches.
- Codebase grounding must come from raw GitHub URLs (public repos) or the
  GitHub connector — work repos are likely unreachable; scope may be
  personal-projects-only or "grill from pasted context."
- Output artifact must be chat text the user copies (no files to write) — maybe
  a paste-ready PLANNING-HANDOFF block that a later CLI session can consume.

## 4. Implementation wrap-up

`wrap-up` is planning-only. pickup-issue anticipates resumed pickups ("if the
worktree path already exists, reuse it") but nothing writes the handoff a
resumed implementation session needs: which TDD slice was in flight, commits
made vs pending, alignment summary, verification state. Long implementation
sessions hit 120K just like planning ones.

## 5. bootstrap-context

One-shot skill: explore a repo (delegated per EXPLORATION.md) and draft an
initial `.claude/context/CONTEXT.md` glossary + orientation brief for legacy
repos that have none. Cuts the cold-start ORIENT tax; doubles as junior
onboarding material.

## 6. skill-retro (standalone)

The retrospective phase exists only inside plan-with-me. Pickup and
address-pr-comments sessions generate the same signal (corrections, repeated
context, afk-downgrades) but nothing harvests it. A `/skill-retro` invocable at
the end of any session. Same approval gate: propose exact edits, never apply
without explicit yes.

## 7. debug-problems

Requested 2026-07-02, not yet grilled. A skill for systematically debugging
problems. Open questions for its grilling session: scope (work stack only, or
stack-agnostic?), entry point (bug ticket, error message, "it's broken"
report?), relationship to pickup-issue's Bug flow, and how it uses delegation
per EXPLORATION.md to trace behavior without flooding main-session context.

## Pending chore

- Regenerated `ios-instructions.md` (now includes `review-pr`) needs commit +
  push to `cboyd10/claude-config` main (user does this manually). The repo copy
  is also missing `address-pr-comments` and the new `review-pr` skill directory,
  plus the `bitbucket_pr_to_review` script's home if it should live in the repo.

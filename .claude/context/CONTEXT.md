# Context: claude-config skill suite

The shared vocabulary of the skills in this repo: the artifacts they produce and
consume, and the session phases they orchestrate. Terms defined by an individual
skill's format file are only listed here when other skills consume them.

## Terms

### Session handoffs

**PLANNING HANDOFF**:
The document a wrapped planning session emits so a later session can resume
planning without re-grilling decisions already made. Written by wrap-up to the
session's planning folder as `PLANNING-HANDOFF.md`; consumed by plan-with-me's
resume path.

**IMPLEMENTATION HANDOFF**:
The document a wrapped implementation session emits so a later session can
resume implementing without re-grilling or re-orienting. Written by wrap-up to
`.claude/wrap-up/IMPLEMENTATION-HANDOFF.md` inside the issue's worktree (never
committed); records the alignment summary, TDD slice state (done / in flight /
remaining), commits made vs pending work, verification state, and the
originating skill to re-invoke. Consumed by the ORIENT phases of pickup-issue,
pickup-issue-personal, and address-pr-comments.

### Ideation artifacts

**IDEA BRIEF**:
The single consolidated handoff document a flesh-out session emits for an idea
that ends in a new repo. One copyable chat-text block containing the refined
pitch, decisions made with rationale, rejected alternatives, research findings,
open questions, and delimited seed-file sections a later CLI session
materializes into real files. Format per `BRIEF-FORMAT.md`.

**RUNBOOK**:
The handoff document a flesh-out session emits for a goal the user executes
directly (no repo results). Shares the IDEA BRIEF's alignment front matter
(refined goal, decisions, rejected alternatives, open risks), then a sequenced
step list where each step carries an expected result and a verify-before-continuing
checkpoint, plus rollback notes for risky steps. Format per `RUNBOOK-FORMAT.md`.

## Relationships

- A wrapped session emits exactly one of **PLANNING HANDOFF** or
  **IMPLEMENTATION HANDOFF**; wrap-up picks by session type (planning folder
  active vs implementation worktree active).
- An **IMPLEMENTATION HANDOFF** lives and dies with its worktree: one per
  worktree, deleted once a resumed session has caught up.
- A flesh-out session emits exactly one of **IDEA BRIEF** or **RUNBOOK**; the
  fork is chosen at intake by whether the idea ends in a repo or in steps the
  user executes.
- An **IDEA BRIEF** is consumed by a later Claude session (materializing a new
  repo, or as input to a planning session); a **RUNBOOK** is consumed by the
  user directly.

# Context: claude-config skill suite

The shared vocabulary of the skills in this repo: the artifacts they produce and
consume, and the session phases they orchestrate. Terms defined by an individual
skill's format file are only listed here when other skills consume them.

## Terms

### Ideation artifacts

**IDEA BRIEF**:
The single consolidated handoff document an ideation session emits for an idea
that ends in a new repo. One copyable chat-text block containing the refined
pitch, decisions made with rationale, rejected alternatives, research findings,
open questions, and delimited seed-file sections a later CLI session
materializes into real files. Format per `BRIEF-FORMAT.md`.

**RUNBOOK**:
The handoff document an ideation session emits for a goal the user executes
directly (no repo results). Shares the IDEA BRIEF's alignment front matter
(refined goal, decisions, rejected alternatives, open risks), then a sequenced
step list where each step carries an expected result and a verify-before-continuing
checkpoint, plus rollback notes for risky steps. Format per `RUNBOOK-FORMAT.md`.

## Relationships

- An ideation session emits exactly one of **IDEA BRIEF** or **RUNBOOK**; the
  fork is chosen at intake by whether the idea ends in a repo or in steps the
  user executes.
- An **IDEA BRIEF** is consumed by a later Claude session (materializing a new
  repo, or as input to a planning session); a **RUNBOOK** is consumed by the
  user directly.

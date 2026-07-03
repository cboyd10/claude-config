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

### Context artifacts

**BOUNDED CONTEXT**:
A scope within which the glossary's terms carry one consistent meaning. A repo
spanning more than one gets a `CONTEXT-MAP.md` routing to per-context
`CONTEXT.md` files; crossing one is a **SCOPE GATE** trigger and a natural
deconstruction seam.

**ORIENTATION BRIEF**:
The repo-level structural map bootstrap-context derives from one delegated
exploration, persisted as `.claude/context/ORIENTATION.md` with a
`Derived: {date} at commit {hash}` staleness header. A map, not truth:
regenerated wholesale on each bootstrap-context re-run, never maintained
incrementally. Consumed by ORIENT phases (per `grill-with-docs/EXPLORATION.md`)
to narrow or skip exploration, and by juniors as onboarding material. Format
per `bootstrap-context/ORIENTATION-FORMAT.md`.

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

### Autonomy labels

**AFK**:
An autonomy label ("away from keyboard") on a personal GitHub issue asserting
an agent can implement it unattended: every design decision is pre-made in the
issue text and justified under its `## Autonomy` section. Set by
plan-to-github at creation; read by pickup-issue-personal to skip grilling.

**HITL**:
The opposing autonomy label ("human in the loop"): the issue needs live
judgment, so pickup runs a full grilling session before implementing.

**AFK SELF-DOWNGRADE**:
The safety valve on **AFK**: when orientation surfaces real ambiguity, the
pickup agent stops, relabels the issue **HITL**, and waits — it never guesses
through an ambiguity the label promised was absent.

### Planning records

**PENDING-N SLUG**:
A sequential placeholder (`PENDING-1`, `PENDING-2`, …) naming work-flow issue
files whose real Jira keys don't exist yet; `jira_sync.py` fills the real keys
after manual Jira entry. Work flows only.

**DECISIONS MADE THIS SESSION**:
The `## Decisions made this session` section of a planning session's
OVERVIEW.md: each entry records what was decided, the alternatives rejected
and why, and the issue slugs touched. The rationale source update-docs
harvests when writing post-implementation ADRs.

### Gates & protocols

**ADR TEST**:
The three-part gate a decision must fully pass to earn an ADR: hard to
reverse AND surprising without context AND a real trade-off. All three, or no
ADR.

**SCOPE GATE**:
grill-with-docs' stop condition: when scope spans more than one **BOUNDED
CONTEXT**, bundles independent sub-goals sharing no resolved decision, or
exceeds 72 hours of estimated implementation work, grilling stops and
/deconstruct is recommended.

**RESUME CONTRACT**:
The protocol an ORIENT phase follows on finding a worktree with an
**IMPLEMENTATION HANDOFF**: verify the handoff's claims against git, skip
already-aligned items, land in the phase it names, and delete the handoff once
caught up.

### Implementation

**VERTICAL SLICE**:
tdd's unit of work: one behavior driven end-to-end by a single test before
the next begins, tracer-bullet style. Horizontal slicing (all tests, then all
code) is the named anti-pattern. Slice state (done / in flight / remaining)
is what an **IMPLEMENTATION HANDOFF** records.

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
- An **ORIENTATION BRIEF** is refreshed only by re-running bootstrap-context;
  the glossary beside it grows additively across grilling sessions and is
  never clobbered by a refresh.
- Every personal GitHub issue carries exactly one of **AFK** or **HITL**; an
  **AFK SELF-DOWNGRADE** moves an issue from AFK to HITL, and nothing moves it
  back automatically.
- A decision passing the **ADR TEST** during planning is recorded under
  **DECISIONS MADE THIS SESSION**; update-docs harvests that entry into an ADR
  post-implementation.
- The **SCOPE GATE** hands an oversized scope to deconstruct, which splits it
  along **BOUNDED CONTEXT** and sub-goal seams.
- An **IMPLEMENTATION HANDOFF** records **VERTICAL SLICE** state; the **RESUME
  CONTRACT** is how a later session consumes and retires it.

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
The default autonomy label ("away from keyboard") on a personal GitHub issue,
asserting an agent can implement it unattended: every design decision is
pre-made in the issue text and justified under its `## Autonomy` section.
Every issue leaves planning as **AFK** unless it qualifies for **HITL** — if
Claude Code can do the work inside the codebase and tooling it has access to
and it isn't a security concern, it's AFK. Set by plan-to-github at creation;
read by pickup-issue-personal to skip grilling.

**HITL**:
The opposing autonomy label ("human in the loop"), reserved for issues
containing a step Claude Code can't or genuinely shouldn't perform itself
even though the design is fully aligned — secrets/encrypted material,
human-only auth ceremonies, irreversible external actions, spending money,
external service provisioning (categories per github-formats). Never a
parking spot for unfinished design: an unresolved decision means the issue
isn't created yet. Its second cause is the **AFK SELF-DOWNGRADE**; the
issue's `## Autonomy` line names which cause applies, and pickup reads it to
choose between a go/no-go with a pause at the human step and a full grilling
session.

**AFK SELF-DOWNGRADE**:
The safety valve on **AFK**: when orientation surfaces real ambiguity, the
pickup agent stops, relabels the issue **HITL**, and waits — it never guesses
through an ambiguity the label promised was absent. In **UNATTENDED MODE**
there is no user to wait for: the downgrade relabels, comments the cause on
the issue, and aborts that pickup instead.

### Sweep

**SWEEP**:
The batch-autonomy flow (sweep-issues-personal): work a repo's open **AFK**
backlog in dependency order via concurrent unattended pickups (default cap 3),
opening a PR per issue, until every dispatchable issue is in PR or the usage
limit kills the run. **HITL** issues and everything transitively downstream of
one are excluded from the pool. Every state transition is persisted to GitHub
as it happens; re-running the sweep is the resume mechanism.

**UNATTENDED MODE**:
The sweep-invoked variant of pickup-issue-personal: the Phase 3 go/no-go is
auto-granted (that is the **AFK** label's promise), browser verification is
skipped, and an **AFK SELF-DOWNGRADE** ends the pickup rather than starting a
grilling session.

**DEPENDS-ON LINE**:
The canonical machine-readable dependency signal: a `Depends on #<N>` line in
an issue's `## Context` section, one blocker per line. Written by
plan-to-github; read by the **SWEEP** to build its dependency graph. Sole
signal until the GitHub MCP exposes native blocked-by relationships (ROADMAP
seed).

**STACKED PR**:
A PR whose base is an unmerged blocker's branch instead of `main`, created
when the **SWEEP** dispatches a blocked issue after its blocker's PR reaches
ready-for-review. Merged bottom-up: blocker to `main` first (GitHub retargets
the child on branch deletion), then the child — so `Closes #<N>` fires for
every issue. With exactly two unmerged blockers the child bases on the
lowest-numbered one and merges the other in (octopus); three or more unmerged
blockers means the issue waits.

**SWEEP-BLOCKED**:
The label recording a hard **SWEEP** failure (unfixable CI, crash) on an issue
that also keeps `in-progress`; the failure detail lives in an issue comment.
Dependents are skipped for the rest of that run. Cleared when a rerun
re-dispatches the issue.

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

### Styling

**COMPONENT BRIEF**:
The document build-style-guide's Phase 2 derives from an approved style-guide
page: an inventory of components to build, each entry naming its BEM
block/partial, a sketch of the component API, existing-app usages to convert
(file citations), and sequencing. Written in the client worktree; consumed by
plan-with-me (work) or plan-with-me-personal (personal) as grilling input for
the component-library conversion issues.

### Debugging

**DIAGNOSIS**:
The deliverable of a debug-problems session: a Bug issue whose text records
the confirmed root cause, the evidence for it (file:line citations), and
reproduction steps. Work flows emit it as a paste-ready Jira Bug per
jira-formats; personal flows write it to a GitHub issue via the MCP. Drafted
as a new issue when none exists. Consumed by the pickup flows' normal ORIENT
phase — debug-problems never implements the fix.

**INVESTIGATION LOG**:
The partial-state record a debug-problems session writes to the issue when it
wraps before the root cause is confirmed: the reproduction recipe, hypotheses
killed (with the evidence that killed them), and hypotheses surviving. Same
home and transport as the **DIAGNOSIS** (paste-ready Jira comment for work,
GitHub issue comment for personal). A resumed debug-problems session reads it
and skips dead hypotheses. Debug sessions wrap themselves — wrap-up's two
handoff types do not apply (no planning folder, no worktree).

### Retrospective

**RETRO SIGNAL**:
Session evidence worth harvesting into skill improvements: repeated context the
user had to explain, corrections to assumptions, new stable preferences, missing
template coverage, and (in implementation sessions) **AFK SELF-DOWNGRADE**s or
grilling questions the issue text should have pre-answered. Generated by any
session type; harvested by skill-retro.

**SEED ENTRY**:
An entry in `skills/ROADMAP.md` deferring skill work too large for an inline
edit — each seeds its own future grill-with-docs session. The landing place for
oversized retro findings.

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
- A **SWEEP** dispatches each pool issue as a pickup-issue-personal run in
  **UNATTENDED MODE**; the **DEPENDS-ON LINE** graph sets dispatch order, and
  a blocked issue lands as a **STACKED PR** on its blocker's branch.
- A mid-sweep **AFK SELF-DOWNGRADE** or **SWEEP-BLOCKED** failure removes that
  issue's transitive dependents from the rest of the run, exactly as a
  planning-time **HITL** label does up front.
- A decision passing the **ADR TEST** during planning is recorded under
  **DECISIONS MADE THIS SESSION**; update-docs harvests that entry into an ADR
  post-implementation.
- The **SCOPE GATE** hands an oversized scope to deconstruct, which splits it
  along **BOUNDED CONTEXT** and sub-goal seams.
- An **IMPLEMENTATION HANDOFF** records **VERTICAL SLICE** state; the **RESUME
  CONTRACT** is how a later session consumes and retires it.
- Every session type emits **RETRO SIGNAL**; skill-retro turns it into approved
  skill-file edits, or a **SEED ENTRY** when the finding outgrows an edit.

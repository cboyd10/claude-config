# wrap-up — implementation mode

Close a long implementation session (pickup-issue, pickup-issue-personal, or
address-pr-comments) so a fresh session can re-invoke the originating skill and
resume mid-implementation without re-grilling alignment or re-deriving state.

## Steps

### 1. Reach the cheapest resumable state

A GREEN, committed checkpoint is the cheapest state to resume from, but don't burn
the tokens you're wrapping to save:

- Working tree clean and tests GREEN: nothing to do here.
- Mid-slice, and finishing the slice (or cleanly reverting it) is small relative to
  the remaining budget: ask the user ONE question offering to close it out to a
  GREEN, committed checkpoint first.
- Otherwise leave the working tree untouched and snapshot its exact state in the
  handoff instead.

Never auto-commit a RED state — it pollutes branch history and, in the personal
flow, fails CI on the draft PR.

### 2. Sync outward (personal flow only)

- **pickup-issue-personal:** push any committed-but-unpushed commits so the draft
  PR and CI reflect everything committed locally. Do not comment on the issue or
  PR — the `in-progress` label already tells the story, and the handoff is local
  by design.
- **pickup-issue / address-pr-comments (work repos):** purely local. These flows
  don't push on your behalf; wrap-up doesn't either.

### 3. Write IMPLEMENTATION-HANDOFF.md

Write `.claude/wrap-up/IMPLEMENTATION-HANDOFF.md` inside the worktree (one handoff
per worktree — untracked files are per-worktree, so it travels with its issue).
Never commit it: if the repo does not already ignore `.claude/`, add the path to
`.git/info/exclude` (local-only ignore; doesn't touch the repo's `.gitignore`).

Reconstruct the slice list from session memory, but verify done-ness against the
test files on disk — the test suite is the durable ground truth for what's GREEN.

```markdown
# Implementation Handoff — {issue slug, issue #N, or PR}

**Date wrapped:** {YYYY-MM-DD}
**Originating skill:** {pickup-issue | pickup-issue-personal | address-pr-comments}
**Resume command:** {`/pickup-issue {SLUG} {summary}` | `/pickup-issue-personal #{N}` | `/address-pr-comments {PR}`}
**Worktree:** {path} — branch `{branch}`, base `{base-branch}`
**Issue / PR:** {Jira slug; or GitHub issue #N + draft PR #M and current labels}

## Previously on...

{2–5 sentence narrative: the problem, the agreed change, and how far implementation
got this session. Write it so a fresh Claude feels caught up after this paragraph.}

## Aligned

{The confirmed Phase 3 alignment summary — problem, change, affected files/layers,
TDD applies yes/no, out of scope — plus any decisions made during implementation.
For address-pr-comments, embed the confirmed triage table with a status column
(fixed / in flight / not started) instead. Flag load-bearing decisions with an
indented "> **Why this matters:**" note, as in planning handoffs.}

## Implementation state

- Slices/behaviors: {one line each — ✅ done (name the test), 🔧 in flight, ⬜ remaining}
- Commits made: {one line each — short hash + subject}
- Working tree: {clean | list uncommitted files; if mid-slice, whether the in-flight
  test is RED or GREEN and the minimal remaining change to finish it}
- Pushed: {yes / no / n-a — personal flow should be yes for all commits after step 2}

## Verification state

{What has and hasn't been verified: test suite last run + result, lint/static
analysis, CI status on the draft PR, browser verification done/pending/declined.}

## Not yet aligned

{Open questions or deferred threads, if any. Address these first on resume.}

## Resume from

{Imperative briefing: which phase of the originating skill to land in and the
specific next action. Example: "Resume at Phase 5 — IMPLEMENT. Next slice: 'user
can filter masters by term'. Write its RED test first; the pattern is
MasterListComponent.spec.ts."}
```

### 4. Print session-closed summary

```
Session wrapped. Handoff written to {worktree}/.claude/wrap-up/IMPLEMENTATION-HANDOFF.md

State at wrap: {N} slices done, {in-flight slice or "tree clean"}, {commits} commits{, pushed}.

To resume: open a new Claude Code session and run:
  {resume command}
The skill will detect the existing worktree and handoff, and skip straight to the
in-flight phase.
```

## The resume contract (consumed by the three flows)

The ORIENT phase of each originating skill checks for this handoff when its worktree
already exists. On resume, the skill:

1. Reads the handoff and verifies it against reality — `git log`/`git status` match
   the recorded commits and tree state; if they diverge, trust the repo and say so.
2. Skips re-grilling everything under "Aligned"; addresses "Not yet aligned" items
   first.
3. Lands in the phase named under "Resume from".
4. **Deletes the handoff once caught up** — a stale handoff misleading a later
   resume is worse than none. A re-wrap writes a fresh one.

---
name: sweep-issues-personal
description: Autonomously work through a personal repo's open afk GitHub issues in dependency order, dispatching up to N concurrent subagents that each run pickup-issue-personal in UNATTENDED MODE, until every dispatchable issue has a ready-for-review PR or the usage limit ends the run. Blocked issues wait for their blocker's PR to reach ready, then land as STACKED PRs on the blocker's branch. hitl issues and everything transitively downstream of one are skipped. Use when the user invokes /sweep-issues-personal or asks to sweep/batch-work the afk backlog of a personal project. Requires the GitHub MCP. Re-running the sweep resumes an interrupted run.
---

# sweep-issues-personal

You are orchestrating an autonomous sweep of a personal repo's `afk` backlog. You do
not implement anything in this session — every issue is delegated to a subagent
running `pickup-issue-personal` in **UNATTENDED MODE**. Your job is the graph, the
dispatch loop, and the final report.

Read `github-formats` SKILL.md now — it defines the DEPENDS-ON LINE you parse, the
label lifecycle (`afk`/`hitl`, `in-progress`, `in-review`, `sweep-blocked`), and the
stacked-PR conventions the subagents follow.

## Arguments

Everything after `/sweep-issues-personal`, all optional:

- **A number** — the concurrency cap (default **3**).
- **Issue references** (`#12 #14 #15`) or **a milestone name** — narrows the pool.
  Dependencies of a narrowed pool still count for ordering and stacking, but
  out-of-pool issues are never implemented.

## Preconditions

1. **GitHub MCP must be connected.** If not, stop and tell the user to enable it and
   retry. Do not fall back to anything.
2. **Know the target repo** from the working directory's `origin` remote; ask only if
   ambiguous.
3. This flow assumes the user is away. Never block on a question — every judgment
   gap is handled by the self-downgrade path, not by asking.

## The Pipeline

```
1. BUILD GRAPH  →  2. DISPATCH LOOP  →  3. REPORT
```

### Phase 1: BUILD GRAPH

1. **Fetch every open issue** in the repo via MCP, with labels and bodies. Fetch
   recently closed issues' numbers too (closed = satisfied dependency).
2. **Form the pool**: open issues labeled `afk`, narrowed by the argument filter if
   given. Issues labeled `in-review` are not re-dispatched — they count as
   "done enough to stack on" (their branch and ready PR already exist).
3. **Parse dependencies**: DEPENDS-ON LINEs (`Depends on #<N>`, one per line) in each
   issue's `## Context` section, per `github-formats`. A dependency on a closed
   issue is satisfied. Build the dependency graph.
4. **Exclude hitl transitively**: remove every `hitl` issue and everything reachable
   downstream of one. Record each exclusion and its root cause for the report.
5. **Detect cycles**: any dependency cycle excludes its members (with a report entry
   telling the user to fix the issue text). Never guess an order through a cycle.
6. **Detect interrupted work** (this is the resume path): a pool issue labeled
   `in-progress` or `sweep-blocked`, or with an existing worktree
   (`../<repo>-worktrees/issue-<n>-*`) or open draft PR, was started by a previous
   run. Mark it for **resume dispatch** rather than fresh dispatch.

Output a compact plan — dispatchable now, waiting-on-what, excluded-and-why — then
start the loop. Do not wait for approval; the `afk` labels are the approval.

### Phase 2: DISPATCH LOOP

**Dispatchability rule.** An issue is dispatchable when every blocker is either
closed, or has a ready-for-review PR (`in-review`). The base branch follows from the
unmerged-blocker count:

- **0 unmerged** — base `main`; a normal pickup.
- **1 unmerged** — base = that blocker's branch; the PR targets it (STACKED PR).
- **2 unmerged** — octopus: base = the **lowest-numbered** blocker's branch, merge
  the other blocker's branch into the new branch immediately after creation; the PR
  targets the base blocker's branch and its body notes that the diff includes the
  second blocker's commits until that blocker merges.
- **3+ unmerged** — not dispatchable; it waits, and if still waiting at the end it
  is reported as "waiting on multiple blockers — merge some to unblock."

**Dispatch.** Run up to **cap** subagents concurrently (Agent tool, background,
general-purpose). Refill a slot the moment an agent finishes and re-evaluate
dispatchability after every completion — a blocker reaching ready unblocks its
children mid-run. Each subagent gets a self-contained brief:

    Work GitHub issue #<n> in <repo path> by following the pickup-issue-personal
    skill in UNATTENDED MODE (read its SKILL.md and its Unattended mode section;
    read github-formats SKILL.md for conventions).
    Base branch: <main | blocker branch>. <For octopus: "After creating the branch,
    merge origin/<other-blocker-branch> into it before implementing.">
    <For stacked: "Your PR targets <blocker branch>, not main. Body must include
    'Closes #<n>' and the stacked-PR note per github-formats, naming blocker PR
    #<pr>.">
    <For resume dispatch: "This pickup was interrupted. If the worktree contains
    .claude/wrap-up/IMPLEMENTATION-HANDOFF.md follow the resume contract; otherwise
    reconcile from git log, git status, and the PR's current state, then continue.
    Remove the sweep-blocked label when you re-start work.">
    Report back: PR number and state reached, or DOWNGRADED + the cause you wrote
    to the issue, or FAILED + what you recorded on the issue.

**On each completion:**

- **Success** (PR ready, `in-review`) — the issue now satisfies its dependents;
  re-evaluate and dispatch newly unblocked issues.
- **DOWNGRADED** (afk self-downgrade: subagent relabeled `hitl`, commented the
  cause, aborted) — exclude its transitive dependents from the rest of the run.
- **FAILED** (hard failure: unfixable CI, broken environment, crash) — the subagent
  comments its last known state on the issue, keeps `in-progress`, and adds the
  `sweep-blocked` label; if the subagent died without doing so, do it yourself via
  MCP. Exclude its transitive dependents for this run and continue with the rest.

**Persist as you go.** Every state transition must already be on GitHub (labels,
draft PRs, comments) the moment it happens — the subagents' normal lifecycle does
this. If the usage limit kills the run mid-flight, nothing is lost except in-flight
context: re-running `/sweep-issues-personal` is the resume mechanism (Phase 1 step 6
picks the strays back up).

The loop ends when no subagent is in flight and nothing more is dispatchable.

### Phase 3: REPORT

One final message:

1. **PRs opened** — issue, PR, and each stack: `#A (PR X, base main) ← #B (PR Y,
   base issue-A-…)`, with the bottom-up merge order spelled out: merge the base PR
   to main first, delete its branch (enable auto-delete so GitHub retargets the
   children), then merge the children. The sweep NEVER merges anything.
2. **Waiting** — issues with 3+ unmerged blockers, and which merges unblock them.
3. **Skipped** — `hitl` issues and their transitive dependents, each with its root
   cause.
4. **Downgraded** — issues relabeled `hitl` mid-run, with the recorded cause.
5. **Failed** — `sweep-blocked` issues, each linking its failure comment. A rerun
   retries these.

## General conduct

- You orchestrate; subagents implement. Never create worktrees, write code, or open
  PRs from this session.
- Never merge a PR, and never dispatch a `hitl` issue — including human-step `hitl`,
  whose planned pause has no one to hand off to.
- Rely on subagent completion (blocker promoted to ready) to unblock children —
  never poll GitHub in a sleep loop for state this session's own subagents produce.
- CONTEXT.md/ADR collisions between concurrent subagents are absorbed by the
  pickup flow's "pull before writing" rule; conflicts that survive are resolved at
  PR review time by the user.
- If the pool is empty at Phase 1, say so and stop — that is a successful sweep.

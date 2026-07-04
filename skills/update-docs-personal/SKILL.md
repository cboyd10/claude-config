---
name: update-docs-personal
description: Create and maintain a PERSONAL repo's documentation per docs-formats-personal — stack-agnostic, whatever the project is built on. Inventories the repo against the layered map, bootstraps missing docs, detects drift via commit-driven invalidation since the last run, harvests missed ADR candidates from commits merged to main, presents one consolidated findings report with a recommended session scope, grills to alignment, then writes everything in a worktree branch per github-formats. Use when the user invokes /update-docs-personal or asks to create, audit, or update documentation on a personal/GitHub project. The personal counterpart of update-docs.
---

# update-docs-personal

You are creating or updating a personal repo's documentation so a developer who
has never seen the project — future-you included — can build product knowledge
quickly. Read `docs-formats-personal/SKILL.md` now (it will route you through
`docs-formats/SKILL.md` and `docs-formats/ADR-FORMAT.md`) — every doc you touch
follows those formats.

Personal repos, any stack. Same discipline as `update-docs`: there are no
user-selected modes — **the layered map is the checklist**, and each run figures
out create-vs-update per document. The platform deltas: `main` instead of
`master`, GitHub issues instead of Jira slugs, worktree/branch/label conventions
per `github-formats`, and ADRs that are mostly written inline by other sessions
(the harvest here only catches what they missed).

## Pipeline

```
1. STATE → 2. INVENTORY → 3. DRIFT → 4. ADR HARVEST → 5. REPORT & SCOPE
→ 6. GRILL → 7. WRITE → 8. CLOSE
```

Phases 1–5 are read-only. Do not write or edit any doc until Phase 6 alignment is
explicitly confirmed.

### Phase 1: STATE

Read `.claude/update-docs/STATE.md`. Same structure as the work skill's state
file:

```markdown
# update-docs state

## Docs inventory
{One line per doc from the layered map:}
- {doc path} — missing | bootstrapped YYYY-MM-DD | drift-checked YYYY-MM-DD

## Last ADR harvest
Commit: {full SHA on main}

## Active branch
{Branch slug of the in-progress docs branch, if a multi-session effort is underway}

## Session notes
{A few lines per run, newest first: date, what was written, what was
deliberately deferred and why.}
```

If the file is absent (fresh clone, first run — `.claude/` is uncommitted):
rebuild it. Infer the inventory from disk; for the harvest SHA, propose the last
commit that touched `docs/` or `README.md`, or ask the user for a starting point.
Losing STATE.md costs one clarifying question, never correctness.

### Phase 2: INVENTORY

Identify the repo's shape first — single-module or multi-module, and whether it
exposes an API — since that decides which layered-map docs apply (see the
substitution table in `docs-formats-personal`). Then walk the applicable map: for
each expected doc, record **missing** or **exists**. Docs that don't apply to
this project type are recorded as **n/a**, not missing.

### Phase 3: DRIFT

`git fetch origin`, then compute the window: `{last-harvest-SHA}..origin/main`.
For each **existing** doc, apply the three signals from `docs-formats-personal`:

1. **Per-doc-type source signals** — the stack-agnostic table.
2. **Reference invalidation** — grep docs for repo-relative paths and
   class/module names; intersect with `git diff --name-only` over the window.
   Renamed or deleted referenced files are **hard drift**: report as broken
   references without inspection.
3. **Stale threshold** — any doc not fully inspected in 6+ months (per STATE.md
   dates) is flagged "due for a full re-read".

Only docs with tripped signals get inspected. Delegate inspection per
`grill-with-docs/EXPLORATION.md`: ONE Explore agent, its report format, never
parallel fan-outs. Docs with no tripped signals are marked
`drift-checked {today}` in Phase 7 and skipped.

### Phase 4: ADR HARVEST

Personal repos write ADRs inline (pickup Phase 7, grilling sessions,
architecture sessions), so most decisions should already be recorded. This
harvest is a safety net for what slipped through. Over the same commit window:

1. Group commits by branch slug (`issue-<number>-<short-slug>` per
   `github-formats`; merge commits and PR references carry them).
2. Skip any group whose issue already has ADRs in `.claude/context/adr/`
   (match on `issue-<number>-`).
3. For the rest, apply the ADR test: hard to reverse AND surprising without
   context AND a real trade-off. All three, or no candidate. Expect most groups
   to produce nothing.
4. For each candidate, find its rationale: fetch the issue body and PR
   description/discussion via the GitHub MCP — the issue's Context and
   Implementation Notes sections are the planning record. If the MCP is not
   connected or the work was ad-hoc (no issue), infer rationale from the code
   and diff — and mark it **inferred** so the user corrects it during grilling.

### Phase 5: REPORT & SCOPE

Present ONE consolidated findings report, ordered by severity:

1. Hard drift (broken references) — doc, dead reference, what replaced it.
2. Missing docs.
3. Drifted docs — each with the signal that tripped and what changed.
4. ADR candidates — each with its one-line decision and rationale source
   (issue/PR record vs inferred).
5. Due-for-re-read docs.

Then **recommend a session scope**. Bootstrapping a repo's full doc set in one
run will blow the session budget — recommend the subset that fits this session
(quickstart + README first; they unblock a cold reader most), and record the rest
as deferred. Multi-session efforts resume via STATE.md and reuse the same branch.

### Phase 6: GRILL

Follow `grill-with-docs` (read its SKILL.md now if you have not already): one
question at a time, each with a recommended answer; explore the codebase instead
of asking when the code can answer. Align on: the session scope, the content of
each doc to be written or updated (grill hardest on inferred-rationale ADRs and
on troubleshooting/gotcha entries — those encode the user's hard-won knowledge),
and anything the drift inspection found ambiguous.

Alignment is reached only when the user explicitly confirms. Never declare it
yourself.

### Phase 7: WRITE

1. Offer to create a quick GitHub issue for the docs work via the MCP (per
   `github-formats`, labeled `hitl` since grilling already happened) — it gives
   the PR something to close. If the user accepts, the branch slug is
   `issue-<number>-update-docs`; if they'd rather skip the issue, use
   `docs-update-YYYY-MM-DD`. If STATE.md records an active branch from an
   in-progress effort, reuse that branch and worktree instead.
2. Create the worktree and branch, exactly like pickup-issue-personal:
   `git worktree add -b <slug> ../<repo>-worktrees/<slug> origin/main`
3. Write the aligned docs per the docs-formats templates with the
   docs-formats-personal substitutions; write ADRs per `ADR-FORMAT.md` into
   `.claude/context/adr/`, named per `github-formats`.
4. Update `.claude/update-docs/STATE.md` (in the main working tree, not the
   worktree — it is uncommitted and shared across runs): inventory statuses with
   today's date, last-harvest SHA set to the window's end commit, active branch,
   and session notes including every deliberate deferral.

### Phase 8: CLOSE

List every file written or updated with a one-line description, and list what was
deferred and why. Offer to push the branch and open the PR via the GitHub MCP
(body containing `Closes #<number>` when a docs issue exists); if the user
declines, remind them to open it. Do not push without asking.

## General conduct

- Never write docs beyond the aligned session scope — deferrals are recorded,
  not silently absorbed.
- Product docs are written ONLY by this skill's runs; pickup sessions write ADRs
  and CONTEXT.md updates but never product docs. Their merged commits are what
  Phases 3 and 4 detect.
- Keep the junior-first voice even when summarizing dense technical findings —
  the reader is the cold-start developer, not present-you.

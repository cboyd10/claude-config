---
name: update-docs
description: Create and maintain a work repo's junior-first documentation per docs-formats. Inventories the repo against the layered map, bootstraps missing docs, detects drift via commit-driven invalidation since the last run, harvests ADR candidates from commits merged to master, presents one consolidated findings report with a recommended session scope, grills to alignment, then writes everything in a worktree branch named after a Jira slug. Run by the lead only — pickup sessions never write product docs. Use when the user invokes /update-docs or asks to create, audit, or update repo documentation.
---

# update-docs

You are creating or updating this repo's documentation so a brand-new junior
developer can build product knowledge quickly. Read `docs-formats/SKILL.md` and
`docs-formats/ADR-FORMAT.md` now — every doc you touch follows those formats.

Work repos only. There are no user-selected modes: **the layered map is the
checklist** — each run figures out create-vs-update per document.

## Pipeline

```
1. STATE → 2. INVENTORY → 3. DRIFT → 4. ADR HARVEST → 5. REPORT & SCOPE
→ 6. GRILL → 7. WRITE → 8. CLOSE
```

Phases 1–5 are read-only. Do not write or edit any doc until Phase 6 alignment is
explicitly confirmed.

### Phase 1: STATE

Read `.claude/update-docs/STATE.md`. It holds:

```markdown
# update-docs state

## Docs inventory
{One line per doc from the layered map:}
- {doc path} — missing | bootstrapped YYYY-MM-DD | drift-checked YYYY-MM-DD

## Last ADR harvest
Commit: {full SHA on master}

## Active branch
{Jira slug of the in-progress docs branch, if a multi-session effort is underway}

## Session notes
{A few lines per run, newest first: date, what was written, what was
deliberately deferred and why ("skipped debugging guides, user wants them
after LDB-1340 lands").}
```

If the file is absent (fresh clone, first run — `.claude/` is uncommitted):
rebuild it. Infer the inventory from disk (docs that exist are not `missing`);
for the harvest SHA, propose the last commit that touched `docs/`, or ask the
user for a starting point if there is no `docs/` history. Losing STATE.md costs
one clarifying question, never correctness.

### Phase 2: INVENTORY

Identify the repo's modules (backend services, Angular clients), then walk the
docs-formats layered map: for each expected doc, record **missing** or
**exists**. Note legacy ADRs in `.claude/context/adr/` — they are ingestion
candidates for Phase 4, not inventory members.

### Phase 3: DRIFT

`git fetch origin`, then compute the window: `{last-harvest-SHA}..origin/master`.
For each **existing** doc, apply the three signals from docs-formats:

1. **Per-doc-type source signals** — the table in `docs-formats/SKILL.md`.
2. **Reference invalidation** — grep docs for repo-relative paths and class
   names; intersect with `git diff --name-only` over the window. Renamed or
   deleted referenced files are **hard drift**: report as broken references
   without inspection.
3. **Stale threshold** — any doc not fully inspected in 6+ months (per STATE.md
   dates) is flagged "due for a full re-read".

Only docs with tripped signals get inspected. Delegate inspection per
`grill-with-docs/EXPLORATION.md`: ONE Explore agent, its report format, never
parallel fan-outs. Docs with no tripped signals are marked
`drift-checked {today}` in Phase 7 and skipped.

### Phase 4: ADR HARVEST

Over the same commit window:

1. Group commits by Jira slug (branch names are exact slugs; commit messages
   carry them).
2. For each group, apply the ADR test: hard to reverse AND surprising without
   context AND a real trade-off. All three, or no candidate. Expect most groups
   to produce nothing.
3. For each candidate, find its rationale: search
   `.claude/jira-planning/*/OVERVIEW.md` `## Decisions made this session`
   entries mentioning the slug. If found, that entry supplies the alternatives
   and reasoning. If not (hotfix, ad-hoc work), infer rationale from the code
   and diff — and mark it **inferred** so the user corrects it during grilling.
4. Ingest legacy or draft ADRs in `.claude/context/adr/` as candidates too:
   they may be planning-era drafts, so treat their content as rationale input
   and plan to rewrite from the concrete code into `docs/adr/` per
   `ADR-FORMAT.md`.

### Phase 5: REPORT & SCOPE

Present ONE consolidated findings report, ordered by severity:

1. Hard drift (broken references) — doc, dead reference, what replaced it.
2. Missing docs.
3. Drifted docs — each with the signal that tripped and what changed.
4. ADR candidates — each with its one-line decision and rationale source
   (planning record vs inferred).
5. Due-for-re-read docs.

Then **recommend a session scope**. Bootstrapping a legacy repo's full doc set
in one run will blow the session budget — recommend the subset that fits this
session (quickstart + README first; they unblock juniors most), and record the
rest as deferred. Multi-session efforts resume via STATE.md and reuse the same
branch.

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

1. Ask for the Jira slug (required — the team's process needs an issue behind
   the docs PR; a quick Improvement issue per `jira-formats` covers it). If
   STATE.md records an active branch from an in-progress effort, reuse that
   branch and worktree instead.
2. Create the worktree and branch, exactly like pickup-issue:
   `git worktree add -b {JIRA-SLUG} ../<repo>-worktrees/{JIRA-SLUG} origin/master`
3. Write the aligned docs per `docs-formats` templates; write ADRs per
   `ADR-FORMAT.md`, numbered sequentially in `docs/adr/`. When an ingested
   legacy ADR is rewritten, delete the old file from `.claude/context/adr/` in
   the same change.
4. Update `.claude/update-docs/STATE.md` (in the main working tree, not the
   worktree — it is uncommitted and shared across runs): inventory statuses with
   today's date, last-harvest SHA set to the window's end commit, active branch,
   and session notes including every deliberate deferral.

### Phase 8: CLOSE

List every file written or updated with a one-line description, list what was
deferred and why, and remind the user to open the PR. Do not commit or push
unless the user asks.

## General conduct

- Never write docs beyond the aligned session scope — deferrals are recorded,
  not silently absorbed.
- Product docs are written ONLY by this skill's runs. Pickup sessions never
  write them; their merged commits are what Phase 3 and 4 detect.
- Keep the junior-first voice from docs-formats even when summarizing dense
  technical findings — the reader is the new hire, not the lead.

---
name: wrap-up
description: Gracefully end a planning session that has grown long (around 100-120K tokens). Writes ready issue files with PENDING-N placeholder slugs, updates 00-overview.md, and writes PLANNING-HANDOFF.md so the next session can resume without re-grilling. Invoke with /wrap-up.
---

# wrap-up

Gracefully close a long planning session. The goal is a clean handoff so the next
Claude Code session can resume without re-grilling decisions already made.

## When to run

The user invokes `/wrap-up` explicitly — typically when approaching 100–120K tokens.
Do not run automatically.

## Steps

### 1. Write ready issue files

Write any issues from the confirmed breakdown that are fully resolved. Use `PENDING-N`
placeholder slugs (e.g., `PENDING-1`, `PENDING-2`) for any issue without a real Jira
key. Number sequentially starting at 1, matching the row order in the issue map.

Sub-tasks within written issues also use `PENDING-N` slugs if keys are unknown —
assign them their own `PENDING-N` numbers continuing the same sequence.

Write files to the current session's planning folder:
- `{planning-folder}/PENDING-1.md`
- `{planning-folder}/PENDING-2.md`
- etc.

Do not write issue files that are not yet fully resolved — list them under "Issues
pending" in the handoff instead.

### 2. Update 00-overview.md

If `00-overview.md` already exists, update the issue map table so that:
- Written issues show their `PENDING-N` slug in the `Jira Slug` column
- Unwritten issues have a blank `Jira Slug` cell
- Sub-task rows (`N.M`) are present for all issues in the breakdown

If `00-overview.md` does not yet exist (wrap-up happened before issue writing began),
write it now with the confirmed breakdown as the issue map table.

### 3. Write PLANNING-HANDOFF.md

Write `PLANNING-HANDOFF.md` into the current planning folder using this structure:

```markdown
# Planning Handoff — {feature-slug or epic-slug}

**Date wrapped:** {YYYY-MM-DD}
**Phase at wrap-up:** {e.g., "Phase 2: GRILL — open questions remain" or "Phase 3: CONFIRM ALIGNMENT — junior dev check in progress"}
**Epic:** {slug or "none"}
**Planning folder:** {relative path, e.g., .claude/jira-planning/LDB-1200/}

## Original request
{The full feature/change description from the initial invocation, verbatim.}

## Decisions resolved
{Bullet list of every grilling decision confirmed in this session. For load-bearing
decisions — ones that are hard to re-derive from the code, would surprise a future
reader, or constrain future decisions — add an indented "Why this matters" note:}

- Use `term_id` as the join key, not `term_code`
  > **Why this matters:** `term_code` is not unique across legacy Banner imports —
  > existing rows have collisions. Any query joining on `term_code` silently double-counts.
  > This constraint is not visible in the entity class.
- Angular component follows `MasterListComponent` pagination pattern

## Open threads
{Bullet list of questions not yet resolved. These get grilled first in the next
session before continuing.}

## References
{Paths to external repos, files, or docs referenced during this session, with a
one-line note on what each was used for.}

- `/home/user/repos/other-repo/` — enrollment sync pattern being modeled after

## Issues written
| PENDING-N | Title | File |
|-----------|-------|------|
| PENDING-1 | {title} | PENDING-1.md |

## Issues pending (not yet written)
{Titles of issues in the confirmed breakdown that have not been written yet. These
get written in the next session after Jira keys are collected.}

## To do on resume
1. Collect Jira keys: open `00-overview.md`, fill in the `Jira Slug` column for all
   written issues (and sub-tasks), then tell Claude to proceed.
2. Claude will find-and-replace all `PENDING-N` references across written files with
   the real slugs and rename the files accordingly.
3. Continue from: {phase and specific next step}.
```

Claude should flag load-bearing decisions without being asked — a decision is
load-bearing if it meets any of these: hard to re-derive from the code alone,
would surprise a reader without session context, or constrains future decisions in
a non-obvious way.

### 4. Print session-closed summary

After writing all files, print:

```
Session wrapped. Files written to {planning-folder}/:
- PLANNING-HANDOFF.md
- 00-overview.md (updated)
- PENDING-1.md — {title}
- PENDING-2.md — {title}

Issues still pending (not written): {list titles or "none"}

To resume: open a new Claude Code session and run:
  /plan-with-me resume {slug-or-folder-name}
or run /plan-with-me with no args to see all open handoffs.
```

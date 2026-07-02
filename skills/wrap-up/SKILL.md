---
name: wrap-up
description: Gracefully end a planning session that has grown long (around 100-120K tokens). Writes ready issue files with PENDING-N placeholder slugs, updates OVERVIEW.md, and writes PLANNING-HANDOFF.md so the next session can resume without re-grilling. Invoke with /wrap-up.
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

### 2. Update OVERVIEW.md

`OVERVIEW.md` is a strategy doc — shared understanding, out of scope, key decisions,
open risks. Only update it if this session produced new decisions, scope exclusions,
or open questions not already captured there. If `OVERVIEW.md` does not exist yet,
write it now using the template in `plan-to-jira/SKILL.md`.

### 3. Write PLANNING-HANDOFF.md

Write `PLANNING-HANDOFF.md` into the current planning folder using this structure:

```markdown
# Planning Handoff — {feature-slug or epic-slug}

**Date wrapped:** {YYYY-MM-DD}
**Resume command:** `/plan-with-me resume {slug-or-folder-name}`
**Skill chain:** plan-with-me > plan-to-jira > jira-formats (read all before writing any files)
**Wrapped at phase:** Phase {N} - {name, e.g., "4: WRITE ISSUES" or "2: GRILL"}
**Epic:** {slug or "none"}
**Planning folder:** {relative path, e.g., .claude/jira-planning/LDB-1200/}

## Original request
{The full feature/change description from the initial invocation, verbatim.}

## References
{Paths to external repos, files, or docs referenced during this session, with a
one-line note on what each was used for.}

- `/home/user/repos/other-repo/` — enrollment sync pattern being modeled after
- Include `{planning-folder}/ORIENTATION.md` here when it exists — don't restate
  codebase facts the brief already carries.

## Previously on...

{2–5 sentence narrative recap in plain English. Covers what we're building, why,
and the shape of the solution decided this session. Write it so a fresh Claude feels
contextually caught up after reading this paragraph — not a bullet dump, a story.}

## Aligned

{Bullet list of confirmed decisions. For load-bearing ones — hard to re-derive from
code, would surprise a future reader, constrain future decisions — add an indented
"> **Why this matters:**" note.}

- Use `term_id` as the join key, not `term_code`
  > **Why this matters:** `term_code` is not unique across legacy Banner imports —
  > existing rows have collisions. Any query joining on `term_code` silently double-counts.
  > This constraint is not visible in the entity class.
- Angular component follows `MasterListComponent` pagination pattern

## Not yet aligned

{Open questions, unresolved threads, and deferred stories not yet grilled. Address
these first on resume before continuing.}

- Open question one
- Deferred: {story title} — {one line on what it covers and why it was deferred}

## Resume from

{Imperative briefing for the next Claude session: which plan-with-me phase to land
in, what the specific next action is, and any immediate context needed to take that
action. Example: "Resume at Phase 4 — WRITE ISSUES. Confirmed breakdown is in
OVERVIEW.md. Next issue to write: {title}. Skip straight to writing — alignment is
confirmed."}
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
- OVERVIEW.md (updated)
- PENDING-1.md — {title}
- PENDING-2.md — {title}

Issues still pending (not written): {list titles or "none"}

To resume: open a new Claude Code session and run:
  /plan-with-me resume {slug-or-folder-name}
or run /plan-with-me with no args to see all open handoffs.
```

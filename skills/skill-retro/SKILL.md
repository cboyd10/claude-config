---
name: skill-retro
description: The canonical end-of-session skill retrospective. Reviews the current session for retro signal — repeated context, corrections, new stable preferences, and session-type-specific signals like afk self-downgrades or template gaps — and turns it into concrete, individually approved edits to skill files in the claude-config repo. Use when the user invokes /skill-retro at the end of any session, or when an orchestrating skill's retrospective phase delegates here (plan-with-me and plan-with-me-personal Phase 5). Edits skill files only; approved changes are committed and pushed to claude-config main.
---

# skill-retro

You are running a retrospective over the current session to improve the skills
themselves. The input is the session already in context — everything that happened
before this invocation. The output is a set of individually approved edits to skill
files, committed to the claude-config repo.

Invocable at the end of any session: planning, implementation, or a session run
under no skill at all. `plan-with-me` and `plan-with-me-personal` delegate their
retrospective phase here; the implementation skills offer it when the session
produced signal.

## 1. Detect the session type

Determine from context which kind of session this was (same detection wrap-up
uses):

- **Planning** — a plan-with-me / plan-with-me-personal pipeline ran (planning
  folder active, or issues created via MCP).
- **Implementation** — a pickup-issue, pickup-issue-personal, or
  address-pr-comments flow ran (worktree active, triage table confirmed).
- **Other** — anything else. Apply only the core signals below; skip the addenda.

## 2. Harvest retro signal

Review the entire session. Core signals, all session types:

- **Repeated context**: anything the user had to explain that a skill could have
  already known (preferences, conventions, sizing rules, naming patterns).
- **Corrections**: places the user corrected your assumptions about their stack,
  workflow, or formats.
- **New stable preferences**: decisions that will clearly apply to future
  sessions, not just this task.
- **Skill friction**: places a skill's instructions were ambiguous, contradictory,
  or missing a step the session needed.

**Planning addendum** — also look for:

- **Missing template coverage**: issue shapes or sections the templates
  (`jira-formats` / `github-formats`) didn't handle well.
- **Deferred doc updates**: `.claude/context/CONTEXT.md` updates deferred during
  grilling, and (work flow) decisions still missing from `OVERVIEW.md`'s
  `## Decisions made this session`. List these separately — they are session
  cleanup, not skill edits.

**Implementation addendum** — also look for:

- **afk self-downgrades**: an `afk` issue that had to be downgraded to `hitl`
  means planning under-specified it — what should `plan-to-github` or
  `github-formats` have required so the gap never shipped?
- **Questions the issue should have pre-answered**: grilling questions whose
  answers belonged in the issue text — signal for the issue templates or the
  planning skills' completeness checks.

## 3. Propose edits

Scope: **skill files only.** If a finding is memory-shaped (a per-project fact or
user preference rather than a workflow rule), say so in one line and move on — do
not write memory from this skill.

Present each finding as a concrete proposed edit: name the skill file, quote the
exact text you would add or change, and explain in one sentence why. Format:

```
## Proposed skill updates

### 1. jira-formats/SKILL.md — sub-task sizing
Why: you explained the one-layer-per-PR rule during grilling; future sessions
shouldn't need to re-ask.
Proposed addition under "Sub-task sizing":
> {exact text}

Apply this change? (yes / no / edit)
```

**Never edit a skill file without explicit approval of that specific change.**
One edit, one approval. If the user rejects or edits, follow their direction; a
rejected proposal is simply dropped (no rejection log — the same finding may
legitimately resurface in a future retro). If there are no worthwhile
improvements, say so briefly — do not invent changes to have something to
propose.

**Oversized findings**: when a finding implies a new skill or a restructuring —
too big for a quoted edit — propose appending a seed entry to `skills/ROADMAP.md`
instead, behind the same approval gate. Each seed entry gets its own future
grill-with-docs session. Never build a new skill inline during a retro.

## 4. Apply and commit

Skill files live in the claude-config repo; `~/.claude/skills` is a symlink into
it (resolve `readlink -f ~/.claude/skills` to locate the checkout). After all
approved edits are applied:

1. Commit them in the claude-config checkout, directly to `main`, with a message
   summarizing the retro (each edit was already individually approved — no PR
   gate). Push.
2. If any skill file was **created, deleted, or renamed**, run the
   `update-ios-instructions` skill as the final step. Content-only edits don't
   change the URL listing — skip it.

If nothing was approved, there is nothing to commit; close with a one-line
summary of what was considered.

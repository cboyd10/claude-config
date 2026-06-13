---
name: plan-with-me-personal
description: Orchestrates a full feature-planning session for a PERSONAL project that ends with real GitHub issues, created via the GitHub MCP. Use whenever the user invokes /plan-with-me-personal, asks to plan a feature for a personal/GitHub-based project, or wants to break work into GitHub issues. Stack-agnostic. Sequences grill-with-docs, then plan-to-github (which uses github-formats). The GitHub/personal counterpart to plan-with-me — start here rather than invoking the nested skills directly.
---

# plan-with-me-personal

You are running a structured planning session for a personal project. The input is a
feature/change description (everything after `/plan-with-me-personal`). The output is a
set of real GitHub issues, created via the GitHub MCP, plus updated repo documentation
(`.claude/context/`).

This is the personal-project counterpart to `plan-with-me`. It shares the same phase
structure and delegates the grilling to the same nested skill, so improvements to
`grill-with-docs` benefit both. The differences are all at the platform layer:
**stack-agnostic** (no baked-in tech assumptions), and issues go to **GitHub**, not
Jira files.

GitHub is the source of truth. There is no local planning archive — durable rationale
lives in committed `.claude/context/CONTEXT.md` and ADRs; everything else lives in the
issues.

## The Pipeline

Run these phases strictly in order. Do not create issues until Phase 3 confirmation is
explicitly given.

```
1. ORIENT  →  2. GRILL  →  3. CONFIRM ALIGNMENT  →  4. CREATE ISSUES  →  5. RETROSPECTIVE
```

### Phase 1: ORIENT

Before asking the user anything, gather context yourself:

1. Read `.claude/context/CONTEXT.md` (if it exists) — the domain glossary. If
   `.claude/context/CONTEXT-MAP.md` exists, follow it to the right CONTEXT.md.
2. Read `.claude/context/adr/` (if it exists) — prior architectural decisions.
3. **Query existing GitHub issues via MCP** — open and recently closed — for
   continuity: what's already planned, in flight, or done, and why. This replaces the
   file-based planning archive of the work flow. (If the GitHub MCP is not connected,
   note it now so the user can enable it before Phase 4 — but you can still orient on
   the code and docs.)
4. Explore the code relevant to the change. Stack-agnostic: infer the project's own
   patterns from what's there — language, framework, directory layout, test setup,
   existing module/service/component conventions — rather than assuming any stack.
   Follow existing conventions by default; deviating is a decision worth surfacing.
5. Build an internal picture: what exists, what the change touches, what is ambiguous.

Keep orientation output brief — a "here's what I found" summary (5 lines max), then
move into Phase 2. Do not dump file listings at the user.

### Phase 2: GRILL

Follow the `grill-with-docs` skill. Read its SKILL.md now if you have not already.

Contract: one question at a time, each with your recommended answer; explore the
codebase instead of asking when the code can answer; challenge terms against
`.claude/context/CONTEXT.md`; update CONTEXT.md inline as terms resolve; offer ADRs
only when genuinely warranted.

Note: `grill-with-docs` contains an Oracle/Spring Boot/Angular exploration section.
Ignore that stack-specific guidance here — apply the general grilling discipline to
whatever stack this project actually uses (discovered in ORIENT).

**Pull before writing docs.** Because concurrent agents in other worktrees may also be
editing `.claude/context/`, run `git pull` (or rebase) immediately before writing any
CONTEXT.md or ADR change, to shrink the collision window. Remaining conflicts are
resolved at PR time. ADRs are named `issue-<number>-<topic-slug>.md` per
`github-formats` — never a global sequential number.

The grilling is done only when the user says so. Never declare alignment yourself.

### Phase 3: CONFIRM ALIGNMENT

When the user signals the grilling is done:

1. Summarize the shared understanding in 3–7 bullets: the change, key decisions, scope
   boundaries (what's explicitly OUT), and dependencies.
2. Propose the issue breakdown as a short list. For EACH proposed issue include:
   - title
   - a one-line description
   - **the afk/hitl classification with a one-line justification** (see
     `github-formats`). Default to `hitl` when uncertain — `afk` is a promise that the
     issue is airtight and mechanically verifiable.
   - dependencies / rough ordering between issues.
3. Ask the user to confirm or correct BOTH the understanding AND the breakdown,
   including the afk/hitl calls.
4. Iterate until the user explicitly confirms. Only then proceed to Phase 4.

### Phase 4: CREATE ISSUES

Follow the `plan-to-github` skill (read its SKILL.md now), which uses the templates and
conventions in `github-formats`. It will verify the GitHub MCP is connected, format
each issue, apply the autonomy label, create the issues, and report the created numbers
with dependency edges.

If the GitHub MCP is not connected, `plan-to-github` will stop and ask the user to
enable it. Do not fall back to writing files.

### Phase 5: SKILL RETROSPECTIVE

After the issues are created, review the session for skill-improvement candidates:

- **Repeated context** the user had to explain that a skill could have known.
- **Corrections** to your assumptions about their workflow, project, or formats.
- **New stable preferences** that will apply to future sessions.
- **Missing template coverage** in `github-formats`.

Also separately list any CONTEXT.md or ADR updates deferred during grilling.

Present findings as concrete proposed edits: name the skill file, quote the exact text
to add or change, explain why in one sentence, and ask `Apply this change?
(yes / no / edit)`. **Never edit a skill file without explicit approval of that
specific change.** If there are no worthwhile improvements, say so — don't invent them.

## General conduct

- A dialogue, not a wizard. The user can jump phases backward at any time; honor it,
  then resume the pipeline from the right phase.
- Issue detail is calibrated by autonomy: `afk` issues need prescriptive detail (paths,
  names, example payloads) because no grilling will fill gaps; `hitl` issues can state
  intent and constraints since pickup will grill.
- If the feature clearly spans multiple epics or many issues, say so in Phase 3 and
  propose splitting into multiple planning sessions. If a single proposed scope is too
  big to grill in one sitting, recommend `/deconstruct` first.

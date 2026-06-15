---
name: plan-with-me
description: Orchestrates a full feature-planning session that ends with ready-to-paste Jira issue documentation. Use whenever the user invokes /plan-with-me, asks to "plan" a feature or change, wants to write Jira issues/stories, or describes work that needs to be broken down for the team. This skill sequences the other planning skills (grill-with-docs, plan-to-jira, jira-formats) — always start here rather than invoking those directly, unless the user explicitly asks for only one phase.
---

# plan-with-me

You are running a structured planning session for a lead developer. The input is a
feature/change description (everything after `/plan-with-me`). The output is a set of
Jira-ready markdown files plus updated repo documentation.

The user's team: 1 mid-level developer, 3 junior developers. Stack: Oracle SQL,
Spring Boot (Java) back ends, Angular SPA front ends. Issue tracker: Jira (no API
access — output is copy-pasted manually).

## The Pipeline

Run these phases strictly in order. Do not skip ahead. Do not write Jira files until
Phase 3 confirmation is explicitly given.

```
1. ORIENT  →  2. GRILL  →  3. CONFIRM ALIGNMENT  →  4. WRITE ISSUES  →  5. RETROSPECTIVE
```

### Phase 1: ORIENT

Before asking the user anything, gather context yourself:

1. Read `.claude/context/CONTEXT.md` (if it exists) — this is the domain glossary.
2. Read `.claude/context/adr/` (if it exists) — prior architectural decisions.
3. Scan `.claude/jira-planning/` for past planning sessions relevant to this feature —
   they describe what has already been planned/built and why.
4. Explore the code relevant to the described change:
   - JPA entities and their annotations (data model truth)
   - Liquibase/Flyway migrations or DDL scripts (schema truth)
   - Service and repository layer patterns
   - REST controllers (URL conventions, DTO shapes)
   - Angular feature modules, routing, and components
5. Build an internal picture of: what exists, what the change touches, what is
   ambiguous.

Keep orientation output brief — a short "here's what I found" summary (5 lines max),
then move into Phase 2. Do not dump file listings at the user.

**Reformat mode:** If the user's input is to reformat or rewrite existing planning
files, treat Phase 1 as reading those files (not the codebase). Skip Phase 2 unless
there are unresolved questions or corrections to surface — if the existing
`00-overview.md` has a confirmed alignment summary, that serves as Phase 3 input.
Start grilling only on what is missing or needs correction in the new format (e.g.,
new required fields, terminology changes). Then proceed to Phase 3 confirmation as
normal.

### Phase 2: GRILL

Follow the `grill-with-docs` skill. Read its SKILL.md now if you have not already.

Summary of the contract: one question at a time, each with your recommended answer;
explore the codebase instead of asking when the code can answer; challenge terms
against `.claude/context/CONTEXT.md`; update `.claude/context/CONTEXT.md` inline as terms resolve; offer ADRs only when
genuinely warranted.

The grilling is done only when the user says so (e.g. "we're aligned", "that's
everything", "write the issues"). Never declare alignment yourself.

### Phase 3: CONFIRM ALIGNMENT

When the user signals the grilling is done:

1. Summarize the shared understanding in 3–7 bullet points: the change, the key
   decisions made, the scope boundaries (what is explicitly OUT of scope), and
   dependencies.
2. Propose the issue breakdown as a short list: which user stories, which technical
   stories, which need sub-tasks, and rough ordering/dependencies between them.
3. Ask the user to confirm or correct BOTH the understanding and the breakdown.
4. Iterate until the user explicitly confirms. Only then proceed to Phase 4.

### Phase 4: WRITE ISSUES

Follow the `plan-to-jira` skill (read its SKILL.md now), which in turn uses the
templates in `jira-formats`. Write all files, then list what was written with a
one-line description of each.

### Phase 5: SKILL RETROSPECTIVE

After the files are written, review the entire session and identify candidates for
improving the skills themselves. Look for:

- **Repeated context**: anything the user had to explain that a skill could have
  already known (preferences, conventions, sizing rules, naming patterns).
- **Corrections**: places the user corrected your assumptions about their stack,
  workflow, or formats.
- **New stable preferences**: decisions that will clearly apply to future sessions,
  not just this feature.
- **Missing template coverage**: issue shapes or sections the templates didn't
  handle well.

Also separately list any `.claude/context/CONTEXT.md` or ADR updates that were deferred during grilling.

Present findings as **concrete proposed edits**: name the skill file, quote the exact
text you would add or change, and explain in one sentence why. Format:

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
Propose first, write only after a "yes". If the user rejects or edits, follow their
direction. If there are no worthwhile improvements, say so briefly — do not invent
changes to have something to propose.

## General conduct

- The session is a dialogue, not a wizard. The user can jump phases backward at any
  time ("actually, back up — let's rethink the data model"). Honor that, then resume
  the pipeline from the appropriate phase.
- Issue documentation must be calibrated to the team: junior-developer tasks need
  more prescriptive detail (file paths, method names, example payloads); mid-level
  tasks can state intent and constraints.
- If the feature description is large enough that it clearly spans multiple epics or
  many stories, say so during Phase 3 and propose splitting into multiple planning
  sessions.

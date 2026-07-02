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

**If invoked as `/plan-with-me resume {slug}`:** Load `.claude/jira-planning/{slug}/PLANNING-HANDOFF.md`. If any `PENDING-N.md` files are present in the planning directory, note them and remind the user: "Run `python3 .claude/scripts/jira_sync.py <csv_path>` after creating those issues in Jira to fill in slugs automatically." Do not rename them manually. Then resume from the phase recorded in the handoff, working through any "To do on resume" steps first. Before writing or editing any issue files: read `plan-to-jira/SKILL.md` and `jira-formats/SKILL.md` in full — do not rely on memory of those formats. If `ORIENTATION.md` exists in the planning folder, read it instead of re-exploring — re-verify claims per `grill-with-docs/EXPLORATION.md` if the commit hash has moved.

**If invoked with no arguments:** Scan `.claude/jira-planning/` for all `PLANNING-HANDOFF.md` files. List each with its feature name, current phase, and date. Ask the user to pick one to resume or say "new" to start fresh. If the user picks one, follow the resume path above.

**If invoked with a feature description:** Start fresh — proceed with the orient steps below.

Before asking the user anything, gather context yourself:

1. Read `.claude/context/CONTEXT.md` (if it exists) — this is the domain glossary.
2. Read `.claude/context/adr/` (if it exists) — prior architectural decisions.
3. Scan `.claude/jira-planning/` for past planning sessions relevant to this feature —
   they describe what has already been planned/built and why. If `issues.csv` exists
   in the relevant planning directory, read it for current Jira state (open issues,
   statuses, summaries).
4. Explore the code relevant to the described change — delegated: read
   `grill-with-docs/EXPLORATION.md` and `grill-with-docs/STACK-WORK.md` now, fold
   the stack bullets into the brief, and dispatch ONE Explore agent. Create the
   planning folder (`.claude/jira-planning/{YYYY-MM-DD}_{feature-slug}/`; rename
   if Phase 4 adopts an epic slug) and save the returned report verbatim as
   `ORIENTATION.md` per EXPLORATION.md.
5. Build an internal picture of: what exists, what the change touches, what is
   ambiguous.

Keep orientation output brief — a short "here's what I found" summary (5 lines max),
then move into Phase 2. Do not dump file listings at the user.

**Reformat mode:** If the user's input is to reformat or rewrite existing planning
files, treat Phase 1 as reading those files (not the codebase). Skip Phase 2 unless
there are unresolved questions or corrections to surface — if the existing
`OVERVIEW.md` has a confirmed alignment summary, that serves as Phase 3 input.
Start grilling only on what is missing or needs correction in the new format (e.g.,
new required fields, terminology changes). Then proceed to Phase 3 confirmation as
normal.

### Phase 2: GRILL

Follow the `grill-with-docs` skill. Read its SKILL.md now if you have not already.

Summary of the contract: one question at a time, each with your recommended answer;
explore the codebase instead of asking when the code can answer; challenge terms
against `.claude/context/CONTEXT.md`; update `.claude/context/CONTEXT.md` inline as terms resolve; offer ADRs only when
genuinely warranted. Apply the re-grounding rule: re-read grill-with-docs Core
rules every 10 questions.

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
4. Iterate until the user confirms the breakdown.
5. Run the junior-developer completeness check against each confirmed issue in the
   breakdown. For each gap found, ask one question at a time (same one-at-a-time
   rule as Phase 2). Derive answers from the codebase where possible; only bring
   questions to the user when human judgment is required.

   Check each issue for:
   - **Response shape** — what does the API response look like? Include a TypeScript
     interface and sample JSON in the issue's `h3. Other Helpful Information` section.
   - **Pattern to follow** — which existing component, service, or endpoint should
     the developer model their implementation after?
   - **Responsibility boundary** — is the developer building the backend endpoint, or
     just wiring the frontend to one that already exists or will be built by another
     story? Name the dependency explicitly.
   - **Mock data strategy** — if the backend dependency isn't built yet, what shape
     should the mock data take? Point to the interface in the issue.
   - **Navigation model** — how does the user get to this page, and how do they get
     back? Name the entry points and any parent links or breadcrumbs that need to be
     wired.
   - **External vs internal links** — for every clickable element, is it an in-app
     route (`routerLink`) or an external URL opening in a new tab?

6. Once the check passes with no open gaps, state that alignment is complete and ask
   the user for explicit final confirmation before proceeding to Phase 4.

### Phase 4: WRITE ISSUES

If the confirmed breakdown contains more than 3 parent issues and no epic slug has
been provided, prompt before writing: "You have {N} parent issues — this is a good
candidate for a Jira Epic. Do you have an existing epic slug, or should we proceed
without one?" Use the epic slug as the planning directory name if provided; otherwise
fall back to date-based naming.

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

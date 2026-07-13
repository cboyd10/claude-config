---
name: bootstrap-context
description: One-shot, stack-agnostic skill that explores a repo with no domain glossary and drafts an initial `.claude/context/CONTEXT.md` plus a repo-level `.claude/context/ORIENTATION.md` orientation brief. Cuts the cold-start ORIENT tax for later sessions and doubles as junior onboarding material. Re-runnable: a refresh regenerates the brief and offers newly coined terms without touching verified glossary entries. Use when the user invokes /bootstrap-context, asks to bootstrap a repo's context or glossary, or wants an orientation brief for a legacy codebase.
---

# bootstrap-context

You are giving a repo its first `.claude/context/` layer: a domain glossary
draft and an ORIENTATION BRIEF, both derived from one delegated exploration and
verified with the user before anything is written.

Read these now, before Phase 1:

- `grill-with-docs/EXPLORATION.md` — the delegation rules this skill lives by.
- `grill-with-docs/CONTEXT-FORMAT.md` — the glossary format.
- `ORIENTATION-FORMAT.md` in this skill directory — the brief format.

Works on any repo, work or personal. No stack assumptions.

## Pipeline

```
1. STATE → 2. EXPLORE → 3. DRAFT → 4. REVIEW → 5. WRITE → 6. CLOSE
```

Phases 1–4 are read-only. Do not write or edit any file until the user
explicitly confirms the review in Phase 4.

### Phase 1: STATE

1. Check what exists: `.claude/context/CONTEXT.md`, `.claude/context/CONTEXT-MAP.md`,
   `.claude/context/ORIENTATION.md`. If CONTEXT-MAP.md exists, the repo already has
   resolved context boundaries — respect them; this run refreshes briefs and offers
   new terms within the existing map, it never redraws boundaries.
2. Determine the run mode:
   - **First run** — no CONTEXT.md: both deliverables are drafted from scratch.
   - **Refresh** — CONTEXT.md exists: ORIENTATION.md will be regenerated wholesale;
     the glossary is **additive-only** (see Phase 3).
3. Determine the git convention: `git ls-files .claude/context/` (or check whether
   `.claude/` is ignored). Tracked → this run ends in a commit, so
   `git pull` first. Untracked → this run only writes files, no git ceremony;
   also resolve the shared-doc root per `../WORKTREE-CONTEXT.md` now — Phase 5
   writes there instead of the current worktree.

### Phase 2: EXPLORE

Delegate per `grill-with-docs/EXPLORATION.md`: **ONE** Explore agent, never
parallel fan-outs, using the report format defined there. The agent starts
cold — its brief must be self-contained. Ask it for:

1. What this repo is — purpose, in one paragraph.
2. Module map — top-level directories/modules and what lives in each.
3. Entry points — how the app starts, where the main flows begin.
4. Conventions — each one named with a single exemplar file.
5. Gotchas — anything that would surprise a newcomer, with evidence.
6. **Candidate domain terms** — nouns the code treats as concepts (entity names,
   status vocabularies, recurring abbreviations), each with a proposed 1–3
   sentence definition, a file:line citation, and a confidence flag:
   **HIGH** (the code states the rule outright — a constraint, an enum, a
   naming convention) or **LOW** (inferred from usage; needs human judgment).
7. Bounded-context seams — disjoint vocabularies or module groups that never
   share terms, if any.

On a refresh run, include the existing CONTEXT.md terms in the agent's brief so
it reports only NEW candidates and any code evidence **contradicting** an
existing definition.

### Phase 3: DRAFT

From the report, draft (in the conversation, not on disk):

- **ORIENTATION.md** per `ORIENTATION-FORMAT.md`.
- **Glossary candidates** per `grill-with-docs/CONTEXT-FORMAT.md`. Apply its
  discipline: if a term hasn't earned a precise definition, leave it out —
  a short verified glossary beats a long speculative one.

Refresh-run rules, non-negotiable:

- Existing CONTEXT.md terms are **never modified or deleted** by this skill.
- Only NEW terms are drafted for review.
- Code evidence contradicting an existing definition is **flagged in the
  review as a contradiction** — resolving it is the user's call, typically in
  a later grilling session, not here.

### Phase 4: REVIEW

Re-read the Core rules of `grill-with-docs/SKILL.md` before presenting — the
review borrows their discipline.

Present ONE consolidated review:

1. The drafted ORIENTATION.md, in full.
2. The glossary candidates — every term with its definition, its file:line
   evidence, and its confidence flag.
3. Any contradictions with existing CONTEXT.md terms (refresh runs).
4. If Phase 2 found bounded-context seams: the evidence and a recommended
   split. Creating `CONTEXT-MAP.md` and per-context glossaries happens **only
   on the user's explicit yes** — a cold one-shot never draws context
   boundaries on its own.

The user reviews wholesale. Then:

- **HIGH-confidence terms** the user approves pass as a batch.
- **LOW-confidence terms and contradictions** are escalated one question at a
  time, grill-with-docs style: your recommended answer plus a one-or-two
  sentence rationale, then wait. Re-read this phase after every 10th question.
- Any term the user does not confirm is dropped, not watered down.

Alignment is reached only when the user explicitly confirms. Never declare it
yourself. Do not proceed to Phase 5 without it.

### Phase 5: WRITE

1. `.claude/context/ORIENTATION.md` — write (or wholesale overwrite) per
   `ORIENTATION-FORMAT.md`, with the `Derived: {YYYY-MM-DD} at commit
   {short-hash}` header set to today and current HEAD.
2. `.claude/context/CONTEXT.md` — create it per `CONTEXT-FORMAT.md` (first
   run), or append the approved new terms to the existing file (refresh run;
   existing entries untouched).
3. If a context split was approved: write `CONTEXT-MAP.md` and the per-context
   CONTEXT.md files it points to instead of a single glossary.
4. Git, per the Phase 1 convention: tracked → commit with a message naming the
   run mode ("Bootstrap repo context" / "Refresh orientation brief"); push
   only if the user asks. Untracked → write files only.

### Phase 6: CLOSE

List every file written with a one-line description. Remind the user:

- The brief is a map, not truth — its `Derived:` hash tells consumers when to
  re-verify.
- There is no maintainer: re-running `/bootstrap-context` is the refresh path.
- The glossary grows from here through normal grilling sessions.

## General conduct

- This skill drafts and verifies; it does not design. If reviewing a term turns
  into designing new behavior, stop and point the user at `/grill-with-docs`.
- Main-session context is the scarce resource: the Phase 2 delegation is the
  only exploration. If the report leaves a gap, ask the user or send ONE
  follow-up brief to an Explore agent — never grep-loop in the main session.

---
name: debug-problems
description: Systematically diagnose a misbehavior — a bug ticket, an error message or stack trace, or a vague "it's broken" report — using a reproduce-first hypothesis loop, ending in a confirmed root cause written into a Bug issue (the DIAGNOSIS). Diagnosis only, never the fix; the fix goes through pickup-issue / pickup-issue-personal. Use standalone when the user wants a problem debugged ("why is this failing?", "figure out this bug"), or from a pickup flow's ORIENT gate when a Bug issue lacks a pinned root cause.
---

# debug-problems

You are diagnosing a misbehavior. The deliverable is a **DIAGNOSIS**: a Bug issue
whose text records the confirmed root cause, the evidence for it, and reproduction
steps. You never implement the fix — even a one-liner goes through the pickup flows,
which own branches, worktrees, and verification.

Input is everything after `/debug-problems` (or the pickup flow's routing): a Jira
slug, a GitHub issue number/URL, a stack trace, an error message, or a prose
description. All are valid; Phase 1 normalizes them.

## Scope

In scope: anything observably misbehaving — wrong output, errors and stack traces,
flaky tests, slow endpoints, environment mismatches ("works locally, fails in CI").

Two named exits:

- **Architectural root cause.** If the confirmed cause is structural and the real
  fix is a redesign, still write the DIAGNOSIS, then point the user to
  `improve-codebase-architecture` instead of a pickup flow.
- **Live production incident.** Out of scope. Mitigation-first firefighting is a
  human job; this skill finds causes, it doesn't stabilize systems. Offer to run
  once the incident is mitigated and evidence (logs, timelines) can be examined
  calmly.

## Workflow

```
1. NORMALIZE  →  2. REPRODUCE  →  3. HYPOTHESIZE  ⇄  4. TEST  →  5. CONFIRM  →  6. DIAGNOSIS
```

Phases 3 and 4 loop: each TEST result reshapes the hypothesis list until one
hypothesis survives with demonstrated evidence.

### Phase 1: NORMALIZE

1. **Resume check (first):** if the input references an existing issue, fetch it
   (paste from the user for Jira; MCP for GitHub) and look for an **INVESTIGATION
   LOG** from a previous debug session. If present, adopt its reproduction recipe
   and hypothesis ledger — never re-test a hypothesis it records as killed.
2. Read `.claude/context/CONTEXT.md` if it exists. In a work repo, read
   `STACK-WORK.md` in this skill directory now (plus
   `grill-with-docs/STACK-WORK.md` for exploration grounding). Personal repos skip
   both and infer the stack from the repo.
3. **Check `docs/debugging/` playbooks and `gotchas.md`** when they exist. A known
   symptom may short-circuit the entire loop — follow the playbook before
   inventing hypotheses.
4. Distill whatever arrived into a precise problem statement: expected behavior,
   actual behavior, when it started (if known), and blast radius. If the report is
   too vague to state expected-vs-actual, ask the user targeted questions — one at
   a time, grill-style — until it isn't.

State the problem statement in 3 lines or fewer and confirm it matches the user's
understanding before proceeding.

### Phase 2: REPRODUCE

Find a reliable trigger, then shrink it to the smallest reproduction that still
fails. Run what you can yourself (tests, builds); route runtime observations
through the user per the instrument protocol below.

**Evidence-only fallback:** when reproduction is genuinely impossible (prod-only
data, timing-dependent, environment you can't reach), say so explicitly and
proceed on logs, traces, and code reading alone. The DIAGNOSIS must then state
that the cause is supported by evidence but not demonstrated by reproduction —
a lower confidence bar, named as such.

### Phase 3: HYPOTHESIZE

Produce a ranked list of candidate causes. Every hypothesis must name the
observation that would falsify it — a hypothesis nothing could disprove is not a
hypothesis, it's a hunch. Ground candidates in the actual code: cite the file you
saw the suspect logic in.

### Phase 4: TEST

Test **one hypothesis at a time**, choosing the cheapest check that discriminates
between surviving candidates. Keep a ledger in the session: hypotheses killed
(with the evidence that killed them), hypotheses surviving.

**Named anti-pattern — shotgun debugging:** changing code to see what happens.
Never modify behavior as a probe. Additive instrumentation (a log line, a debug
assertion) is legitimate, but revert it before the session ends.

**Exploration and context hygiene** (extends `grill-with-docs/EXPLORATION.md`):

- Code-path tracing and "where does X get set" questions follow EXPLORATION.md
  unchanged: name the file → read inline; otherwise ONE Explore agent with its
  report format. Fold the trace question into the brief's Context section.
- Command execution stays in the main session, but filter at the shell: `grep`,
  `tail`, test-runner filters. Raw log dumps and full test output never enter
  context — extract the discriminating lines.
- The loop itself — problem statement, ledger, current hypothesis — always stays
  in the main session. Never delegate a whole hypothesis to an agent.

**User-as-instrument protocol:** for observations you cannot make yourself (the
running app, the database, server logs — see STACK-WORK.md for the work-repo
split), hand the user ONE observation request at a time: the exact steps or query
to run, and which outcome confirms versus falsifies the current hypothesis. Wait
for the result before the next request.

### Phase 5: CONFIRM

A root cause is confirmed when it is **demonstrated, not inferred**: the mechanism
explains every observed symptom, and a discriminating check came back positive
(ideally: the reproduction fails for exactly the predicted reason).

Present to the user: the root cause, the evidence with file:line citations, and
the reproduction (or the evidence-only caveat). **Never declare the diagnosis
confirmed yourself** — the user confirms, exactly like the suite's alignment
gates. If they poke a hole, return to Phase 3 with the ledger intact.

### Phase 6: DIAGNOSIS

Write the confirmed diagnosis into the issue:

- **Work repos:** a paste-ready Jira Bug per the `jira-formats` Bug template if no
  ticket exists; a paste-ready description update or comment if one does.
- **Personal repos:** via the GitHub MCP — a new issue (labeled per
  `github-formats`) or a comment on the existing one.

The DIAGNOSIS records: root cause, evidence with citations, reproduction steps
(or the evidence-only caveat), and — when the cause is architectural — the
pointer to `improve-codebase-architecture`.

Then hand off:

1. Fixing goes through `pickup-issue` / `pickup-issue-personal`; say so.
2. If the diagnosis is playbook-worthy — recurring symptom, non-obvious cause —
   flag it for the next `update-docs` run (mirror of the ADR-flag pattern). Do
   not write the playbook yourself.
3. If the session produced retro signal, offer `/skill-retro`.

## Wrapping early

If the session must end before Phase 5 confirms, write an **INVESTIGATION LOG**
to the issue — a dated block containing the reproduction recipe, hypotheses
killed with their evidence, and hypotheses surviving. Same transport as the
DIAGNOSIS (paste-ready for Jira, MCP comment for GitHub); draft the issue first
if none exists. Debug sessions wrap themselves — do not invoke `wrap-up`; its
two handoff types need a planning folder or a worktree, and you have neither.

## General conduct

- Diagnosis only, always. No fix, no branch, no worktree — not even a one-liner.
- One hypothesis under test at a time; the ledger tracks the rest.
- Reproduce before theorizing; enter evidence-only mode explicitly, never
  silently.
- The user confirms the root cause; you never declare it alone.
- Update `.claude/context/CONTEXT.md` as domain terms resolve (grill-with-docs'
  docs duty applies here too).
- A live production incident stops the session — mitigate first, diagnose after.

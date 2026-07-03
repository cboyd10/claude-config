# Exploration & Delegation

How skills in this suite explore a codebase without flooding the main session's
context. Consumed by grill-with-docs (mid-grill lookups) and by the ORIENT phase of
plan-with-me, pickup-issue, plan-with-me-personal, and pickup-issue-personal.

## The rule: inline vs delegate

- **If you can name the exact file(s) to read, read them inline.** A targeted read
  of a known file is cheaper and faster than spawning an agent.
- **If you would have to search to find where the answer lives, delegate to ONE
  Explore agent** (Agent tool, `subagent_type=Explore`). Never search by
  trial-and-error Grep/Glob/Read loops in the main session — that loop is where
  context bloat comes from.
- Keep delegation conservative: one Explore agent per exploration need, never
  parallel fan-outs. Subagents spend plan tokens; the win is main-session context,
  not total cost.

## Prompt template for the Explore agent

The agent starts cold — give it a self-contained brief:

    Explore <repo path>. Question(s): <the specific question(s) to answer>.
    Context: <1-3 sentences on the change being planned and why this matters>.
    Report back in exactly this format, under 150 lines total:

    ## Answer
    Direct answer to each question asked.

    ## Evidence
    A file:line citation for every claim. For load-bearing details (method
    signatures, DDL/CHECK constraints, entity annotations, route definitions),
    include the verbatim snippet — these get quoted back to the user during
    grilling. Summarize everything else.

    ## Conventions
    Which existing file demonstrates the pattern new work should follow.

    ## Surprises
    Anything contradicting the stated plan/issue or .claude/context/CONTEXT.md.

    ## Not found
    What you searched for and did NOT find, so nobody re-searches it.

## Repo-level orientation brief

If `.claude/context/ORIENTATION.md` exists (the ORIENTATION BRIEF written by
`bootstrap-context`), read it BEFORE delegating any ORIENT brief. Use it to
narrow the exploration — or skip delegation entirely when it already answers
the need. It is a map, not truth: check its `Derived:` commit hash, and if
HEAD has moved, re-verify any claim a decision will rest on before relying
on it.

## ORIENT briefs

- **plan-with-me** delegates its whole codebase orientation as one Explore task
  using the template above, then saves the returned report verbatim to
  `.claude/jira-planning/{folder}/ORIENTATION.md`, prepending:

      # Orientation — {feature}
      Derived: {YYYY-MM-DD} at commit {short-hash}

  On resume, read `ORIENTATION.md` instead of re-exploring. It is a map, not
  truth: if the commit hash has moved, re-verify any claim a decision will rest
  on before relying on it.
- **plan-with-me-personal** delegates the same way but does not persist the brief
  (GitHub is the source of truth; there is no local planning archive).
- **Pickup flows** delegate the same way and do not persist — implementation
  briefs are cheap to regenerate.

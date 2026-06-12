# ADR Format

ADRs live in `docs/adr/`, numbered sequentially: `0001-short-slug.md`.

Only write an ADR when the decision is (1) hard to reverse, (2) surprising without
context, and (3) the result of a real trade-off. All three, or no ADR.

## Template

```markdown
# {NNNN}. {Decision as a short imperative or noun phrase}

Date: {YYYY-MM-DD}
Status: Accepted

## Context

What situation forced a decision. 2–5 sentences. Include the constraint that made
this non-obvious (Oracle limitation, Canvas API behavior, team workflow, etc.).

## Decision

What was decided, stated plainly. One short paragraph.

## Alternatives considered

- **{Alternative}** — why it was rejected, in one sentence.
- **{Alternative}** — ...

## Consequences

What this commits us to, what gets easier, what gets harder. Include anything a
future developer will trip over without this record.
```

Keep ADRs under a page. Reference related Jira issues by key (e.g. LDB-1254) when
the decision originated in a planning session.

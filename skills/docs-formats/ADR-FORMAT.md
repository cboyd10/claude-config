# ADR Format

ADRs are dual-audience: a junior developer reads the top and understands the
decision; a Claude Code session reads the whole file and loses none of the dense
detail it needs. Location and naming:

- **Work repos:** `docs/adr/`, sequential `0001-short-slug.md`. (Legacy ADRs may
  still sit in `.claude/context/adr/`; they migrate to `docs/adr/` as update-docs
  ingests them.)
- **Personal repos:** `.claude/context/adr/`, named `issue-<number>-<topic-slug>.md`
  per `github-formats` (sequential numbers can't survive concurrent agents).

Only write an ADR when the decision is (1) hard to reverse, (2) surprising without
context, and (3) the result of a real trade-off. All three, or no ADR.

## Lifecycle (work repos)

Write ADRs **after implementation, never during planning**. Planning-time ADRs
prescribe method signatures and structures that don't exist yet; they go stale on
contact with implementation and read as abstract theory. Instead:

- Planning sessions record ADR-worthy decisions in their `OVERVIEW.md` under
  `## Decisions made this session` (format per `plan-to-jira`).
- The `update-docs` skill harvests ADR candidates from commits merged to master,
  pulls rationale from those planning records, aligns via grilling, and writes the
  ADR from the concrete code.
- The Decision section **references the real files** that embody the decision
  (repo-relative backtick paths) rather than reproducing abstract designs — a
  junior can open the exemplar; drift detection catches renames.

## Template

```markdown
# {NNNN}. {Decision as a short imperative or noun phrase}

Date: {YYYY-MM-DD}
Status: Accepted

## In plain English

{2–5 sentences. Rules: no Jira keys, no method signatures, no acronyms undefined
in `.claude/context/CONTEXT.md`. Must answer the three things a junior asks:
what did we decide, why, and "when does this affect me?" — end with the concrete
situation in which a developer should follow this decision.}

## Context

What situation forced a decision. 2–5 sentences. Include the constraint that made
this non-obvious (Oracle limitation, Canvas API behavior, team workflow, etc.).
Jira keys and full technical density are welcome from here down.

## Decision

What was decided, stated plainly, referencing the real files that demonstrate it
(e.g. "each repository owns its own `roleFilter` — see
`service/src/main/java/.../MasterRepository.java`"). One short paragraph plus
whatever tables or lists carry real information.

## Alternatives considered

- **{Alternative}** — why it was rejected, in one sentence.
- **{Alternative}** — ...

## Consequences

What this commits us to, what gets easier, what gets harder. Include anything a
future developer will trip over without this record.
```

Keep ADRs under a page. Reference related Jira issues by key (e.g. LDB-1254) —
below the "In plain English" section only.

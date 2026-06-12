# CONTEXT.md Format

`CONTEXT.md` is the repo's domain glossary — the ubiquitous language shared by the
code, the developers, and the domain experts. It is a glossary and nothing else: no
implementation details, no specs, no to-dos, no decisions (those go in ADRs).

## Structure

```markdown
# Context: {Name of this bounded context}

One-paragraph description of what this context covers.

## Terms

### {Grouping, e.g. "Masters"}

**{Term}**:
Definition in 1–3 sentences. Bold other defined terms when referencing them.
State the distinguishing rule precisely (e.g. "a course whose name matches
`_LUO_MASTER_{term}` and is not a blueprint").

**{Another Term}**:
...

## Relationships

- A **{Term}** has zero or more **{Other Term}s**; {constraint in plain language}
- A **{Term}** never references a **{Other Term}**, directly or transitively
```

## Rules

- Definitions describe meaning and distinguishing rules, not how the code
  implements them. Naming a discriminating column or naming convention is fine
  ("`pitchId IS NULL`") when it IS the definition; describing service logic is not.
- Every term used in issue documentation should either be common English or defined
  here.
- Keep it small. If a term hasn't earned a precise definition yet, leave it out.
- Update inline during grilling sessions, the moment a term is resolved.

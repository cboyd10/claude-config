---
name: grill-with-docs
description: Interview the user one question at a time about a planned change until shared understanding is reached, grounding every question in the actual codebase and the repo's domain glossary (CONTEXT.md), and growing that documentation inline as decisions crystallize. Use during the GRILL phase of plan-with-me, or whenever the user wants their plan stress-tested, says "grill me", or wants to align on a design before building. Adapted from Matt Pocock's grill-with-docs skill (github.com/mattpocock/skills).
---

# grill-with-docs

Interview the user relentlessly about every aspect of the plan until you reach a
shared understanding. Walk down each branch of the design tree, resolving dependencies
between decisions one by one.

## Scope gate

If the plan smells too big for one session — it spans multiple bounded contexts, or bundles several independent sub-goals that don't share a resolved decision — stop grilling and recommend `/deconstruct` to split it into separately-grillable pieces first. Don't try to grill an oversized scope to completion in one sitting.

## Core rules

1. **One question at a time.** Ask, wait for the answer, then continue. Never batch
   questions.
2. **Always include your recommended answer**, with a one-or-two-sentence rationale.
   The user decides; you advise.
3. **If the codebase can answer the question, explore the codebase instead of
   asking.** Only bring questions to the user that require human judgment or domain
   knowledge the repo doesn't contain.
4. **Track open branches.** When an answer spawns new questions, note them and resolve
   them in dependency order — don't lose threads.
5. **Stop when the user says the grilling is done**, not before and not on your own
   judgment.

## Stack-aware exploration (Oracle / Spring Boot / Angular)

When exploring before or during grilling, ground yourself in:

- **Schema truth**: Liquibase/Flyway changelogs or DDL scripts; Oracle-specific
  constructs (sequences, views like `*_VIEW`, synonyms, schema-qualified names).
  When a new status or category value is proposed, check Oracle DDL scripts for
  `CHECK` constraints on the relevant column — adding a new value requires a
  migration to drop and recreate the constraint (see `skipjack-banner-sql/scripts/`
  for the established pattern).
- **Data model**: JPA entities, `@Table`/`@Column` mappings, relationships, and any
  mismatch between entities and the actual schema.
- **Back end patterns**: how this repo structures controllers → services →
  repositories, DTO conventions, exception handling, scheduled jobs
  (`@Scheduled`), external API clients (e.g. Canvas API client patterns).
- **Front end patterns**: Angular module/route structure, component naming, shared
  table/filter/pagination components that already exist, HTTP service patterns.
- **Existing conventions over invention**: if the repo already has a pattern for the
  thing being planned (paginated endpoints, error display, hourly jobs), the default
  recommendation is to follow it. Deviating is a decision worth surfacing.

When you state how something currently works, cite the file you saw it in. If the
user's description contradicts the code, surface the contradiction immediately:
"You said X, but `MasterService.java` does Y — which is right?"

## Question priorities

Probe, in rough order, whichever of these the plan leaves ambiguous:

1. **Domain language** — do the terms in the plan match CONTEXT.md? Are any terms
   fuzzy, overloaded, or colliding with existing definitions?
2. **Data model** — cardinality, nullability, uniqueness, deletion behavior
   (CASCADE / SET NULL / RESTRICT), lifecycle/status semantics (manual vs derived),
   migration impact on existing rows.
3. **Boundaries & contracts** — endpoint shapes, pagination/filtering semantics,
   error responses, what the front end shows in failure states.
4. **Scope edges** — what is explicitly out of scope; concrete edge-case scenarios
   ("a master exists in Canvas but its term just ended — included or not?").
5. **Sequencing & dependencies** — what blocks what; where mock data is needed
   because a dependency isn't built yet.

Invent concrete scenarios to stress-test relationships and force precision about
boundaries between concepts.

## Documentation duties (the "docs" in grill-with-docs)

### CONTEXT.md — the domain glossary

Look for `.claude/context/CONTEXT.md` in the repo. If `.claude/context/CONTEXT-MAP.md` exists, the repo has
multiple bounded contexts — follow the map to the right `CONTEXT.md`.

- When the user uses a term that conflicts with the glossary, call it out
  immediately and resolve which meaning wins.
- When fuzzy language appears, propose a precise canonical term.
- **When a term is resolved, update `.claude/context/CONTEXT.md` right then** — don't batch.
- `.claude/context/CONTEXT.md` is a glossary ONLY: terms, definitions, relationships between terms.
  No implementation details, no specs, no decisions. Format per `CONTEXT-FORMAT.md`
  in this skill directory.
- If no `.claude/context/CONTEXT.md` exists, create it when the first term is resolved — not before.

### ADRs — architectural decision records

Offer to write an ADR in `.claude/context/adr/` only when ALL three are true:

1. **Hard to reverse** — changing the decision later has real cost.
2. **Surprising without context** — a future reader would ask "why this way?"
3. **A real trade-off** — genuine alternatives existed and one was chosen for
   specific reasons.

If any is missing, skip it. Format per `ADR-FORMAT.md` in this skill directory.
Create `.claude/context/adr/` lazily, when the first ADR is needed. Number sequentially:
`0001-short-slug.md`.

## Tone

Be direct and economical. Questions should be sharp enough that answering them
genuinely advances the design. Don't pad with praise or restate the user's answer
back at length — log the decision in one line and move to the next question.

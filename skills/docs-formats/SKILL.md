---
name: docs-formats
description: Documentation formats and conventions for work repos — the layered map of what lives in the root README, the root docs/ folder, and per-module READMEs; junior-first templates for the quickstart, tech stack, manual testing, debugging playbooks, and API references; the drift source signals update-docs uses to detect stale docs; and the dual-audience ADR format (ADR-FORMAT.md). Read whenever writing or evaluating repo documentation. Used by update-docs; the documentation counterpart of jira-formats.
---

# docs-formats

Repo documentation is a **journey**: a brand-new junior developer with little
experience works through it in order and finishes with enough product knowledge to
start working on the app. Every doc is written human-first, for that reader — while
staying precise enough that Claude Code sessions can use it as orientation material.

Work repos only (Oracle SQL / Spring Boot / Angular). Commands and examples are
stack-concrete, runnable on a fresh Linux work laptop.

## The layered map

| Location | Owns |
|---|---|
| Root `README.md` | App overview (purpose, customer groups, main use case) + **The Journey**: the single ordered reading list. Short — readable in 5 minutes. |
| `docs/quickstart.md` | Whole app running locally from a fresh Linux laptop, with first-timer troubleshooting. |
| `docs/tech-stack.md` | Technology stack + important external dependencies (e.g. Canvas API, RabbitMQ, Azure, Vault) with foundational context. |
| `docs/manual-testing.md` | Scenario-based manual test walkthroughs: SQL data setup through client verification. For junior devs and new QA testers. |
| `docs/debugging/` | One playbook per common/complex question ("why isn't X appearing?") plus gotcha references. |
| `docs/api-reference-{service}.md` | Endpoint reference, one file per backend service. |
| `docs/adr/` | Architectural decision records, per `ADR-FORMAT.md` in this skill directory. |
| Module `README.md` (each backend service and client) | Architecture and structure in technical detail, patterns explained, Mermaid diagrams for core/complex areas, and how to run that module's unit/integration tests. |
| `.claude/context/CONTEXT.md` | Domain glossary — owned by grill-with-docs, NOT by these formats. Docs link to it rather than redefining terms. |

Design decisions are summarized in module docs only as brief references that link
to the ADR — never duplicated in full.

## The Journey

- The reading order lives in **exactly one place**: an ordered, annotated list in
  the root `README.md` ("read these in order; here's what each gives you").
- Default order: overview (the README itself) → quickstart → tech-stack → backend
  module README → client module README (while clicking around the locally running
  app) → manual-testing walkthrough → debugging guides (skim now, use forever).
- Doc filenames are plain and unnumbered (`quickstart.md`, not `01-quickstart.md`),
  and docs do not link "next" to each other. Reordering the journey is one edit to
  the README list.

## Writing conventions

- **Audience calibration:** assume a brand-new junior dev on a fresh Linux work
  laptop. No undefined acronyms — link `.claude/context/CONTEXT.md` terms or define
  inline. Explain the *why* alongside the *what*.
- **Cite code as repo-relative paths in backticks** (e.g.
  `service/src/main/java/.../MasterService.java`). This is both junior-friendly
  (clickable, findable) and load-bearing: update-docs greps these references
  against changed files to invalidate stale docs.
- **Commands must be copy-paste runnable** — no `<placeholders>` inside commands
  unless immediately explained with a concrete example.
- **Mermaid diagrams** earn their place in module READMEs for core or complex
  areas: sequence diagrams for multi-system flows (scheduled jobs, external API
  calls, message queues), ER diagrams for the core data model, flowcharts for
  architecture. Skip diagrams for simple CRUD.

## Templates

### Root README.md

```markdown
# {App name}

{2–4 paragraphs: what the app does, who uses it (each customer group and their
main use case), and where it sits among neighboring systems.}

## The Journey

New to {app}? Read these in order:

1. This overview — what the app is and who it serves. (You are here.)
2. [Quickstart](docs/quickstart.md) — get the app running locally.
3. [Tech stack](docs/tech-stack.md) — what it's built on and what it talks to.
4. [{Service} README]({service}/README.md) — backend architecture and patterns.
5. [{Client} README]({client}/README.md) — client architecture; read while
   clicking around your locally running app.
6. [Manual testing](docs/manual-testing.md) — walk the app's central functions
   end to end.
7. [Debugging guides](docs/debugging/) — skim now, use forever.

## Reference

- [API reference](docs/api-reference-{service}.md)
- [Architectural decisions](docs/adr/)
- Domain glossary: `.claude/context/CONTEXT.md`
```

### docs/quickstart.md

```markdown
# Quickstart

Goal: {app} running locally — backend up, client served, and you logged in —
starting from a fresh Linux work laptop.

## Prerequisites

{Numbered install steps with exact commands and version checks (`java -version`
should print ...). Include access requests that take lead time (Vault access,
VPN, DB credentials) FIRST, flagged as such.}

## Steps

{Numbered, copy-paste runnable. After each significant step, state the expected
output or how to verify it worked ("you should see `Started {App}Application`
in the logs").}

## Troubleshooting

{One entry per known first-timer failure:}

### {Symptom, as the junior would see it — the actual error text}

{Cause in one sentence, then the fix as runnable commands.}
```

### docs/tech-stack.md

```markdown
# Tech stack

## Core stack

{Table: technology | version | role in this app | where configured (repo-relative
path). One row each for the DB, backend framework, client framework, build tools.}

## External dependencies

{One subsection per external system (e.g. Canvas API, RabbitMQ, Azure, Vault):}

### {Dependency}

- **What we use it for:** {one or two sentences, in this app's domain terms}
- **How the app connects:** {auth mechanism, config location as repo-relative path}
- **How you get access:** {what a new dev requests, from whom}
- **Good to know:** {foundational context and gotchas a junior needs}

## Foundational notes

{Anything about the stack a junior should internalize early: transaction
boundaries, caching behavior, scheduled job model, environments and how they
differ.}
```

### docs/manual-testing.md

```markdown
# Manual testing guide

For junior developers and new QA testers. Each scenario is self-contained:
stage the data, act in the client, verify the outcome.

{Recommended order note if scenarios build on each other.}

## Scenario: {central function being tested}

**Goal:** {what correct behavior looks like, one sentence}

### Data setup

{Runnable SQL INSERT/UPDATE blocks with realistic fake values, plus which
environment/schema to run them against. Note anything the SQL depends on.}

### Steps

{Numbered client actions: where to navigate, what to click, what to enter.}

### Expected results

{What appears in the client AND what changed in the database (verification
SELECTs where useful). Cover the failure path where the scenario has one.}

### Cleanup

{SQL to remove the staged data, when needed.}
```

### docs/debugging/ playbooks

One file per question, named as a question slug (e.g.
`why-isnt-a-course-appearing.md`):

```markdown
# {The question, phrased the way the customer asks it}

## Answer path

{Numbered diagnostic steps, most-likely cause first. Each step: what to check,
the exact SQL (or log location, or client action) to check it, and what each
possible result means — "if `STATUS = 'PENDING'`, the sync job hasn't run yet;
see step 3".}

## Gotchas

{Caveats that trip people up during this diagnosis — weird caching, timing
windows, misleading UI states. One bolded line each with a short explanation.}
```

Cross-cutting gotchas that don't belong to one question go in
`docs/debugging/gotchas.md` with the same one-bolded-line-each format.

### docs/api-reference-{service}.md

One file per backend service. Organized by resource/controller. Junior-oriented —
purpose and shape, not full OpenAPI verbosity:

```markdown
### {METHOD} {/api/path}

{What it's for and which client screen or job calls it, 1–2 sentences.}

- Query params: {name — semantics, one line each}
- Returns: {response shape in words, linking a TypeScript interface or sample
  JSON where it helps}
- Roles: {role-based behavior differences, if any}
- Errors: {non-obvious failure responses}
```

If the service already runs springdoc/Swagger, keep entries thinner and link the
Swagger UI instead of duplicating schemas.

### Module README.md (backend service or Angular client)

```markdown
# {Module name}

{What this module is responsible for, 2–3 sentences.}

## Architecture

{Prose + Mermaid for the core flows. Backend: request lifecycle, scheduled jobs,
messaging. Client: route/module structure, state and HTTP service approach.}

## Structure

{Annotated package/directory listing — one line per package saying what belongs
there.}

## Patterns

{One subsection per pattern a junior must follow:}

### {Pattern name}

{What it is, why we do it this way (link the ADR when one exists), and the
exemplar to copy — cite the repo-relative path of the file that demonstrates it.}

## Running tests

{Copy-paste commands: full suite, a single test class, a single test method.
Note any setup the tests need (DB containers, env vars) and how long a full
run takes.}
```

## Drift source signals

update-docs uses these to decide which existing docs a batch of commits makes
suspect. A doc is invalidated when the window's commits touch:

| Doc | Source signals |
|---|---|
| `quickstart.md` | Build files (`build.gradle`, `package.json`), Docker/compose files, env/config templates, infra or Vault setup scripts |
| `tech-stack.md` | Dependency manifests; new external API client packages |
| `manual-testing.md` | Schema migrations/DDL, seed SQL, controller endpoints, Angular routes |
| `debugging/*` | The tables, services, and files each playbook's steps reference |
| `api-reference-{service}.md` | That service's controllers (exact check: set-diff endpoints in doc vs `@RestController` mappings in code) |
| Module README | Structural changes in that module's source tree (new packages, components, services) — not line edits inside existing files |
| Root README | Modules added/removed; app purpose changes (rare — mostly bootstrap-once) |

Plus two global rules, applied to every doc including ADRs:

- **Reference invalidation:** grep docs for repo-relative paths and class names;
  intersect with the window's changed files. Any hit makes the doc suspect. A
  referenced file that was renamed or deleted is **hard drift** — report it as a
  broken reference without further inspection.
- **Stale threshold:** any doc not fully inspected in over 6 months is flagged
  "due for a full re-read" (catches drift with causes outside the repo — new
  Vault policies, Azure changes — and docs wrong from day one).

## ADRs

Format and lifecycle per `ADR-FORMAT.md` in this skill directory. The rules that
interact with the other docs:

- ADRs live in `docs/adr/`, numbered `0001-short-slug.md`.
- ADRs are written **post-implementation only**, by the `update-docs` skill, from
  concrete merged code. Planning sessions record decisions in their
  `OVERVIEW.md` `## Decisions made this session` section (see `plan-to-jira`)
  instead — that record is the rationale source update-docs harvests later.
- Module docs summarize a decision in at most a line or two and link the ADR.

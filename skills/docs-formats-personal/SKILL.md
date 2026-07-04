---
name: docs-formats-personal
description: Documentation formats and conventions for PERSONAL repos — the same layered map, journey structure, junior-first templates, and drift source signals as docs-formats, made stack-agnostic so they apply to whatever stack the project happens to use. Defines the deltas from the work formats (ADR location and lifecycle, conditional docs, generic drift signals); read alongside docs-formats/SKILL.md, which owns the templates. Used by update-docs-personal; the personal counterpart of docs-formats.
---

# docs-formats-personal

The personal counterpart of `docs-formats`. Read `../docs-formats/SKILL.md` now —
its layered map, journey structure, writing conventions, and templates all apply
here. This file defines only what changes for personal repos: the stack-agnostic
substitutions, the ADR delta, and the generic drift signals.

Personal repos are any stack. The reader is a capable developer who has never seen
this project — future-you after six months away, an occasional contributor, or a
Claude Code session orienting cold. Keep the same junior-first voice: no undefined
acronyms, explain the *why* alongside the *what*, commands copy-paste runnable.

## Stack-agnostic substitutions

Apply these when using the docs-formats templates in a personal repo:

| docs-formats says | Personal repo equivalent |
|---|---|
| "fresh Linux work laptop" | Fresh machine of whatever OS the project targets. Note OS assumptions explicitly. |
| SQL data setup in `manual-testing.md` | Whatever stages state in this repo: seed scripts, fixtures, API calls, SQL, or manual UI steps. Same shape — stage, act, verify, clean up. |
| `api-reference-{service}.md` per backend service | Only for projects that expose an API. Skip entirely for CLIs, libraries, and static sites; a library's public interface reference belongs in its module README instead. |
| Module `README.md` per backend service and client | One per substantial module in multi-module repos. Single-module repos fold this content into `docs/architecture.md` and put it in the same Journey slot. |
| springdoc/Swagger note | Any generated API docs the stack provides (OpenAPI, GraphQL introspection, typedoc): keep entries thinner and link the generated docs. |
| Mermaid for scheduled jobs / message queues / ER diagrams | Same rule, generic: sequence diagrams for multi-system flows, ER-style diagrams for the core data model, flowcharts for architecture. Skip diagrams for simple CRUD. |
| Vault/VPN/DB access requests in `quickstart.md` | External accounts and API keys the project needs (deploy platform, third-party APIs), flagged first when they have lead time. |

The Journey keeps the same shape and single-source rule: overview → quickstart →
tech-stack → module README(s) (or `architecture.md`) → manual-testing → debugging.
Drop steps whose doc doesn't exist for this project type rather than writing
filler docs.

## ADRs — the personal delta

Location and naming per `../docs-formats/ADR-FORMAT.md` (personal section) and
`github-formats`: `.claude/context/adr/`, named `issue-<number>-<topic-slug>.md`
(no global sequential numbers — they can't survive concurrent agents). ADRs
without a backing issue (e.g. from an architecture session) use
`arch-<topic-slug>.md`.

Lifecycle differs from work repos: personal ADRs are written **inline** — by
`pickup-issue-personal` Phase 7, by grilling sessions, and by
`improve-codebase-architecture-personal` when a candidate is rejected for a
load-bearing reason. `update-docs-personal` does not own ADR writing; its harvest
only catches candidates those sessions missed. The three-part ADR test (hard to
reverse AND surprising without context AND a real trade-off) is unchanged.

## Drift source signals

`update-docs-personal` uses these to decide which existing docs a batch of commits
makes suspect. Stack-agnostic versions of the docs-formats table:

| Doc | Source signals |
|---|---|
| `quickstart.md` | Build/dependency manifests (`package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, …), container/compose files, env/config templates, setup or install scripts |
| `tech-stack.md` | Dependency manifests; new external API client packages or SDK imports |
| `manual-testing.md` | Schema migrations, seed data, route/endpoint/command definitions, UI page or view additions |
| `debugging/*` | The data stores, modules, and files each playbook's steps reference |
| `api-reference-*.md` | The files defining routes/endpoints (exact check: set-diff endpoints in doc vs route definitions in code) |
| Module README / `architecture.md` | Structural changes in that module's source tree (new packages, directories, top-level components) — not line edits inside existing files |
| Root README | Modules added/removed; app purpose changes (rare — mostly bootstrap-once) |

The two global rules from docs-formats apply unchanged to every doc including
ADRs: **reference invalidation** (grep docs for repo-relative paths and
class/module names, intersect with the window's changed files; renamed or deleted
references are hard drift) and the **6-month stale threshold** ("due for a full
re-read").

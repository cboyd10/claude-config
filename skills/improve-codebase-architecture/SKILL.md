---
name: improve-codebase-architecture
description: Find deepening opportunities in a codebase, informed by the domain language in CONTEXT.md and the decisions in docs/adr/. Use when the user wants to improve architecture, find refactoring opportunities, consolidate tightly-coupled modules, or make a codebase more testable and AI-navigable. Tailored for Angular client / Spring Boot back end / SQL stacks.
---

# Improve Codebase Architecture

Surface architectural friction and propose **deepening opportunities** — refactors that turn shallow modules into deep ones. The aim is testability and AI-navigability.

## Glossary

Use these terms exactly in every suggestion. Consistent language is the point — don't drift into "component," "service," "API," or "boundary." Full definitions in [LANGUAGE.md](LANGUAGE.md).

- **Module** — anything with an interface and an implementation (function, class, package, slice).
- **Interface** — everything a caller must know to use the module: types, invariants, error modes, ordering, config. Not just the type signature.
- **Implementation** — the code inside.
- **Depth** — leverage at the interface: a lot of behaviour behind a small interface. **Deep** = high leverage. **Shallow** = interface nearly as complex as the implementation.
- **Seam** — where an interface lives; a place behaviour can be altered without editing in place. (Use this, not "boundary.")
- **Adapter** — a concrete thing satisfying an interface at a seam.
- **Leverage** — what callers get from depth.
- **Locality** — what maintainers get from depth: change, bugs, knowledge concentrated in one place.

Key principles (see [LANGUAGE.md](LANGUAGE.md) for the full list):

- **Deletion test**: imagine deleting the module. If complexity vanishes, it was a pass-through. If complexity reappears across N callers, it was earning its keep.
- **The interface is the test surface.**
- **One adapter = hypothetical seam. Two adapters = real seam.**

This skill is _informed_ by the project's domain model. The domain language gives names to good seams; ADRs record decisions the skill should not re-litigate.

## Stack-aware exploration (Angular / Spring Boot / SQL)

When exploring before or during grilling, ground yourself in the following layer-specific patterns. These are where shallow modules and leaking seams concentrate most in this stack.

### Spring Boot (back end)

- **Controller → Service → Repository pass-throughs.** A `@Service` that does nothing but delegate every method to a single `@Repository` is shallow — the service layer has no depth, and callers effectively cross two seams to reach one implementation. Apply the deletion test: if removing the service forces repository calls into the controller, the service was earning its keep. If the controller just gains a direct repo call, the service was a pass-through.
- **Business logic in controllers or repositories.** Watch for controllers that build domain objects, validate, or apply business rules directly — these belong behind a service seam. Similarly, query methods on repositories that encode business rules (complex derived finders, multi-step filtering) may be pulling logic that belongs in the service.
- **`@Transactional` leaking across seams.** If callers must be aware of transaction boundaries — or if transactional behaviour is scattered across controller, service, and repository — that's a seam discipline failure. Transaction management should be an internal concern of the service, not visible to the controller.
- **JPA entities with business logic.** Entities that accumulate business methods become a hidden module inside the persistence layer. Note when entity methods are the real home of logic callers are trying to reach, and whether that's intentional or accidental.
- **N+1 and scattered query logic.** When the same data-fetching pattern is repeated across multiple services (each calling the same repository methods in sequence), that's a shallow coordination layer — a candidate for a deeper service that owns the query and its derivatives.

### Angular (front end)

- **Smart components reaching past service seams.** A component that constructs `HttpParams`, builds request bodies, or maps raw API responses is leaking across the service seam. The service should hide the HTTP transport entirely.
- **Services that wrap `HttpClient` with no added logic.** An Angular service that does nothing but proxy HTTP calls has a shallow interface — it's not earning the seam. Candidates for either deletion (inline the call) or deepening (add mapping, caching, error normalisation).
- **State management fragmentation.** Watch for the same piece of state maintained redundantly in a component, a service, and a resolver. Each copy is a shallow reflection of the others — a candidate for a single deep state module.
- **Template logic.** Business rules expressed in template conditionals (`*ngIf`, pipes, inline ternaries) rather than in a service or component method reduce testability — the template has no test surface.

### SQL / JPA

- **Query logic in service vs. repository.** Watch for services that fetch a collection from a repository and then filter, sort, or transform it in Java — often the query could be pushed into the repository where it runs in the database and the repository interface becomes deeper.
- **Lazy-loading side effects crossing seams.** If a `@ManyToOne` or `@OneToMany` association is fetched lazily and callers depend on triggering that load at a specific point, the load behaviour is leaking through the entity into the caller. Note where eager vs. lazy loading is a hidden coupling.
- **Schema migrations (Liquibase/Flyway).** When exploring, check changelogs for repeated patterns across migrations — copy-pasted column definitions, duplicated constraint patterns. These are locality issues worth flagging.

When you state how something currently works, cite the file. If the user's description contradicts the code, surface the contradiction immediately.

## Process

### 1. Explore

Read the project's domain glossary (`.claude/context/CONTEXT.md`) and any ADRs in `docs/adr/` (or legacy `.claude/context/adr/`) first. In a work repo, resolve the shared-doc root per [../WORKTREE-CONTEXT.md](../WORKTREE-CONTEXT.md) before reading `CONTEXT.md`.

Then use the Agent tool with `subagent_type=Explore` to walk the codebase. Require
the report contract in [../grill-with-docs/EXPLORATION.md](../grill-with-docs/EXPLORATION.md). Don't follow rigid heuristics — explore organically and note where you experience friction:

- Where does understanding one concept require bouncing between many small modules?
- Where are modules **shallow** — interface nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, but the real bugs hide in how they're called (no **locality**)?
- Where do tightly-coupled modules leak across their seams?
- Which parts of the codebase are untested, or hard to test through their current interface?

Apply the **deletion test** to anything you suspect is shallow: would deleting it concentrate complexity, or just move it? A "yes, concentrates" is the signal you want.

### 2. Present candidates as an HTML report

Write a self-contained HTML file to the OS temp directory so nothing lands in the repo. Resolve the temp dir from `$TMPDIR`, falling back to `/tmp` (or `%TEMP%` on Windows), and write to `<tmpdir>/architecture-review-<timestamp>.html` so each run gets a fresh file. Open it for the user — `xdg-open <path>` on Linux, `open <path>` on macOS, `start <path>` on Windows — and tell them the absolute path.

The report uses **Tailwind via CDN** for layout and styling, and **Mermaid via CDN** for diagrams where a graph/flow/sequence reliably communicates the structure. Mix Mermaid with hand-crafted CSS/SVG visuals — use Mermaid when relationships are graph-shaped (call graphs, dependencies, sequences), and hand-built divs/SVG when you want something more editorial (mass diagrams, cross-sections, collapse animations). Each candidate gets a **before/after visualisation**. Be visual.

For each candidate, the same template as before, but rendered as a card:

- **Files** — which files/modules are involved
- **Problem** — why the current architecture is causing friction
- **Solution** — plain English description of what would change
- **Benefits** — explained in terms of locality and leverage, and how tests would improve
- **Before / After diagram** — side-by-side, custom-drawn, illustrating the shallowness and the deepening
- **Recommendation strength** — one of `Strong`, `Worth exploring`, `Speculative`, rendered as a badge

End the report with a **Top recommendation** section: which candidate you'd tackle first and why.

**Use CONTEXT.md vocabulary for the domain, and [LANGUAGE.md](LANGUAGE.md) vocabulary for the architecture.** If `CONTEXT.md` defines "Order," talk about "the Order intake module" — not "the FooBarHandler," and not "the Order service."

**ADR conflicts**: if a candidate contradicts an existing ADR, only surface it when the friction is real enough to warrant revisiting the ADR. Mark it clearly in the card (e.g. a warning callout: _"contradicts ADR-0007 — but worth reopening because…"_). Don't list every theoretical refactor an ADR forbids.

See [HTML-REPORT.md](HTML-REPORT.md) for the full HTML scaffold, diagram patterns, and styling guidance.

Do NOT propose interfaces yet. After the file is written, ask the user: "Which of these would you like to explore?"

### 3. Grilling loop

Once the user picks a candidate, drop into a grilling conversation. Walk the design tree with them — constraints, dependencies, the shape of the deepened module, what sits behind the seam, what tests survive.

Side effects happen inline as decisions crystallize:

- **Naming a deepened module after a concept not in `CONTEXT.md`?** Add the term to `.claude/context/CONTEXT.md` — same discipline as `/grill-with-docs` (see [CONTEXT-FORMAT.md](../grill-with-docs/CONTEXT-FORMAT.md)). Create the file lazily if it doesn't exist.
- **Sharpening a fuzzy term during the conversation?** Update `.claude/context/CONTEXT.md` right there.
- **User rejects the candidate with a load-bearing reason?** Offer an ADR in `docs/adr/`, framed as: _"Want me to record this as an ADR so future architecture reviews don't re-suggest it?"_ Only offer when the reason would actually be needed by a future explorer to avoid re-suggesting the same thing — skip ephemeral reasons ("not worth it right now") and self-evident ones. See [ADR-FORMAT.md](../docs-formats/ADR-FORMAT.md).
- **Want to explore alternative interfaces for the deepened module?** See [INTERFACE-DESIGN.md](INTERFACE-DESIGN.md).

---
name: jira-formats
description: The team's Jira issue templates and conventions — user story format, technical story format, sub-task format, acceptance criteria style, and formatting rules. Read this whenever writing or revising Jira issue documentation, before drafting any story, sub-task, or acceptance criteria. Used by plan-to-jira; also consult it during grilling when proposing issue breakdowns so proposals match the team's conventions.
---

# jira-formats

Templates and conventions derived from the team's real issues (e.g. LDB-1246,
LDB-1254). Match them exactly — the goal is that pasted issues are
indistinguishable from ones the lead wrote by hand.

## Issue types in use

- **User Story** — user-observable capability, testable end to end. Title:
  `As a(n) {role}, I can {capability}` (e.g. "As an admin, I can view master
  course information").
- **Technical Story** — backend/infrastructure work with no direct UI surface.
  Title: imperative description of the work (e.g. "Create scheduled job to
  create/update Canvas course masters for current and upcoming terms").
- **Sub-task** — created under a story only when the story is large enough that
  implementing it as one PR would be too big. Sub-tasks exist to keep PRs small.

## Formatting conventions (all issue types)

- **Bold** for UI elements, menu items, routes, and endpoint paths the user/dev
  interacts with: **Masters**, **/masters**, **GET /api/masters**, **page**.
- `Backticks` for code identifiers, DB objects, and naming conventions:
  `TERM_VIEW`, `MASTER`, `_LUO_MASTER_{term}`, `isBlueprint`.
- Naming conventions use `{placeholder}` syntax inside backticks.
- ~~Strikethrough~~ for descoped requirements — keep them visible in the
  description rather than deleting, so the descoping decision is on record.
- Cross-reference other issues by key when known, otherwise by planning-file slug:
  "The actual process of getting the masters will be completed by LDB-1254..."
- Code blocks with language tags for SQL, TypeScript, JSON, Java.

## Acceptance criteria rules

- A bulleted list under an `## Acceptance Criteria` heading.
- Every bullet starts with **"Should"** and describes one independently testable
  behavior.
- Phrase from the observer's perspective: what the user sees (user stories) or what
  the system does (technical stories).
- Cover the failure path, not just the happy path ("Should display an error message
  if the fetch to get master courses fails").
- Each enumerable variant gets its own bullet (one per naming convention, per
  status, per page state) rather than one compound bullet.
- ACs define done for the whole story; sub-tasks do not get their own AC sections.

## User Story template

```markdown
# As a(n) {role}, I can {capability}

**Type:** User Story

## Description

{Prose, ordered by how the user encounters the feature: entry point/navigation →
main view/behavior → interactions (filtering, paging, links) → error states.}

{Back end contract paragraph: the endpoint(s) this story needs, in prose — method
and path in bold, query parameters in bold, page sizes, filter semantics.}

{Dependency paragraph, if any: name the blocking issue, state what it will deliver,
and prescribe the interim approach for THIS issue (mock data, stub), including a
sample SQL query or fixture to generate realistic data.}

### Other Helpful Information

{TypeScript interface(s) for the front end model.}

{Sample JSON payload with realistic values.}

## Acceptance Criteria

* Should ...
* Should ...

## Sub-tasks

{Only when the story is too large for one PR — see sizing rules below.}

## Attachments

{Relative links to Mermaid diagrams etc., when present.}
```

## Technical Story template

```markdown
# {Imperative description of the work}

**Type:** Technical Story

## Description

{Prose: the trigger/schedule, the data sources (tables/views in backticks), the
external APIs and how they're queried (naming conventions as bulleted list of
`{placeholder}` patterns when there are several), filtering/exclusion rules, and
persistence behavior (insert vs update semantics).}

### Other Helpful Information

{Optional: relevant SQL, interface definitions, API response shapes.}

## Acceptance Criteria

* Should ...
* Should ...

## Sub-tasks

{Only when needed.}

## Attachments

{Sequence diagram link for multi-system flows — scheduled jobs calling external
APIs warrant one.}
```

## Sub-task format

> PROVISIONAL — drafted without a real sub-task example. Replace with the team's
> actual format when one is provided, then delete this note.

Inside the parent issue file, under `## Sub-tasks`:

```markdown
### {N}. {Imperative title scoped to one PR}

{2–5 sentences: what this sub-task delivers, which layer(s) it touches, what it
must NOT include (left for a later sub-task), and what it can rely on from earlier
sub-tasks. Name concrete files/classes/tables where known.}
```

## Sub-task sizing rules

- Split a story into sub-tasks only when the total changes are too large for one reviewable PR. For stories that touch one concern across one or two files — a single entity change, a self-contained scheduled method, a small Angular model update — keep it as one PR. The layer-by-layer split (DB → service → controller → Angular) is the default pattern for stories that span all layers end-to-end.
- A sub-task should be implementable and reviewable as a single PR of manageable size.
- Order sub-tasks so each is testable/demonstrable when merged (mock or stub the not-yet-built layers above, as in the LDB-1246 mock-data approach).

## Tier calibration

- **Junior**: prescribe more — name files, classes, endpoints, and patterns to copy;
  include sample payloads and queries; spell out edge cases in the description.
- **Mid-level**: state intent, contracts, and constraints; leave implementation
  approach open; flag the risky parts rather than prescribing solutions.
- Never write the tier into the issue text itself (it would be pasted into Jira) —
  tier suggestions live only in the planning session's `00-overview.md` issue map.

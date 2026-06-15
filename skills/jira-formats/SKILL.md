---
name: jira-formats
description: The team's Jira issue templates and conventions — user story format, technical story format, bug format, improvement format, sub-task format, acceptance criteria style, and formatting rules. Read this whenever writing or revising Jira issue documentation, before drafting any story, sub-task, or acceptance criteria. Used by plan-to-jira; also consult it during grilling when proposing issue breakdowns so proposals match the team's conventions.
---

# jira-formats

Templates and conventions derived from the team's real issues. Match them exactly — the goal is that pasted issues are indistinguishable from ones the lead wrote by hand.

## Issue types in use

- **User Story** — user-observable capability, testable end to end. Title: `As a(n) {role}, I can {capability}`.
- **Technical Story** — backend/infrastructure work with no direct UI surface. Title: imperative description of the work.
- **Bug** — corrects unexpected behavior. Use when grilling a ticket or report about something not working as intended that requires code changes to fix. Title: imperative description of what is being fixed.
- **Improvement** — non-behavioral enhancement to the codebase or user experience. Use for stylistic changes, small refactors, and other changes that do not affect existing behavior or features. Title: imperative description of what is being improved.
- **Sub-task** — created under a story only when the story is large enough that implementing it as one PR would be too big. Sub-tasks exist to keep PRs small.

## Formatting conventions (all issue types)

- All description field content **MUST** use valid Jira Wiki Markup syntax — not Markdown.
- `*text*` (single asterisks) for bold: UI elements, menu items, routes, endpoint paths.
- `{{text}}` (double curly braces) for monospace/inline code: code identifiers, DB objects, naming conventions.
- Naming conventions use `{placeholder}` syntax inside `{{}}` to mark variable parts.
- `-text-` (hyphens) for strikethrough: descoped requirements — keep visible rather than deleting.
- Cross-reference other issues by key when known, otherwise by planning-file slug.
- Code blocks with language tag: `{code:java}`, `{code:sql}`, `{code:javascript}`, closed with `{code}`.
- Section sub-headings within the description body use Jira heading syntax: `h3. Other Helpful Information`, `h3. Testing`, `h3. Steps to Reproduce`, etc. — never Markdown `###`.

## Acceptance criteria rules

- A bulleted list under an `## Acceptance Criteria` heading.
- Every bullet starts with **"Should"** and describes one independently testable behavior.
- Phrase from the observer's perspective: what the user sees (user stories) or what the system does (technical/bug/improvement stories).
- Cover the failure path, not just the happy path.
- Each enumerable variant gets its own bullet rather than one compound bullet.
- ACs define done for the whole story; sub-tasks do not get their own AC sections.
- Bullets must use **plain text only** — no Jira Wiki Markup (`{{}}`, `*bold*`, `{code}`). Each bullet is pasted as the title of a separate Jira "Acceptance Criteria" issue, and issue titles do not render markup.

## Original Estimate rules

- Expressed in hours. Must be divisible by 3 (e.g. 3, 6, 9, 12, 15...).
- Represents the hours a junior developer would be expected to spend completing the work.
- For issues with sub-tasks, the parent estimate equals the sum of all sub-task estimates.

## User Story template

```markdown
# As a(n) {role}, I can {capability}

**Issue Type:** User Story

**Original Estimate:** {hours, divisible by 3}

## Description

{Prose, ordered by how the user encounters the feature: entry point/navigation →
main view/behavior → interactions (filtering, paging, links) → error states.}

{Back end contract paragraph: the endpoint(s) this story needs, in prose — method
and path in bold, query parameters in bold, page sizes, filter semantics.}

{Dependency paragraph, if any: name the blocking issue, state what it will deliver,
and prescribe the interim approach for THIS issue (mock data, stub), including a
sample SQL query or fixture to generate realistic data.}

h3. Other Helpful Information

{TypeScript interface(s) for the front end model.}

{Sample JSON payload with realistic values.}

h3. Testing

{Optional. Include only when there is helpful information for the developer or QAE
to manually verify the issue is completed successfully. Omit this section entirely
if not applicable.}

## Acceptance Criteria

* Should ...
* Should ...

## Sub-tasks

{Only when the story is too large for one PR — see sizing rules below.}

## Attachments

{Optional. Relative links to Mermaid diagrams etc., when present.}
```

## Technical Story template

```markdown
# {Imperative description of the work}

**Issue Type:** Technical Story

**Original Estimate:** {hours, divisible by 3}

## Description

{Prose: the trigger/schedule, the data sources (tables/views in monospace), the
external APIs and how they're queried (naming conventions as bulleted list of
{{placeholder}} patterns when there are several), filtering/exclusion rules, and
persistence behavior (insert vs update semantics).}

h3. Other Helpful Information

{Reference any existing code the developer should read before implementing —
name the file, class, or method and note what the new implementation
preserves, simplifies, or replaces. Then include pseudocode in a {code:java}
(or appropriate language) block showing the skeleton of the new
implementation: the key method calls, branching logic, and persistence
pattern. Junior developers should be able to orient and start coding from
this section alone.}

h3. Testing

{Optional. Include only when there is helpful information for the developer or QAE
to manually verify the issue is completed successfully. Omit this section entirely
if not applicable.}

## Acceptance Criteria

* Should ...
* Should ...

## Sub-tasks

{Only when needed.}

## Attachments

{Optional. Sequence diagram link for multi-system flows — scheduled jobs calling
external APIs warrant one.}
```

## Bug template

```markdown
# {Imperative description of what is being fixed}

**Issue Type:** Bug

**Original Estimate:** {hours, divisible by 3}

## Description

{Prose context: what component or feature is affected and under what conditions
the bug occurs.}

h3. Steps to Reproduce

{Numbered steps a developer or QAE can follow to observe the bug.}

h3. Expected Behavior

{What should happen.}

h3. Actual Behavior

{What currently happens instead.}

h3. Other Helpful Information

{Optional: relevant stack traces, screenshots, log output, or code references.}

h3. Testing

{Optional. Include only when there is helpful information for the developer or QAE
to manually verify the bug is resolved. Omit this section entirely if not applicable.}

## Acceptance Criteria

* Should ...
* Should ...

## Sub-tasks

{Only when needed.}

## Attachments

{Optional.}
```

## Improvement template

```markdown
# {Imperative description of what is being improved}

**Issue Type:** Improvement

**Original Estimate:** {hours, divisible by 3}

## Description

{Prose: what is being improved, why it is being improved, and what the desired
end state looks like. Reference existing code being changed where relevant.}

h3. Other Helpful Information

{Optional: relevant code snippets, before/after examples, or style references.}

h3. Testing

{Optional. Include only when there is helpful information for the developer or QAE
to manually verify the improvement. Omit this section entirely if not applicable.}

## Acceptance Criteria

* Should ...
* Should ...

## Sub-tasks

{Only when needed.}

## Attachments

{Optional.}
```

## Sub-task format

Inside the parent issue file, under `## Sub-tasks`:

```markdown
### {N}. {One-sentence summary of the sub-task}

**Original Estimate:** {hours, divisible by 3}

#### Description

{Prose: what this sub-task delivers, which layer(s) it touches, what it must NOT
include (left for a later sub-task), and what it can rely on from earlier
sub-tasks. Name concrete files/classes/tables where known. Must use valid Jira
Wiki Markup syntax.}
```

## Sub-task sizing rules

- Split a story into sub-tasks only when the total changes are too large for one reviewable PR.
- For stories that touch one concern across one or two files, keep it as one PR.
- The layer-by-layer split (DB → service → controller → Angular) is the default pattern for stories that span all layers end-to-end.
- A sub-task should be implementable and reviewable as a single PR of manageable size.
- Order sub-tasks so each is testable/demonstrable when merged (mock or stub the not-yet-built layers above).

## Tier calibration

- **Junior**: prescribe more — name files, classes, endpoints, and patterns to copy; include sample payloads and queries; spell out edge cases in the description.
- **Mid-level**: state intent, contracts, and constraints; leave implementation approach open; flag the risky parts rather than prescribing solutions.
- Never write the tier into the issue text itself — tier suggestions live only in the planning session's `00-overview.md` issue map.
